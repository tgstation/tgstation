/datum/action/cooldown/spell/conjure/void_conduit
	name = "Void Conduit"
	desc = "Opens a gate to the Void; it releases an intermittent pulse that damages windows and airlocks, \
		while afflicting Heathens with void chill. \
		Affected Heretics instead receive low pressure resistance."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "void_rift"

	cooldown_time = 1 MINUTES

	sound = null
	school = SCHOOL_FORBIDDEN
	invocation = "MBR'C' TH' V''D!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/structure/void_conduit)
	summon_respects_density = TRUE
	summon_respects_prev_spawn_points = TRUE

/obj/structure/void_conduit
	name = "Void Conduit"
	desc = "An open gate which leads to nothingness. Releases pulses which you do not want to get hit by."
	icon = 'icons/effects/effects.dmi'
	icon_state = "void_conduit"
	anchored = TRUE
	density = TRUE
	///Overlay to apply to the tiles in range of the conduit
	var/static/image/void_overlay = image(icon = 'icons/turf/overlays.dmi', icon_state = "voidtile")
	///List of tiles that we added an overlay to, so we can clear them when the conduit is deleted
	var/list/overlayed_turfs = list()
	///How many tiles far our effect is
	var/effect_range = 8
	///id of the deletion timer
	var/timerid
	///Audio loop for the rift being alive
	var/datum/looping_sound/void_conduit/soundloop

/obj/structure/void_conduit/Initialize(mapload)
	. = ..()
	soundloop = new(src, start_immediately = TRUE)
	timerid = QDEL_IN_STOPPABLE(src, 1 MINUTES)
	START_PROCESSING(SSobj, src)
	build_view_turfs()

/obj/structure/void_conduit/proc/build_view_turfs()
	for(var/turf/affected_turf as anything in overlayed_turfs)
		affected_turf.cut_overlay(void_overlay)
	for(var/turf/affected_turf as anything in view(effect_range, src))
		if(!isopenturf(affected_turf))
			continue
		affected_turf.add_overlay(void_overlay)
		overlayed_turfs += affected_turf
		void_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		void_overlay.alpha = 180

/obj/structure/void_conduit/Destroy(force)
	QDEL_NULL(soundloop)
	deltimer(timerid)
	STOP_PROCESSING(SSobj, src)
	for(var/turf/affected_turf as anything in overlayed_turfs) //If the portal is moved, the overlays don't stick around
		affected_turf.cut_overlay(void_overlay)
	return ..()

/obj/structure/void_conduit/process(seconds_per_tick)
	build_view_turfs()
	do_conduit_pulse()

///Sends out a pulse
/obj/structure/void_conduit/proc/do_conduit_pulse()
	var/list/turfs_to_affect = list()
	for(var/turf/affected_turf as anything in view(effect_range, loc))
		var/distance = get_dist(loc, affected_turf)
		if(!turfs_to_affect["[distance]"])
			turfs_to_affect["[distance]"] = list()
		turfs_to_affect["[distance]"] += affected_turf

	for(var/distance in 0 to effect_range)
		if(!turfs_to_affect["[distance]"])
			continue
		addtimer(CALLBACK(src, PROC_REF(handle_effects), turfs_to_affect["[distance]"]), (1 SECONDS) * distance)

	new /obj/effect/temp_visual/circle_wave/void_conduit(get_turf(src))

///Applies the effects of the pulse "hitting" something. Freezes non-heretic, destroys airlocks/windows
/obj/structure/void_conduit/proc/handle_effects(list/turfs)
	for(var/turf/affected_turf as anything in turfs)
		for(var/atom/thing_to_affect as anything in affected_turf.contents)

			if(isliving(thing_to_affect))
				var/mob/living/affected_mob = thing_to_affect
				if(affected_mob.can_block_magic(MAGIC_RESISTANCE))
					continue
				if(IS_HERETIC_OR_MONSTER(affected_mob) || HAS_TRAIT(affected_mob, TRAIT_MANSUS_TOUCHED))
					affected_mob.apply_status_effect(/datum/status_effect/void_conduit)
				else
					affected_mob.apply_status_effect(/datum/status_effect/void_chill, 1)

			if(istype(thing_to_affect, /obj/machinery/door) || istype(thing_to_affect, /obj/structure/door_assembly))
				var/obj/affected_door = thing_to_affect
				affected_door.take_damage(rand(15, 30))

			if(istype(thing_to_affect, /obj/structure/window) || istype(thing_to_affect, /obj/structure/grille))
				var/obj/structure/affected_structure = thing_to_affect
				affected_structure.take_damage(rand(10, 20))

/datum/looping_sound/void_conduit
	mid_sounds = 'sound/ambience/misc/ambiatm1.ogg'
	mid_length = 1 SECONDS
	extra_range = 10
	volume = 40
	falloff_distance = 5
	falloff_exponent = 20

/datum/status_effect/void_conduit
	id = "void_conduit"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/void_conduit/on_apply()
	ADD_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/void_conduit/on_remove()
	REMOVE_TRAIT(owner, TRAIT_RESISTLOWPRESSURE, TRAIT_STATUS_EFFECT(id))
