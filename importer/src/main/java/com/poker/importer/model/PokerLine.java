package com.poker.importer.model;

import com.sun.istack.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data

@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "pokerline")
@IdClass(PokerLineId.class)
public class PokerLine implements Serializable {

    @Id
    private Long tournamentId;

    @Id
    private Long lineNumber;

    @NotNull
    private Integer tableId;

    @NotNull
    private Long handId;

    @NotNull
    private LocalDateTime playedAt;

    @NotNull
    @Size(max = 50)
    private String section;

    @NotNull
    @Size(max = 255)
    private String line;

    @NotNull
    @Size(max = 255)
    private String filename;
}
