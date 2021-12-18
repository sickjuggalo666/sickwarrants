CREATE TABLE IF NOT EXISTS `warrants` (
    `case` INT(20) NOT NULL,
    `firstname` varchar(10) NOT NULL,
    `lastname` varchar(10) NOT NULL,
    `bday` varchar(15) NOT NULL,
    `reason` LONGTEXT NOT NULL,
    `active` varchar(5) NOT NULL,
    CONSTRAINT `case` UNIQUE (`case`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

INSERT INTO `warrants` (`case`, `firstname`, `lastname`, `bday`, `reason`) VALUES 
    ('1212', 'Jack', 'Napier','04/20/1420','IDK Cause i feel like it!')
; 