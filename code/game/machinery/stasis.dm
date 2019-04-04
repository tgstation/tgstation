#define STASIS_TOGGLE_COOLDOWN 50
/obj/machinery/stasis
	name = "Lifeform Stasis Unit"
	desc = "A not so comfortable looking bed with some nozzles at the top and bottom. It will keep someone in stasis."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "stasis"
	density = FALSE
	can_buckle = TRUE
	buckle_lying = TRUE
	circuit = /obj/item/circuitboard/machine/stasis
	idle_power_usage = 40
	active_power_usage = 340
	fair_market_price = 10
	payment_department = ACCOUNT_MED
	var/stasis_enabled = TRUE
	var/last_stasis_sound = FALSE
	var/stasis_can_toggle = 0
	var/obj/effect/overlay/vis/mattress_on

/obj/machinery/stasis/Initialize(mapload)
	mattress_on = SSvis_overlays.add_vis_overlay(src, icon, "stasis_on", layer, plane, dir, alpha = 0, unique = TRUE)
	return ..()

/obj/machinery/stasis/examine(mob/user)
	..()
	var/turn_on_or_off = stasis_enabled ? "turn off" : "turn on"
	to_chat(user, "<span class='notice'>Alt-click to [turn_on_or_off] the machine.</span>")

/obj/machinery/stasis/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		if(_running)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = 7056)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = 7056)
		last_stasis_sound = _running

/obj/machinery/stasis/AltClick(mob/user)
	if(world.time >= stasis_can_toggle && user.canUseTopic(src))
		stasis_enabled = !stasis_enabled
		stasis_can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		play_power_sound()
		update_icon()

/obj/machinery/stasis/Exited(atom/movable/AM, atom/newloc)
	if(AM == occupant)
		var/mob/living/L = AM
		if(L.IsInStasis())
			thaw_them(L)
	. = ..()

/obj/machinery/stasis/proc/stasis_running()
	return stasis_enabled && is_operational()

/obj/machinery/stasis/update_icon()
	. = ..()
	var/_running = stasis_running()

	if(mattress_on.alpha ? !_running : _running) //check the inverse of _running compared to truthy alpha, to see if they differ
		var/new_alpha = _running ? 255 : 0
		var/easing_direction = _running ? EASE_OUT : EASE_IN
		animate(mattress_on, alpha = new_alpha, time = 50, easing = CUBIC_EASING|easing_direction)

	if(occupant)
		add_overlay(mutable_appearance('icons/obj/machines/stasis.dmi', "tubes", LYING_MOB_LAYER + 0.1))
	else
		cut_overlay(mutable_appearance('icons/obj/machines/stasis.dmi', "tubes", LYING_MOB_LAYER + 0.1))

	if(stat & BROKEN)
		icon_state = "stasis_broken"
		return
	if(panel_open || stat & MAINT)
		icon_state = "stasis_maintenance"
		return
	icon_state = "stasis"

/obj/machinery/stasis/obj_break(damage_flag)
	. = ..()
	play_power_sound()
	update_icon()

/obj/machinery/stasis/power_change()
	. = ..()
	play_power_sound()
	update_icon()

/obj/machinery/stasis/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.SetStasis(TRUE)
	target.ExtinguishMob()
	use_power = ACTIVE_POWER_USE

/obj/machinery/stasis/proc/thaw_them(mob/living/target)
	target.SetStasis(FALSE)
	if(target == occupant)
		use_power = IDLE_POWER_USE

/obj/machinery/stasis/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	occupant = L
	if(stasis_running() && check_nap_violations())
		chill_out(L)
	update_icon()

/obj/machinery/stasis/post_unbuckle_mob(mob/living/L)
	thaw_them(L)
	if(L == occupant)
		occupant = null
	update_icon()

/obj/machinery/stasis/process()
	if( !( occupant && isliving(occupant) && check_nap_violations() ) )
		use_power = IDLE_POWER_USE
		return
	var/mob/living/L_occupant = occupant
	if(stasis_running())
		if(!L_occupant.IsInStasis())
			chill_out(L_occupant)
	else if(L_occupant.IsInStasis())
		thaw_them(L_occupant)

/obj/machinery/stasis/screwdriver_act(mob/living/user, obj/item/I)
	. = default_deconstruction_screwdriver(user, "stasis_maintenance", "stasis", I)
	update_icon()

/obj/machinery/stasis/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(I)

/obj/machinery/stasis/nap_violation(mob/violator)
	unbuckle_mob(violator, TRUE)
#undef STASIS_TOGGLE_COOLDOWN
