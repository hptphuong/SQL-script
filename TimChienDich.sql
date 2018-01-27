-- =============================================
-- Author:      Phuong Hoang
-- Description: Tim chien dich theo cac filter cua man hinh quan ly chien dich.
-- Parameters:
--  `_ten_chien_dich` varchar(255) CHARSET utf8, co the nhap tieng viet
--  `_ngay_bat_dau` varchar(255) , _ngay_bat_dau theo dinh dang yyyymmdd neu nhap sai format filter se bi bo qua
--  `_ngay_ket_thuc` varchar(255), _ngay_ket_thuc theo dinh dang yyyymmdd neu nhap sai format filter se bi bo qua
--  `_current_page` int(10), _current_page phai lon hon 0
--  `_nb_items` int(10), _nb_items can phai la so duong
--  `_order_column_name` varchar(255), gia tri nay khong the thieu de sort du lieu
--
-- Returns:    
--      Ket qua theo cac filter o tren
-- History:
--   01/12/2018 - Phuong Hoang: Create first version of store proc.
--   01/19/2018 - Phuong Hoang: update to new db, add label field to return value. This field has format 
-- Example
-- call TimChienDich(
--    'sa', -- `_ten_chien_dich` varchar(255) CHARSET utf8,
--     null,-- `_ngay_bat_dau` varchar(255) ,
--     null,-- `_ngay_ket_thuc` varchar(255),
--     1,-- `_current_page` int(10),
--     25,-- _nb_items` int(10),
--     'khu_vuc' -- `_order_column_name` varchar(255)
-- );
-- call TimChienDich(
--    null, -- `_ten_chien_dich` varchar(255) CHARSET utf8,
--     '20180118',-- `_ngay_bat_dau` varchar(255) ,
--     '20180204',-- `_ngay_ket_thuc` varchar(255),
--     1,-- `_current_page` int(10),
--     25,-- _nb_items` int(10),
--     'khu_vuc' -- `_order_column_name` varchar(255)
-- );
-- call TimChienDich(
--    'sa', -- `_ten_chien_dich` varchar(255) CHARSET utf8,
--     '20180118',-- `_ngay_bat_dau` varchar(255) ,
--     '20180204',-- `_ngay_ket_thuc` varchar(255),
--     1,-- `_current_page` int(10),
--     25,-- _nb_items` int(10),
--     'khu_vuc' -- `_order_column_name` varchar(255)
-- );
-- =============================================

USE `asdgo_cms`;
DROP procedure IF EXISTS `TimChienDich`;

DELIMITER $$
USE `asdgo_cms`$$


-- --- sql  ------
CREATE DEFINER=`root`@`%` PROCEDURE `TimChienDich`(
    `_ten_chien_dich` varchar(255) CHARSET utf8,
    `_ngay_bat_dau` varchar(255) ,
    `_ngay_ket_thuc` varchar(255),
    `_current_page` int(10),
    `_nb_items` int(10),
    `_order_column_name` varchar(255)
)
proc_label:BEGIN
     
    IF((_current_page is null) OR (_nb_items is null) OR (_current_page<=0) OR(_nb_items<0)) THEN 
        select "_current_page and nb_items have to positive number";
        LEAVE proc_label;
    END IF;

    SET @schema='asdgo_cms';
    SET @columnName=' chien_dich.id, ten_chien_dich, thoi_gian_bat_dau, thoi_gian_ket_thuc,khu_vuc,(tong4cho+tong7cho) as tong_xe, trang_thai_chien_dich,url_quang_cao ';
    SET @label=' ,concat(CASE 
            WHEN (thoi_gian_bat_dau<=Date(now())and thoi_gian_ket_thuc>=Date(Now())) THEN "running"
            WHEN thoi_gian_bat_dau>Date(now()) THEN "waiting"
            WHEN thoi_gian_ket_thuc<Date(now()) THEN "Complete"
            ELSE NULL
            END,";",IF(chien_dich.status_record = 1, "Active", "Unactive")) as label ';
    SET @tableName="chien_dich";
    SET @tableJoinName=' FROM chien_dich inner join quang_cao on chien_dich.id=quang_cao.chien_dich_id ';
    SET @where_string='';
    set @ngay_bat_dau = str_to_date(_ngay_bat_dau, '%Y%m%d');
    set @ngay_ket_thuc = str_to_date(_ngay_ket_thuc, '%Y%m%d');
    set @order_column_name=_order_column_name;
    SET @where_string="";
    SET @limit_string="";

    /* check order_column_name*/
    IF ((
            SELECT count(*) FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = @schema
            AND TABLE_NAME = @tableName
            AND COLUMN_NAME=@order_column_name
        )=0) 
    THEN 
        select "Need column which use to sort data ";
        LEAVE proc_label;
    ELSE
        SET @order_string=concat(" order by ",@order_column_name);
        
    END IF;

    -- filter by _ten_chien_dich;
    IF(_ten_chien_dich is not null) THEN
        SET @where_string=concat('ten_chien_dich like ', "'%",_ten_chien_dich,"%'") ;
    END IF;
    -- select @where_string;

    -- filter by @ngay_bat_dau
    IF(@ngay_bat_dau is not null) THEN
        SET @where_string=concat(@where_string,if(@where_string="",""," and")," thoi_gian_bat_dau >= '", @ngay_bat_dau,"'");
    END IF;
    -- -- filter by @ngay_ket_thuc
    IF(@ngay_ket_thuc is not null) THEN
        SET @where_string=concat(@where_string,if(@where_string="",""," and")," thoi_gian_ket_thuc <= '", @ngay_ket_thuc,"'");
    END IF;
    -- select @where_string;
    
    -- select data by current page and nb of items

    SET @limit_string=concat(" limit ",(_current_page-1)*_nb_items," , ",_nb_items);

    
    -- add where to @where_string
    IF(@where_string <>"") THEN
        SET @where_string  = concat(" where ",@where_string );
    END IF;
    
    SET @sql_string=CONCAT('select ',@columnName,@label,@tableJoinName,@where_string,@order_string,@limit_string,";");
      
    -- select @sql_string;

    PREPARE QUERY FROM @sql_string;
    -- select @sql_string;

    execute QUERY;
    DEALLOCATE PREPARE QUERY;


    -- select @sql_string;    
-- --- sql  ------
END$$

DELIMITER ;




