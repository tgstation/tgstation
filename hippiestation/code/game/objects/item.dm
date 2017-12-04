/obj/item
	var/special_attack = FALSE
	var/special_name = "generic"
	var/special_desc = "not supposed to see this"
	var/special_cost = 0
	var/interact_sound_timeout = 0   // time when we can next play the sound
	var/interact_sound_cooldown = 0  // How long before we can play these sounds again
	var/pickup_sound = null          // This sound plays when you pull out
	var/dropped_sound = null         // This sound plays when you put it down/away

/obj/item/proc/do_special_attack(atom/target, mob/living/carbon/user, proximity_flag)
	return

/obj/item/pickup(mob/user)
	..()

	if (pickup_sound || dropped_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

/obj/item/dropped(mob/user)
	..()

	if (pickup_sound || dropped_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

/obj/item/equipped(mob/user, slot)
	..()

	if (pickup_sound || dropped_sound)
		addtimer(CALLBACK(src, .proc/try_play_interact_sound, user), 1)

// Because of how pickup() and dropped() are handled I need to wait a very short time before finding where the item goes
// Could also use "on_enter_storage" and "on_exit_storage" but this is for when an item is picked up or dropped (from hand)
/obj/item/proc/try_play_interact_sound(mob/user)
	if (user)
		if (src in user.held_items)
			if (interact_sound_timeout < world.time && pickup_sound)
				playsound(user, pickup_sound, 50, 0)
				interact_sound_timeout = world.time + interact_sound_cooldown
		else
			if (interact_sound_timeout < world.time && dropped_sound)
				playsound(user, dropped_sound, 50, 0)
				interact_sound_timeout = world.time + interact_sound_cooldown

