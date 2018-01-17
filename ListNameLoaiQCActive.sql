USE `asdgo_cms`;
DROP procedure IF EXISTS `ListNameLoaiQCActive`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE PROCEDURE `ListNameLoaiQCActive`()
BEGIN
	select id, ten_loai_quang_cao
    from asdgo_cms.loai_quang_cao
    where status_record=1;
END$$

DELIMITER ;