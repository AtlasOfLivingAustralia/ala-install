--
-- First admin user creation if not exists
--
-- cas_first_admin_email should be an email
-- cas_first_admin_temp_auth_key is generated in userdetails with:
--   user.tempAuthKey = UUID.randomUUID().toString()
-- Tools like 'uuidgen' can be used in the command line
--
-- About creation if does not exists in mysql: https://stackoverflow.com/a/25996186
--
INSERT INTO users (userid, username, firstname, lastname, email, activated, locked, temp_auth_key)
    SELECT userid, username, firstname, lastname, email, activated, locked, temp_auth_key
    FROM (SELECT 1 as userid, '{{ cas_first_admin_email }}' as username, 'Admin' as firstname, 'User' as lastname, '{{ cas_first_admin_email }}' as email, '1' as activated, '0' as locked, '{{ cas_first_admin_temp_auth_key }}' as temp_auth_key) t
    WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.userid = t.userid);
--
-- Password (should be a bcrypt hash)
-- See:
-- https://github.com/AtlasOfLivingAustralia/userdetails/blob/master/src/main/java/au/org/ala/cas/encoding/BcryptPasswordEncoder.java
-- Can be easy created with:
--
--   htpasswd -bnBC 10 "" password | tr -d ':\n' | sed 's/$2y/$2a/'
--
-- or in node:
--
--   bcrypt.genSalt(saltRounds, "a", function (err, salt) {
--     bcrypt.hash(myPlaintextPassword, salt2, function (err, hash) {
--       console.log(salt);
--     });
--   });
--
INSERT INTO passwords (userid, password, type, status)
    SELECT userid, password, type, status
    FROM (SELECT 1 as userid,'{{ cas_first_admin_bcrypt_password }}' as password, 'bcrypt' as type, 'CURRENT' as status) t
    WHERE NOT EXISTS (SELECT 1 FROM passwords p WHERE p.userid = t.userid);
--
-- User Profiles
--
INSERT INTO profiles (userid, property, value)
    SELECT userid, property, value
    FROM (SELECT 1 as userId, 'city' as property, '' as value) t
    WHERE NOT EXISTS (SELECT 1 FROM profiles u WHERE u.userid = t.userid AND u.property = t.property);
--
INSERT INTO profiles (userid, property, value)
    SELECT userid, property, value
    FROM (SELECT 1 as userId, 'country' as property, '' as value) t
    WHERE NOT EXISTS (SELECT 1 FROM profiles u WHERE u.userid = t.userid AND u.property = t.property);
--
INSERT INTO profiles (userid, property, value)
    SELECT userid, property, value
    FROM (SELECT 1 as userId, 'organisation' as property, '' as value) t
    WHERE NOT EXISTS (SELECT 1 FROM profiles u WHERE u.userid = t.userid AND u.property = t.property);
--
INSERT INTO profiles (userid, property, value)
    SELECT userid, property, value
    FROM (SELECT 1 as userId, 'state' as property, '' as value) t
    WHERE NOT EXISTS (SELECT 1 FROM profiles u WHERE u.userid = t.userid AND u.property = t.property);
--
-- Admin roles
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_ADMIN' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_COLLECTION_ADMIN' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_COLLECTION_EDITOR' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_EDITOR' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_IMAGE_ADMIN' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_SPATIAL_ADMIN' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_SYSTEM_ADMIN' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
--
INSERT INTO user_role (user_id, role_id)
    SELECT user_id, role_id
    FROM (SELECT 1 as user_id, 'ROLE_USER' as role_id) t
    WHERE NOT EXISTS (SELECT 1 FROM user_role u WHERE u.user_id = t.user_id AND u.role_id = t.role_id);
