/obj/effect/mob_spawn/human/superhero
	name = "cryostasis sleeper"
	desc = "A cryostasis sleeper containing somebody."
	mob_name = "a superhero"
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	roundstart = FALSE
	death = FALSE
	show_flavour = FALSE
	anchored = TRUE
	density = FALSE
	mob_species = /datum/species/human
	short_desc = "You are a superhero."
	flavour_text = "You are a superhero aboard the OwlSkip. Help your fellow superheroes and catch those nasty villains!"
	assignedrole = "Superhero"
	outfit = /datum/outfit/superhero

/obj/effect/mob_spawn/human/superhero/special(mob/living/new_spawn)
	new_spawn.mind.add_antag_datum(/datum/antagonist/superhero)

/obj/effect/mob_spawn/human/superhero/villain
	mob_name = "a supervillain"
	short_desc = "You are a supervillain."
	flavour_text = "You are a supervillain aboard the Dark Mothership. Help your fellow superheroes and catch those nasty villains!"
	assignedrole = "Supervillain"
	outfit = /datum/outfit/superhero/villain

/obj/effect/mob_spawn/human/superhero/villain/special(mob/living/new_spawn)
	new_spawn.mind.add_antag_datum(/datum/antagonist/supervillain)

//Heroes

/obj/effect/mob_spawn/human/superhero/buzzon
	name = "BuzzOn's cryostasis sleeper"
	desc = "A cryostasis sleeper containing BuzzOn, the creator of the robotic bee suit. It smells of honey and flowers."

	outfit = /datum/outfit/superhero/buzzon_nude

/obj/effect/mob_spawn/human/superhero/ianiser
	name = "Ianiser's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Ianiser, the greatest electrofurry. It has a lot of dirt on it and is sparking a little."

	outfit = /datum/outfit/superhero/ianiser_nude

/obj/effect/mob_spawn/human/superhero/owlman
	name = "Owlman's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Owlman, the leader of the superhero team. It has a lot of scratches on it."

	outfit = /datum/outfit/superhero/owlman_nude

//Villains

/obj/effect/mob_spawn/human/superhero/villain/skeledoom
	name = "SkeleDoom's cryostasis sleeper"
	desc = "A cryostasis sleeper containing an edgy teen cosplaying a skeleton. It's probably SkeleDoom."

	outfit = /datum/outfit/superhero/villain/skeledoom_nude

/obj/effect/mob_spawn/human/superhero/villain/nekometic
	name = "Nekometic's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Nekometic. Is he a real catboy or just a pervert wearing an anime skirt?"

	outfit = /datum/outfit/superhero/villain/nekometic_nude

/obj/effect/mob_spawn/human/superhero/villain/griffin
	name = "Griffin's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Griffin, the father of the Tide. It's covered in white feathers."

	outfit = /datum/outfit/superhero/villain/griffin_nude
