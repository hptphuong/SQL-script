USE `asdgo_cms`;
DROP procedure IF EXISTS `XoaChienDich`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `XoaChienDich`(
    `_id` bigint(20)
)
proc_label:BEGIN

/*
=============================================
    Author:      Phuong Hoang
    Store:  XoaChienDich
    Description: Soft delete chien dich
        - Records Tu bang chien_dich
        - Records tu xe_chien_dich

    Parameters:
        `_chiendich_id` bigint(20),   -- id cua chien dich moi tao/can chinh su
        
    Returns:    
          danh sach id cac xe da duoc add tuong ung voi chien dich

    History:
          01/23/2018 - Phuong Hoang: Create store.
    Example
        call XoaChienDich(4);

     Return format:
         # id, status_record
        '4', '0'



===================================
*/
 /*   Exit Handler*/
  DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
    select -1 as id, -1 as status_record ;
        ROLLBACK;
    END;
 IF(
    select cd.status_record
    from chien_dich cd
    where cd.id=_id
    )=0
 THEN
    select 0 as id, 0 as status_record ;
    leave proc_label;
 END IF;


  -- select _id;
  START TRANSACTION;

/*Soft remove in xe_chien_dich*/
  update xe_chien_dich
  set status_record = 0
  where chien_dich_id =_id;

/*Soft remove in chien_dich*/
  update chien_dich
  set status_record=0
  where id=_id;
  COMMIT;
  
  select cd.id, cd.status_record
  from chien_dich cd
  where cd.id=_id;



  
  
END$$

DELIMITER ;

