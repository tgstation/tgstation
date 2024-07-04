//simply an item that breaks turfs down
/obj/item/turf_demolisher
	name = "\improper Exprimental Demolisher"
	desc = "An exprimental able to quickly deconstruct any surface."
	icon = 'icons/obj/mining.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	icon_state = "jackhammer"
	inhand_icon_state = "jackhammer"
	///The balloon_alert() to send when we cannot demolish a turf
	var/unbreakable_alert = "Unable to demolish that."
	///List of turf types we are allowed to break, if unset then we can break any turfs that dont have the INDESTRUCTIBLE resistance flag
	var/list/allowed_types = list(/turf/closed/wall)
	///List of turf types we are NOT allowed to break
	var/list/blacklisted_types
	///How long is the do_after() to break a turf
	var/break_time = 8 SECONDS
	///Do we devastate broken walls, because of quality 7 year old code this always makes iron no matter the wall type
	var/devastate = TRUE
	///How long is our recharge time between uses
	var/recharge_time = 0
	COOLDOWN_DECLARE(recharge)

/obj/item/turf_demolisher/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !isturf(target) || (user.istate & ISTATE_HARM))
		return

	if(!check_breakble(target, user, click_parameters))
		return

	if(try_demolish(target, user))
		return

/obj/item/turf_demolisher/proc/check_breakble(turf/attacked_turf, mob/living/user, params)
	if(recharge_time && !COOLDOWN_FINISHED(src, recharge))
		balloon_alert(user, "\The [src] is still recharging.")
		return FALSE

	if((allowed_types && !is_type_in_list(attacked_turf, allowed_types)) || is_type_in_list(attacked_turf, blacklisted_types) || (attacked_turf.resistance_flags & INDESTRUCTIBLE))
		if(unbreakable_alert)
			balloon_alert(user, unbreakable_alert)
		return FALSE
	return TRUE

/obj/item/turf_demolisher/proc/try_demolish(turf/attacked_turf, mob/living/user)
	if(!do_after(user, break_time, attacked_turf))
		return FALSE

	playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 80, channel = CHANNEL_SOUND_EFFECTS, mixer_channel = CHANNEL_SOUND_EFFECTS)
	if(iswallturf(attacked_turf))
		var/turf/closed/wall/wall_turf = attacked_turf
		wall_turf.dismantle_wall(devastate)
	else
		attacked_turf.ScrapeAway()

	if(recharge_time)
		COOLDOWN_START(src, recharge, recharge_time)
	return TRUE

/obj/item/turf_demolisher/reebe
	desc = "An exprimental able to quickly deconstruct any surface. This one seems to be calibrated to only work on reebe."
	break_time = 5 SECONDS
	recharge_time = 5 SECONDS

/obj/item/turf_demolisher/reebe/check_breakble(turf/attacked_turf, mob/living/user, params)
	. = ..()
	if(!.)
		return

	var/turf/our_turf = get_turf(src)
	if(!on_reebe(our_turf))
		balloon_alert(user, "\The [src] is specially calibrated to be used on reebe and will not work here!")
		return FALSE

	if(GLOB.clock_ark && get_dist(our_turf, get_turf(GLOB.clock_ark)) <= ARK_TURF_DESTRUCTION_BLOCK_RANGE)
		balloon_alert(user, "A near by energy source is interfering \the [src]!")
		return FALSE
