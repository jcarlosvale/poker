DROP TABLE IF EXISTS PUBLIC.CONSOLIDATION;

CREATE TABLE PUBLIC.CONSOLIDATION (

    id SERIAL NOT NULL,

    nickname varchar, --'HEADER' '%Seat %:%in chips%'
    tournament_id bigint,  --'HEADER' '%Seat %:%in chips%'
    hand_id bigint,  --'HEADER' '%Seat %:%in chips%'
    table_id int,  --'HEADER' '%Seat %:%in chips%'

    tournament_level varchar(20), --'HEADER' '%Seat %:%in chips%'
    big_blind int,  --'HEADER' '%Seat %:%in chips%'
    small_blind int,  --'HEADER' '%Seat %:%in chips%'
    button int, -- 'SUMMARY' '%Seat %:%' '%(button)%' '%(small blind)% '%(big blind)%''
    max_pos int DEFAULT -1, --'HEADER' '%Seat %:%in chips%'
    min_pos int DEFAULT 100, --'HEADER' '%Seat %:%in chips%'
    number_of_players int DEFAULT 0, --'HEADER' '%Seat %:%in chips%'
    positions varchar(50) DEFAULT '', --'HEADER' '%Seat %:%in chips%'

    total_pot int, --'SUMMARY' '%Total pot%'
    win_pot int,  -- 'SUMMARY' '%Seat %:%' '%collected%' '%and won %'
    win_showdown bool, -- 'SUMMARY' '%Seat %:%' '%collected%' '%and won %'
    board_cards varchar, --'SUMMARY' '%Board [%]%'
    hand_win_description varchar,  -- 'SUMMARY' '%Seat %:%' '%collected%' '%and won %'
    hand_lose_description varchar, -- 'SUMMARY' '%Seat %:%' '%and lost %'


    player_position int, --'HEADER' '%Seat %:%in chips%'
    player_place varchar(20) CONSTRAINT CK_PLAYER_PLACE CHECK (player_place IN ('small blind', 'big blind', 'button')), -- 'SUMMARY' '%Seat %:%' '%(button)%' '%(small blind)% '%(big blind)%''
    player_stack int,  --'HEADER' '%Seat %:%in chips%'
    player_card_description varchar, -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_card1 char(1), -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_card2 char(1), -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_chen int, -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_card_normalised varchar(3), -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_card_pair bool, -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_card_suited bool, -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_no_bet bool, -- 'SUMMARY' '%Seat %:%' '%folded before Flop%' '%folded on the Flop%' '%folded on the Turn%' '%folded on the River%'
    player_fold_round varchar CONSTRAINT CK_PLAYER_FOLD_ROUND CHECK (player_fold_round IN ('FLOP', 'PREFLOP', 'TURN', 'RIVER')), -- 'SUMMARY' '%Seat %:%' '%folded before Flop%' '%folded on the Flop%' '%folded on the Turn%' '%folded on the River%'
    player_showdown bool DEFAULT false, -- 'SUMMARY' '%Seat %:%' '%mucked [%' '%showed [%'
    player_winner bool DEFAULT false,  -- 'SUMMARY' '%Seat %:%' '%collected%' '%and won %'



    file_name varchar, --'HEADER' '%Seat %:%in chips%'
    line_number int, --'HEADER' '%Seat %:%in chips%'
    played_at timestamp, --'HEADER' '%Seat %:%in chips%'
    updated_at timestamp, --now()


    CONSTRAINT UK_CONSOLIDATION UNIQUE(nickname, tournament_id, hand_id),

    CONSTRAINT PK_CONSOLIDATION PRIMARY KEY (id)
);

CREATE INDEX idx_nickname_consolidation
    on CONSOLIDATION(nickname);

CREATE INDEX idx_hand_id_consolidation
    on CONSOLIDATION(hand_id);

CREATE INDEX idx_tournament_id_consolidation
    on CONSOLIDATION(tournament_id);

CREATE INDEX idx_filename_consolidation
    on CONSOLIDATION(file_name);