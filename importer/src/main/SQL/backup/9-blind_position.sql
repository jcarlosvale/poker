DROP TABLE IF EXISTS public.blind_position;

CREATE TABLE public.blind_position (
    hand_id bigint NOT NULL,
    position int NOT NULL,
    place varchar(20) NOT NULL,
    CONSTRAINT PK_BlindPosition PRIMARY KEY (hand_id, position)
);

-- public.blind_position foreign keys

ALTER TABLE public.blind_position ADD CONSTRAINT FK_BlindPosition FOREIGN KEY (hand_id,position) REFERENCES public.player_position(hand_id,position);