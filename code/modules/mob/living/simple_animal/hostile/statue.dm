// A mob which only moves when it isn't being watched by living beings.

/mob/living/simple_animal/hostile/statue
	name = "human statue"
	desc = "It looks spooky. Its eye seems to follow you.."
	icon = 'icons/obj/statue.dmi'
	icon_state = "human_male"
	icon_living = "human_male"
	icon_dead = "human_male"
	gender = NEUTER
	a_intent = "harm"

	response_help = "touches"
	response_disarm = "pushes"

	speed = -1
	maxHealth = 25000
	health = 25000

	harm_intent_damage = 40
	melee_damage_lower = 38
	melee_damage_upper = 43
	attacktext = "claws"
	attack_sound = 'sound/hallucinations/growl1.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "statue"
	move_to_delay = 2 // Very fast

	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.

	see_in_dark = 15
	vision_range = 14
	aggro_vision_range = 14
	idle_vision_range = 14

	search_objects = 1 // So that it can see through walls

	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS
	anchored = 1
	status_flags = GODMODE // Cannot push also


// No movement while seen code.

/mob/living/simple_animal/hostile/statue/New()
	..()
	// Give spells
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/flicker_lights(src)
	spell_list += new /obj/effect/proc_holder/spell/aoe_turf/blindness(src)
	spell_list += new /obj/effect/proc_holder/spell/targeted/night_vision(src)

	// Give nightvision
	see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/mob/living/simple_animal/hostile/statue/Move(NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			src << "<span class='warning'>You cannot move, there are eyes on you!</span>"
		return 0
	return ..()

/mob/living/simple_animal/hostile/statue/AttackingTarget()
	if(!can_be_seen())
		..()

/mob/living/simple_animal/hostile/statue/DestroySurroundings()
	if(!can_be_seen())
		..()

/mob/living/simple_animal/hostile/statue/UnarmedAttack()
	if(can_be_seen())
		if(client)
			src << "<span class='warning'>You cannot attack, there are eyes on you!</span>"
		return
	..()

/mob/living/simple_animal/hostile/statue/proc/can_be_seen(var/turf/destination)

	// Check for darkness
	var/turf/T = get_turf(loc)
	if(T)
		if(!T.lighting_lumcount) // No one can see us in the darkness, right?
			if(!destination || !destination.lighting_lumcount)
				return 0

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(destination)
		check_list += destination

	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(world.view + 1, check))
			if(M.client && !istype(M, type))
				if(!M.blinded && !(sdisabilities & BLIND))
					return 1
	return 0

// Cannot talk

/mob/living/simple_animal/hostile/statue/say()
	return 0

// Statue powers

// Flicker lights
/obj/effect/proc_holder/spell/aoe_turf/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	charge_max = 300
	clothes_req = 0
	range = 18

/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.flicker()
	return

//Blind AOE
/obj/effect/proc_holder/spell/aoe_turf/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	charge_max = 800
	clothes_req = 0
	range = 7

/obj/effect/proc_holder/spell/aoe_turf/blindness/cast(list/targets)
	for(var/turf/T in targets)
		for(var/mob/living/L in T)
			if(L != loc)
				L.eye_blind = max(L.eye_blind, 3)
	return

//Toggle Night Vision
/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision \[ON\]"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets)

	for(var/mob/living/target in targets)
		if(target.see_invisible == SEE_INVISIBLE_LIVING)
			target.see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING
			name = "Toggle Nightvision \[ON\]"
		else
			target.see_invisible = SEE_INVISIBLE_LIVING
			name = "Toggle Nightvision \[OFF\]"
	return