drop table if exists tournaments;
CREATE TABLE public.tournaments (
    tournament_id bigint NOT NULL,
    created_at timestamp NOT NULL,
    file_name varchar NOT NULL,
    CONSTRAINT PK_TOURNAMENT PRIMARY KEY (tournament_id)
);