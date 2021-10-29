#define SCANNER_VERBOSE 1
/obj/machinery/stasissleeper
	name = "lifeform stasis unit"
	desc = "A somewhat comfortable looking bed with a cover over it. It will keep someone in stasis."
	icon = 'modular_skyrat/modules/stasisrework/icons/obj/machines/stasissleeper.dmi'
	icon_state = "sleeper"
	base_icon_state = "sleeper"
	density = FALSE
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/stasissleeper
	idle_power_usage = 40
	active_power_usage = 340
	var/enter_message = "<span class='notice'><b>You feel cool air surround you. You go numb as your senses turn inward.<b></span>"
	var/last_stasis_sound = FALSE
	fair_market_price = 10
	payment_department = ACCOUNT_MED

/obj/machinery/stasissleeper/Destroy()
	. = ..()

/obj/machinery/stasissleeper/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to [state_open ? "close" : "open"] the machine.</span>"
	. += "<span class='notice'>A light blinking on the side indicates that it is [occupant ? "occupied" : "vacant"].</span>"
	. += "<span class='notice'>It has a screen on the side displaying the vitals of the occupant. Interact to read it.</span>"

/obj/machinery/stasissleeper/open_machine()
	if(!state_open && !panel_open)
		if(occupant)
			thaw_them(occupant)
			play_power_sound()
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		flick("[initial(icon_state)]-anim", src)
		..()

/obj/machinery/stasissleeper/close_machine(mob/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		flick("[initial(icon_state)]-anim", src)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(occupant)
			play_power_sound()
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(mob_occupant, "[enter_message]")

/obj/machinery/stasissleeper/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		var/sound_freq = rand(5120, 8800)
		if(!(_running))
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)
		last_stasis_sound = _running

/obj/machinery/stasissleeper/AltClick(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	if(!panel_open)
		user.visible_message("<span class='notice'>\The [src] [state_open ? "hisses as it seals shut." : "hisses as it swings open."].</span>", \
						"<span class='notice'>You [state_open ? "close" : "open"] \the [src].</span>", \
						"<span class='hear'>You hear a nearby machine [state_open ? "seal shut." : "swing open."].</span>")
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/stasissleeper/Exited(atom/movable/AM, atom/newloc)
	if(!state_open && AM == occupant)
		container_resist_act(AM)
	. = ..()

/obj/machinery/stasissleeper/container_resist_act(mob/living/user)
	visible_message("<span class='notice'>[occupant] emerges from [src]!</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()
	if(IS_IN_STASIS(user))
		thaw_them(user)

/obj/machinery/stasissleeper/proc/stasis_running()
	return !(state_open) && is_operational

/obj/machinery/stasissleeper/update_icon_state()
	icon_state = "[occupant ? "o-" : null][base_icon_state][state_open ? "-open" : null]"
	return ..()

/obj/machinery/stasissleeper/power_change()
	. = ..()
	play_power_sound()

/obj/machinery/stasissleeper/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	ADD_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	target.extinguish_mob()
	use_power = ACTIVE_POWER_USE

/obj/machinery/stasissleeper/proc/thaw_them(mob/living/target)
	target.remove_status_effect(STATUS_EFFECT_STASIS, STASIS_MACHINE_EFFECT)
	REMOVE_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	if(target == occupant)
		use_power = IDLE_POWER_USE


/obj/machinery/stasissleeper/process()
	if( !( occupant && isliving(occupant) && check_nap_violations() ) )
		use_power = IDLE_POWER_USE
		return
	var/mob/living/L_occupant = occupant
	if(stasis_running())
		if(!IS_IN_STASIS(L_occupant))
			chill_out(L_occupant)
	else if(IS_IN_STASIS(L_occupant))
		thaw_them(L_occupant)

/obj/machinery/stasissleeper/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is currently occupied!</span>")
		return
	if(state_open)
		to_chat(user, "<span class='warning'>[src] must be closed to [panel_open ? "close" : "open"] its maintenance hatch!</span>")
		return
	default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I)

/obj/machinery/stasissleeper/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	default_change_direction_wrench(user, I)

/obj/machinery/stasissleeper/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_pry_open(I))
		return TRUE
	default_deconstruction_crowbar(I)

/obj/machinery/stasissleeper/default_pry_open(obj/item/I)
	if(occupant)
		thaw_them(occupant)
	. = !(state_open || panel_open || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open [src].</span>", "<span class='notice'>You pry open [src].</span>")
		open_machine()

/obj/machinery/stasissleeper/attack_hand(mob/user)
	if(occupant)
		if(occupant == user)
			to_chat(user, "<span class='notice'>You read the vitals readout on the inside of the stasis unit.</span>")
		else
			to_chat(user, "<span class='notice'>You read the vitals readout on the side of the stasis unit.</span>")
		healthscan(user, occupant, SCANNER_VERBOSE, TRUE)
	else
		to_chat(user, "<span class='warning'>The vitals readout is blank, the stasis unit is unoccupied!</span>")

/obj/machinery/stasissleeper/attack_hand_secondary(mob/user)
	if(occupant)
		if(occupant == user)
			to_chat(user, "<span class='notice'>You read the bloodstream readout on the inside of the stasis unit.</span>")
		else
			to_chat(user, "<span class='notice'>You read the bloodstream readout on the side of the stasis unit.</span>")
		chemscan(user, occupant)
	else
		to_chat(user, "<span class='warning'>The bloodstream readout is blank, the stasis unit is unoccupied!</span>")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/stasissleeper/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/stasissleeper/attack_robot(mob/user)
	attack_hand(user)

/obj/machinery/stasissleeper/attack_ai_secondary(mob/user) // this works for borgs and ais shrug
	attack_hand_secondary(user)

#undef SCANNER_VERBOSE
