create or replace procedure insertHandPosition(fileName varchar)
    language plpgsql
as $$
    begin
        --hand position
        INSERT INTO hand_position
        (hand_id, number_of_players, min_pos, max_pos, button, positions)
            (
                select
                    hc.hand_id,
                    count(hc.*) as numberOfPlayers,
                    min(hc.position) as minPos,
                    max(hc.position) as maxPos,
                    bp.position as button,
                    string_agg(distinct cast(hc.position as text) , ',') as positions
                from
                    hand_consolidation hc
                left join
                    blind_position bp on hc.hand_id = bp.hand_id
                where
                        bp.place = 'button' and
                        hc.hand_id in (select hand_id
                                       from hands
                                                join tournaments t on hands.tournament_id = t.tournament_id
                                       where t.file_name like fileName)
                group by
                    hc.hand_id,
                    bp.position
            )
        on conflict(hand_id)
            do nothing;
    end;
$$