/datum/species/zombie
	// 1spooky
	name = "High-Functioning Zombie"
	id = SPECIES_ZOMBIE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN
	mutanttongue = /obj/item/organ/tongue/zombie // not necessary as status effect gives it, but for tests

/datum/species/zombie/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/zombie/on_species_gain(mob/living/carbon/human/human_who_gained_species, datum/species/old_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	human_who_gained_species.apply_status_effect(/datum/status_effect/zombie/uninfected)

/datum/species/zombie/on_species_loss(mob/living/carbon/human/human_who_lost_species, datum/species/new_species, pref_load, regenerate_icons, replace_missing)
	. = ..()
	human_who_lost_species.remove_status_effect(/datum/status_effect/zombie/uninfected)

/datum/species/zombie/get_physical_attributes()
	return "Zombies are undead, and thus completely immune to any environmental hazard, or any physical threat besides blunt force trauma and burns. \
		Their limbs are easy to pop off their joints, but they can somehow just slot them back in."

/datum/species/zombie/get_species_description()
	return "A rotting zombie! They descend upon Space Station Thirteen Every year to spook the crew! \"Sincerely, the Zombies!\""

/datum/species/zombie/get_species_lore()
	return list("Zombies have long lasting beef with Botanists. Their last incident involving a lawn with defensive plants has left them very unhinged.")

// Override for the default temperature perks, so we can establish that they don't care about temperature very much
/datum/species/zombie/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-half",
		SPECIES_PERK_NAME = "No Body Temperature",
		SPECIES_PERK_DESC = "Having long since departed, Zombies do not have anything \
			regulating their body temperature anymore. This means that \
			the environment decides their body temperature - which they don't mind at \
			all, until it gets a bit too hot.",
	))

	return to_add

/datum/status_effect/zombie
	id = "zombified"
	alert_type = null
	tick_interval = STATUS_EFFECT_NO_TICK

	/// Time it takes before regen starts to kick in
	var/regen_time = 6 SECONDS
	/// Amount healed per regen tick - if 0, no regen will occur
	var/regen_amount = 0.5
	/// The hand to give the zombie - if null, they will have normal hands
	var/zombie_hand = /obj/item/mutant_hand/zombie
	/// The movespeed modifier to apply to the zombie - if null, no movespeed modifier will be applied
	var/movespeed_mod = /datum/movespeed_modifier/zombie
	/// % Reduction to all physical damage the zombie takes
	var/damage_modifier = 20
	/// Multiplier to all stamina damage the zombie types
	var/stamina_modifier = 0.33
	/// Max length of stun effects
	var/max_stun_length = 2 SECONDS

	/// List of traits applied to this type of zombie
	var/list/unique_traits = list(
		TRAIT_APATHETIC,
		TRAIT_COMBAT_MODE_LOCK,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_ILLITERATE,
		TRAIT_NEVER_CONSIDERED_ALIVE,
		TRAIT_PRIMITIVE,
		TRAIT_STABLEHEART,
		TRAIT_STABLELIVER,
	)
	/// List of traits applied to all zombie types
	var/static/list/zombie_traits = list(
		TRAIT_BLOODY_MESS,
		TRAIT_COLD_BLOODED,
		TRAIT_EASILY_WOUNDED,
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_LIMBATTACHMENT,
		TRAIT_LIVERLESS_METABOLISM,
		TRAIT_NOBREATH,
		TRAIT_NOCRITDAMAGE,
		TRAIT_NODEATH,
		TRAIT_NOHUNGER,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
	)

	/// Biotypes we added (typically just MOB_UNDEAD)
	VAR_PRIVATE/added_biotypes = NONE
	/// Biotypes we removed (typically just MOB_ORGANIC)
	VAR_PRIVATE/removed_biotypes = NONE
	/// Tongue we removed and stored away for later restoration
	VAR_PRIVATE/datum/weakref/removed_tongue

