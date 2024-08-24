#define PROCESSES_PER_HEAL 5
/datum/artifact_effect/heal
	weight = ARTIFACT_VERYUNCOMMON
	type_name = "Single Healer Effect"
	activation_message = "starts emitting a soothing aura!"
	deactivation_message = "becomes silent."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)

	examine_discovered = span_warning("It appears to heal those who touch it.")

	///list of damage types we heal, this is randomly removed from at setup
	var/list/damage_types = list(
		BRUTE,
		BURN,
		TOX,
		OXY,
		BRAIN,
		CLONE,
	)
	///how much do we heal
	var/heal_amount
	///process count
	var/process_count = 0
	COOLDOWN_DECLARE(heal_cooldown)

/datum/artifact_effect/heal/setup()
	heal_amount = rand(1,15)
	potency += heal_amount
	var/type_amount = prob(75) ? 4 : rand(2,4) //75% to remove 4 types for 1 heal type or 25% for 2 or 4 types removed
	while(type_amount)
		type_amount--
		damage_types -= pick(damage_types)
	potency += 5 * (length(damage_types) - 1)

/datum/artifact_effect/heal/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, heal_cooldown))
		return
	var/damage_length = length(damage_types)
	for(var/dam_type in damage_types)
		user.heal_damage_type( (heal_amount / damage_length), dam_type)
	to_chat(user, span_notice("You feel slightly refreshed!"))
	new /obj/effect/temp_visual/heal(get_turf(user), COLOR_HEALING_CYAN)
	COOLDOWN_START(src, heal_cooldown, 5 SECONDS)

/datum/artifact_effect/heal/effect_process()
	if(potency < 75)
		return

	process_count++
	if(process_count < PROCESSES_PER_HEAL)
		return
	process_count = 0

	for(var/mob/living/carbon/user in view(5, src))
		var/damage_length = length(damage_types)
		for(var/dam_type in damage_types)
			user.heal_damage_type( (heal_amount / damage_length), dam_type)
		to_chat(user, span_notice("You feel slightly refreshed!"))
		new /obj/effect/temp_visual/heal(get_turf(user), COLOR_HEALING_CYAN)

#undef PROCESSES_PER_HEAL
