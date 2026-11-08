-- Database: locara_db
CREATE DATABASE IF NOT EXISTS `locara_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `locara_db`;

-- 1. Table: users
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `uid` VARCHAR(64) NOT NULL UNIQUE,
    `name` VARCHAR(100) NOT NULL,
    `family_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table: devices
CREATE TABLE IF NOT EXISTS `devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(64) NOT NULL,
    `device_key` VARCHAR(64) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `device_code` VARCHAR(50) NOT NULL,
    `device_type` VARCHAR(30) DEFAULT 'car',
    `subtitle` VARCHAR(100) DEFAULT '',
    `location` VARCHAR(255) DEFAULT 'Cikini, Jakarta Pusat',
    `speed` VARCHAR(50) DEFAULT 'Berhenti',
    `battery` INT DEFAULT 100,
    `status` VARCHAR(20) DEFAULT 'online',
    `time_ago` VARCHAR(50) DEFAULT 'Baru saja',
    `is_demo` TINYINT(1) DEFAULT 1,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table: members
CREATE TABLE IF NOT EXISTS `members` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(64) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `place` VARCHAR(255) DEFAULT 'Lokasi belum tersedia',
    `status` VARCHAR(50) DEFAULT 'offline',
    `battery` INT DEFAULT 0,
    `latitude` DECIMAL(10, 7) DEFAULT -7.7956000,
    `longitude` DECIMAL(10, 7) DEFAULT 110.3695000,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Table: notifications
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(64) NOT NULL,
    `title` VARCHAR(150) NOT NULL,
    `message` TEXT NOT NULL,
    `type` VARCHAR(50) DEFAULT 'info',
    `avatar_text` VARCHAR(10) DEFAULT 'LC',
    `sender_name` VARCHAR(100) DEFAULT 'Locara',
    `request_status` VARCHAR(50) DEFAULT 'Menunggu',
    `subtitle` VARCHAR(100) DEFAULT '',
    `is_read` TINYINT(1) DEFAULT 0,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Table: friend_permissions
CREATE TABLE IF NOT EXISTS `friend_permissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(64) NOT NULL,
    `friend_id` VARCHAR(64) NOT NULL,
    `friend_name` VARCHAR(100) NOT NULL,
    `friend_code` VARCHAR(50) NOT NULL,
    `avatar_text` VARCHAR(10) DEFAULT 'FR',
    `status` VARCHAR(30) DEFAULT 'active',
    `sharing_duration` VARCHAR(100) DEFAULT 'Selalu aktif',
    `last_accessed` VARCHAR(100) DEFAULT 'Baru saja',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Table: trips
CREATE TABLE IF NOT EXISTS `trips` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` VARCHAR(64) NOT NULL,
    `device_id` VARCHAR(64) NULL,
    `time_range` VARCHAR(100) NOT NULL,
    `route_name` VARCHAR(255) NOT NULL,
    `distance` VARCHAR(50) NOT NULL,
    `duration` VARCHAR(50) NOT NULL,
    `detail` VARCHAR(255) DEFAULT '',
    `trip_date` VARCHAR(100) NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
