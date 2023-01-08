create or replace function SP_UPDATE_AGGREGATION_CARDS() returns trigger
language plpgsql
as $$

    declare cardsOfPlayer varchar;
    DECLARE v_RowCountInt  Int;


    begin

        cardsOfPlayer = new.player_card_normalised;

        UPDATE aggregation
        SET
            cards =
                CASE
                    WHEN (position(cardsOfPlayer in cards) > 0) THEN cards
                    ELSE cards || ' ' || cardsOfPlayer
                END,

            sum_chen = sum_chen + new.player_chen,
            qty_chen = qty_chen + 1,
            avg_chen = (sum_chen + new.player_chen) / (qty_chen + 1.0),

            qty_shows = qty_shows + 1,
            avg_shows = (qty_shows + 1.0) / qty_hands

        WHERE
            nickname = new.nickname;

        GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

        IF v_RowCountInt <= 0 THEN
            RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
        end if;

        return new;
    end
$$