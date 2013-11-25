#define EMPTY 0
#define WIRED 1
#define READY 2

/obj/item/weapon/grenade/chem_grenade
	name = "grenade casing"
	desc = "A do it yourself grenade casing!"
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = 2
	force = 2
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly_holder/nadeassembly = null


/obj/item/weapon/grenade/chem_grenade/New()
	create_reagents(1000)


/obj/item/weapon/grenade/chem_grenade/examine()
	set src in usr
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state
	..()


/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
		message_admins(log_str)
		log_game(log_str)
		if(nadeassembly)
			nadeassembly.attack_self(user)
		else if(clown_check(user))
			user << "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>"
			active = 1
			icon_state = initial(icon_state) + "_active"
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

			spawn(det_time)
				prime()


/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				user << "<span class='notice'>You lock the assembly.</span>"
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
				icon_state = initial(icon_state) +"_locked"
				stage = READY
			else
				user << "<span class='notice'>You need to add at least one beaker before locking the assembly.</span>"
		else if(stage == READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			user << "<span class='notice'>You modify the time delay. It's set for [det_time / 10] second\s.</span>"
		else if(stage == EMPTY)
			user << "<span class='notice'>You need to add an activation mechanism.</span>"

	else if(stage == WIRED && is_type_in_list(I, allowed_containers))
		if(beakers.len == 2)
			user << "<span class='notice'>[src] can not hold more containers.</span>"
			return
		else
			if(I.reagents.total_volume)
				user << "<span class='notice'>You add [I] to the assembly.</span>"
				user.drop_item()
				I.loc = src
				beakers += I
			else
				user << "<span class='notice'>[I] is empty.</span>"

	else if(stage == EMPTY && istype(I, /obj/item/device/assembly_holder))
		var/obj/item/device/assembly_holder/A = I
		if(!A.secured)
			return
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return

		user.drop_item()
		nadeassembly = A
		A.master = src
		A.loc = src

		stage = WIRED
		icon_state = initial(icon_state) + "_ass"
		user << "<span class='notice'>You add [A] to [src]!</span>"

	else if(stage == EMPTY && istype(I, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = I
		C.use(1)

		stage = WIRED
		icon_state = initial(icon_state) + "_ass"
		user << "<span class='notice'>You rig [src].</span>"

	else if(stage == READY && istype(I, /obj/item/weapon/wirecutters))
		user << "<span class='notice'>You unlock the assembly.</span>"
		icon_state = initial(icon_state) + "_ass"
		stage = WIRED

	else if(stage == WIRED && istype(I, /obj/item/weapon/wrench))
		user << "<span class='notice'>You open the grenade and remove the contents.</span>"
		icon_state = initial(icon_state)
		stage = EMPTY
		if(nadeassembly)
			nadeassembly.loc = get_turf(src)
			nadeassembly.master = null
			nadeassembly = null
		if(beakers.len)
			for(var/obj/O in beakers)
				O.loc = get_turf(src)
			beakers = list()



//assembly stuff
/obj/item/weapon/grenade/chem_grenade/receive_signal()
	prime()

/obj/item/weapon/grenade/chem_grenade/HasProximity(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.HasProximity(AM)

/obj/item/weapon/grenade/chem_grenade/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/weapon/grenade/chem_grenade/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/weapon/grenade/chem_grenade/hear_talk(mob/living/M, msg)
	if(nadeassembly)
		nadeassembly.hear_talk(M, msg)



/obj/item/weapon/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/has_reagents = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(G.reagents.total_volume)
			has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	update_mob()

	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)

	if(reagents.total_volume)	//The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, loc))
			if(A == src)
				continue
			reagents.reaction(A, 1, 10)

	invisibility = INVISIBILITY_MAXIMUM		//Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		del(src)	   //correctly before deleting the grenade.



//Large chem grenades accept slime cores and use the appropriately.
/obj/item/weapon/grenade/chem_grenade/large
	name = "large chem grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass,/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = "combat=3;materials=3"
	affected_area = 4

/obj/item/weapon/grenade/chem_grenade/large/prime()
	if(stage != READY)
		return

	var/has_reagents = 0
	var/obj/item/slime_extract/valid_core = null

	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(!istype(G)) continue
		if(G.reagents.total_volume) has_reagents = 1
	for(var/obj/item/slime_extract/E in beakers)
		if(!istype(E)) continue
		if(E.Uses) valid_core = E
		if(E.reagents.total_volume) has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(loc, 'sound/effects/bamf.ogg', 50, 1)

	update_mob()

	if(valid_core)
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(valid_core, G.reagents.total_volume)

		//If there is still a core (sometimes it's used up)
		//and there are reagents left, behave normally

		if(valid_core && valid_core.reagents && valid_core.reagents.total_volume)
			valid_core.reagents.trans_to(src,valid_core.reagents.total_volume)
	else
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

	if(reagents.total_volume)	//The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, loc))
			if( A == src ) continue
			reagents.reaction(A, 1, 10)

	invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		del(src)	   //correctly before deleting the grenade.


	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/weapon/grenade/chem_grenade/large/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		user << "<span class='notice'>You add [I] to the assembly.</span>"
		user.drop_item()
		I.loc = src
		beakers += I
	else
		return ..()


/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"


/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 25)
		B2.reagents.add_reagent("plasma", 25)
		B2.reagents.add_reagent("sacid", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"


/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("plantbgone", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"


/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 40)
		B2.reagents.add_reagent("water", 40)
		B2.reagents.add_reagent("cleaner", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"


/obj/item/weapon/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("condensedcapsaicin", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

#undef EMPTY
#undef WIRED
#undef READY