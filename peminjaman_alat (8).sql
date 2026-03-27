-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 25, 2026 at 05:01 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `peminjaman_alat`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_kembalikan_alat` (IN `p_id_peminjaman` INT, IN `p_tgl_kembali` DATE, IN `p_kondisi` VARCHAR(20), IN `p_denda_kerusakan` INT, IN `p_catatan` TEXT)   BEGIN
    DECLARE v_denda_telat INT;
    
    -- Procedure ini memanggil Function func_hitung_denda yang kita buat di atas
    SET v_denda_telat = func_hitung_denda(p_id_peminjaman, p_tgl_kembali);
    
    -- Lalu masukkan datanya ke tabel pengembalian
    INSERT INTO pengembalian (
        id_peminjaman, 
        tanggal_dikembalikan, 
        kondisi_kembali, 
        denda, 
        denda_kerusakan, 
        catatan_petugas
    ) VALUES (
        p_id_peminjaman, 
        p_tgl_kembali, 
        p_kondisi, 
        v_denda_telat, 
        p_denda_kerusakan, 
        p_catatan
    );
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `func_hitung_denda` (`p_id` INT, `p_tgl` DATE) RETURNS INT(11) DETERMINISTIC BEGIN
    DECLARE telat INT;
    DECLARE total_barang INT;
    DECLARE nominal_denda INT;
    
    -- Hitung selisih hari
    SELECT DATEDIFF(p_tgl, tanggal_kembali) INTO telat FROM peminjaman WHERE id_peminjaman = p_id;
    
    -- Hitung TOTAL BARANG yang dipinjam pada ID tersebut
    SELECT IFNULL(SUM(jumlah), 0) INTO total_barang FROM detail_peminjaman WHERE id_peminjaman = p_id;
    
    -- Logika denda: Hari telat * Rp 5.000 * Jumlah Barang
    IF telat > 0 THEN 
        SET nominal_denda = telat * 5000 * total_barang; 
    ELSE 
        SET nominal_denda = 0; 
    END IF;
    
    RETURN nominal_denda;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alat`
--

CREATE TABLE `alat` (
  `id_alat` int(11) NOT NULL,
  `id_kategori` int(11) DEFAULT NULL,
  `nama_alat` varchar(100) DEFAULT NULL,
  `gambar` varchar(255) DEFAULT 'default.png',
  `deskripsi` text DEFAULT NULL,
  `stok` int(11) DEFAULT NULL,
  `kondisi` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `alat`
--

INSERT INTO `alat` (`id_alat`, `id_kategori`, `nama_alat`, `gambar`, `deskripsi`, `stok`, `kondisi`) VALUES
(1, 1, 'Pensil', '1770620658_52db34ce2f4fa89d1f9e.png', 'Untuk Menulis ', 4, 'Baik'),
(3, 1, 'Pulpen', '1772333439_99d05b75b8aa752eca87.jpeg', 'Untuk Menulis', 5, 'Baik'),
(4, 1, 'penghapus', '1773035349_237229303e8d2f51e02c.jpeg', 'kjhkjshksahkja', 8, 'Baik');

--
-- Triggers `alat`
--
DELIMITER $$
CREATE TRIGGER `trg_alat_delete` BEFORE DELETE ON `alat` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menghapus data alat: ', OLD.nama_alat));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_alat_insert` AFTER INSERT ON `alat` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menambahkan data alat: ', NEW.nama_alat));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_alat_update` AFTER UPDATE ON `alat` FOR EACH ROW BEGIN
    IF OLD.stok != NEW.stok THEN
        INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Update stok alat ', NEW.nama_alat, ' dari ', OLD.stok, ' menjadi ', NEW.stok));
    ELSE
        INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Update data alat: ', NEW.nama_alat));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `detail_peminjaman`
--

CREATE TABLE `detail_peminjaman` (
  `id_detail` int(11) NOT NULL,
  `id_peminjaman` int(11) DEFAULT NULL,
  `id_alat` int(11) DEFAULT NULL,
  `jumlah` int(11) DEFAULT 1,
  `jml_baik` int(11) DEFAULT 0,
  `jml_rusak` int(11) DEFAULT 0,
  `jml_hilang` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `detail_peminjaman`
--

INSERT INTO `detail_peminjaman` (`id_detail`, `id_peminjaman`, `id_alat`, `jumlah`, `jml_baik`, `jml_rusak`, `jml_hilang`) VALUES
(1, 6, 1, 1, 1, 0, 0),
(2, 7, 1, 1, 1, 0, 0),
(3, 8, 1, 1, 1, 0, 0),
(5, 10, 1, 1, 0, 1, 0),
(6, 11, 1, 1, 0, 1, 0),
(7, 12, 1, 1, 1, 0, 0),
(8, 13, 1, 1, 0, 1, 0),
(9, 14, 1, 1, 1, 0, 0),
(10, 14, 3, 1, 1, 0, 0),
(11, 15, 1, 1, 1, 0, 0),
(12, 15, 3, 1, 1, 0, 0),
(13, 16, 1, 1, 1, 0, 0),
(14, 16, 3, 1, 1, 0, 0),
(15, 17, 1, 1, 1, 0, 0),
(16, 18, 1, 6, 1, 2, 3),
(17, 19, 1, 1, 0, 0, 0),
(18, 20, 1, 1, 0, 1, 0),
(19, 21, 3, 1, 1, 0, 0),
(20, 22, 1, 1, 1, 0, 0),
(21, 23, 1, 1, 0, 0, 0),
(22, 24, 3, 1, 0, 1, 0),
(23, 25, 3, 1, 0, 1, 0),
(24, 26, 3, 1, 0, 1, 0),
(25, 27, 3, 1, 1, 0, 0),
(26, 28, 1, 1, 0, 1, 0),
(27, 28, 3, 1, 0, 1, 0),
(28, 29, 1, 2, 1, 1, 0),
(29, 30, 4, 1, 0, 1, 0),
(30, 31, 1, 1, 1, 0, 0),
(31, 32, 1, 2, 0, 0, 0),
(32, 33, 1, 1, 1, 0, 0),
(33, 34, 1, 1, 0, 0, 0),
(34, 35, 3, 1, 0, 1, 0),
(35, 36, 4, 1, 0, 1, 0);

--
-- Triggers `detail_peminjaman`
--
DELIMITER $$
CREATE TRIGGER `trg_detail_delete` BEFORE DELETE ON `detail_peminjaman` FOR EACH ROW BEGIN
    DECLARE v_nama_alat VARCHAR(100);
    SELECT nama_alat INTO v_nama_alat FROM alat WHERE id_alat = OLD.id_alat;
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menghapus detail alat ', v_nama_alat, ' dari peminjaman ID ', OLD.id_peminjaman));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_detail_insert` AFTER INSERT ON `detail_peminjaman` FOR EACH ROW BEGIN
    DECLARE v_nama_alat VARCHAR(100);
    SELECT nama_alat INTO v_nama_alat FROM alat WHERE id_alat = NEW.id_alat;
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menambahkan detail alat ', v_nama_alat, ' pada peminjaman ID ', NEW.id_peminjaman));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id_kategori` int(11) NOT NULL,
  `nama_kategori` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id_kategori`, `nama_kategori`) VALUES
(1, 'Pelengkapan Alat Tulis');

--
-- Triggers `kategori`
--
DELIMITER $$
CREATE TRIGGER `trg_kategori_delete` BEFORE DELETE ON `kategori` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menghapus kategori: ', OLD.nama_kategori));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_kategori_insert` AFTER INSERT ON `kategori` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menambahkan kategori baru: ', NEW.nama_kategori));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_kategori_update` AFTER UPDATE ON `kategori` FOR EACH ROW BEGIN
    IF OLD.nama_kategori != NEW.nama_kategori THEN
        INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Update kategori dari ', OLD.nama_kategori, ' menjadi ', NEW.nama_kategori));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `log_aktivitas`
--

