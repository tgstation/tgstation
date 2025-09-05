/datum/quirk/erratic
	name = "Erratic"
	desc = "You can never seem to nail down your personality."
	icon = FA_ICON_MASKS_THEATER
	value = -2
	medical_record_text = "Patient has a bipolar personality disorder."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES
	hardcore_value = 2
	mail_goodies = list(/obj/item/storage/pill_bottle/psicodine)
	/// Cooldown between personality randomizations
	COOLDOWN_DECLARE(randomize_cooldown)
	/// Personalities before the quirk was applied
	VAR_PRIVATE/list/base_personalities
	/// Every other randomization, revert to base personality
	var/random_index = 0

/datum/quirk/erratic/add(client/client_source)
	base_personalities = LAZYCOPY(quirk_holder.personalities)
	COOLDOWN_START(src, randomize_cooldown, rand(5, 10) MINUTES)

/datum/quirk/erratic/remove()
	replace_personalities(base_personalities)

/datum/quirk/erratic/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, randomize_cooldown))
		return
	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS) || quirk_holder.stat >= UNCONSCIOUS)
		return

	COOLDOWN_START(src, randomize_cooldown, rand(6, 12) MINUTES)

	random_index += 1
	if(random_index % 2 == 0)
		replace_personalities(base_personalities)
		random_index = 0
		to_chat(quirk_holder, span_notice("You feel... normal."))
		return

	for(var/existing in quirk_holder.personalities)
		var/datum/personality/existing_datum = SSpersonalities.personalities_by_type[existing]
		existing_datum.remove_from_mob(quirk_holder)

	var/list/personality_pool = SSpersonalities.personalities_by_type.Copy()
	var/num = rand(CONFIG_GET(number/max_personalities) - 2, CONFIG_GET(number/max_personalities) + 1)
	var/i = 1
	while(i <= num)
		if(!length(personality_pool))
			break
		var/picked_type = pick(personality_pool)
		if(SSpersonalities.is_incompatible(quirk_holder.personalities, picked_type))
			continue
		var/datum/personality/picked_datum = personality_pool[picked_type]
		picked_datum.apply_to_mob(quirk_holder)
		personality_pool -= picked_type
		i += 1
	to_chat(quirk_holder, span_notice("You feel... different."))

/datum/quirk/erratic/proc/replace_personalities(list/new_personalities)
	for(var/existing in quirk_holder.personalities)
		var/datum/personality/existing_datum = SSpersonalities.personalities_by_type[existing]
		existing_datum.remove_from_mob(quirk_holder)
	for(var/incoming in new_personalities)
		var/datum/personality/incoming_datum = SSpersonalities.personalities_by_type[incoming]
		incoming_datum.apply_to_mob(quirk_holder)
