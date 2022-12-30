create or replace function insertPlayer() returns trigger
language plpgsql
as $$
    --player
    declare nicknameOfPlayer varchar;

    --hand
    declare levelOf varchar(20);
    declare smallBlind int;
    declare bigBlind int;
    declare playedAt timestamp;

    --board
    declare boardOf varchar;

    begin
        if (new.section = 'HEADER') then
            --nickname
            if (new.line like '%Seat %:%in chips%') then
                nicknameOfPlayer = trim(substring(new.line from 'Seat [0-9]*:(.*)\([0-9]* in chips'));

                INSERT INTO players(nickname, created_at) values (nicknameOfPlayer, now()) ON CONFLICT (nickname) do nothing;

            end if;

            --hands
            if (new.line like '%PokerStars Hand #%') then

                levelOf =  trim(substring(new.line from 'Level(.*)\('));
                smallBlind = cast(trim(substring(new.line from '\(([0-9]*)/')) as int);
                bigBlind = cast(trim(substring(new.line from '/([0-9]*)\)')) as int);
                playedAt = to_timestamp((regexp_matches(new.line, '[0-9]{4}/[0-9]{1,2}/[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}'))[1], 'YYYY/MM/DD HH24:MI:SS');

                INSERT INTO hands(hand_id, table_id, level_tournament, small_blind, big_blind, created_at, played_at, tournament_id)
                VALUES(new.hand_id, new.table_id, levelOf, smallBlind, bigBlind, now(), playedAt, new.tournament_id)
                ON CONFLICT (hand_id) do nothing;

            end if;
        end if;
        if (new.section = 'SUMMARY') then
            --board
            if (new.line like '%Board [%]%') then
                boardOf = substring(new.line from 'Board \[(.*)\]');

                INSERT INTO board_of_hand(hand_id, board) VALUES(new.hand_id, boardOf) on conflict(hand_id) do nothing;
            end if;

        end if;

        --tournament id
        INSERT INTO tournaments(tournament_id, file_name, created_at) VALUES (new.tournament_id, new.filename, now())
                                                                      ON CONFLICT (tournament_id) do nothing;

        return new;
    end
$$