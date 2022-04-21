/*
	The holodeck activates these shortly after the program loads,
	and deactivates them immediately before changing or disabling the holodeck.

	These remove snowflake code for special holodeck functions.
*/
/obj/effect/holodeck_effect
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/holodeck_effect/proc/activate(obj/machinery/computer/holodeck/HC)
	return

/obj/effect/holodeck_effect/proc/deactivate(obj/machinery/computer/holodeck/HC)
	qdel(src)
	return

// Called by the holodeck computer as long as the program is running
/obj/effect/holodeck_effect/proc/tick(obj/machinery/computer/holodeck/HC)
	return

/obj/effect/holodeck_effect/proc/safety(active)
	return


// Generates a holodeck-tracked card deck
/obj/effect/holodeck_effect/cards
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_nanotrasen_full"
	var/obj/item/toy/cards/deck/deck

/obj/effect/holodeck_effect/cards/activate(obj/machinery/computer/holodeck/HC)
	deck = new(loc)
	safety(!(HC.obj_flags & EMAGGED))
	deck.holo = HC
	RegisterSignal(deck, COMSIG_PARENT_QDELETING, .proc/handle_card_delete)
	return deck

/obj/effect/holodeck_effect/cards/proc/handle_card_delete(datum/source)
	SIGNAL_HANDLER
	deck = null

/obj/effect/holodeck_effect/cards/safety(active)
	if(!deck)
		return
	if(active)
		deck.card_hitsound = null
		deck.card_force = 0
		deck.card_throwforce = 0
		deck.card_throw_speed = 3
		deck.card_throw_range = 7
		deck.card_attack_verb_continuous = string_list(list("attacks"))
	else
		deck.card_hitsound = 'sound/weapons/bladeslice.ogg'
		deck.card_force = 5
		deck.card_throwforce = 10
		deck.card_throw_speed = 3
		deck.card_throw_range = 7
		deck.card_attack_verb_continuous = string_list(list("attacks", "slices", "dices", "slashes", "cuts"))


/obj/effect/holodeck_effect/sparks/activate(obj/machinery/computer/holodeck/HC)
	var/turf/T = get_turf(src)
	if(T)
		var/datum/effect_system/spark_spread/s = new
		s.set_up(3, 1, T)
		s.start()
		T.temperature = 5000 //Why? not quite sure to be honest with you
		T.hotspot_expose(50000,50000,1)

/obj/effect/holodeck_effect/random_book


/obj/effect/holodeck_effect/random_book/activate(obj/machinery/computer/holodeck/father_holodeck)
	var/static/banned_books = list(/obj/item/book/manual/random, /obj/item/book/manual/nuclear, /obj/item/book/manual/wiki)
	var/newtype = pick(subtypesof(/obj/item/book/manual) - banned_books)
	var/obj/item/book/manual/to_spawn = new newtype(loc)
	to_spawn.flags_1 |= (HOLOGRAM_1 | NODECONSTRUCT_1)
	return to_spawn

/obj/effect/holodeck_effect/mobspawner
	var/mobtype = /mob/living/simple_animal/hostile/carp/holocarp
	var/mob/our_mob = null

/obj/effect/holodeck_effect/mobspawner/activate(obj/machinery/computer/holodeck/HC)
	if(islist(mobtype))
		mobtype = pick(mobtype)
	our_mob = new mobtype(loc)
	our_mob.flags_1 |= HOLOGRAM_1

	// these vars are not really standardized but all would theoretically create stuff on death
	for(var/v in list("butcher_results","corpse","weapon1","weapon2","blood_volume") & our_mob.vars)
		our_mob.vars[v] = null
	RegisterSignal(our_mob, COMSIG_PARENT_QDELETING, .proc/handle_mob_delete)
	return our_mob

/obj/effect/holodeck_effect/mobspawner/deactivate(obj/machinery/computer/holodeck/HC)
	if(our_mob)
		HC.derez(our_mob)
	qdel(src)

/obj/effect/holodeck_effect/mobspawner/proc/handle_mob_delete(datum/source)
	SIGNAL_HANDLER
	our_mob = null

/obj/effect/holodeck_effect/mobspawner/pet

/obj/effect/holodeck_effect/mobspawner/pet/Initialize(mapload)
	. = ..()
	mobtype = list(
		/mob/living/simple_animal/butterfly,
		/mob/living/simple_animal/chick/holo,
		/mob/living/simple_animal/pet/fox,
		/mob/living/simple_animal/rabbit,
	)
	mobtype += pick(
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/pet/dog/corgi/puppy,
		/mob/living/simple_animal/pet/dog/pug,
	)
	mobtype += pick(
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/cat/kitten,
	)

/obj/effect/holodeck_effect/mobspawner/bee
	mobtype = /mob/living/simple_animal/hostile/bee/toxin

/obj/effect/holodeck_effect/mobspawner/monkey
	mobtype = /mob/living/simple_animal/holodeck_monkey

/obj/effect/holodeck_effect/mobspawner/penguin
	mobtype = /mob/living/simple_animal/pet/penguin/emperor

/obj/effect/holodeck_effect/mobspawner/penguin/Initialize(mapload)
	if(prob(1))
		mobtype = /mob/living/simple_animal/pet/penguin/emperor/shamebrero
	return ..()

/obj/effect/holodeck_effect/mobspawner/penguin_baby
	mobtype = /mob/living/simple_animal/pet/penguin/baby
