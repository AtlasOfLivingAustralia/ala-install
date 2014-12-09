-- This is to work around the error "SQL state [HY000]; error code [1449]; The user specified as a definer ('logger_user'@'%') does not exist; nested exception is java.sql.SQLException: The user specified as a definer ('logger_user'@'%') does not exist"
grant all on *.* to 'logger_user'@'%' identified by 'logger_user' with grant option;
