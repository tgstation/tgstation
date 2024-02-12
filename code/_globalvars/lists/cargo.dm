GLOBAL_LIST_INIT(discountable_packs, init_discountable_packs())

/proc/init_discountable_packs()
	var/list/packs = list()
	for(var/datum/supply_pack/prototype as anything in subtypesof(/datum/supply_pack))
		var/discountable = initial(prototype.discountable)
		if(discountable)
			LAZYADD(packs[discountable], prototype)
	return packs

GLOBAL_LIST_INIT(pack_discount_odds, list(
	SUPPLY_PACK_STD_DISCOUNTABLE = 45,
	SUPPLY_PACK_UNCOMMON_DISCOUNTABLE = 4,
	SUPPLY_PACK_RARE_DISCOUNTABLE = 1,
))

GLOBAL_LIST_EMPTY(supplypod_loading_bays)

GLOBAL_LIST_INIT(podstyles, list(\
	list(POD_SHAPE_NORML, "pod",         TRUE, "default", "yellow",   RUBBLE_NORMAL, "supply pod",     "A Nanotrasen supply drop pod."),\
	list(POD_SHAPE_NORML, "advpod",      TRUE, "bluespace", "blue",     RUBBLE_NORMAL, "bluespace supply pod" ,     "A Nanotrasen Bluespace supply pod. Teleports back to CentCom after delivery."),\
	list(POD_SHAPE_NORML, "advpod",      TRUE, "centcom", "blue",     RUBBLE_NORMAL, "\improper CentCom supply pod", "A Nanotrasen supply pod, this one has been marked with Central Command's designations. Teleports back to CentCom after delivery."),\
	list(POD_SHAPE_NORML, "darkpod",     TRUE, "syndicate", "red",      RUBBLE_NORMAL, "blood-red supply pod", "An intimidating supply pod, covered in the blood-red markings of the Syndicate. It's probably best to stand back from this."),\
	list(POD_SHAPE_NORML, "darkpod",     TRUE, "deathsquad", "blue",     RUBBLE_NORMAL, "\improper Deathsquad drop pod",     "A Nanotrasen drop pod. This one has been marked the markings of Nanotrasen's elite strike team."),\
	list(POD_SHAPE_NORML, "pod",         TRUE, "cultist", "red",      RUBBLE_NORMAL, "bloody supply pod",     "A Nanotrasen supply pod covered in scratch-marks, blood, and strange runes."),\
	list(POD_SHAPE_OTHER, "missile",     FALSE, FALSE, FALSE,   RUBBLE_THIN,     "cruise missile", "A big ass missile that didn't seem to fully detonate. It was likely launched from some far-off deep space missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."),\
	list(POD_SHAPE_OTHER, "smissile",    FALSE, FALSE,         FALSE,   RUBBLE_THIN,     "\improper Syndicate cruise missile", "A big ass, blood-red missile that didn't seem to fully detonate. It was likely launched from some deep space Syndicate missile silo. There appears to be an auxillery payload hatch on the side, though manually opening it is likely impossible."),\
	list(POD_SHAPE_OTHER, "box",         TRUE, FALSE,            FALSE,   RUBBLE_WIDE, "\improper Aussec supply crate", "An incredibly sturdy supply crate, designed to withstand orbital re-entry. Has 'Aussec Armory - 2532' engraved on the side."),\
	list(POD_SHAPE_NORML, "clownpod",    TRUE, "clown", "green",    RUBBLE_NORMAL, "\improper HONK pod",     "A brightly-colored supply pod. It likely originated from the Clown Federation."),\
	list(POD_SHAPE_OTHER, "orange",      TRUE, FALSE, FALSE,   RUBBLE_NONE,     "\improper Orange", "An angry orange."),\
	list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,     "\improper S.T.E.A.L.T.H. pod MKVII", "A supply pod that, under normal circumstances, is completely invisible to conventional methods of detection. How are you even seeing this?"),\
	list(POD_SHAPE_OTHER, "gondola",     FALSE, FALSE, FALSE,   RUBBLE_NONE,     "gondola",     "The silent walker. This one seems to be part of a delivery agency."),\
	list(POD_SHAPE_OTHER, FALSE,         FALSE,    FALSE,            FALSE,   RUBBLE_NONE,         FALSE,      FALSE,      "rl_click", "give_po")\
))
