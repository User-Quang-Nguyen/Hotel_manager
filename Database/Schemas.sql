-- Function tao id nhan vien tu tang --
CREATE OR REPLACE FUNCTION insert_nhan_vien() RETURNS integer AS 
$$
	DECLARE maNV integer;
BEGIN
	IF ((SELECT COUNT(nv_id) FROM nhanvien) = 0)
    THEN
        maNV=1;
	ELSE
        maNV = cast((SELECT MAX(nv_id) FROM nhanvien) as integer)+1 ;
    END IF;
        RETURN maNV;
END;
$$ LANGUAGE plpgsql ;

-- Function tao id khach hang tu tang --
CREATE OR REPLACE FUNCTION insert_khach_hang() RETURNS integer AS 
$$
	DECLARE maKH integer;

BEGIN
	IF ((SELECT COUNT(kh_id) FROM khachhang) = 0)
    THEN
        maKH=1;
	ELSE
        maKH = cast((SELECT MAX(kh_id) FROM khachhang) as integer)+1;
    END IF;
        RETURN maKH;
END;

$$ LANGUAGE plpgsql ;

-- Function tao id hoa don tu tang --
CREATE OR REPLACE FUNCTION insert_hoa_don() RETURNS integer AS 
$$
	DECLARE maHD integer;
BEGIN
IF ((SELECT COUNT(mahoadon) FROM hoadon) = 0)
    THEN
        maHD = 1;
    ELSE
        maHD = cast((SELECT MAX(mahoadon) FROM hoadon) as integer)+1;
    END IF;
        RETURN maHD;
END;
$$ LANGUAGE plpgsql ;



-- Tao bang khach hang --
CREATE TABLE khachhang
(
    kh_id integer DEFAULT insert_khach_hang(),
    hovaten character varying(30) NOT NULL,
	gioitinh character varying(5) NOT NULL,
	ngaysinh date NOT NULL, 
    sdt character varying(15) NOT NULL,
	uname character varying(30) UNIQUE,
    pass character varying(30), 
    CONSTRAINT kh_pk PRIMARY KEY (kh_id),
    CONSTRAINT kh_chk_gioitinh CHECK (gioitinh= 'nam' OR gioitinh = 'nữ')
);

-- Tao bang nhan vien -- 
CREATE TABLE nhanvien
(
	nv_id integer DEFAULT insert_nhan_vien(),
	hovaten character varying(30) COLLATE pg_catalog."default" NOT NULL,
    gioitinh character varying(5) COLLATE pg_catalog."default" NOT NULL,
    ngaysinh date NOT NULL, 
    sdt character varying(15) COLLATE pg_catalog."default",
	chucvu character varying(100) COLLATE pg_catalog."default" NOT NULL,
	uname character varying(30) UNIQUE,
    pass character varying(30), 
    CONSTRAINT nv_pk PRIMARY KEY (nv_id),
    CONSTRAINT nv_chk_gioitinh CHECK (gioitinh= 'nam' OR gioitinh = 'nữ'),
	CONSTRAINT nv_chk_age CHECK (( DATE_PART('year', CURRENT_DATE) - DATE_PART('year', ngaysinh)) >18)
);

-- Tao bang thue phong -- 
CREATE TABLE thuephong
(
    kh_id integer  NOT NULL,
    phong_id integer NOT NULL,
    mahoadon integer DEFAULT insert_hoa_don(),
	TG_datphong TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TG_layphong TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    TG_traphong TIMESTAMP NOT NULL,
    CONSTRAINT tp_ck_tg CHECK (tg_traphong>TG_layphong)
);

-- Tao bang hoa don -- 
CREATE TABLE hoadon
(
	mahoadon integer DEFAULT insert_hoa_don(),
	kh_id integer NOT NULL,
	chiphi double precision DEFAULT 0,
	trangthai character varying(100) DEFAULT 'Chưa thanh toán', 
	mahinhthuc integer ,
	TG_giaodich TIMESTAMP,
    nv_id integer ,
	CONSTRAINT hd_pk PRIMARY KEY (mahoadon),
	CONSTRAINT hd_chk_tt CHECK (trangthai='Chưa thanh toán' OR trangthai='Đã thanh toán' OR trangthai='Đã hủy')
);

-- Tao bang hinh thuc
CREATE TABLE hinhthuc
(
	mahinhthuc SERIAL PRIMARY KEY,
	loaihinhthuc character varying(100) NOT NULL UNIQUE
);

-- Tao bang phong -- 
 CREATE TABLE phong
(
	phong_id integer NOT NULL PRIMARY KEY,
	maloaiphong integer NOT NULL,
    trangthai character varying(100) DEFAULT 'Trống'
);

-- Tao bang loai phong --
CREATE TABLE loaiphong
(
	maloaiphong SERIAL PRIMARY KEY,
	ten character varying(100) NOT NULL,
	giaphong double precision NOT NULL,
	dientich double precision,
	tienich character varying(100) NOT NULL
);

CREATE TABLE quanliphong
(
	phong_id integer NOT NULL,
	nv_id integer NOT NULL
);
-- Tao khoa ngoai--
ALTER TABLE thuephong 
ADD CONSTRAINT tp_fk_kh FOREIGN KEY (kh_id) REFERENCES khachhang(kh_id),
ADD CONSTRAINT tp_fk_p FOREIGN KEY (phong_id) REFERENCES phong(phong_id),
ADD CONSTRAINT tp_fk_hd FOREIGN KEY (mahoadon) REFERENCES hoadon(mahoadon);

