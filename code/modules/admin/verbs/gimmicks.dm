var/global/gimmick_hat = null

// irreversable, for now
/client/proc/cmd_admin_christmas()
	set category = "Fun"
	set name = "Christmas Time"

	if(!holder)
		src << "Only administrators may use this command."
		return

	if(!gimmick_hat)
		log_admin("[usr.key] has started Christmas!")
		message_admins("<font color='blue'>[usr.key] has started Christmas!</font>")

		// handle pre-existing hats
		gimmick_hat = "santahat"
	else
		log_admin("[usr.key] has stopped Christmas!")
		message_admins("<font color='blue'>[usr.key] has stopped Christmas!</font>")

		// handle pre-existing hats
		gimmick_hat = null
