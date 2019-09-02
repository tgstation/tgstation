/obj/item/dice/d20/bees
	dice_spawn = /mob/living/simple_animal/hostile/poison/bees

/obj/item/dice/d4/bears
	dice_spawn = /mob/living/simple_animal/hostile/bear

obj/item/dice/carp
	dice_spawn = /mob/living/simple_animal/hostile/carp

/obj/item/dice/proc/dicespawn(SpawnMob) //copied wholesale from viscerator grenade code
	update_mob()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	var/datum/effect_system/smoke_spread/smoke = new
	src.visible_message("<span class='warning'>ROLL INITIATIVE!</span>")
	smoke.set_up(1, T)
	smoke.start()

	var/list/spawned = spawn_and_random_walk(SpawnMob, T, result, walk_chance=50, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE)) //doing it this way seems important somehow so I'll leave it
	afterspawn(spawned)

	for(var/mob/living/M in spawned)
		if(!src.owner)
			src.owner = usr
		var/mob/living/carbon/H = src.owner
		M.faction += H.faction
		M.faction -= "neutral"
	qdel(src)

/obj/item/dice/proc/afterspawn(list/mob/spawned)
	return

/obj/item/dice/proc/update_mob() //no idea what this does but the spawner grenades use it so it must be important
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/storage/pill_bottle/encounter_dice
	name = "bag of dice"
	desc = "Contains all the luck you'll ever need."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	var/rattled = FALSE

/obj/item/storage/pill_bottle/encounter_dice/Initialize()
	. = ..()
	new /obj/item/dice/d20/bees(src)
	new /obj/item/dice/d4/bears(src)
	new /obj/item/dice/carp(src)

/obj/item/storage/pill_bottle/encounter_dice/attack_self()
	if(!rattled)
		var/mob/living/carbon/H = usr
		to_chat(usr, "<span class='notice'>You give the bag a rattle, for luck.</span>")
		rattled = TRUE
		for(var/obj/item/dice/D in contents)
			if(!D.owner)
				D.owner = H
