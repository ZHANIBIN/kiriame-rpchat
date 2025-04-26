ALTER TABLE players 
ADD COLUMN RadioInfo JSON DEFAULT '{
  "radiochannel": [
    {"id":1,"value":null},
    {"id":2,"value":null},
    {"id":3,"value":null},
    {"id":4,"value":null},
    {"id":5,"value":null},
    {"id":6,"value":null},
    {"id":7,"value":null},
    {"id":8,"value":null},
    {"id":9,"value":null},
    {"id":10,"value":null}
  ],
  "radiodepartment": [
    {"id":1,"value":"LSPD"}
  ]
}';

CREATE TABLE `playtime` (
	`identifier` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`time` INT(11) NOT NULL DEFAULT '0',
	`last_updated` TIMESTAMP NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
	PRIMARY KEY (`identifier`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;
