/datum/quirk/erratic
	name = "Erratic"
	desc = "You mood swings like a pendulum, causing your personality to change on a whim every so often."
	icon = FA_ICON_MASKS_THEATER
	value = -3
	gain_text = span_danger("You feel erratic.") // say that again?
	lose_text = span_notice("You feel more stable.")
	medical_record_text = "Patient has a bipolar personality disorder."
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_MOODLET_BASED|QUIRK_PROCESSES
	hardcore_value = 3
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
	if(!QDELING(quirk_holder))
		announce_personality_change()

/datum/quirk/erratic/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, randomize_cooldown))
		return
	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS) || quirk_holder.stat >= UNCONSCIOUS)
		return

	COOLDOWN_START(src, randomize_cooldown, rand(6, 12) MINUTES)
	randomize_personalities()

/datum/quirk/erratic/proc/randomize_personalities()
	random_index += 1
	if(random_index % 2 == 0)
		random_index = 0
		replace_personalities(base_personalities)
		to_chat(quirk_holder, span_notice("You feel... normal."))
		announce_personality_change()
		return

	var/max = CONFIG_GET(number/max_personalities)
	var/list/new_personality = prob(1) ? list() : SSpersonalities.select_random_personalities(max - 2, max + 1)
	replace_personalities(new_personality)
	to_chat(quirk_holder, span_notice("You feel... different."))
	announce_personality_change()

/datum/quirk/erratic/proc/replace_personalities(list/new_personalities)
	quirk_holder.clear_personalities()
	quirk_holder.add_personalities(new_personalities)

/datum/quirk/erratic/proc/announce_personality_change()
	var/list/new_personality = list()
	for(var/datum/personality/personality_type as anything in quirk_holder.personalities)
		new_personality += initial(personality_type.name)
	to_chat(quirk_holder, span_green("Your personality is now: [english_list(new_personality)]."))
