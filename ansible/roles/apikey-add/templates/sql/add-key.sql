-- Add a App if not exist
INSERT INTO app (name, date_created, user_email, user_id)
    SELECT name, date_created, user_email, user_id
    FROM (SELECT '{{ app }}' as name, NOW() as date_created, '{{ apikey_def_creator_email }}' as user_email, '{{ apikey_def_creator_userid }}' as user_id) t
    WHERE NOT EXISTS (SELECT 1 FROM app a WHERE a.name = t.name);
-- Add a new apikey for that app if not exist
INSERT INTO apikey (apikey, app_id, date_created, user_email, user_id, enabled)
    SELECT apikey, app_id, date_created, user_email, user_id, enabled
    FROM (SELECT '{{ apikey }}' as apikey, '{{ app }}' as app_id, NOW() as date_created, '{{ apikey_def_creator_email }}' as user_email, '{{ apikey_def_creator_userid }}' as user_id, 1 as enabled) t
    WHERE NOT EXISTS (SELECT 1 FROM apikey a WHERE a.apikey = t.apikey);
