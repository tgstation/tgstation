#define STASIS_TOGGLE_COOLDOWN 50
/obj/machinery/electric
	name = "Electric Shock Therapy Unit"
	desc = "A not so comfortable looking bed with some nozzles at the top and bottom. It will shock the buckled person after 10 seconds."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "electric"
	density = FALSE
	can_buckle = TRUE
	buckle_lying = 90
	circuit = /obj/item/circuitboard/machine/stasis
	idle_power_usage = 40
	active_power_usage = 340
	fair_market_price = 10
	payment_department = ACCOUNT_MED
	var/electric_enabled = TRUE
	var/last_stasis_sound = FALSE
	var/electric_can_toggle = 0
	var/mattress_state = "electric_on"
	var/safety = TRUE
	var/obj/effect/overlay/vis/mattress_on

/obj/machinery/electric/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to [electric_enabled ? "turn off" : "turn on"] the machine.</span>"
	if(!safety)
		. += "<span class='danger'>the maintenance panel looks heavily damaged, and wiring messed up!</span>"

/obj/machinery/electric/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		var/sound_freq = rand(5120, 8800)
		if(_running)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)
		last_stasis_sound = _running

/obj/machinery/electric/AltClick(mob/user)
	if(world.time >= electric_can_toggle && user.canUseTopic(src, !issilicon(user)))
		electric_enabled = !electric_enabled
		electric_can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
		playsound(src, 'sound/machines/click.ogg', 60, TRUE)
		play_power_sound()
		update_icon()

/obj/machinery/electric/proc/stasis_running()
	return electric_enabled && is_operational()

/obj/machinery/electric/update_icon_state()
	if(stat & BROKEN)
		icon_state = "electric_broken"
		return
	if(panel_open || stat & MAINT)
		icon_state = "electric_maintenance"
		return
	icon_state = "electric"

/obj/machinery/electric/update_overlays()
	. = ..()
	var/_running = stasis_running()
	var/list/overlays_to_remove = managed_vis_overlays

	if(mattress_state)
		if(!mattress_on || !managed_vis_overlays)
			mattress_on = SSvis_overlays.add_vis_overlay(src, icon, mattress_state, layer, plane, dir, alpha = 0, unique = TRUE)

		if(mattress_on.alpha ? !_running : _running) //check the inverse of _running compared to truthy alpha, to see if they differ
			var/new_alpha = _running ? 255 : 0
			var/easing_direction = _running ? EASE_OUT : EASE_IN
			animate(mattress_on, alpha = new_alpha, time = 50, easing = CUBIC_EASING|easing_direction)

		overlays_to_remove = managed_vis_overlays - mattress_on

	SSvis_overlays.remove_vis_overlay(src, overlays_to_remove)

/obj/machinery/electric/obj_break(damage_flag)
	. = ..()
	if(.)
		play_power_sound()

/obj/machinery/electric/power_change()
	. = ..()
	play_power_sound()

/obj/machinery/electric/proc/shock_n_heal(mob/living/target)
	if(target != occupant)
		return
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	addtimer(CALLBACK(src, .proc/shock), 10 SECONDS)
	use_power = ACTIVE_POWER_USE

/obj/machinery/electric/proc/shock()
	if(!(istype(occupant,/mob/living/carbon/human) && occupant))
		return
	var/mob/living/carbon/human/H = occupant
	var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
	playsound(src,  'sound/machines/defib_zap.ogg', 50, TRUE, -1)
	new /obj/effect/particle_effect/sparks(get_turf(H))
	if(safety)
		mood.adjustPsychInstability(rand(-5,10))
		H.Jitter(100)
		H.electrocute_act(15,src)
		unbuckle_mob(H)
	else
		mood.adjustPsychInstability(rand(-20,10))
		H.Jitter(100)
		H.electrocute_act(25,src)

/obj/machinery/electric/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	occupant = L
	if(stasis_running() && check_nap_violations())
		shock_n_heal(L)
	update_icon()

/obj/machinery/electric/post_unbuckle_mob(mob/living/L)
	if(L == occupant)
		occupant = null
	update_icon()

/obj/machinery/electric/process()
	if( !( occupant && isliving(occupant) && check_nap_violations() ) )
		use_power = IDLE_POWER_USE
		return

/obj/machinery/electric/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	. |= default_deconstruction_screwdriver(user, "stasis_maintenance", "stasis", I)
	update_icon()

/obj/machinery/electric/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I) || .

/obj/machinery/electric/nap_violation(mob/violator)
	unbuckle_mob(violator, TRUE)

/obj/machinery/electric/attack_robot(mob/user)
	if(Adjacent(user) && occupant)
		unbuckle_mob(occupant)
	else
		..()
#undef STASIS_TOGGLE_COOLDOWN
