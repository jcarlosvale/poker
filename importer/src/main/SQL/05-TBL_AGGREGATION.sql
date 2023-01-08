DROP TABLE IF EXISTS PUBLIC.AGGREGATION;

CREATE TABLE PUBLIC.AGGREGATION
(

    nickname varchar NOT NULL, -- insert consolidation
    cards varchar default '', -- update cards consolidation
    qty_hands int default 0, -- insert consolidation

    qty_shows int default 0, -- update cards consolidation
    avg_shows decimal(5,2), -- insert consolidation, update cards consolidation

    qty_in_action int default 0, --update player fold round consolidation
    avg_in_action decimal(5,2), --update player fold round consolidation

    qty_fold_preflop int default 0, --update player fold round consolidation
    avg_fold_preflop decimal(5,2), --update player fold round consolidation

    qty_fold_flop int default 0, --update player fold round consolidation
    avg_fold_flop decimal(5,2), --update player fold round consolidation

    qty_fold_turn int default 0, --update player fold round consolidation
    avg_fold_turn decimal(5,2), --update player fold round consolidation

    qty_fold_river int default 0, --update player fold round consolidation
    avg_fold_river decimal(5,2), --update player fold round consolidation

    sum_chen int default 0, -- update cards consolidation
    qty_chen int default 0, -- update cards consolidation
    avg_chen decimal(5,2), -- update cards consolidation

    qty_play_button int default 0, --update player fold round consolidation
    sum_play_button int default 0, --update player fold round consolidation
    avg_play_button decimal(5,2), --update player fold round consolidation

    qty_play_small_blind int default 0, --update player fold round consolidation
    sum_play_small_blind int default 0, --update player fold round consolidation
    avg_play_small_blind decimal(5,2), --update player fold round consolidation

    qty_play_big_blind int default 0, --update player fold round consolidation
    sum_play_big_blind int default 0, --update player fold round consolidation
    avg_play_big_blind decimal(5,2), --update player fold round consolidation

    CONSTRAINT PK_AGGREGATION PRIMARY KEY (nickname)
);