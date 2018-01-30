USE `asdgo_cms`;
DROP procedure IF EXISTS `ListXeTrong`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListXeTrong`(
	_chien_dich_id bigint(20)
    )

proc_label:BEGIN

/*
=============================================
    Author:      Phuong Hoang
    Store:  ListXeTrong
    Description: List tat ca cac xe trong(available) cho chien dich moi:
    	- Cac xe chua add vao chien dich nao
    	- Xe da duoc add vao cac chien dich ko trung voi loaiqc cua chien dich moi
    	- Xe da duoc add vao chien dich nhung trong trong thoi gian cua chien dich moi


    Parameters:
    	`_chiendich_id` bigint(20),   -- id cua chien dich moi tao/can chinh su
    	
    Returns:    
          danh sach id cac xe da duoc add tuong ung voi chien dich

    History:
    	  01/27/2018 - Phuong Hoang: Create store.
    Example
    	call ListXeTrong(44);

     Return format:
    	# bien_kiem_soat, bai_xe, create_date, loai_xe, so_cho, so_quan_ly, status_record, tinh_trang_xe
        '0003', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '4', '14', '1', 'Normal'
        '0004', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '4', '15', '1', 'Normal'
        '0005', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '7', '16', '1', 'Normal'
        '0006', 'bai 2', '2018-01-19 03:25:40', 'Toyota', '7', '17', '1', 'Normal'
        '0007', 'bai 2', '2018-01-19 03:25:40', 'Toyota', '4', '18', '1', 'Normal'
        '0009', 'bai 1', '2018-01-19 03:25:40', 'Toyota', '7', '19', '1', 'Normal'


===================================
*/
   
/*Get Advertise type of new campaign*/

    declare _loaiqc_of_new_camp bigint(20);
    SET @new_ngay_chuan_bi =null;
    SET @new_thoi_gian_ket_thuc =null;

    select qc.id_loaiqc 
    into _loaiqc_of_new_camp
    from quang_cao qc
    where qc.chien_dich_id=_chien_dich_id;

/*Filter cars which have loaiqc in time of new chien_dich*/
    select cd.ngay_chuan_bi,cd.thoi_gian_ket_thuc
    into @new_ngay_chuan_bi,@new_thoi_gian_ket_thuc
    from chien_dich cd
    where cd.id=_chien_dich_id;

    IF(
        _loaiqc_of_new_camp is null
        or @new_thoi_gian_ket_thuc is null
        or @new_ngay_chuan_bi is null
        )
    THEN
            leave proc_label;
    END IF;

    -- set @new_ngay_chuan_bi=str_to_date('20190825','%Y%m%d');  --   20190929
    -- set @new_thoi_gian_ket_thuc = str_to_date('20191001','%Y%m%d'); --  20191116
    
    select xe.bien_kiem_soat, 
           xe.bai_xe, create_date, 
           xe.loai_xe, 
           xe.so_cho, 
           xe.so_quan_ly, 
           xe.status_record, 
           xe.tinh_trang_xe
    from xe
    where xe.status_record=1
    and xe.bien_kiem_soat not in
    (
        select distinct xcd.bien_kiem_soat
        from 
            xe_chien_dich xcd
        inner join quang_cao qc
            on qc.chien_dich_id=xcd.chien_dich_id
        inner join chien_dich cd
            on cd.id=xcd.chien_dich_id
        where qc.id_loaiqc=1
        and(

            (
                ngay_chuan_bi>=@new_ngay_chuan_bi and
                ngay_chuan_bi<= @new_thoi_gian_ket_thuc
            )
        or  (
                ngay_chuan_bi<=@new_ngay_chuan_bi and
                thoi_gian_ket_thuc>=@new_ngay_chuan_bi 
            )

        )
    );
 


    
END$$





DELIMITER ;

