#define FINAL_BUD_GROWTH_ICON 3
/**
 * Kudzu Flower Bud
 *
 * A flower created by flowering kudzu which spawns a venus human trap after a certain amount of time has passed.
 *
 * A flower created by kudzu with the flowering mutation.  Spawns a venus human trap after 2 minutes under normal circumstances.
 * Also spawns 4 vines going out in diagonal directions from the bud.  Any living creature not aligned with plants is damaged by these vines.
 * Once it grows a venus human trap, the bud itself will destroy itself.
 *
 */
/obj/structure/alien/resin/flower_bud //inheriting basic attack/damage stuff from alien structures
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "bud0"
	layer = SPACEVINE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	opacity = FALSE
	canSmoothWith = null
	smoothing_flags = NONE
	/// The amount of time it takes to create a venus human trap.
	var/growth_time = 120 SECONDS
	var/growth_icon = 0

	/// Used by countdown to check time, this is when the timer will complete and the venus trap will spawn.
	var/finish_time
	/// The countdown ghosts see to when the plant will hatch
	var/obj/effect/countdown/flower_bud/countdown

	var/trait_flags = 0

	var/list/vines = list()

/obj/structure/alien/resin/flower_bud/Initialize(mapload)
	. = ..()
	countdown = new(src)
	var/list/anchors = list()
	anchors += locate(x-2,y+2,z)
	anchors += locate(x+2,y+2,z)
	anchors += locate(x-2,y-2,z)
	anchors += locate(x+2,y-2,z)

	for(var/turf/T in anchors)
		vines += Beam(T, "vine", maxdistance=5, beam_type=/obj/effect/ebeam/vine)
	finish_time = world.time + growth_time
	addtimer(CALLBACK(src, .proc/bear_fruit), growth_time)
	addtimer(CALLBACK(src, .proc/progress_growth), growth_time/4)
	countdown.start()

/obj/structure/alien/resin/flower_bud/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if((trait_flags & SPACEVINE_HEAT_RESISTANT) && damage_type == BURN)
		damage_amount = 0
	. = ..()

/obj/structure/alien/resin/flower_bud/Destroy()
	QDEL_LIST(vines)
	return ..()

/**
 * Spawns a venus human trap, then qdels itself.
 *
 * Displays a message, spawns a human venus trap, then qdels itself.
 */
/obj/structure/alien/resin/flower_bud/proc/bear_fruit()
	visible_message(span_danger("The plant has borne fruit!"))
	var/mob/living/simple_animal/hostile/venus_human_trap/spawned_human_trap = new(get_turf(src))
	if(trait_flags & SPACEVINE_HEAT_RESISTANT)
		spawned_human_trap.unsuitable_heat_damage = 0
	if(trait_flags & SPACEVINE_COLD_RESISTANT)
		spawned_human_trap.unsuitable_cold_damage = 0
	qdel(src)

/obj/structure/alien/resin/flower_bud/proc/progress_growth()
	growth_icon++
	icon_state = "bud[growth_icon]"
	if(growth_icon == FINAL_BUD_GROWTH_ICON)
		return
	addtimer(CALLBACK(src, .proc/progress_growth), growth_time/4)

/obj/effect/ebeam/vine
	name = "thick vine"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A thick vine, painful to the touch."

/obj/effect/ebeam/vine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/ebeam/vine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(isliving(AM))
		var/mob/living/L = AM
		if(!isvineimmune(L))
			L.adjustBruteLoss(5)
			to_chat(L, span_alert("You cut yourself on the thorny vines."))

/**
 * Venus Human Trap
 *
 * The result of a kudzu flower bud, these enemies use vines to drag prey close to them for attack.
 *
 * A carnivorious plant which uses vines to catch and ensnare prey.  Spawns from kudzu flower buds.
 * Each one has a maximum of four vines, which can be attached to a variety of things.  Carbons are stunned when a vine is attached to them, and movable entities are pulled closer over time.
 * Attempting to attach a vine to something with a vine already attached to it will pull all movable targets closer on command.
 * Once the prey is in melee range, melee attacks from the venus human trap heals itself for 10% of its max health, assuming the target is alive.
 * Akin to certain spiders, venus human traps can also be possessed and controlled by ghosts.
 *
 */
