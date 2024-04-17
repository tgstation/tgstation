/datum/modpack/whitelist220
	name = "Whitelist220"
	desc = "Использование вайтлиста через БД"
	author = "larentoun"

/datum/modpack/whitelist220/pre_initialize()
	GLOB.admin_verbs_server |= /client/proc/update_whitelist
