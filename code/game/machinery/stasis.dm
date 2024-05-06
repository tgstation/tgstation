#define STASIS_TOGGLE_COOLDOWN 50
/obj/machinery/stasis
	name = "lifeform stasis unit"
	desc = "A not so comfortable looking bed with some nozzles at the top and bottom. It will keep someone in stasis, and if toggled into \
	high support mode, filter any harmful substances out of their body."
	icon = 'icons/obj/machines/stasis.dmi'
	icon_state = "stasis"
	base_icon_state = "stasis"
	density = FALSE
	obj_flags = BLOCKS_CONSTRUCTION
	can_buckle = TRUE
	buckle_lying = 90
	circuit = /obj/item/circuitboard/machine/stasis
	fair_market_price = 10
	payment_department = ACCOUNT_MED
	interaction_flags_click = ALLOW_SILICON_REACH
	var/stasis_enabled = TRUE
	var/filtering_enabled = FALSE
	var/filtering_efficiency = 1
	var/last_stasis_sound = FALSE
	var/can_toggle = 0
	var/mattress_state = "stasis_on"
	var/obj/effect/overlay/vis/mattress_on

/obj/machinery/stasis/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/elevation, pixel_shift = 6)
	register_context()

/obj/machinery/stasis/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED
	to_chat(user, span_danger("You invert the filtering safeties and remove the thresholds on the stasis unit."))
	if(occupant)
		occupant.add_traits(list(TRAIT_INCAPACITATED, TRAIT_SOFTSPOKEN), STASIS_MACHINE_EFFECT)
	return TRUE

/obj/machinery/stasis/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to [stasis_enabled ? "turn off" : "turn on"] the stasis bed's functions.")
	. += span_notice("Ctrl-click to [filtering_enabled ? "turn off" : "turn on"] the auxilary filtering function. A ridiculously small-print \
		warning label beside the switch only has the words \"DANGER ... SLIME PERSONNEL ... INCREASED POWER ...\" bolded enough to be legible.")
	if(filtering_enabled)
		. += span_notice("Thousands of micro-needles jut up from the mattress.[obj_flags & EMAGGED ? span_danger(" They look thirsty, the filter servos whirring ominously.") : ""]")

/obj/machinery/stasis/add_context(
	atom/source,
	list/context,
	obj/item/held_item,
	mob/living/user,
)
	. = ..()
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Toggle passive blood filtering"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Toggle power"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/stasis/proc/play_power_sound()
	var/_running = stasis_running()
	if(last_stasis_sound != _running)
		var/sound_freq = rand(5120, 8800)
		if(_running)
			playsound(src, 'sound/machines/synth_yes.ogg', 50, TRUE, frequency = sound_freq)
		else
			playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = sound_freq)
		last_stasis_sound = _running

/obj/machinery/stasis/click_alt(mob/user)
	if(world.time < can_toggle)
		return CLICK_ACTION_BLOCKING
	stasis_enabled = !stasis_enabled
	can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
	playsound(src, 'sound/machines/click.ogg', 60, TRUE)
	user.visible_message(span_notice("\The [src] [stasis_enabled ? "powers on" : "shuts down"]."), \
				span_notice("You [stasis_enabled ? "power on" : "shut down"] \the [src]."), \
				span_hear("You hear a nearby machine [stasis_enabled ? "power on" : "shut down"]."))
	play_power_sound()
	update_appearance()
	return CLICK_ACTION_SUCCESS

/// Toggle the filtering function on or off. This makes a bunch of scary-ass needles poke out of the bed.
/// In exchange for having a passive function on hand to filter people's blood, it causes a little bit of damage.
/// This damage only occurs upon initial activation, either through filtering starting by you being buckled or
/// someone activating filtering on the bed you're buckled in already. Malicious doctors or silicons could toggle
/// this over and over while you're helplessly buckled to the bed, though the effect of you being mutilated with
/// needles will be obvious to onlookers.
/obj/machinery/stasis/CtrlClick(mob/user)
	if(!can_interact(user))
		return
	. = ..()
	if(world.time < can_toggle)
		return CLICK_ACTION_BLOCKING
	filtering_enabled = !filtering_enabled
	can_toggle = world.time + STASIS_TOGGLE_COOLDOWN
	if(filtering_enabled)
		var/sound/toggle_sound = sound('sound/items/unsheath.ogg')
		toggle_sound.pitch = 2
		playsound(src, toggle_sound, 60, TRUE,)
	else
		var/sound/toggle_sound = sound('sound/items/sheath.ogg')
		toggle_sound.pitch = 2
		playsound(src, toggle_sound, 60, TRUE,)
	user.visible_message(span_notice("\The [src] filtering function [filtering_enabled ? "powers on. Thousands of micro-needles jut up from the mattress" : "shuts down. The micro-needles shunt back into the mattress invisibly"]."), \
				span_notice("You [filtering_enabled ? "power on" : "shut down"] \the [src] filtering function. [filtering_enabled ? "Thousands of micro-needles jut up from the mattress" : "The micro-needles collapse back into the mattress, invisible"]."), \
				span_hear("You hear [filtering_enabled ? " the unnerving sound of sharpened metal sliding against metal" : " a clunk of something metal"]."))
	update_appearance()
	if(occupant && filtering_enabled)
		filter_jab(occupant, user)
	return CLICK_ACTION_SUCCESS


