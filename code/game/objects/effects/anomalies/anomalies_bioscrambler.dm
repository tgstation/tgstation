
/obj/effect/anomaly/bioscrambler
	name = "bioscrambler anomaly"
	icon_state = "bioscrambler"
	aSignal = /obj/item/assembly/signaler/anomaly/bioscrambler
	immortal = TRUE
	/// Cooldown for every anomaly pulse
	COOLDOWN_DECLARE(pulse_cooldown)
	/// How many seconds between each anomaly pulses
	var/pulse_delay = 15 SECONDS
	/// Range of the anomaly pulse
	var/range = 5
	///Lists for zones and bodyparts to swap and randomize
	var/static/list/zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/static/list/chests
	var/static/list/heads
	var/static/list/l_arms
	var/static/list/r_arms
	var/static/list/l_legs
	var/static/list/r_legs

/obj/effect/anomaly/bioscrambler/Initialize(mapload, new_lifespan, drops_core)
	. = ..()
	if(!chests)
		chests = typesof(/obj/item/bodypart/chest)
	if(!heads)
		heads = typesof(/obj/item/bodypart/head)
	if(!l_arms)
		l_arms = typesof(/obj/item/bodypart/arm/left)
	if(!r_arms)
		r_arms = typesof(/obj/item/bodypart/arm/right)
	if(!l_legs)
		l_legs = typesof(/obj/item/bodypart/leg/left)
	if(!r_legs)
		r_legs = typesof(/obj/item/bodypart/leg/right)

/obj/effect/anomaly/bioscrambler/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return

	COOLDOWN_START(src, pulse_cooldown, pulse_delay)

	swap_parts(range)

/obj/effect/anomaly/bioscrambler/proc/swap_parts(swap_range)
	for(var/mob/living/carbon/nearby in range(swap_range, src))
		if(nearby.run_armor_check(attack_flag = BIO, absorb_text = "Your armor protects you from [src]!") >= 100)
			continue //We are protected
		var/picked_zone = pick(zones)
		var/obj/item/bodypart/picked_user_part = nearby.get_bodypart(picked_zone)
		var/obj/item/bodypart/picked_part
		switch(picked_zone)
			if(BODY_ZONE_HEAD)
				picked_part = pick(heads)
			if(BODY_ZONE_CHEST)
				picked_part = pick(chests)
			if(BODY_ZONE_L_ARM)
				picked_part = pick(l_arms)
			if(BODY_ZONE_R_ARM)
				picked_part = pick(r_arms)
			if(BODY_ZONE_L_LEG)
				picked_part = pick(l_legs)
			if(BODY_ZONE_R_LEG)
				picked_part = pick(r_legs)
		var/obj/item/bodypart/new_part = new picked_part()
		new_part.replace_limb(nearby, TRUE)
		if(picked_user_part)
			qdel(picked_user_part)
		nearby.update_body(TRUE)
		balloon_alert(nearby, "something has changed about you")
