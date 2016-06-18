//TOMB OF RAFID: THE AWAY MISSION

//First area: expedition camp. Features a mime and some supplies to get you started, nothing else

//Second area: the pyramid. Some corridors and rooms. There is a sealed gate in the middle; a sacrifice is needed to unlock it. Valid sacrifices are: Ian or any living conscious crewmember (no monkey humans or braindeads)

//Third area: Tomb of Rafid. The largest and the toughest area, it features flying skulls and mummies of various kinds. The mad king Rafid is buried somewhere in there

//Optional area: Spider Caverns. Contains a spider queen and a hermit wizard's house. If you defeat the spider queen, the hermit and the spider hunters, you gain access to a staff of animation

//Optional area: Tower of Madness. Contains many mummy priests and faithless, in the end there's an altar. Praying at the altar will cause you to completely lose your mind and gain many superpowers.

/area/awaymission/tomb/expedition_camp
	name = "expedition camp"

/area/awaymission/tomb/pyramid_outside
	name = "great pyramid"

/area/awaymission/tomb/tomb_of_rafid
	name = "Tomb of Rafid"

/area/awaymission/tomb/spider_cave
	name = "cavern"

/area/awaymission/tomb/tower_of_madness
	name = "Tower of Madness"

/obj/effect/narration/tomb/intro
	msg = {"<span class='info'>You appear on the surface of an unknown to you planet. This appears to be a desert; trees are few and scarce and there's no water in sight. The sun is setting.
	The first thing that catches your eye is the massive pyramid in front of you. Behind it you see an expedition camp of some sort.</span>"}

/obj/effect/trap/cage_trap //When triggered, spawns a cage and unleashes monsters
	name = "cage trap"

/obj/effect/trap/cage_trap/activate(atom/movable/AM)
	to_chat(AM, "<span class='userdanger'>A cage falls down on top of you!</span>")

	sleep(rand(1,5))

	new /obj/structure/cage/autoclose(get_turf(src))

	sleep(20)

	for(var/obj/effect/ddr_loot/DL in get_area(src))
		var/turf/T = get_turf(DL)
		T.ChangeTurf(/turf/unsimulated/floor)

/obj/item/weapon/skull/rigged/Crossed(atom/movable/L)
	..()

	if(istype(L, /mob/living/carbon) || istype(L, /mob/living/silicon) || istype(L, /obj/item/weapon/skull/rigged)) //Another rigged skull or a mob entered our turf
		activate()

/obj/item/weapon/skull/rigged/pickup(mob/living/user)
	..()

	if(istype(user))
		if(user.drop_item(src))
			activate()

/obj/item/weapon/skull/rigged/proc/activate()
	visible_message("<span class='danger'>All of a sudden, \the [src] comes to life!</span>")

	var/mob/living/simple_animal/hostile/viscerator/flying_skull/FS = new(get_turf(src))
	FS.pixel_x = src.pixel_x
	FS.pixel_y = src.pixel_y - 4 //The skull item sprite is slightly lower

	animate(FS, pixel_y = src.pixel_y + 8, time = 7, easing = SINE_EASING)
	qdel(src)

/obj/effect/landmark/corpse/mummy/rafid
	name = "Rafid the Mad"

	corpsebelt = /obj/item/weapon/storage/belt/soulstone/full
	corpsemask = /obj/item/clothing/mask/happy

/obj/structure/sacrificial_altar
	name = "sacrificial altar"
	desc = "An altar used for sacrifices to Riniel, the ruler of the underworld."

	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "ano51"

	density = 0
	opacity = 0

/obj/structure/sacrificial_altar/proc/can_sacrifice(mob/victim, rejection_message)
	if(istype(victim, /mob/living/simple_animal/corgi/Ian))
		return 1

	if(ishuman(victim))
		if(victim.isDead())
			to_chat(rejection_message, "<span class='danger'>\The [victim] is dead. Only living beings can be offered to Riniel.</span>")
			return 0
		if(!victim.key || !victim.client)
			to_chat(rejection_message, "<span class='danger'>\The [victim] is catatonic. Riniel only accepts able-minded sacrifices.</span>")
			return 0

		return 1

/obj/structure/sacrificial_altar/proc/sacrifice(mob/victim, mob/user)
	var/client/C = victim.client

	victim.dust()
	for(var/obj/effect/ddr_loot/D in get_area(src)) //Open locked doors
		var/turf/T = get_turf(D)

		T.ChangeTurf(/turf/unsimulated/floor)
		playsound(T, 'sound/effects/stonedoor_openclose.ogg', 100, 1)

	if(!C) return
	to_chat(C, "<span class='danger'>You were sacrificed to Riniel, ruler of the Underworld.</span>")

/obj/structure/sacrificial_altar/attack_hand(mob/user)
	var/mob_amount = 0
	var/mob/living/victim

	for(var/mob/living/L in get_turf(src))
		if(ishuman(L) && !L.lying) continue
		if(L == user) continue

		victim = L
		mob_amount++

		if(mob_amount >= 2)
			to_chat(user, "<span class='danger'>There are too many living beings lying on top of the altar.</span>")
			return 1

	if(!victim)
		to_chat(user, "<span class='info'>The sacrifice must be lying on top of the altar, and the ritualist must stand beside it. The sacrifice must be a human, however sacred animals are sometimes accepted by Riniel too.</span>")
		return 1

	user.visible_message("<span class='userdanger'>[user] starts sacrificing [victim] to Riniel, the ruler of the underworld.</span>")
	if(do_after(user, victim, 6 SECONDS))
		if(!can_sacrifice(victim, user))
			return 1

		victim.visible_message("<span class='sinister'>[victim]'s body crumbles to dust.</span>")
		sacrifice(victim, user)


	return 1

//Magic door that only unlocks when you put an adamantine coin in it

/obj/machinery/door/mineral/sandstone/tomb
	var/unlocked = 0

/obj/machinery/door/mineral/sandstone/tomb/New()
	..()

	name = "Chamber of Madness"

/obj/machinery/door/mineral/sandstone/tomb/open()
	if(!unlocked) return

	..()

/obj/machinery/door/mineral/sandstone/tomb/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/coin/adamantine))
		to_chat(user, "<span class='info'>You unseal \the [src].</span>")
		unlocked = 1

	//no ..() to prevent peopel from being able to damage this door

