/datum/fantasy_affix/cosmetic_suffixes
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD | AFFIX_EVIL

	var/list/goodSuffixes
	var/list/badSuffixes

/datum/fantasy_affix/cosmetic_suffixes/New()
	goodSuffixes = list(
		"dexterity",
		"constitution",
		"intelligence",
		"wisdom", 
		"charisma",
		"the forest",
		"the hills", 
		"the plains", 
		"the sea", 
		"the sun", 
		"the moon", 
		"the void", 
		"the world", 
		"many secrets", 
		"many tales", 
		"many colors", 
		"rending", 
		"sundering", 
		"the night", 
		"the day",
		)
	badSuffixes = list(
		"draining",
		"burden",
		"discomfort",
		"awkwardness",
		"poor hygiene",
		"timidity",
		)

	weight = (length(goodSuffixes) + length(badSuffixes)) * 10

/datum/fantasy_affix/cosmetic_suffixes/apply(datum/component/fantasy/comp, newName)
	if(comp.quality > 0 || (comp.quality == 0 && prob(50)))
		return "[newName] of [pick(goodSuffixes)]"
	else
		return "[newName] of [pick(badSuffixes)]"

//////////// Good suffixes
/datum/fantasy_affix/bane
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD
	weight = 20

/datum/fantasy_affix/bane/apply(datum/component/fantasy/comp, newName)
	. = ..()
	// First a list of types and their subtypes which are allowed
	// Next a list of particular types removed, abstract in betweem types for example
	// Finally a list of types and their subtypes to remove
	// This is set up to be easy to add to these lists as I expect it will need modifications
	var/static/list/possible_mobtypes = typecacheof(list(
		/mob/living/simple_animal,
		/mob/living/carbon,
		)) - (list(
		/mob/living/simple_animal/hostile,
		) + typecacheof(list(
		/mob/living/carbon/human/species,
		)))

	var/mob/picked_mobtype = pick(possible_mobtypes)

	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/bane, picked_mobtype)
	return "[newName] of [initial(picked_mobtype.name)] slaying"

/datum/fantasy_affix/strength
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/strength/apply(datum/component/fantasy/comp, newName)
	. = ..()
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/knockback, CEILING(comp.quality/2, 1))
	return "[newName] of strength"

//////////// Bad suffixes

/datum/fantasy_affix/fool
	placement = AFFIX_SUFFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/fool/apply(datum/component/fantasy/comp, newName)
	. = ..()
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/squeak/bikehorn)
	return "[newName] of the fool"