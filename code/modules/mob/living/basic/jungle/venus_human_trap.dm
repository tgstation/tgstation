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
/// Flower bud structure that ghost role spawns, actual spawn logic handled by /obj/effect/mob_spawn/ghost_role/venus_human_trap
/obj/structure/alien/resin/flower_bud //inheriting basic attack/damage stuff from alien structures
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/mob/spacevines.dmi'
	icon_state = "bud0"
	layer = SPACEVINE_MOB_LAYER
	opacity = FALSE
	canSmoothWith = null
	smoothing_flags = NONE
	density = FALSE
	/// The amount of time it takes to create a venus human trap.
	var/growth_time = 120 SECONDS
	var/growth_icon = 0

	/// Used by countdown to check time, this is when the timer will complete and the venus trap will spawn.
	var/finish_time
	/// The countdown ghosts see to when the plant will hatch
	var/obj/effect/countdown/flower_bud/countdown

	var/trait_flags = 0

	var/list/vines = list()

	/// The spawner that actually handles spawning the ghost role in
	var/obj/effect/mob_spawn/ghost_role/venus_human_trap/spawner

/obj/structure/alien/resin/flower_bud/Initialize(mapload)
	. = ..()
	spawner = new(get_turf(loc))
	spawner.flower_bud = src
	countdown = new(src)
	var/list/anchors = list()
	anchors += locate(x-2,y+2,z)
	anchors += locate(x+2,y+2,z)
	anchors += locate(x-2,y-2,z)
	anchors += locate(x+2,y-2,z)

	for(var/turf/T in anchors)
		vines += Beam(T, "vine", maxdistance=5, beam_type=/obj/effect/ebeam/vine)
	finish_time = world.time + growth_time
	addtimer(CALLBACK(src, PROC_REF(bear_fruit)), growth_time)
	addtimer(CALLBACK(src, PROC_REF(progress_growth)), growth_time/4)
	countdown.start()

/obj/structure/alien/resin/flower_bud/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if((trait_flags & SPACEVINE_HEAT_RESISTANT) && damage_type == BURN)
		damage_amount = 0
	. = ..()

/obj/structure/alien/resin/flower_bud/attacked_by(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	LAZYSET(attack_modifiers, SILENCE_DEFAULT_MESSAGES, TRUE)
	LAZYSET(attack_modifiers, FORCE_MULTIPLIER, 1)
	if(item.damtype == BURN)
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 4)
	if(item.get_sharpness())
		MODIFY_ATTACK_FORCE_MULTIPLIER(attack_modifiers, 16) // alien resin applies 75% reduction to brute damage so this actually x4 damage
	return ..()

/obj/structure/alien/resin/flower_bud/Destroy()
	QDEL_LIST(vines)
	QDEL_NULL(countdown)
	if(spawner) // anti harddel checks
		if(!QDELETED(spawner))
			qdel(spawner)
		spawner = null
	return ..()

/// Tells the spawner that the venus human trap is ready
/obj/structure/alien/resin/flower_bud/proc/bear_fruit()
	visible_message(span_danger("The plant has borne fruit!"))
	if(spawner)
		spawner.bear_fruit()

/obj/structure/alien/resin/flower_bud/proc/progress_growth()
	growth_icon++
	icon_state = "bud[growth_icon]"
	if(growth_icon == FINAL_BUD_GROWTH_ICON)
		return
	addtimer(CALLBACK(src, PROC_REF(progress_growth)), growth_time/4)

/obj/structure/alien/resin/flower_bud/attack_ghost(mob/user)
	spawner.attack_ghost(user)

/obj/effect/ebeam/vine
	name = "thick vine"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A thick vine, painful to the touch."

/obj/effect/ebeam/vine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
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
 * Each one can attach up to two temporary vines to objects or mobs and drag them around with it.
 * Attempting to attach a vine to something with a vine already attached to it will pull all movable targets closer on command.
 * Once the prey is in melee range, melee attacks from the venus human trap heals itself for 10% of its max health, assuming the target is alive.
 * Akin to certain spiders, venus human traps can also be possessed and controlled by ghosts.
 *
 */

