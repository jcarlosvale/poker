create or replace function SP_UPDATE_AGGREGATION_PLACE() returns trigger
language plpgsql
as $$

    DECLARE v_RowCountInt  Int;
    DECLARE foldedPreFlop bool;

    begin

        foldedPreFlop = (new.player_fold_round = 'PREFLOP');

        -- no bet
        UPDATE aggregation
        SET
            qty_in_action =  case when new.player_in_action then qty_in_action + 1 else qty_in_action end,
            avg_in_action =  case when new.player_no_bet then (qty_in_action + 1.0) / aggregation.qty_hands else avg_in_action end
        WHERE
                nickname = new.nickname;

        -- fold position
        IF (new.player_fold_round = 'PREFLOP') THEN

            UPDATE aggregation
            SET
                qty_fold_preflop =  qty_fold_preflop + 1,
                avg_fold_preflop = (qty_fold_preflop + 1.0) / qty_hands
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        IF (new.player_fold_round = 'FLOP') THEN

            UPDATE aggregation
            SET
                qty_fold_flop =  qty_fold_flop + 1,
                avg_fold_flop = (qty_fold_flop + 1.0) / qty_hands
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        IF (new.player_fold_round = 'TURN') THEN

            UPDATE aggregation
            SET
                qty_fold_turn =  qty_fold_turn + 1,
                avg_fold_turn = (qty_fold_turn + 1.0) / qty_hands
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        IF (new.player_fold_round = 'RIVER') THEN

            UPDATE aggregation
            SET
                qty_fold_river =  qty_fold_river + 1,
                avg_fold_river = (qty_fold_river + 1.0) / qty_hands
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        -- button, small or big blind
        IF (new.player_place = 'button') THEN

            UPDATE aggregation
            SET
                sum_play_button = sum_play_button + 1,
                qty_play_button = case when foldedPreFlop then qty_play_button + 1 else qty_play_button end,
                avg_play_button = case when foldedPreFlop then (sum_play_button + 1.0) / (qty_play_button + 1) else avg_play_button end
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        IF (new.player_place = 'small blind') THEN

            UPDATE aggregation
            SET
                sum_play_small_blind = sum_play_small_blind + 1,
                qty_play_small_blind = case when foldedPreFlop then qty_play_small_blind + 1 else qty_play_small_blind end,
                avg_play_small_blind = case when foldedPreFlop then (sum_play_small_blind + 1.0)/ (qty_play_small_blind + 1) else avg_play_small_blind end
            WHERE
                nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        IF (new.player_place = 'big blind') THEN

            UPDATE aggregation
            SET
                sum_play_big_blind = sum_play_big_blind + 1,
                qty_play_big_blind = case when foldedPreFlop then qty_play_big_blind + 1 else qty_play_big_blind end,
                avg_play_big_blind = case when foldedPreFlop then (sum_play_big_blind + 1.0)/ (qty_play_big_blind + 1) else avg_play_big_blind end
            WHERE
                    nickname = new.nickname;

            GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

            IF v_RowCountInt <= 0 THEN
                RAISE EXCEPTION 'Must be update at least 1 record in AGGREGATION TABLE';
            end if;

        end if;

        return new;
    end
$$