/**
 * A floating fungus which turns people into zombies and explodes into reagent clouds upon death.
 */
/mob/living/basic/blob_minion/spore
	name = "blob spore"
	desc = "A floating, fragile spore."
	icon = 'icons/mob/nonhuman-player/blob.dmi'
	icon_state = "blobpod"
	icon_living = "blobpod"
	health_doll_icon = "blobpod"
	health = BLOBMOB_SPORE_HEALTH
	maxHealth = BLOBMOB_SPORE_HEALTH
	verb_say = "psychically pulses"
	verb_ask = "psychically probes"
	verb_exclaim = "psychically yells"
	verb_yell = "psychically screams"
	melee_damage_lower = BLOBMOB_SPORE_DMG_LOWER
	melee_damage_upper = BLOBMOB_SPORE_DMG_UPPER
	obj_damage = 0
	attack_verb_continuous = "batters"
	attack_verb_simple = "batter"
	attack_sound = 'sound/items/weapons/genhit1.ogg'
	death_message = "explodes into a cloud of gas!"
	gold_core_spawnable = HOSTILE_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	ai_controller = /datum/ai_controller/basic_controller/blob_spore
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = 1
	/// Type of mob to create
	var/mob/living/zombie_type = /mob/living/basic/blob_minion/zombie

/mob/living/basic/blob_minion/spore/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBSPORE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/blob_minion/spore/death(gibbed)
	. = ..()
	death_burst()

/mob/living/basic/blob_minion/spore/on_factory_destroyed()
	death()

/// Create an explosion of spores on death
/mob/living/basic/blob_minion/spore/proc/death_burst()
	do_chem_smoke(range = death_cloud_size, holder = src, location = get_turf(src), reagent_type = /datum/reagent/toxin/spore)


/mob/living/basic/blob_minion/spore/melee_attack(mob/living/carbon/human/target, list/modifiers, ignore_cooldown)
	. = ..()
	if (!ishuman(target) || target.stat != DEAD)
		return
	zombify(target)

/// Become a zombie
/mob/living/basic/blob_minion/spore/proc/zombify(mob/living/carbon/human/target)
	visible_message(span_warning("The corpse of [target.name] suddenly rises!"))
	var/mob/living/basic/blob_minion/zombie/blombie = change_mob_type(zombie_type, loc, new_name = initial(zombie_type.name))
	blombie.set_name()
	if (istype(blombie)) // In case of badmin
		blombie.consume_corpse(target)
	SEND_SIGNAL(src, COMSIG_BLOB_ZOMBIFIED, blombie)
	qdel(src)

/// Variant of the blob spore which is actually spawned by blob factories
/mob/living/basic/blob_minion/spore/minion
	gold_core_spawnable = NO_SPAWN
	zombie_type = /mob/living/basic/blob_minion/zombie/controlled
	/// We die if we leave the same turf as this z level
	var/turf/z_turf

/mob/living/basic/blob_minion/spore/minion/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_changed))

/// When we z-move check that we're on the same z level as our factory was
/mob/living/basic/blob_minion/spore/minion/proc/on_z_changed()
	SIGNAL_HANDLER
	if (isnull(z_turf))
		return
	if (!is_valid_z_level(get_turf(src), z_turf))
		death()

/// Mark the turf we need to track from our factory
/mob/living/basic/blob_minion/spore/minion/link_to_factory(obj/structure/blob/special/factory/factory)
	. = ..()
	z_turf = get_turf(factory)

/// If the blob changes to distributed neurons then you can control the spores
/mob/living/basic/blob_minion/spore/minion/on_strain_updated(mob/camera/blob/overmind, datum/blobstrain/new_strain)
	if (isnull(overmind))
		REMOVE_TRAIT(src, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_PERMANENTLY_MORTAL, INNATE_TRAIT)

	if (istype(new_strain, /datum/blobstrain/reagent/distributed_neurons))
		AddComponent(\
			/datum/component/ghost_direct_control,\
			ban_type = ROLE_BLOB_INFECTION,\
			poll_candidates = TRUE,\
			poll_ignore_key = POLL_IGNORE_BLOB,\
		)
	else
		qdel(GetComponent(/datum/component/ghost_direct_control))

/mob/living/basic/blob_minion/spore/minion/death_burst()
	return // This behaviour is superceded by the overmind's intervention


/// Weakened spore spawned by distributed neurons, can't zombify people and makes a teeny explosion
/mob/living/basic/blob_minion/spore/minion/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2
	death_cloud_size = 0

/mob/living/basic/blob_minion/spore/minion/weak/zombify()
	return

/mob/living/basic/blob_minion/spore/minion/weak/on_strain_updated()
	return
