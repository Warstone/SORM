CREATE TABLE master_table (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    data TEXT NOT NULL
);

CREATE TABLE slave_table (
    id BIGSERIAL NOT NULL PRIMARY KEY,
    master_id BIGINT NOT NULL REFERENCES master_table(id),
    slave_data TEXT NOT NULL--,
--    addon_date TIMESTAMP(0) NOT NULL DEFAULT NOW()
);

INSERT INTO master_table(data) SELECT ('{"master":true,"ident":' || t || '}') FROM generate_series(1, 10) t;
--INSERT INTO slave_table(master_id, slave_data, addon_date) SELECT t % 10 + 1, '{"slave":true,"ident":' || t || '}', NOW() - INTERVAL '1 day' * t FROM generate_series (1, 100) t;
INSERT INTO slave_table(master_id, slave_data) SELECT t % 10 + 1, '{"slave":true,"ident":' || t || '}' FROM generate_series (1, 100) t;
