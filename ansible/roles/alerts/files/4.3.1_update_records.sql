-- One-time update for the 4.3.1 release:

-- 1. Annotations now uses its own template. To update the template, run the following query:
update alerts.query set email_template='/email/annotations' where name='Annotations';

--  2. My Annotations now uses its own template. To update the template, run the following query:
update alerts.query set email_template='/email/myAnnotations' where name='My Annotations';

-- 3. Annotation on records for Dataset / collections / species  now uses its "Annotation" template. To update the template, run the following query:

    UPDATE alerts.query
    SET email_template = '/email/annotations'
    WHERE name LIKE 'New annotations on%';

-- 4. Species List Annotations now share the same template with datasets. To update the template, run the following query:
    -- 4.1  Update fire_when_change to false for species list queries

    UPDATE alerts.property_path
    SET fire_when_change = false
    WHERE query_id IN (
        SELECT query_id
        FROM query
        WHERE email_template = '/email/specieslists'
    );

    -- 4.2
    update alerts.query set email_template="/email/datasets" where email_template='/email/specieslists';

-- 5. Data Resource using Collectory Service now share the same template with datasets. To update the template, run the following query:
   -- 5.1
   -- update alerts.query set email_template="/email/datasets" where email_template='/email/dataresource';


-- 6. Check base_url and query_path for the queries which name is "Annotations" and "My Annotations"

--      if base_url is like:
--       https://biocache.ala.org.au
--       and query_path is like:
--       /ws/occurrences/search?fq=user_assertions:*&q=last_assertion_date:[___DATEPARAM___%20TO%20*]&sort=last_assertion_date&dir=desc&pageSize=20&facets=basis_of_record
--
--       then they should be changed to:
--       https://biocache.ala.org.au/ws
--       and
--       /occurrences/search?fq=user_assertions:*&q=last_assertion_date:[___DATEPARAM___%20TO%20*]&sort=last_assertion_date&dir=desc&pageSize=20&facets=basis_of_record

    UPDATE alerts.query
    SET
        base_url = CONCAT(base_url, '/ws'),      -- Add '/ws' to the end of base_url
        query_path = SUBSTRING(query_path, 4)    -- Remove '/ws' from the start of query_path
    WHERE
        query_path LIKE '/ws%';                  -- Only apply if query_path starts with '/ws'


-- Update some queries using api.test.ala.org.au and api.ala.org.au

      UPDATE alerts.query
        SET
            base_url = 'https://biocache-ws-test.ala.org.au/ws'
        WHERE
            base_url LIKE 'https://api.test.ala.org.au/occurrences%';


      UPDATE alerts.query
        SET
            base_url = 'https://biocache.ala.org.au/ws'
        WHERE
            base_url LIKE 'https://api.ala.org.au/occurrences%';
