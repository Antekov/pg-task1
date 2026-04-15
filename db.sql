DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS users_history;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT
);

CREATE TABLE users_history (
    id SERIAL,
    user_id INT,
    old_name TEXT,
    old_email TEXT,
    changed_at TIMESTAMP DEFAULT now()
);

CREATE TABLE users_audit (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by TEXT,
    field_changed TEXT,
    old_value TEXT,
    new_value TEXT
);

CREATE OR REPLACE FUNCTION log_user_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users_history(user_id, old_name, old_email)
    VALUES (OLD.id, OLD.name, OLD.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_user_update
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_update();

CREATE OR REPLACE FUNCTION log_user_audit()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.name IS DISTINCT FROM NEW.name THEN
        INSERT INTO users_audit(user_id, changed_by, field_changed, old_value, new_value)
        VALUES (OLD.id, current_user, 'name', OLD.name, NEW.name);
    END IF;

    IF OLD.email IS DISTINCT FROM NEW.email THEN
        INSERT INTO users_audit(user_id, changed_by, field_changed, old_value, new_value)
        VALUES (OLD.id, current_user, 'email', OLD.email, NEW.email);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_user_audit
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION log_user_audit();


INSERT INTO users (name, email)
VALUES
('Ivan Ivanov', 'ivan@example.com'),
('Anna Petrova', 'anna@example.com');

UPDATE users
SET email = 'ivan.new@example.com'
WHERE name = 'Ivan Ivanov';

UPDATE users
SET name = 'Ivan Antonov'
WHERE email = 'ivan.new@example.com';


UPDATE users
SET name = 'Petr Antonov'
WHERE id = 1;

UPDATE users
SET email = 'petr.antonov@mail.ru'
WHERE id = 1;

UPDATE users
SET name = 'Anton Antonov',
email = 'anton.antonov@mail.ru'
WHERE id = 1;