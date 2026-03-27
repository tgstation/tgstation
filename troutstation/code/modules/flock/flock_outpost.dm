#define FLOCK_OUTPOST_DEFAULT_ATMOS GAS_N2 + "=100;TEMP=200"
#define FLOCK_OUTPOST_VOID_LIGHT_COLOR "#ace5c6"
#define FLOCK_OUTPOST_LIGHT_COLOR "#b8ece4" // a very faint teal

// TEMPLATE DEFINITION STUFF
/datum/lazy_template/flock_outpost
	key = LAZY_TEMPLATE_KEY_FLOCK_OUTPOST
	map_name = "flock_outpost"

// AREAS
/area/centcom/flock_outpost
	name = "Flock Outpost"
	desc = "caw caw motherfucker"
	icon = 'troutstation/icons/area/areas_centcom.dmi'
	icon_state = "flock_outpost"
	requires_power = FALSE
	area_flags = NOTELEPORT
	static_lighting = TRUE
	base_lighting_alpha = 0
	default_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	ambience_index = AMBIENCE_FLOCK

// TURFS
// Floors
/turf/open/floor/flock_outpost
	name = "resilient substrate"
	desc = "You are absolutely being watched."
	icon = 'troutstation/icons/turf/floors/flock_outpost_floor.dmi'
	icon_state = "flock_outpost_floor-255"
	baseturfs = /turf/open/floor/flock_outpost/plating
	base_icon_state = "flock_outpost_floor"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FLOCK_OUTPOST
	canSmoothWith = SMOOTH_GROUP_FLOCK_OUTPOST
	footstep = FOOTSTEP_FLOOR
	smoothing_junction = 255
	planetary_atmos = TRUE
	initial_gas_mix = FLOCK_OUTPOST_DEFAULT_ATMOS
	/// Icon for the emissive overlay
	var/emissive_icon = 'troutstation/icons/turf/floors/flock_outpost_floor_e.dmi'
	/// The alpha used for the emissive decal.
	var/emissive_alpha = 20
	/// Do we add an emissive decal at all?
	var/is_emissive = TRUE

/turf/open/floor/flock_outpost/Initialize(mapload)
	. = ..()
	if(is_emissive)
		AddElement(/datum/element/decal, emissive_icon, base_icon_state, dir, EMISSIVE_PLANE, null, emissive_alpha, null, smoothing_junction)

/turf/open/floor/flock_outpost/break_tile()
	return // unbreakable

/turf/open/floor/flock_outpost/burn_tile()
	return // unbreakable

/turf/open/floor/flock_outpost/plating
	name = "underwiring"
	desc = "Exposed nerve and tissue of the outpost superstructure. Strange for it to not be concealed."
	icon = 'troutstation/icons/turf/floors/flock_outpost.dmi'
	icon_state = "plating"
	smoothing_groups = null
	smoothing_flags = NONE
	canSmoothWith = null
	footstep = FOOTSTEP_PLATING
	is_emissive = FALSE

/turf/open/floor/flock_outpost/carpet
	name = "deep carpet"
	desc = "A nice soft carpet that feels better than it looks. The Lords have a little compassion, sometimes."
	icon = 'troutstation/icons/turf/floors/flock_outpost_carpet.dmi'
	icon_state = "flock_outpost_carpet-255"
	base_icon_state = "flock_outpost_carpet"
	smoothing_groups = SMOOTH_GROUP_CARPET_FLOCK_OUTPOST
	canSmoothWith = SMOOTH_GROUP_CARPET_FLOCK_OUTPOST
	footstep = FOOTSTEP_CARPET
	is_emissive = FALSE

/turf/open/floor/flock_outpost/light
	name = "bright glass"
	desc = "A bright surface to illuminate the way."
	icon = 'troutstation/icons/turf/floors/flock_outpost_light_floor.dmi'
	icon_state = "flock_outpost_light_floor-255"
	base_icon_state = "flock_outpost_light_floor"
	smoothing_groups = SMOOTH_GROUP_FLOCK_OUTPOST_LIGHT
	canSmoothWith = SMOOTH_GROUP_FLOCK_OUTPOST_LIGHT
	footstep = FOOTSTEP_FLOOR
	emissive_icon = 'troutstation/icons/turf/floors/flock_outpost_light_floor_e.dmi'
	light_range = 5
	light_power = 1
	light_color = FLOCK_OUTPOST_LIGHT_COLOR

