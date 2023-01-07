package com.poker.importer.service;

import com.poker.importer.model.FileSection;
import com.poker.importer.model.PokerLine;
import com.poker.importer.repository.PokerLineRepository;
import com.zaxxer.hikari.HikariDataSource;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.postgresql.copy.CopyManager;
import org.postgresql.jdbc.PgConnection;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import javax.transaction.Transactional;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.function.Predicate;
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkArgument;

@Service
@RequiredArgsConstructor
@Log4j2
public class FileImportService {

    private static final String FILE_EXTENSION = "txt";
    private int totalFiles;
    private int processedFilesCounter;
    private Set<Long> handIdsCache;

    private final DataSource dataSource;

    private final PokerLineRepository pokerLineRepository;

    public void importFiles(final String folder) {
        long start = System.currentTimeMillis();

        log.info("Importing files from folder {} ...\n", folder);
        this.processedFilesCounter = 0;
        this.totalFiles = FileUtils.listFiles(new File(folder), new String[]{FILE_EXTENSION}, false).size();
        this.handIdsCache = pokerLineRepository.getDistinctHandIds();

        int importedFiles = FileUtils.listFiles(new File(folder), new String[]{FILE_EXTENSION}, false)
                .stream()
                .parallel()
                .map(this::importFile)
                .mapToInt(aBoolean -> aBoolean ? 1 : 0)
                .sum();

        String message = String.format("Imported %d / %d files in %d ms from folder %s",
                importedFiles, totalFiles, (System.currentTimeMillis() - start), folder);

        log.info(message);
    }

