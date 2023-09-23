/**
 * A floating fungus which turns people into zombies and explodes into reagent clouds upon death.
 */
/mob/living/basic/blob_spore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	health_doll_icon = "blobpod"
	unique_name = TRUE
	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)
	combat_mode = TRUE
	health = BLOBMOB_SPORE_HEALTH
	maxHealth = BLOBMOB_SPORE_HEALTH
	bubble_icon = "blob"
	speak_emote = null
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = BLOBMOB_SPORE_DMG_LOWER
	melee_damage_upper = BLOBMOB_SPORE_DMG_UPPER
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	obj_damage = 0
	attack_verb_continuous = "batters"
	attack_verb_simple = "batter"
	attack_sound = 'sound/weapons/genhit1.ogg'
	death_message = "explodes into a cloud of gas!"
	lighting_cutoff_red = 20
	lighting_cutoff_green = 40
	lighting_cutoff_blue = 30
	initial_language_holder = /datum/language_holder/empty
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/blob_spore
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = 1
	/// Type of mob to create
	var/mob/living/zombie_type = /mob/living/basic/blob_zombie

/mob/living/basic/blob_spore/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	add_traits(list(TRAIT_BLOB_ALLY, TRAIT_MUTE), INNATE_TRAIT)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBSPORE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/blob_spore/death(gibbed)
	. = ..()
	death_burst()

/// Create an explosion of spores on death
/mob/living/basic/blob_spore/proc/death_burst()
	release_spore_cloud()

/// On death, create a small smoke of harmful gas (s-Acid)
/mob/living/basic/blob_spore/proc/release_spore_cloud(reagent_type = /datum/reagent/toxin/spore)
	var/datum/effect_system/fluid_spread/smoke/chem/spores = new
	var/turf/location = get_turf(src)
	// Create the reagents to put into the air
	create_reagents(10)
	reagents.add_reagent(reagent_type, 10)
	// Attach the smoke spreader and setup/start it.
	spores.attach(location)
	spores.set_up(death_cloud_size, holder = src, location = location, carry = reagents, silent = TRUE)
	spores.start()

/mob/living/basic/blob_spore/melee_attack(mob/living/carbon/human/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!ishuman(target) || target.stat != DEAD)
		return
	zombify(target)

/// Become a zombie
/mob/living/basic/blob_spore/proc/zombify(mob/living/carbon/human/target)
	visible_message(span_warning("The corpse of [target.name] suddenly rises!"))
	var/mob/living/basic/blob_zombie/blombie = change_mob_type(zombie_type, loc, new_name = initial(zombie_type.name))
	blombie.set_name()
	if (istype(blombie)) // In case of badmin
		blombie.consume_corpse(target)
	SEND_SIGNAL(src, COMSIG_BLOB_ZOMBIFIED, blombie)
	qdel(src)

/// Variant of the blob spore which is actually spawned by blob factories
/mob/living/basic/blob_spore/minion
	gold_core_spawnable = NO_SPAWN
	zombie_type = /mob/living/basic/blob_zombie/controlled
	/// We die if we leave the same turf as this z level
	var/turf/z_turf

/mob/living/basic/blob_spore/minion/Life(seconds_per_tick, times_fired)
	. = ..()
	if (isnull(z_turf))
		return
	if (!is_valid_z_level(get_turf(src), z_turf))
		death()

/// Mark the turf we need to track from our factory
/mob/living/basic/blob_spore/minion/proc/link_to_factory(turf/factory_turf)
	z_turf = factory_turf

/// If the blob changes to distributed neurons then you can control the spores
/mob/living/basic/blob_spore/minion/proc/on_strain_updated(mob/camera/blob/overmind, datum/blobstrain/new_strain)
	if (istype(new_strain, /datum/blobstrain/reagent/distributed_neurons))
		AddComponent(\
			/datum/component/ghost_direct_control,\
			ban_type = ROLE_BLOB_INFECTION,\
			poll_candidates = TRUE,\
			poll_ignore_key = POLL_IGNORE_BLOB,\
		)
	else
		qdel(GetComponent(/datum/component/ghost_direct_control))

/mob/living/basic/blob_spore/minion/death_burst()
	return // This behaviour is superceded by the overmind's intervention


/// Weakened spore spawned by distributed neurons, can't zombify people and makes a teeny explosion
/mob/living/basic/blob_spore/minion/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2
	death_cloud_size = 0

/mob/living/basic/blob_spore/minion/weak/zombify()
	return

/mob/living/basic/blob_spore/minion/weak/on_strain_updated()
	return

/datum/ai_controller/basic_controller/spore
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/jps
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
