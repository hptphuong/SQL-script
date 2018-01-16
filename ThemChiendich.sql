-- =============================================
-- Author:      Phuong Hoang
-- Description: Them chien dich vao bang chien dich, dong thoi cap nhat thong tin trong bang quangcao
-- Parameters:
--   _thoi_gian_bat_dau` varchar(255):chuoi co dang "yyyymmdd"
--   _ngay_ket_thuc_tam_thoi varchar(255): ngay ket thuc tren hop dong, , chuoi co dang "yyyymmdd"
--   _bonus int(11): ngay cong them, 
--   _khu_vuc varchar(255): khu vuc cua chien dich , cho phep go tieng viet co dau
--   _so_luong_xe int(11)
--   _status_record varchar(255): status chien dich - chua ro data, cho phep go tieng viet co dau
--   _ten_chien_dich, varchar(255):cho phep go tieng viet co dau
--   _trang_thai_chien_dich varchar(255): can kiem tra,etc
--   _url_quang_cao varchar(255): url market cua chien dich theo dinh dang [position1]-{url1};[position2]-[url2]
--          Vi du: front-http://abc/image1.jpg;left-http://abc/image2.jpg
--
-- Returns:    
      -- OUT `ck_success` int(11), 
--    - Insert data vao table chiendich
--    - Cap nhat thong tin vao bang quang_cao tai truong url_quang_cao, can bo sung them field loai quang cao

-- History:
--   01/10/2018 - Phuong Hoang: Create first version of store proc.
--   01/13/2018 - update data integration
--              - update return id of chien_dich khi insert thanh cong
--
--
-- Example:
--
-- call ThemChienDich(
-- '20170701', 
-- '20170911', 
--  0, 
-- 'Hà Nội', 
-- 0, 
-- 'status 1', 
-- 'chiến dịch test 4', 
-- 'Cần kiểm tra',
-- 'front-http://abc/image1.jpg;left-http://abc/image2.jpg'
-- );
-- =============================================
USE `cms`;
DROP procedure IF EXISTS `ThemChienDich`;

DELIMITER $$
USE `cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ThemChienDich`(
  `_thoi_gian_bat_dau` varchar(255) ,
  `_ngay_ket_thuc_tam_thoi` varchar(255) ,
  `_bonus` int(11),
  `_khu_vuc` varchar(255) CHARSET utf8,
  `_so_luong_xe` int(11),
  `_status_record` varchar(255) CHARSET utf8,
  `_ten_chien_dich` varchar(255) CHARSET utf8,
  `_trang_thai_chien_dich` varchar(255) CHARSET utf8,
  `_url_quang_cao` varchar(255) CHARSET utf8,
  OUT `ck_success` int(11)
)
proc_label:BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET ck_success = 0;
    END;
  SET @bonus=_bonus;
  SET @thoi_gian_bat_dau = str_to_date(_thoi_gian_bat_dau, '%Y%m%d');
  SET @ngay_ket_thuc_tam_thoi = str_to_date(_ngay_ket_thuc_tam_thoi, '%Y%m%d');
  

  IF(@bonus<0) 
  THEN
      select "bonus day have to positive number";
      SET ck_success= -1;
      LEAVE proc_label;
  END IF;
  IF(@bonus is null) 
  THEN 
    SET @bonus=0;
  END IF;

  SET @thoi_gian_ket_thuc = adddate(@ngay_ket_thuc_tam_thoi,interval @bonus day) ;
  -- select _thoi_gian_bat_dau,_ngay_ket_thuc_tam_thoi,@thoi_gian_bat_dau,@ngay_ket_thuc_tam_thoi,@thoi_gian_bat_dau is null , @ngay_ket_thuc_tam_thoi is null , @thoi_gian_bat_dau<@ngay_ket_thuc_tam_thoi;
  IF(@thoi_gian_bat_dau is null or @ngay_ket_thuc_tam_thoi is null or @thoi_gian_bat_dau>@ngay_ket_thuc_tam_thoi)
  THEN
    select "check again 'thoi gian bat dau' and 'thoi gian ket thuc'";
    SET ck_success = -1;
    LEAVE proc_label;
  END IF;

  IF(_khu_vuc is null or _khu_vuc="")
  THEN
    select "Missing data for 'khu vuc'";
    SET ck_success = -1;
    LEAVE proc_label;
  END IF;

  IF(_so_luong_xe < 0)
  THEN
    select "So luong xe phai la so duong";
    SET ck_success = -1;
    LEAVE proc_label;
  END IF;



  START TRANSACTION;
  INSERT INTO `cms`.`chien_dich` (
    `bonus`, 
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
  SET ck_success=-1;
  IF(ROW_COUNT()>0)
  THEN
    INSERT INTO quang_cao(chien_dich_id,url_quang_cao)
    values (@last_id,_url_quang_cao);
    -- SET
  END IF;


  SET ck_success = @last_ID;
  COMMIT;
  
END$$

DELIMITER ;

