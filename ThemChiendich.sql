USE `asdgo_cms`;
DROP procedure IF EXISTS `ThemChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ThemChienDich`(
  `_thoi_gian_bat_dau` varchar(255) ,
  `_ngay_ket_thuc_tam_thoi` varchar(255) ,
  `_songay_setup` int(11),
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
 /*   Exit Handler*/
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
    select "handler";
    select -1 as ten_chien_dich, -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,-1 as url_quang_cao,-1 as ten_loai_quang_cao;
        ROLLBACK;
    END;

/*   Exit Handler*/

/*   Result return if error*/
  
  SET @sql_error= "select -1 as ten_chien_dich, -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,-1 as url_quang_cao,-1 as ten_loai_quang_cao;";
  PREPARE QUERY FROM @sql_error;

/* Check bonus & _songay_setup*/
  SET @bonus=_bonus;
  IF(@bonus<0 or _songay_setup <0) 
  THEN
      -- select "bonus day have to positive number";
      execute QUERY;
      LEAVE proc_label;
  END IF;
  IF(@bonus is null) 
  THEN 
    SET @bonus=0;
  END IF;
  IF(_songay_setup is null) 
  THEN 
    SET _songay_setup=0;
  END IF;
  
  SET @songay_setup=-_songay_setup;
 
/*Process @thoi_gian_bat_dau,@ngay_ket_thuc_tam_thoi,@thoi_gian_ket_thuc,@ngay_chuan_bi*/
  SET @thoi_gian_bat_dau = str_to_date(_thoi_gian_bat_dau, '%Y%m%d');
  SET @ngay_ket_thuc_tam_thoi = str_to_date(_ngay_ket_thuc_tam_thoi, '%Y%m%d');  -- thoi gian hop dong
  
  -- SELECT MAX(id)
  -- INTO @cd_max_pre_id
  -- from chien_dich;
  
  SET @thoi_gian_ket_thuc = adddate(@ngay_ket_thuc_tam_thoi,interval @bonus day) ;
  IF(@thoi_gian_bat_dau is null or @ngay_ket_thuc_tam_thoi is null or @thoi_gian_bat_dau>@ngay_ket_thuc_tam_thoi)
  THEN
    execute QUERY;
    LEAVE proc_label;
  END IF;

  SET @ngay_chuan_bi= adddate(@thoi_gian_bat_dau,interval @bonus day) ;
  IF(_khu_vuc is null or _khu_vuc="")
  THEN
    execute QUERY;
    LEAVE proc_label;
  END IF;
/* Check so luong xe*/  
  IF(_so_luong_xe < 0)
  THEN
    -- select "So luong xe phai la so duong";
    execute QUERY;
    LEAVE proc_label;
  END IF;
  -- select ">>>>>>>>>>>>>>>>.test";
  select khach_hang_id;
/* check khach hang exist or not*/
  IF( 
  (select count(*) from khach_hang where id=khach_hang_id) = 0
  )
  THEN
    execute QUERY;
    LEAVE proc_label;
    
  END IF;
  select "check khach hang";
/* check loai quang cao exist or not*/
  select count(*) from loai_quang_cao where id=loai_qc_id;
  IF( 
  (select count(*) from loai_quang_cao where id=loai_qc_id) = 0
  )
  THEN
    execute QUERY;
    LEAVE proc_label;
  END IF;
  select loai_qc_id;
  
  
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
    `trang_thai_chien_dich`,
    `create_date`,
    `ngay_chuan_bi`
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
    _trang_thai_chien_dich,
    now(),
    @ngay_chuan_bi
  );
  select "ok";
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
