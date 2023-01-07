DROP TABLE IF EXISTS public.board_of_hand;

CREATE TABLE public.board_of_hand (
    hand_id bigint NOT NULL,
    board varchar NOT NULL,
    CONSTRAINT PK_BboardOfHand PRIMARY KEY (hand_id)
);
ALTER TABLE public.board_of_hand
    ADD CONSTRAINT FK_PK_BboardOfHand FOREIGN KEY (hand_id) REFERENCES public.hands(hand_id);