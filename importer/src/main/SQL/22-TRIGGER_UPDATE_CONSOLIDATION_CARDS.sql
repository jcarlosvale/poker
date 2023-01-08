DROP TRIGGER IF EXISTS TRIGGER_UPDATE_CONSOLIDATION_CARDS on consolidation;

CREATE TRIGGER TRIGGER_UPDATE_CONSOLIDATION_CARDS
    AFTER UPDATE OF player_card_description ON consolidation
    FOR EACH ROW
    EXECUTE FUNCTION sp_update_aggregation_cards();