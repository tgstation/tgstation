/obj/item/wrench/syndicate
	name = "Pipe wrench"
	desc = "A rather dangerous looking pipe wrench with teeth that grip better than a normal wrench."
	icon = 'hippiestation/icons/obj/tools.dmi'
	icon_state = "wrench_nuke"
	origin_tech = "materials=1;engineering=1;syndicate=1"
	toolspeed = 0.5

/obj/item/wirecutters/syndicate
	name = "Bolt cutters"
	desc = "A sturdy set of bolt cutters that lets the user put more leverage into cutting through grilles, wire and people."
	origin_tech = "materials=1;engineering=1;syndicate=1"
	icon = 'hippiestation/icons/obj/tools.dmi'
	icon_state = "cutters_nuke"
	toolspeed = 0.5

/obj/item/weldingtool/syndicate
	name = "Precision welding tool"
	desc = "The thin nozzle on this welding tool produces a smaller but far hotter flame, allowing it to cut through thick metal much faster."
	icon = 'hippiestation/icons/obj/tools.dmi'
	icon_state = "welder_nuke"
	origin_tech = "engineering=1;plasmatech=1;syndicate=1"
	max_fuel = 40
	toolspeed = 0.5

/obj/item/weldingtool/syndicate/flamethrower_screwdriver()
	return

/obj/item/crowbar/syndicate
	name = "Flat headed crowbar"
	desc = "This crowbar's prying ends are longer and thinner, letting the user really force it into gaps and crevices."
	icon = 'hippiestation/icons/obj/tools.dmi'
	icon_state = "crowbar_nuke"
	origin_tech = "engineering=1;combat=1;syndicate=1"
	toolspeed = 0.5
	var/alien_bonus_damage = 60 //Half life joke, also three shots any non royal alien

/obj/item/crowbar/syndicate/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(isalien(M))
		return gordon_freeman(M, user, alien_bonus_damage)
	else
		return ..()

/obj/item/crowbar/syndicate/proc/gordon_freeman(mob/living/carbon/alien/M, mob/living/carbon/user, damage)
	if(!isalien(M))
		return
	var/mob/living/carbon/alien/A = M
	src.add_fingerprint(user)
	user.do_attack_animation(A)
	A.apply_damage(damage, BRUTE)
	playsound(loc, src.hitsound, 30, 1, -1)
