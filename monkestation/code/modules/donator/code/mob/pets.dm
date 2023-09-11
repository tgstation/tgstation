/mob/living/basic/mothroach/void
	name = "void mothroach"
	desc = "A mothroach from the stars!"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "void_mothroach"
	icon_living = "void_mothroach"
	icon_dead = "void_mothroach_dead"
	held_state = "void_mothroach"
	held_lh = 'monkestation/code/modules/donator/icons/mob/pets_held_lh.dmi'
	held_rh = 'monkestation/code/modules/donator/icons/mob/pets_held_rh.dmi'
	head_icon = 'monkestation/code/modules/donator/icons/mob/pets_held.dmi'
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/crab/spycrab
	name = "spy crab"
	desc = "hon hon hon"
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/crab/spycrab/Initialize(mapload)
	. = ..()
	var/random_icon = pick("crab_red","crab_blue")
	icon_state = random_icon
	icon_dead = "[random_icon]_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/lizard/blahaj
	name = "\improper Blåhaj"
	desc = "The blue shark can swim very far, dive really deep and hear noises from almost 250 meters away."
	icon = 'monkestation/code/modules/donator/icons/mob/pets.dmi'
	icon_state = "blahaj"
	icon_living = "blahaj"
	icon_dead = "blahaj_dead"
	icon_gib = null
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/lizard/cirno  //nobody needs to know she's a lizard
	name = "Cirno"
	desc = "She is the greatest."
	icon = 'monkestation/icons/obj/plushes.dmi'
	icon_state = "cirno-happy"
	icon_living = "cirno-happy"
	icon_dead = ""
	icon_gib = null
	gold_core_spawnable = NO_SPAWN
