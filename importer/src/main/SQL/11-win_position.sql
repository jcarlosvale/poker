DROP TABLE IF EXISTS public.win_position;

CREATE TABLE public.win_position (
     hand_id bigint NOT NULL,
     position int NOT NULL,
     hand_description varchar NULL,
     pot int NOT NULL,
     showdown bool NOT NULL,
     CONSTRAINT PK_WinPosition PRIMARY KEY (hand_id, "position")
);
-- public.win_position foreign keys
ALTER TABLE public.win_position ADD CONSTRAINT FK_WinPosition FOREIGN KEY (hand_id,position) REFERENCES public.player_position(hand_id,position);