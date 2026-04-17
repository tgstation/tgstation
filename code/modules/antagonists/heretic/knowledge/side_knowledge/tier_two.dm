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
	desc = "Author the Codex Morbus.<br>Draws runes and siphons essences a bit faster than a Codex Cicatrix.<br>\
		Right Click on a rune to curse crewmembers - the target's blood is required in your off hand for a curse to take effect \
		(Best combined with Phylactery Of Damnation)."
	transmute_text = "Transmute the Codex Cicatrix and a body into a Codex Morbus."
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
	for(var/_limb in to_fuck_up.get_bodyparts())
		var/obj/item/bodypart/limb = _limb
		limb.force_wound_upwards(/datum/wound/slash/flesh/critical)
	for(var/obj/item/bodypart/limb as anything in to_fuck_up.get_bodyparts())
		to_fuck_up.cause_wound_of_type_and_severity(WOUND_BLUNT, limb, WOUND_SEVERITY_CRITICAL)
	return TRUE

/datum/heretic_knowledge/greaves_of_the_prophet
	name = "Greaves of the Prophet"
	desc = "Forge a pair of Armored Greaves, which confer to the user full immunity to slips."
	transmute_text = "Transmute a pair of shoes and two sheets of titanium or silver."
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
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained.<br>\
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."
	required_atoms = list(
		/obj/item/clothing/suit/jacket/straight_jacket = 1,
	)
	action_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 2
	drafting_tier = 2
	max_charges = 1
	transmute_text = "To recharge, complete a ritual with a straight jacket."

/datum/heretic_knowledge/rune_carver
	name = "Carving Knife"
	desc = "Create a Carving Knife.<br>\
		The Carving Knife allows you to etch difficult to see traps that trigger on heathens who walk overhead.<br>\
		Also makes for a handy throwing weapon."
	transmute_text = "Transmute a knife, a shard of glass, and a piece of paper."
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
	desc = "Brews a single use potion.<br>Imbibing it will restore you to full health and \
		remove any sort of abnormality from your body (including diseases, traumas and implants) - \
		however, you will lose consciousness for a full minute."
	transmute_text = "Transmute a pool of vomit and a shard."
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
	desc = "Paint a curse into existence. \
		Each painting has a unique effect and recipe. \
		<br>&bull; The Sister and He Who Wept: Clears your mind, while cursing heathens with hallucinations. \
		<br>&bull; The Feast of Desire: Supplies you with random organs, while cursing heathens with a hunger for flesh. \
		<br>&bull; Great Chaparral Over Rolling Hills: Spreads kudzu when placed, and supplies you with poppies and harebells. \
		<br>&bull; Lady of the Gate: Clears your mutations, while mmutating and cursing heathens them with scratching. \
		<br>&bull; Master of the Rusted Mountain: Curses heathens to rust the floor they walk on."
	transmute_text = "Transmute a canvas and an additional item to create a painting. \
		<br>&bull; A pair of eyes for The Sister and He Who Wept \
		<br>&bull; A severed limb for The Feast of Desire \
		<br>&bull; Any plant produce for Great Chaparral Over Rolling Hills \
		<br>&bull; Any pair of gloves for Lady of the Gate \
		<br>&bull; A piece of trash for Master of the Rusted Mountain"
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

/datum/heretic_knowledge/hypnosis_ritual
	name = "Unwrap Minds"
	desc = "Exposes a healthen directly to the horrors of the Mansus, hypnotizing them.\
		<br>Further exposure to the horrors of the Mansus may cause the hypnosis to break."
	transmute_text = "Transmute a scalpel, a shard of glass, a piece of paper, and a living heathen."
	notice = "Whatever is written on the paper supplied, the heathen will be hypnotized with.\
		<br>If the heathen is mindshielded, it will shater - but the resulting hypnosis may not be what you expect.\
		<br>Other Heretics are unaffected by this ritual."
	gain_text = "My rise has been lonely, but I had realized it did not have to be. \
		I can show them the truth. Their weak, mortal minds may not be able to withstand the revelation, but in its tatters, they will find freedom. \
		I can show them the world as it really is, and if they are strong enough to endure it, they will join me in my vision."
	required_atoms = list(
		/obj/item/scalpel = 1,
		/obj/item/shard = 1,
		/obj/item/paper = 1,
		/mob/living/carbon/human = 1,
	)
	cost = 2
	research_tree_icon_path = 'icons/hud/screen_alert.dmi'
	research_tree_icon_state = "hypnosis"
	drafting_tier = 2

/datum/heretic_knowledge/hypnosis_ritual/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/mob/living/carbon/human/victim in atoms)
		if(victim.stat == DEAD || IS_HERETIC(victim) || victim.has_trauma_type(/datum/brain_trauma/hypnosis))
			atoms -= victim

/datum/heretic_knowledge/hypnosis_ritual/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	var/hypnosis_text = ""
	if(!HAS_TRAIT(user, TRAIT_UNCONVERTABLE))
		for(var/obj/item/paper/paper in selected_atoms)
			for(var/datum/paper_input/text as anything in paper.raw_text_inputs)
				hypnosis_text += "[STRIP_HTML_FULL(text.raw_text, MAX_MESSAGE_LEN)] "
			paper.burn()
			selected_atoms -= paper

	for(var/obj/item/implant/mindshield/shield in user.implants)
		shield.removed(user, silent = FALSE)
		shield.forceMove(user.drop_location())
		shield.burn()

	hypnosis_text = trim(hypnosis_text, MAX_MESSAGE_LEN) || pick_list(HERETIC_INFLUENCE_FILE, "hypnosis")
	for(var/mob/living/carbon/human/victim in selected_atoms)
		selected_atoms -= victim
		// lobotomy resistance because it might be a bit rough to make this permanent aye
		var/datum/brain_trauma/hypnosis/trauma = new(hypnosis_text)
		victim.gain_trauma(trauma, TRAUMA_RESILIENCE_LOBOTOMY)