CREATE TABLE `log_aktivitas` (
  `id_log` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `aktivitas` text DEFAULT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_aktivitas`
--

INSERT INTO `log_aktivitas` (`id_log`, `id_user`, `aktivitas`, `waktu`) VALUES
(1, 1, 'Menambahkan data user dengan username Dill', '2026-02-09 03:28:24'),
(2, 1, 'Melakukan Login ke sistem', '2026-02-09 03:37:18'),
(3, 2, 'Menambahkan data user dengan username Dik', '2026-02-09 03:53:01'),
(4, 2, 'Update data user dengan username Dik', '2026-02-09 03:53:26'),
(5, 1, 'Update data user dengan username Dill', '2026-02-09 05:59:52'),
(6, 3, 'Menambahkan data user dengan username Zan', '2026-02-09 06:18:05'),
(7, 3, 'Update data user dengan username Zan', '2026-02-09 06:18:21'),
(8, 1, 'Update data user dengan username Dill', '2026-02-09 06:18:48'),
(9, 1, 'Melakukan Login ke sistem', '2026-02-09 06:22:42'),
(10, 1, 'Melakukan Login ke sistem', '2026-02-09 06:51:59'),
(11, 1, 'Update data user dengan username Dill', '2026-02-09 07:01:40'),
(12, 3, 'Melakukan Login ke sistem', '2026-02-09 07:01:59'),
(13, 1, 'Melakukan Login ke sistem', '2026-02-09 07:02:39'),
(14, NULL, 'Menambahkan kategori baru: Pelengkapan Alat Tulis', '2026-02-09 07:03:44'),
(15, NULL, 'Menambahkan data alat: Pensil', '2026-02-09 07:04:18'),
(16, 3, 'Melakukan Login ke sistem', '2026-02-09 07:04:41'),
(17, 1, 'Melakukan Login ke sistem', '2026-02-09 07:05:36'),
(18, 3, 'Update data user dengan username Zan', '2026-02-09 07:07:14'),
(19, 1, 'Update data user dengan username Dill', '2026-02-09 07:15:24'),
(20, 1, 'Melakukan Login ke sistem', '2026-02-09 07:15:40'),
(21, 3, 'Melakukan Login ke sistem', '2026-02-09 07:17:01'),
(22, 3, 'Menambahkan peminjaman ID: 1', '2026-02-09 07:18:10'),
(23, 2, 'Melakukan Login ke sistem', '2026-02-09 07:18:31'),
(24, 1, 'Melakukan Login ke sistem', '2026-02-09 07:21:51'),
(25, 1, 'Melakukan Login ke sistem', '2026-02-09 07:25:27'),
(26, 1, 'Melakukan Login ke sistem', '2026-02-09 07:26:42'),
(27, 2, 'Melakukan Login ke sistem', '2026-02-09 07:28:50'),
(28, 1, 'Melakukan Login ke sistem', '2026-02-09 07:32:31'),
(29, 2, 'Melakukan Login ke sistem', '2026-02-09 07:33:44'),
(30, 3, 'Update status peminjaman ID 1 menjadi dipinjam', '2026-02-09 07:34:03'),
(31, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-09 07:34:03'),
(32, 2, 'Menyetujui peminjaman ID: 1', '2026-02-09 07:34:03'),
(33, 3, 'Melakukan Login ke sistem', '2026-02-09 07:34:25'),
(34, 2, 'Melakukan Login ke sistem', '2026-02-09 07:35:55'),
(35, 1, 'Melakukan Login ke sistem', '2026-02-10 00:28:23'),
(36, 4, 'Menambahkan data user dengan username Tan', '2026-02-10 00:30:37'),
(37, 1, 'Melakukan Login ke sistem', '2026-02-10 00:41:42'),
(38, NULL, 'Menambahkan data user dengan username fan', '2026-02-10 00:48:32'),
(39, 4, 'Melakukan Login ke sistem', '2026-02-10 08:10:08'),
(40, 4, 'Menambahkan peminjaman ID: 2', '2026-02-10 08:10:35'),
(41, 2, 'Melakukan Login ke sistem', '2026-02-10 08:14:25'),
(42, 4, 'Update status peminjaman ID 2 menjadi dipinjam', '2026-02-10 08:14:34'),
(43, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-10 08:14:34'),
(44, 2, 'Menyetujui peminjaman ID #2 (Status: Dipinjam)', '2026-02-10 08:14:34'),
(45, 4, 'Melakukan Login ke sistem', '2026-02-10 08:15:02'),
(46, 4, 'Update status peminjaman ID 2 menjadi menunggu_kembali', '2026-02-10 08:31:25'),
(47, 4, 'Mengajukan pengembalian untuk ID Pinjam #2', '2026-02-10 08:31:25'),
(48, 2, 'Melakukan Login ke sistem', '2026-02-10 08:31:52'),
(49, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-10 08:32:03'),
(50, 3, 'Update status peminjaman ID 1 menjadi selesai', '2026-02-10 08:32:03'),
(51, 3, 'Menambahkan data pengembalian untuk peminjaman ID: 1', '2026-02-10 08:32:03'),
(52, 2, 'Memproses pengembalian alat (ID Peminjaman: 1)', '2026-02-10 08:32:03'),
(53, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-10 08:42:27'),
(54, 4, 'Update status peminjaman ID 2 menjadi selesai', '2026-02-10 08:42:27'),
(55, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 2', '2026-02-10 08:42:27'),
(56, 2, 'Memproses pengembalian peminjaman ID #2 (Selesai)', '2026-02-10 01:42:27'),
(57, 4, 'Melakukan Login ke sistem', '2026-02-10 08:42:57'),
(58, 4, 'Menambahkan peminjaman ID: 3', '2026-02-10 08:43:08'),
(59, 1, 'Melakukan Login ke sistem', '2026-02-10 08:43:43'),
(60, 4, 'Melakukan Login ke sistem', '2026-02-10 08:44:22'),
(61, 2, 'Melakukan Login ke sistem', '2026-02-10 08:44:41'),
(62, 4, 'Update status peminjaman ID 3 menjadi dipinjam', '2026-02-10 08:44:50'),
(63, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-10 08:44:50'),
(64, 2, 'Menyetujui peminjaman ID #3 (Status: Dipinjam)', '2026-02-10 08:44:50'),
(65, 4, 'Melakukan Login ke sistem', '2026-02-10 08:46:09'),
(66, 4, 'Update status peminjaman ID 3 menjadi menunggu_kembali', '2026-02-10 08:46:18'),
(67, 4, 'Mengajukan pengembalian untuk ID Pinjam #3', '2026-02-10 08:46:18'),
(68, 2, 'Melakukan Login ke sistem', '2026-02-10 08:46:30'),
(69, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-10 08:46:56'),
(70, 4, 'Update status peminjaman ID 3 menjadi selesai', '2026-02-10 08:46:56'),
(71, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 3', '2026-02-10 08:46:56'),
(72, 2, 'Memproses pengembalian peminjaman ID #3 (Selesai)', '2026-02-10 01:46:56'),
(73, 4, 'Melakukan Login ke sistem', '2026-02-10 08:51:33'),
(74, 4, 'Menambahkan peminjaman ID: 4', '2026-02-10 08:51:44'),
(75, 2, 'Melakukan Login ke sistem', '2026-02-10 08:51:59'),
(76, 4, 'Update status peminjaman ID 4 menjadi dipinjam', '2026-02-10 08:52:13'),
(77, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-10 08:52:13'),
(78, 2, 'Menyetujui peminjaman ID #4 (Status: Dipinjam)', '2026-02-10 08:52:13'),
(79, 4, 'Melakukan Login ke sistem', '2026-02-10 08:52:54'),
(80, 4, 'Menambahkan peminjaman ID: 5', '2026-02-10 08:53:05'),
(81, 2, 'Melakukan Login ke sistem', '2026-02-10 08:54:29'),
(82, 4, 'Update status peminjaman ID 5 menjadi dipinjam', '2026-02-10 08:54:38'),
(83, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-10 08:54:38'),
(84, 2, 'Menyetujui peminjaman ID #5 (Status: Dipinjam)', '2026-02-10 08:54:38'),
(85, 4, 'Melakukan Login ke sistem', '2026-02-10 08:55:15'),
(86, 4, 'Update status peminjaman ID 4 menjadi menunggu_kembali', '2026-02-10 08:55:25'),
(87, 4, 'Mengajukan pengembalian untuk ID Pinjam #4', '2026-02-10 08:55:25'),
(88, 2, 'Melakukan Login ke sistem', '2026-02-10 08:55:42'),
(89, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-10 08:55:55'),
(90, 4, 'Update status peminjaman ID 4 menjadi selesai', '2026-02-10 08:55:55'),
(91, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 4', '2026-02-10 08:55:55'),
(92, 2, 'Memproses pengembalian peminjaman ID #4 (Selesai)', '2026-02-10 01:55:55'),
(93, 4, 'Melakukan Login ke sistem', '2026-02-10 09:09:30'),
(94, 4, 'Menambahkan peminjaman ID: 6', '2026-02-10 09:09:55'),
(95, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 6', '2026-02-10 09:09:55'),
(96, 2, 'Melakukan Login ke sistem', '2026-02-10 09:10:22'),
(97, 4, 'Update status peminjaman ID 6 menjadi dipinjam', '2026-02-10 09:10:32'),
(98, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-10 09:10:32'),
(99, NULL, 'Update stok alat Pensil dari 8 menjadi 7', '2026-02-10 09:10:32'),
(100, 2, 'Menyetujui peminjaman ID #6 (Status: Dipinjam)', '2026-02-10 09:10:32'),
(101, 4, 'Melakukan Login ke sistem', '2026-02-10 09:10:45'),
(102, 4, 'Update status peminjaman ID 5 menjadi menunggu_kembali', '2026-02-10 09:10:58'),
(103, 4, 'Mengajukan pengembalian untuk ID Pinjam #5', '2026-02-10 09:10:58'),
(104, 2, 'Melakukan Login ke sistem', '2026-02-10 09:11:10'),
(105, NULL, 'Update stok alat Pensil dari 7 menjadi 8', '2026-02-10 09:11:20'),
(106, 4, 'Update status peminjaman ID 5 menjadi selesai', '2026-02-10 09:11:20'),
(107, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 5', '2026-02-10 09:11:20'),
(108, 2, 'Memproses pengembalian peminjaman ID #5 (Selesai)', '2026-02-10 02:11:20'),
(109, 1, 'Melakukan Login ke sistem', '2026-02-10 09:11:38'),
(110, 4, 'Melakukan Login ke sistem', '2026-02-10 09:12:09'),
(111, 4, 'Update status peminjaman ID 6 menjadi menunggu_kembali', '2026-02-10 09:12:29'),
(112, 4, 'Mengajukan pengembalian untuk ID Pinjam #6', '2026-02-10 09:12:29'),
(113, 1, 'Melakukan Login ke sistem', '2026-02-10 09:12:41'),
(114, 4, 'Melakukan Login ke sistem', '2026-02-10 09:13:41'),
(115, 1, 'Melakukan Login ke sistem', '2026-02-12 07:47:39'),
(116, 1, 'Melakukan Login ke sistem', '2026-02-18 05:08:16'),
(117, 2, 'Melakukan Login ke sistem', '2026-02-18 05:34:46'),
(118, 4, 'Melakukan Login ke sistem', '2026-02-18 05:35:24'),
(119, 2, 'Melakukan Login ke sistem', '2026-02-18 05:36:33'),
(120, 4, 'Melakukan Login ke sistem', '2026-02-18 05:45:17'),
(121, 2, 'Melakukan Login ke sistem', '2026-02-18 05:56:34'),
(122, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-18 06:01:34'),
(123, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-18 06:01:34'),
(124, 4, 'Update status peminjaman ID 6 menjadi selesai', '2026-02-18 06:01:34'),
(125, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 6', '2026-02-18 06:01:34'),
(126, 2, 'Memproses pengembalian peminjaman ID #6 (Selesai)', '2026-02-17 23:01:34'),
(127, 4, 'Melakukan Login ke sistem', '2026-02-18 06:01:52'),
(128, 1, 'Melakukan Login ke sistem', '2026-02-24 06:13:49'),
(129, 6, 'Menambahkan data user dengan username Jar', '2026-02-24 06:16:16'),
(130, NULL, 'Menghapus data user dengan username fan', '2026-02-24 06:16:25'),
(131, 4, 'Update data user dengan username Tan', '2026-02-24 06:16:40'),
(132, NULL, 'Menambahkan data alat: Pulpen', '2026-02-24 06:17:28'),
(133, NULL, 'Update stok alat Pulpen dari 50 menjadi 20', '2026-02-24 06:17:40'),
(134, NULL, 'Menghapus data alat: Pulpen', '2026-02-24 06:17:46'),
(135, NULL, 'Menambahkan kategori baru: Elektronik', '2026-02-24 06:17:55'),
(136, 6, 'Menambahkan peminjaman ID: 7', '2026-02-24 06:19:00'),
(137, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 7', '2026-02-24 06:19:00'),
(138, 2, 'Melakukan Login ke sistem', '2026-02-24 06:19:50'),
(139, 6, 'Update status peminjaman ID 7 menjadi dipinjam', '2026-02-24 06:20:33'),
(140, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-24 06:20:33'),
(141, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-24 06:20:33'),
(142, 2, 'Menyetujui peminjaman ID #7 (Status: Dipinjam)', '2026-02-24 06:20:33'),
(143, 6, 'Melakukan Login ke sistem', '2026-02-24 06:20:55'),
(144, 6, 'Update status peminjaman ID 7 menjadi menunggu_kembali', '2026-02-24 06:21:18'),
(145, 2, 'Melakukan Login ke sistem', '2026-02-24 06:21:39'),
(146, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-24 06:21:50'),
(147, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-24 06:21:50'),
(148, 6, 'Update status peminjaman ID 7 menjadi selesai', '2026-02-24 06:21:50'),
(149, 6, 'Menambahkan data pengembalian untuk peminjaman ID: 7', '2026-02-24 06:21:50'),
(150, 2, 'Memproses pengembalian peminjaman ID #7 (Selesai)', '2026-02-23 23:21:50'),
(151, 6, 'Melakukan Login ke sistem', '2026-02-24 06:29:34'),
(152, 6, 'Menambahkan peminjaman ID: 8', '2026-02-24 06:30:05'),
(153, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 8', '2026-02-24 06:30:05'),
(154, 2, 'Melakukan Login ke sistem', '2026-02-24 06:30:21'),
(155, 6, 'Update status peminjaman ID 8 menjadi dipinjam', '2026-02-24 06:30:33'),
(156, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-24 06:30:33'),
(157, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-24 06:30:33'),
(158, 2, 'Menyetujui peminjaman ID #8 (Status: Dipinjam)', '2026-02-24 06:30:33'),
(159, 6, 'Melakukan Login ke sistem', '2026-02-24 06:31:01'),
(160, 6, 'Update status peminjaman ID 8 menjadi menunggu_kembali', '2026-02-24 06:31:39'),
(161, 6, 'Menambahkan peminjaman ID: 9', '2026-02-24 06:32:43'),
(162, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 9', '2026-02-24 06:32:43'),
(163, 2, 'Melakukan Login ke sistem', '2026-02-24 06:40:24'),
(164, 2, 'Melakukan Login ke sistem', '2026-02-24 06:51:44'),
(165, 6, 'Update status peminjaman ID 9 menjadi dipinjam', '2026-02-24 06:51:58'),
(166, NULL, 'Update stok alat Pensil dari 8 menjadi 7', '2026-02-24 06:51:58'),
(167, NULL, 'Update stok alat Pensil dari 7 menjadi 6', '2026-02-24 06:51:58'),
(168, 2, 'Menyetujui peminjaman ID #9 (Status: Dipinjam)', '2026-02-24 06:51:58'),
(169, 2, 'Melakukan Login ke sistem', '2026-02-24 06:52:20'),
(170, NULL, 'Update stok alat Pensil dari 6 menjadi 7', '2026-02-24 06:52:33'),
(171, NULL, 'Update stok alat Pensil dari 7 menjadi 8', '2026-02-24 06:52:33'),
(172, 6, 'Update status peminjaman ID 8 menjadi selesai', '2026-02-24 06:52:33'),
(173, 6, 'Menambahkan data pengembalian untuk peminjaman ID: 8', '2026-02-24 06:52:33'),
(174, 2, 'Memproses pengembalian peminjaman ID #8 (Selesai)', '2026-02-23 23:52:33'),
(175, 6, 'Melakukan Login ke sistem', '2026-02-24 06:52:46'),
(176, 2, 'Melakukan Login ke sistem', '2026-02-24 06:53:09'),
(177, 6, 'Melakukan Login ke sistem', '2026-02-24 06:53:23'),
(178, 6, 'Update status peminjaman ID 9 menjadi menunggu_kembali', '2026-02-24 06:53:29'),
(179, 6, 'Mengajukan pengembalian untuk ID Pinjam #9', '2026-02-23 23:53:29'),
(180, 2, 'Melakukan Login ke sistem', '2026-02-24 06:53:52'),
(181, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-24 06:54:00'),
(182, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-24 06:54:00'),
(183, 6, 'Update status peminjaman ID 9 menjadi selesai', '2026-02-24 06:54:00'),
(184, 6, 'Menambahkan data pengembalian untuk peminjaman ID: 9', '2026-02-24 06:54:00'),
(185, 2, 'Memproses pengembalian peminjaman ID #9 (Selesai)', '2026-02-23 23:54:00'),
(186, 6, 'Melakukan Login ke sistem', '2026-02-24 06:54:14'),
(187, 1, 'Melakukan Login ke sistem', '2026-02-24 06:55:13'),
(188, 2, 'Melakukan Login ke sistem', '2026-02-24 07:01:51'),
(189, 6, 'Melakukan Login ke sistem', '2026-02-24 07:03:00'),
(190, 6, 'Menambahkan peminjaman ID: 10', '2026-02-24 07:03:44'),
(191, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 10', '2026-02-24 07:03:44'),
(192, 2, 'Melakukan Login ke sistem', '2026-02-24 07:03:55'),
(193, 6, 'Update status peminjaman ID 10 menjadi dipinjam', '2026-02-24 07:04:01'),
(194, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-24 07:04:01'),
(195, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-24 07:04:01'),
(196, 2, 'Menyetujui peminjaman ID #10 (Status: Dipinjam)', '2026-02-24 07:04:01'),
(197, 2, 'Melakukan Login ke sistem', '2026-02-24 07:04:18'),
(198, 6, 'Melakukan Login ke sistem', '2026-02-24 07:04:58'),
(199, 6, 'Update status peminjaman ID 10 menjadi menunggu_kembali', '2026-02-24 07:05:27'),
(200, 6, 'Mengajukan pengembalian untuk ID Pinjam #10', '2026-02-24 00:05:27'),
(201, 1, 'Melakukan Login ke sistem', '2026-02-24 07:05:48'),
(202, NULL, 'Menghapus data pengembalian ID: 9', '2026-02-24 07:12:18'),
(203, 6, 'Menghapus data peminjaman ID: 9', '2026-02-24 07:12:18'),
(205, NULL, 'Menghapus kategori: Elektronik', '2026-02-24 07:12:41'),
(206, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-02-24 08:05:33'),
(207, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-02-24 08:05:33'),
(208, 6, 'Update status peminjaman ID 10 menjadi selesai', '2026-02-24 08:05:33'),
(209, 6, 'Menambahkan data pengembalian untuk peminjaman ID: 10', '2026-02-24 08:05:33'),
(210, 1, 'Memproses pengembalian ID #10 (Sebagian Rusak/Hilang)', '2026-02-24 01:05:33'),
(211, 6, 'Menambahkan peminjaman ID: 11', '2026-02-24 08:28:35'),
(212, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 11', '2026-02-24 08:28:35'),
(213, 2, 'Melakukan Login ke sistem', '2026-02-24 08:28:46'),
(214, 6, 'Update status peminjaman ID 11 menjadi dipinjam', '2026-02-24 08:28:54'),
(215, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-02-24 08:28:54'),
(216, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-02-24 08:28:54'),
(217, 2, 'Menyetujui peminjaman ID #11 (Status: Dipinjam)', '2026-02-24 08:28:54'),
(218, 6, 'Melakukan Login ke sistem', '2026-02-24 08:29:06'),
(219, 6, 'Update status peminjaman ID 11 menjadi menunggu_kembali', '2026-02-24 08:29:13'),
(220, 6, 'Mengajukan pengembalian untuk ID Pinjam #11', '2026-02-24 01:29:13'),
(221, 2, 'Melakukan Login ke sistem', '2026-02-24 08:29:29'),
(222, 2, 'Melakukan Login ke sistem', '2026-02-25 05:32:24'),
(223, 4, 'Melakukan Login ke sistem', '2026-03-01 02:16:49'),
(224, 4, 'Menambahkan peminjaman ID: 12', '2026-03-01 02:30:04'),
(225, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 12', '2026-03-01 02:30:04'),
(226, 1, 'Melakukan Login ke sistem', '2026-03-01 02:32:43'),
(227, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-03-01 02:33:39'),
(228, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-03-01 02:33:39'),
(229, 6, 'Update status peminjaman ID 11 menjadi selesai', '2026-03-01 02:33:39'),
(230, 6, 'Menambahkan data pengembalian untuk peminjaman ID: 11', '2026-03-01 02:33:39'),
(231, 1, 'Memproses pengembalian ID #11 (Sebagian Rusak/Hilang). Denda Kerusakan: Rp 1.000', '2026-02-28 19:33:39'),
(232, 2, 'Melakukan Login ke sistem', '2026-03-01 02:34:26'),
(233, 4, 'Update status peminjaman ID 12 menjadi dipinjam', '2026-03-01 02:34:35'),
(234, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-03-01 02:34:35'),
(235, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-03-01 02:34:35'),
(236, 2, 'Menyetujui peminjaman ID #12 (Status: Dipinjam)', '2026-02-28 19:34:35'),
(237, 1, 'Melakukan Login ke sistem', '2026-03-01 02:34:49'),
(238, 4, 'Melakukan Login ke sistem', '2026-03-01 02:46:05'),
(239, 4, 'Update status peminjaman ID 12 menjadi menunggu_kembali', '2026-03-01 02:46:15'),
(240, 4, 'Mengajukan pengembalian untuk ID Pinjam #12', '2026-02-28 19:46:15'),
(241, 2, 'Melakukan Login ke sistem', '2026-03-01 02:46:28'),
(242, NULL, 'Update stok alat Pensil dari 8 menjadi 9', '2026-03-01 02:46:38'),
(243, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-03-01 02:46:38'),
(244, NULL, 'Update stok alat Pensil dari 10 menjadi 11', '2026-03-01 02:46:38'),
(245, 4, 'Update status peminjaman ID 12 menjadi selesai', '2026-03-01 02:46:38'),
(246, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 12', '2026-03-01 02:46:38'),
(247, 2, 'Memproses pengembalian ID #12 (Lengkap & Baik). Denda Kerusakan: Rp 0', '2026-02-28 19:46:38'),
(248, 4, 'Melakukan Login ke sistem', '2026-03-01 02:46:55'),
(249, 1, 'Melakukan Login ke sistem', '2026-03-01 02:47:28'),
(250, 4, 'Melakukan Login ke sistem', '2026-03-01 02:47:50'),
(251, 4, 'Menambahkan peminjaman ID: 13', '2026-03-01 02:48:12'),
(252, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 13', '2026-03-01 02:48:12'),
(253, 2, 'Melakukan Login ke sistem', '2026-03-01 02:48:59'),
(254, 4, 'Update status peminjaman ID 13 menjadi dipinjam', '2026-03-01 02:49:07'),
(255, NULL, 'Update stok alat Pensil dari 11 menjadi 10', '2026-03-01 02:49:07'),
(256, 2, 'Menyetujui peminjaman ID #13 (Status: Dipinjam)', '2026-02-28 19:49:07'),
(257, 4, 'Melakukan Login ke sistem', '2026-03-01 02:49:24'),
(258, 1, 'Melakukan Login ke sistem', '2026-03-01 02:49:55'),
(259, NULL, 'Menambahkan data alat: Pulpen', '2026-03-01 02:50:39'),
(260, 4, 'Melakukan Login ke sistem', '2026-03-01 02:50:59'),
(261, 4, 'Menambahkan peminjaman ID: 14', '2026-03-01 02:51:28'),
(262, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 14', '2026-03-01 02:51:28'),
(263, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 14', '2026-03-01 02:51:28'),
(264, 2, 'Melakukan Login ke sistem', '2026-03-01 02:58:12'),
(265, 4, 'Update status peminjaman ID 14 menjadi ditolak', '2026-03-01 02:58:24'),
(266, 2, 'Menolak permintaan peminjaman ID #14', '2026-02-28 19:58:24'),
(267, 4, 'Melakukan Login ke sistem', '2026-03-01 02:58:41'),
(268, 4, 'Menambahkan peminjaman ID: 15', '2026-03-01 03:01:47'),
(269, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 15', '2026-03-01 03:01:47'),
(270, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 15', '2026-03-01 03:01:47'),
(271, 2, 'Melakukan Login ke sistem', '2026-03-01 03:02:00'),
(272, 4, 'Update status peminjaman ID 15 menjadi ditolak', '2026-03-01 03:15:30'),
(273, 2, 'Menolak permintaan peminjaman ID #15', '2026-02-28 20:15:30'),
(274, 4, 'Melakukan Login ke sistem', '2026-03-01 03:16:29'),
(275, 2, 'Melakukan Login ke sistem', '2026-03-02 04:19:38'),
(276, 4, 'Melakukan Login ke sistem', '2026-03-02 04:43:40'),
(277, 6, 'Melakukan Login ke sistem', '2026-03-02 04:45:08'),
(278, 1, 'Melakukan Login ke sistem', '2026-03-02 04:45:38'),
(279, 4, 'Melakukan Login ke sistem', '2026-03-02 04:50:12'),
(280, 4, 'Menambahkan peminjaman ID: 16', '2026-03-02 05:02:29'),
(281, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 16', '2026-03-02 05:02:29'),
(282, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 16', '2026-03-02 05:02:29'),
(283, 1, 'Melakukan Login ke sistem', '2026-03-02 05:02:44'),
(284, 4, 'Melakukan Login ke sistem', '2026-03-02 05:07:06'),
(285, 2, 'Melakukan Login ke sistem', '2026-03-02 05:07:45'),
(286, 4, 'Update status peminjaman ID 16 menjadi dipinjam', '2026-03-02 05:11:47'),
(287, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-03-02 05:11:47'),
(288, NULL, 'Update stok alat Pulpen dari 10 menjadi 9', '2026-03-02 05:11:47'),
(289, 2, 'Menyetujui peminjaman ID #16 (Status: Dipinjam)', '2026-03-01 22:11:47'),
(290, 4, 'Melakukan Login ke sistem', '2026-03-02 05:12:05'),
(291, 4, 'Melakukan Login ke sistem', '2026-03-02 05:25:13'),
(292, 1, 'Melakukan Login ke sistem', '2026-03-02 06:34:42'),
(293, 4, 'Melakukan Login ke sistem', '2026-03-02 07:08:27'),
(294, 4, 'Update status peminjaman ID 16 menjadi menunggu_kembali', '2026-03-02 07:08:57'),
(295, 4, 'Mengajukan pengembalian untuk ID Pinjam #16', '2026-03-02 00:08:57'),
(296, 2, 'Melakukan Login ke sistem', '2026-03-02 07:09:18'),
(297, 4, 'Melakukan Login ke sistem', '2026-03-02 07:10:21'),
(298, 1, 'Melakukan Login ke sistem', '2026-03-02 07:36:06'),
(299, 4, 'Melakukan Login ke sistem', '2026-03-02 07:42:16'),
(300, 4, 'Melakukan Login ke sistem', '2026-03-03 05:57:32'),
(301, 4, 'Update status peminjaman ID 13 menjadi menunggu_kembali', '2026-03-03 05:57:47'),
(302, 4, 'Mengajukan pengembalian untuk ID Pinjam #13', '2026-03-02 22:57:47'),
(303, 4, 'Melakukan Login ke sistem', '2026-03-03 05:58:03'),
(304, 2, 'Melakukan Login ke sistem', '2026-03-03 05:58:52'),
(305, 1, 'Melakukan Login ke sistem', '2026-03-03 05:59:29'),
(306, NULL, 'Update stok alat Pensil dari 9 menjadi 10', '2026-03-03 05:59:52'),
(307, NULL, 'Update stok alat Pensil dari 10 menjadi 11', '2026-03-03 05:59:52'),
(308, 4, 'Update status peminjaman ID 13 menjadi selesai', '2026-03-03 05:59:52'),
(309, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 13', '2026-03-03 05:59:52'),
(310, 1, 'Memproses pengembalian ID #13 (Sebagian Rusak/Hilang). Total Denda: Rp 6.000', '2026-03-02 22:59:52'),
(311, NULL, 'Update stok alat Pensil dari 11 menjadi 12', '2026-03-03 06:00:16'),
(312, NULL, 'Update stok alat Pulpen dari 9 menjadi 10', '2026-03-03 06:00:16'),
(313, NULL, 'Update stok alat Pensil dari 12 menjadi 13', '2026-03-03 06:00:16'),
(314, NULL, 'Update stok alat Pensil dari 13 menjadi 14', '2026-03-03 06:00:16'),
(315, NULL, 'Update stok alat Pulpen dari 10 menjadi 11', '2026-03-03 06:00:16'),
(316, 4, 'Update status peminjaman ID 16 menjadi selesai', '2026-03-03 06:00:16'),
(317, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 16', '2026-03-03 06:00:16'),
(318, 1, 'Memproses pengembalian ID #16 (Lengkap & Baik). Total Denda: Rp 0', '2026-03-02 23:00:16'),
(319, 4, 'Melakukan Login ke sistem', '2026-03-03 06:00:48'),
(320, 4, 'Menambahkan peminjaman ID: 17', '2026-03-03 06:01:10'),
(321, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 17', '2026-03-03 06:01:10'),
(322, 2, 'Melakukan Login ke sistem', '2026-03-03 06:01:25'),
(323, 4, 'Update status peminjaman ID 17 menjadi dipinjam', '2026-03-03 06:01:34'),
(324, NULL, 'Update stok alat Pensil dari 14 menjadi 13', '2026-03-03 06:01:34'),
(325, 2, 'Menyetujui peminjaman ID #17 (Status: Dipinjam)', '2026-03-02 23:01:34'),
(326, 4, 'Melakukan Login ke sistem', '2026-03-03 06:01:47'),
(327, 4, 'Update status peminjaman ID 17 menjadi menunggu_kembali', '2026-03-03 06:01:57'),
(328, 4, 'Mengajukan pengembalian untuk ID Pinjam #17', '2026-03-02 23:01:57'),
(329, 2, 'Melakukan Login ke sistem', '2026-03-03 06:02:13'),
(330, NULL, 'Update stok alat Pensil dari 13 menjadi 14', '2026-03-03 06:02:21'),
(331, NULL, 'Update stok alat Pensil dari 14 menjadi 15', '2026-03-03 06:02:21'),
(332, NULL, 'Update stok alat Pensil dari 15 menjadi 16', '2026-03-03 06:02:21'),
(333, 4, 'Update status peminjaman ID 17 menjadi selesai', '2026-03-03 06:02:21'),
(334, 4, 'Menambahkan data pengembalian untuk peminjaman ID: 17', '2026-03-03 06:02:21'),
(335, 2, 'Memproses pengembalian ID #17 (Lengkap & Baik). Total Denda: Rp 0', '2026-03-02 23:02:22'),
(336, 4, 'Melakukan Login ke sistem', '2026-03-03 06:02:33'),
(337, 2, 'Melakukan Login ke sistem', '2026-03-03 06:35:04'),
(338, 4, 'Melakukan Login ke sistem', '2026-03-03 06:38:21'),
(339, 4, 'Menambahkan peminjaman ID: 18', '2026-03-03 06:38:50'),
(340, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 18', '2026-03-03 06:38:50'),
(341, 2, 'Melakukan Login ke sistem', '2026-03-03 06:39:09'),
(342, 4, 'Update status peminjaman ID 18 menjadi dipinjam', '2026-03-03 06:39:35'),
(343, NULL, 'Update stok alat Pensil dari 16 menjadi 10', '2026-03-03 06:39:35'),
(344, 2, 'Menyetujui peminjaman ID #18 (Status: Dipinjam)', '2026-03-02 23:39:35'),
(345, 4, 'Melakukan Login ke sistem', '2026-03-03 06:39:52'),
(346, 4, 'Update status peminjaman ID 18 menjadi menunggu_kembali', '2026-03-03 06:40:13'),
(347, 4, 'Mengajukan pengembalian untuk ID Pinjam #18', '2026-03-02 23:40:13'),
(348, 2, 'Melakukan Login ke sistem', '2026-03-03 06:40:25'),
(349, NULL, 'Update stok alat Pensil dari 10 menjadi 11', '2026-03-03 06:41:26'),
(350, 4, 'Update status peminjaman ID 18 menjadi selesai', '2026-03-03 06:41:26'),
(351, 4, 'Memproses pengembalian ID: 18', '2026-03-03 06:41:26'),
(352, 2, 'Memproses pengembalian ID #18 (Sebagian Rusak/Hilang). Total Denda: Rp 5.000', '2026-03-02 23:41:26'),
(353, 4, 'Melakukan Login ke sistem', '2026-03-03 06:41:48'),
(354, 1, 'Melakukan Login ke sistem', '2026-03-03 06:46:05'),
(355, 4, 'Melakukan Login ke sistem', '2026-03-04 06:49:46'),
(356, 4, 'Melakukan Login ke sistem', '2026-03-04 07:02:54'),
(357, 4, 'Menambahkan peminjaman ID: 19', '2026-03-04 07:03:28'),
(358, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 19', '2026-03-04 07:03:28'),
(359, 1, 'Melakukan Login ke sistem', '2026-03-04 07:03:54'),
(360, 2, 'Melakukan Login ke sistem', '2026-03-04 07:04:41'),
(361, 4, 'Update status peminjaman ID 19 menjadi dipinjam', '2026-03-04 07:04:51'),
(362, NULL, 'Update stok alat Pensil dari 11 menjadi 10', '2026-03-04 07:04:51'),
(363, 2, 'Menyetujui peminjaman ID #19 (Status: Dipinjam)', '2026-03-04 00:04:51'),
(364, 2, 'Melakukan Login ke sistem', '2026-03-04 07:05:22'),
(365, NULL, 'Update data alat: Pensil', '2026-03-04 07:05:47'),
(366, 4, 'Update status peminjaman ID 19 menjadi selesai', '2026-03-04 07:05:47'),
(367, 4, 'Memproses pengembalian ID: 19', '2026-03-04 07:05:47'),
(368, 2, 'Memproses pengembalian ID #19 (Lengkap & Baik). Total Denda: Rp 0', '2026-03-04 00:05:47'),
(369, 4, 'Melakukan Login ke sistem', '2026-03-04 07:12:41'),
(370, 4, 'Menambahkan peminjaman ID: 20', '2026-03-04 07:13:02'),
(371, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 20', '2026-03-04 07:13:02'),
(372, 2, 'Melakukan Login ke sistem', '2026-03-04 07:13:17'),
(373, 4, 'Update status peminjaman ID 20 menjadi dipinjam', '2026-03-04 07:13:24'),
(374, NULL, 'Update stok alat Pensil dari 10 menjadi 9', '2026-03-04 07:13:24'),
(375, 2, 'Menyetujui peminjaman ID #20 (Status: Dipinjam)', '2026-03-04 00:13:24'),
(376, 4, 'Melakukan Login ke sistem', '2026-03-04 07:13:36'),
(377, 4, 'Update status peminjaman ID 20 menjadi menunggu_kembali', '2026-03-04 07:13:45'),
(378, 4, 'Mengajukan pengembalian untuk ID Pinjam #20', '2026-03-04 00:13:45'),
(379, 2, 'Melakukan Login ke sistem', '2026-03-04 07:14:00'),
(380, 4, 'Melakukan Login ke sistem', '2026-03-04 07:30:25'),
(381, 4, 'Menambahkan peminjaman ID: 21', '2026-03-04 07:30:43'),
(382, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 21', '2026-03-04 07:30:43'),
(383, 2, 'Melakukan Login ke sistem', '2026-03-04 07:31:04'),
(384, 4, 'Update status peminjaman ID 21 menjadi dipinjam', '2026-03-04 07:31:13'),
(385, NULL, 'Update stok alat Pulpen dari 11 menjadi 10', '2026-03-04 07:31:13'),
(386, 2, 'Menyetujui peminjaman ID #21 (Status: Dipinjam)', '2026-03-04 00:31:13'),
(387, 2, 'Melakukan Login ke sistem', '2026-03-04 07:31:26'),
(388, NULL, 'Update stok alat Pulpen dari 10 menjadi 11', '2026-03-04 07:38:09'),
(389, 4, 'Update status peminjaman ID 21 menjadi selesai', '2026-03-04 07:38:09'),
(390, 4, 'Memproses pengembalian ID: 21', '2026-03-04 07:38:09'),
(391, 2, 'Memproses pengembalian ID #21 (Lengkap & Baik). Total Denda: Rp 0', '2026-03-04 00:38:09'),
(392, 1, 'Melakukan Login ke sistem', '2026-03-04 23:36:28'),
(393, 2, 'Melakukan Login ke sistem', '2026-03-04 23:43:25'),
(394, 4, 'Melakukan Login ke sistem', '2026-03-04 23:45:11'),
(395, 1, 'Melakukan Login ke sistem', '2026-03-05 01:16:48'),
(396, 4, 'Melakukan Login ke sistem', '2026-03-05 02:50:30'),
(397, NULL, 'Menghapus data pengembalian ID: 1', '2026-03-05 03:24:33'),
(398, 3, 'Menghapus data peminjaman ID: 1', '2026-03-05 03:24:33'),
(399, NULL, 'Menghapus data pengembalian ID: 2', '2026-03-05 03:24:38'),
(400, 4, 'Menghapus data peminjaman ID: 2', '2026-03-05 03:24:38'),
(401, NULL, 'Menghapus data pengembalian ID: 3', '2026-03-05 03:24:44'),
(402, 4, 'Menghapus data peminjaman ID: 3', '2026-03-05 03:24:44'),
(403, NULL, 'Menghapus data pengembalian ID: 4', '2026-03-05 03:24:49'),
(404, 4, 'Menghapus data peminjaman ID: 4', '2026-03-05 03:24:49'),
(405, 7, 'Menambahkan data user dengan username Fan', '2026-03-05 03:42:18'),
(406, 4, 'Update status peminjaman ID 20 menjadi dipinjam', '2026-03-05 04:13:41'),
(407, NULL, 'Update stok alat Pensil dari 9 menjadi 8', '2026-03-05 04:13:41'),
(408, 1, 'Menolak pengajuan pengembalian ID #20 karena alat belum lengkap/sesuai. Status dikembalikan ke Dipinjam.', '2026-03-04 21:13:41'),
(409, 4, 'Melakukan Login ke sistem', '2026-03-05 04:19:06'),
(410, 2, 'Melakukan Login ke sistem', '2026-03-05 04:20:15'),
(411, NULL, 'Menambahkan data user dengan username Zamzam', '2026-03-05 04:27:44'),
(412, NULL, 'Menghapus data user dengan username Zamzam', '2026-03-05 04:28:36'),
(413, 4, 'Menambahkan peminjaman ID: 22', '2026-03-05 04:29:36'),
(414, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 22', '2026-03-05 04:29:36'),
(415, 4, 'Update status peminjaman ID 20 menjadi menunggu_kembali', '2026-03-05 04:33:23'),
(416, 4, 'Mengajukan pengembalian untuk ID Pinjam #20', '2026-03-04 21:33:23'),
(417, NULL, 'Update data alat: Pensil', '2026-03-05 04:37:10'),
(418, 4, 'Update status peminjaman ID 20 menjadi selesai', '2026-03-05 04:37:10'),
(419, 4, 'Memproses pengembalian ID: 20', '2026-03-05 04:37:10'),
(420, 1, 'Memproses pengembalian ID #20 (Sebagian Rusak/Hilang). Total Denda: Rp 10.000', '2026-03-04 21:37:10'),
(421, NULL, 'Menambahkan kategori baru: Mesin Berat', '2026-03-05 05:38:51'),
(422, NULL, 'Update kategori dari Mesin Berat menjadi Mesin ', '2026-03-05 05:39:36'),
(423, 4, 'Menambahkan peminjaman ID: 23', '2026-03-05 06:07:55'),
(424, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 23', '2026-03-05 06:07:55'),
(425, 1, 'Melakukan Login ke sistem', '2026-03-07 03:02:57'),
(426, 4, 'Update status peminjaman ID 23 menjadi dipinjam', '2026-03-07 03:17:16'),
(427, NULL, 'Update stok alat Pensil dari 8 menjadi 7', '2026-03-07 03:17:16'),
(428, 4, 'Update status peminjaman ID 22 menjadi dipinjam', '2026-03-07 03:18:15'),
(429, NULL, 'Update stok alat Pensil dari 7 menjadi 6', '2026-03-07 03:18:15'),
(430, 6, 'Menambahkan peminjaman ID: 24', '2026-03-07 03:18:51'),
(431, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 24', '2026-03-07 03:18:51'),
(432, 6, 'Menambahkan peminjaman ID: 25', '2026-03-07 03:19:20'),
(433, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 25', '2026-03-07 03:19:20'),
(434, 4, 'Update status peminjaman ID 23 menjadi selesai', '2026-03-07 03:20:03'),
(435, 4, 'Update status peminjaman ID 22 menjadi menunggu_kembali', '2026-03-07 03:20:21'),
(436, NULL, 'Update stok alat Pensil dari 6 menjadi 7', '2026-03-07 03:20:34'),
(437, 4, 'Update status peminjaman ID 22 menjadi selesai', '2026-03-07 03:20:34'),
(438, 4, 'Memproses pengembalian ID: 22', '2026-03-07 03:20:34'),
(439, 1, 'Memproses pengembalian ID #22 (Lengkap & Baik). Total Denda: Rp 0', '2026-03-06 20:20:34'),
(440, 4, 'Menambahkan peminjaman ID: 26', '2026-03-07 03:25:11'),
(441, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 26', '2026-03-07 03:25:11'),
(442, 4, 'Update status peminjaman ID 26 menjadi dipinjam', '2026-03-07 03:25:11'),
(443, NULL, 'Update stok alat Pulpen dari 11 menjadi 10', '2026-03-07 03:25:11'),
(444, 1, 'Membuat peminjaman & penyerahan langsung (Fast-Track) ID #26', '2026-03-06 20:25:11'),
(445, 4, 'Update status peminjaman ID 26 menjadi menunggu', '2026-03-07 03:29:12'),
(446, 4, 'Update status peminjaman ID 26 menjadi dipinjam', '2026-03-07 03:29:37'),
(447, NULL, 'Update stok alat Pulpen dari 10 menjadi 9', '2026-03-07 03:29:37'),
(448, 4, 'Update status peminjaman ID 26 menjadi menunggu', '2026-03-07 03:29:50'),
(449, 4, 'Update status peminjaman ID 26 menjadi dipinjam', '2026-03-07 03:30:09'),
(450, NULL, 'Update stok alat Pulpen dari 9 menjadi 8', '2026-03-07 03:30:09'),
(451, 6, 'Menambahkan peminjaman ID: 27', '2026-03-07 03:35:56'),
(452, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 27', '2026-03-07 03:35:56'),
(453, 6, 'Update status peminjaman ID 27 menjadi dipinjam', '2026-03-07 03:36:10'),
(454, NULL, 'Update stok alat Pulpen dari 8 menjadi 7', '2026-03-07 03:36:10'),
(455, NULL, 'Update data alat: Pulpen', '2026-03-07 04:32:39'),
(456, 6, 'Update status peminjaman ID 24 menjadi selesai', '2026-03-07 04:32:39'),
(457, 6, 'Memproses pengembalian ID: 24', '2026-03-07 04:32:39'),
(458, 1, 'Memproses pengembalian ID #24 (Sebagian Rusak/Hilang). Total Denda: Rp 5.000', '2026-03-06 21:32:39'),
(459, NULL, 'Update data alat: Pulpen', '2026-03-07 04:33:32'),
(460, 6, 'Update status peminjaman ID 25 menjadi selesai', '2026-03-07 04:33:32'),
(461, 6, 'Memproses pengembalian ID: 25', '2026-03-07 04:33:32'),
(462, 1, 'Memproses pengembalian ID #25 (Sebagian Rusak/Hilang). Total Denda: Rp 5.000', '2026-03-06 21:33:32'),
(463, 4, 'Menambahkan peminjaman ID: 28', '2026-03-07 04:39:54'),
(464, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 28', '2026-03-07 04:39:54'),
(465, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 28', '2026-03-07 04:39:54'),
(466, 4, 'Update status peminjaman ID 28 menjadi dipinjam', '2026-03-07 04:39:54'),
(467, NULL, 'Update stok alat Pensil dari 7 menjadi 6', '2026-03-07 04:39:54'),
(468, NULL, 'Update stok alat Pulpen dari 7 menjadi 6', '2026-03-07 04:39:54'),
(469, 1, 'Membuat peminjaman & penyerahan langsung (Fast-Track) ID #28', '2026-03-06 21:39:54'),
(470, 1, 'Melakukan Login ke sistem', '2026-03-07 04:47:30'),
(471, NULL, 'Update data alat: Pensil', '2026-03-07 04:48:26'),
(472, NULL, 'Update data alat: Pulpen', '2026-03-07 04:48:26'),
(473, 4, 'Update status peminjaman ID 28 menjadi selesai', '2026-03-07 04:48:26'),
(474, 4, 'Memproses pengembalian ID: 28', '2026-03-07 04:48:26'),
(475, 1, 'Memproses pengembalian ID #28 (Sebagian Rusak/Hilang). Total Denda: Rp 10.000', '2026-03-06 21:48:26'),
(476, 2, 'Melakukan Login ke sistem', '2026-03-07 05:16:04'),
(477, 4, 'Melakukan Login ke sistem', '2026-03-07 05:53:46'),
(478, 2, 'Melunasi hutang denda untuk ID Pengembalian #21', '2026-03-06 23:33:07'),
(479, 1, 'Melakukan Login ke sistem', '2026-03-08 12:02:27'),
(480, 1, 'Melakukan Login ke sistem', '2026-03-08 12:02:58'),
(481, 1, 'Melakukan Login ke sistem', '2026-03-08 12:03:32'),
(482, 4, 'Melakukan Login ke sistem', '2026-03-08 12:03:56'),
(483, 1, 'Melakukan Login ke sistem', '2026-03-08 12:05:50'),
(484, 4, 'Melakukan Login ke sistem', '2026-03-08 12:06:52'),
(485, 4, 'Update status peminjaman ID 26 menjadi menunggu_kembali', '2026-03-08 12:40:24'),
(486, 4, 'Mengajukan pengembalian untuk ID Pinjam #26', '2026-03-08 05:40:24'),
(487, 2, 'Melakukan Login ke sistem', '2026-03-08 12:46:21'),
(488, 4, 'Update status peminjaman ID 26 menjadi dipinjam', '2026-03-08 12:51:02'),
(489, NULL, 'Update stok alat Pulpen dari 6 menjadi 5', '2026-03-08 12:51:02'),
(490, 2, 'Menolak pengajuan pengembalian ID #26 karena alat belum lengkap/sesuai. Status dikembalikan ke Dipinjam.', '2026-03-08 05:51:02'),
(491, 4, 'Update status peminjaman ID 26 menjadi menunggu_kembali', '2026-03-08 12:52:28'),
(492, 4, 'Mengajukan pengembalian untuk ID Pinjam #26', '2026-03-08 05:52:28'),
(493, 1, 'Melakukan Login ke sistem', '2026-03-09 05:41:31'),
(494, 1, 'Melakukan Login ke sistem', '2026-03-09 05:41:47'),
(495, 2, 'Melakukan Login ke sistem', '2026-03-09 05:43:35'),
(496, 4, 'Melakukan Login ke sistem', '2026-03-09 05:43:57'),
(497, NULL, 'Menambahkan data alat: penghapus', '2026-03-09 05:49:09'),
(498, 4, 'Melakukan Login ke sistem', '2026-03-09 05:50:25'),
(499, 4, 'Menambahkan peminjaman ID: 29', '2026-03-09 05:51:45'),
(500, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 29', '2026-03-09 05:51:45'),
(501, 2, 'Melakukan Login ke sistem', '2026-03-09 05:52:11'),
(502, 4, 'Update status peminjaman ID 29 menjadi dipinjam', '2026-03-09 05:52:36'),
(503, NULL, 'Update stok alat Pensil dari 6 menjadi 4', '2026-03-09 05:52:36'),
(504, 2, 'Menyetujui peminjaman ID #29 (Status: Dipinjam)', '2026-03-08 22:52:36'),
(505, 4, 'Update status peminjaman ID 29 menjadi menunggu_kembali', '2026-03-09 05:55:06'),
(506, 4, 'Mengajukan pengembalian untuk ID Pinjam #29', '2026-03-08 22:55:06'),
(507, NULL, 'Update stok alat Pensil dari 4 menjadi 5', '2026-03-09 05:56:07'),
(508, 4, 'Update status peminjaman ID 29 menjadi selesai', '2026-03-09 05:56:07'),
(509, 4, 'Memproses pengembalian ID: 29', '2026-03-09 05:56:07'),
(510, 2, 'Memproses pengembalian ID #29 (Sebagian Rusak/Hilang). Total Denda: Rp 2.000', '2026-03-08 22:56:07'),
(511, 2, 'Melunasi hutang denda untuk ID Pengembalian #22', '2026-03-08 23:12:20'),
(512, 2, 'Melunasi hutang denda untuk ID Pengembalian #24', '2026-03-08 23:12:59'),
(513, 2, 'Melunasi hutang denda untuk ID Pengembalian #23', '2026-03-08 23:13:18'),
(514, NULL, 'Update data alat: Pulpen', '2026-03-09 06:18:11'),
(515, 4, 'Update status peminjaman ID 26 menjadi selesai', '2026-03-09 06:18:11'),
(516, 4, 'Memproses pengembalian ID: 26', '2026-03-09 06:18:11'),
(517, 2, 'Memproses pengembalian ID #26 (Sebagian Rusak/Hilang). Total Denda: Rp 7.000', '2026-03-08 23:18:11'),
(518, 4, 'Melakukan Login ke sistem', '2026-03-09 07:04:29'),
(519, 1, 'Melunasi hutang denda untuk ID Pengembalian #25', '2026-03-09 00:14:05'),
(520, NULL, 'Menghapus data pengembalian ID: 6', '2026-03-09 07:24:56'),
(521, NULL, 'Menghapus data pengembalian ID: 10', '2026-03-09 07:24:56'),
(522, NULL, 'Menghapus data pengembalian ID: 11', '2026-03-09 07:24:56'),
(523, NULL, 'Menghapus data pengembalian ID: 13', '2026-03-09 07:24:56'),
(524, NULL, 'Menghapus data pengembalian ID: 16', '2026-03-09 07:24:56'),
(525, NULL, 'Menghapus data pengembalian ID: 19', '2026-03-09 07:24:56'),
(526, NULL, 'Menghapus data pengembalian ID: 21', '2026-03-09 07:24:56'),
(527, NULL, 'Menghapus data pengembalian ID: 22', '2026-03-09 07:24:56'),
(528, NULL, 'Menghapus data pengembalian ID: 23', '2026-03-09 07:24:56'),
(529, NULL, 'Menghapus data pengembalian ID: 24', '2026-03-09 07:24:56'),
(530, NULL, 'Menghapus data pengembalian ID: 25', '2026-03-09 07:24:56'),
(531, 4, 'Menambahkan peminjaman ID: 30', '2026-03-09 07:25:32'),
(532, NULL, 'Menambahkan detail alat penghapus pada peminjaman ID 30', '2026-03-09 07:25:32'),
(533, 4, 'Update status peminjaman ID 30 menjadi dipinjam', '2026-03-09 07:25:42'),
(534, NULL, 'Update stok alat penghapus dari 10 menjadi 9', '2026-03-09 07:25:42'),
(535, 2, 'Menyetujui peminjaman ID #30 (Status: Dipinjam)', '2026-03-09 00:25:42'),
(536, 4, 'Update status peminjaman ID 30 menjadi menunggu_kembali', '2026-03-09 07:25:56'),
(537, 4, 'Mengajukan pengembalian untuk ID Pinjam #30', '2026-03-09 00:25:56'),
(538, NULL, 'Update data alat: penghapus', '2026-03-09 07:26:16'),
(539, 4, 'Update status peminjaman ID 30 menjadi selesai', '2026-03-09 07:26:16'),
(540, 4, 'Memproses pengembalian ID: 30', '2026-03-09 07:26:16'),
(541, 2, 'Memproses pengembalian ID #30 (Sebagian Rusak/Hilang). Total Denda: Rp 2.000', '2026-03-09 00:26:16'),
(542, 2, 'Melunasi hutang denda untuk ID Pengembalian #26', '2026-03-09 00:26:32'),
(543, 1, 'Melakukan Login ke sistem', '2026-03-10 07:32:29'),
(544, NULL, 'Menghapus kategori: Mesin ', '2026-03-10 07:33:32'),
(546, 2, 'Melakukan Login ke sistem', '2026-03-10 07:39:57'),
(547, 1, 'Melakukan Login ke sistem', '2026-03-11 04:46:23'),
(548, 1, 'Melakukan Login ke sistem', '2026-03-12 00:35:59'),
(549, 1, 'Melakukan Login ke sistem', '2026-03-12 00:46:56'),
(550, 1, 'Melakukan Login ke sistem', '2026-03-12 00:47:39'),
(551, 1, 'Melakukan Login ke sistem', '2026-03-12 00:48:18'),
(552, 1, 'Melakukan Login ke sistem', '2026-03-12 00:49:05'),
(553, 3, 'Update data user dengan username Zan', '2026-03-12 00:59:28'),
(554, 4, 'Melakukan Login ke sistem', '2026-03-12 01:17:37'),
(555, NULL, 'Menambahkan data user dengan username dummy01', '2026-03-12 01:29:11'),
(556, NULL, 'Menambahkan data user dengan username dummy02', '2026-03-12 01:29:11'),
(557, 11, 'Menambahkan data user dengan username dummy03', '2026-03-12 01:29:11'),
(558, NULL, 'Menambahkan data user dengan username dummy04', '2026-03-12 01:29:11'),
(559, NULL, 'Menambahkan data user dengan username dummy05', '2026-03-12 01:29:11'),
(560, 14, 'Menambahkan data user dengan username dummy06', '2026-03-12 01:29:11'),
(561, 15, 'Menambahkan data user dengan username dummy07', '2026-03-12 01:29:11'),
(562, 16, 'Menambahkan data user dengan username dummy08', '2026-03-12 01:29:11'),
(563, 17, 'Menambahkan data user dengan username dummy09', '2026-03-12 01:29:11'),
(564, 18, 'Menambahkan data user dengan username dummy10', '2026-03-12 01:29:11'),
(565, 19, 'Menambahkan data user dengan username dummy11', '2026-03-12 01:29:11'),
(566, 20, 'Menambahkan data user dengan username dummy12', '2026-03-12 01:29:11'),
(567, 21, 'Menambahkan data user dengan username dummy13', '2026-03-12 01:29:11'),
(568, 22, 'Menambahkan data user dengan username dummy14', '2026-03-12 01:29:11'),
(569, 23, 'Menambahkan data user dengan username dummy15', '2026-03-12 01:29:11'),
(570, 24, 'Menambahkan data user dengan username dummy16', '2026-03-12 01:29:11'),
(571, 25, 'Menambahkan data user dengan username dummy17', '2026-03-12 01:29:11'),
(572, 26, 'Menambahkan data user dengan username dummy18', '2026-03-12 01:29:11'),
(573, NULL, 'Menambahkan data user dengan username dummy19', '2026-03-12 01:29:11'),
(574, 28, 'Menambahkan data user dengan username dummy20', '2026-03-12 01:29:11'),
(575, 29, 'Menambahkan data user dengan username dummy21', '2026-03-12 01:29:11'),
(576, 30, 'Menambahkan data user dengan username dummy22', '2026-03-12 01:29:11'),
(577, 31, 'Menambahkan data user dengan username dummy23', '2026-03-12 01:29:11'),
(578, 32, 'Menambahkan data user dengan username dummy24', '2026-03-12 01:29:11'),
(579, NULL, 'Menambahkan data user dengan username dummy25', '2026-03-12 01:29:11'),
(580, NULL, 'Menghapus data user dengan username dummy19', '2026-03-12 01:44:23'),
(581, NULL, 'Menghapus data user dengan username dummy01', '2026-03-12 01:44:23'),
(582, NULL, 'Menghapus data user dengan username dummy02', '2026-03-12 01:44:23'),
(583, NULL, 'Menghapus data user dengan username dummy25', '2026-03-12 01:47:22'),
(584, NULL, 'Menghapus data user dengan username dummy05', '2026-03-12 01:47:22'),
(585, NULL, 'Menghapus data user dengan username dummy04', '2026-03-12 01:47:22'),
(586, 4, 'Melakukan Login ke sistem', '2026-03-12 02:25:18'),
(587, 1, 'Melakukan Login ke sistem', '2026-03-12 02:29:58'),
(588, 4, 'Menambahkan peminjaman ID: 31', '2026-03-12 03:00:29'),
(589, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 31', '2026-03-12 03:00:29'),
(590, 4, 'Update status peminjaman ID 31 menjadi dipinjam', '2026-03-12 03:01:04'),
(591, NULL, 'Update stok alat Pensil dari 5 menjadi 4', '2026-03-12 03:01:04'),
(592, 1, 'Melakukan Login ke sistem', '2026-03-14 12:12:06'),
(593, 2, 'Melakukan Login ke sistem', '2026-03-14 12:13:41'),
(594, 1, 'Melakukan Login ke sistem', '2026-03-14 12:15:06'),
(595, 1, 'Melakukan Login ke sistem', '2026-03-14 12:15:37'),
(596, 4, 'Melakukan Login ke sistem', '2026-03-14 12:16:53'),
(597, 2, 'Melakukan Login ke sistem', '2026-03-14 12:17:57'),
(598, 4, 'Melakukan Login ke sistem', '2026-03-14 12:20:19'),
(599, 4, 'Menambahkan peminjaman ID: 32', '2026-03-14 12:21:50'),
(600, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 32', '2026-03-14 12:21:50'),
(601, 2, 'Melakukan Login ke sistem', '2026-03-14 12:22:21'),
(602, 4, 'Update status peminjaman ID 32 menjadi ditolak', '2026-03-14 12:22:57'),
(603, 2, 'Menolak permintaan peminjaman ID #32', '2026-03-14 05:22:57'),
(604, 4, 'Menambahkan peminjaman ID: 33', '2026-03-14 12:23:32'),
(605, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 33', '2026-03-14 12:23:32'),
(606, 4, 'Update status peminjaman ID 33 menjadi dipinjam', '2026-03-14 12:23:41'),
(607, NULL, 'Update stok alat Pensil dari 4 menjadi 3', '2026-03-14 12:23:41'),
(608, 2, 'Menyetujui peminjaman ID #33 (Status: Dipinjam)', '2026-03-14 05:23:41'),
(609, 4, 'Menambahkan peminjaman ID: 34', '2026-03-14 12:41:52'),
(610, NULL, 'Menambahkan detail alat Pensil pada peminjaman ID 34', '2026-03-14 12:41:52'),
(611, 4, 'Update status peminjaman ID 34 menjadi dipinjam', '2026-03-14 12:42:16'),
(612, NULL, 'Update stok alat Pensil dari 3 menjadi 2', '2026-03-14 12:42:16'),
(613, 2, 'Menyetujui peminjaman \"Pensil\" untuk Intan rafida (ID #34)', '2026-03-14 05:42:16'),
(614, 4, 'Menambahkan peminjaman ID: 35', '2026-03-14 12:46:39'),
(615, NULL, 'Menambahkan detail alat Pulpen pada peminjaman ID 35', '2026-03-14 12:46:39'),
(616, 4, 'Update status peminjaman ID 35 menjadi dipinjam', '2026-03-14 12:46:55'),
(617, NULL, 'Update stok alat Pulpen dari 5 menjadi 4', '2026-03-14 12:46:55'),
(618, 2, 'Petugas Radika MENYETUJUI peminjaman \"Pulpen\" untuk Intan rafida (ID #35)', '2026-03-14 05:46:55'),
(619, 4, 'Menambahkan peminjaman ID: 36', '2026-03-14 12:59:35'),
(620, NULL, 'Menambahkan detail alat penghapus pada peminjaman ID 36', '2026-03-14 12:59:35'),
(621, 2, 'Petugas Radika MENYETUJUI peminjaman \"penghapus\" untuk Intan rafida (ID #36)', '2026-03-14 13:00:06'),
(622, NULL, 'Update stok alat penghapus dari 9 menjadi 8', '2026-03-14 13:00:06'),
(623, NULL, 'Update stok alat Pulpen dari 4 menjadi 5', '2026-03-14 13:13:00'),
(624, 6, 'Update status peminjaman ID #27 menjadi selesai', '2026-03-14 13:13:00'),
(625, 6, 'Memproses pengembalian ID: 27', '2026-03-14 13:13:00'),
(626, 2, 'Memproses pengembalian ID #27 (Lengkap & Baik). Tagihan tercatat: Rp 30.000', '2026-03-14 06:13:00'),
(627, 2, 'Melunasi seluruh hutang denda untuk ID Pengembalian #27', '2026-03-14 06:13:09'),
(628, NULL, 'Update stok alat Pensil dari 2 menjadi 3', '2026-03-14 13:14:37'),
(629, 4, 'Update status peminjaman ID #31 menjadi selesai', '2026-03-14 13:14:37'),
(630, 4, 'Memproses pengembalian ID: 31', '2026-03-14 13:14:37'),
(631, 2, 'Memproses pengembalian ID #31 (Lengkap & Baik). Tagihan tercatat: Rp 5.000', '2026-03-14 06:14:37'),
(632, 2, 'Melunasi seluruh hutang denda untuk ID Pengembalian #28', '2026-03-14 06:17:32'),
(633, NULL, 'Update data alat: penghapus', '2026-03-14 13:25:12'),
(634, 4, 'Update status peminjaman ID #36 menjadi selesai', '2026-03-14 13:25:12'),
(635, 4, 'Memproses pengembalian ID: 36', '2026-03-14 13:25:12'),
(636, 2, 'Petugas Radika memproses pengembalian ID #36 (Sebagian Rusak/Hilang). Tagihan tercatat: Rp 5.000', '2026-03-14 06:25:12'),
(637, 2, 'Petugas Radika menerima CICILAN sebesar Rp 4.000 untuk ID Pengembalian #29. (Sisa: Rp 1.000)', '2026-03-14 06:25:53'),
(638, 2, 'Petugas Radika MELUNASI sisa hutang Rp 1.000 untuk Pengembalian ID #29', '2026-03-14 13:38:20'),
(639, NULL, 'Update data alat: Pulpen', '2026-03-14 13:46:20'),
(640, 2, 'Update status peminjaman ID #35 menjadi selesai', '2026-03-14 13:46:20'),
(641, 2, 'Petugas Radika memproses Pengembalian ID #35. (Ada Tagihan/Hutang Denda: Rp 5.000)', '2026-03-14 13:46:20'),
(642, 2, 'Petugas Radika menerima CICILAN denda Rp 4.000 (Sisa Tagihan: Rp 1.000) untuk Peminjaman ID #35', '2026-03-14 13:47:08'),
(643, 4, 'Melakukan Login ke sistem', '2026-03-17 12:48:25'),
(644, 4, 'Intan rafida mengajukan pengembalian untuk alat \"Pensil\" (ID #33)', '2026-03-17 12:53:59'),
(645, 1, 'Melakukan Login ke sistem', '2026-03-17 12:56:21'),
(646, 2, 'Melakukan Login ke sistem', '2026-03-17 13:07:00'),
(647, NULL, 'Update stok alat Pensil dari 3 menjadi 4', '2026-03-17 13:16:20'),
(648, 2, 'Update status peminjaman ID #33 menjadi selesai', '2026-03-17 13:16:20'),
(649, 2, 'Petugas Radika memproses Pengembalian ID #33. (Ada Tagihan/Hutang Denda: Rp 10.000)', '2026-03-17 13:16:20'),
(650, 1, 'Melakukan Login ke sistem', '2026-03-25 15:42:40');

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id_peminjaman` int(11) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_alat` int(11) DEFAULT NULL,
  `tanggal_pinjam` date DEFAULT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `status` enum('menunggu','disetujui','dipinjam','menunggu_kembali','selesai','ditolak') DEFAULT 'menunggu',
  `keterangan` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`id_peminjaman`, `id_user`, `id_alat`, `tanggal_pinjam`, `tanggal_kembali`, `status`, `keterangan`) VALUES
(5, 4, 1, '2026-02-10', '2026-02-11', 'selesai', 'Menulis'),
(6, 4, 1, '2026-02-10', '2026-02-11', 'selesai', 'menulis'),
(7, 6, 1, '2026-02-24', '2026-02-27', 'selesai', 'Untuk PSAJ'),
(8, 6, 1, '2026-02-24', '2026-02-26', 'selesai', 'Menulis'),
(10, 6, 1, '2026-02-24', '2026-02-25', 'selesai', 'Menulis'),
(11, 6, 1, '2026-02-24', '2026-02-25', 'selesai', 'menulis'),
(12, 4, 1, '2026-03-01', '2026-03-02', 'selesai', 'Menggunakan Untuk PSAJ'),
(13, 4, 1, '2026-03-01', '2026-03-02', 'selesai', 'Untuk PSAJ'),
(14, 4, 1, '2026-03-01', '2026-03-04', 'ditolak', 'Untuk PSAJ'),
(15, 4, 1, '2026-03-01', '2026-03-02', 'ditolak', 'Untuk PSAJ'),
(16, 4, 1, '2026-03-02', '2026-03-03', 'selesai', 'untuk ukk'),
(17, 4, 1, '2026-03-03', '2026-03-04', 'selesai', 'UKK'),
(18, 4, 1, '2026-03-03', '2026-03-04', 'selesai', 'PSAJ'),
(19, 4, 1, '2026-03-04', '2026-03-05', 'selesai', 'ukk'),
(20, 4, 1, '2026-03-04', '2026-03-05', 'selesai', 'untuk psaj'),
(21, 4, 3, '2026-03-04', '2026-03-05', 'selesai', 'ukk'),
(22, 4, 1, '2026-03-05', '2026-03-07', 'selesai', 'Untuk PSAJ'),
(23, 4, 1, '2026-03-05', '2026-03-06', 'selesai', 'jnkasjjdsa'),
(24, 6, 3, '2026-03-07', '2026-03-08', 'selesai', 'jasknakjnjsk'),
(25, 6, 3, '2026-03-07', '2026-03-08', 'selesai', 'ancksnksj'),
(26, 4, 3, '2026-03-07', '2026-03-08', 'selesai', 'm,nkjnn'),
(27, 6, 3, '2026-03-07', '2026-03-08', 'selesai', 'jakkdbkjakcks'),
(28, 4, 1, '2026-03-07', '2026-03-08', 'selesai', 'aknslknkja'),
(29, 4, 1, '2026-03-09', '2026-03-10', 'selesai', 'kahkhkaj'),
(30, 4, 4, '2026-03-09', '2026-03-10', 'selesai', 'jkkjhkjhk'),
(31, 4, 1, '2026-03-12', '2026-03-13', 'selesai', ''),
(32, 4, 1, '2026-03-14', '2026-03-15', 'ditolak', 'kllkjl'),
(33, 4, 1, '2026-03-14', '2026-03-15', 'selesai', 'hjvjhvj'),
(34, 4, 1, '2026-03-14', '2026-03-15', 'dipinjam', 'asasasa'),
(35, 4, 3, '2026-03-14', '2026-03-15', 'selesai', ''),
(36, 4, 4, '2026-03-14', '2026-03-15', 'selesai', '');

--
-- Triggers `peminjaman`
--
DELIMITER $$
CREATE TRIGGER `trg_peminjaman_delete` BEFORE DELETE ON `peminjaman` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (OLD.id_user, CONCAT('Menghapus data peminjaman ID: ', OLD.id_peminjaman));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_peminjaman_insert` AFTER INSERT ON `peminjaman` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NEW.id_user, CONCAT('Menambahkan peminjaman ID: ', NEW.id_peminjaman));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_peminjaman_update` AFTER UPDATE ON `peminjaman` FOR EACH ROW BEGIN
    DECLARE v_nama_peminjam VARCHAR(100);
    DECLARE v_nama_alat VARCHAR(100);
    DECLARE v_nama_petugas VARCHAR(100);
    DECLARE v_actor_id INT;
    
    -- 1. Ambil nama peminjam
    SELECT nama INTO v_nama_peminjam FROM users WHERE id_user = NEW.id_user;
    
    -- 2. Ambil nama alat (Dari id_alat yang dipinjam)
    SELECT nama_alat INTO v_nama_alat FROM alat WHERE id_alat = NEW.id_alat;

    -- 3. TRIK SAKTI: Cek apakah ada kiriman @petugas_id dari PHP CodeIgniter?
    IF @petugas_id IS NOT NULL THEN
        SET v_actor_id = @petugas_id;
        SELECT nama INTO v_nama_petugas FROM users WHERE id_user = v_actor_id;
    ELSE
        -- Jika tidak ada (misal diupdate paksa dari phpMyAdmin langsung)
        SET v_actor_id = NEW.id_user;
        SET v_nama_petugas = 'Sistem/Otomatis';
    END IF;

    -- 4. Catat log berdasarkan perubahan status
    IF OLD.status != NEW.status THEN
        IF NEW.status = 'dipinjam' THEN
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' MENYETUJUI peminjaman "', v_nama_alat, '" untuk ', v_nama_peminjam, ' (ID #', NEW.id_peminjaman, ')'));
        
        ELSEIF NEW.status = 'ditolak' THEN
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' MENOLAK peminjaman "', v_nama_alat, '" dari ', v_nama_peminjam, ' (ID #', NEW.id_peminjaman, ')'));
            
        ELSEIF NEW.status = 'menunggu_kembali' THEN
            -- Ini jika siswa mengajukan pengembalian
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            VALUES (v_actor_id, CONCAT(v_nama_peminjam, ' mengajukan pengembalian untuk alat "', v_nama_alat, '" (ID #', NEW.id_peminjaman, ')'));
            
        ELSE
            -- Status lainnya
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            VALUES (v_actor_id, CONCAT('Update status peminjaman ID #', NEW.id_peminjaman, ' menjadi ', NEW.status));
        END IF;
    END IF;

    -- 5. Kurangi stok HANYA berdasarkan tabel detail peminjaman
    IF NEW.status = 'dipinjam' AND OLD.status != 'dipinjam' THEN
        UPDATE alat a INNER JOIN detail_peminjaman dp ON a.id_alat = dp.id_alat
        SET a.stok = a.stok - dp.jumlah 
        WHERE dp.id_peminjaman = NEW.id_peminjaman;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pengembalian`
