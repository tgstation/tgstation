/obj/vehicle/ridden
	name = "ridden vehicle"
	can_buckle = TRUE
	max_buckled_mobs = 1
	buckle_lying = 0
	pass_flags_self = PASSTABLE
	COOLDOWN_DECLARE(message_cooldown)
	interaction_flags_click = NEED_DEXTERITY

/obj/vehicle/ridden/examine(mob/user)
	. = ..()
	var/key_message = examine_key_message()
	if (key_message)
		. += key_message

/obj/vehicle/ridden/proc/examine_key_message()
	if(!key_type)
		return
	if(!inserted_key)
		return span_notice("Put a key inside it by clicking it with the [key_type::name].")
	else
		return span_notice("Alt-click [src] to remove \the [inserted_key].")

/obj/vehicle/ridden/generate_action_type(actiontype)
	var/datum/action/vehicle/ridden/A = ..()
	. = A
	if(istype(A))
		A.vehicle_ridden_target = src

/obj/vehicle/ridden/post_unbuckle_mob(mob/living/M)
	remove_occupant(M)
	return ..()

/obj/vehicle/ridden/post_buckle_mob(mob/living/M)
	add_occupant(M)
	return ..()

/obj/vehicle/ridden/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!key_type || is_key(inserted_key) || !is_key(tool))
		return NONE
	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] seems to be stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("You insert \the [tool] into \the [src]."))
	if(inserted_key) //just in case there's an invalid key
		inserted_key.forceMove(drop_location())
	inserted_key = tool
	return ITEM_INTERACT_SUCCESS

/obj/vehicle/ridden/click_alt(mob/user)
	if(!inserted_key)
		return CLICK_ACTION_BLOCKING
	if(!is_occupant(user))
		to_chat(user, span_warning("You must be riding the [src] to remove [src]'s [inserted_key]!"))
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("You remove \the [inserted_key] from \the [src]."))
	user.put_in_hands(inserted_key)
	inserted_key = null
	return CLICK_ACTION_SUCCESS

/obj/vehicle/ridden/user_buckle_mob(mob/living/M, mob/user, check_loc = TRUE)
	if(!in_range(user, src) || !in_range(M, src))
		return FALSE
	return ..(M, user, FALSE)

/obj/vehicle/ridden/buckle_mob(mob/living/M, force = FALSE, check_loc = TRUE)
	if(!force && occupant_amount() >= max_occupants)
		return FALSE

	var/response = SEND_SIGNAL(M, COMSIG_VEHICLE_RIDDEN, src)
	if(response & EJECT_FROM_VEHICLE)
		return FALSE

	return ..()

/obj/vehicle/ridden/zap_act(power, zap_flags)
	zap_buckle_check(power)
	return ..()
