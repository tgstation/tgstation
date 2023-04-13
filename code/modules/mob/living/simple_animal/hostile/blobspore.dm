/mob/living/simple_animal/hostile/blob/blobspore
	name = "blob spore"
	desc = "A floating, fragile spore."
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
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 0
	attack_verb_continuous = "hits"
	attack_verb_simple = "hit"
	attack_sound = 'sound/weapons/genhit1.ogg'
	del_on_death = TRUE
	death_message = "explodes into a cloud of gas!"
	gold_core_spawnable = NO_SPAWN //gold slime cores should only spawn the independent subtype
	/// Size of cloud produced from a dying spore
	var/death_cloud_size = 1
	/// The attached person
	var/mob/living/carbon/human/corpse
	/// If this is attached to a person
	var/is_zombie = FALSE
	/// Whether or not this is a fragile spore from Distributed Neurons
	var/is_weak = FALSE

/mob/living/simple_animal/hostile/blob/blobspore/Initialize(mapload, obj/structure/blob/special/linked_node)
	. = ..()
	AddElement(/datum/element/simple_flying)

	if(!istype(linked_node))
		return

	factory = linked_node
	factory.spores += src
	if(linked_node.overmind && istype(linked_node.overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons) && !istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak))
		notify_ghosts("A controllable spore has been created in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Sentient Spore Created")
	add_cell_sample()

/mob/living/simple_animal/hostile/blob/blobspore/mind_initialize()
	. = ..()
	if(independent || !overmind)
		return FALSE
	var/datum/antagonist/blob_minion/blob_zombie/zombie = new(overmind)
	mind.add_antag_datum(zombie)

/mob/living/simple_animal/hostile/blob/blobspore/Life(delta_time = SSMOBS_DT, times_fired)
	if(!is_zombie && isturf(loc))
		for(var/mob/living/carbon/human/target in view(src,1)) //Only for corpse right next to/on same tile
			if(!is_weak && target.stat == DEAD)
				zombify(target)
				break
	if(factory && !is_valid_z_level(get_turf(src), get_turf(factory)))
		death()
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	humanize_pod(user)

/mob/living/simple_animal/hostile/blob/blobspore/death(gibbed)
	// On death, create a small smoke of harmful gas (s-Acid)
	var/datum/effect_system/fluid_spread/smoke/chem/spores = new
	var/turf/location = get_turf(src)

	// Create the reagents to put into the air
	create_reagents(10)

	if(overmind?.blobstrain)
		overmind.blobstrain.on_sporedeath(src)
	else
		reagents.add_reagent(/datum/reagent/toxin/spore, 10)

	// Attach the smoke spreader and setup/start it.
	spores.attach(location)
	spores.set_up(death_cloud_size, holder = src, location = location, carry = reagents, silent = TRUE)
	spores.start()
	if(factory)
		factory.spore_delay = world.time + factory.spore_cooldown //put the factory on cooldown

	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/Destroy()
	if(factory)
		factory.spores -= src
		factory = null
	if(corpse)
		corpse.forceMove(loc)
		corpse = null
	return ..()

/mob/living/simple_animal/hostile/blob/blobspore/update_icons()
	if(overmind)
		add_atom_colour(overmind.blobstrain.complementary_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)
	if(!is_zombie)
		return FALSE

	copy_overlays(corpse, TRUE)
	var/mutable_appearance/blob_head_overlay = mutable_appearance('icons/mob/nonhuman-player/blob.dmi', "blob_head")
	if(overmind)
		blob_head_overlay.color = overmind.blobstrain.complementary_color
	color = initial(color) // looks better.
	add_overlay(blob_head_overlay)

/mob/living/simple_animal/hostile/blob/blobspore/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_BLOBSPORE, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/simple_animal/hostile/blob/blobspore/independent
	gold_core_spawnable = HOSTILE_SPAWN
	independent = TRUE

/mob/living/simple_animal/hostile/blob/blobspore/weak
	name = "fragile blob spore"
	health = 15
	maxHealth = 15
	melee_damage_lower = 1
	melee_damage_upper = 2
	death_cloud_size = 0
	is_weak = TRUE

/** Ghost control a blob zombie */
/mob/living/simple_animal/hostile/blob/blobspore/proc/humanize_pod(mob/user)
	if((!overmind || istype(src, /mob/living/simple_animal/hostile/blob/blobspore/weak) || !istype(overmind.blobstrain, /datum/blobstrain/reagent/distributed_neurons)) && !is_zombie)
		return FALSE
	if(key || stat)
		return FALSE
	var/pod_ask = tgui_alert(usr, "Are you bulbous enough?", "Blob Spore", list("Yes", "No"))
	if(pod_ask != "Yes" || QDELETED(src))
		return FALSE
	if(key)
		to_chat(user, span_warning("Someone else already took this spore!"))
		return FALSE
	key = user.key
	log_message("took control of [name].", LOG_GAME)

/** Zombifies a dead mob, turning it into a blob zombie */
/mob/living/simple_animal/hostile/blob/blobspore/proc/zombify(mob/living/carbon/human/target)
	is_zombie = 1
	if(target.wear_suit)
		maxHealth += target.get_armor_rating(MELEE) // That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "blob zombie"
	desc = "A shambling corpse animated by the blob."
	mob_biotypes |= MOB_HUMANOID
	melee_damage_lower += 8
	melee_damage_upper += 11
	obj_damage = 20 // now that it has a corpse to puppet, it can properly attack structures
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	movement_type = GROUND
	death_cloud_size = 0
	icon = target.icon
	icon_state = "zombie"
	target.hairstyle = null
	target.update_body_parts()
	target.forceMove(src)
	corpse = target
	update_icons()
	visible_message(span_warning("The corpse of [target.name] suddenly rises!"))
	if(!key)
		notify_ghosts("\A [src] has been created in \the [get_area(src)].", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Blob Zombie Created")
