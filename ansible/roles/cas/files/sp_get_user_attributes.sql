DROP PROCEDURE IF EXISTS sp_get_user_attributes;
delimiter //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_attributes`(p_username varchar(255))
begin
select 'email' as 'key', email as 'value' from users where username=p_username
union select 'firstname' as 'key', firstname as 'value' from users where username=p_username
union select 'lastname' as 'key', lastname as 'value' from users where username=p_username
union select 'displayName' as 'key', profiles.value from profiles inner join users ON users.userid=profiles.userid where users.username=p_username and profiles.property='displayName'
union select 'userid' as 'key', cast(userid as char) as 'value' from users where username=p_username
union select 'authority' as 'key', group_concat(a.authority) as 'value' from authorities a, users u where a.userid=u.userid and u.username=p_username;
end
//
delimiter ;


DROP PROCEDURE IF EXISTS sp_get_user_authorities;
delimiter //
create procedure sp_get_user_authorities()
begin
select username, group_concat(ur.role_id) as 'authorities' from users u, user_role ur where u.userid=ur.user_id group by username;
end
//
delimiter ;