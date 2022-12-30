package com.poker.importer.repository;

import com.poker.importer.model.PokerLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Set;

@Repository
public interface PokerLineRepository extends JpaRepository<PokerLine, Long> {
    String SELECT_DISTINCT_HAND_ID =
            "select distinct hand_id from pokerline";
    @Query(value = SELECT_DISTINCT_HAND_ID, nativeQuery = true)
    Set<Long> getDistinctHandIds();


    long countByTournamentId(long tournamentId);
}
