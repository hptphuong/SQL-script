-- =============================================
-- Author:      Phuong Hoang
-- Description: Them chien dich vao bang chien dich, dong thoi cap nhat thong tin trong bang quangcao
-- Parameters:
--   _bonus int(11): ngay cong them, 
--   _khu_vuc varchar(255): khu vuc cua chien dich , cho phep go tieng viet co dau
--   _TenChienDich varchar(255):Ten chien dich, 
--   _ngay_ket_thuc_tam_thoi varchar(255): ngay ket thuc tren hop dong, , chuoi co dang "yyyymmdd"
--   _so_luong_xe int(11)
--   _status_record varchar(255): status chien dich - chua ro data, cho phep go tieng viet co dau
--   _ten_chien_dich, varchar(255):cho phep go tieng viet co dau
--   _thoi_gian_bat_dau` varchar(255):chuoi co dang "yyyymmdd"
--   _trang_thai_chien_dich varchar(255): can kiem tra,etc
--   _url_quang_cao varchar(255): url market cua chien dich theo dinh dang [position1]-{url1};[position2]-[url2]
--          Vi du: front-http://abc/image1.jpg;left-http://abc/image2.jpg
--
-- Returns:    
--    - Inser data vao table chiendich
--    - Cap nhat thong tin vao bang quang_cao tai truong url_quang_cao, can bo sung them field loai quang cao
-- History:
--   01/10/2018 - Phuong Hoang: Create first version of store proc.
-- =============================================
USE `cms`;
DROP procedure IF EXISTS `ThemChienDich`;

DELIMITER $$
USE `cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ThemChienDich`(
  `_bonus` int(11),
  `_khu_vuc` varchar(255) CHARSET utf8,
  `_ngay_ket_thuc_tam_thoi` varchar(255) ,
  `_so_luong_xe` int(11)  ,
  `_status_record` varchar(255) CHARSET utf8,
  `_ten_chien_dich` varchar(255) CHARSET utf8,
  `_thoi_gian_bat_dau` varchar(255) ,
  `_trang_thai_chien_dich` varchar(255) CHARSET utf8,
  `_url_quang_cao` varchar(255) CHARSET utf8
)
BEGIN
  SET @bonus=_bonus;
  IF(@bonus is null) THEN SET @bonus=0;
  END IF;
  SET @thoi_gian_bat_dau = str_to_date(_thoi_gian_bat_dau, '%Y%m%d');
  SET @ngay_ket_thuc_tam_thoi = str_to_date(_ngay_ket_thuc_tam_thoi, '%Y%m%d');
  SET @thoi_gian_ket_thuc = adddate(@ngay_ket_thuc_tam_thoi,interval @bonus day) ;
  
  INSERT INTO `cms`.`chien_dich` (
    `bouns`, 
    `khu_vuc`, 
    `ngay_ket_thuc_tam_thoi`, 
    `so_luong_xe`, 
    `status_record`, 
    `ten_chien_dich`, 
    `thoi_gian_bat_dau`, 
    `thoi_gian_ket_thuc`, 
    `trang_thai_chien_dich`
    ) 
  VALUES ( 
    @bonus, 
    _khu_vuc, 
    @ngay_ket_thuc_tam_thoi, 
    _so_luong_xe, 
    _status_record, 
    _ten_chien_dich, 
    @thoi_gian_bat_dau, 
    @thoi_gian_ket_thuc, 
    _trang_thai_chien_dich
  );
  SET @last_ID = LAST_INSERT_ID();
  INSERT INTO quang_cao(chien_dich_id,url_quang_cao)
  values (@last_id,_url_quang_cao);
  
END$$

DELIMITER ;

