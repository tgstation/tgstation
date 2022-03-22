#define SPAM_CD 3 SECONDS

/obj/machinery/prisongate
	name = "prison gate scanner"
	desc = "A hardlight gate with an ID scanner attached to the side. Good at deterring even the most persistent temporarily embarrassed employee."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "prisongate_on"
	/// roughly the same health/armor as an airlock
	max_integrity = 450
	damage_deflection = 30
	armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 100, FIRE = 80, ACID = 70)
	use_power = IDLE_POWER_USE
	power_channel = AREA_USAGE_EQUIP
	idle_power_usage = 5
	active_power_usage = 30
	anchored = TRUE
	/// dictates whether the gate barrier is up or not
	var/gate_active = TRUE
	COOLDOWN_DECLARE(spam_cooldown_time)

/obj/machinery/prisongate/power_change()
	. = ..()
	if(!powered())
		visible_message(span_notice("[src] momentarily flickers before the hardlight barrier loses cohesion and dissipates into thin air!"))
		gate_active = FALSE
		flick("prisongate_turningoff", src)
		icon_state = "prisongate_off"
	else
		gate_active = TRUE
		visible_message(span_notice("[src] whirrs back to life as its hardlight barrier fills the space between it."))
		flick("prisongate_turningon", src)
		icon_state = "prisongate_on"

/obj/machinery/prisongate/CanAllowThrough(atom/movable/gate_toucher, border_dir)
	. = ..()
	if(!iscarbon(gate_toucher))
		if(!isstructure(gate_toucher))
			return TRUE
		var/obj/structure/cargobay = gate_toucher
		for(var/mob/living/stowaway in cargobay.contents) //nice try bub
			if(COOLDOWN_FINISHED(src, spam_cooldown_time))
				say("Stowaway detected in internal contents. Access denied.")
				playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
				COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
			return FALSE
	var/mob/living/carbon/the_toucher = gate_toucher
	if(gate_active == FALSE)
		return TRUE
	for(var/obj/item/card/id/regular_id in the_toucher.get_all_contents())
		var/list/id_access = regular_id.GetAccess()
		if(ACCESS_BRIG in id_access)
			if(COOLDOWN_FINISHED(src, spam_cooldown_time))
				say("Brig clearance detected. Access granted.")
				playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
				COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
			return TRUE
	for(var/obj/item/card/id/advanced/prisoner/prison_id in the_toucher.get_all_contents())
		if(!prison_id.timed)
			continue
		if(prison_id.time_to_assign)
			say("Prison ID with active sentence detected. Please enjoy your stay in our corporate rehabilitation center, [prison_id.registered_name]!")
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
			prison_id.time_left = prison_id.time_to_assign
			prison_id.time_to_assign = initial(prison_id.time_to_assign)
			prison_id.start_timer()
			return TRUE
		if(prison_id.time_left <= 0)
			say("Prison ID with served sentence detected. Access granted.")
			prison_id.timed = FALSE //disables the id check from earlier so you can't just throw it back into perma for mass escapes
			playsound(src, 'sound/machines/chime.ogg', 50, FALSE)
			return TRUE
		if(COOLDOWN_FINISHED(src, spam_cooldown_time))
			say("Prison ID with ongoing sentence detected. Access denied.")
			playsound(src, 'sound/machines/buzz-two.ogg', 50, FALSE)
			COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
		return FALSE
	if(COOLDOWN_FINISHED(src, spam_cooldown_time))
		to_chat(the_toucher, span_warning("You try to push through the hardlight barrier with little effect."))
		COOLDOWN_START(src, spam_cooldown_time, SPAM_CD)
	return FALSE

#undef SPAM_CD
