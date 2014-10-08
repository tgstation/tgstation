/mob/living/simple_animal/shade
	name = "Shade"
	real_name = "Shade"
	desc = "A bound spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	icon_dead = "shade_dead"
	maxHealth = 50
	health = 50
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "drains the life from"
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = -1
	stop_automated_movement = 1
	status_flags = 0
	faction = list("cult")
	status_flags = CANPUSH


/mob/living/simple_animal/shade/Life()
	..()
	if(stat == 2)
		new /obj/item/weapon/ectoplasm (src.loc)
		visible_message("<span class='warning'>[src] lets out a contented sigh as their form unwinds.</span>")
		ghostize()
		qdel(src)
		return


/mob/living/simple_animal/shade/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/SS = O
		SS.transfer_soul("SHADE", src, user)
	else
		..()
	return

////////////////////////////
//Spookoween Ghost
///////////////////////////

/mob/living/simple_animal/shade/howling_ghost
	name ="Ghost"
	real_name = "Ghost"
	icon = 'icons/mob/mob.dmi'
	maxHealth = 1e6
	health = 1e6
	speak_emote = list("howls")
	emote_hear = list("wails","screeches")
	density = 0
	anchored = 1
	incorporeal_move = 1
	layer = 4
	var/timer = 0

/mob/living/simple_animal/shade/howling_ghost/New()
	..()
	icon_state = pick("ghost","ghostian","ghostian2","ghostking","ghost1","ghost2")
	icon_living = icon_state
	status_flags |= GODMODE
	timer = rand(1,20)

/mob/living/simple_animal/shade/howling_ghost/Life()
	..()
	timer--
	if(timer == 0)
		roam()
		spooky_ghosty()
		timer = rand(1,20)

/mob/living/simple_animal/shade/howling_ghost/proc/EtherealMove(direction)
	loc = get_step(src, direction)
	dir = direction

/mob/living/simple_animal/shade/howling_ghost/proc/roam()
	if(prob(80))
		var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		EtherealMove(direction)

/mob/living/simple_animal/shade/howling_ghost/proc/spooky_ghosty()
	if(prob(20))//haunt
		playsound(src.loc, pick('sound/spookoween/ghosty_wind.ogg','sound/spookoween/ghost_whisper.ogg','sound/spookoween/chain_rattling.ogg'), 300, 1)
	if(prob(10))//flickers
		var/obj/machinery/light/L = locate(/obj/machinery/light) in view(5, src)
		if(L)
			L.flicker()
		return
	if(prob(5))//poltergeist
		var/obj/item/I = locate(/obj/item) in view(3, src)
		if(I)
			var/direction = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
			step(I,direction)
		return

/mob/living/simple_animal/shade/howling_ghost/adjustBruteLoss()
	return

/mob/living/simple_animal/shade/howling_ghost/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	return 1