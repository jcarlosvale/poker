DROP TABLE IF EXISTS public.cards_of_player;

CREATE TABLE public.cards_of_player (
    hand_id bigint NOT NULL,
    position int NOT NULL,
    description varchar NOT NULL,
    CONSTRAINT PK_CardsOfPlayer PRIMARY KEY (hand_id, "position")
);


-- public.cards_of_player foreign keys

ALTER TABLE public.cards_of_player ADD CONSTRAINT FK_CardsOfPlayer_Position FOREIGN KEY (hand_id,"position") REFERENCES public.player_position(hand_id,"position");
ALTER TABLE public.cards_of_player ADD CONSTRAINT FK_CardsOfPlayer_Cards FOREIGN KEY (description) REFERENCES public.cards(description);