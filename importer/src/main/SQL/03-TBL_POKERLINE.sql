DROP TABLE IF EXISTS public.pokerline;

CREATE TABLE public.pokerline (
    tournament_id int8 NOT NULL,
    line_number int4 NOT NULL,
    table_id int4 NOT NULL,
    hand_id int8 NOT NULL,
    played_at timestamp NOT NULL,

    tournament_level varchar(20),
    big_blind int,
    small_blind int,


    "section" varchar(50) NOT NULL,
    line varchar NOT NULL,
    filename varchar NOT NULL,
    CONSTRAINT pk_pokerline PRIMARY KEY (tournament_id, line_number)
);