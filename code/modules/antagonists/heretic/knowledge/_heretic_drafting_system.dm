/**
 * Randomly generated side knowledge based on tiers
 */

/datum/heretic_knowledge/drafting
	name = "Drafted knowledge"
	desc = "If you can see this, that means some knowledge failed to generate somehow"
	cost = 0
	abstract_parent_type = /datum/heretic_knowledge/drafting
	/// List of all knowledge we are elligible to pull from
	var/list/elligible_research = list()

/datum/heretic_knowledge/drafting/New()
	. = ..()
	GLOB.heretic_knowledge_tier_one.Copy()
	GLOB.heretic_knowledge_tier_two.Copy()
	GLOB.heretic_knowledge_tier_three.Copy()
	GLOB.heretic_knowledge_tier_four.Copy()
	GLOB.heretic_knowledge_tier_five.Copy()

/datum/heretic_knowledge/drafting/one
/datum/heretic_knowledge/drafting/two
/datum/heretic_knowledge/drafting/three
/datum/heretic_knowledge/drafting/four

// XANTODO Make heretic knowledge tree for each heretic instead of global
