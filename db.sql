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

INSERT INTO users (name, email)
VALUES
('Ivan Ivanov', 'ivan@example.com'),
('Anna Petrova', 'anna@example.com');