DROP TABLE IF EXISTS public.hand_position;

CREATE TABLE public.hand_position (
    hand_id bigint NOT NULL,
    button int NOT NULL,
    max_pos int NOT NULL,
    min_pos int NOT NULL,
    number_of_players int NOT NULL,
    positions varchar NOT NULL,
    CONSTRAINT PK_HandPosition PRIMARY KEY (hand_id)
);