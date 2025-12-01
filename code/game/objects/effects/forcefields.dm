/obj/effect/forcefield
	name = "FORCEWALL"
	desc = "A space wizard's magic wall."
	icon_state = "m_shield"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	/// If set, how long the force field lasts after it's created. Set to 0 to have infinite duration forcefields.
	var/initial_duration = 30 SECONDS

/obj/effect/forcefield/Initialize(mapload)
	. = ..()
	if(initial_duration > 0 SECONDS)
		QDEL_IN(src, initial_duration)

/obj/effect/forcefield/singularity_pull(atom/singularity, current_size)
	return

/// The wizard's forcefield, summoned by forcewall
/obj/effect/forcefield/wizard
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// A weakref to whoever casted our forcefield.
	var/datum/weakref/caster_weakref

/obj/effect/forcefield/wizard/Initialize(mapload, mob/caster, flags = MAGIC_RESISTANCE)
	. = ..()
	if(caster)
		caster_weakref = WEAKREF(caster)
	antimagic_flags = flags

/obj/effect/forcefield/wizard/CanAllowThrough(atom/movable/mover, border_dir)
	if(IS_WEAKREF_OF(mover, caster_weakref))
		return TRUE
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
			return TRUE

	return ..()

/// Cult forcefields
/obj/effect/forcefield/cult
	name = "glowing wall"
	desc = "An unholy shield that blocks all attacks."
	icon = 'icons/effects/cult.dmi'
	icon_state = "cultshield"
	can_atmos_pass = ATMOS_PASS_NO
	initial_duration = 20 SECONDS

/// A form of the cult forcefield that lasts permanently.
/// Used on the Shuttle 667.
/obj/effect/forcefield/cult/permanent
	initial_duration = 0

/// Mime forcefields (invisible walls)

/obj/effect/forcefield/mime
	icon_state = "nothing"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	alpha = 0

/obj/effect/forcefield/mime/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_MOUSEDROPPED_ONTO = PROC_REF(mousedrop_receive),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/forcefield/mime/proc/mousedrop_receive(atom/source, atom/movable/dropped, mob/user, params)
	SIGNAL_HANDLER
	// Reroute the call to ourselves so leanable component can trigger
	if (dropped == user)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, mouse_drop_receive), dropped, user, params)
		return COMPONENT_CANCEL_MOUSEDROPPED_ONTO

/obj/effect/forcefield/mime/mouse_drop_receive(mob/living/dropping, mob/user, params)
	. = ..()
	LoadComponent(/datum/component/leanable, dropping)

/obj/effect/forcefield/mime/advanced
	name = "invisible blockade"
	desc = "You're gonna be here awhile."
	initial_duration = 1 MINUTES

/// Psyker forcefield
/obj/effect/forcefield/psychic
	name = "psychic forcefield"
	desc = "A wall of psychic energy powerful enough stop the motion of objects. Projectiles ricochet."
	icon_state = "psychic"
	can_atmos_pass = ATMOS_PASS_YES
	flags_ricochet = RICOCHET_SHINY | RICOCHET_HARD
	receive_ricochet_chance_mod = INFINITY //we do ricochet a lot!
	initial_duration = 10 SECONDS

GLOBAL_LIST_EMPTY_TYPED(active_cosmic_fields, /obj/effect/forcefield/cosmic_field)

/// The cosmic heretics forcefield
/obj/effect/forcefield/cosmic_field
	name = "Cosmic Field"
	desc = "A field that cannot be passed by people marked with a cosmic star."
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "cosmic_carpet"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	layer = GIB_LAYER
	density = FALSE
	can_atmos_pass = ATMOS_PASS_NO
	initial_duration = 30 SECONDS
	/// Flags for what antimagic can just ignore our forcefields
	var/antimagic_flags = MAGIC_RESISTANCE
	/// If we are able to slow down projectiles
	var/slows_projectiles = FALSE

/obj/effect/forcefield/cosmic_field/Initialize(mapload, flags = MAGIC_RESISTANCE)
	. = ..()
	antimagic_flags = flags
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_loc_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	// Make sure that if we create a field, we apply whatever effects
	for(var/atom/movable/thing in get_turf(src))
		on_entered(src, thing)

/obj/effect/forcefield/cosmic_field/Destroy(force)
	// Make sure when the field goes away that the effects don't persist
	for(var/atom/movable/thing in get_turf(src))
		on_loc_exited(src, thing)
	GLOB.active_cosmic_fields -= src
	return ..()

/obj/effect/forcefield/cosmic_field/CanAllowThrough(atom/movable/mover, border_dir)
	if(!isliving(mover))
		return ..()
	var/mob/living/living_mover = mover
	if(living_mover.can_block_magic(antimagic_flags, charge_cost = 0))
		return ..()
	// Being buckled/pulled by a cosmic heretic will allow you through cosmic fields EVEN IF you have a star mark
	if(ismob(living_mover.buckled))
		var/mob/living/fireman = living_mover.buckled
		if(fireman.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
			return ..()
	if(living_mover.pulledby?.has_status_effect(/datum/status_effect/heretic_passive/cosmic))
		return ..()
	if(living_mover.has_status_effect(/datum/status_effect/star_mark))
		return FALSE
	return ..()

/obj/effect/forcefield/cosmic_field/proc/on_entered(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(isprojectile(thing) && slows_projectiles)
		var/obj/projectile/bullet = thing
		if(istype(bullet, /obj/projectile/magic/star_ball)) // Don't slow down star balls
			return
		bullet.speed *= 0.2 // 80% Slowdown
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return
	living_mover.add_movespeed_modifier(/datum/movespeed_modifier/cosmic_field)

/obj/effect/forcefield/cosmic_field/proc/on_loc_exited(datum/source, atom/movable/thing)
	SIGNAL_HANDLER
	if(isprojectile(thing) && slows_projectiles)
		var/obj/projectile/bullet = thing
		if(istype(bullet, /obj/projectile/magic/star_ball)) // Don't speed up star balls
			return
		bullet.speed /= 0.2 // 80% Slowdown
		return

	if(!isliving(thing))
		return
	var/mob/living/living_mover = thing
	var/datum/status_effect/heretic_passive/cosmic/cosmic_passive = living_mover.has_status_effect(/datum/status_effect/heretic_passive/cosmic)
	if(!cosmic_passive)
		return
	living_mover.remove_movespeed_modifier(/datum/movespeed_modifier/cosmic_field)

/// Adds the ability to slow down any projectiles that enters any turf we occupy
/obj/effect/forcefield/cosmic_field/proc/slows_projectiles()
	slows_projectiles = TRUE

/// Adds our cosmic field to the global list which bombs check to see if they have to stop exploding
/obj/effect/forcefield/cosmic_field/proc/prevents_explosions()
	GLOB.active_cosmic_fields += src

/datum/movespeed_modifier/cosmic_field
	multiplicative_slowdown = -0.25

/obj/effect/forcefield/cosmic_field/star_blast
	initial_duration = 5 SECONDS

/obj/effect/forcefield/cosmic_field/star_touch
	initial_duration = 30 SECONDS

/obj/effect/forcefield/cosmic_field/fast
	initial_duration = 5 SECONDS

/obj/effect/forcefield/cosmic_field/extrafast
	initial_duration = 2.5 SECONDS
