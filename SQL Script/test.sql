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




///////// test db


SELECT * FROM asdgo_cms.khach_hang;
select * from tai_khoan;
INSERT INTO `asdgo_cms`.`tai_khoan` 
(`create_date`, `enabled`, `last_password_reset_date`, `loai_tai_khoang`, `password`, `trang_thaitk`) 
VALUES (now(), 1, now(), 'KH', '11', '1'),
(now(), 1, now(), 'TXe', '11', '1'),
(now(), 1, now(), 'KH', '1123', '1');

select * from asdgo_cms.tai_khoan;
INSERT INTO `asdgo_cms`.`khach_hang` 
(`sdt`, `create_date`, `dia_chi`, `email`, `khach_hang_cap_tren`, `status_record`, `ten_cong_ty`, `ten_viet_tat`, `tai_khoanid`) 
VALUES ('0908xxx', now(), 'Tran Hung Dao', 'ba1@gmail.com', null, 1, 'Cong Ty Đất Việt', 'Đất Việt', 4),
('0908xxx', now(), 'Tran Hung Dao', 'con-ba1-1@gmail.com', 1, 1, 'Cong Ty Đất Việt -thanh vien 1', 'Đất Việt -Thanh vien 1', 4),
('0908xxx', now(), 'Nguyen Tri phuong', 'con-ba1-2@gmail.com', 1, 1, 'Cong Ty Đất Việt -mem 2', 'Đất Việt - thanh vien 2', 6),
('0908xxx', now(), 'Lý Thường Kiệt', 'ba2@gmail.com', null, 1, 'Cong Ty Lua Việt', 'Lua Việt', 6),
('0908xxx', now(), 'Lý Thường Kiệt', 'con-ba2@gmail.com', 4, 1, 'Cong Ty  mam', 'mam',6);


INSERT INTO `asdgo_cms`.`loai_quang_cao` 
(`create_date`, `status_record`, `ten_loai_quang_cao`) 
VALUES (now(), 1, 'Tran duoi');

select * from asdgo_cms.khach_hang;
select * from loai_quang_cao;


call ListLoaiQCActive();
call ListNameKhachHang();


call ThemChienDich(
  '20180118',
    '20180220',
    2,
    3,
    'Test Area 1',
    1,
    'Bão sa mạc 5',
    'Bình thường',
    "front-http://aaa.com;left-http://xyz.com",
    4,
    1
    
);





select * from asdgo_cms.khach_hang;

select * from asdgo_cms.tai_khoan;

truncate table `asdgo_cms`.`khach_hang` ;

