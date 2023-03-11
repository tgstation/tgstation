// Sidepaths for knowledge between Cosmos and Ash.

/datum/heretic_knowledge/summon/fire_shark
	name = "Fire Fish"
	desc = "Allows you to transmute a pool of ash, eyes, and a sheet of plasma into a Fire Shark. \
		Fire Sharks are fast and strong in groups, but are bad at combat."
	gain_text = "My knowledge of the universe with the energy of remains, constructed it. It gave the Fire Shark life."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cosmic_runes,
		/datum/heretic_knowledge/spell/ash_passage,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/eyes = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/basic/fire_shark
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/curse/cosmic_trail
	name = "Curse of The Stars"
	desc = "Allows you to transmute a bluespace crystal, a pool of ash, and a liver to cast a Curse of The Stars on a crew member. \
		While cursed, the victim will recieve a star mark that always lasts for 30 seconds. This star mark makes it so that the \
		crew member cannot enter cosmic carpet fields. The victim will also recieve a cosmic carpet trail for at least 30 seconds."
	gain_text = "Strange stars glare through the cosmos. The stars focus their solar radiation onto their target."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/star_blast,
		/datum/heretic_knowledge/mad_mask,
	)
	required_atoms = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/liver = 1,
	)
	duration = 0.5 MINUTES
	duration_modifier = 2
	curse_color = "#dcaa5b"
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/curse/cosmic_trail/curse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	to_chat(chosen_mob, span_danger("You feel very strange..."))
	chosen_mob.apply_status_effect(/datum/status_effect/star_mark)
	chosen_mob.AddElement(/datum/element/cosmic_carpet_trail)
	return ..()

/datum/heretic_knowledge/curse/cosmic_trail/uncurse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.RemoveElement(/datum/element/cosmic_carpet_trail)
	to_chat(chosen_mob, span_green("You start to feel better."))
	return ..()

/datum/heretic_knowledge/eldritch_coin
	name = "Eldritch Coin"
	desc = "Allows you to transmute a sheet of plasma, a diamond mask and eyes to create an Eldritch Coin. \
		The coin will heals when landing on heads and damages when landing on tails. \
		The coin will heal for more, but only for heretics."
	gain_text = "It tossed the coin and won its bet, now it gains..."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/cosmic_expansion,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	required_atoms = list(
		/obj/item/stack/sheet/mineral/diamond = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
		/obj/item/organ/internal/eyes = 1,
	)
	result_atoms = list(/obj/item/coin/eldritch)
	cost = 1
	route = PATH_SIDE
