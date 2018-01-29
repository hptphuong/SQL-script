USE `asdgo_cms`;
DROP procedure IF EXISTS `ListXeChienDichKhac`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListXeChienDichKhac`(
	_chien_dich_id bigint(20)
    )

proc_label:BEGIN

/*
=============================================
    Author:      Phuong Hoang
    Store:  ListXeChienDichKhac
    Description: List tat ca cac xe o trong chien dich khac overlap voi duoi cua chien dich dang tao:
    	- Neu xe da duoc add vao chien dich hien tai khi chinh sua se ko dc list vao day nua
        - Neu xe da chay nhieu chien dich( da duplicate) cung ko dc list vao day


    Parameters:
    	`_chiendich_id` bigint(20),   -- id cua chien dich moi tao/can chinh sua
    	
    	Returns:    
          danh sach id cac xe da duoc add tuong ung voi chien dich
    History:
    	  01/28/2018 - Phuong Hoang: Create store.
    Example
    	call ListXeChienDichKhac(56);

    Return format:
    	# bien_kiem_soat, bai_xe, create_date, loai_xe, so_cho, so_quan_ly, status_record, tinh_trang_xe, ten_chien_dich, thoi_gian_ket_thuc_chien_dich, chien_dich_id
        '0008', 'bai 1', '2018-01-28 08:32:18', 'Toyota', '7', '29', '1', 'Normal', 'sample campaign 60', '90', '60'
        '0018', 'bai 1', '2018-01-28 05:06:19', 'Toyota', '4', '28', '1', 'Normal', 'sample campaign 60', '90', '60'
        '0019', 'bai 4', '2018-01-28 08:33:44', 'Toyota', '7', '29', '1', 'Normal', 'sample campaign 60', '90', '60'
===================================
*/

	declare current_start_time, current_end_time datetime;
/*-----------------------------------------------------*/
	SET current_start_time=null;
	SET current_end_time=null;
	SET @loai_qc_id = null;


/*-----------------------------------------------------*/
	select cd.ngay_chuan_bi, cd.thoi_gian_ket_thuc
	into current_start_time ,current_end_time
	from chien_dich cd
	where cd.id=_chien_dich_id;

    
    select qc.id_loaiqc
    into @loai_qc_id
    from quang_cao qc
    where chien_dich_id=_chien_dich_id;	
    

    
    IF (
    	current_start_time is null
    	or current_end_time is null
    	or @loai_qc_id is null
    	
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
    and cd.ngay_chuan_bi<=current_end_time
    and current_end_time<= cd.thoi_gian_ket_thuc
    and cd.ngay_chuan_bi>current_start_time
    and qc.id_loaiqc =@loai_qc_id
    and xe.bien_kiem_soat not in( 
        -- xe da co trong chien dich se khong xuat hien o day
    	select bien_kiem_soat
    	from tmp_xe_in_chiendich
    	);

    -- select * from tmp_rlst;
    /*Delete cars which is running in multiple campaigns*/ 
	
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

