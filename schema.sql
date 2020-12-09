CREATE TABLE users (
id serial PRIMARY KEY,
username varchar(30) UNIQUE NOT NULL,
password varchar NOT NULL CHECK(LENGTH(password) >= 8)
);

CREATE TABLE expenses (
    id serial PRIMARY KEY,
    name varchar(40) NOT NULL,
    price numeric NOT NULL CHECK(price > 0),
    wasted_check boolean DEFAULT true,
    time_added date NOT NULL DEFAULT(CURRENT_TIMESTAMP)
    user_id integer NOT NULL REFERENCES users(id)
);