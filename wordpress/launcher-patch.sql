SET sql_mode = '';
ALTER TABLE wp_users
ADD COLUMN uuid CHAR(36) UNIQUE DEFAULT NULL,
ADD COLUMN accessToken CHAR(32) DEFAULT NULL,
ADD COLUMN serverID VARCHAR(41) DEFAULT NULL,
ADD COLUMN hwidId BIGINT DEFAULT NULL;


DELIMITER //
CREATE TRIGGER setUUID BEFORE INSERT ON wp_users
FOR EACH ROW BEGIN
IF NEW.uuid IS NULL THEN
SET NEW.uuid = UUID();
END IF;
END; //
DELIMITER ;

UPDATE wp_users SET uuid=(SELECT UUID()) WHERE uuid IS NULL;

CREATE TABLE `hwids` (
`id` bigint(20) NOT NULL,
`publickey` blob,
`hwDiskId` varchar(255) DEFAULT NULL,
`baseboardSerialNumber` varchar(255) DEFAULT NULL,
`graphicCard` varchar(255) DEFAULT NULL,
`displayId` blob,
`bitness` int(11) DEFAULT NULL,
`totalMemory` bigint(20) DEFAULT NULL,
`logicalProcessors` int(11) DEFAULT NULL,
`physicalProcessors` int(11) DEFAULT NULL,
`processorMaxFreq` bigint(11) DEFAULT NULL,
`battery` tinyint(1) NOT NULL DEFAULT "0",
`banned` tinyint(1) NOT NULL DEFAULT "0"
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
ALTER TABLE `hwids`
ADD PRIMARY KEY (`id`),
ADD UNIQUE KEY `publickey` (`publickey`(255));
ALTER TABLE `hwids`
MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
ALTER TABLE `wp_users`
ADD CONSTRAINT `users_hwidfk` FOREIGN KEY (`hwidId`) REFERENCES `hwids` (`id`);