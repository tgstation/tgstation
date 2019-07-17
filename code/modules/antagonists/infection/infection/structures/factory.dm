/obj/structure/infection/factory
	name = "factory infection"
	icon = 'icons/mob/infection/crystaline_infection_medium.dmi'
	icon_state = "crystalinvasion-layer"
	desc = "A thick spire of tendrils."
	pixel_x = -16
	pixel_y = 0
	max_integrity = 200
	health_regen = 1
	point_return = 5
	build_time = 100
	upgrade_subtype = /datum/infection_upgrade/factory
	var/list/spores = list()
	var/max_spores = 3
	var/spore_delay = 0
	var/spore_cooldown = 80 //8 seconds between spores and after spore death

/obj/structure/infection/factory/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/infection/factory/update_icon()
	. = ..()
	underlays.Cut()
	var/mutable_appearance/factory_base = mutable_appearance('icons/mob/infection/crystaline_infection_medium.dmi', "crystalinvasion-base")
	var/mutable_appearance/infection_base = mutable_appearance('icons/mob/infection/infection.dmi', "normal")
	infection_base.pixel_x = -pixel_x
	infection_base.pixel_y = -pixel_y
	underlays += factory_base
	underlays += infection_base

/obj/structure/infection/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
		spore.death()
	spores = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/factory/Be_Pulsed()
	. = ..()
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return
	flick(pick("crystalinvasion-effect", "crystalinvasion-effect-2"), src)
	spore_delay = world.time + spore_cooldown
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(src.loc, src, overmind)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		IS.update_icons()
		overmind.infection_mobs.Add(IS)
