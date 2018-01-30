-- =============================================
-- Author:      Phuong Hoang
-- Store: ListNameKhachHang
-- Description: List name khach hang ( có mối quan hệ cha con, cách nhau bởi --).
-- Parameters:
-- Returns:    
--    - Result with format id, ten_viet_tat
-- History:
--   01/17/2018 - Phuong Hoang: Create first version of store proc.
-- Example: call ListNameKhachHang()
-- =============================================

USE `asdgo_cms`;
DROP procedure IF EXISTS `ListNameKhachHang`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListNameKhachHang`()
BEGIN
	select id,ten_viet_tat from 
		asdgo_cms.khach_hang
	where khach_hang_cap_tren is null
	or khach_hang_cap_tren =""
	union
	select kh1.id , concat(kh2.ten_viet_tat,"--",kh1.ten_viet_tat) as ten_viet_tat from 
	asdgo_cms.khach_hang kh1
		inner join asdgo_cms.khach_hang kh2
		on kh1.khach_hang_cap_tren=kh2.id
	order by ten_viet_tat;
END$$

DELIMITER ;