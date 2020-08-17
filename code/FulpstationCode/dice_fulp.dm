/obj/item/dice/encounter/d20
	dice_spawn = /mob/living/simple_animal/hostile/poison/bees
	name = "d20"
	desc = "A die with twenty sides. The preferred die to throw at the GM."
	icon_state = "d20"
	sides = 20

/obj/item/dice/encounter/d4
	dice_spawn = /mob/living/simple_animal/hostile/bear
	name = "d4"
	desc = "A die with four sides. The nerd's caltrop."
	icon_state = "d4"
	sides = 4

/obj/item/dice/encounter
	var/dice_spawn = null
	var/owner = null
	dice_spawn = /mob/living/simple_animal/hostile/carp

/obj/item/dice/encounter/attack_self(mob/user)
	diceroll(user)

/obj/item/dice/encounter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	diceroll(thrownby)


/obj/item/dice/encounter/diceroll(mob/roller) //copied wholesale from viscerator grenade code
	..()
	update_mob()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/effects/phasein.ogg', 100, 1)
	var/datum/effect_system/smoke_spread/smoke = new
	src.visible_message("<span class='warning'>ROLL INITIATIVE!</span>")
	smoke.set_up(1, T)
	smoke.start()

	var/list/spawned = spawn_and_random_walk(dice_spawn, T, result, walk_chance=50, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE)) //doing it this way seems important somehow so I'll leave it
	afterspawn(spawned)

	if(!owner)
		owner = roller

	for(var/mob/living/M in spawned)
		if(owner)
			var/mob/living/carbon/H = owner
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
	new /obj/item/dice/encounter/d20(src)
	new /obj/item/dice/encounter/d4(src)
	new /obj/item/dice/encounter(src)

/obj/item/storage/pill_bottle/encounter_dice/attack_self()
	if(!rattled)
		var/mob/living/carbon/H = usr
		to_chat(usr, "<span class='notice'>You give the bag a rattle, for luck.</span>")
		rattled = TRUE
		for(var/obj/item/dice/encounter/D in contents)
			if(!D.owner)
				D.owner = H
