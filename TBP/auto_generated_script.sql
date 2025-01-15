create domain smalldescription as text
    constraint smalldescription_check check (char_length(VALUE) <= 256);

create type rolename as enum ('Admin', 'User');

create table roles
(
    id          serial
        primary key,
    name        rolename         not null
        unique,
    description smalldescription not null
);

create table actions
(
    id          serial
        primary key,
    name        varchar(100)     not null
        unique,
    description smalldescription not null
);

create table users
(
    id        serial
        primary key,
    email     varchar(100)                        not null
        unique,
    password  varchar(256)                        not null,
    metadata  jsonb,
    roleid    integer                             not null
        references roles
            on delete cascade,
    createdat timestamp default CURRENT_TIMESTAMP not null,
    updatedat timestamp,
    isdeleted boolean   default false
);

create policy admin_access_policy on users
    as permissive
    for all
    using (is_admin((current_setting('app.current_user_id'::text))::integer) = true);

create policy user_self_access_policy on users
    as permissive
    for all
    using (id = (current_setting('app.current_user_id'::text))::integer);

create policy active_session_policy on users
    as permissive
    for all
    using (has_existing_session((current_setting('app.current_user_id'::text))::integer) = true);

create table auditlogs
(
    id         serial
        primary key,
    actionid   integer                             not null
        references actions
            on delete cascade,
    executedat timestamp default CURRENT_TIMESTAMP not null,
    executedby integer                             not null
        references users
            on delete cascade
);

create table sessions
(
    id         serial
        primary key,
    userid     integer                             not null
        references users
            on delete cascade,
    userroleid integer                             not null,
    ipaddress  varchar(45)                         not null,
    beganat    timestamp default CURRENT_TIMESTAMP not null,
    expiresin  integer                             not null
        constraint sessions_expiresin_check
            check (expiresin > 0),
    constraint session_unique
        unique (userid, ipaddress)
);

