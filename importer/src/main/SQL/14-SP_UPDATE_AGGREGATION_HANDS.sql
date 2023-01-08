create or replace function SP_UPDATE_AGGREGATION_HANDS() returns trigger
language plpgsql
as $$

    DECLARE v_RowCountInt  Int;

    begin

        UPDATE aggregation
        SET
            avg_shows = qty_shows / new.qty_hands::decimal,
            avg_in_action = qty_in_action / new.qty_hands::decimal,
            avg_fold_preflop = qty_fold_preflop / new.qty_hands::decimal,
            avg_fold_flop = qty_fold_flop / new.qty_hands::decimal,
            avg_fold_turn = qty_fold_turn / new.qty_hands::decimal,
            avg_fold_river = qty_fold_river /new.qty_hands::decimal
        WHERE nickname = new.nickname;

        GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

        IF v_RowCountInt <= 0 THEN
            RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
        end if;

        return new;
    end
$$