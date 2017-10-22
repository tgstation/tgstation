/client/proc/spawn_floor_cluwne()
	set category = "Fun"
	set name = "Unleash Floor Cluwne"
	set desc = "Pick a specific target or just let it select randomly and spawn the floor cluwne mob on the station. Be warned: spawning more than one may cause issues!"
	var/target

	if(!check_rights(R_FUN))
		return

	var/turf/T = get_turf(usr)
	target = input("Any specific target in mind? Please note only live, non cluwned, human targets are valid.", "Target", target) as null|anything in GLOB.player_list
	if(target && ishuman(target))
		var/mob/living/carbon/human/H = target
		var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
		FC.Acquire_Victim(H)
	else
		new /mob/living/simple_animal/hostile/floor_cluwne(T)
	log_admin("[key_name(usr)] spawned floor cluwne.")
	message_admins("[key_name(usr)] spawned floor cluwne.")
	SSblackbox.add_details("admin_verb","SFC")