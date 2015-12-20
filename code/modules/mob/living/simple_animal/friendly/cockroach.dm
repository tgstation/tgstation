

/mob/living/simple_animal/cockroach
	name = "cockroach"
	desc = "This station is just crawling with bugs."
	icon_state = "cockroach"
	icon_dead = "cockroach"
	health = 1
	maxHealth = 1
	turns_per_move = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 270
	maxbodytemp = INFINITY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	response_help  = "pokes"
	response_disarm = "shoos"
	response_harm   = "splats"
	density = 0
	ventcrawler = 2
	gold_core_spawnable = 2
	var/squish_chance = 50

/mob/living/simple_animal/cockroach/death(gibbed)
	if(ticker.cinematic) //If the nuke is going off, then cockroaches are invincible. Keeps the nuke from killing them, cause cockroaches are immune to nukes.
		return
	if(!ckey || gibbed)// stupid staff of change fucking everything up.
		new /obj/effect/decal/cleanable/deadcockroach(src.loc)
		qdel(src)
		return
	else
		..()

/mob/living/simple_animal/cockroach/Crossed(var/atom/movable/AM)
	if(ismob(AM))
		if(isliving(AM))
			var/mob/living/A = AM
			if(A.mob_size > MOB_SIZE_TINY)
				if(prob(squish_chance))
					A.visible_message("[A] squashed \the [name].", "<span class='notice'>You squashed \the [name].</span>")
					death()
				else
					visible_message("\The [name] avoids getting crushed.")
	else
		if(isobj(AM))
			if(istype(AM,/obj/structure))
				visible_message("As \the [AM] moved over \the [name], it was crushed.")
				death()

/mob/living/simple_animal/cockroach/ex_act() //Explosions are a terrible way to handle a cockroach.
	return

/obj/effect/decal/cleanable/deadcockroach
	name = "cockroach guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")