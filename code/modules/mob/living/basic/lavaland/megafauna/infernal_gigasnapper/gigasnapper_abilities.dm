
/// arena ability, how big the square arena is in tiles
#define ARENA_SIZE 9
/// summon ability, how long the crab channels to summon
#define SUMMON_CHANNEL_TIME 4 SECONDS

/datum/action/cooldown/mob_cooldown/crab_dig
	name = "Crustacean Reposition"
	desc = "Tunnel to a new location. Only available when arena is lowered."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/crab_dig/Activate(atom/target_atom)
	StartCooldownSelf(INFINITY)
	jump(owner, target_atom)
	StartCooldownOthers(1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/crab_dig/proc/jump(mob/living/crab, atom/target)
	///TODO
	//player chooses a location with a point and click before activate
	//	if no player, auto decision somewhere on a nearby target or random if none
	//chargeup sequence, cant do anything
	//leap
	return

/datum/action/cooldown/mob_cooldown/crab_arena
	name = "Raise Molten Fissure Arena"
	desc = "Create an arena around you. No cooldown to raise, but a cooldown after lowering the arena."
	cooldown_time = 30 SECONDS
	///if the arena is raised, this list will have references to the walls.
	var/list/arena_turfs = list()
	///initializes into a list of all the types created by the boss while an arena is active for cleanup.
	var/static/list/types_to_remove
	///weak reference to the center of the arena
	var/datum/weakref/weak_arena_center_turf

/datum/action/cooldown/mob_cooldown/crab_arena/Activate(atom/target_atom)
	toggle_arena()
	if(!arena_turfs.len)
		StartCooldown()

///toggles the arena on and off, creating a square of blocking effects to contain the fight.
/datum/action/cooldown/mob_cooldown/crab_arena/proc/toggle_arena()
	if(!arena_turfs.len)
		//make arena
		var/turf/crab_turf = get_turf(owner)
		for(var/turf/range_turf as anything in RANGE_TURFS(ARENA_SIZE, crab_turf))
			if(range_turf && get_dist(range_turf, crab_turf) == ARENA_SIZE)
				arena_turfs += new /obj/effect/gigasnapper_arena(range_turf, src)
	else
		//destroy arena

		if(!types_to_remove)
			types_to_remove = list(
				/obj/effect/empowered_turf,
				/obj/effect/temp_visual/telegraphing/create_type/smallsnipper,
				/mob/living/basic/crab/smallsnipper,
				/obj/projectile/smallsnipper_bubble,
			)
		var/list/cleanup_turfs = RANGE_TURFS(ARENA_SIZE-1, get_turf(owner))
		for(var/turf/cleanup_turf as anything in cleanup_turfs)
			for(var/type_to_remove in types_to_remove)
				var/atom/found = locate(type_to_remove) in cleanup_turf
				if(found)
					qdel(found)
		//walls
		for(var/turf/arena_turf as anything in arena_turfs)
			qdel(arena_turf)
		arena_turfs.Cut()

///helper for other abilities, grabs open spaces without anything on them
///
///criteria for a "good" turf for other abilities to place on:
/// * open floor
/// * no mobs, player gigasnapper or smallsnipper
/// * none of the sprite-covered turfs considered "crab_turfs" by the megafauna
/// * no empowered turfs
/datum/action/cooldown/mob_cooldown/crab_arena/proc/get_spawn_turfs() as /list
	var/mob/living/basic/mining/megafauna/infernal_gigasnapper/crab = owner
	var/list/good_turfs = list()
	var/list/arena_turfs = RANGE_TURFS(ARENA_SIZE-1, get_turf(owner))
	arena_turfs -= crab.get_crab_turfs()
	for(var/turf/arena_turf as anything in arena_turfs)
		if(!isopenturf(arena_turf))
			continue
		if(/obj/effect/empowered_turf in arena_turf)
			continue
		if(/mob/living in arena_turf)
			continue
		good_turfs += arena_turf
	return good_turfs

/obj/effect/gigasnapper_arena
	name = "molten crucible"
	desc = "Deep rock raised around a singular point. Still very hot from thermal activity below."

	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "crucible_rock"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE

/obj/effect/gigasnapper_arena/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/effect/gigasnapper_arena/update_overlays()
	. = ..()
	. += "crucible_lava"
	. += emissive_appearance(icon, "crucible_lava", src)

/datum/action/cooldown/mob_cooldown/crab_minions
	name = "Call of Cancer"
	desc = "Channel to summon crab minions inside the arena, depending on how much health missing. The arena must be active."
	shared_cooldown = MOB_SHARED_COOLDOWN_1

/datum/action/cooldown/mob_cooldown/crab_minions/Activate(atom/target)
	//TODO: Arena check
	if(!channel())
		owner.balloon_alert(owner, "interrupted!")
		return
	summon(owner)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/crab_minions/proc/channel()
	disable_cooldown_actions()
	owner.visible_message(span_warning("[owner] begins rhythmically waving [owner.p_their()] claws in the air..."))
	var/success = do_after(owner, SUMMON_CHANNEL_TIME, owner)
	enable_cooldown_actions()
	return success

/// summons 1 - 3 crabs, gaining an extra crab summoned for each third chunk of health lost
/// (so 2 under 2/3rds and 3 under 1/3rds)
/datum/action/cooldown/mob_cooldown/crab_minions/proc/summon(mob/living/basic/mining/megafauna/infernal_gigasnapper/crab)
	var/crabs_to_summon = 1
	var/third_of_health = crab.maxHealth / 3
	if(crab.health < third_of_health * 2)
		crabs_to_summon++
	if(crab.health < third_of_health)
		crabs_to_summon++
	var/list/spawn_turfs = crab.arena.get_spawn_turfs()
	for(var/i in 1 to crabs_to_summon)
		var/turf/spawn_turf = pick_n_take(spawn_turfs)
		new /obj/effect/temp_visual/telegraphing/create_type/smallsnipper(spawn_turf)

#undef ARENA_SIZE
#undef SUMMON_CHANNEL_TIME
