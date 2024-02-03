
CREATE TABLE IF NOT EXISTS `society` (
  `job` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `ledger` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC;


INSERT INTO `society` (`job`, `ledger`) VALUES
	('police', 0),
	('medic', 0);
