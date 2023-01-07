DROP TABLE if exists hands cascade ;

CREATE TABLE public.hands (
    hand_id bigint NOT NULL,
    big_blind int NOT NULL,
    created_at timestamp NOT NULL,
    level varchar(20) NOT NULL,
    played_at timestamp NOT NULL,
    small_blind int NOT NULL,
    table_id int NOT NULL,
    tournament_id bigint NOT NULL,
    CONSTRAINT PK_HANDS PRIMARY KEY (hand_id)
);