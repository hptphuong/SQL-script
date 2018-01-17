-- =============================================
-- Author:      Phuong Hoang
-- Store: TongChienDichDangChay()
-- Description: List name cac loai quang cao dang active.
-- Parameters:
-- Returns:    
--    - Result with sum of chien dich dang chay
-- History:
--   01/17/2018 - Phuong Hoang: Create first version of store proc.
-- Example call ListLoaiQCActive()
-- =============================================

USE `asdgo_cms`;
DROP procedure IF EXISTS `ListLoaiQCActive`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE PROCEDURE `ListLoaiQCActive`()
BEGIN
	select id, ten_loai_quang_cao
    from asdgo_cms.loai_quang_cao
    where status_record=1;
END$$

DELIMITER ;