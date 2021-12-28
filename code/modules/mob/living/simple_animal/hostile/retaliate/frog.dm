/mob/living/simple_animal/hostile/retaliate/frog
	name = "frog"
	desc = "They seem a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	speak = list("ribbit","croak")
	emote_see = list("hops in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 15
	health = 15
	melee_damage_lower = 5
	melee_damage_upper = 5
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "pokes"
	response_disarm_simple = "poke"
	response_harm_continuous = "splats"
	response_harm_simple = "splat"
	density = FALSE
	faction = list("hostile")
	attack_sound = 'sound/effects/reee.ogg'
	butcher_results = list(/obj/item/food/nugget = 1)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	atom_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	var/stepped_sound = 'sound/effects/huuu.ogg'

/mob/living/simple_animal/hostile/retaliate/frog/Initialize(mapload)
	. = ..()

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	if(prob(1))
		name = "rare frog"
		desc = "They seem a little smug."
		icon_state = "rare_frog"
		icon_living = "rare_frog"
		icon_dead = "rare_frog_dead"
		butcher_results = list(/obj/item/food/nugget = 5)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	add_cell_sample()

/mob/living/simple_animal/hostile/retaliate/frog/proc/on_entered(datum/source, AM as mob|obj)
	SIGNAL_HANDLER
	if(!stat && isliving(AM))
		var/mob/living/L = AM
		if(L.atom_size > MOB_SIZE_TINY)
			playsound(src, stepped_sound, 50, TRUE)

/mob/living/simple_animal/hostile/retaliate/frog/add_cell_sample()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_FROG, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
