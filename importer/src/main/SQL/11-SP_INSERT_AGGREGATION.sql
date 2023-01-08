create or replace function SP_INSERT_AGGREGATION() returns trigger
language plpgsql
as $$
    declare nicknameOfPlayer varchar;

    begin

        SELECT nickname into nicknameOfPlayer from aggregation where nickname = new.nickname;

        --new player
        IF (nicknameOfPlayer is null) then

            INSERT INTO aggregation (nickname, qty_hands)
            VALUES(new.nickname, 1);

        end if;

        --update player
        IF (nicknameOfPlayer is not null) then
            UPDATE aggregation
                SET
                    qty_hands = qty_hands + 1
            WHERE nickname = nicknameOfPlayer;
        end if;

        return new;
    end
$$