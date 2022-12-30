drop table if exists players;

CREATE TABLE public.players (
    nickname varchar NOT NULL,
    created_at timestamp NOT NULL,
    CONSTRAINT PK_PLAYERS PRIMARY KEY (nickname)
);