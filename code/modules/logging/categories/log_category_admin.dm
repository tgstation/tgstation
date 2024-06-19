/datum/log_category/admin
	category = LOG_CATEGORY_ADMIN
	config_flag = /datum/config_entry/flag/log_admin

/datum/log_category/admin_dsay
	category = LOG_CATEGORY_ADMIN_DSAY
	master_category = /datum/log_category/admin
	config_flag = /datum/config_entry/flag/log_admin

/datum/log_category/admin_circuit
	category = LOG_CATEGORY_ADMIN_CIRCUIT
	master_category = /datum/log_category/admin
	config_flag = /datum/config_entry/flag/log_admin

// private categories //

/datum/log_category/admin_private
	category = LOG_CATEGORY_ADMIN_PRIVATE
	config_flag = /datum/config_entry/flag/log_admin
	secret = TRUE

/datum/log_category/admin_asay
	category = LOG_CATEGORY_ADMIN_PRIVATE_ASAY
	master_category = /datum/log_category/admin_private
	config_flag = /datum/config_entry/flag/log_adminchat
	secret = TRUE
