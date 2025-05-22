
CREATE TABLE IF NOT EXISTS `billing` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `job` int(1) DEFAULT NULL,
  `reason` varchar(50) DEFAULT NULL,
  `identifier` longtext DEFAULT NULL,
  `charidentifier` int(11) DEFAULT NULL,
  `username` longtext DEFAULT NULL,
  `issuer` longtext DEFAULT NULL,
  `account` int(1) DEFAULT NULL,
  `cost` int(11) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4;
