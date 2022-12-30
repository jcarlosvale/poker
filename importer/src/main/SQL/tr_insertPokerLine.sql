DROP TRIGGER IF EXISTS tr_after_insert_pokerline on pokerline;

CREATE TRIGGER tr_after_insert_pokerline
    AFTER INSERT ON pokerline
    FOR EACH ROW
    EXECUTE FUNCTION insertPlayer();