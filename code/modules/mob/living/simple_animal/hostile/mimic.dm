//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/carpmeat
	response_help = "touches the"
	response_disarm = "pushes the"
	response_harm = "hits the"
	speed = -1
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

/mob/living/simple_animal/hostile/mimic/FindTarget()
	. = ..()
	if(.)
		emote("growls at [.]")

/mob/living/simple_animal/hostile/mimic/Die()
	..()
	visible_message("\red <b>[src]</b> stops moving!")
	del(src)



//
// Crate Mimic
//


// Aggro when you try to open them. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate

	attacktext = "bites"

	stop_automated_movement = 1
	wander = 0
	var/attempt_open = 0

// Pickup loot
/mob/living/simple_animal/hostile/mimic/crate/initialize()
	..()
	for(var/obj/item/I in loc)
		I.loc = src

/mob/living/simple_animal/hostile/mimic/crate/DestroySurroundings()
	..()
	if(prob(90))
		icon_state = "[initial(icon_state)]open"
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/ListTargets()
	if(attempt_open)
		return view(src, 10)
	return view(src, 1)

/mob/living/simple_animal/hostile/mimic/crate/FindTarget()
	. = ..()
	if(.)
		trigger()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. = ..()
	if(.)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<b>[src]</b> starts to move!")
		attempt_open = 1

/mob/living/simple_animal/hostile/mimic/crate/adjustBruteLoss(var/damage)
	trigger()
	..(damage)

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/mimic/crate/Die()

	var/obj/structure/closet/crate/C = new(get_turf(src))
	// Put loot in crate
	for(var/obj/O in src)
		O.loc = C
	..()

/mob/living/simple_animal/hostile/mimic/crate/AttackingTarget()
	. =..()
	var/mob/living/L = .
	if(istype(L))
		if(prob(15))
			L.Weaken(2)
			L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")

//
// Copy Mimic
//

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100
	var/obj/item/staff = null // the staff that changed they, never attack the bearer of this staff
	destroy_surroundings = 0
	var/knockdown_people = 0

/mob/living/simple_animal/hostile/mimic/copy/New(loc, var/obj/copy, var/obj/item/staff)
	..(loc)
	CopyObject(copy, staff)

/mob/living/simple_animal/hostile/mimic/copy/Die()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the holder of our staff
	return view(src, 7) - get(staff, /mob)

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(var/obj/O, var/obj/item/staff)

	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))

		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state

		if(istype(O, /obj/structure))
			health = (anchored * 50) + 50
			destroy_surroundings = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(istype(O, /obj/item))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class

		maxHealth = health
		if(staff)
			src.staff = staff
			faction = "\ref[staff]" // very unique
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. =..()
	if(knockdown_people)
		var/mob/living/L = .
		if(istype(L))
			if(prob(15))
				L.Weaken(1)
				L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")