
/datum/component/riding/proc/driver_move(obj/vehicle/vehicle_parent, mob/living/user, direction)
	if(!keycheck(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>[vehicle_parent] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate \the [vehicle_parent] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(rider_check_flags & REQUIRES_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it while unable to stand!</span>")
			user.Stun(3 SECONDS)
			return COMPONENT_DRIVER_BLOCK_MOVE
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move \the [vehicle_parent]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(rider_check_flags & REQUIRES_ARMS && HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		if(rider_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it without being able to hold on!</span>")
			user.Stun(3 SECONDS)
			return COMPONENT_DRIVER_BLOCK_MOVE

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that unable to hold onto \the [vehicle_parent] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	handle_ride(user, direction)
