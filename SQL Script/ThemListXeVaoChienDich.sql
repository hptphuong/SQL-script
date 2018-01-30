-- =============================================
-- Author:      Phuong Hoang
-- Store:  ThemListXeVaoChienDich
-- Description: Them list id cac xe vao chien dich.
-- Parameters:
-- 	`_chiendich_id` bigint(20),
-- 	`_list_bien_kiem_soat` varchar(255) -- split by comma
--
-- Returns:    
--      danh sach id cac xe da duoc add tuong ung voi chien dich
-- History:
--   01/19/2018 - Phuong Hoang: Create store.
-- Example
--   call ThemListXeVaoChienDich(5,"0001;0002");
-- # id, chien_dich_id, bien_kiem_soat, create_date
-- '75', '5', '0001', '2018-01-19 15:37:44'
-- '76', '5', '0002', '2018-01-19 15:37:44'

-- ===================================

USE `asdgo_cms`;
DROP procedure IF EXISTS `ThemListXeVaoChienDich`;

DELIMITER $$
USE `asdgo_cms`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ThemListXeVaoChienDich`(
`_chiendich_id` bigint(20),
`_list_bien_kiem_soat` varchar(255) -- split by comma
)
proc_label:BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE nb_sevenseat INT DEFAULT 0;
DECLARE nb_fourseat INT DEFAULT 0;


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN

	-- GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
	-- @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
	-- SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
	-- SELECT @full_error;
	
	select -1 as id, 
		-1 as chien_dich_id, 
		-1 as bien_kiem_soat, 
		-1 as create_date;

	rollback;
END;
	
	SET @chiendich_id = _chiendich_id;
    SET @list_bien_kiem_soat =_list_bien_kiem_soat;	
	DROP TEMPORARY TABLE IF EXISTS tmp;

	CREATE TEMPORARY TABLE IF NOT EXISTS tmp (
    `bien_kiem_soat` varchar(255) NOT NULL,
    PRIMARY KEY (`bien_kiem_soat`)) ENGINE=MEMORY; 
    START TRANSACTION;
do_this:LOOP
    
		SET strLen = LENGTH(@list_bien_kiem_soat);
		SET SubStrLen = LENGTH(SUBSTRING_INDEX(@list_bien_kiem_soat, ';', 1))+2;
        SET @bien_kiem_soat = trim(SUBSTRING_INDEX(@list_bien_kiem_soat, ';', 1));

		IF(
			(SubStrLen>0 or SubStrLen is not null )
            and (select count(*) from xe where bien_kiem_soat=@bien_kiem_soat)>0
        )
        THEN
			insert into tmp(`bien_kiem_soat`)
            values(@bien_kiem_soat);
            insert into xe_chien_dich(chien_dich_id,bien_kiem_soat,status_record,create_date)
            values(@chiendich_id,@bien_kiem_soat,1,now())
            ON DUPLICATE KEY UPDATE
			chien_dich_id=@chiendich_id, bien_kiem_soat=@bien_kiem_soat;

			IF(
				select(select so_cho 
				from asdgo_cms.xe
				where bien_kiem_soat=@bien_kiem_soat)=4	
				)
			THEN
				set nb_fourseat=nb_fourseat+1;

			else
				set nb_sevenseat= nb_sevenseat+1;
			END IF;
		else
			-- truncate tmp;
            rollback;
            leave proc_label;
        END IF;
		SET @list_bien_kiem_soat= MID(@list_bien_kiem_soat, SubStrLen, strLen);
		-- select @list_bien_kiem_soat;

		IF (@list_bien_kiem_soat = NULL or @list_bien_kiem_soat="") THEN
			LEAVE do_this;
		END IF;
	END LOOP do_this;
	/*update chien dich*/
	update chien_dich
		set tong4cho=nb_fourseat, tong7cho=nb_sevenseat, so_luong_xe = nb_sevenseat+nb_fourseat
		where id = @chiendich_id;
    COMMIT;
    select id, chien_dich_id, bien_kiem_soat, create_date
    from xe_chien_dich
    where chien_dich_id=@chiendich_id
    and bien_kiem_soat in (select bien_kiem_soat from tmp);
    DROP TEMPORARY TABLE IF EXISTS tmp;
END$$


DELIMITER ;