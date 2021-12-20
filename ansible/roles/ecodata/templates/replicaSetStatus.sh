mongo -u {{ mongodb_root_username }} -p {{ mongodb_root_password }} admin --eval "db.adminCommand({replSetGetStatus:1, initialSync: 1})";