/datum/status_effect/zombie/on_apply()
	if(!ishuman(owner) || HAS_TRAIT(owner, TRAIT_UNHUSKABLE))
		return FALSE

	var/mob/living/carbon/human/new_zombie = owner
	RegisterSignal(new_zombie, COMSIG_HUMAN_SPEC_STUN, PROC_REF(on_spec_stun))
	if(!isnull(movespeed_mod))
		new_zombie.add_movespeed_modifier(movespeed_mod)
	MODIFY_PHYSIOLOGY(new_zombie, STAMINA, stamina_modifier) // Zombie stam resist
	new_zombie.damage_resistance += damage_modifier
	new_zombie.add_traits(unique_traits | zombie_traits, TRAIT_STATUS_EFFECT(id))
	new_zombie.lighting_cutoff_red = 25
	new_zombie.lighting_cutoff_green = 35
	new_zombie.lighting_cutoff_blue = 5
	new_zombie.update_sight()
	new_zombie.set_combat_mode(TRUE, silent = TRUE, force = TRUE)
	set_zombie_temperature()
	add_zombie_biotypes()

	// Ensures we have an infection organ even if we were applied by something else
	var/obj/item/organ/zombie_infection/infection = new_zombie.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(isnull(infection))
		infection = new()
		infection.Insert(new_zombie)
		RegisterSignal(infection, COMSIG_ORGAN_REMOVED, PROC_REF(organ_removed))

	var/obj/item/bodypart/head/head = new_zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!QDELETED(head))
		head.can_dismember = TRUE

	var/obj/item/organ/tongue/old_tongue = new_zombie.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!QDELETED(old_tongue))
		old_tongue.Remove(new_zombie, special = TRUE)
		if(!QDELETED(old_tongue))
			old_tongue.moveToNullspace()
			removed_tongue = WEAKREF(old_tongue)

	var/obj/item/organ/tongue/zombie/new_tongue = new()
	new_tongue.Insert(new_zombie, special = TRUE)

	if(!isnull(zombie_hand))
		new_zombie.AddComponent( \
			/datum/component/mutant_hands, \
			mutant_hand_path = zombie_hand, \
		)
	if(regen_amount > 0)
		new_zombie.AddComponent( \
			/datum/component/regenerator, \
			regeneration_delay = regen_time, \
			brute_per_second = regen_amount, \
			burn_per_second = regen_amount, \
			tox_per_second = regen_amount, \
			oxy_per_second = regen_amount * 0.5, \
			heals_wounds = TRUE, \
		)

	new_zombie.become_husk(id)

	RegisterSignal(new_zombie, COMSIG_SPECIES_GAIN, PROC_REF(zombie_species_changed))
	RegisterSignal(new_zombie, COMSIG_LIVING_DEATH, PROC_REF(zombie_died_somehow))
	RegisterSignal(new_zombie, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(zombie_limb_gained))
	RegisterSignal(new_zombie, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(zombie_limb_lost))

	return TRUE

/datum/status_effect/zombie/on_remove()
	var/mob/living/carbon/human/was_zombie = owner

	var/obj/item/organ/tongue/zombie/old_tongue = was_zombie.get_organ_slot(ORGAN_SLOT_TONGUE)
	var/obj/item/organ/tongue/removed_tongue_real = removed_tongue?.resolve()
	if(!QDELETED(old_tongue))
		qdel(old_tongue)
	if(!QDELETED(removed_tongue_real))
		removed_tongue_real.Insert(was_zombie, special = TRUE)

	var/obj/item/bodypart/head/head = was_zombie.get_bodypart(BODY_ZONE_HEAD)
	if(!QDELETED(head))
		head.can_dismember = initial(head.can_dismember)

	qdel(was_zombie.GetComponent(/datum/component/mutant_hands))
	qdel(was_zombie.GetComponent(/datum/component/regenerator))
	UnregisterSignal(was_zombie, COMSIG_HUMAN_SPEC_STUN)
	if(!isnull(movespeed_mod))
		was_zombie.remove_movespeed_modifier(movespeed_mod)
	MODIFY_PHYSIOLOGY(was_zombie, STAMINA, 1 / stamina_modifier)
	was_zombie.damage_resistance -= damage_modifier
	was_zombie.remove_traits(zombie_traits | unique_traits, TRAIT_STATUS_EFFECT(id))
	was_zombie.lighting_cutoff_red = initial(was_zombie.lighting_cutoff_red)
	was_zombie.lighting_cutoff_green = initial(was_zombie.lighting_cutoff_green)
	was_zombie.lighting_cutoff_blue = initial(was_zombie.lighting_cutoff_blue)
	was_zombie.update_sight()
	was_zombie.cure_husk(id)
	restore_zombie_temperature()
	remove_zombie_biotypes()

	var/obj/item/organ/zombie_infection/infection = was_zombie.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(!QDELETED(infection))
		UnregisterSignal(infection, COMSIG_ORGAN_REMOVED)
		qdel(infection)

	UnregisterSignal(was_zombie, COMSIG_SPECIES_GAIN)
	UnregisterSignal(was_zombie, COMSIG_LIVING_DEATH)
	UnregisterSignal(was_zombie, COMSIG_CARBON_POST_ATTACH_LIMB)
	UnregisterSignal(was_zombie, COMSIG_CARBON_POST_REMOVE_LIMB)

