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


DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN

	GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, 
	@errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
	SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);
	SELECT @full_error;
	select "Handler error";
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

    COMMIT;
    select id, chien_dich_id, bien_kiem_soat, create_date
    from xe_chien_dich
    where chien_dich_id=@chiendich_id
    and bien_kiem_soat in (select bien_kiem_soat from tmp);
    DROP TEMPORARY TABLE IF EXISTS tmp;
END$$


DELIMITER ;