--

CREATE TABLE `pengembalian` (
  `id_pengembalian` int(11) NOT NULL,
  `id_peminjaman` int(11) DEFAULT NULL,
  `tanggal_dikembalikan` date DEFAULT NULL,
  `kondisi_kembali` enum('baik','rusak','hilang') DEFAULT 'baik',
  `denda` int(11) DEFAULT 0,
  `denda_kerusakan` int(11) DEFAULT 0,
  `catatan_petugas` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pengembalian`
--

INSERT INTO `pengembalian` (`id_pengembalian`, `id_peminjaman`, `tanggal_dikembalikan`, `kondisi_kembali`, `denda`, `denda_kerusakan`, `catatan_petugas`) VALUES
(5, 5, '2026-02-10', 'baik', 0, 0, NULL),
(7, 7, '2026-02-24', 'baik', 0, 0, NULL),
(8, 8, '2026-02-24', 'baik', 0, 0, NULL),
(12, 12, '2026-03-01', 'baik', 0, 0, ''),
(14, 16, '2026-03-03', 'baik', 0, 0, ''),
(15, 17, '2026-03-03', 'baik', 0, 0, ''),
(17, 19, '2026-03-04', 'baik', 0, 0, NULL),
(18, 21, '2026-03-04', 'baik', 0, 0, ''),
(20, 22, '2026-03-07', 'baik', 0, 0, ''),
(26, 30, '2026-03-09', '', 0, 0, '[✅ LUNAS (Hutang Dibayar)] '),
(27, 27, '2026-03-14', 'baik', 0, 0, '[✅ LUNAS (Hutang Dibayar)] '),
(28, 31, '2026-03-14', 'baik', 0, 0, '[✅ LUNAS (Hutang Dibayar)] '),
(29, 36, '2026-03-14', '', 0, 0, '[✅ LUNAS (Hutang Dibayar)] '),
(30, 35, '2026-03-14', '', 0, 1000, '[⚠️ NGUTANG: Sisa Rp 1.000] '),
(31, 33, '2026-03-17', 'baik', 10000, 0, '[⚠️ NGUTANG: Sisa Rp 10.000] ');

--
-- Triggers `pengembalian`
--
DELIMITER $$
CREATE TRIGGER `trg_pengembalian_delete` BEFORE DELETE ON `pengembalian` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NULL, CONCAT('Menghapus data pengembalian ID: ', OLD.id_pengembalian));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pengembalian_insert` AFTER INSERT ON `pengembalian` FOR EACH ROW BEGIN
    DECLARE v_nama_petugas VARCHAR(100);
    DECLARE v_actor_id INT;
    DECLARE total_tagihan INT;

    SET total_tagihan = NEW.denda + NEW.denda_kerusakan;

    -- Trik menangkap ID Petugas dari PHP
    IF @petugas_id IS NOT NULL THEN
        SET v_actor_id = @petugas_id;
        SELECT nama INTO v_nama_petugas FROM users WHERE id_user = v_actor_id;
    ELSE
        SET v_actor_id = NULL;
        SET v_nama_petugas = 'Sistem';
    END IF;

    -- Kembalikan stok alat ke rak (Hanya yang barangnya kembali 'Baik')
    UPDATE alat a 
    INNER JOIN detail_peminjaman dp ON a.id_alat = dp.id_alat
    SET a.stok = a.stok + dp.jml_baik 
    WHERE dp.id_peminjaman = NEW.id_peminjaman;
    
    -- Ubah status transaksi jadi selesai
    UPDATE peminjaman SET status = 'selesai' WHERE id_peminjaman = NEW.id_peminjaman;
    
    -- Catat log apakah lunas atau ngutang
    IF total_tagihan > 0 THEN
        INSERT INTO log_aktivitas (id_user, aktivitas) 
        VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' memproses Pengembalian ID #', NEW.id_peminjaman, '. (Ada Tagihan/Hutang Denda: Rp ', REPLACE(FORMAT(total_tagihan, 0), ',', '.'), ')'));
    ELSE
        INSERT INTO log_aktivitas (id_user, aktivitas) 
        VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' memproses Pengembalian ID #', NEW.id_peminjaman, ' (Lengkap & Bebas Denda)'));
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_pengembalian_update` AFTER UPDATE ON `pengembalian` FOR EACH ROW BEGIN
    DECLARE v_nama_petugas VARCHAR(100);
    DECLARE v_actor_id INT;
    DECLARE hutang_lama INT;
    DECLARE hutang_baru INT;
    DECLARE uang_masuk INT;

    SET hutang_lama = OLD.denda + OLD.denda_kerusakan;
    SET hutang_baru = NEW.denda + NEW.denda_kerusakan;

    -- Jika angka hutang berkurang (Artinya ada pembayaran masuk!)
    IF hutang_baru < hutang_lama THEN
        SET uang_masuk = hutang_lama - hutang_baru;

        IF @petugas_id IS NOT NULL THEN
            SET v_actor_id = @petugas_id;
            SELECT nama INTO v_nama_petugas FROM users WHERE id_user = v_actor_id;
        ELSE
            SET v_actor_id = NULL;
            SET v_nama_petugas = 'Sistem';
        END IF;

        -- Jika sisa hutang jadi 0 (Lunas)
        IF hutang_baru = 0 THEN
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            -- PERBAIKAN DI SINI: Menggunakan NEW.id_peminjaman
            VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' MELUNASI sisa hutang Rp ', REPLACE(FORMAT(uang_masuk, 0), ',', '.'), ' untuk Peminjaman ID #', NEW.id_peminjaman));
        ELSE
            -- Jika masih ada sisa (Cicilan)
            INSERT INTO log_aktivitas (id_user, aktivitas) 
            -- PERBAIKAN DI SINI: Menggunakan NEW.id_peminjaman
            VALUES (v_actor_id, CONCAT('Petugas ', v_nama_petugas, ' menerima CICILAN denda Rp ', REPLACE(FORMAT(uang_masuk, 0), ',', '.'), ' (Sisa Tagihan: Rp ', REPLACE(FORMAT(hutang_baru, 0), ',', '.'), ') untuk Peminjaman ID #', NEW.id_peminjaman));
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id_role` int(11) NOT NULL,
  `nama_role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id_role`, `nama_role`) VALUES
