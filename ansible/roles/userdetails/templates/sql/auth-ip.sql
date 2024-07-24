-- Authorize IP inserting a register if does not exists yet
INSERT INTO authorised_system (host, description, version)
    SELECT host, description, version
    FROM (SELECT @ip as host, @description as description, 1 as version) t
    WHERE NOT EXISTS (SELECT 1 FROM authorised_system a WHERE a.host = t.host COLLATE utf8mb4_unicode_ci);
