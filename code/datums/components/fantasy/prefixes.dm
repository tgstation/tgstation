/datum/fantasy_affix/cosmetic_prefixes
	name = "purely cosmetic prefix"
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
	name = "tactical"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 1 // Very powerful, no one should have such power

/datum/fantasy_affix/tactical/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/tactical)
	return "tactical [newName]"

/datum/fantasy_affix/pyromantic
	name = "pyromantic"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/pyromantic/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/igniter, clamp(comp.quality, 1, 10))
	return "pyromantic [newName]"

/datum/fantasy_affix/vampiric
	name = "vampiric"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 5

/datum/fantasy_affix/vampiric/validate(obj/item/attached)
	return attached.force //don't apply to things that just bap people

/datum/fantasy_affix/vampiric/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/lifesteal, comp.quality)
	return "vampiric [newName]"

/datum/fantasy_affix/vampiric/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/lifesteal, comp.quality)

/datum/fantasy_affix/beautiful
	name = "beautiful"
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
	name = "ugly"
	placement = AFFIX_PREFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/ugly/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/beauty, min(comp.quality, -1) * 250)
	return "[pick("fugly", "ugly", "grotesque", "hideous")] [newName]"

/datum/fantasy_affix/ugly/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/beauty, min(comp.quality, -1) * 250)

/datum/fantasy_affix/venomous
	name = "<poisonname>-laced (picked from small pool of toxins)"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/venomous/validate(obj/item/attached)
	return attached.force //don't apply to things that just bap people

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
		/datum/reagent/toxin/plantbgone = "plantbane",
		/datum/reagent/toxin/mutetoxin = "mimemind",
		/datum/reagent/toxin/amanitin = "dormant death",
		/datum/reagent/toxin/lipolicide = "famineblood",
		/datum/reagent/toxin/spewium = "gulchergut",
		/datum/reagent/toxin/heparin = "jabberwound",
		/datum/reagent/toxin/rotatium = "spindown",
		/datum/reagent/toxin/histamine = "creeping malaise"
	)
	var/poisonname = names[picked_poison]
	master.AddElement(/datum/element/venomous, picked_poison, comp.quality+1)
	//seriously don't @ me about the correct use of venom vs poison. shut up.
	return "[poisonname]-[pick("poisoned", "envenomed", "laced")] [newName]"

/datum/fantasy_affix/venomous/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/venomous)

/datum/fantasy_affix/soul_stealer
	name = "soul-stealing"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/soul_stealer/validate(obj/item/attached)
	if(attached.force)
		return FALSE
	if(attached.atom_storage)
		return FALSE
	return TRUE

/datum/fantasy_affix/soul_stealer/apply(datum/component/fantasy/comp, newName)
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/soul_stealer)
	return "soul-[pick("stealing", "hungering", "devouring")] [newName]"

// On hitting a mob chain lightning will jump to another mob within 2 tiles of the original target
/datum/fantasy_affix/thunderfury
	name = "Thunderfury"
	placement = AFFIX_PREFIX
	alignment = AFFIX_GOOD
	weight = 3

/datum/fantasy_affix/thunderfury/apply(datum/component/fantasy/comp, newName)
	comp.parent.AddElement(/datum/element/chain_lightning_attack, get_damage(comp), get_range(comp), get_limit(comp))
	return "Thunderfury, Blessed [newName]"

/datum/fantasy_affix/thunderfury/remove(datum/component/fantasy/comp)
	comp.parent.RemoveElement(/datum/element/chain_lightning_attack, get_damage(comp), get_range(comp), get_limit(comp))

/datum/fantasy_affix/thunderfury/proc/get_damage(datum/component/fantasy/comp)
	return min(round(comp.quality, 2), 20)

/datum/fantasy_affix/thunderfury/proc/get_range(datum/component/fantasy/comp)
	return min(round(sqrt(comp.quality), 1), 3)

/datum/fantasy_affix/thunderfury/proc/get_limit(datum/component/fantasy/comp)
	return min(round(sqrt(comp.quality), 1), 3)
