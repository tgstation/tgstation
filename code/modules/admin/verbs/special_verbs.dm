// Admin Verbs in this file are special and cannot use the AVD system for some reason or another.

DEFINE_PROC_VERB(/client, show_verbs, "Adminverbs - Show", "", FALSE, ADMIN_CATEGORY_MAIN)
	remove_verb(src, /client/proc/show_verbs)
	add_admin_verbs()

	to_chat(src, span_interface("All of your adminverbs are now visible."), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Show Adminverbs")

DEFINE_PROC_VERB(/client, readmin, "Readmin", "Regain your admin powers.", FALSE, "Admin")
	var/datum/admins/A = GLOB.deadmins[ckey]

	if(!A)
		A = GLOB.admin_datums[ckey]
		if (!A)
			var/msg = " is trying to readmin but they have no deadmin entry"
			message_admins("[key_name_admin(src)][msg]")
			log_admin_private("[key_name(src)][msg]")
			return

	A.associate(src)

	if (!holder)
		return //This can happen if an admin attempts to vv themself into somebody elses's deadmin datum by getting ref via brute force

	to_chat(src, span_interface("You are now an admin."), confidential = TRUE)
	message_admins("[src] re-adminned themselves.")
	log_admin("[src] re-adminned themselves.")
	BLACKBOX_LOG_ADMIN_VERB("Readmin")

DEFINE_PROC_VERB(/client, admin_2fa_verify, "Verify Admin", "", FALSE, "Admin")
	var/datum/admins/admin = GLOB.admin_datums[ckey]
	admin?.associate(src)
