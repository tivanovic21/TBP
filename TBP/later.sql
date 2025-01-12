-- add later
CREATE OR REPLACE FUNCTION check_admin_privilege()
    RETURNS TRIGGER AS $$
BEGIN
    IF NOT is_admin(NEW.UpdatedBy) THEN
        RAISE EXCEPTION 'Only admins can register new users.';
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_admin_for_user_creation
    BEFORE INSERT ON Users
    FOR EACH ROW
    EXECUTE FUNCTION check_admin_privilege();