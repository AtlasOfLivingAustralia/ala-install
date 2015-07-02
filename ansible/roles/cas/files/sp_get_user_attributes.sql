DROP PROCEDURE IF EXISTS sp_get_user_attributes;
delimiter //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_user_attributes`(p_username varchar(255))
begin
select 'email' as 'key', email as 'value' from users where username=p_username
union select 'firstname' as 'key', firstname as 'value' from users where username=p_username
union select 'lastname' as 'key', lastname as 'value' from users where username=p_username
union select 'displayName' as 'key', profiles.value from profiles inner join users ON users.userid=profiles.userid where users.username=p_username and profiles.property='displayName'
union select 'userid' as 'key', cast(userid as char) as 'value' from users where username=p_username
union select 'authority' as 'key', group_concat(a.role_id) as 'value' from user_role a, users u where a.user_id=u.userid and u.username=p_username;
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


DROP PROCEDURE IF EXISTS sp_create_user;
delimiter //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_user`(
`email`              varchar(255),
`firstname`          varchar(255),
`lastname`           varchar(255),
`password`           varchar(255),
`city`               varchar(255),
`organisation`       varchar(255),
`primaryUserType`    varchar(255),
`secondaryUserType`  varchar(255),
`ausstate`           varchar(255),
`telephone`          varchar(255))
BEGIN
declare userid int(11);
INSERT INTO `emmet`.`users` (`username`, `firstname`, `lastname`, `email`, `activated`, `locked`) VALUES (email, firstname, lastname, email, '1', '0');
set userid = LAST_INSERT_ID();
INSERT INTO `emmet`.`passwords` (`userid`, `password`, `status`) VALUES (userid, password, 'CURRENT');
INSERT INTO `emmet`.`user_role` (`user_id`, `role_id`) VALUES (userid, 'ROLE_USER');
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'city',              city);
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'organisation',      organisation);
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'primaryUserType',   primaryUserType);
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'secondaryUserType', secondaryUserType);
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'state',             ausstate);
INSERT INTO `emmet`.`profiles` (`userid`, `property`, `value`) VALUES (userid, 'telephone',         telephone);
END
//
delimiter ;
