/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		consume()
		spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Tendrils reach out from \the [src.name] pulling [H] in! Blood seeps over the eggs as [H] is devoured.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			meat_counter ++
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	if(meat_counter >= 2)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(src.loc, SOUTH))
		visible_message("<span class='danger'>An egg is ready to hatch!</span>")
		meat_counter -= 2

/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/lizard
	helmet = /obj/item/clothing/head/helmet/gladiator
	uniform = /obj/item/clothing/under/gladiator
	roundstart = FALSE
	death = FALSE
	anchored = 0
	density = 0
	flavour_text = {"<B>You are an Ash Walker. Your tribe worships <span class='danger'>the necropolis</span>. The wastes are sacred ground, it's monsters a blessed bounty. You have seen lights in the distance though, the arrival of outsiders seeking to destroy the land. Fresh sacrifices.</B>"}

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/new_spawn)
	new_spawn.real_name = random_unique_lizard_name(gender)
	new_spawn << "Drag corpses to your nest to feed the young, and spawn more Ash Walkers. Bring glory to the tribe!"
	if(ishuman(new_spawn))
		var/mob/living/carbon/human/H = new_spawn
		H.dna.species.specflags |= NOBREATH
		H.dna.species.specflags |= NOGUNS



