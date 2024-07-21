// Sidepaths for knowledge between Ash and Flesh.
/datum/heretic_knowledge/medallion
	name = "Ashen Eyes"
	desc = "Allows you to transmute a pair of eyes, a candle, and a glass shard into an Eldritch Medallion. \
		The Eldritch Medallion grants you thermal vision while worn, and also functions as a focus."
	gain_text = "Piercing eyes guided them through the mundane. Neither darkness nor terror could stop them."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/ash_passage,
		/datum/heretic_knowledge/spell/moon_smile,
	)
	required_atoms = list(
		/obj/item/organ/internal/eyes = 1,
		/obj/item/shard = 1,
		/obj/item/flashlight/flare/candle = 1,
	)
	result_atoms = list(/obj/item/clothing/neck/eldritch_amulet)
	cost = 1
	route = PATH_SIDE
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "eye_medalion"
	depth = 4

/datum/heretic_knowledge/curse/paralysis
	name = "Curse of Paralysis"
	desc = "Allows you to transmute a hatchet and both a left and right leg to cast a curse of immobility on a crew member. \
		While cursed, the victim will be unable to walk. You can additionally supply an item that a victim has touched \
		or is covered in the victim's blood to make the curse last longer."
	gain_text = "The flesh of humanity is weak. Make them bleed. Show them their fragility."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/moon_amulet,
	)
	required_atoms = list(
		/obj/item/bodypart/leg/left = 1,
		/obj/item/bodypart/leg/right = 1,
		/obj/item/hatchet = 1,
	)
	duration = 3 MINUTES
	duration_modifier = 2
	curse_color = "#f19a9a"
	cost = 1
	route = PATH_SIDE
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "curse_paralysis"
	depth = 8

/datum/heretic_knowledge/curse/paralysis/curse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(chosen_mob.usable_legs <= 0) // What're you gonna do, curse someone who already can't walk?
		to_chat(chosen_mob, span_notice("You feel a slight pain for a moment, but it passes shortly. Odd."))
		return

	to_chat(chosen_mob, span_danger("You suddenly lose feeling in your leg[chosen_mob.usable_legs == 1 ? "":"s"]!"))
	chosen_mob.add_traits(list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG), type)
	return ..()

/datum/heretic_knowledge/curse/paralysis/uncurse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.remove_traits(list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG), type)
	if(chosen_mob.usable_legs > 1)
		to_chat(chosen_mob, span_green("You regain feeling in your leg[chosen_mob.usable_legs == 1 ? "":"s"]!"))
	return ..()

/datum/heretic_knowledge/summon/ashy
	name = "Ashen Ritual"
	desc = "Allows you to transmute a head, a pile of ash, and a book to create an Ash Spirit. \
		Ash Spirits have a short range jaunt and the ability to cause bleeding in foes at range. \
		They also have the ability to create a ring of fire around themselves for a length of time."
	gain_text = "I combined my principle of hunger with my desire for destruction. The Marshal knew my name, and the Nightwatcher gazed on."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/flame_birth,
		/datum/heretic_knowledge/spell/moon_ringleader,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/bodypart/head = 1,
		/obj/item/book = 1,
		)
	mob_to_summon = /mob/living/basic/heretic_summon/ash_spirit
	cost = 1
	route = PATH_SIDE
	poll_ignore_define = POLL_IGNORE_ASH_SPIRIT
	depth = 10

/datum/heretic_knowledge/summon/ashy/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
