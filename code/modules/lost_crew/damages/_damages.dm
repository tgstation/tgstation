// Unique damage types we can apply for blacklisting, so we dont remove all organs twice etc
#define CORPSE_DAMAGE_ORGAN_DECAY "organ decay"
#define CORPSE_DAMAGE_ORGAN_LOSS "organ loss"
#define CORPSE_DAMAGE_LIMB_LOSS "limb loss"

/// The main style controller for new dead bodies! Determines the character, lore, possible causes of death, decay and every other modifier!
/datum/corpse_damage_class
	/// Message sent to the recovered crew, constructed from the different death lores
	var/list/death_lore = list()
	/// Lore we give on revival, this is the first line
	var/area_lore = "I was doing something"
	/// Weight given to this class. Setting this is all that's needed for it to be rollable
	var/weight
	/// Different character archetypes we can spawn
	var/list/possible_character_types
	/// Assignments that can be given to the corpse
	var/list/possible_character_assignments
	/// Whatever killed us
	var/list/possible_causes_of_death
	/// Goddamn space vultures stealing my organs
	var/list/post_mortem_effects
	/// A random decay we apply. Defined here so we can vary it (i.e. a spaced body has less decay than one in a warm jungle)
	var/list/decays = list(/datum/corpse_damage/post_mortem/organ_decay)
	/// When healthscanned, this is the minimum time that shows
	var/lore_death_time_min = 1 DAYS
	/// When healthscanned, this is the maximum time that shows
	var/lore_death_time_max = 5 YEARS

/// Generate and apply a possible character (species etc)
/datum/corpse_damage_class/proc/apply_character(mob/living/carbon/human/fashion_corpse, list/protected_objects, list/datum/callback/on_revive_and_player_occupancy, list/body_data)
	var/datum/corpse_character/character = pick_weight(possible_character_types)
	character = new character()
	character.apply_character(fashion_corpse, protected_objects, on_revive_and_player_occupancy)

	var/datum/corpse_assignment/assignment = pick_weight(possible_character_assignments)
	if(assignment)
		assignment = new assignment()
		assignment.apply_assignment(fashion_corpse, protected_objects, on_revive_and_player_occupancy)

	death_lore += assignment?.job_lore

	body_data += character.type
	body_data += assignment?.type

/// Set up injuries
/datum/corpse_damage_class/proc/apply_injuries(mob/living/carbon/human/victim, list/saved_objects, list/datum/callback/on_revive_and_player_occupancy, list/body_data)
	var/datum/corpse_damage/cause_of_death/cause_of_death = pick_damage_type(possible_causes_of_death)
	cause_of_death.apply_to_body(victim, rand(), saved_objects, on_revive_and_player_occupancy)

	var/datum/corpse_damage/post_mortem = pick_damage_type(post_mortem_effects)
	post_mortem?.apply_to_body(victim, rand(), saved_objects, on_revive_and_player_occupancy)

	var/datum/corpse_damage/decay = pick_damage_type(decays)
	decay?.apply_to_body(victim, rand(), saved_objects, on_revive_and_player_occupancy)

	// Simulate bloodloss by dragging/moving
	victim.blood_volume = max(victim.blood_volume - victim.bleedDragAmount() * rand(20, 100), 0)
	set_death_date(victim)

	body_data += cause_of_death.type
	body_data += post_mortem?.type
	body_data += decay.type

	death_lore += area_lore + " " + cause_of_death.cause_of_death

/// Wrapped pickweight so we can have a bit more controle over how we pick our rules
/datum/corpse_damage_class/proc/pick_damage_type(list/damages, list/used_damage_types)
	var/list/possible_damages = list()

	for(var/datum/corpse_damage/damage as anything in damages)
		if(isdatum(damage) && damage.damage_type && (damage.damage_type in used_damage_types))
			continue
		possible_damages[damage] = damages[damage]

	var/datum/corpse_damage/chosen = pick_weight(possible_damages)
	if(!ispath(chosen)) //can also be null for some variants
		return null

	chosen = new chosen()

	if(chosen.damage_type)
		used_damage_types += chosen.damage_type
	return chosen

/// Soulfully give a date of death for health analyzers
/datum/corpse_damage_class/proc/set_death_date(mob/living/carbon/body)
	var/died_how_long_ago = rand(lore_death_time_min, lore_death_time_max)
	body.timeofdeath = world.time - died_how_long_ago

	var/death_real_time = world.realtime - died_how_long_ago
	var/current_date = time2text(death_real_time, "DD Month")
	var/current_year = text2num(time2text(death_real_time, "YYYY")) + STATION_YEAR_OFFSET
	body.station_timestamp_timeofdeath = "[current_date] [current_year]"

/// Main corpse damage type that's used to apply damages to a body
/datum/corpse_damage
	/// When given, automatically blacklist corpse_damages with the same damage_type flag to avoid stuff like being delimbed twice (dragon ate me AND I got space vultures???)
	var/damage_type

/// Tear IT UPPP!!! Apply any damages to the body that we need to
/datum/corpse_damage/proc/apply_to_body(mob/living/carbon/human/body, severity, list/storage)
	return

/// This is the reason we died
/datum/corpse_damage/cause_of_death
	/// I was in x, [when I ....]
	var/cause_of_death = "when I tripped and died."

/// Some post mortem damages from space vultures
/datum/corpse_damage/post_mortem
