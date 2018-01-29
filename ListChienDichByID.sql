USE `asdgo_cms`;
DROP procedure IF EXISTS `ListChienDichByID`;

DELIMITER $$
USE `asdgo_cms`$$
CREATE DEFINER=`root`@`%` PROCEDURE `ListChienDichByID`(
	_chien_dich_id bigint(20)
)
BEGIN
-- =============================================
-- Author:      Phuong Hoang
-- Store: ListChienDichByID()
-- Description: List detail chien_dich by ID:
--		- TenCD,TGBD,TGKT,TGTANGTHEM,TONG SO XE, SOxe 4cho,soxe 7cho
-- 		- Tong so hien thi(views), tong so km
-- Parameters:
-- Returns:    
--    - Result with format id, ten_loai_quang_cao
-- History:
--   01/28/2018 - Phuong Hoang: Create first version of store proc. 
--   01/29/2018 - Phuong Hoang: Edit to match with chinh sua chien dich (1hour) -- chua log work
-- Example call ListChienDichByID(56);
--	Return format:
-- 		# id, bonus, create_date, ghi_chu, khu_vuc, ngay_chuan_bi, ngay_ket_thuc_tam_thoi, so_luong_xe, status_record, ten_chien_dich, thoi_gian_bat_dau, thoi_gian_ket_thuc, tong4cho, tong7cho, trang_thai_chien_dich, khach_hang_id, tien_chien_dich, sum_views, sum_km
-- 		'56', '2', '2018-01-28 05:16:27', NULL, 'HCM', '2018-05-15 00:00:00', '2018-06-05 00:00:00', '0', '1', 'new camp, no xe 52', '2018-05-20 00:00:00', '2018-06-07 00:00:00', '0', '0', 'Normal', '1', NULL, '1000', '1000'

-- =============================================
	set @ten_loai_quang_cao=null;
	/*Get loai quang cao*/
    select lqc.id, lqc.ten_loai_quang_cao 
    into @loai_quang_cao_id,@ten_loai_quang_cao
    from loai_quang_cao lqc
    where lqc.id=(
    select qc.id_loaiqc
    from quang_cao qc
    where qc.chien_dich_id=_chien_dich_id);
	select 
			cd.id, 
		  	cd.bonus, 
		  	cd.create_date, 
		  	cd.ghi_chu, 
		  	cd.khu_vuc, 
			cd.ngay_chuan_bi, 
			cd.ngay_ket_thuc_tam_thoi, 
			cd.so_luong_xe, 
			cd.status_record, 
			cd.ten_chien_dich, 
			cd.thoi_gian_bat_dau, 
			cd.thoi_gian_ket_thuc, 
			cd.tong4cho, 
			cd.tong7cho, 
			cd.trang_thai_chien_dich, 
			cd.khach_hang_id, 
			cd.tien_chien_dich,
			1000 as sum_views,
			1000 as sum_km,
            kh.ten_viet_tat as kh_ten_viet_tat,
            @loai_quang_cao_id as loai_quang_cao_id,
            @ten_loai_quang_cao as ten_loai_quang_cao
    from chien_dich cd
    inner join khach_hang kh
		on cd.khach_hang_id=kh.id
    where cd.id =_chien_dich_id;
END$$

DELIMITER ;