(1, 'admin'),
(2, 'petugas'),
(3, 'peminjam');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL,
  `id_role` int(11) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `no_hp` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `foto_profil` varchar(255) DEFAULT 'default.png',
  `status` enum('aktif','nonaktif') DEFAULT 'aktif',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id_user`, `id_role`, `nama`, `no_hp`, `alamat`, `username`, `password`, `foto_profil`, `status`, `created_at`) VALUES
(1, 1, 'Muhammad Fadril', '083465789666', 'bakom', 'Dill', '$2y$10$H4qO2JmM4wyNMRBdBXKvZ.SEux0RwmUtw1c1LZsCiW22Iaur.JGD.', '1770621324_bf92fdb59c462d2c2e72.png', 'aktif', '2026-02-09 03:28:24'),
(2, 2, 'Radika', NULL, NULL, 'Dik', '$2y$10$a0GwSeM6dd8WMY9lSbfywOW.BGGxLJ/O0RjcXv7EaU/dpNcW2nUxi', '1770609206_e2ac8af45cd151bb25a8.jpg', 'aktif', '2026-02-09 03:53:01'),
(3, 3, 'Fauzan Nur Ramadhan', NULL, NULL, 'Zan', '$2y$10$0e8JVeRmXI..Whrv3jMeeOlcl2tDAuhJAjcpNBUjWQExYNZ7Ciplu', '1770620834_f966d033bc2cc9de69ba.png', 'nonaktif', '2026-02-09 06:18:05'),
(4, 3, 'Intan rafida', '086567253', 'Dusun Sukatali', 'Tan', '$2y$10$MPav94M79Y4PeirZeaJ6bubmhvVc8qOmOVrMaHMtud3YdO91.zNzm', '1771913800_7fe0a32d6b796ea1882c.png', 'aktif', '2026-02-10 00:30:37'),
(6, 3, 'Fajar', NULL, NULL, 'Jar', '$2y$10$kmcl1KB.yn5gKKWNT.Pnx.Zdz1qVKLpi0EMO3TXp5JMy3Yt0q3km6', '1771913776_031084b0e72f2c1c510b.png', 'aktif', '2026-02-24 06:16:16'),
(7, 3, 'Irfan', NULL, NULL, 'Fan', '$2y$10$0NhpZ3b/a8xbTY7mmpCOzunyUP3anFSz03B878hXZIee3waHisCua', '1772682138_5c097a7e45e38817b81e.png', 'nonaktif', '2026-03-05 03:42:18'),
(11, 3, 'Dummy User 03', NULL, NULL, 'dummy03', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(14, 3, 'Dummy User 06', NULL, NULL, 'dummy06', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(15, 3, 'Dummy User 07', NULL, NULL, 'dummy07', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(16, 3, 'Dummy User 08', NULL, NULL, 'dummy08', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(17, 3, 'Dummy User 09', NULL, NULL, 'dummy09', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(18, 3, 'Dummy User 10', NULL, NULL, 'dummy10', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(19, 3, 'Dummy User 11', NULL, NULL, 'dummy11', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(20, 3, 'Dummy User 12', NULL, NULL, 'dummy12', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(21, 3, 'Dummy User 13', NULL, NULL, 'dummy13', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(22, 3, 'Dummy User 14', NULL, NULL, 'dummy14', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(23, 3, 'Dummy User 15', NULL, NULL, 'dummy15', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(24, 3, 'Dummy User 16', NULL, NULL, 'dummy16', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(25, 3, 'Dummy User 17', NULL, NULL, 'dummy17', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(26, 3, 'Dummy User 18', NULL, NULL, 'dummy18', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(28, 3, 'Dummy User 20', NULL, NULL, 'dummy20', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(29, 3, 'Dummy User 21', NULL, NULL, 'dummy21', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(30, 3, 'Dummy User 22', NULL, NULL, 'dummy22', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(31, 3, 'Dummy User 23', NULL, NULL, 'dummy23', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11'),
(32, 3, 'Dummy User 24', NULL, NULL, 'dummy24', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'default.png', 'aktif', '2026-03-12 01:29:11');

--
-- Triggers `users`
--
DELIMITER $$
CREATE TRIGGER `trg_user_delete` BEFORE DELETE ON `users` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (OLD.id_user, CONCAT('Menghapus data user dengan username ', OLD.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_user_insert` AFTER INSERT ON `users` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NEW.id_user, CONCAT('Menambahkan data user dengan username ', NEW.username));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_user_update` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
    INSERT INTO log_aktivitas (id_user, aktivitas) VALUES (NEW.id_user, CONCAT('Update data user dengan username ', NEW.username));
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alat`
--
ALTER TABLE `alat`
  ADD PRIMARY KEY (`id_alat`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indexes for table `detail_peminjaman`
--
ALTER TABLE `detail_peminjaman`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_peminjaman` (`id_peminjaman`),
  ADD KEY `id_alat` (`id_alat`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indexes for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `id_user` (`id_user`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id_peminjaman`),
  ADD KEY `id_user` (`id_user`),
  ADD KEY `id_alat` (`id_alat`);

