
//This proc is the most basic of the procs. All it does is make a new mob on the same tile and transfer over a few variables.
//Returns the new mob
//Note that this proc does NOT do MMI related stuff!
/mob/proc/change_mob_type(new_type = null, turf/location = null, new_name = null as text, delete_old_mob = FALSE)

	if(isnewplayer(src))
		to_chat(usr, span_danger("Cannot convert players who have not entered yet."))
		return

	if(!new_type)
		new_type = input("Mob type path:", "Mob type") as text|null

	if(istext(new_type))
		new_type = text2path(new_type)

	if( !ispath(new_type) )
		to_chat(usr, "Invalid type path (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		return

	if(ispath(new_type, /mob/dead/new_player))
		to_chat(usr, span_danger("Cannot convert into a new_player mob type."))
		return

	var/mob/desired_mob
	if(isturf(location))
		desired_mob = new new_type(location)
	else
		desired_mob = new new_type(src.loc)

	if(!desired_mob || !ismob(desired_mob))
		to_chat(usr, "Type path is not a mob (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		qdel(desired_mob)
		return

	if( istext(new_name) )
		desired_mob.name = new_name
		desired_mob.real_name = new_name
	else
		desired_mob.name = src.name
		desired_mob.real_name = src.real_name

	if(has_dna() && desired_mob.has_dna())
		var/mob/living/carbon/oldmob = src
		var/mob/living/carbon/newmob = desired_mob
		oldmob.dna.transfer_identity(newmob, transfer_species = FALSE)
		newmob.updateappearance(mutcolor_update=1, mutations_overlay_update=1)
	else if(ishuman(desired_mob) && (!ismonkey(desired_mob)))
		var/mob/living/carbon/human/new_human = desired_mob
		client?.prefs.safe_transfer_prefs_to(new_human)
		new_human.dna.update_dna_identity()

	if(mind && isliving(desired_mob))
		mind.transfer_to(desired_mob, 1) // second argument to force key move to new mob
	else
		desired_mob.key = key

	if(delete_old_mob)
		QDEL_IN(src, 1)
	return desired_mob
