#define SPAM_CD (3 SECONDS)
#define ALLOW_EXIT "allow_exit"
#define BLOCK_EXIT "block_exit"
#define SKIP_EXIT null

/obj/machinery/prisongate
	name = "prison gate scanner"
	desc = "A hardlight gate with an ID scanner attached to the side. Good at deterring even the most persistent temporarily embarrassed employee."
	icon = 'icons/obj/machines/sec.dmi'
	icon_state = "prisongate_on"
	/// roughly the same health/armor as an airlock
	max_integrity = 450
	damage_deflection = 30
	armor_type = /datum/armor/machinery_prisongate
	use_power = IDLE_POWER_USE
	power_channel = AREA_USAGE_EQUIP
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 0.03
	anchored = TRUE
	req_one_access = list(ACCESS_BRIG)
	/// dictates whether the gate barrier is up or not
	var/gate_active = TRUE
	COOLDOWN_DECLARE(spam_cooldown_time)

/datum/armor/machinery_prisongate
	melee = 30
	bullet = 30
	laser = 20
	energy = 20
	bomb = 10
	fire = 80
	acid = 70

/obj/machinery/prisongate/power_change()
	. = ..()
	if(!powered())
		visible_message(span_notice("[src] momentarily flickers before the hardlight barrier loses cohesion and dissipates into thin air!"))
		gate_active = FALSE
		flick("prisongate_turningoff", src)
		icon_state = "prisongate_off"
		update_use_power(IDLE_POWER_USE)
	else
		gate_active = TRUE
		visible_message(span_notice("[src] whirrs back to life as its hardlight barrier fills the space between it."))
		flick("prisongate_turningon", src)
		icon_state = "prisongate_on"
		update_use_power(ACTIVE_POWER_USE)

/obj/machinery/prisongate/CanAllowThrough(atom/movable/gate_toucher, border_dir)
	. = ..()
	if(!iscarbon(gate_toucher))
		if(!isstructure(gate_toucher))
			return TRUE
		var/obj/structure/cargobay = gate_toucher
		for(var/mob/living/stowaway in cargobay.contents) //nice try bub
			if(COOLDOWN_FINISHED(src, spam_cooldown_time))
				say("Stowaway detected in internal contents. Access denied.")
				playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, FALSE)
				COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
			return FALSE
	var/mob/living/carbon/the_toucher = gate_toucher
	if(!gate_active)
		return TRUE
	if(allowed(the_toucher))
		if(COOLDOWN_FINISHED(src, spam_cooldown_time))
			say("Brig clearance detected. Access granted.")
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
			COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
		return TRUE

	else if(the_toucher.pulledby && allowed(the_toucher.pulledby))
		if(COOLDOWN_FINISHED(src, spam_cooldown_time))
			say("Brig escort detected. Access granted.")
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
			COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
		return TRUE

	for(var/obj/item/card/id/advanced/prisoner/prison_id in the_toucher.get_all_contents())
		switch(allow_prisoner_id(prison_id))
			if(ALLOW_EXIT)
				return TRUE
			if(BLOCK_EXIT)
				return FALSE

	if(COOLDOWN_FINISHED(src, spam_cooldown_time))
		to_chat(the_toucher, span_warning("You try to push through the hardlight barrier with little effect."))
		COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
	return FALSE

/obj/machinery/prisongate/proc/allow_prisoner_id(obj/item/card/id/advanced/prisoner/prison_id)
	if(!prison_id.timed)
		return SKIP_EXIT
	if(prison_id.time_to_assign)
		say("Prison ID with active sentence detected. Please enjoy your stay in our corporate rehabilitation center, [prison_id.registered_name]!")
		playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
		prison_id.time_left = prison_id.time_to_assign
		prison_id.time_to_assign = initial(prison_id.time_to_assign)
		prison_id.start_timer()
		return ALLOW_EXIT
	if(prison_id.time_left <= 0)
		say("Prison ID with served sentence detected. Access granted.")
		prison_id.timed = FALSE //disables the id check from earlier so you can't just throw it back into perma for mass escapes
		playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
		return ALLOW_EXIT
	if(COOLDOWN_FINISHED(src, spam_cooldown_time))
		say("Prison ID with ongoing sentence detected. Access denied.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, FALSE)
		COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
	return BLOCK_EXIT

/obj/machinery/prisongate/labour
	name = "labor camp gate scanner"

/obj/machinery/prisongate/labour/allow_prisoner_id(obj/item/card/id/advanced/prisoner/prison_id)
	if(!prison_id.goal)
		return SKIP_EXIT
	if(prison_id.points >= prison_id.goal)
		if(COOLDOWN_FINISHED(src, spam_cooldown_time))
			say("All points served. Access granted.")
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
			COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
		return ALLOW_EXIT
	if(COOLDOWN_FINISHED(src, spam_cooldown_time))
		say("[prison_id.goal - prison_id.points] point\s remaining on sentence. Access denied.")
		playsound(src, 'sound/machines/buzz/buzz-two.ogg', 50, FALSE)
		COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
	return BLOCK_EXIT

#undef SPAM_CD