/obj/machinery/stasis/Exited(atom/movable/gone, direction)
	if(gone == occupant)
		var/mob/living/L = gone
		if(HAS_TRAIT(L, TRAIT_STASIS))
			thaw_them(L)
	return ..()

/obj/machinery/stasis/RefreshParts()
	. = ..()
	for(var/datum/stock_part/servo/servo in component_parts)
		filtering_efficiency = servo.tier
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		filtering_efficiency += filtering_efficiency * (capacitor.tier * 0.25)

/obj/machinery/stasis/proc/stasis_running()
	return stasis_enabled && is_operational

/obj/machinery/stasis/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
		return ..()
	if(panel_open || machine_stat & MAINT)
		icon_state = "[base_icon_state]_maintenance"
		return ..()
	icon_state = base_icon_state
	return ..()

/obj/machinery/stasis/update_overlays()
	. = ..()
	if(!mattress_state)
		return
	var/_running = stasis_running()
	if(!mattress_on)
		mattress_on = SSvis_overlays.add_vis_overlay(src, icon, mattress_state, BELOW_OBJ_LAYER, plane, dir, alpha = 0, unique = TRUE)
	else
		vis_contents += mattress_on
		if(managed_vis_overlays)
			managed_vis_overlays += mattress_on
		else
			managed_vis_overlays = list(mattress_on)

	if(mattress_on.alpha ? !_running : _running) //check the inverse of _running compared to truthy alpha, to see if they differ
		var/new_alpha = _running ? 255 : 0
		var/easing_direction = _running ? EASE_OUT : EASE_IN
		animate(mattress_on, alpha = new_alpha, time = 50, easing = CUBIC_EASING|easing_direction)

/obj/machinery/stasis/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	if(same_z_layer)
		return ..()
	SET_PLANE(mattress_on, PLANE_TO_TRUE(mattress_on.plane), new_turf)
	return ..()

/obj/machinery/stasis/atom_break(damage_flag)
	. = ..()
	if(.)
		play_power_sound()

/obj/machinery/stasis/power_change()
	. = ..()
	play_power_sound()

/obj/machinery/stasis/proc/chill_out(mob/living/target)
	if(target != occupant)
		return
	var/is_emagged = obj_flags & EMAGGED
	var/freq = rand(24750, 26550)
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 2, frequency = freq)
	target.apply_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	ADD_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	if(is_emagged)
		target.add_traits(list(TRAIT_INCAPACITATED, TRAIT_SOFTSPOKEN), STASIS_MACHINE_EFFECT)
	target.extinguish_mob()
	/// Double power usage if we have filtering enabled.
	update_use_power(ACTIVE_POWER_USE * (filtering_enabled ? 2 : 1))

/obj/machinery/stasis/proc/filter_jab(mob/living/target, mob/user)
	target.visible_message(span_danger("The thousands of micro-needles in the [src]'s mattress slide into [target]'s flesh."), \
				span_danger("You feel a sharp jabbing sensation as the needles of the [src] pierce your skin!"), \
				span_hear("You hear a wet squelching sound."))
	target.add_splatter_floor(get_turf(target))
	target.apply_damage(obj_flags & EMAGGED ? 20 : 5, BRUTE, forced = TRUE, spread_damage = TRUE, wound_bonus = CANT_WOUND, attacking_item = src)
	playsound(src, 'sound/surgery/organ2.ogg', 75, falloff_exponent = 1, falloff_distance = 7, pressure_affected = 1)
	if(!HAS_TRAIT(target, TRAIT_ANALGESIA))
		target.emote("scream")
	target.log_message("has been jabbed with the needles of a stasis bed by [key_name(user)]", LOG_ATTACK)

