DROP TABLE IF EXISTS public.lose_position;

CREATE TABLE public.lose_position (
    hand BIGINT NOT NULL,
    position int NOT NULL,
    hand_description varchar NULL,
    CONSTRAINT PK_LosePosition PRIMARY KEY (hand, position)
);


ALTER TABLE public.lose_position
    ADD CONSTRAINT FK_LosePosition FOREIGN KEY (hand,position)
    REFERENCES public.player_position(hand_id,position);