// Walls
/turf/closed/indestructible/flock_outpost
	name = "ultradense substrate panel"
	desc = "Impervious to all known forms of damage. All known forms you can think of, anyway."
	icon = 'troutstation/icons/turf/floors/flock_outpost_wall.dmi'
	icon_state = "flock_outpost_wall-0"
	base_icon_state = "flock_outpost_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FLOCK_OUTPOST_WALL
	canSmoothWith = SMOOTH_GROUP_FLOCK_OUTPOST_WALL
	smoothing_junction = 255
	/// Icon for the emissive overlay
	var/emissive_icon = 'troutstation/icons/turf/floors/flock_outpost_wall_e.dmi'
	/// The alpha used for the emissive decal.
	var/emissive_alpha = 20

/turf/closed/indestructible/flock_outpost/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/decal, emissive_icon, base_icon_state, dir, EMISSIVE_PLANE, null, emissive_alpha, null, smoothing_junction)

/turf/closed/indestructible/flock_outpost_window
	name = "sealed window"
	desc = "Pretty dull weather we're having today. Looks like dots again."
	icon = MAP_SWITCH('troutstation/icons/obj/smooth_structures/flock_outpost_window.dmi', 'troutstation/icons/turf/floors/flock_outpost.dmi')
	icon_state = MAP_SWITCH("flock_outpost_window-0", "window")
	base_icon_state = "flock_outpost_window"
	opacity = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FLOCK_OUTPOST_WINDOW
	canSmoothWith = SMOOTH_GROUP_FLOCK_OUTPOST_WINDOW
	smoothing_junction = 255

/turf/closed/indestructible/flock_outpost_window/Initialize(mapload)
	. = ..()
	underlays += mutable_appearance('troutstation/icons/turf/floors/flock_outpost.dmi', "plating", layer - 0.01, src) //add the plating underlay

/turf/closed/indestructible/flock_outpost_fakedoor
	name = "iris door"
	desc = "You don't think it's unlocking any time soon."
	icon = 'troutstation/icons/obj/doors/flock.dmi'
	icon_state = "outpost_locked"

// The voooooiiid
/turf/open/flock_void
	name = "\proper signal space"
	desc = "The artificial energy subdimension this outpost resides in. Shreds lesser beings."
	icon = 'troutstation/icons/turf/floors/flock_outpost.dmi'
	icon_state = "void"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	layer = SPACE_LAYER
	turf_flags = NOJAUNT | NO_RUST
	light_range = 2
	light_power = 0.6
	light_color = FLOCK_OUTPOST_VOID_LIGHT_COLOR
	var/static/list/forbidden_types = typecacheof(list( // copied from chasm component, these must never be destroyed by this
		/obj/docking_port,
		/obj/effect/abstract,
		/obj/effect/atmos_shield,
		/obj/effect/collapse,
		/obj/effect/constructing_effect,
		/obj/effect/dummy/phased_mob,
		/obj/effect/ebeam,
		/obj/effect/fishing_float,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/light_emitter/tendril,
		/obj/effect/mapping_helpers,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/particle_effect/sparks,
		/obj/effect/portal,
		/obj/effect/projectile,
		/obj/effect/spectre_of_resurrection,
		/obj/effect/temp_visual,
		/obj/effect/wisp,
		/obj/energy_ball,
		/obj/narsie,
		/obj/projectile,
		/obj/singularity,
		/obj/structure/lattice,
		/obj/structure/stone_tile,
		/obj/structure/ore_vent,
	))

/turf/open/flock_void/examine(mob_user)
	. = ..()
	. += span_warning("You'd be dissolved immediately if you somehow walked into this.")

/turf/open/flock_void/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(is_type_in_typecache(arrived, forbidden_types) || (!isliving(arrived) && !isobj(arrived)))
		return
	arrived.visible_message(span_boldwarning("[src] is torn to shreds by the energy of signal space!"),
		span_userdanger("You are instantly torn and subatomically flayed by a raging sea of energy that overwhelms all senses."))
	arrived.dust(force = TRUE)

// OBJS
/obj/machinery/door/flock_outpost
	name = "iris door"
	desc = "Radial-blade doors are in vogue right now. Only 3 reported accidental amputations in the last 267 cycles!"
	icon = 'troutstation/icons/obj/doors/flock.dmi'
	icon_state = "outpost_closed"
	base_icon_state = "outpost"
	can_be_glass = FALSE // ironically
	autoclose = TRUE
	has_access_panel = FALSE
	var/open_sound = 'troutstation/sound/effects/flock/flock_door_open.ogg'
	var/close_sound = 'troutstation/sound/effects/flock/flock_door_close.ogg'

// I am absolutely fucking astounded this needs to be hooked into, what the fuck
/obj/machinery/door/flock_outpost/run_animation(animation, force_type = DEFAULT_DOOR_CHECKS)
	. = ..()
	switch(animation)
		if(DOOR_OPENING_ANIMATION)
			playsound(src, open_sound, 30, TRUE)
		if(DOOR_CLOSING_ANIMATION)
			playsound(src, close_sound, 30, TRUE)

/obj/effect/flock_outpost_light
	name = "luminous orb"
	desc = "A minor automaton. It softly floats and bathes the room in light. Surprisingly stubborn in keeping to its post."
	icon = 'troutstation/icons/obj/flock_outpost.dmi'
	icon_state = "orb"
	anchored = TRUE
	light_range = 6
	light_power = 1
	light_color = FLOCK_OUTPOST_LIGHT_COLOR
	/// Icon for the emissive overlay
	var/emissive_icon = 'troutstation/icons/obj/flock_outpost.dmi'
	/// The alpha used for the emissive decal.
	var/emissive_alpha = 20

/obj/effect/flock_outpost_light/Initialize()
	. = ..()
	AddElement(/datum/element/decal, emissive_icon, "orb_e", dir, EMISSIVE_PLANE, null, emissive_alpha, null, smoothing_junction)
	DO_FLOATING_ANIM(src)

// MACHINERY
////
/obj/machinery/computer/camera_advanced/flock
	name = "Mission Deployment Console"
	desc = "Pick where in the station you want to deploy to using this console."
	icon = 'troutstation/icons/obj/flock_outpost.dmi'
	icon_state = "console"
	icon_keyboard = null
	icon_screen = null
	networks = list(CAMERANET_NETWORK_SS13)
	lock_override = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/machinery/flock_outpost/pod_pad/pad
	var/obj/effect/client_image_holder/flock_pod_drop_marker/marker
	var/actions_created = FALSE

/obj/machinery/computer/camera_advanced/flock/post_machine_initialize()
	. = ..()
	for(var/obj/machinery/flock_outpost/pod_pad/p as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/flock_outpost/pod_pad))
		pad = p
		break

/obj/machinery/computer/camera_advanced/flock/CreateEye()
	. = ..()
	//For observers
	eyeobj.icon = 'icons/mob/eyemob.dmi'
	eyeobj.icon_state = "marker"
	//For the user
	eyeobj.set_user_icon(eyeobj.icon, eyeobj.icon_state)

/obj/machinery/computer/camera_advanced/flock/proc/update_pod_drop_marker()
	if(!marker)
		marker = new(null, current_user)
	if(pad && pad.drop_location)
		marker.forceMove(pad.drop_location)
	else
		marker.moveToNullspace()

/obj/machinery/computer/camera_advanced/flock/give_eye_control(mob/user)
	. = ..()
	update_pod_drop_marker()
	marker.add_seer(user)

/obj/machinery/computer/camera_advanced/flock/remove_eye_control(mob/living/user)
	. = ..()
	update_pod_drop_marker()
	marker.remove_seer(user)

/obj/machinery/computer/camera_advanced/flock/GrantActions(mob/living/carbon/user)
	if(!actions_created)
		actions_created = TRUE
		actions += new /datum/action/innate/set_flockpod_point(src)
	..()

/obj/machinery/computer/camera_advanced/flock/proc/set_drop_point(turf/open/location, user)
	if(!istype(location))
		to_chat(user, span_warning("Unable to drop at specified location."))
		return
	if(pad)
		pad.drop_location = location
		to_chat(user, span_notice("Location marked for drop point."))
		pad.activate()
		update_pod_drop_marker()

/datum/action/innate/set_flockpod_point
	name = "Set Drop Point"
	button_icon = 'troutstation/icons/mob/actions/actions_flock.dmi'
	button_icon_state = "set_pod"

/datum/action/innate/set_flockpod_point/Activate()
	if(!target || !isliving(owner))
		return

	var/mob/eye/camera/remote/remote_eye = owner.remote_control

	var/obj/machinery/computer/camera_advanced/flock/console = target
	console.set_drop_point(remote_eye.loc, owner)

/obj/effect/client_image_holder/flock_pod_drop_marker
	image_icon = 'troutstation/icons/effects/flock.dmi'
	image_state = "pod_marker"
	persist_without_seers = TRUE

/////
/obj/machinery/flock_outpost
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE

/obj/machinery/flock_outpost/pod_pad
	name = "Transport Pod Shaper"
	desc = "Spawns a transport pod when you're ready. Free one-way ticket."
	icon = 'troutstation/icons/obj/flock_outpost.dmi'
	icon_state = "pad"
	var/turf/open/drop_location
	var/activated = FALSE

/obj/machinery/flock_outpost/pod_pad/proc/activate()
	if(activated)
		return
	activated = TRUE
	icon_state = "pad_on"
	spawn_pod()

/obj/machinery/flock_outpost/pod_pad/proc/spawn_pod()
	var/obj/structure/closet/flockpod/pod = new(get_turf(src))
	pod.drop_location = drop_location
	pod.spawner_pad = src
	pod.warp_in()

