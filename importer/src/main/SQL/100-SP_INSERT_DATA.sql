create or replace function insertData() returns trigger
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

    --pot of hand
    declare totalPot int;

    --player position
    declare positionOf int;
    declare stackOf int;

    --cards of player
    declare cardsOfPlayer varchar;

    --blind_position
    declare placeOf varchar(20);

    --fold_position
    declare noBet bool;
    declare roundOf varchar;

    --win position
    declare showDownOf bool;
    declare potOf int;
    declare handDescription varchar;


    begin
        if (new.section = 'HEADER') then
            --nickname
            if (new.line like '%Seat %:%in chips%') then
                nicknameOfPlayer = trim(substring(new.line from 'Seat [0-9]*:(.*)\([0-9]* in chips'));

                INSERT INTO players(nickname, created_at)
                values (nicknameOfPlayer, now())
                ON CONFLICT (nickname)
                do nothing;

            end if;

            --hands
            if (new.line like '%PokerStars Hand #%') then

                levelOf =  trim(substring(new.line from 'Level(.*)\('));
                smallBlind = cast(trim(substring(new.line from '\(([0-9]*)/')) as int);
                bigBlind = cast(trim(substring(new.line from '/([0-9]*)\)')) as int);
                playedAt = to_timestamp((regexp_matches(new.line, '[0-9]{4}/[0-9]{1,2}/[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}'))[1], 'YYYY/MM/DD HH24:MI:SS');

                INSERT INTO hands(hand_id, table_id, level, small_blind, big_blind, created_at, played_at, tournament_id)
                VALUES(new.hand_id, new.table_id, levelOf, smallBlind, bigBlind, now(), playedAt, new.tournament_id)
                ON CONFLICT (hand_id)
                do nothing;

            end if;

            --player position
            if (new.line like '%Seat %:%in chips%') then

                nicknameOfPlayer = trim(substring(new.line from 'Seat [0-9]*:(.*)\([0-9]* in chips'));
                positionOf = cast(trim(substring(new.line from 'Seat ([0-9]*):')) as int);
                stackOf = cast(trim(substring(new.line from '\(([0-9]*) in chips')) as int);

                INSERT INTO player_position(hand_id, nickname, position, stack)
                VALUES(new.hand_id, nicknameOfPlayer, positionOf, stackOf)
                on conflict (hand_id, position)
                do nothing;

            end if;
        end if;


        if (new.section = 'SUMMARY') then
            --board
            if (new.line like '%Board [%]%') then
                boardOf = substring(new.line from 'Board \[(.*)\]');

                INSERT INTO board_of_hand(hand_id, board)
                VALUES(new.hand_id, boardOf)
                on conflict(hand_id) do nothing;

            end if;

            --pot of hand
            if (new.line like '%Total pot%') then
                totalPot = cast(substring(new.line from 'Total pot ([0-9]*)')  as int);

                INSERT INTO pot_of_hand (hand_id, total_pot)
                VALUES(new.hand_id, totalPot)
                on conflict(hand_id)
                do nothing;

            end if;

            --cards of player
            if (new.line like '%Seat %:%') then

                --cards of player
                if (new.line like '%mucked [%' or new.line like '%showed [%') then

                    positionOf = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    cardsOfPlayer = null;

                    if position('mucked [' in new.line) > 0 then
                        cardsOfPlayer = substring(new.line from 'mucked \[(.{5})\]');
                    end if;
                    if position('showed [' in new.line) > 0 then
                        cardsOfPlayer = substring(new.line from 'showed \[(.{5})\]');
                    end if;


                    INSERT INTO cards_of_player(position, description, hand_id)
                    VALUES(positionOf, cardsOfPlayer, new.hand_id)
                    on conflict (hand_id, position)
                    do nothing;

                end if;

                --blind_position
                if (new.line like '%(button)%' or new.line like '%(small blind)%' or new.line like '%(big blind)%') then

                    positionOf = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    placeOf = null;

                    if (strpos(new.line, '(button)') > 0) then
                        placeOf = 'button';
                    end if;
                    if (strpos(new.line, '(small blind)') > 0) then
                        placeOf =  'small blind';
                    end if;
                    if (strpos(new.line, '(big blind)') > 0) then
                        placeOf =  'big blind';
                    end if;

                    INSERT INTO blind_position(hand_id, position, place)
                    VALUES(new.hand_id, positionOf, placeOf)
                    on conflict(hand_id, position)
                    do nothing;

                end if;

                --fold position
                if (new.line like '%folded before Flop%' or new.line like '%folded on the Flop%' or
                    new.line like '%folded on the Turn%' or new.line like '%folded on the River%') then

                    positionOf = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    roundOf = null;
                    noBet = false;

                    if (strpos(new.line, 'folded before Flop')  > 0) then
                        roundOf = 'PREFLOP';
                    end if;
                    if (strpos(new.line, 'folded on the Flop') > 0) then
                        roundOf = 'FLOP';
                    end if;
                    if (strpos(new.line, 'folded on the Turn')  > 0) then
                        roundOf = 'TURN';
                    end if;
                    if (strpos(new.line, 'folded on the River') > 0) then
                        roundOf = 'RIVER';
                    end if;

                    if (strpos(new.line, 'didn''t bet')  > 0) then
                        noBet = true;
                    end if;

                    INSERT INTO fold_position(hand_id, position, round, no_bet)
                    VALUES(new.hand_id, positionOf, roundOf, noBet)
                    on conflict(hand_id, position)
                    do nothing;

                end if;

                -- win_position
                if (new.line like '%collected%' or  new.line like '%and won %') then

                    positionOf = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    showDownOf = null;
                    potOf = null;
                    handDescription = null;

                    if strpos(new.line, 'collected') > 0 then
                        showDownOf = false;
                        potOf = cast(substring(new.line from 'collected \(([0-9]*)\)') as int);
                    end if;
                    if (strpos(new.line, 'and won ' ) > 0) then
                        showDownOf = true;
                        potOf = cast(substring(new.line from 'and won \(([0-9]*)\)') as int);
                        handDescription = trim(substring(new.line from '\) with (.*)'));
                    end if;

                    INSERT INTO win_position(hand_id, position, showdown, pot, hand_description)
                    VALUES(new.hand_id, positionOf, showDownOf, potOf, handDescription)
                    on conflict(hand_id, position)
                    do nothing;

                end if;

                -- lose_position
                if (new.line like '%and lost %') then

                    positionOf = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    handDescription = trim(substring(new.line from 'and lost with (.*)'));

                    INSERT INTO lose_position (hand, position, hand_description)
                    VALUES (new.hand_id, positionOf, handDescription)
                    on conflict(hand, position)
                    do nothing;

                end if;

            end if;
        end if;

        return new;

/*        EXCEPTION WHEN others THEN  -- or be more specific
            INSERT INTO LOG_TBL VALUES (NEW.filename, NEW.line, new.line_number, SQLERRM, now());
            return null;*/
    end
$$