create function digest(text, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function digest(bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function hmac(text, text, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function hmac(bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function crypt(text, text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function gen_salt(text) returns text
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function gen_salt(text, integer) returns text
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function encrypt(bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function decrypt(bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function encrypt_iv(bytea, bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function decrypt_iv(bytea, bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function gen_random_bytes(integer) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function gen_random_uuid() returns uuid
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_encrypt(text, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_encrypt_bytea(bytea, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_encrypt(text, text, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_encrypt_bytea(bytea, text, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_decrypt(bytea, text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_decrypt_bytea(bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_decrypt(bytea, text, text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_sym_decrypt_bytea(bytea, text, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_encrypt(text, bytea) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_encrypt_bytea(bytea, bytea) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_encrypt(text, bytea, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_encrypt_bytea(bytea, bytea, text) returns bytea
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt(bytea, bytea) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt_bytea(bytea, bytea) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt(bytea, bytea, text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt_bytea(bytea, bytea, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt(bytea, bytea, text, text) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_pub_decrypt_bytea(bytea, bytea, text, text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_key_id(bytea) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function armor(bytea) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function armor(bytea, text[], text[]) returns text
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function dearmor(text) returns bytea
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;
$$;

create function pgp_armor_headers(text, out key text, out value text) returns setof setof record
    immutable
    strict
    parallel safe
    language c
as
$$
begin
-- missing source code
end;

$$;

create function create_audit_log() returns trigger
    language plpgsql
as
$$
BEGIN
INSERT INTO AuditLogs (ActionId, ExecutedAt, ExecutedBy)
VALUES (
           (SELECT ID FROM Actions WHERE Name = TG_ARGV[0]),
           NOW(),
           NEW.ID
       );
RETURN NEW;
END;
$$;

create function enfore_unique_email() returns trigger
    language plpgsql
as
$$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM Users
        WHERE Email = NEW.Email AND ID != NEW.ID
    ) THEN
        RAISE EXCEPTION 'Email % already exists!', NEW.Email;
END IF;
RETURN NEW;
END;
$$;

create trigger check_unique_email
    before insert or update
                         on users
                         for each row
                         execute procedure enfore_unique_email();

create function enforce_password_rules() returns trigger
    language plpgsql
as
$$
BEGIN
    IF LENGTH(NEW.Password) < 8 THEN
        RAISE EXCEPTION 'Password must be at least 8 characters long.';
END IF;

    NEW.Password := hash_password(NEW.Password);
RETURN NEW;
END;
$$;

create trigger check_password_rules
    before insert or update
                         on users
                         for each row
                         execute procedure enforce_password_rules();

create function is_admin(user_id integer) returns boolean
    language plpgsql
as
$$
BEGIN
RETURN EXISTS (
    SELECT 1
    FROM Users u
             JOIN Roles r ON u.RoleId = r.ID
    WHERE u.ID = user_id AND r.Name = 'Admin'
);
END;
$$;

create function calculate_age() returns trigger
    language plpgsql
as
$$
DECLARE
dob DATE;
    updated_metadata JSONB;
BEGIN
    -- Extract DateOfBirth from Metadata JSON field
    dob := (NEW.Metadata->>'DateOfBirth')::DATE;

    -- If a valid DateOfBirth exists, calculate the age
    IF dob IS NOT NULL THEN
        updated_metadata := jsonb_set(
                NEW.Metadata,
                '{Age}', -- JSON path to the key to be updated
                to_jsonb(DATE_PART('year', AGE(dob))::INT) -- Calculate the age
                            );

        -- Update the Metadata field
        NEW.Metadata := updated_metadata;
END IF;

RETURN NEW;
END;
$$;

create trigger age_calculation
    before insert or update
                         on users
                         for each row
                         execute procedure calculate_age();

create function hash_password(plain_password text) returns text
    language plpgsql
as
$$
BEGIN
RETURN crypt(plain_password, gen_salt('bf'));
END;
$$;

create function create_audit_log(action_name text, user_id integer) returns void
    language plpgsql
as
$$
DECLARE
action_id INT;
BEGIN
SELECT ID INTO action_id FROM Actions WHERE Name = action_name;
IF action_id IS NULL THEN
            RAISE EXCEPTION 'Action % not found in Actions table!', action_name;
end if;

INSERT INTO AuditLogs (ActionId, ExecutedAt, ExecutedBy)
VALUES (
           action_id,
           NOW(),
           user_id
       );
END;
$$;

create function login_user(user_id integer, ip_address character varying) returns void
    language plpgsql
as
$$
BEGIN
DELETE FROM Sessions
WHERE UserId = user_id
  AND IpAddress = ip_address
  AND (BeganAt + (ExpiresIn || ' minutes')::INTERVAL) < NOW();

INSERT INTO Sessions (UserId, UserRoleId, IpAddress, BeganAt, ExpiresIn)
SELECT u.ID, u.RoleId, ip_address, NOW(), 60
FROM Users u WHERE u.ID = user_id;

PERFORM create_audit_log('login', user_id);
END;
$$;

create function validate_session(user_id integer, ip_address character varying) returns boolean
    language plpgsql
as
$$
BEGIN
RETURN EXISTS (
    SELECT 1
    FROM Sessions
    WHERE UserId = user_id
      AND IpAddress = ip_address
      AND (BeganAt + (ExpiresIn || ' minutes')::INTERVAL) >= NOW()
);
END;
$$;

create function has_existing_session(user_id integer) returns boolean
    language plpgsql
as
$$
BEGIN
RETURN EXISTS (
    SELECT 1
    FROM Sessions
    WHERE UserId = user_id
      AND (BeganAt + (ExpiresIn || ' minutes')::INTERVAL) >= NOW()
);
END;
$$;

create function logout_user() returns void
    language plpgsql
as
$$
DECLARE
current_user_id INT;
BEGIN
SELECT current_setting('app.current_user_id', true)::INT INTO current_user_id;
IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'No user session found!';
end if;

DELETE FROM Sessions WHERE UserId = current_user_id;
PERFORM create_audit_log('logout', current_user_id);
    
    RESET app.current_user_id;
END;
$$;

create function logout_user(current_user_id integer) returns void
    language plpgsql
as
$$
DECLARE
BEGIN
    IF current_user_id IS NULL THEN
        RAISE EXCEPTION 'No user session found!';
end if;

DELETE FROM Sessions WHERE UserId = current_user_id;
PERFORM create_audit_log('logout', current_user_id);

END;
$$;

create function log_on_update_user() returns trigger
    language plpgsql
as
$$
BEGIN
    NEW.createdat = OLD.createdat;
    NEW.updatedat = CURRENT_TIMESTAMP::timestamp;
    PERFORM create_audit_log('update', NEW.ID);

return NEW;
end;
$$;

create trigger log_on_update
    before update
    on users
    for each row
    execute procedure log_on_update_user();

