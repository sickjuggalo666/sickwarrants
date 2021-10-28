CREATE TABLE IF NOT EXISTS `warrants` ( 

    `id`                  varchar(100) NOT NULL,
    `name`                varchar(100) NOT NULL DEFAULT '{}',
    `bday`                varchar(100) NOT NULL DEFAULT '{}',
    `reason`              LONGTEXT NOT NULL DEFAULT '{}',
    CONSTRAINT id
        UNIQUE (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `warrants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

INSERT INTO `warrants` (name,bday,reason) VALUES 
    ('Jack Napier', '08/15/1990', 'IDK Cause i feel like it!')
;