/mob/living/simple_animal/hostile/venus_human_trap
	name = "venus human trap"
	desc = "Now you know how the fly feels."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "venus_human_trap"
	health_doll_icon = "venus_human_trap"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	layer = SPACEVINE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	health = 50
	maxHealth = 50
	ranged = TRUE
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 20
	minbodytemp = 100
	combat_mode = TRUE
	ranged_cooldown_time = 4 SECONDS
	del_on_death = TRUE
	deathmessage = "collapses into bits of plant matter."
	attacked_sound = 'sound/creatures/venus_trap_hurt.ogg'
	deathsound = 'sound/creatures/venus_trap_death.ogg'
	attack_sound = 'sound/creatures/venus_trap_hit.ogg'
	unsuitable_heat_damage = 5 // heat damage is different from cold damage since coldmos is significantly more common than plasmafires
	unsuitable_cold_damage = 2 // they now do take cold damage, but this should be sufficiently small that it does not cause major issues
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	/// copied over from the code from eyeballs (the mob) to make it easier for venus human traps to see in kudzu that doesn't have the transparency mutation
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	faction = list("hostile","vines","plants")
	initial_language_holder = /datum/language_holder/venus
	unique_name = TRUE
	/// A list of all the plant's vines
	var/list/vines = list()
	/// The maximum amount of vines a plant can have at one time
	var/max_vines = 4
	/// How far away a plant can attach a vine to something
	var/vine_grab_distance = 5
	/// Whether or not this plant is ghost possessable
	var/playable_plant = TRUE

/mob/living/simple_animal/hostile/venus_human_trap/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	pull_vines()

/mob/living/simple_animal/hostile/venus_human_trap/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	pixel_x = base_pixel_x + (dir & (NORTH|WEST) ? 2 : -2)

/mob/living/simple_animal/hostile/venus_human_trap/AttackingTarget()
	. = ..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat != DEAD)
			adjustHealth(-maxHealth * 0.1)

/mob/living/simple_animal/hostile/venus_human_trap/OpenFire(atom/the_target)
	for(var/datum/beam/B in vines)
		if(B.target == the_target)
			pull_vines()
			ranged_cooldown = world.time + (ranged_cooldown_time * 0.5)
			return
	if(get_dist(src,the_target) > vine_grab_distance || vines.len >= max_vines)
		return
	for(var/turf/T in get_line(src,target))
		if (T.density)
			return
		for(var/obj/O in T)
			if(O.density)
				return

	var/datum/beam/newVine = Beam(the_target, icon_state = "vine", maxdistance = vine_grab_distance, beam_type=/obj/effect/ebeam/vine)
	RegisterSignal(newVine, COMSIG_PARENT_QDELETING, .proc/remove_vine, newVine)
	vines += newVine
	if(isliving(the_target))
		var/mob/living/L = the_target
		L.apply_damage(85, STAMINA, BODY_ZONE_CHEST)
		L.Knockdown(1 SECONDS)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/venus_human_trap/Login()
	. = ..()
	to_chat(src, span_boldwarning("You are a venus human trap!  Protect the kudzu at all costs, and feast on those who oppose you!"))

/mob/living/simple_animal/hostile/venus_human_trap/attack_ghost(mob/user)
	. = ..()
	if(. || !(GLOB.ghost_role_flags & GHOSTROLE_SPAWNER))
		return
	humanize_plant(user)

/mob/living/simple_animal/hostile/venus_human_trap/Destroy()
	for(var/datum/beam/vine as anything in vines)
		qdel(vine) // reference is automatically deleted by remove_vine
	return ..()

/**
 * Sets a ghost to control the plant if the plant is eligible
 *
 * Asks the interacting ghost if they would like to control the plant.
 * If they answer yes, and another ghost hasn't taken control, sets the ghost to control the plant.
 * Arguments:
 * * mob/user - The ghost to possibly control the plant
 */
/mob/living/simple_animal/hostile/venus_human_trap/proc/humanize_plant(mob/user)
	if(key || !playable_plant || stat)
		return
	var/plant_ask = tgui_alert(usr,"Become a venus human trap?", "Are you reverse vegan?", list("Yes", "No"))
	if(plant_ask == "No" || QDELETED(src))
		return
	if(key)
		to_chat(user, span_warning("Someone else already took this plant!"))
		return
	key = user.key
	log_game("[key_name(src)] took control of [name].")

/**
 * Manages how the vines should affect the things they're attached to.
 *
 * Pulls all movable targets of the vines closer to the plant
 * If the target is on the same tile as the plant, destroy the vine
 * Removes any QDELETED vines from the vines list.
 */
/mob/living/simple_animal/hostile/venus_human_trap/proc/pull_vines()
	for(var/datum/beam/B in vines)
		if(istype(B.target, /atom/movable))
			var/atom/movable/AM = B.target
			if(!AM.anchored)
				step(AM, get_dir(AM, src))
		if(get_dist(src, B.target) == 0)
			qdel(B)

/**
 * Removes a vine from the list.
 *
 * Removes the vine from our list.
 * Called specifically when the vine is about to be destroyed, so we don't have any null references.
 * Arguments:
 * * datum/beam/vine - The vine to be removed from the list.
 */
/mob/living/simple_animal/hostile/venus_human_trap/proc/remove_vine(datum/beam/vine)
	SIGNAL_HANDLER

	vines -= vine

#undef FINAL_BUD_GROWTH_ICON
