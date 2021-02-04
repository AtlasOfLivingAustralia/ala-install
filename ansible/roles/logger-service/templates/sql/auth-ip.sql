-- Insert remote address if do no exists
INSERT INTO remote_address (ip, host_name)
    SELECT ip, host_name
    FROM (SELECT @ip as ip, @host_name as host_name) t
    WHERE NOT EXISTS (SELECT 1 FROM remote_address r WHERE r.ip = t.ip);
