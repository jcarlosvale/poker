DROP TABLE IF EXISTS public.pot_of_hand;

CREATE TABLE public.pot_of_hand (
    hand_id bigint NOT NULL,
    total_pot int NOT NULL,
    CONSTRAINT PK_PotOfHand PRIMARY KEY (hand_id)
);

ALTER TABLE public.pot_of_hand ADD CONSTRAINT FK_PotOfHand FOREIGN KEY (hand_id) REFERENCES public.hands(hand_id);