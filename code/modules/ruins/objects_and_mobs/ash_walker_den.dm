#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/mob/living/simple_animal/hostile/spawner/ash_walker
	name = "ash walker nest"
	desc = "A nest built around a necropolis tendril. The eggs seem to grow unnaturally fast..."
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"
	icon_living = "ash_walker_nest"
	faction = list("ashwalker")
	health = 200
	maxHealth = 200
	loot = list(/obj/effect/gibspawner, /obj/item/device/assembly/signaler/anomaly)
	del_on_death = 1
	var/meat_counter = ASH_WALKER_SPAWN_THRESHOLD * 3 //supplies the roundstart eggs
	var/list/eggs	= list()
	var/list/children = list()

/mob/living/simple_animal/hostile/spawner/ash_walker/Life()
	..()
	if(!stat)
		if(consume())
			spawn_mob()

/mob/living/simple_animal/hostile/spawner/ash_walker/proc/consume()
	for(var/mob/living/H in view(src,1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Serrated tendrils eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs.</span>")
			playsound(get_turf(src),'sound/magic/Demon_consume.ogg', 100, 1)
			if(istype(H,/mob/living/simple_animal/hostile/megafauna/dragon))
				meat_counter += 20
			else
				meat_counter ++
			for(var/obj/item/W in H)
				H.unEquip(W)
			H.gib()

/mob/living/simple_animal/hostile/spawner/ash_walker/spawn_mob()
	var/ashwalker_force = 0
	var/opposing_force = 1
	var/threat_ratio = ashwalker_force / opposing_force
	var/cost_to_spawn = max(round(threat_ratio*10),ASH_WALKER_SPAWN_THRESHOLD)

	for(var/mob/M in children)
		if(M.stat == DEAD || isbrain(M) || qdeleted(M))
			children -= M

	for(var/E in eggs)
		if(qdeleted(E))
			eggs -= E

	ashwalker_force = children.len + eggs.len

	for(var/mob/M in mob_list)
		if(M.mind && M.stat != DEAD && !isnewplayer(M) &&!isbrain(M))
			opposing_force++

	opposing_force = max((opposing_force - children.len),1) //DIV0 protection

	if(ashwalker_force <= 3)
		cost_to_spawn = ASH_WALKER_SPAWN_THRESHOLD

	if(meat_counter >= cost_to_spawn)
		var/obj/effect/mob_spawn/human/ash_walker/A = new(get_step(src.loc, SOUTH))
		eggs += A
		A.home_nest = src
		visible_message("<span class='danger'>One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!</span>")
		meat_counter -= cost_to_spawn