/obj/machinery/flock_outpost/pod_pad/attack_hand(mob/living/user, list/modifiers)
	if(locate(/obj/structure/closet/flockpod, loc))
		to_chat(user, span_warning("The pad can only manage one pod at a time."))
		return
	if(!drop_location)
		to_chat(user, span_warning("The pad is unresponsive. It has no destination set."))
		return
	to_chat(user, span_notice("Shaping pod. Walk into it and close it by clicking it, once it's ready, to deploy to the landing zone."))
	spawn_pod()

/////
#define FLOCKPOD_COLOR_MATRIX list(1,0,0, 0,1,0, 0,0,1, 0,0,0, 0.52,0.81,0.63)
#define FLOCKPOD_HIDE_COLOR_MATRIX list(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,0, 0.52,0.81,0.63,0)
#define FLOCKPOD_WARP_IN_TIME 3 SECONDS
#define FLOCKPOD_TRANSIT_TIME 6 SECONDS
#define FLOCKPOD_LEAVE_TIME 2 SECONDS

/obj/structure/closet/flockpod
	name = "matter preservation transport capsule"
	desc = "A robust structure designed to keep its contents safe as it traverses through signal and material space with minimal degradation."
	icon = 'troutstation/icons/obj/flock_obj_64x64.dmi'
	icon_state = "pod"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_OBJ_LAYER //So that the crate inside doesn't appear underneath
	allow_objects = TRUE
	allow_dense = TRUE
	delivery_icon = null
	can_weld_shut = FALSE
	armor_type = /datum/armor/closet_supplypod
	anchored = TRUE //So it cant slide around after landing
	anchorable = FALSE
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | LONG_GLIDE
	density = FALSE
	divable = FALSE
	opened = TRUE
	var/turf/open/drop_location
	var/obj/machinery/flock_outpost/pod_pad/spawner_pad
	var/in_transit = FALSE

/obj/structure/closet/flockpod/proc/warp_in()
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_pod_form.ogg', 50, TRUE)
	animate(src, color = FLOCKPOD_HIDE_COLOR_MATRIX, transform = matrix()*2, time = 0)
	animate(color = null, transform = null, time = FLOCKPOD_WARP_IN_TIME, easing = SINE_EASING)

/obj/structure/closet/flockpod/close(mob/living/user)
	. = ..()
	if(drop_location && !in_transit)
		in_transit = TRUE
		transit_out()

/obj/structure/closet/flockpod/proc/transit_out()
	locked = TRUE
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_pod_travel.ogg', 50, TRUE)
	animate(src, color = FLOCKPOD_COLOR_MATRIX, transform = matrix()*2, time = FLOCKPOD_TRANSIT_TIME, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(transit_in)), FLOCKPOD_TRANSIT_TIME)

/obj/structure/closet/flockpod/proc/transit_in()
	forceMove(drop_location)
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_pod_travel.ogg', 50, TRUE)
	animate(src, color = null, transform = null, time = FLOCKPOD_TRANSIT_TIME, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(finish_transit)), FLOCKPOD_TRANSIT_TIME)

/obj/structure/closet/flockpod/proc/finish_transit()
	locked = FALSE
	open(null, TRUE)
	addtimer(CALLBACK(src, PROC_REF(warp_out)), FLOCKPOD_TRANSIT_TIME)

/obj/structure/closet/flockpod/proc/warp_out()
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_pod_disappear.ogg', 50, TRUE)
	animate(src, color = null, transform = null, transform = null, time = 0)
	animate(color = FLOCKPOD_HIDE_COLOR_MATRIX, transform = matrix()*2, time = FLOCKPOD_LEAVE_TIME, easing = SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(post_warp_out)), FLOCKPOD_LEAVE_TIME)

/obj/structure/closet/flockpod/proc/post_warp_out()
	dump_contents() // just in case they managed to crawl in at the last second
	qdel(src)

#undef FLOCKPOD_COLOR_MATRIX
#undef FLOCKPOD_HIDE_COLOR_MATRIX
#undef FLOCKPOD_WARP_IN_TIME
#undef FLOCKPOD_TRANSIT_TIME
#undef FLOCKPOD_LEAVE_TIME

/obj/effect/landmark/flock_agent
	icon = 'troutstation/icons/mob/simple/flock.dmi'
	icon_state = "agent"
	var/position = 0 // ideally have 2 spawn positions

#undef FLOCK_OUTPOST_LIGHT_COLOR
#undef FLOCK_OUTPOST_DEFAULT_ATMOS
#undef FLOCK_OUTPOST_VOID_LIGHT_COLOR