/obj/machinery/door/mineral/sandstone/tomb/ex_act()
	return

//Fire shooting pipe
/obj/structure/fire_trap
	name = "mysterious pipe"
	desc = "A pipe looking out from a wall."
	icon_state = "pipe"

	anchored = 1
	density = 0

	var/movement_dir = SOUTH

	var/fire_projectile = /obj/item/projectile/fire_breath
	var/fire_sound = 'sound/weapons/flamethrower.ogg'

	var/last_fired
	var/fire_cooldown = 40

	var/default_dir = SOUTH

/obj/structure/fire_trap/New()
	..()

	processing_objects.Add(src)
	default_dir = dir
	movement_dir = turn(dir, pick(90, 270))

	fire_cooldown = rand(30,60)

/obj/structure/fire_trap/Destroy()
	processing_objects.Remove(src)

	..()

/obj/structure/fire_trap/process()
	//Process movement
	if(movement_dir)
		if(!Move(get_step(src, movement_dir)))
			movement_dir = turn(movement_dir, 180)

	//Process firing
	dir = default_dir
	if(world.time > last_fired + fire_cooldown)
		last_fired = world.time

		shoot()

/obj/structure/fire_trap/proc/shoot()
	var/obj/item/projectile/A = new fire_projectile(get_step(src, turn(dir, 180)))

	if(!A)
		return 0

	playsound(get_turf(src), fire_sound, 50, 1)


	var/turf/T = get_step(src, turn(dir, 180)) //One turf behind us
	var/turf/U = get_step(src, dir) //Turf in front of us
	A.original = U
	A.target = U
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn()
		A.OnFired()
		A.process()


//WOODEN SUPPORTS
//Collapse when they catch fire, spawning an unnaturally hard rock wall and gibbing all mobs underneath
/obj/structure/wooden_support
	name = "wooden support"
	desc = "A structure that holds up the rocky ceiling. Extremely flammable."

	icon = 'icons/obj/structures.dmi'
	icon_state = "wooden_support"

	opacity = 0
	density = 0

	layer = MOB_LAYER + 0.1
	plane = PLANE_MOB
	autoignition_temperature = AUTOIGNITION_WOOD // TODO:  Special ash subtype that looks like charred table legs.
	fire_fuel = 5

/obj/structure/wooden_support/fire_act()
	visible_message("<span class='danger'>\The [src] catches fire and collapses!</span>")

	var/turf/T = get_turf(src)

	T.ChangeTurf(/turf/unsimulated/wall/rock)
	for(var/atom/movable/AM in T)
		AM.ex_act(1)

	explosion(T, -1, -1, 1)