/obj/machinery/stasis/proc/passive_filter(mob/living/target)
	var/is_emagged = obj_flags & EMAGGED
	/// Jelly people shouldn't try to get their blood filtered,
	/// because these things were designed by humans, for humans.
	/// NOBODY should try to get their blood filtered if the machine
	/// is emagged.
	var/onlooker_message
	var/target_message
	if(prob(30))
		play_filtering_sound()
	if(isjellyperson(target) || is_emagged)
		onlooker_message = span_notice("[src] filters [target]'s blood, emitting an ominous whirring noise.")
		target_message = span_danger("[src] filters your blood-- SOMETHING IS WRONG! You feel emptier!")
		target.blood_volume = max(target.blood_volume - (filtering_efficiency * 3), 0)
		if(prob(15))
			target.emote("scream")
	else
		onlooker_message = span_notice("[src] filters [target]'s blood, humming softly.")
		target_message = span_notice("You feel an odd, floaty sensation as [src] filters your blood.")
	target.visible_message(onlooker_message, target_message, span_hear("You hear a wet, squelching, slurping sort of noise."), vision_distance = 1)
	for(var/datum/reagent/to_remove in target.reagents.reagent_list)
		if(is_emagged)
			if(istype(to_remove, /datum/reagent/medicine/))
				target.reagents.remove_reagent(to_remove.type, filtering_efficiency)
				/// If we're emagged, we're going to be a bit more "aggressive" with filtering.
				/// And a bit more forgetful about actually filtering out the right things.
				continue
		if(filtering_efficiency < 3)
			target.reagents.remove_reagent(to_remove.type, filtering_efficiency)
		else
			if(istype(to_remove, /datum/reagent/medicine/))
				continue
			target.reagents.remove_reagent(to_remove.type, filtering_efficiency)

/obj/machinery/stasis/proc/play_filtering_sound()
	var/sound/slurping = sound('sound/effects/wounds/splatter.ogg')
	slurping.pitch = 0.3
	playsound(src, slurping, 50, TRUE, falloff_exponent = 10, pressure_affected = TRUE, ignore_walls = FALSE, falloff_distance = 0)

/obj/machinery/stasis/proc/thaw_them(mob/living/target)
	var/is_emagged = obj_flags & EMAGGED
	target.remove_status_effect(/datum/status_effect/grouped/stasis, STASIS_MACHINE_EFFECT)
	REMOVE_TRAIT(target, TRAIT_TUMOR_SUPPRESSED, TRAIT_GENERIC)
	if(is_emagged)
		target.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_SOFTSPOKEN), STASIS_MACHINE_EFFECT)
	if(target == occupant)
		update_use_power(IDLE_POWER_USE)

/obj/machinery/stasis/user_buckle_mob(mob/living/L, mob/user, check_loc = TRUE)
	. = ..(L, user, check_loc)
	if(. && filtering_enabled)
		filter_jab(L, user)

/obj/machinery/stasis/post_buckle_mob(mob/living/L)
	if(!can_be_occupant(L))
		return
	set_occupant(L)
	if(stasis_running() && check_nap_violations())
		chill_out(L)
	update_appearance()

/obj/machinery/stasis/post_unbuckle_mob(mob/living/L)
	thaw_them(L)
	if(L == occupant)
		set_occupant(null)
	update_appearance()

/obj/machinery/stasis/process()
	if(!(occupant && isliving(occupant) && check_nap_violations()))
		update_use_power(IDLE_POWER_USE)
		return
	var/mob/living/L_occupant = occupant
	if(stasis_running())
		if(!HAS_TRAIT(L_occupant, TRAIT_STASIS))
			chill_out(L_occupant)
		if(filtering_enabled)
			passive_filter(L_occupant)
	else if(HAS_TRAIT(L_occupant, TRAIT_STASIS))
		thaw_them(L_occupant)

/obj/machinery/stasis/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	. |= default_deconstruction_screwdriver(user, "stasis_maintenance", "stasis", I)
	update_appearance()

/obj/machinery/stasis/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	return default_deconstruction_crowbar(I) || .

/obj/machinery/stasis/nap_violation(mob/violator)
	unbuckle_mob(violator, TRUE)

#undef STASIS_TOGGLE_COOLDOWN