--
-- Indexes for table `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD PRIMARY KEY (`id_pengembalian`),
  ADD KEY `id_peminjaman` (`id_peminjaman`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_role`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `id_role` (`id_role`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alat`
--
ALTER TABLE `alat`
  MODIFY `id_alat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `detail_peminjaman`
--
ALTER TABLE `detail_peminjaman`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id_kategori` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=651;

--
-- AUTO_INCREMENT for table `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id_peminjaman` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `pengembalian`
--
ALTER TABLE `pengembalian`
  MODIFY `id_pengembalian` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id_role` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alat`
--
ALTER TABLE `alat`
  ADD CONSTRAINT `alat_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `kategori` (`id_kategori`);

--
-- Constraints for table `detail_peminjaman`
--
ALTER TABLE `detail_peminjaman`
  ADD CONSTRAINT `detail_peminjaman_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`) ON DELETE CASCADE,
  ADD CONSTRAINT `detail_peminjaman_ibfk_2` FOREIGN KEY (`id_alat`) REFERENCES `alat` (`id_alat`);

--
-- Constraints for table `log_aktivitas`
--
ALTER TABLE `log_aktivitas`
  ADD CONSTRAINT `log_aktivitas_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE SET NULL;

--
-- Constraints for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`),
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_alat`) REFERENCES `alat` (`id_alat`);

--
-- Constraints for table `pengembalian`
--
ALTER TABLE `pengembalian`
  ADD CONSTRAINT `pengembalian_ibfk_1` FOREIGN KEY (`id_peminjaman`) REFERENCES `peminjaman` (`id_peminjaman`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`id_role`) REFERENCES `roles` (`id_role`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
