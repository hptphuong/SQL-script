USE `asdgo_cms`;
DROP procedure IF EXISTS `ListXeSapHetChienDich`;

DELIMITER $$
USE `asdgo_cms`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ListXeSapHetChienDich`()
proc_label:BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN

	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
	@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
	SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
	SELECT @full_error;
	select "Handler error";
	rollback;
END;
	
	
END$$


DELIMITER ;

select * from chien_dich
		where thoi_gian_ket_thuc>Date(now())
		and datediff(thoi_gian_ket_thuc,date(now()))<10;


select* 
from 
	( 	
		select * from quang_cao where quang_cao.id_loaiqc= @loaiqc_id
		
	) t1

inner join (
		select * from chien_dich
		where thoi_gian_ket_thuc>Date(now())
		and datediff(thoi_gian_ket_thuc,date(now()))<@cond_xehethan
	
) t2
inner join xe t3
on t1.chien_dich_id=t2.id
and t3.bien_kiem_soat=