USE `asdgo_cms`;
DROP procedure IF EXISTS `ListXeTrongChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListXeTrongChienDich`(
	_chien_dich_id bigint(20)
    )

proc_label:BEGIN

/*
=============================================
    Author:      Phuong Hoang
    Store:  ListXeTrongChienDich
    Description: List tat ca cac xe o trong chien dich khac overlap voi duoi cua chien dich dang tao:
    	- Neu xe da duoc add vao chien dich hien tai khi chinh sua se ko dc list vao day nua
        - Neu xe da chay nhieu chien dich( da duplicate) cung ko dc list vao day


    Parameters:
    	`_chien_dich_id` bigint(20),   -- id cua chien dich moi tao/can chinh sua
    	
    	Returns:    
          danh sach id cac xe da duoc add tuong ung voi chien dich
    History:
    	  01/28/2018 - Phuong Hoang: Create store.
    Example
    	call ListXeTrongChienDich(59);

    Return format:
    	# chien_dich_id, bien_kiem_soat, bai_xe, loai_xe, so_cho, so_quan_ly, status_record, tinh_trang_xe, create_date
            '59', '0008', 'bai 1', 'Toyota', '7', '29', '1', 'Normal', '2018-01-28 08:32:18'
            '59', '0018', 'bai 1', 'Toyota', '4', '28', '1', 'Normal', '2018-01-28 05:06:19'
            '59', '0019', 'bai 4', 'Toyota', '7', '29', '1', 'Normal', '2018-01-28 08:33:44'
===========================
*/

	select xcd.chien_dich_id,xcd.bien_kiem_soat,xe.bai_xe,xe.loai_xe,xe.so_cho,xe.so_quan_ly,xe.status_record,xe.tinh_trang_xe,xe.create_date 
    from xe_chien_dich xcd
    inner join xe
        on xe.bien_kiem_soat=xcd.bien_kiem_soat
    where xcd.chien_dich_id=_chien_dich_id
    and xcd.status_record=1;
    
END$$

DELIMITER ;

