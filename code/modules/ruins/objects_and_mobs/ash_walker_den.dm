#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/mob/living/simple_animal/hostile/spawner/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "A vile tendril of corruption. It's surrounded by a nest of rapidly growing eggs..."
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	icon_dead = "ash_walker_nest"
	faction = list("ashwalker")
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/collapse)
	var/meat_counter = 6

/mob/living/simple_animal/hostile/spawner/lavaland/ash_walker/death()
	new /obj/item/device/assembly/signaler/anomaly (get_step(loc, pick(GLOB.alldirs)))
	return ..()

/mob/living/simple_animal/hostile/spawner/lavaland/ash_walker/handle_automated_action()
	consume()
	return ..()

/mob/living/simple_animal/hostile/spawner/lavaland/ash_walker/proc/consume()
	for(var/mob/living/H in view(src, 1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Serrated tendrils eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs.</span>")
			playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, 1)
			if(ismegafauna(H))
				meat_counter += 20
			else
				meat_counter++
			H.gib()
			adjustHealth(-maxHealth * 0.05)//restores 5% hp of tendril

/mob/living/simple_animal/hostile/spawner/lavaland/ash_walker/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/human/ash_walker(get_step(loc, pick(GLOB.alldirs)))
		visible_message("<span class='danger'>One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!</span>")
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD
