create or replace procedure insertTournament(tournamentId bigint, filename varchar)
    language plpgsql
as $$
    begin

        --tournament id
        INSERT INTO tournaments(tournament_id, file_name, created_at) VALUES (tournamentId, filename, now())
        ON CONFLICT (tournament_id) do nothing;

    end;
$$