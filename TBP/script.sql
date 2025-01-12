-- cryptography
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- tables
CREATE TABLE Users(
                      ID SERIAL PRIMARY KEY,
                      Email VARCHAR(100) NOT NULL UNIQUE,
                      Password VARCHAR(256) NOT NULL,
                      Metadata JSONB, -- Changed from 'Metadata' composite type to 'jsonb'
                      RoleId INT NOT NULL REFERENCES Roles(ID) ON DELETE CASCADE,
                      CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                      UpdatedAt TIMESTAMP NULL,
                      IsDeleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE Roles(
                      ID SERIAL PRIMARY KEY,
                      Name RoleName NOT NULL UNIQUE,
                      Description SmallDescription NOT NULL
);

CREATE TABLE Actions(
                        ID SERIAL PRIMARY KEY,
                        Name VARCHAR(100) NOT NULL UNIQUE,
                        Description SmallDescription NOT NULL
);

CREATE TABLE AuditLogs(
                          ID SERIAL PRIMARY KEY,
                          ActionId INT NOT NULL REFERENCES Actions(ID) ON DELETE CASCADE,
                          ExecutedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
                          ExecutedBy INT NOT NULL REFERENCES Users(ID) ON DELETE CASCADE
);

-- domains
CREATE DOMAIN SmallDescription AS TEXT
    CHECK (char_length(VALUE) <= 256);

CREATE TYPE RoleName AS ENUM ('Admin', 'User');

-- functions
CREATE OR REPLACE FUNCTION create_audit_log()
    RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO AuditLogs (ActionId, ExecutedAt, ExecutedBy)
    VALUES (
               (SELECT ID FROM Actions WHERE Name = TG_ARGV[0]),
               NOW(),
               NEW.ID
           );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION enfore_unique_email()
    RETURNS TRIGGER AS $$
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
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION enforce_password_rules()
    RETURNS TRIGGER AS $$
BEGIN
    IF LENGTH(NEW.Password) < 8 THEN
        RAISE EXCEPTION 'Password must be at least 8 characters long.';
    END IF;

    NEW.Password := hash_password(NEW.Password);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION is_admin(user_id INT)
    RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS(
        SELECT 1
        FROM Users u
                 JOIN Roles r ON u.RoleId = r.ID
        WHERE u.ID = user_id AND r.Name = 'Admin'
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_age()
    RETURNS TRIGGER AS $$
DECLARE
    dob DATE;
    updated_metadata JSONB;
BEGIN
    dob := (NEW.Metadata->>'DateOfBirth')::DATE;

    IF dob IS NOT NULL THEN
        updated_metadata := jsonb_set(
                NEW.Metadata,
                '{Age}', 
                to_jsonb(DATE_PART('year', AGE(dob))::INT)
                            );

        NEW.Metadata := updated_metadata;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION hash_password(plain_password TEXT)
    RETURNS TEXT AS $$
BEGIN
    RETURN crypt(plain_password, gen_salt('bf'));
END;
$$ LANGUAGE plpgsql;

-- triggers
CREATE TRIGGER check_password_rules
    BEFORE INSERT OR UPDATE ON Users
    FOR EACH ROW
EXECUTE FUNCTION enforce_password_rules();

CREATE TRIGGER check_unique_email
    BEFORE INSERT OR UPDATE ON Users
    FOR EACH ROW
EXECUTE FUNCTION enfore_unique_email();

CREATE TRIGGER age_calculation
    BEFORE INSERT OR UPDATE ON Users
    FOR EACH ROW
EXECUTE FUNCTION calculate_age();