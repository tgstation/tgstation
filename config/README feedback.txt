Create a databse at the same location where the server MySQL databse is. (as defined in config/dbconfig.txt under ADDRESS and PORT) It can be a separate database or the same one, as you wish. Create the following table in it: (name needs to remain as 'erro_feedback')
 

CREATE TABLE IF NOT EXISTS `erro_feedback` (

  `id` int(11) NOT NULL AUTO_INCREMENT,

  `time` datetime NOT NULL,

  `round_id` int(8) NOT NULL,

  `var_name` varchar(32) NOT NULL,

  `var_value` int(16) DEFAULT NULL,

  `details` text,

  PRIMARY KEY (`id`)

);

 

Open the file config/dbconfig.txt and edit the following lines:

FEEDBACK_DATABASE test

FEEDBACK_LOGIN mylogin

FEEDBACK_PASSWORD mypassword