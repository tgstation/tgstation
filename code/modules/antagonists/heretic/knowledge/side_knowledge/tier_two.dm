/*!
 * Tier 2 knowledge: Defensive tools and curses
 */

/**
 * Codex Morbus, an upgrade to the base codex
 * Functionally an upgraded version of the codex, but it also has the ability to cast curses by right clicking at a rune.
 * Requires you to have the blood of your victim in your off-hand
 */
/datum/heretic_knowledge/codex_morbus
	name = "Codex Morbus"
	desc = "Allows you to to combine a codex cicatrix, and a body into a Codex Morbus. \
		It draws runes and siphons essences a bit faster. \
		Right Click on a rune to curse crewmembers, the target's blood is required in your off hand for a curse to take effect (Best combined with Phylactery Of Damnation)."
	gain_text = "The spine of this leather-bound tome creaks with an eerily pained sigh. \
		To ply page from place takes considerable effort, and I dare not linger on the suggestions the book makes for longer than necessary. \
		It speaks of coming plagues, of waiting supplicants of dead and forgotten gods, and the undoing of mortal kind. \
		It speaks of needles to peel the skin of the world back and leaving it to fester. And it speaks to me by name."
	required_atoms = list(
		/obj/item/codex_cicatrix = 1,
		/mob/living/carbon/human = 1,
	)
	result_atoms = list(/obj/item/codex_cicatrix/morbus)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "book_morbus"
	drafting_tier = 2

/datum/heretic_knowledge/codex_morbus/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/mob/living/carbon/human/to_fuck_up = locate() in selected_atoms
	for(var/_limb in to_fuck_up.bodyparts)
		var/obj/item/bodypart/limb = _limb
		limb.force_wound_upwards(/datum/wound/slash/flesh/critical)
	for(var/obj/item/bodypart/limb as anything in to_fuck_up.bodyparts)
		to_fuck_up.cause_wound_of_type_and_severity(WOUND_BLUNT, limb, WOUND_SEVERITY_CRITICAL)
	return TRUE

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Greaves Of The Prophet"
	desc = "Allows you to combine a pair of shoes and 2 sheets of titanium or silver into a pair of Armored Greaves, they confer to the user fully immunity to slips."
	gain_text = " \
		Gristle churns into joint, a pop, and the fool twists a blackened foot from the \
		jaws of another. At their game for centuries, this mangled tree of limbs twists, \
		thrashing snares buried into snarling gums, seeking to shred the weight of grafted \
		neighbors. Weighed down by lacerated feet, this canopy of rancid idiots ever seeks \
		the undoing of its own bonds. I dread the thought of walking in their wake, but \
		I must press on all the same. Their rhythms keep the feud fresh with indifference \
		to barrier or border. Pulling more into their turmoil as they waltz."
	required_atoms = list(
		/obj/item/clothing/shoes = 1,
		list(/obj/item/stack/sheet/mineral/titanium, /obj/item/stack/sheet/mineral/silver) = 2,
	)
	result_atoms = list(/obj/item/clothing/shoes/greaves_of_the_prophet)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/shoes.dmi'
	research_tree_icon_state = "hereticgreaves"
	drafting_tier = 2

/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby. \
		However, you will fall unconscious a short time after casting this spell."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."

	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Allows you to transmute a knife, a shard of glass, and a piece of paper to create a Carving Knife. \
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead. \
		Also makes for a handy throwing weapon."
	gain_text = "Etched, carved... eternal. There is power hidden in everything. I can unveil it! \
		I can carve the monolith to reveal the chains!"
	required_atoms = list(
		/obj/item/knife = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
	)
	result_atoms = list(/obj/item/melee/rune_carver)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "rune_carver"
	drafting_tier = 2

/datum/heretic_knowledge/ether
	name = "Ether Of The Newborn"
	desc = "Transmutes a pool of vomit and a shard into a single use potion, drinking it will remove any sort of abnormality from your body including diseases, traumas and implants \
		on top of restoring it to full health, at the cost of losing consciousness for an entire minute."
	gain_text = "Vision and thought grow hazy as the fumes of this ichor swirl up to meet me. \
		Through the haze, I find myself staring back in relief, or something grossly resembling my visage. \
		It is this wretched thing that I consign to my fate, and whose own that I snatch through the haze of dreams. Fools that we are."
	required_atoms = list(
		/obj/item/shard = 1,
		/obj/effect/decal/cleanable/vomit = 1,
	)
	result_atoms = list(/obj/item/ether)
	cost = 2
	research_tree_icon_path = 'icons/obj/antags/eldritch.dmi'
	research_tree_icon_state = "poison_flask"
	drafting_tier = 2

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
	cost = 2
	research_tree_icon_path = 'icons/obj/signs.dmi'
	research_tree_icon_state = "eldritch_painting_weeping"
	drafting_tier = 2

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
