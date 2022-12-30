package com.poker.importer.repository;

import com.poker.importer.model.Cards;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CardsRepository extends JpaRepository<Cards, String> {

}
