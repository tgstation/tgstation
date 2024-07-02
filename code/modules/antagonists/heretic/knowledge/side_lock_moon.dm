// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell which inflicts hallucinations, \
		confusion, oxygen loss and brain damage to its target over 10 seconds.\
		The caster takes 20 brain damage per use."
	gain_text = "My mind swings open like a gate, and its insight will let me perceive the truth."
	next_knowledge = list(
		/datum/heretic_knowledge/key_ring,
		/datum/heretic_knowledge/spell/moon_smile,
	)
	spell_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 1
	route = PATH_SIDE
	depth = 4

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs and any belt into an Unfathomable Curio, \
			a belt that can hold blades and items for rituals. Whilst worn it will also \
			veil you, allowing you to take 5 hits without suffering damage, this veil will recharge very slowly \
			outside of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/moon_amulet,
	)
	required_atoms = list(
		/obj/item/organ/internal/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1
	route = PATH_SIDE
	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"
	depth = 8

/datum/heretic_knowledge/painting
	name = "Unsealed Arts"
	desc = "Allows you to transmute a canvas and an additional item to create a painting. \
			Each painting has a unique effect and recipe. Possible paintings: \
			The Sister and He Who Wept: Requires a pair of Eyes. Clears your own mind, and curses non-heretics with hallucinations. \
			The Feast of Desire: Requires a severed limb. Supplies you with random organs, and curses non-heretics with a hunger for flesh. \
			Great Chaparral Over Rolling Hills: Requires any plant produce. Spreads kudzu when placed, and supplies you with poppies and harebells. \
			Lady of the Gate: Requires any pair of Gloves. Clears your mutations, mutates non-heretics and curses them with scratching. \
			Master of the Rusted Mountain: Requires a piece of Trash. Curses non-heretics to rust the floor they walk on."
	gain_text = "A wind of inspiration blows through me. Beyond the veil and past the gate great works exist, yet to be painted. \
				They yearn for mortal eyes, so I shall give them an audience."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/burglar_finesse,
		/datum/heretic_knowledge/moon_amulet,
	)
	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 1
	route = PATH_SIDE
	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"
	depth = 8

/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(locate(/obj/item/organ/internal/eyes) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/weeping)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/internal/eyes = 1,
		)
		return TRUE

	if(locate(/obj/item/bodypart) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/desire)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/bodypart = 1,
		)
		return TRUE

	if(locate(/obj/item/food/grown) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/vines)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/food/grown = 1,
		)
		return TRUE

	if(locate(/obj/item/clothing/gloves) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/beauty)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/clothing/gloves = 1,
		)
		return TRUE

	if(locate(/obj/item/trash) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/rust)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/trash = 1,
		)
		return TRUE

	user.balloon_alert(user, "no additional atom present!")
	return FALSE
