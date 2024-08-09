/datum/action/cooldown/spell/conjure/void_conduit //XANTODO Clean this shit up afterwards
	name = "Void Conduit"
	desc = "Opens a gate to the Void; it quickly lowers the temperature and pressure of the room while siphoning all gasses. \
		The gate releases an intermittent pulse that damages windows and airlocks, \
		applies a stack of void chill to non heretics, \
		Heretics receive a small heal and are granted the cold resistance and low pressure resistance trait."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "void_rift"

	cooldown_time = 90 SECONDS

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "Conduit!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/void_conduit)
	summon_respects_density = TRUE
	summon_respects_prev_spawn_points = TRUE

/datum/action/cooldown/spell/conjure/void_conduit/cast(atom/cast_on)
	. = ..()

/obj/structure/void_conduit
	name = "Void Conduit"
	desc = "An open gate which leads to nothingness. Pulls in air and energy to release pulses."
	icon = 'icons/effects/effects.dmi'
	icon_state = "void_conduit"
	anchored = TRUE
	density = TRUE
	/////Counter for each process goes up by 1, when it's high enough our conduit will pulse
	//var/conduit_pulse_counter
	///Overlay to apply to the tiles in range of the conduit
	var/static/mutable_appearance/void_overlay = mutable_appearance('icons/turf/overlays.dmi', "voidtile", ABOVE_OPEN_TURF_LAYER)

/obj/structure/void_conduit/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	for(var/turf/affected_turf in RANGE_TURFS(10, src))
		if(!isopenturf(affected_turf))
			continue
		affected_turf.add_overlay(void_overlay)
		void_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		void_overlay.alpha = 180

/obj/structure/void_conduit/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	for(var/turf/affected_turf in RANGE_TURFS(10, src))
		affected_turf.cut_overlay(void_overlay)
	return ..()

/obj/structure/void_conduit/process(seconds_per_tick)
//	var/turf/our_turf = get_turf(src)
//	var/adjacent_turfs = our_turf.get_atmos_adjacent_turfs(alldir = TRUE)
//	for(var/turf/tile in adjacent_turfs)
//		do_conduit_freeze(tile)
	//conduit_pulse_counter++
	//if(conduit_pulse_counter >= 2)
	//	conduit_pulse_counter = 0
	do_conduit_freeze()
	do_conduit_pulse()

///Siphons out the air from the area we are in
/obj/structure/void_conduit/proc/do_conduit_freeze()
	var/area/our_area = get_area(loc)
	if(isnull(our_area))
		return
	var/list/turf_list = our_area.get_turfs_by_zlevel(z)
	if(!islist(turf_list))
		return
	for(var/turf/turf_to_siphon as anything in turf_list)
		var/datum/gas_mixture/environment = turf_to_siphon.return_air()
		turf_to_siphon.remove_air(environment.total_moles() * 0.9)

///Sends out a pulse
/obj/structure/void_conduit/proc/do_conduit_pulse()
	var/list/turfs_to_affect = list()
	for(var/turf/affected_turf as anything in range(10, loc))
		var/distance = get_dist(loc, affected_turf)
		if(!turfs_to_affect["[distance]"])
			turfs_to_affect["[distance]"] = list()
		turfs_to_affect["[distance]"] += affected_turf

	for(var/distance in 0 to 10)
		if(!turfs_to_affect["[distance]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(handle_effects), turfs_to_affect["[distance]"]), (1 SECONDS) * distance)

	new /obj/effect/temp_visual/circle_wave/void_conduit(get_turf(src))

///Applies the effects of the pulse "hitting" something. Freezes non-heretic, destroys airlocks/windows
/obj/structure/void_conduit/proc/handle_effects(list/turfs)
	for(var/mob/living/affected_mob in turfs)
		if(IS_HERETIC(affected_mob))
			affected_mob.apply_status_effect(/datum/status_effect/void_conduit)
		else
			affected_mob.apply_status_effect(/datum/status_effect/void_chill, 1)
	for(var/obj/machinery/door/affected_door in turfs)
		affected_door.take_damage(rand(30, 50))
	for(var/obj/structure/door_assembly/affected_assembly in turfs)
		affected_assembly.take_damage(rand(30, 50))
	for(var/obj/structure/window/affected_window in turfs)
		affected_window.take_damage(rand(10, 20))
	for(var/obj/structure/grille/affected_grille in turfs)
		affected_grille.take_damage(rand(10, 20))

	for(var/turf/affected_turf in turfs)
		var/datum/gas_mixture/environment = affected_turf.return_air()
		environment.temperature *= 0.9
		//var/mutable_appearance/floor_overlay = mutable_appearance('icons/turf/overlays.dmi', "greyOverlay", ABOVE_OPEN_TURF_LAYER)
		//floor_overlay.color = COLOR_RED
		//floor_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		//floor_overlay.alpha = 200
		//affected_turf.flick_overlay_view(floor_overlay, 1 SECONDS)

/datum/status_effect/void_conduit
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/void_conduit/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "void_conduit")
	return TRUE

/datum/status_effect/void_conduit/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, "void_conduit")
