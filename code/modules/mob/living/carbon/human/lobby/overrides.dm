//No breathing/reagents/whatever please. Those subsystems aren't running
/mob/living/carbon/human/lobby/Life()
	return

//Needful
/mob/living/carbon/human/lobby/Stat()
	..()
	LobbyStat()

//OOC and memes only
/mob/living/carbon/human/lobby/say(message)
	if(check_emote(message))
		return
	client.ooc(message)

//do it right
/mob/living/carbon/human/lobby/suicide()
	if(new_character || notransform)
		return
	make_me_an_observer()

//no griff
/mob/living/carbon/human/lobby/can_be_pulled()
	return FALSE

//nahh, don't worry about us
/mob/living/carbon/human/lobby/update_z()
	return

//no moverino
/mob/living/carbon/human/lobby/ShuttleThrow(list/movement_force, move_dir)
	return

//checking stuff
/mob/living/carbon/human/lobby/Moved()
	. = ..()
	if(!ready_up)
		return
	instant_ready = istype(get_area(src), /area/shuttle/lobby/start_zone)
	ready_up.UpdateButtonIcon()
