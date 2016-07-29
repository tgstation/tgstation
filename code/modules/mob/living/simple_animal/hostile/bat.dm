/mob/living/simple_animal/hostile/scarybat
	name = "space bats"
	desc = "A swarm of cute little blood sucking bats that looks pretty pissed."
	icon = 'icons/mob/bats.dmi'
	icon_state = "bat"
	icon_living = "bat"
	icon_dead = "bat_dead"
	icon_gib = "bat_dead"
	speak_chance = 0
	turns_per_move = 3
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 20
	health = 20
	flying = 1

	harm_intent_damage = 8
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	//Space carp aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	holder_type = null //Can't pick a SWARM OF BATS up

	environment_smash = 1
	size = SIZE_TINY

	faction = "scarybat"
	var/mob/living/owner

/mob/living/simple_animal/hostile/scarybat/New(loc, mob/living/L as mob)
	..()
	if(istype(L))
		owner = L

/mob/living/simple_animal/hostile/scarybat/Process_Spacemove(var/check_drift = 0)
	return ..()	//No drifting in space for space carp!	//original comments do not steal

/mob/living/simple_animal/hostile/scarybat/CanAttack(var/atom/the_target)
	if(the_target == owner)
		return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/scarybat/FindTarget()
	. = ..()
	if(.)
		emote("flutters towards [.]")

/mob/living/simple_animal/hostile/scarybat/Found(var/atom/A)//This is here as a potential override to pick a specific target if available
	if(istype(A) && A == owner)
		return 0
	return ..()

/mob/living/simple_animal/hostile/scarybat/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Stun(1)
			L.visible_message("<span class='danger'>\the [src] scares \the [L]!</span>")

/mob/living/simple_animal/hostile/scarybat/cult
	faction = "cult"
	var/shuttletarget = null
	var/enroute = 0

	supernatural = 1

/mob/living/simple_animal/hostile/scarybat/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(iscultist(the_target))
		return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/scarybat/cult/cultify()
	return

/mob/living/simple_animal/hostile/scarybat/cult/Life()
	if(timestopped) return 0 //under effects of time magick
	..()
	if(emergency_shuttle.location == 1)
		if(!enroute && !target)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget && escape_list.len) //Make sure we didn't already assign it a target, and that there are targets to pick
				shuttletarget = pick(escape_list) //Pick a shuttle target
			enroute = 1
			stop_automated_movement = 1
/*			spawn()
				if(!src.stat)
					horde()*/

		if(get_dist(src, shuttletarget) <= 2)		//The monster reached the escape hallway
			enroute = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/scarybat/cult/proc/horde()
	var/turf/T = get_step_to(src, shuttletarget)
	for(var/atom/A in T)
		if(istype(A,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = A
			if(D.density && !D.locked && !D.welded)
				D.open()
		else if(istype(A,/obj/machinery/door/mineral))
			var/obj/machinery/door/D = A
			if(D.density)
				D.open()
		else if(istype(A,/obj/structure/cult/pylon))
			A.attack_animal(src)
		else if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
			A.attack_animal(src)
	Move(T)
	var/new_target = FindTarget()
	GiveTarget(new_target)
	if(!target || enroute)
		spawn(10)
			if(!src.stat)
				horde()



/mob/living/simple_animal/hostile/scarybat/book
	name = "flying book"
	desc = "An enchanted book, flying through the air by flapping it's pages."
	icon = 'icons/mob/animal.dmi'
	icon_state = "bookbat"
	icon_living = "bookbat"
	icon_dead = "bookbat_dead"
	icon_gib = "bookbat_dead"
	speak_chance = 0
	turns_per_move = 3
	response_help = "pats the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 15
	health = 15
	var/book_cover

	harm_intent_damage = 8
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "clamps shut on"
	attack_sound = 'sound/effects/pageturn3.ogg'

	holder_type = /obj/item/weapon/holder/animal //CAN pick up a single book!

mob/living/simple_animal/hostile/scarybat/book/New()
	..()
	if(!book_cover)
		book_cover = pick( list("red","purple","blue","green") )
	icon_state = "bookbat_[book_cover]"
	icon_living = "bookbat_[book_cover]"
	icon_dead = "bookbat_[book_cover]_dead"

/mob/living/simple_animal/hostile/scarybat/book/woody
	name = "Woody"
	desc = "A close friend to many librarians."
	icon_state = "bookbat_woody"
	icon_living = "bookbat_woody"
	icon_dead = "bookbat_woody_dead"
	icon_gib = "bookbat_woody_dead"
	book_cover = "woody"
	environment_smash = 0
	harm_intent_damage = 0
	melee_damage_lower = 0
	melee_damage_upper = 0