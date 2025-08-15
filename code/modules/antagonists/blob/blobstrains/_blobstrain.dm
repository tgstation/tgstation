GLOBAL_LIST_INIT(valid_blobstrains, subtypesof(/datum/blobstrain) - list(/datum/blobstrain/reagent, /datum/blobstrain/multiplex))

/datum/blobstrain
	var/name
	var/description
	var/color = COLOR_BLACK
	/// The color that stuff like healing effects and the overmind camera gets
	var/complementary_color = COLOR_BLACK
	/// A short description of the power and its effects
	var/shortdesc = null
	/// Any long, blob-tile specific effects
	var/effectdesc = null
	/// Short descriptor of what the strain does damage-wise, generally seen in the reroll menu
	var/analyzerdescdamage = "Unknown. Report this bug to a coder, or just adminhelp."
	/// Short descriptor of what the strain does in general, generally seen in the reroll menu
	var/analyzerdesceffect
	/// Blobbernaut attack verb
	var/blobbernaut_message = "slams"
	/// Message sent to any mob hit by the blob
	var/message = "The blob strikes you"
	/// Gets added onto 'message' if the mob stuck is of type living
	var/message_living = null
	/// Stores world.time to figure out when to next give resources
	var/resource_delay = 0
	///The blob overmind eye mob used to control the spread
	var/mob/eye/blob/overmind
	/// The amount of health regenned on core_process
	var/base_core_regen = BLOB_CORE_HP_REGEN
	/// The amount of points gained on core_process
	var/point_rate = BLOB_BASE_POINT_RATE

	// Various vars that strains can buff the blob with
	/// HP regen bonus added by strain
	var/core_regen_bonus = 0
	/// resource point bonus added by strain
	var/point_rate_bonus = 0

	/// Adds to claim, pulse, and expand range
	var/core_range_bonus = 0
	/// Extra range up to which the core reinforces blobs
	var/core_strong_reinforcement_range_bonus = 0
	/// Extra range up to which the core reinforces blobs into reflectors
	var/core_reflector_reinforcement_range_bonus = 0

	/// Adds to claim, pulse, and expand range
	var/node_range_bonus = 0
	/// Nodes can sustain this any extra spores with this strain
	var/node_spore_bonus = 0
	/// Extra range up to which the node reinforces blobs
	var/node_strong_reinforcement_range_bonus = 0
	/// Extra range up to which the node reinforces blobs into reflectors
	var/node_reflector_reinforcement_range_bonus = 0

	/// Extra spores produced by factories with this strain
	var/factory_spore_bonus = 0

	/// Multiplies the max and current health of every blob with this value upon selecting this strain.
	var/max_structure_health_multiplier = 1
	/// Multiplies the max and current health of every mob with this value upon selecting this strain.
	var/max_mob_health_multiplier = 1

	/// Makes blobbernauts inject a bonus amount of reagents, making their attacks more powerful
	var/blobbernaut_reagentatk_bonus = 0

/datum/blobstrain/New(mob/eye/blob/new_overmind)
	if(new_overmind)
		overmind = new_overmind

/datum/blobstrain/Destroy()
	overmind = null
	return ..()

/datum/blobstrain/proc/on_gain()
	overmind.color = complementary_color

	if(overmind.blob_core)
		overmind.blob_core.claim_range += core_range_bonus
		overmind.blob_core.pulse_range += core_range_bonus
		overmind.blob_core.expand_range += core_range_bonus
		overmind.blob_core.strong_reinforce_range += core_strong_reinforcement_range_bonus
		overmind.blob_core.reflector_reinforce_range += core_reflector_reinforcement_range_bonus

	for(var/obj/structure/blob/special/node/N as anything in overmind.node_blobs)
		N.claim_range += node_range_bonus
		N.pulse_range += node_range_bonus
		N.expand_range += node_range_bonus
		N.strong_reinforce_range += node_strong_reinforcement_range_bonus
		N.reflector_reinforce_range += node_reflector_reinforcement_range_bonus

	for(var/obj/structure/blob/special/factory/F as anything in overmind.factory_blobs)
		F.max_spores += factory_spore_bonus

	for(var/obj/structure/blob/B as anything in overmind.all_blobs)
		B.modify_max_integrity(B.max_integrity * max_structure_health_multiplier)
		B.update_appearance()

	for(var/mob/living/blob_mob as anything in overmind.blob_mobs)
		blob_mob.maxHealth *= max_mob_health_multiplier
		blob_mob.health *= max_mob_health_multiplier
		blob_mob.update_icons() //If it's getting a new strain, tell it what it does!
		to_chat(blob_mob, "Your overmind's blob strain is now: <b><font color=\"[color]\">[name]</b></font>!")
		to_chat(blob_mob, "The <b><font color=\"[color]\">[name]</b></font> strain [shortdesc ? "[shortdesc]" : "[description]"]")

