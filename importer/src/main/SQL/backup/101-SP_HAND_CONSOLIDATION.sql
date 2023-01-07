create or replace procedure insertHandConsolidation(fileName varchar)
    language plpgsql
as $$
    begin
        --hand consolidation
        INSERT INTO hand_consolidation
        (tournament_id, table_id, board, hand_id, level, small_blind, big_blind, total_pot, nickname, position, place,
         cards_description, card1, card2, chen, normalised, pair, suited, stack_of_player, fold_round, no_bet,
         lose_hand_description, win_hand_description, win_pot, win_showdown, played_at)
            (
                select
                    h.tournament_id,
                    h.table_id,
                    boh.board,
                    h.hand_id,
                    h.level,
                    h.small_blind,
                    h.big_blind,
                    poh.total_pot,
                    pp.nickname,
                    pp.position,
                    bp.place,
                    cop.description,
                    c.card1,
                    c.card2,
                    c.chen,
                    c.normalised,
                    c.pair,
                    c.suited,
                    pp.stack,
                    fp.round as fold,
                    fp.no_bet,
                    lp.hand_description as loseHand,
                    wp.hand_description as winHand,
                    wp.pot as winPot,
                    wp.showdown,
                    h.played_at
                from hands h
                         join player_position pp on pp.hand_id = h.hand_id
                         left join blind_position bp on bp.hand_id = pp.hand_id and bp.position = pp.position
                         left join board_of_hand boh on boh.hand_id = h.hand_id
                         left join cards_of_player cop on cop.hand_id = pp.hand_id and cop.position = pp.position
                         left join cards c on c.description = cop.description
                         left join fold_position fp on fp.hand_id = pp.hand_id and fp.position = pp.position
                         left join lose_position lp on lp.hand = pp.hand_id and lp.position = pp.position
                         left join win_position wp on wp.hand_id = pp.hand_id and wp.position = pp.position
                         left join pot_of_hand poh on poh.hand_id = pp.hand_id
                where
                        h.hand_id in (select hand_id
                                      from hands
                                               join tournaments t on hands.tournament_id = t.tournament_id
                                      where t.file_name like fileName
                                     )
            )
        on conflict(hand_id, position)
            do nothing;
    end;
$$