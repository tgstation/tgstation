
/obj/effect/timestop
	anchored = TRUE
	name = "chronofield"
	desc = "ZA WARUDO"
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	pixel_x = -64
	pixel_y = -64
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/list/immune = list() // the one who creates the timestop is immune
	var/turf/target
	var/freezerange = 2
	var/duration = 140
	var/datum/proximity_monitor/advanced/timestop/chronofield
	alpha = 125

/obj/effect/timestop/Initialize(mapload, radius, time, list/immune_atoms, start = TRUE)	//Immune atoms assoc list atom = TRUE
	. = ..()
	if(immune_atoms)
		immune = immune_atoms.Copy()
	if(!isnull(time))
		duration = time
	if(!isnull(radius))
		freezerange = radius
	for(var/mob/living/L in GLOB.player_list)
		if(locate(/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop) in L.mind.spell_list) //People who can stop time are immune to its effects
			immune[L] = TRUE
	if(start)
		timestop()

/obj/effect/timestop/Destroy()
	qdel(chronofield)
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, TRUE, frequency = -1) //reverse!
	return ..()

/obj/effect/timestop/proc/timestop()
	target = get_turf(src)
	playsound(src, 'sound/magic/timeparadox2.ogg', 75, 1, -1)
	chronofield = make_field(/datum/proximity_monitor/advanced/timestop, list("current_range" = freezerange, "host" = src, "immune" = immune))
	QDEL_IN(src, duration)

/obj/effect/timestop/wizard
	duration = 100

/datum/proximity_monitor/advanced/timestop
	name = "chronofield"
	setup_field_turfs = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	requires_processing = TRUE
	var/list/immune = list()
	var/list/mob/living/frozen_mobs = list()
	var/list/obj/item/projectile/frozen_projectiles = list()
	var/list/atom/movable/frozen_throws = list()

/datum/proximity_monitor/advanced/timestop/Destroy()
	unfreeze_all()
	return ..()

/datum/proximity_monitor/advanced/timestop/field_turf_crossed(atom/movable/AM)
	freeze_atom(AM)

/datum/proximity_monitor/advanced/timestop/proc/freeze_atom(atom/movable/A)
	if(immune[A] || !istype(A))
		return FALSE
	if(A.throwing)
		freeze_throwing(A)
	if(isliving(A))
		freeze_mob(A)
	else if(istype(A, /obj/item/projectile))
		freeze_projectile(A)
	else
		return FALSE
	return TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_all()
	for(var/i in frozen_projectiles)
		unfreeze_projectile(i)
	for(var/i in frozen_mobs)
		unfreeze_mob(i)
	for(var/i in frozen_throws)
		unfreeze_throw(i)

/datum/proximity_monitor/advanced/timestop/proc/freeze_throwing(atom/movable/AM)
	var/datum/thrownthing/T = AM.throwing
	T.paused = TRUE
	frozen_throws[AM] = T

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_throw(atom/movable/AM)
	var/datum/thrownthing/T = frozen_throws[AM]
	T.paused = FALSE
	frozen_throws -= AM

/datum/proximity_monitor/advanced/timestop/process()
	for(var/i in frozen_mobs)
		var/mob/living/m = i
		if(get_dist(get_turf(m), get_turf(host)) > current_range)
			unfreeze_mob(m)
		else
			m.Stun(20, 1, 1)

/datum/proximity_monitor/advanced/timestop/setup_field_turf(turf/T)
	for(var/i in T.contents)
		freeze_atom(i)
	return ..()

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_projectile(obj/item/projectile/P)
	frozen_projectiles -= P
	P.paused = FALSE

/datum/proximity_monitor/advanced/timestop/proc/freeze_projectile(obj/item/projectile/P)
	frozen_projectiles[P] = TRUE
	P.paused = TRUE

/datum/proximity_monitor/advanced/timestop/proc/freeze_mob(mob/living/L)
	L.Stun(20, 1, 1)
	frozen_mobs[L] = L.anchored
	L.anchored = TRUE
	if(ishostile(L))
		var/mob/living/simple_animal/hostile/H = L
		H.toggle_ai(AI_OFF)
		H.LoseTarget()

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_mob(mob/living/L)
	L.AdjustStun(-20, 1, 1)
	L.anchored = frozen_mobs[L]
	frozen_mobs -= L
	if(ishostile(L))
		var/mob/living/simple_animal/hostile/H = L
		H.toggle_ai(initial(H.AIStatus))
