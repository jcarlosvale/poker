DROP TABLE IF EXISTS public.player_position;

CREATE TABLE public.player_position (
    hand_id bigint NOT NULL,
    position int NOT NULL,
    stack int NOT NULL,
    nickname varchar NULL,
    CONSTRAINT PK_PlayerPosition PRIMARY KEY (hand_id, position)
);


-- public.player_position foreign keys

ALTER TABLE public.player_position ADD CONSTRAINT FK_PlayerPosition_Hand FOREIGN KEY (hand_id) REFERENCES public.hands(hand_id);
ALTER TABLE public.player_position ADD CONSTRAINT FK_PlayerPosition_Player FOREIGN KEY (nickname) REFERENCES public.players(nickname);