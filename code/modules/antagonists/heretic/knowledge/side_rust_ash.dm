// Sidepaths for knowledge between Rust and Ash.

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a Flask of Eldritch Essence. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me. \
		Created by the Priest - the Liquid that is both was and is not."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/spell/ash_passage,
		)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	desc = "Allows you to transmute wirecutters, a pool of vomit, a heart, \
		and an item containing fingerprints to cast a curse of plague \
		on one of the fingerprint's owners for two minutes. While cursed, \
		the victim will repeatedly vomit while their organs will take constant damage."
	gain_text = "The body of humanity is temporary. Their weaknesses cannot be stopped, like iron falling to rust. Show them all."
	next_knowledge = list(
		/datum/heretic_knowledge/mad_mask,
		/datum/heretic_knowledge/spell/area_conversion,
	)
	required_atoms = list(
		/obj/item/wirecutters = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/organ/heart = 1,
	)
	duration = 2 MINUTES
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/carbon/human/chosen_mob)
	to_chat(chosen_mob, span_danger("You feel very ill."))
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/carbon/human/chosen_mob)
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)
	to_chat(chosen_mob, span_notice("You start to feel better."))

/datum/heretic_knowledge/spell/cleave
	name = "Blood Cleave"
	desc = "Grants you Cleave, an area-of-effect targeted spell \
		that causes heavy bleeding and blood loss to anyone afflicted."
	gain_text = "At first I didn't understand these instruments of war, but the Priest \
		told me to use them regardless. Soon, he said, I would know them well."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/entropic_plume,
		/datum/heretic_knowledge/spell/flame_birth,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/cleave
	cost = 1
	route = PATH_SIDE
