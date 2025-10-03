/datum/personality/apathetic
	savefile_key = "apathetic"
	name = "Apathetic"
	desc = "I don't care about much. Not the good, nor the bad, and certainly not the ugly."
	neut_gameplay_desc = "All moodlets affect you less"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/apathetic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/apathetic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive
	savefile_key = "sensitive"
	name = "Sensitive"
	desc = "I am easily influenced by the world around me."
	neut_gameplay_desc = "All moodlets affect you more"
	groups = list(PERSONALITY_GROUP_MOOD_POWER)

/datum/personality/sensitive/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier += 0.2

/datum/personality/sensitive/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.mood_modifier -= 0.2

/datum/personality/resilient
	savefile_key = "resilient"
	name = "Resilient"
	desc = "It's whatever. I can take it!"
	pos_gameplay_desc = "Negative moodlets expire faster"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/resilient/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/resilient/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding
	savefile_key = "brooding"
	name = "Brooding"
	desc = "Everything gets to me and I can't help but think about it."
	neg_gameplay_desc = "Negative moodlets last longer"
	groups = list(PERSONALITY_GROUP_MOOD_LENGTH)

/datum/personality/brooding/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier += 0.2

/datum/personality/brooding/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.negative_moodlet_length_modifier -= 0.2

/datum/personality/hopeful
	savefile_key = "hopeful"
	name = "Hopeful"
	desc = "I believe things will always get better."
	pos_gameplay_desc = "Positive moodlets last longer"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/hopeful/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/hopeful/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic
	savefile_key = "pessimistic"
	name = "Pessimistic"
	desc = "I believe our best days are behind us."
	neg_gameplay_desc = "Positive moodlets last shorter"
	groups = list(PERSONALITY_GROUP_HOPE)

/datum/personality/pessimistic/apply_to_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier -= 0.2

/datum/personality/pessimistic/remove_from_mob(mob/living/who)
	. = ..()
	who.mob_mood?.positive_moodlet_length_modifier += 0.2

/datum/personality/whimsical
	savefile_key = "whimsical"
	name = "Whimsical"
	desc = "This station is too serious sometimes, lighten up!"
	pos_gameplay_desc = "Likes ostensibly pointless but silly things, and does not mind clownish pranks"

/datum/personality/snob
	savefile_key = "snob"
	name = "Snobbish"
	desc = "I expect only the best out of this station - anything less is unacceptable!"
	neut_gameplay_desc = "Room quality affects your mood"
	personality_trait = TRAIT_SNOB