/datum/blobstrain/proc/on_lose()
	if(overmind.blob_core)
		overmind.blob_core.claim_range -= core_range_bonus
		overmind.blob_core.expand_range -= core_range_bonus
		overmind.blob_core.strong_reinforce_range -= core_strong_reinforcement_range_bonus
		overmind.blob_core.reflector_reinforce_range -= core_reflector_reinforcement_range_bonus

	for(var/obj/structure/blob/special/node/N as anything in overmind.node_blobs)
		N.claim_range -= node_range_bonus
		N.expand_range -= node_range_bonus
		N.strong_reinforce_range -= node_strong_reinforcement_range_bonus
		N.reflector_reinforce_range -= node_reflector_reinforcement_range_bonus

	for(var/obj/structure/blob/special/factory/F as anything in overmind.factory_blobs)
		F.max_spores -= factory_spore_bonus

	for(var/obj/structure/blob/B as anything in overmind.all_blobs)
		B.modify_max_integrity(B.max_integrity / max_structure_health_multiplier)

	for(var/mob/living/blob_mob as anything in overmind.blob_mobs)
		blob_mob.maxHealth /= max_mob_health_multiplier
		blob_mob.health /= max_mob_health_multiplier


/datum/blobstrain/proc/on_sporedeath(mob/living/dead_minion, death_cloud_size)
	return

/datum/blobstrain/proc/send_message(mob/living/M)
	var/totalmessage = message
	if(message_living && !issilicon(M))
		totalmessage += message_living
	totalmessage += "!"
	to_chat(M, span_userdanger("[totalmessage]"))

/datum/blobstrain/proc/core_process()
	if(resource_delay <= world.time)
		resource_delay = world.time + 10 // 1 second
		overmind.add_points(point_rate+point_rate_bonus)
	overmind.blob_core.repair_damage(base_core_regen + core_regen_bonus)

/datum/blobstrain/proc/attack_living(mob/living/L, list/nearby_blobs) // When the blob attacks people
	send_message(L)

/// When this blob's blobbernaut attacks any atom
/datum/blobstrain/proc/blobbernaut_attack(mob/living/blobbernaut, atom/victim)
	SIGNAL_HANDLER
	return

/datum/blobstrain/proc/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag, coefficient = 1) //when the blob takes damage, do this
	return coefficient*damage

/datum/blobstrain/proc/death_reaction(obj/structure/blob/B, damage_flag, coefficient = 1) //when a blob dies, do this
	return

/datum/blobstrain/proc/expand_reaction(obj/structure/blob/B, obj/structure/blob/newB, turf/T, mob/eye/blob/O, coefficient = 1) //when the blob expands, do this
	return

/datum/blobstrain/proc/tesla_reaction(obj/structure/blob/B, power, coefficient = 1) //when the blob is hit by a tesla bolt, do this
	return TRUE //return 0 to ignore damage

/datum/blobstrain/proc/extinguish_reaction(obj/structure/blob/B, coefficient = 1) //when the blob is hit with water, do this
	return

/datum/blobstrain/proc/emp_reaction(obj/structure/blob/B, severity, coefficient = 1) //when the blob is hit with an emp, do this
	return

/datum/blobstrain/proc/examine(mob/user)
	return list("<b>Progress to Critical Mass:</b> [span_notice("[overmind.blobs_legit.len]/[overmind.blobwincount].")]")

/datum/blobstrain/proc/on_blobmob_atom_interacted(mob/living/minion, atom/interacted_atom, adjacent, modifiers)
	return
