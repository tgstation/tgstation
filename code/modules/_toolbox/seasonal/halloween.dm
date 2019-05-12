//Updating parallax planet
GLOBAL_VAR_INIT(parallax_planet_icon, 'icons/effects/parallax.dmi')
/obj/screen/parallax_layer/planet/Initialize(mapload, view)
	.=..()
	update_icon()

/obj/screen/parallax_layer/planet/update_icon()
	.=..()
	icon = GLOB.parallax_planet_icon

/proc/update_parallax_planet_icons()
	for(var/client/C in GLOB.clients)
		for(var/obj/screen/parallax_layer/planet/P in C.screen)
			P.update_icon()

//change to halloween spooky event
/datum/round_event/spooky/proc/toolbox_halloween_event()
	SSnightshift.can_fire = FALSE
	SSnightshift.update_nightshift(TRUE, FALSE)
	GLOB.parallax_planet_icon = 'icons/oldschool/hw_parallax.dmi'
	update_parallax_planet_icons()
	create_pumpkins()
	spawn_spiderlings()
	/*light_flicker()
	spawn_halloweeen_gibs()*/

/datum/round_event/spooky/proc/spawn_spiderlings()
	var/spiderling_amount = 20
	var/list/tile_list = list()
	for(var/turf/open/floor/F in world)
		if(is_station_level(F.z))
			var/blocked = 0
			for(var/obj/O in F)
				if(O.density)
					blocked = 1
					break
			if(blocked)
				continue
			tile_list += F

	var/turf/chosen_tile
	if(tile_list.len)
		chosen_tile = pick(tile_list)
		for(var/i=0,i<=spiderling_amount,i++)
			new /obj/structure/spider/spiderling/spooky(chosen_tile)

//Spooky Spiderlings
/obj/structure/spider/spiderling/spooky
	name = "spooky spiderling"
	desc = "It never stays still for long. This kind doesn't grow big."
	faction = list("halloween")

/obj/structure/spider/spiderling/spooky/process()
	.=..()
	amount_grown = initial(amount_grown)

/proc/create_pumpkins()
	for(var/turf/open/floor/F in world)
		if(!is_station_level(F.z))
			continue
		var/area/thearea = get_area(F)
		var/list/exclusion_list = list(
			/area/shuttle,
			/area/maintenance)
		var/wrongarea = 0
		for(var/type in exclusion_list)
			if(istype(thearea,/area/maintenance))
				wrongarea = 1
				break
		if(wrongarea)
			continue
		if(F.air && istype(F.air.gases,/list))
			var/o2_concentration
			if(F.air.gases[/datum/gas/oxygen] && F.air.gases[/datum/gas/oxygen][MOLES])
				o2_concentration = F.air.gases[/datum/gas/oxygen][MOLES]
			if(((o2_concentration < 16)||(o2_concentration >= 40))||!o2_concentration)
				continue
		var/hassomething = 0
		for(var/obj/O in F)
			if(((O.density)|(istype(O,/obj/structure))|(istype(O,/obj/machinery/recharge_station))))
				hassomething = 1
				break
		if(hassomething)
			continue
		var/isacorner = 0
		var/turf/northcheck = locate(F.x,F.y+1,F.z)
		var/turf/eastcheck = locate(F.x-1,F.y,F.z)
		var/turf/westcheck = locate(F.x+1,F.y,F.z)
		var/turf/southcheck = locate(F.x,F.y-1,F.z)
		//northeast
		if(northcheck && eastcheck && northcheck.density && eastcheck.density)
			isacorner = 1
		if(northcheck && westcheck && northcheck.density && westcheck.density)
			isacorner = 1
		if(southcheck && eastcheck && southcheck.density && eastcheck.density)
			isacorner = 1
		if(southcheck && westcheck && southcheck.density && westcheck.density)
			isacorner = 1
		if(isacorner)
			var/list/cornerlist = list()
			for(var/turf/R in range(1,F))
				if(R.x == F.x)
					continue
				if(R.y == F.y)
					continue
				cornerlist += R
			var/clearedturf = 0
			for(var/turf/R in cornerlist)
				if(!R.Adjacent(F))
					continue
				if(R.density)
					continue
				var/hasobject = 0
				for(var/obj/O in R)
					if(O.density)
						hasobject = 1
						break
				if(hasobject)
					continue
				clearedturf = 1
				break
			if(clearedturf)
				new /obj/structure/flora/jackolantern(F)

/obj/structure/flora/jackolantern
	name = "Jack-O-Lantern"
	desc = "Spooky!"
	icon = 'icons/oldschool/objects.dmi'
	icon_state = "jackolantern"
	density = 1
	anchored = 0
	var/pumpkin_light_strength = 1
	var/pumpkin_light_range = 2

/obj/structure/flora/jackolantern/Initialize()
	. = ..()
	light_up_pumpkin()

/obj/structure/flora/jackolantern/proc/light_up_pumpkin()
	set_light(pumpkin_light_strength, pumpkin_light_range)

//Spooky Skeletons
/mob/living/simple_animal/hostile/skeleton/spooky
	name = "spooky skeleton"
	desc = "A real bonefied skeleton, doesn't seem like it wants to socialize."
	maxHealth = 50
	health = 50
	melee_damage_lower = 3
	melee_damage_upper = 10
	faction = list("skeleton", "halloween")
	var/non_brute_armor_modifier = 2


/mob/living/simple_animal/hostile/skeleton/spooky/New()
	.=..()
	color = pick("#d4c1a3", "#e6d6bc", "#f5e9d5", "#d4d4d4", "#e6e6e6", "#f0f0f0", "#f5f5f5", "#fcfcfc", "null")


/mob/living/simple_animal/hostile/skeleton/spooky/bullet_act(obj/item/projectile/P)
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != "brute")
		P.damage = (P.damage / non_brute_armor_modifier)
		visible_message("<span class='danger'>[P] has a reduced effect on [src]!</span>")
	..()


/mob/living/simple_animal/hostile/skeleton/spooky/huge
	name = "huge spooky skeleton"
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 25
	pixel_y = 8


/mob/living/simple_animal/hostile/skeleton/spooky/huge/New()
	.=..()
	transform = transform*1.5


//Killer Pumpkins
/mob/living/simple_animal/hostile/killerpumpkin
	name = "killer pumpkin"
	desc = "It's a horrifyingly enormous spooky pumpkin!"
	icon = 'icons/oldschool/simple_animals.dmi'
	icon_state = "killer_pumpkin"
	icon_living = "killer_pumpkin"
	icon_dead = "killer_pumpkin"
	gender = NEUTER
	turns_per_move = 5
	a_intent = INTENT_HARM
	maxHealth = 30
	health = 30
	speed = 1
	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	minbodytemp = 150
	maxbodytemp = 500
	healable = 0
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	robust_searching = 1
	gold_core_spawnable = HOSTILE_SPAWN
	faction = list("halloween")
	see_in_dark = 3
	del_on_death = 1
	loot = list(/obj/item/clothing/head/hardhat/pumpkinhead)



