create or replace function SP_INSERT_CONSOLIDATION() returns trigger
language plpgsql
as $$

    -- general
    declare tournamentId bigint;
    declare handId bigint;
    declare filename varchar;
    declare lineNumber int;
    declare tableId int;

    DECLARE v_RowCountInt  Int;

        --player
    declare nicknameOfPlayer varchar;

    --hand
    declare levelOf varchar(20);
    declare smallBlind int;
    declare bigBlind int;
    declare playedAt timestamp;

    --board
    declare boardCards varchar;

    --pot of hand
    declare totalPot int;

    --player position
    declare playerPosition int;
    declare playerStack int;

    --cards of player
    declare cardsOfPlayer varchar;

    --blind_position
    declare placeOf varchar(20);

    --fold_position
    declare inAction bool;
    declare roundOf varchar;

    --win position
    declare showDownOf bool;
    declare potOf int;
    declare handDescription varchar;


    begin

        tournamentId = new.tournament_id;
        handId = new.hand_id;
        filename = new.filename;
        tableId = new.table_id;
        lineNumber = new.line_number;
        levelOf = new.tournament_level;
        bigBlind = new.big_blind;
        smallBlind = new.small_blind;
        playedAt = new.played_at;

        if (new.section = 'HEADER') then

            --nickname
            if (new.line like '%Seat %:%in chips%') then

                nicknameOfPlayer = trim(substring(new.line from 'Seat [0-9]*:(.*)\([0-9]* in chips'));
                playerPosition = cast(trim(substring(new.line from 'Seat ([0-9]*):')) as int);
                playerStack = cast(trim(substring(new.line from '\(([0-9]*) in chips')) as int);

                INSERT INTO CONSOLIDATION(
                                          nickname,
                                          tournament_id,
                                          hand_id,
                                          table_id,
                                          tournament_level,
                                          big_blind,
                                          small_blind,
                                          player_position,
                                          player_stack,
                                          file_name,
                                          line_number,
                                          updated_at,
                                          played_at)
                VALUES(
                                         nicknameOfPlayer,
                                         tournamentId,
                                         handId,
                                         tableId,
                                         levelOf,
                                         bigBlind,
                                         smallBlind,
                                         playerPosition,
                                         playerStack,
                                         filename,
                                         lineNumber,
                                         now(),
                                         playedAt);
            end if;
        end if;

        if (new.section = 'PRE_FLOP') then
            --dealt to
            if (new.line like 'Dealt to%') then

                nicknameOfPlayer = trim(substring(new.line, char_length('Dealt to '), char_length(new.line)-char_length('Dealt to ')-char_length('[xx xx]')));
                cardsOfPlayer = substring(new.line from ' \[(.{5})\]');

                --cards of hero
                UPDATE CONSOLIDATION
                SET
                    player_card_description = cardsOfPlayer,
                    player_card1 = cards.card1,
                    player_card2 = cards.card2,
                    player_chen = cards.chen,
                    player_card_normalised = cards.normalised,
                    player_card_pair = cards.pair,
                    player_showdown = true,
                    player_card_suited = cards.suited
                FROM
                    (SELECT card1, card2, chen, normalised, pair, suited FROM cards WHERE cards.description = cardsOfPlayer) as cards
                WHERE
                        hand_id = handId and
                        nickname = nicknameOfPlayer;

                GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                IF v_RowCountInt <= 0 THEN
                    RAISE EXCEPTION 'Must be update at least 1 record';
                end if;

                -- update places
                UPDATE CONSOLIDATION
                SET
                    max_pos = subquery.max_pos,
                    min_pos = subquery.min_pos,
                    number_of_players = subquery.number_of_players,
                    positions = subquery.positions
                FROM
                    (
                        select
                            count(hc.*) as number_of_players,
                            min(hc.player_position) as min_pos,
                            max(hc.player_position) as max_pos,
                            string_agg(distinct cast(hc.player_position as text) , ',') as positions
                        from
                            consolidation hc
                        where
                                hc.hand_id = handId
                    ) as subquery
                WHERE
                        hand_id = handId;

                GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                IF v_RowCountInt <= 0 THEN
                    RAISE EXCEPTION 'Must be update at least 1 record';
                end if;

            end if;
        end if;

        if (new.section = 'SUMMARY') then
            --board
            if (new.line like '%Board [%]%') then

                boardCards = substring(new.line from 'Board \[(.*)\]');

                UPDATE CONSOLIDATION
                    SET
                        board_cards = boardCards
                WHERE
                    hand_id = handId;

                GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                IF v_RowCountInt <= 0 THEN
                    RAISE EXCEPTION 'Must be update at least 1 record';
                end if;

            end if;

            --pot of hand
            if (new.line like '%Total pot%') then

                totalPot = cast(substring(new.line from 'Total pot ([0-9]*)')  as int);

                UPDATE CONSOLIDATION
                SET
                    total_pot = totalPot
                WHERE
                        hand_id = handId;

                GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                IF v_RowCountInt <= 0 THEN
                    RAISE EXCEPTION 'Must be update at least 1 record';
                end if;

            end if;

            --cards of player
            if (new.line like '%Seat %:%') then

                --cards of player
                if (new.line like '%mucked [%' or new.line like '%showed [%') then

                    playerPosition = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    cardsOfPlayer = null;

                    if position('mucked [' in new.line) > 0 then
                        cardsOfPlayer = substring(new.line from 'mucked \[(.{5})\]');
                    end if;
                    if position('showed [' in new.line) > 0 then
                        cardsOfPlayer = substring(new.line from 'showed \[(.{5})\]');
                    end if;

                    UPDATE CONSOLIDATION
                    SET
                        player_card_description = cardsOfPlayer,
                        player_card1 = cards.card1,
                        player_card2 = cards.card2,
                        player_chen = cards.chen,
                        player_card_normalised = cards.normalised,
                        player_card_pair = cards.pair,
                        player_showdown = true,
                        player_card_suited = cards.suited
                    FROM
                        (SELECT card1, card2, chen, normalised, pair, suited FROM cards WHERE cards.description = cardsOfPlayer) as cards
                    WHERE
                        hand_id = handId and
                        player_position = playerPosition;

                    GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                    IF v_RowCountInt <= 0 THEN
                        RAISE EXCEPTION 'Must be update at least 1 record';
                    end if;

                end if;

                --blind_position
                if (new.line like '%(button)%' or new.line like '%(small blind)%' or new.line like '%(big blind)%') then

                    playerPosition = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    placeOf = null;

                    if (strpos(new.line, '(button)') > 0) then
                        placeOf = 'button';

                        UPDATE CONSOLIDATION
                        SET
                            button = playerPosition
                        WHERE
                            hand_id = handId;

                    end if;
                    if (strpos(new.line, '(small blind)') > 0) then
                        placeOf =  'small blind';
                    end if;
                    if (strpos(new.line, '(big blind)') > 0) then
                        placeOf =  'big blind';
                    end if;

                    UPDATE CONSOLIDATION
                    SET
                        player_place = placeOf
                    WHERE
                        hand_id = handId and
                        player_position = playerPosition;

                    GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                    IF v_RowCountInt <= 0 THEN
                        RAISE EXCEPTION 'Must be update at least 1 record';
                    end if;

                end if;

                --fold position
                if (new.line like '%folded before Flop%' or new.line like '%folded on the Flop%' or
                    new.line like '%folded on the Turn%' or new.line like '%folded on the River%') then

                    playerPosition = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    roundOf = null;
                    inAction = true;

                    if (strpos(new.line, 'folded before Flop')  > 0) then
                        inAction = false;
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
                        inAction = false;
                    end if;

                    UPDATE CONSOLIDATION
                    SET
                        player_fold_round = roundOf,
                        player_in_action = inAction
                    WHERE
                            hand_id = handId and
                            player_position = playerPosition;

                    GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                    IF v_RowCountInt <= 0 THEN
                        RAISE EXCEPTION 'Must be update at least 1 record';
                    end if;

                end if;

                -- win_position
                if (new.line like '%collected%' or  new.line like '%and won %') then

                    playerPosition = cast(substring(new.line from 'Seat ([0-9]*):') as int);
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

                    UPDATE CONSOLIDATION
                    SET
                        winner_showdown = showDownOf,
                        hand_win_description = handDescription
                    WHERE
                        hand_id = handId;

                    UPDATE CONSOLIDATION
                    SET
                        player_win_pot = potOf,
                        player_hand_description = handDescription,
                        player_winner = true
                    WHERE
                        hand_id = handId and
                        player_position = playerPosition;

                    GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                    IF v_RowCountInt <= 0 THEN
                        RAISE EXCEPTION 'Must be update at least 1 record';
                    end if;

                end if;

                -- lose_position
                if (new.line like '%and lost %') then

                    playerPosition = cast(substring(new.line from 'Seat ([0-9]*):') as int);
                    handDescription = trim(substring(new.line from 'and lost with (.*)'));

                    UPDATE CONSOLIDATION
                    SET
                        player_hand_description = handDescription
                    WHERE
                        hand_id = handId and
                        player_position = playerPosition;

                    GET DIAGNOSTICS v_RowCountInt = ROW_COUNT;

                    IF v_RowCountInt <= 0 THEN
                        RAISE EXCEPTION 'Must be update at least 1 record';
                    end if;

                end if;

            end if;
        end if;

        return new;

/*        EXCEPTION WHEN others THEN  -- or be more specific
            INSERT INTO LOG_TBL VALUES (NEW.filename, NEW.line, new.line_number, SQLERRM, now());
            return null;*/
    end
$$