    private boolean importFile(File file) {

        log.info("Processing " + file.getName());

        long start = System.currentTimeMillis();

        try {
            List<String> normalisedLines =
                    FileUtils
                    .readLines(file, "utf-8")
                    .stream()
                    .map(String::trim)
                    .filter(StringUtils::isNotBlank)
                    .toList();

            List<PokerLine> listOfPokerLines = extractLinesOfFile(normalisedLines, file.getName());

            Optional<Long> tournamentOptional = persistData(listOfPokerLines);

            tournamentOptional.ifPresent(tournamentId -> {
                checkArgument(listOfPokerLines.size() == pokerLineRepository.countByTournamentId(tournamentId));
                log.info("Imported file {} in {} ms", file.getName(), (System.currentTimeMillis() - start));
            });

            processedFilesCounter++;

            log.info("{}: Processed {}/{} {}ms",
                    file.getName(), processedFilesCounter, totalFiles, (System.currentTimeMillis() - start));

            return tournamentOptional.isPresent();
        } catch (IOException e) {
            log.error(e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private List<PokerLine> extractLinesOfFile(@NonNull final List<String> normalisedLines,
                                               @NonNull final String filename) {
        long start = System.currentTimeMillis();

        List<PokerLine> listOfPokerLines = new ArrayList<>();
        FileSection currentSection = FileSection.HEADER;
        Long handId = null;
        Long tournamentId = null;
        Integer tableId = null;
        long lineNumber = 1L;
        LocalDateTime playedAt = null;
        String tournamentLevel = null;
        Integer bigBlind = null;
        Integer smallBlind = null;

        for(int i = 0; i < normalisedLines.size(); i++) {
            String line = normalisedLines.get(i);
            if (line.contains("PokerStars Hand #")) {
                currentSection = FileSection.HEADER;
                handId = Long.valueOf(StringUtils.substringBetween(line, "PokerStars Hand #", ": Tournament ").trim());
                tournamentId = Long.valueOf(StringUtils.substringBetween(line, ": Tournament #", ", ").trim());
                String strDateTime = StringUtils.substringBetween(line, "[", "]").trim();
                playedAt = toLocalDateTime(strDateTime);

                tournamentLevel = StringUtils.substringBetween(line, "- Level ", " (").trim();
                smallBlind = Integer.valueOf(StringUtils.substringBetween(line," (",  "/").trim());
                bigBlind = Integer.valueOf(StringUtils.substringBetween(line,"/",  ")").trim());

                //GET TABLE ID NEXT LINE
                String tableLine = normalisedLines.get(i+1);
                tableId = Integer.valueOf(StringUtils.substringBetween(tableLine, "Table '" + tournamentId + " ", "'").trim());  //table id
            }
            else if (line.contains("PokerStars Home Game Hand #")) {
                return List.of();  //dont process home games
            }
            else if (line.contains("*** HOLE CARDS ***"))  currentSection = FileSection.PRE_FLOP;
            else if (line.contains("*** FLOP ***"))        currentSection = FileSection.FLOP;
            else if (line.contains("*** TURN ***"))        currentSection = FileSection.TURN;
            else if (line.contains("*** RIVER ***"))       currentSection = FileSection.RIVER;
            else if (line.contains("*** SHOW DOWN ***"))   currentSection = FileSection.SHOWDOWN;
            else if (line.contains("*** SUMMARY ***"))     currentSection = FileSection.SUMMARY;

            listOfPokerLines.add(
                    PokerLine.builder()
                            .tournamentId(tournamentId)
                            .lineNumber(lineNumber)
                            .handId(handId)
                            .tableId(tableId)
                            .playedAt(playedAt)
                            .tournamentLevel(tournamentLevel)
                            .smallBlind(smallBlind)
                            .bigBlind(bigBlind)
                            .section(currentSection.name())
                            .line(line)
                            .filename(filename)
                            .build());
            lineNumber++;
        }

        long end = System.currentTimeMillis();
        log.info("{}: Extracted lines {} ms", filename, (end - start));

        return listOfPokerLines;
    }

    private LocalDateTime toLocalDateTime(String strDateTime) {
        String[] fields = strDateTime.split(" ");
        String[] date = fields[0].split("/");
        String[] time = fields[1].split(":");
        int year = Integer.parseInt(date[0]);
        int month = Integer.parseInt(date[1]);
        int day = Integer.parseInt(date[2]);
        int hour = Integer.parseInt(time[0]);
        int min = Integer.parseInt(time[1]);
        int sec = Integer.parseInt(time[2]);
        return LocalDateTime.of(year,month,day, hour, min, sec);
    }

    @Transactional
    public Optional<Long> persistData(@NonNull final List<PokerLine> listOfPokerLines) {
        long start = System.currentTimeMillis();

        if (listOfPokerLines.isEmpty()) return Optional.empty();

        List<PokerLine> listOfPokerLinesToInsert = filterLinesToInsert(listOfPokerLines);

        if (listOfPokerLinesToInsert.isEmpty()) {
            log.info("File already processed {}", listOfPokerLines.get(0).getFilename());
            return Optional.empty();
        } else {

            try {
                // tournament
        //        pokerLineRepository.insertTournament(listOfPokerLines.get(0).getTournamentId(), listOfPokerLines.get(0).getFilename());
                //save lines
                saveLines(listOfPokerLinesToInsert);
                //hand consolidation
          //      pokerLineRepository.insertHandConsolidation(listOfPokerLines.get(0).getFilename());
                //hand position
          //      pokerLineRepository.insertHandPosition(listOfPokerLines.get(0).getFilename());
            } catch (Exception e) {
                log.error("{}: ERROR {}", listOfPokerLines.get(0).getFilename(), e.getMessage());
                throw e;
            }

            long end = System.currentTimeMillis();
            log.info("{}: Persisted {} ms", listOfPokerLines.get(0).getFilename(), (end - start));

            return Optional.of(listOfPokerLines.get(0).getTournamentId());
        }
    }

    private List<PokerLine> filterLinesToInsert(List<PokerLine> listOfPokerLines) {
        Set<Long> distinctHandsFromFile =
                listOfPokerLines.stream()
                .map(PokerLine::getHandId)
                .collect(Collectors.toSet());

        Set<Long> handIdsToInsert =
                distinctHandsFromFile.stream()
                .filter(Predicate.not(handIdsCache::contains))
                .collect(Collectors.toSet());

        handIdsCache.addAll(handIdsToInsert);

        return
                listOfPokerLines.stream()
                        .filter(pokerLine -> handIdsToInsert.contains(pokerLine.getHandId()))
                        .collect(Collectors.toList());
    }

    private void saveLines(@NonNull final List<PokerLine> listOfPokerLines) {
        log.info("Active connections: " + ((HikariDataSource)dataSource).getHikariPoolMXBean().getActiveConnections());

        try {

            final String COPY = "COPY pokerline (tournament_id, line_number, played_at, tournament_level, big_blind, small_blind, section, line, table_id, hand_id, filename)"
                    + " FROM STDIN WITH (FORMAT TEXT, ENCODING 'UTF-8', DELIMITER '\t',"
                    + " HEADER false)";

            Connection connection = dataSource.getConnection();
            PgConnection unwrapped = connection.unwrap(PgConnection.class);
            CopyManager copyManager = unwrapped.getCopyAPI();

            StringBuilder sb = new StringBuilder();
            for(PokerLine pokerLine : listOfPokerLines) {
                sb.append(pokerLine.getTournamentId()).append("\t");
                sb.append(pokerLine.getLineNumber()).append("\t");
                sb.append(pokerLine.getPlayedAt()).append("\t");
                sb.append(pokerLine.getTournamentLevel()).append("\t");
                sb.append(pokerLine.getBigBlind()).append("\t");
                sb.append(pokerLine.getSmallBlind()).append("\t");
                sb.append(pokerLine.getSection()).append("\t");
                sb.append(pokerLine.getLine()).append("\t");
                sb.append(pokerLine.getTableId()).append("\t");
                sb.append(pokerLine.getHandId()).append("\t");
                sb.append(pokerLine.getFilename()).append("\n");
            }

            if (sb.length() > 0) {
                InputStream is = new ByteArrayInputStream(sb.toString().getBytes());
                copyManager.copyIn(COPY, is);
                sb.setLength(0);
            }
            connection.close();
        } catch (SQLException | IOException e) {
            throw new RuntimeException(e);
        }
    }
}
