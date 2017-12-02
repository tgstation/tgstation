/obj/item
	var/special_attack = FALSE
	var/special_name = "generic"
	var/special_desc = "not supposed to see this"
	var/special_cost = 0
	var/interact_sound_timeout = 0   // time when we can next play the sound
	var/interact_sound_cooldown = 0  // How long before we can play these sounds again
	var/pullout_sound = null		 // This sound plays when you pull out
	var/putaway_sound = null		 // This sound plays when you put it in

/obj/item/proc/do_special_attack(atom/target, mob/living/carbon/user, proximity_flag)
	return

/obj/item/pickup(mob/user)
	..()

	if (pullout_sound || putaway_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

/obj/item/dropped(mob/user)
	..()

	if (pullout_sound || putaway_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

/obj/item/equipped(mob/user, slot)
	..()

	if (pullout_sound || putaway_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

// Because of how pickup() and dropped() are handled I need to wait a very short time before finding where the item goes
/obj/item/proc/try_play_interact_sound(mob/user)
	if (src in user.held_items)
		if (interact_sound_timeout < world.time && pullout_sound)
			playsound(user, pullout_sound, 50, 0)
			interact_sound_timeout = world.time + interact_sound_cooldown
	else
		if (interact_sound_timeout < world.time && putaway_sound)
			playsound(user, putaway_sound, 50, 0)
			interact_sound_timeout = world.time + interact_sound_cooldown