/datum/status_effect/zombie/proc/add_zombie_biotypes()
	if(!(owner.mob_biotypes & MOB_UNDEAD))
		owner.mob_biotypes |= MOB_UNDEAD
		added_biotypes = MOB_UNDEAD

	if(owner.mob_biotypes & MOB_ORGANIC)
		owner.mob_biotypes &= ~MOB_ORGANIC
		removed_biotypes = MOB_ORGANIC

/datum/status_effect/zombie/proc/on_spec_stun(list/amount)
	SIGNAL_HANDLER
	amount[1] = min(amount[1], max_stun_length)

/datum/status_effect/zombie/proc/remove_zombie_biotypes()
	owner.mob_biotypes &= ~added_biotypes
	owner.mob_biotypes |= removed_biotypes

/datum/status_effect/zombie/proc/set_zombie_temperature()
	var/mob/living/carbon/human/zombie = owner
	zombie.dna.species.bodytemp_normal = T0C
	zombie.dna.species.bodytemp_heat_damage_limit = FIRE_MINIMUM_TEMPERATURE_TO_EXIST

/datum/status_effect/zombie/proc/restore_zombie_temperature()
	var/mob/living/carbon/human/zombie = owner
	zombie.dna.species.bodytemp_normal = initial(zombie.dna.species.bodytemp_normal)
	zombie.dna.species.bodytemp_heat_damage_limit = initial(zombie.dna.species.bodytemp_heat_damage_limit)

/datum/status_effect/zombie/proc/zombie_limb_gained(mob/living/carbon/human/zombie, obj/item/bodypart/head/limb)
	SIGNAL_HANDLER
	if(istype(limb))
		limb.can_dismember = TRUE

/datum/status_effect/zombie/proc/zombie_limb_lost(mob/living/carbon/human/zombie, obj/item/bodypart/head/limb)
	SIGNAL_HANDLER
	if(istype(limb))
		limb.can_dismember = initial(limb.can_dismember)

/datum/status_effect/zombie/proc/organ_removed(obj/item/organ/zombie_infection/infection, ...)
	SIGNAL_HANDLER
	UnregisterSignal(infection, COMSIG_ORGAN_REMOVED)
	qdel(src)

/datum/status_effect/zombie/proc/zombie_died_somehow(mob/living/carbon/human/zombie, gibbed)
	SIGNAL_HANDLER
	if(gibbed)
		return

	var/obj/item/organ/zombie_infection/infection = owner.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	qdel(infection) // this will in turn qdel this status effect

/datum/status_effect/zombie/proc/zombie_species_changed(mob/living/carbon/human/zombie, ...)
	SIGNAL_HANDLER

	set_zombie_temperature()
	add_zombie_biotypes()

/datum/status_effect/zombie/mindless
	regen_time = 10 SECONDS
	regen_amount = 0.2
	zombie_hand = /obj/item/mutant_hand/zombie/weak
	movespeed_mod = /datum/movespeed_modifier/zombie/mindless

/datum/status_effect/zombie/uninfected
	regen_amount = 0
	damage_modifier = 0
	stamina_modifier = 1
	zombie_hand = null
	movespeed_mod = null
	max_stun_length = INFINITY
	unique_traits = list(
		TRAIT_NOBLOOD,
		TRAIT_SUCCUMB_OVERRIDE,
	)

/datum/status_effect/zombie/uninfected/organ_removed(obj/item/organ/zombie_infection/infection, ...)
	return // nope

/datum/status_effect/zombie/uninfected/zombie_died_somehow(mob/living/carbon/human/zombie, gibbed)
	return // you're stuck with it bud

/datum/movespeed_modifier/zombie
	multiplicative_slowdown = 1.0

/datum/movespeed_modifier/zombie/mindless
	multiplicative_slowdown = parent_type::multiplicative_slowdown + 0.5
