/datum/fantasy_affix/cosmetic_prefixes
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD | AFFIX_EVIL

	var/list/goodPrefixes
	var/list/badPrefixes

/datum/fantasy_affix/cosmetic_prefixes/New()
	goodPrefixes = list(
		"greater",
		"major",
		"blessed",
		"superior",
		"empowered",
		"honed",
		"true",
		"glorious",
		"robust",
		)
	badPrefixes = list(
		"lesser",
		"minor",
		"blighted",
		"inferior",
		"enfeebled",
		"rusted",
		"unsteady",
		"tragic",
		"gimped",
		"cursed",
		)

	weight = (length(goodPrefixes) + length(badPrefixes)) * 10

/datum/fantasy_affix/cosmetic_prefixes/apply(datum/component/fantasy/comp, newName)
	if(comp.quality > 0 || (comp.quality == 0 && prob(50)))
		return "[pick(goodPrefixes)] [newName]"
	else
		return "[pick(badPrefixes)] [newName]"

/datum/fantasy_affix/tactical
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 1 // Very powerful, no one should have such power

/datum/fantasy_affix/tactical/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/tactical)
	return "tactical [newName]"

/datum/fantasy_affix/pyromantic
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/pyromantic/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/igniter, clamp(comp.quality, 1, 10))
	return "pyromantic [newName]"

/datum/fantasy_affix/vampiric
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 5

/datum/fantasy_affix/vampiric/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/lifesteal, comp.quality)
	return "vampiric [newName]"

/datum/fantasy_affix/beautiful
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/beautiful/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/beauty, max(comp.quality, 1) * 250)
	return "[pick("aesthetic", "beautiful", "gorgeous", "pretty")] [newName]"

/datum/fantasy_affix/beautiful/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/beauty, max(comp.quality, 1) * 250)

/datum/fantasy_affix/ugly
	placement = AFFIX_PREFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/ugly/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/beauty, min(comp.quality, -1) * 250)
	return "[pick("fugly", "ugly", "grotesque", "hideous")] [newName]"

/datum/fantasy_affix/ugly/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/beauty, min(comp.quality, -1) * 250)

/datum/fantasy_affix/venomous
	placement = AFFIX_PREFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/venomous/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	var/picked_poison = pick(list(
		/datum/reagent/toxin/plantbgone,
		/datum/reagent/toxin/mutetoxin,
		/datum/reagent/toxin/amanitin,
		/datum/reagent/toxin/lipolicide,
		/datum/reagent/toxin/spewium,
		/datum/reagent/toxin/heparin,
		/datum/reagent/toxin/rotatium,
		/datum/reagent/toxin/histamine
	))
	var/list/names = list(
		/datum/reagent/toxin/plantbgone = "Plantbane",
		/datum/reagent/toxin/mutetoxin = "Mimemind",
		/datum/reagent/toxin/amanitin = "Dormant Death",
		/datum/reagent/toxin/lipolicide = "Famineblood",
		/datum/reagent/toxin/spewium = "Gulchergut",
		/datum/reagent/toxin/heparin = "Jabberwound",
		/datum/reagent/toxin/rotatium = "Spindown",
		/datum/reagent/toxin/histamine = "Creeping Malaise"
	)
	var/poisonname = names[picked_poison]
	comp.appliedComponents += master.AddComponent(/datum/component/poisonous, picked_poison, 5)
	//seriously don't @ me about the correct use of venom vs poison and toxin. shut up.
	return "[poisonname] [pick("toxin", "poison", "venom")] [newName]"
