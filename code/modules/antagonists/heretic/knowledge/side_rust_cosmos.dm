// Sidepaths for knowledge between Rust and Cosmos.

/datum/heretic_knowledge/essence
	name = "Priest's Ritual"
	desc = "Allows you to transmute a tank of water and a glass shard into a Flask of Eldritch Essence. \
		Eldritch water can be consumed for potent healing, or given to heathens for deadly poisoning."
	gain_text = "This is an old recipe. The Owl whispered it to me. \
		Created by the Priest - the Liquid that both was and is not."
	next_knowledge = list(
		/datum/heretic_knowledge/rust_regen,
		/datum/heretic_knowledge/spell/cosmic_runes,
		)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank = 1,
		/obj/item/shard = 1,
	)
	result_atoms = list(/obj/item/reagent_containers/cup/beaker/eldritch)
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/entropy_pulse
	name = "Pulse of Entropy"
	desc = "Allows you to transmute 20 irons and 2 garbage items to fill the surrounding vicinity of the rune with rust."
	gain_text = "Reality begins to whisper to me. To give it its entropic end."
	required_atoms = list(
		/obj/item/stack/sheet/iron = 20,
		/obj/item/trash = 2
	)
	cost = 0
	route = PATH_SIDE
	var/rusting_range = 4

/datum/heretic_knowledge/entropy_pulse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	for(var/turf/nearby_turf in view(rusting_range, loc))
		if(get_dist(nearby_turf, loc) <= 1) //tiles on rune should always be rusted
			nearby_turf.rust_heretic_act()
		//we exclude closed turf to avoid exposing cultist bases
		if(prob(20) || isclosedturf(nearby_turf))
			continue
		nearby_turf.rust_heretic_act()
	return TRUE

/datum/heretic_knowledge/curse/corrosion
	name = "Curse of Corrosion"
	desc = "Allows you to transmute wirecutters, a pool of vomit, and a heart to cast a curse of sickness on a crew member. \
		While cursed, the victim will repeatedly vomit while their organs will take constant damage. You can additionally supply an item \
		that a victim has touched or is covered in the victim's blood to empower the curse."
	gain_text = "The body of humanity is temporary. Their weaknesses cannot be stopped, like iron falling to rust. Show them all."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/area_conversion,
		/datum/heretic_knowledge/spell/star_blast,
	)
	required_atoms = list(
		/obj/item/wirecutters = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/organ/internal/heart = 1,
	)
	duration = 0.5 MINUTES
	duration_modifier = 4
	curse_color = "#c1ffc9"
	cost = 1
	route = PATH_SIDE

/datum/heretic_knowledge/curse/corrosion/curse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	to_chat(chosen_mob, span_danger("You feel very ill..."))
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)
	return ..()

/datum/heretic_knowledge/curse/corrosion/uncurse(mob/living/carbon/human/chosen_mob, boosted = FALSE)
	if(QDELETED(chosen_mob))
		return

	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)
	to_chat(chosen_mob, span_green("You start to feel better."))
	return ..()

/datum/heretic_knowledge/summon/rusty
	name = "Rusted Ritual"
	desc = "Allows you to transmute a pool of vomit, a book, and a head into a Rust Walker. \
		Rust Walkers excel at spreading rust and are moderately strong in combat."
	gain_text = "I combined my knowledge of creation with my desire for corruption. The Marshal knew my name, and the Rusted Hills echoed out."
	next_knowledge = list(
		/datum/heretic_knowledge/spell/entropic_plume,
		/datum/heretic_knowledge/spell/cosmic_expansion,
	)
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/book = 1,
		/obj/item/bodypart/head = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_spirit
	cost = 1
	route = PATH_SIDE
	poll_ignore_define = POLL_IGNORE_RUST_SPIRIT

/datum/heretic_knowledge/summon/rusty/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
