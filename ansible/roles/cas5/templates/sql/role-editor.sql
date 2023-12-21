-- INSERT role if does not exits
-- ROLE_EDITOR is not added  by default by CAS but used in some ALA modules 
INSERT INTO role (role, description)
    SELECT role, description
    FROM (SELECT 'ROLE_EDITOR' as role, '' as description) t
    WHERE NOT EXISTS (SELECT 1 FROM role r WHERE r.role = CONVERT(t.role USING latin1));
