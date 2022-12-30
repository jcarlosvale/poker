DROP TABLE if exists public.cards;

CREATE TABLE public.cards (
    description varchar(5) NOT NULL,
    card1 varchar(1) NOT NULL,
    card2 varchar(1) NOT NULL,
    chen int NOT NULL,
    created_at timestamp NOT NULL,
    normalised varchar(3) NULL,
    pair bool NOT NULL,
    suited bool NOT NULL,
    CONSTRAINT PK_CARDS PRIMARY KEY (description)
);