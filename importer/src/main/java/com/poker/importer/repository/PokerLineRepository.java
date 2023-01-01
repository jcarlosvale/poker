package com.poker.importer.repository;

import com.poker.importer.model.PokerLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import javax.transaction.Transactional;
import java.util.Set;

@Repository
public interface PokerLineRepository extends JpaRepository<PokerLine, Long> {
    String SELECT_DISTINCT_HAND_ID =
            "select distinct hand_id from pokerline";
    @Query(value = SELECT_DISTINCT_HAND_ID, nativeQuery = true)
    Set<Long> getDistinctHandIds();

    long countByTournamentId(long tournamentId);

    String CALL_PROCEDURE_INSERT_HAND_CONSOLIDATION = "call insertHandConsolidation(:filename);";
    @Query(value = CALL_PROCEDURE_INSERT_HAND_CONSOLIDATION, nativeQuery = true)
    @Transactional
    @Modifying(clearAutomatically = true)
    void insertHandConsolidation(@Param("filename") String filename);
}
