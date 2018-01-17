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




--------------------------------------------------------------------------------------
--------------------------------

  -- new version - not ready






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
USE `asdgo_cms`;
DROP procedure IF EXISTS `ThemChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
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
  `khach_hang_id`bigint(20),
  `loai_qc_id` bigint(20)
)
proc_label:BEGIN
 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
    select -1 as ten_chien_dich, -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,-1 as url_quang_cao,-1 as ten_loai_quang_cao;
        ROLLBACK;
    END;
  SET @bonus=_bonus;
  SET @sql_error= "select -1 as ten_chien_dich, -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,-1 as url_quang_cao,-1 as ten_loai_quang_cao;";
  PREPARE QUERY FROM @sql_error;
  SET @thoi_gian_bat_dau = str_to_date(_thoi_gian_bat_dau, '%Y%m%d');
  SET @ngay_ket_thuc_tam_thoi = str_to_date(_ngay_ket_thuc_tam_thoi, '%Y%m%d');  -- thoi gian hop dong
  SELECT MAX(id)
  INTO @cd_max_pre_id
  from chien_dich;
  select @cd_max_pre_id;
  IF(@bonus<0) 
  THEN
      -- select "bonus day have to positive number";
      execute QUERY;
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
    -- select "check again 'thoi gian bat dau' and 'thoi gian ket thuc'";
    execute QUERY;
    LEAVE proc_label;
  END IF;
 
  IF(_khu_vuc is null or _khu_vuc="")
  THEN
    -- select "Missing data for 'khu vuc'";
    execute QUERY;
    LEAVE proc_label;
  END IF;
  
  IF(_so_luong_xe < 0)
  THEN
    -- select "So luong xe phai la so duong";
    execute QUERY;
    LEAVE proc_label;
  END IF;
  -- check khach_hang
  IF( 
  (select count(*) from khach_hang where id=khach_hang_id) = 0
  )
  THEN
  -- select "Khong co data khach hang";
    execute QUERY;
    
    LEAVE proc_label;
    
  END IF;
  
  -- check loai quang cao
  IF( 
  (select count(*) from khach_hang where id=loai_qc_id) = 0
  )
  THEN
  -- select "Khong ton tai loai qc";
    execute QUERY;
    LEAVE proc_label;
  END IF;
  
  
  
  START TRANSACTION;
  INSERT INTO `asdgo_cms`.`chien_dich` (
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
  
  SET @chien_dich_count=row_count();
  select @chien_dich_count;
  SET @chien_dich_id = LAST_INSERT_ID();
  
  INSERT INTO quang_cao(create_date,status_code,chien_dich_id,url_quang_cao,id_loaiqc)
  values (now(),1,@chien_dich_id,_url_quang_cao,loai_qc_id);
      
  COMMIT;
  select @chien_dich_id;
  select distinct cd.ten_chien_dich, cd.bonus,cd.thoi_gian_bat_dau,cd.thoi_gian_ket_thuc,cd.khu_vuc,qc.url_quang_cao,lqc.ten_loai_quang_cao
  from chien_dich cd
  inner join quang_cao qc
  inner join loai_quang_cao lqc
  on cd.id= qc.chien_dich_id
  and qc.id_loaiqc=lqc.id
  where cd.id=@chien_dich_id;
END$$

DELIMITER ;

