USE `asdgo_cms`;
DROP procedure IF EXISTS `ListXeSapHetChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListXeSapHetChienDich`(
	_chien_dich_id bigint(20)
    )

proc_label:BEGIN

/*
=============================================
    Author:      Phuong Hoang
    Store:  ListXeSapHetChienDich
    Description: List tat ca cac xe sap het chien dich voi cac dieu kien:
    	- List cac xe thuoc chien dich dang chay voi cung loai quang cao, co thoi gian overlap luc dau.
    		(thoi_gian_chuan_bi<thoi_gian_ket_thuc)
    	- Thoi gian sap het chien dich duoc tinh bang hieu so giua thoi_gian_chuan_bi cua chien dich dang 
    		tao va thoi_gian_ket_thuc cua chien dich dang chay
    	- Cac xe da bi overlap se ko dc list


    Parameters:
    	`_chiendich_id` bigint(20),   -- id cua chien dich moi tao/can chinh sua
    	
    	Returns:    
          danh sach id cac xe da duoc add tuong ung voi chien dich
    History:
    	  01/27/2018 - Phuong Hoang: Create store.
    Example
    	call ListXeSapHetChienDich(45);

    Return format:
    	# bien_kiem_soat, bai_xe, create_date, loai_xe, so_cho, so_quan_ly, status_record, tinh_trang_xe, ten_chien_dich, thoi_gian_ket_thuc_chien_dich, chien_dich_id
        '0001', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '4', '12', '1', 'Normal', 'Test chien dich moi overlap duoi', '2', '42'
        '0002', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '7', '13', '1', 'Normal', 'Test chien dich moi overlap duoi', '2', '42'
        '0003', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '4', '14', '1', 'Normal', 'Test listxesaphethan 2', '12', '47'
        '0004', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '4', '15', '1', 'Normal', 'Test listxesaphethan 2', '12', '47'



===================================
*/

	declare current_start_time, current_end_time datetime;
/*-----------------------------------------------------*/
	SET current_start_time=null;
	SET current_end_time=null;
	SET @loai_qc_id = null;
	SET @max_time_xe_sap_het_cdich =null;

/*-----------------------------------------------------*/
	select cd.ngay_chuan_bi, cd.thoi_gian_ket_thuc
	into current_start_time ,current_end_time
	from chien_dich cd
	where cd.id=_chien_dich_id;


    
    
    select qc.id_loaiqc
    into @loai_qc_id
    from quang_cao qc
    where chien_dich_id=_chien_dich_id;	
    
    
    select ts.gia_tri
    into @max_time_xe_sap_het_cdich
    from tham_so ts
    where ten_tham_so = 'max_time_xe_sap_het_cdich';
    
    IF (
    	current_start_time is null
    	or current_end_time is null
    	or @loai_qc_id is null
    	or @max_time_xe_sap_het_cdich is null 
    	)
    THEN
        select current_start_time,current_end_time,@loai_qc_id,@max_time_xe_sap_het_cdich;
    	leave proc_label;
    END IF;
/* Load bien_kiem_soat of all cars which inserted to chien_dich*/
    DROP TEMPORARY TABLE IF EXISTS tmp_xe_in_chiendich;
    DROP TEMPORARY TABLE IF EXISTS tmp_rlst;
    DROP TEMPORARY TABLE IF EXISTS tmp_rlst_duplcate;

    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_xe_in_chiendich
    select bien_kiem_soat
    from xe_chien_dich
    where chien_dich_id=_chien_dich_id;

	/*Test*/
    -- select xe.bien_kiem_soat, xe.bai_xe, xe.create_date, xe.loai_xe, xe.so_cho, xe.so_quan_ly, xe.status_record, xe.tinh_trang_xe, cd.ten_chien_dich,datediff(cd.thoi_gian_ket_thuc, current_start_time) as thoi_gian_ket_thuc_chien_dich, cd.id
    -- from 
    --     xe_chien_dich xcd
    --     left join chien_dich cd
    --         on cd.id=xcd.chien_dich_id
    --     inner join quang_cao qc
    --         on qc.chien_dich_id = cd.id 
    --     left join xe
    --         on xcd.bien_kiem_soat = xe.bien_kiem_soat
    -- where xcd.status_record=1
    -- and xe.status_record=1
    -- and qc.status_record=1
    -- and cd.status_record=1;
    /*Test*/
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_rlst
    -- select  cd.id as chien_dich_id,cd.ngay_chuan_bi,cd.thoi_gian_ket_thuc,@max_time_xe_sap_het_cdich,@current_start_time,xe.*,datediff(cd.thoi_gian_ket_thuc, current_start_time) as thoi_gian_ket_thuc_chien_dich,cd.id
    select xe.bien_kiem_soat, xe.bai_xe, xe.create_date, xe.loai_xe, xe.so_cho, xe.so_quan_ly, xe.status_record, xe.tinh_trang_xe, cd.ten_chien_dich,datediff(cd.thoi_gian_ket_thuc, current_start_time) as thoi_gian_ket_thuc_chien_dich, cd.id
    from 
		xe_chien_dich xcd
		left join chien_dich cd
			on cd.id=xcd.chien_dich_id
		inner join quang_cao qc
			on qc.chien_dich_id = cd.id 
		left join xe
			on xcd.bien_kiem_soat = xe.bien_kiem_soat
	where xcd.status_record=1
    and xe.status_record=1
  	and qc.status_record=1
  	and cd.status_record=1
    and cd.thoi_gian_ket_thuc>=current_start_time
    and cd.thoi_gian_ket_thuc<=current_end_time
    and cd.ngay_chuan_bi<current_start_time
    and datediff(cd.thoi_gian_ket_thuc, current_start_time)<@max_time_xe_sap_het_cdich
    and qc.id_loaiqc =@loai_qc_id
    and xe.bien_kiem_soat not in(
    	select bien_kiem_soat
    	from tmp_xe_in_chiendich
    	);

    -- select * from tmp_rlst;
    /*Delete cars which run in multiple campaigns*/ 
	
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_rlst_duplcate
    select bien_kiem_soat
	from tmp_rlst
	group by bien_kiem_soat
	having count(bien_kiem_soat)>1;
    
    
	-- select * from tmp_rlst_duplcate;
	SET SQL_SAFE_UPDATES = 0;

    delete from tmp_rlst
   	where bien_kiem_soat in(
   		select bien_kiem_soat
   		from tmp_rlst_duplcate
   		);
   	
    
    SET SQL_SAFE_UPDATES = 1;
    select bien_kiem_soat, bai_xe, create_date, loai_xe, 
        so_cho, so_quan_ly, status_record, tinh_trang_xe, 
        ten_chien_dich,thoi_gian_ket_thuc_chien_dich, id as chien_dich_id
    from tmp_rlst;



    -- select * from tmp_chiendich;
    DROP TEMPORARY TABLE IF EXISTS tmp_xe_in_chiendich;
    DROP TEMPORARY TABLE IF EXISTS tmp_rlst;
    DROP TEMPORARY TABLE IF EXISTS tmp_rlst_duplcate;

    
END$$

DELIMITER ;

