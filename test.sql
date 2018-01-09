USE `test`;
DROP procedure IF EXISTS `sayHello`;

DELIMITER $$
USE `test`$$
CREATE PROCEDURE `sayHello` ()
BEGIN
	select "Hello";
END$$

DELIMITER ;


USE `test`;
DROP procedure IF EXISTS `insetDataToCChienDich`;
---------------------------

DELIMITER $$
USE `test`$$
DROP procedure IF EXISTS `insetDataToCChienDich`;
CREATE PROCEDURE `insetDataToCChienDich` 
(
 IN `TenChienDich` VARCHAR(255) ,
 IN `TGBatDau` DATETIME ,
  IN `TGKetThuc` DATETIME ,
  IN `SoLuongXe` INT ,
  IN `TrangThaiCD` VARCHAR(255) ,
  IN `KhuVuc` VARCHAR(45) ,
  IN `Tong4Cho` INT ,
  IN `Tong7Cho` INT ,
  IN `StatusRecord` VARCHAR(45) ,
  IN `TaiKhoanKH` VARCHAR(45) ,
  IN `CreatedDate` DATETIME 
)
BEGIN
	select CONCAT("Hello_",`TenChienDich`) as test;
END$$
DELIMITER ;

CALL insetDataToCChienDich('1',now(),now(),12,'chsy','Ho Chi Minh',100,200,'a','test',now());

select "a"+"2";
SELECT CONCAT("SQL","-", "Tutorial ", "is ", "fun!") AS ConcatenatedString;

