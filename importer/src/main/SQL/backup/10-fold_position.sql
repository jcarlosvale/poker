DROP TABLE IF EXISTS public.fold_position;

CREATE TABLE public.fold_position (
    hand_id bigint NOT NULL,
    position int NOT NULL,
    no_bet bool NOT NULL,
    round varchar NOT NULL,
    CONSTRAINT PK_FoldPosition PRIMARY KEY (hand_id, position)
);


-- public.fold_position foreign keys

ALTER TABLE public.fold_position ADD CONSTRAINT FK_FoldPosition FOREIGN KEY (hand_id,"position") REFERENCES public.player_position(hand_id,"position");