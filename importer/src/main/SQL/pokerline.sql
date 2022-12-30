CREATE TABLE public.pokerline
(
    tournament_id bigint NOT NULL,
    line_number integer NOT NULL,
    table_id integer NOT NULL,
    hand_id bigint NOT NULL,
    played_at timestamp without time zone NOT NULL,
    section varchar(50) NOT NULL,
    line varchar NOT NULL,
    filename varchar NOT NULL,

    CONSTRAINT PK_POKERLINE PRIMARY KEY (line_number, tournament_id)
)