ALTER TABLE hoadon
ADD CONSTRAINT hd_fk_kh FOREIGN KEY (kh_id) REFERENCES khachhang(kh_id),
ADD CONSTRAINT hd_fk_ht FOREIGN KEY (mahinhthuc) REFERENCES hinhthuc(mahinhthuc),
ADD CONSTRAINT hd_fk_nv FOREIGN KEY (nv_id) REFERENCES nhanvien(nv_id);

ALTER TABLE phong
ADD CONSTRAINT phong_fk_lp FOREIGN KEY (maloaiphong) REFERENCES loaiphong(maloaiphong);

ALTER TABLE quanliphong
ADD CONSTRAINT qlp_fk_p FOREIGN KEY (phong_id) REFERENCES phong(phong_id),
ADD CONSTRAINT qlp_fk_nv FOREIGN KEY (nv_id) REFERENCES nhanvien(nv_id);

-- Function xoa khoi bang thue phong khi khach huy hoa don--
CREATE OR REPLACE FUNCTION khach_huy_phong() RETURNS trigger AS 
$$
BEGIN
    DELETE FROM thuephong 
	WHERE thuephong.mahoadon = OLD.mahoadon;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER huyphong
    AFTER UPDATE ON hoadon
    FOR EACH ROW
    WHEN (NEW.trangthai='Đã hủy')
    EXECUTE FUNCTION khach_huy_phong();

-- Function tu sinh hoa don khi khach thue phong -- 
CREATE OR REPLACE FUNCTION khach_thue_phong() RETURNS trigger AS 
$$
BEGIN
    INSERT INTO hoadon(kh_id) VALUES (NEW.kh_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER thue_phong
    BEFORE INSERT ON thuephong
    FOR EACH ROW
    EXECUTE FUNCTION khach_thue_phong();

-- Funtion: kiem tra ngay va phong khach muon dat co hop le khong-- 
CREATE OR REPLACE FUNCTION kiem_tra_ngay(layphong TIMESTAMP,traphong TIMESTAMP,maphong INT) RETURNS BOOLEAN AS 
$$
BEGIN
    IF((SELECT COUNT(mahoadon) FROM thuephong 
	WHERE phong_id=maphong AND
	((TG_layphong<=layphong AND TG_traphong>=layphong) 
	OR (TG_layphong<=traphong AND TG_traphong>=traphong) 
    OR (layphong<TG_layphong AND traphong> TG_traphong ))>0))
    	THEN RETURN FALSE;
	ELSE
		RETURN TRUE;
	END IF;
END;
$$ LANGUAGE plpgsql ;
ALTER TABLE thuephong 
ADD CONSTRAINT check_tg CHECK (kiem_tra_ngay(TG_layphong,TG_traphong,phong_id));

-- Begin: Function cap nhat tt phong
CREATE FUNCTION update_tt_phong() RETURNS trigger AS
$$
BEGIN
    UPDATE phong SET trangthai='Bận' WHERE phong_id IN 
    (SELECT phong_id FROM thuephong WHERE tg_layphong<=CURRENT_TIMESTAMP AND tg_traphong>=CURRENT_TIMESTAMP);
    UPDATE phong SET trangthai='Trống' WHERE phong_id NOT IN 
    (SELECT phong_id FROM thuephong WHERE tg_layphong<=CURRENT_TIMESTAMP AND tg_traphong>=CURRENT_TIMESTAMP);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql ;

CREATE TRIGGER update_phong
    AFTER INSERT OR UPDATE ON hoadon
    FOR EACH ROW
    EXECUTE FUNCTION update_tt_phong();
--End--


-- View thong ke so luong nhan vien va chuc vu--
CREATE VIEW thongke_nv AS
 SELECT nhanvien.chucvu,
    count(nhanvien.chucvu) AS soluong
   FROM nhanvien
  GROUP BY nhanvien.chucvu;
 
-- View xem thong tin cac phong --
CREATE OR REPLACE VIEW bang_gia_phong AS
	SELECT * FROM phong NATURAL JOIN loaiphong;

-- VIEW xem tg thuephong

  

--View xem chi tiet hoa don--
CREATE OR REPLACE VIEW bill AS
SELECT hoadon.mahoadon,
    khachhang.kh_id,
    khachhang.hovaten,
    khachhang.sdt,
    thuephong.phong_id,
    bang_gia_phong.giaphong,
    thuephong.TG_datphong,
    thuephong.TG_layphong,
    thuephong.TG_traphong,
    hoadon.chiphi,
    bang_gia_phong.giaphong * extract(day from (tg_traphong-tg_layphong))+ hoadon.chiphi AS "tongtien",
    hoadon.trangthai,
    hoadon.tg_giaodich
   FROM thuephong
     NATURAL JOIN khachhang
     NATURAL JOIN hoadon
	JOIN bang_gia_phong ON thuephong.phong_id= bang_gia_phong.phong_id
     ORDER BY hoadon.mahoadon ASC;

-- View xem thong tin khach hang hien tai dang thue -- 
CREATE OR REPLACE VIEW xem_phong AS
SELECT phong_id,kh_id,hovaten,gioitinh,ngaysinh,sdt FROM thuephong NATURAL JOIN khachhang 
WHERE tg_layphong<=CURRENT_TIMESTAMP AND tg_traphong>=CURRENT_TIMESTAMP ORDER BY phong_id ASC;
 
-- View thong ke doanh thu thang --
CREATE VIEW thong_ke_dt AS
SELECT sum(bill.tongtien) AS doanhthu,
    EXTRACT(month FROM bill.tg_giaodich) AS thang
   FROM bill
  GROUP BY (EXTRACT(month FROM bill.tg_giaodich));








