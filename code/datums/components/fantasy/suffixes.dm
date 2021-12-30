/datum/fantasy_affix/cosmetic_suffixes
	name = "purely cosmetic suffix"
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
	name = "of <mobtype> slaying (random species, carbon or simple animal)"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD
	var/list/target_types_by_comp = list()

/datum/fantasy_affix/bane/apply(datum/component/fantasy/comp, newName)
	. = ..()
	// This is set up to be easy to add to these lists as I expect it will need modifications
	var/static/list/possible_mobtypes
	if(!possible_mobtypes)
		// The base list of allowed mob/species types
		possible_mobtypes = typecacheof(
			list(
				/mob/living/simple_animal = TRUE,
				/mob/living/carbon = TRUE,
				/datum/species = TRUE,
				// Some types to remove them and their subtypes
				/mob/living/carbon/human/species = FALSE,
			),
			zebra = TRUE
		)
		// Some particular types to disallow if they're too broad/abstract
		// Not in the above typecache generator because they it includes subtypes and this doesn't.
		possible_mobtypes -= list(
			/mob/living/simple_animal/hostile,
		)

	var/mob/picked_mobtype = pick(possible_mobtypes)
	// This works even with the species picks since we're only accessing the name

	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/bane, picked_mobtype)
	target_types_by_comp[comp] = picked_mobtype
	return "[newName] of [initial(picked_mobtype.name)] slaying"

/datum/fantasy_affix/bane/remove(datum/component/fantasy/comp)
	var/picked_mobtype = target_types_by_comp[comp]
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/bane, picked_mobtype)
	target_types_by_comp -= comp

/datum/fantasy_affix/summoning
	name = "of <mobtype> summoning (dangerous, can pick all but megafauna tier stuff)"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD
	weight = 5

/datum/fantasy_affix/summoning/apply(datum/component/fantasy/comp, newName)
	. = ..()
	// This is set up to be easy to add to these lists as I expect it will need modifications
	var/static/list/possible_mobtypes
	if(!possible_mobtypes)
		// The base list of allowed mob/species types
		possible_mobtypes = typecacheof(
			list(
				/mob/living/simple_animal = TRUE,
				/mob/living/carbon = TRUE,
				/datum/species = TRUE,
				// Some types to remove them and their subtypes
				/mob/living/carbon/human/species = FALSE,
				/mob/living/simple_animal/hostile/syndicate/mecha_pilot = FALSE,
				/mob/living/simple_animal/hostile/asteroid/elite = FALSE,
				/mob/living/simple_animal/hostile/megafauna = FALSE,
			),
			zebra = TRUE
		)
		// Some particular types to disallow if they're too broad/abstract
		// Not in the above typecache generator because they it includes subtypes and this doesn't.
		possible_mobtypes -= list(
			/mob/living/simple_animal/hostile,
		)

	var/mob/picked_mobtype = pick(possible_mobtypes)
	// This works even with the species picks since we're only accessing the name

	var/obj/item/master = comp.parent
	var/max_mobs = max(CEILING(comp.quality/2, 1), 1)
	var/spawn_delay = 300 - 30 * comp.quality
	comp.appliedComponents += master.AddComponent(/datum/component/summoning, list(picked_mobtype), 100, max_mobs, spawn_delay)
	return "[newName] of [initial(picked_mobtype.name)] summoning"

/datum/fantasy_affix/shrapnel
	name = "shrapnel"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/shrapnel/validate(obj/item/attached)
	if(isgun(attached))
		return TRUE
	return FALSE

/datum/fantasy_affix/shrapnel/apply(datum/component/fantasy/comp, newName)
	. = ..()
	// higher means more likely
	var/list/weighted_projectile_types = list(/obj/projectile/meteor = 1,
											  /obj/projectile/energy/nuclear_particle = 1,
											  /obj/projectile/beam/pulse = 1,
											  /obj/projectile/bullet/honker = 15,
											  /obj/projectile/temp = 15,
											  /obj/projectile/ion = 15,
											  /obj/projectile/magic/door = 15,
											  /obj/projectile/magic/locker = 15,
											  /obj/projectile/magic/fetch = 15,
											  /obj/projectile/beam/emitter = 15,
											  /obj/projectile/magic/flying = 15,
											  /obj/projectile/energy/net = 15,
											  /obj/projectile/bullet/incendiary/c9mm = 15,
											  /obj/projectile/temp/hot = 15,
											  /obj/projectile/beam/disabler = 15)

	var/obj/projectile/picked_projectiletype = pick_weight(weighted_projectile_types)

	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/mirv, picked_projectiletype)
	return "[newName] of [initial(picked_projectiletype.name)] shrapnel"

/datum/fantasy_affix/strength
	name = "of strength (knockback)"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_GOOD

/datum/fantasy_affix/strength/apply(datum/component/fantasy/comp, newName)
	. = ..()
	var/obj/item/master = comp.parent
	master.AddElement(/datum/element/knockback, CEILING(comp.quality/2, 1), FLOOR(comp.quality/10, 1))
	return "[newName] of strength"

/datum/fantasy_affix/strength/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/knockback, CEILING(comp.quality/2, 1), FLOOR(comp.quality/10, 1))

//////////// Bad suffixes

/datum/fantasy_affix/fool
	name = "of the fool (honking)"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/fool/apply(datum/component/fantasy/comp, newName)
	. = ..()
	var/obj/item/master = comp.parent
	comp.appliedComponents += master.AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20)
	return "[newName] of the fool"

/datum/fantasy_affix/curse_of_hunger
	name = "curse of hunger"
	placement = AFFIX_SUFFIX
	alignment = AFFIX_EVIL

/datum/fantasy_affix/curse_of_hunger/validate(obj/item/attached)
	//curse of hunger that attaches onto food has the ability to eat itself. it's hilarious.
	if(!IS_EDIBLE(attached))
		return TRUE
	return TRUE

/datum/fantasy_affix/curse_of_hunger/apply(datum/component/fantasy/comp, newName)
	. = ..()
	var/obj/item/master = comp.parent
	var/filter_color = "#8a0c0ca1" //clarified args
	var/new_name = pick(", eternally hungry", " of the glutton", " cursed with hunger", ", consumer of all", " of the feast")
	master.AddElement(/datum/element/curse_announcement, "[master] is cursed with the curse of hunger!", filter_color, new_name, comp)
	var/add_dropdel = FALSE //clarified boolean
	comp.appliedComponents += master.AddComponent(/datum/component/curse_of_hunger, add_dropdel)
	return newName //no spoilers!

/datum/fantasy_affix/curse_of_hunger/remove(datum/component/fantasy/comp)
	var/obj/item/master = comp.parent
	master.RemoveElement(/datum/element/curse_announcement) //just in case
