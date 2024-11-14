/datum/heretic_knowledge_tree_column/moon_to_lock
	neighbour_type_left = /datum/heretic_knowledge_tree_column/main/moon
	neighbour_type_right = /datum/heretic_knowledge_tree_column/main/lock

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/spell/mind_gate
	tier2 = list(/datum/heretic_knowledge/unfathomable_curio, /datum/heretic_knowledge/painting)
	tier3 = /datum/heretic_knowledge/dummy_moon_to_lock

// Sidepaths for knowledge between Knock and Moon.

/datum/heretic_knowledge/dummy_moon_to_lock
	name = "Lock and Moon ways"
	desc = "Research this to gain access to the other path"
	gain_text = "The powers of Madness are like a wound in one's soul, and every wound can be opened and closed."
	cost = 1



/datum/heretic_knowledge/spell/mind_gate
	name = "Mind Gate"
	desc = "Grants you Mind Gate, a spell which inflicts hallucinations, \
		confusion, oxygen loss and brain damage to its target over 10 seconds.\
		The caster takes 20 brain damage per use."
	gain_text = "My mind swings open like a gate, and its insight will let me perceive the truth."

	spell_to_add = /datum/action/cooldown/spell/pointed/mind_gate
	cost = 1

/datum/heretic_knowledge/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "Allows you to transmute 3 rods, lungs and any belt into an Unfathomable Curio, \
			a belt that can hold blades and items for rituals. Whilst worn it will also \
			veil you, allowing you to take 5 hits without suffering damage, this veil will recharge very slowly \
			outside of combat."
	gain_text = "The mansus holds many a curio, some are not meant for the mortal eye."

	required_atoms = list(
		/obj/item/organ/lungs = 1,
		/obj/item/stack/rods = 3,
		/obj/item/storage/belt = 1,
	)
	result_atoms = list(/obj/item/storage/belt/unfathomable_curio)
	cost = 1

	research_tree_icon_path = 'icons/obj/clothing/belts.dmi'
	research_tree_icon_state = "unfathomable_curio"


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

	required_atoms = list(/obj/item/canvas = 1)
	result_atoms = list(/obj/item/canvas)
	cost = 1

	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"


/datum/heretic_knowledge/painting/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(locate(/obj/item/organ/eyes) in atoms)
		src.result_atoms = list(/obj/item/wallframe/painting/eldritch/weeping)
		src.required_atoms = list(
			/obj/item/canvas = 1,
			/obj/item/organ/eyes = 1,
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