/mob/living/basic/venus_human_trap
	name = "venus human trap"
	desc = "Now you know how the fly feels."
	icon = 'icons/mob/spacevines.dmi'
	icon_state = "venus_human_trap"
	health_doll_icon = "venus_human_trap"
	mob_biotypes = MOB_ORGANIC | MOB_PLANT
	layer = SPACEVINE_MOB_LAYER
	health = 100
	maxHealth = 100
	obj_damage = 60
	melee_damage_lower = 10
	melee_damage_upper = 20
	minimum_survivable_temperature = 100
	combat_mode = TRUE
	basic_mob_flags = DEL_ON_DEATH
	death_message = "collapses into bits of plant matter."
	attacked_sound = 'sound/mobs/non-humanoids/venus_trap/venus_trap_hurt.ogg'
	death_sound = 'sound/mobs/non-humanoids/venus_trap/venus_trap_death.ogg'
	attack_sound = 'sound/mobs/non-humanoids/venus_trap/venus_trap_hit.ogg'
	unsuitable_heat_damage = 5 // heat damage is different from cold damage since coldmos is significantly more common than plasmafires
	unsuitable_cold_damage = 2 // they now do take cold damage, but this should be sufficiently small that it does not cause major issues
	habitable_atmos = null
	unsuitable_atmos_damage = 0
	/// copied over from the code from eyeballs (the mob) to make it easier for venus human traps to see in kudzu that doesn't have the transparency mutation
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	// Real green, cause of course
	lighting_cutoff_red = 10
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 20
	faction = list(FACTION_HOSTILE,FACTION_VINES,FACTION_PLANTS)
	initial_language_holder = /datum/language_holder/venus
	unique_name = TRUE
	speed = 1.2
	melee_attack_cooldown = 1.2 SECONDS
	ai_controller = /datum/ai_controller/basic_controller/human_trap
	///how much damage we take out of weeds
	var/no_weed_damage = 12.5
	///how much do we heal in weeds
	var/weed_heal = 10
	///if the balloon alert was shown atleast once, reset after healing in weeds
	var/alert_shown = FALSE

/mob/living/basic/venus_human_trap/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lifesteal, 5)
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle = BB_TARGETED_ACTION,
	)
	grant_actions_by_list(innate_actions)

/mob/living/basic/venus_human_trap/RangedAttack(atom/victim)
	if(!combat_mode)
		return
	var/datum/action/cooldown/mob_cooldown/tangle_ability = ai_controller.blackboard[BB_TARGETED_ACTION]
	if(!istype(tangle_ability))
		return
	tangle_ability.Trigger(target = victim)

/mob/living/basic/venus_human_trap/Life(seconds_per_tick = SSMOBS_DT, times_fired)
	. = ..()
	if(!.)
		return FALSE

	var/vines_in_range = locate(/obj/structure/spacevine) in range(2, src)
	if(!vines_in_range && !alert_shown)
		alert_shown = TRUE
		balloon_alert(src, "do not leave vines!")
	else if(vines_in_range)
		alert_shown = FALSE

	adjustBruteLoss(vines_in_range ? -weed_heal : no_weed_damage) //every life tick take 20 damage if not near vines or heal 10 if near vines, 5 times out of weeds = u ded

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle
	name = "Tangle"
	button_icon = 'icons/mob/spacevines.dmi'
	button_icon_state = "Light1"
	desc = "Grabs a target with a sticky vine, allowing you to pull it alongside you."
	cooldown_time = 8 SECONDS
	/// An assoc list of all the plant's vines (beam = leash)
	var/list/datum/beam/vines = list()
	/// How far away a plant can attach a vine to something
	var/vine_grab_distance = 4
	/// how long does a vine attached to something last (and its leash) (lasts twice as long on nonliving things)
	var/vine_duration = 2 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/Remove(mob/remove_from)
	QDEL_LIST(vines)
	return ..()

/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/Activate(atom/movable/target_atom)
	if(!ismovable(target_atom) || istype(target_atom, /obj/structure/spacevine))
		return
	if(target_atom.anchored)
		owner.balloon_alert(owner, "can't pull!")
		return
	if(get_dist(owner, target_atom) > vine_grab_distance)
		owner.balloon_alert(owner, "too far!")
		return
	var/list/target_turfs = get_line(owner, target_atom) - list(get_turf(owner), get_turf(target_atom))
	for(var/turf/blockage in target_turfs)
		if(blockage.is_blocked_turf(exclude_mobs = TRUE))
			owner.balloon_alert(owner, "path blocked!")
			return

	var/datum/beam/new_vine = owner.Beam(target_atom, icon_state = "vine", time = vine_duration * (ismob(target_atom) ? 1 : 2), beam_type = /obj/effect/ebeam/vine, emissive = FALSE)
	var/component = target_atom.AddComponent(/datum/component/leash, owner, vine_grab_distance)
	RegisterSignal(new_vine, COMSIG_QDELETING, PROC_REF(remove_vine), new_vine)
	vines[new_vine] = component
	if(isliving(target_atom))
		var/mob/living/victim = target_atom
		victim.Knockdown(2 SECONDS)
	StartCooldown()
	return TRUE

/**
 * Removes a vine from the list.
 *
 * Removes the vine from our list.
 * Called specifically when the vine is about to be destroyed, so we don't have any null references.
 * Arguments:
 * * datum/beam/vine - The vine to be removed from the list.
 */
/datum/action/cooldown/mob_cooldown/projectile_attack/vine_tangle/proc/remove_vine(datum/beam/vine)
	SIGNAL_HANDLER

	qdel(vines[vine])
	vines -= vine

/datum/ai_controller/basic_controller/human_trap
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/continue_planning,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

#undef FINAL_BUD_GROWTH_ICON
