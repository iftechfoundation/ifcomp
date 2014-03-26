-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Mar 24 11:05:12 2014
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `auth_token`;

--
-- Table: `auth_token`
--
CREATE TABLE `auth_token` (
  `id` integer unsigned NOT NULL auto_increment,
  `user_id` integer unsigned NOT NULL,
  `token` varchar(64) NOT NULL DEFAULT '',
  `updated` timestamp NULL,
  `created` datetime NULL,
  INDEX `auth_token_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `auth_token_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `comp`;

--
-- Table: `comp`
--
CREATE TABLE `comp` (
  `id` integer unsigned NOT NULL auto_increment,
  `year` char(4) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `entry`;

--
-- Table: `entry`
--
CREATE TABLE `entry` (
  `id` integer unsigned NOT NULL auto_increment,
  `title` char(128) NOT NULL DEFAULT '',
  `subtitle` char(128) NULL,
  `author` integer unsigned NOT NULL,
  `author_pseudonym` char(64) NULL,
  `archive_url` char(128) NULL,
  `feelies_url` char(128) NULL,
  `hints_url` char(128) NULL,
  `play_url` char(128) NULL,
  `ifdb_id` char(16) NULL,
  `comp` integer unsigned NOT NULL,
  `upload_time` datetime NULL,
  `place` tinyint NULL,
  `blurb` text NULL,
  `reveal_pseudonym` tinyint NOT NULL DEFAULT 0,
  `miss_congeniality_place` integer NULL,
  INDEX `entry_idx_author` (`author`),
  INDEX `entry_idx_comp` (`comp`),
  PRIMARY KEY (`id`),
  CONSTRAINT `entry_fk_author` FOREIGN KEY (`author`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `entry_fk_comp` FOREIGN KEY (`comp`) REFERENCES `comp` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `entry_update`;

--
-- Table: `entry_update`
--
CREATE TABLE `entry_update` (
  `id` integer unsigned NOT NULL auto_increment,
  `entry` integer unsigned NOT NULL,
  `note` text NOT NULL,
  `time` datetime NOT NULL,
  INDEX `entry_update_idx_entry` (`entry`),
  PRIMARY KEY (`id`),
  CONSTRAINT `entry_update_fk_entry` FOREIGN KEY (`entry`) REFERENCES `entry` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `federated_site`;

--
-- Table: `federated_site`
--
CREATE TABLE `federated_site` (
  `id` integer unsigned NOT NULL auto_increment,
  `name` varchar(255) NULL,
  `api_key` varchar(255) NULL,
  `created` datetime NULL,
  `updated` timestamp NULL,
  `hashing_method` varchar(255) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `prize`;

--
-- Table: `prize`
--
CREATE TABLE `prize` (
  `id` integer unsigned NOT NULL auto_increment,
  `comp` integer unsigned NOT NULL,
  `donor` integer unsigned NOT NULL,
  `name` char(128) NOT NULL DEFAULT '',
  `notes` text NULL,
  `donor_pseudonym` char(64) NULL,
  `recipient` integer unsigned NULL,
  INDEX `prize_idx_comp` (`comp`),
  INDEX `prize_idx_donor` (`donor`),
  INDEX `prize_idx_recipient` (`recipient`),
  PRIMARY KEY (`id`),
  CONSTRAINT `prize_fk_comp` FOREIGN KEY (`comp`) REFERENCES `comp` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `prize_fk_donor` FOREIGN KEY (`donor`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `prize_fk_recipient` FOREIGN KEY (`recipient`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `role`;

--
-- Table: `role`
--
CREATE TABLE `role` (
  `id` integer unsigned NOT NULL auto_increment,
  `name` char(8) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user`;

--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer unsigned NOT NULL auto_increment,
  `name` char(64) NOT NULL DEFAULT '',
  `password` char(64) NOT NULL DEFAULT '',
  `salt` char(64) NOT NULL DEFAULT '',
  `email` char(64) NOT NULL DEFAULT '',
  `email_is_public` tinyint NOT NULL DEFAULT 1,
  `url` char(128) NULL,
  `twitter` char(32) NULL,
  `created` datetime NULL,
  `updated` timestamp NULL,
  `site_id` integer unsigned NOT NULL,
  `verified` tinyint NOT NULL DEFAULT 0,
  INDEX `user_idx_site_id` (`site_id`),
  PRIMARY KEY (`id`),
  UNIQUE `email` (`email`),
  CONSTRAINT `user_fk_site_id` FOREIGN KEY (`site_id`) REFERENCES `federated_site` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user_role`;

--
-- Table: `user_role`
--
CREATE TABLE `user_role` (
  `id` integer unsigned NOT NULL auto_increment,
  `user` integer unsigned NULL,
  `role` integer unsigned NULL,
  INDEX `user_role_idx_role` (`role`),
  INDEX `user_role_idx_user` (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `user_role_fk_role` FOREIGN KEY (`role`) REFERENCES `role` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `user_role_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `vote`;

--
-- Table: `vote`
--
CREATE TABLE `vote` (
  `id` integer unsigned NOT NULL auto_increment,
  `user` integer unsigned NOT NULL,
  `score` tinyint NOT NULL,
  `entry` integer unsigned NOT NULL,
  INDEX `vote_idx_entry` (`entry`),
  INDEX `vote_idx_user` (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `vote_fk_entry` FOREIGN KEY (`entry`) REFERENCES `entry` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `vote_fk_user` FOREIGN KEY (`user`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB;

SET foreign_key_checks=1;

