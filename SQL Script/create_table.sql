
USE test;
DROP TABLE IF EXISTS `test`.`CQuangCao`;
DROP TABLE IF EXISTS `test`.`CChienDich`;

CREATE TABLE  `test`.`CChienDich` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `TenChienDich` VARCHAR(255) DEFAULT NULL,
  `TGBatDau` DATETIME DEFAULT NULL,
  `TGKetThuc` DATETIME DEFAULT NULL,
  `SoLuongXe` INT DEFAULT NULL,
  `TrangThaiCD` VARCHAR(255) DEFAULT NULL,
  `KhuVuc` VARCHAR(45) DEFAULT NULL,
  `Tong4Cho` INT DEFAULT NULL,
  `Tong7Cho` INT DEFAULT NULL,
  `StatusRecord` VARCHAR(45) DEFAULT NULL,
  `TaiKhoanKH` VARCHAR(45) DEFAULT NULL,
  `CreatedDate` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)
  )DEFAULT CHARSET=utf8;


CREATE TABLE `test`.`CQuangCao` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `status_code` varchar(255) DEFAULT NULL,
  `url_quang_cao` varchar(255) DEFAULT NULL,
  `loai_quang_cao` varchar(255) DEFAULT NULL,
  `chien_dich_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`chien_dich_id`) REFERENCES `test`.`CChienDich`(`id`)
) DEFAULT CHARSET=utf8;





-- call inserToCChiendich("hi");
-- call inserToCChiendich(
--   _TenChienDich VARCHAR(255) ,
--   _TGBatDau DATETIME ,
--   _TGKetThuc DATETIME ,
--   _SoLuongXe INT ,
--   _TrangThaiCD VARCHAR(255) ,
--   _KhuVuc VARCHAR(45) ,
--   _Tong4Cho INT ,
--   _Tong7Cho INT ,
--   _StatusRecord VARCHAR(45) ,
--   _TaiKhoanKH VARCHAR(45) ,
--   _CreatedDate DATETIME,
--   _loai_quang_cao varchar(255),
--   _url_quang_cao varchar(255) 
-- );
-- 


call inserToCChiendich(null,null,'quang cao 1');
select * from cchiendich;
