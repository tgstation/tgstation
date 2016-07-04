/*Cabin areas*/
/area/awaymission/snowforest
	name = "Snow Forest"
	icon_state = "away"
	requires_power = 0
	luminosity = 1
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/cabin
	name = "Cabin"
	icon_state = "away2"
	requires_power = 1
	luminosity = 0
	lighting_use_dynamic = DYNAMIC_LIGHTING_ENABLED

/area/awaymission/snowforest/lumbermill
	name = "Lumbermill"
	icon_state = "away3"



#define SECONDS_PER_LOG 150 //How many seconds a log will burn for

//Fireplaces//

/obj/structure/fireplace
	name = "fireplace"
	desc = "A large stone fireplace, warm and cozy"
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "fireplace"
	density = 0
	anchored = 1
	pixel_x = -16
	var/wood = 0
	var/lit = 0


/obj/structure/fireplace/proc/try_light(obj/item/O, mob/user)
	if (!wood)
		user << "<span class='warning'>[src] needs some wood to burn!</span>"
		return FALSE
	if (lit == 1)
		user << "<span class='warning'>It's already lit!</span>"
		return FALSE

	var/lighting_text = "<span class='notice'>[user] lights the [src] with the [O].</span>"
	if(istype(O, /obj/item/weapon/weldingtool))
		lighting_text = "<span class='notice'>[user] lights the [src] with the [O]. What a badass. </span>"
	else if(istype(O, /obj/item/weapon/lighter/greyscale))
		lighting_text = "<span class='notice'>After some fiddling, [user] manages to light the [src] with [O].</span>"
	else if(istype(O, /obj/item/weapon/lighter))
		lighting_text =  "<span class='rose'>With a single flick of their wrist, [user] smoothly lights the [src] with [O]. Classy.</span>"
	else if(istype(O, /obj/item/weapon/melee/energy))
		lighting_text = "<span class='warning'>[user] swings their [O], lighting the [src] in the proccess.</span>"
	if(O.is_hot())
		visible_message(lighting_text)
		lit = 1
		//IT'S LIT FAM
		START_PROCESSING(SSobj, src)
		return TRUE

/obj/structure/fireplace/attackby(obj/item/T, mob/user)
	if(istype(T,/obj/item/stack/sheet/mineral/wood))
		if(wood > 4)
			user << "<span class = 'warning'>There's already enough logs in the [src].</span>"
			return
		var/woodnumber = input(user, "Fireplace Fuel: Max 4 logs.", "How much wood do you want to add?", 0) as num //Something is causing this to break
		woodnumber = Clamp(woodnumber,0,4)
		var/obj/item/stack/sheet/mineral/wood/woody = T
		if(!user.incapacitated() && in_range(src, user) && woody.use(woodnumber))
			wood += woodnumber * SECONDS_PER_LOG
			user.visible_message("<span class='notice'>[user] tosses some wood into [name].</span>", "<span class='notice'>You add some fuel to [src].</span>")
			return

	else if(try_light(T,user))
		return

/obj/structure/fireplace/update_icon()
	cut_overlays()
	luminosity = 0
	switch(wood)
		if(0 to 100)
			add_overlay("fireplace_fire0")
			SetLuminosity(1)
		if(100 to 200)
			add_overlay("fireplace_fire1")
			SetLuminosity(2)
		if(200 to 300)
			add_overlay("fireplace_fire2")
			SetLuminosity(3)
		if(300 to 400)
			add_overlay("fireplace_fire3")
			SetLuminosity(4)
		if(400 to 600)
			add_overlay("fireplace_fire4")
			SetLuminosity(6)

	if (wood != 0)
		add_overlay("fireplace_glow")


/obj/structure/fireplace/process()
	wood --
	update_icon()
	if(wood > 1)
		playsound(src, 'sound/effects/comfyfire.ogg',50,0, 0, 1)
	else if(!wood)
		lit = 0
		update_icon()
		STOP_PROCESSING(SSobj, src)

/obj/structure/fireplace/Destroy()
	STOP_PROCESSING(SSobj, src)
	.=..()





//Firepits are dumb, they can do whatever they want
/obj/structure/firepit
	name = "firepit"
	desc = "warm and toasty"
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "firepit-active"
	density = 0
	var/active = 1

/obj/structure/firepit/initialize()
	..()
	toggleFirepit()

/obj/structure/firepit/attack_hand(mob/living/user)
	if(active)
		active = 0
		toggleFirepit()
	else
		..()


/obj/structure/firepit/attackby(obj/item/W,mob/living/user,params)
	if(!active)
		if(W.is_hot())
			active = 1
			toggleFirepit()
		else
			return ..()
	else
		W.fire_act()

/obj/structure/firepit/proc/toggleFirepit()
	if(active)
		SetLuminosity(8)
		icon_state = "firepit-active"
	else
		SetLuminosity(0)
		icon_state = "firepit"

/obj/structure/firepit/extinguish()
	if(active)
		active = 0
		toggleFirepit()

/obj/structure/firepit/fire_act()
	if(!active)
		active = 1
		toggleFirepit()



//other Cabin Stuff//

/obj/machinery/recycler/lumbermill
	name = "lumbermill saw"
	desc = "Faster then the cartoons!"
	emagged = 2 //Always gibs people
	item_recycle_sound = 'sound/weapons/chainsawhit.ogg'

/obj/machinery/recycler/lumbermill/recycle_item(obj/item/weapon/grown/log/L)
	if(!istype(L))
		return
	else
		var/potency = L.seed.potency
		..()
		new L.plank_type(src.loc, 1 + round(potency / 25))

/mob/living/simple_animal/chicken/rabbit/normal
	icon_state = "b_rabbit"
	icon_living = "b_rabbit"
	icon_dead = "b_rabbit_dead"
	icon_prefix = "b_rabbit"
	minbodytemp = 0
	eggsleft = 0
	egg_type = null
	speak = list()

/*Cabin's forest*/
/datum/mapGenerator/snowy
	modules = list(/datum/mapGeneratorModule/snow/pineTrees, \
	/datum/mapGeneratorModule/snow/deadTrees, \
	/datum/mapGeneratorModule/snow/randBushes, \
	/datum/mapGeneratorModule/snow/randIceRocks, \
	/datum/mapGeneratorModule/snow/bunnies)

/datum/mapGeneratorModule/snow/checkPlaceAtom(turf/T)
	if(istype(T,/turf/open/floor/plating/asteroid/snow))
		return ..(T)
	return 0

/datum/mapGeneratorModule/snow/pineTrees
	spawnableAtoms = list(/obj/structure/flora/tree/pine = 30)

/datum/mapGeneratorModule/snow/deadTrees
	spawnableAtoms = list(/obj/structure/flora/tree/dead = 10)

/datum/mapGeneratorModule/snow/randBushes
	spawnableAtoms = list()

/datum/mapGeneratorModule/snow/randBushes/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/ausbushes)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 1

/datum/mapGeneratorModule/snow/bunnies
	//spawnableAtoms = list(/mob/living/simple_animal/chicken/rabbit/normal = 0.1)
	spawnableAtoms = list(/mob/living/simple_animal/chicken/rabbit = 0.5)

/datum/mapGeneratorModule/snow/randIceRocks
	spawnableAtoms = list(/obj/structure/flora/rock/icy = 5, /obj/structure/flora/rock/pile/icy = 5)

/obj/effect/landmark/mapGenerator/snowy
	mapGeneratorType = /datum/mapGenerator/snowy
