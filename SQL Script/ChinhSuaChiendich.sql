USE `asdgo_cms`;
DROP procedure IF EXISTS `ChinhSuaChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ChinhSuaChienDich`(
  `_chien_dich_id` bigint(20),
  `_thoi_gian_bat_dau` varchar(255) ,
  `_ngay_ket_thuc_tam_thoi` varchar(255) ,
  `_songay_setup` int(11),
  `_bonus` int(11),
  `_khu_vuc` varchar(255) CHARSET utf8,
  `_ten_chien_dich` varchar(255) CHARSET utf8,
  `_url_quang_cao` varchar(255) CHARSET utf8,
  `_khach_hang_id` bigint(20),
  `_loai_qc_id` bigint(20),
  `_tien_chien_dich` bigint(20)

)
proc_label:BEGIN
 
-- =============================================
-- Author:      Phuong Hoang
-- Description: Chinh sua chien dich sau khi load bang store ListChienDichByID
-- Parameters:
--   `_chien_dich_id` bigint(20),
--   _thoi_gian_bat_dau` varchar(255):chuoi co dang "yyyymmdd"
--   _ngay_ket_thuc_tam_thoi varchar(255): ngay ket thuc tren hop dong, , chuoi co dang "yyyymmdd"
--   _songay_setup int(11),
--   _bonus int(11): ngay cong them, 
--   _khu_vuc varchar(255): khu vuc cua chien dich , cho phep go tieng viet co dau
--   _ten_chien_dich, varchar(255):cho phep go tieng viet co dau
--   _url_quang_cao varchar(255): url market cua chien dich theo dinh dang [position1]-{url1};[position2]-[url2]
--          Vi du: front-http://abc/image1.jpg;left-http://abc/image2.jpg
--   _khach_hang_id bigint(20) : id cua khach hang ung voi chien dich
--   _loai_qc_id bigint(20): id cua loai quang cao ung voi chien dich
--   `_tien_chien_dich` bigint(20)

--
-- Returns:    
--      xem tai    https://docs.google.com/document/d/1gLfDfFGFRr9t5O6b8JwZjqjUPvDHGayrVP5HoyjobHw/edit?ts=5a5cdef7
-- History:
--   01/31/2018 - Phuong Hoang: Create first version of store proc.
--
-- Example:
--
-- call ChinhSuaChienDich(
--   68,
--   "20190218" ,
--   "20190318" ,
--   1,
--   4,
--   "HCM",
--   "chinh sua chien dich test 1",
--   "front-http://chinh sua chien dich test 2",
--   1,
--   1,
--   15000

-- );
-- =============================================
/*   Exit Handler*/

  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN

    

    select -1 as ten_chien_dich, -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,
       -1 as url_quang_cao,-1 as ten_loai_quang_cao, -1 as tien_chien_dich,  -1 as ngay_chuan_bi,  -1 as ngay_ket_thuc_tam_thoi;
        ROLLBACK;
    END;


/*   Exit Handler*/

/*   Result return if error*/
  
  SET @sql_error= "select -1 as id, -1 as ten_chien_dich, 
      -1 as bonus,-1 as thoi_gian_bat_dau,-1 as thoi_gian_ket_thuc,-1 as khu_vuc,-1 as url_quang_cao,-1 as ten_loai_quang_cao,
      -1 as tien_chien_dich,  -1 as ngay_chuan_bi, -1 as ngay_ket_thuc_tam_thoi;";
  PREPARE QUERY FROM @sql_error;

/* Check bonus & _songay_setup*/

  /*Check _chien_dich_id*/
  IF( 
    (select count(*) from chien_dich where id=_chien_dich_id and status_record =1) = 0
  )
  THEN
    execute QUERY;
    LEAVE proc_label;
    
  END IF;
  SET @bonus=_bonus;
  IF(@bonus<0 or _songay_setup <0 or _tien_chien_dich<0 or _loai_qc_id is null or _khach_hang_id is null) 
  THEN
      -- select "bonus day have to positive number";
      execute QUERY;
      LEAVE proc_label;
  END IF;

  IF(@bonus is null) 
  THEN 
    SET @bonus=0;
  END IF;

  IF(_tien_chien_dich is null) 
  THEN 
    SET _tien_chien_dich=0;
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

  SET @ngay_chuan_bi= adddate(@thoi_gian_bat_dau,interval @songay_setup day) ;
  IF(_khu_vuc is null or _khu_vuc="")
  THEN
    execute QUERY;
    LEAVE proc_label;
  END IF;

  IF( 
    (select count(*) from khach_hang where id=_khach_hang_id and status_record =1) = 0
  )
  THEN
    execute QUERY;
    LEAVE proc_label;
    
  END IF;
  
/* check loai quang cao exist or not*/
  -- select count(*) from loai_quang_cao where id=_loai_qc_id;
  IF( 
  
    (select count(*) from loai_quang_cao where id=_loai_qc_id and status_record=1) = 0
  )
  THEN
    execute QUERY;
    LEAVE proc_label;
  END IF;
  SET _ten_chien_dich = trim(_ten_chien_dich);


  /*Get old loai_qc_id and khach_hang_id*/
  SET @old_loai_quang_cao_id =null;
  SET @old_khach_hang_id = null;

  select lqc.id
  into @old_loai_quang_cao_id
  from loai_quang_cao lqc
  where lqc.id=(
    select qc.id_loaiqc
    from quang_cao qc
    where qc.chien_dich_id=_chien_dich_id
    and qc.status_record=1
    )
  and lqc.status_record=1;

  -- select cd.khach_hang_id
  -- into @old_khach_hang_id
  -- from chien_dich cd
  -- where cd.status_record =1
  -- and cd.id = _chien_dich_id;

  -- IF( 
  --   @old_loai_quang_cao_id = _loai_qc_id
  -- )
  -- THEN
  --   execute QUERY;
  --   LEAVE proc_label;
  -- END IF;
  
  START TRANSACTION;

 
  update chien_dich
  SET 
    bonus = @bonus,
    create_date=now(),
    khu_vuc=_khu_vuc,
    ngay_chuan_bi = @ngay_chuan_bi,
    ngay_ket_thuc_tam_thoi = @ngay_ket_thuc_tam_thoi,
    ten_chien_dich = _ten_chien_dich,
    thoi_gian_bat_dau=@thoi_gian_bat_dau,
    thoi_gian_ket_thuc=@thoi_gian_ket_thuc,
    khach_hang_id=_khach_hang_id,
    tien_chien_dich=_tien_chien_dich
  where id =_chien_dich_id;


  -- select kh.ten_viet_tat 
  -- into @kh_ten_viet_tat
  -- from khach_hang kh
  -- where kh.id=_khach_hang_id;
  
  /*Update records in table quang_cao*/
  IF( 
    @old_loai_quang_cao_id is null
    or
    @old_loai_quang_cao_id <>_loai_qc_id
  )
  THEN
    select _url_quang_cao;
    update quang_cao
    set status_record =0
    where chien_dich_id = _chien_dich_id;
    INSERT INTO quang_cao(create_date,status_record,chien_dich_id,url_quang_cao,id_loaiqc)
    values (now(),1,_chien_dich_id,_url_quang_cao,_loai_qc_id);
  ELSE
    update quang_cao
    SET 
        create_date = now(),
        url_quang_cao = _url_quang_cao
    where chien_dich_id = _chien_dich_id
    and status_record =1;
  END IF;
  
  

  COMMIT;
  
  select distinct cd.id, cd.ten_chien_dich, cd.bonus,cd.thoi_gian_bat_dau,cd.thoi_gian_ket_thuc,
        cd.khu_vuc,qc.url_quang_cao,lqc.ten_loai_quang_cao,
        cd.tien_chien_dich, cd.ngay_chuan_bi, cd.ngay_ket_thuc_tam_thoi,
        cd.khach_hang_id
  from chien_dich cd
    inner join quang_cao qc
    inner join loai_quang_cao lqc
      on cd.id= qc.chien_dich_id
      and qc.id_loaiqc=lqc.id
      and cd.status_record=1
      and qc.status_record=1
      and lqc.status_record=1
  where cd.id=_chien_dich_id;
  
END$$

DELIMITER ;

