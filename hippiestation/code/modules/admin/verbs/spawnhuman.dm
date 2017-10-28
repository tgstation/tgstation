/client/proc/spawn_human()
	set category = "Fun"
	set name = "Spawn Human"
	set desc = "Spawns a normal human"

	if(!check_rights(R_FUN))
		return

	var/turf/T = get_turf(usr)
	new /mob/living/carbon/human(T)
	log_admin("[key_name(usr)] spawned a human.")
	SSblackbox.add_details("admin_verb","SH")
