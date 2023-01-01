package com.poker.importer;

import com.poker.importer.repository.CardsRepository;
import com.poker.importer.service.FileImportService;
import com.poker.importer.util.CardsGenerator;
import lombok.AllArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.IOException;

@AllArgsConstructor
@SpringBootApplication
public class Main implements CommandLineRunner {

    private final FileImportService service;
    private final CardsRepository cardsRepository;

    public static void main(String[] args) throws IOException {
        SpringApplication.run(Main.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        String folder = "C:\\Users\\jcarlos\\AppData\\Local\\PokerStars\\HandHistory";
        //String folder = "C:\\temp";
        if (args.length > 0) {
            folder = args[0];
        }

        if (cardsRepository.count() == 0) {
                cardsRepository.saveAll(CardsGenerator.generateCards());
        }

        service.importFiles(folder);
    }
}
