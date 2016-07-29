<<<<<<< HEAD
#define EMPTY 1
#define WIRED 2
#define READY 3

/obj/item/weapon/grenade/chem_grenade
	name = "chemical grenade"
	desc = "A custom made grenade."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = 2
	force = 2
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.

/obj/item/weapon/grenade/chem_grenade/New()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.


/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state
	..()


/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		if(nadeassembly)
			nadeassembly.attack_self(user)
		else if(clown_check(user))
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[key_name_admin(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[usr]'>FLW</A>) has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
			user << "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>"
			playsound(user.loc, 'sound/weapons/armbomb.ogg', 60, 1)
			active = 1
			icon_state = initial(icon_state) + "_active"
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

			addtimer(src, "prime", det_time)


/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				stage_change(READY)
				user << "<span class='notice'>You lock the [initial(name)] assembly.</span>"
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, -3)
			else
				user << "<span class='warning'>You need to add at least one beaker before locking the [initial(name)] assembly!</span>"
		else if(stage == READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			user << "<span class='notice'>You modify the time delay. It's set for [det_time / 10] second\s.</span>"
		else if(stage == EMPTY)
			user << "<span class='warning'>You need to add an activation mechanism!</span>"

	else if(stage == WIRED && is_type_in_list(I, allowed_containers))
		. = 1 //no afterattack
		if(beakers.len == 2)
			user << "<span class='warning'>[src] can not hold more containers!</span>"
			return
		else
			if(I.reagents.total_volume)
				if(!user.unEquip(I))
					return
				user << "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>"
				I.loc = src
				beakers += I
			else
				user << "<span class='warning'>[I] is empty!</span>"

	else if(stage == EMPTY && istype(I, /obj/item/device/assembly_holder))
		. = 1 // no afterattack
		var/obj/item/device/assembly_holder/A = I
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return
		if(!user.unEquip(I))
			return

		nadeassembly = A
		A.master = src
		A.loc = src
		assemblyattacher = user.ckey

		stage_change(WIRED)
		user << "<span class='notice'>You add [A] to the [initial(name)] assembly.</span>"

	else if(stage == EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(WIRED)
			user << "<span class='notice'>You rig the [initial(name)] assembly.</span>"
		else
			user << "<span class='warning'>You need one length of coil to wire the assembly!</span>"
			return

	else if(stage == READY && istype(I, /obj/item/weapon/wirecutters))
		stage_change(WIRED)
		user << "<span class='notice'>You unlock the [initial(name)] assembly.</span>"

	else if(stage == WIRED && istype(I, /obj/item/weapon/wrench))
		if(beakers.len)
			for(var/obj/O in beakers)
				O.loc = get_turf(src)
			beakers = list()
			user << "<span class='notice'>You open the [initial(name)] assembly and remove the payload.</span>"
			return // First use of the wrench remove beakers, then use the wrench to remove the activation mechanism.
		if(nadeassembly)
			nadeassembly.loc = get_turf(src)
			nadeassembly.master = null
			nadeassembly = null
		else // If "nadeassembly = null && stage == WIRED", then it most have been cable_coil that was used.
			new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(EMPTY)
		user << "<span class='notice'>You remove the activation mechanism from the [initial(name)] assembly.</span>"
	else
		return ..()

/obj/item/weapon/grenade/chem_grenade/proc/stage_change(N)
	if(N)
		stage = N
	if(stage == EMPTY)
		name = "[initial(name)] casing"
		desc = "A do it yourself [initial(name)]!"
		icon_state = initial(icon_state)
	else if(stage == WIRED)
		name = "unsecured [initial(name)]"
		desc = "An unsecured [initial(name)] assembly."
		icon_state = "[initial(icon_state)]_ass"
	else if(stage == READY)
		name = initial(name)
		desc = initial(desc)
		icon_state = "[initial(icon_state)]_locked"


//assembly stuff
/obj/item/weapon/grenade/chem_grenade/receive_signal()
	prime()


/obj/item/weapon/grenade/chem_grenade/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/weapon/grenade/chem_grenade/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/weapon/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		reactants += G.reagents

	if(!chem_splash(get_turf(src), affected_area, reactants, ignition_temp, threatscale))
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [key_name_admin(M)]<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>(?)</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>) and last touched by [key_name_admin(last)]<A HREF='?_src_=holder;adminmoreinfo=\ref[last]'>(?)</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[last]'>FLW</A>) ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z])")

	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A grenade detonated at [DA.name] ([DT.x], [DT.y], [DT.z])")

	update_mob()

	qdel(src)

//Large chem grenades accept slime cores and use the appropriately.
/obj/item/weapon/grenade/chem_grenade/large
	name = "large grenade"
	desc = "A custom made large grenade. It affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass,/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = "combat=3;engineering=3"
	affected_area = 5
	ignition_temp = 25 // Large grenades are slightly more effective at setting off heat-sensitive mixtures than smaller grenades.
	threatscale = 1.1	// 10% more effective.

/obj/item/weapon/grenade/chem_grenade/large/prime()
	if(stage != READY)
		return

	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			//If there is still a core (sometimes it's used up)
			//and there are reagents left, behave normally

			if(S && S.reagents && S.reagents.total_volume)
				S.reagents.trans_to(src,S.reagents.total_volume)
			return
	..()

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/weapon/grenade/chem_grenade/large/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		if(!user.unEquip(I))
			return
		user << "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>"
		I.loc = src
		beakers += I
	else
		return ..()

/obj/item/weapon/grenade/chem_grenade/cryo // Intended for rare cryogenic mixes. Cools the area moderately upon detonation.
	name = "cryo grenade"
	desc = "A custom made cryogenic grenade. It rapidly cools its contents upon detonation."
	icon_state = "cryog"
	affected_area = 2
	ignition_temp = -100

/obj/item/weapon/grenade/chem_grenade/pyro // Intended for pyrotechnical mixes. Produces a small fire upon detonation, igniting potentially flammable mixtures.
	name = "pyro grenade"
	desc = "A custom made pyrotechnical grenade. It heats up and ignites its contents upon detonation."
	icon_state = "pyrog"
	origin_tech = "combat=4;engineering=4"
	affected_area = 3
	ignition_temp = 500 // This is enough to expose a hotspot.

/obj/item/weapon/grenade/chem_grenade/adv_release // Intended for weaker, but longer lasting effects. Could have some interesting uses.
	name = "advanced release grenade"
	desc = "A custom made advanced release grenade. It is able to be detonated more than once. Can be configured using a multitool."
	icon_state = "timeg"
	origin_tech = "combat=3;engineering=4"
	var/unit_spread = 10 // Amount of units per repeat. Can be altered with a multitool.

/obj/item/weapon/grenade/chem_grenade/adv_release/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		switch(unit_spread)
			if(0 to 24)
				unit_spread += 5
			if(25 to 99)
				unit_spread += 25
			else
				unit_spread = 5
		user << "<span class='notice'> You set the time release to [unit_spread] units per detonation.</span>"
		return
	..()

/obj/item/weapon/grenade/chem_grenade/adv_release/prime()
	if(stage != READY)
		return

	var/total_volume = 0
	for(var/obj/item/weapon/reagent_containers/RC in beakers)
		total_volume += RC.reagents.total_volume
	if(!total_volume)
		qdel(src)
		qdel(nadeassembly)
		return
	var/fraction = unit_spread/total_volume
	var/datum/reagents/reactants = new(unit_spread)
	reactants.my_atom = src
	for(var/obj/item/weapon/reagent_containers/RC in beakers)
		RC.reagents.trans_to(reactants, RC.reagents.total_volume*fraction, threatscale, 1, 1)
	chem_splash(get_turf(src), affected_area, list(reactants), ignition_temp, threatscale)

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [key_name_admin(M)]<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>(?)</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>) and last touched by [key_name_admin(last)]<A HREF='?_src_=holder;adminmoreinfo=\ref[last]'>(?)</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[last]'>FLW</A>) ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>.")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] ([T.x], [T.y], [T.z])")
	else
		addtimer(src, "prime", det_time)
	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A grenade detonated at [DA.name] ([DT.x], [DT.y], [DT.z])")





//////////////////////////////
////// PREMADE GRENADES //////
//////////////////////////////

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminium", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("facid", 10)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("stable_plasma", 25)
	B2.reagents.add_reagent("sacid", 25)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/teargas/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 60)
	B1.reagents.add_reagent("potassium", 40)
	B2.reagents.add_reagent("phosphorus", 40)
	B2.reagents.add_reagent("sugar", 40)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/facid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/facid/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("facid", 290)
	B1.reagents.add_reagent("potassium", 10)
	B2.reagents.add_reagent("phosphorus", 10)
	B2.reagents.add_reagent("sugar", 10)
	B2.reagents.add_reagent("facid", 280)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/colorful
	name = "colorful grenade"
	desc = "Used for wide scale painting projects."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/colorful/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("colorful_reagent", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2


/obj/item/weapon/grenade/chem_grenade/clf3
	name = "clf3 grenade"
	desc = "BURN!-brand foaming clf3. In a special applicator for rapid purging of wide areas."
	stage = READY

/obj/item/weapon/grenade/chem_grenade/clf3/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 250)
	B1.reagents.add_reagent("clf3", 50)
	B2.reagents.add_reagent("water", 250)
	B2.reagents.add_reagent("clf3", 50)

	beakers += B1
	beakers += B2

/obj/item/weapon/grenade/chem_grenade/bioterrorfoam
	name = "Bio terror foam grenade"
	desc = "Tiger Cooperative chemical foam grenade. Causes temporary irration, blindness, confusion, mutism, and mutations to carbon based life forms. Contains additional spore toxin"
	stage = READY

/obj/item/weapon/grenade/chem_grenade/bioterrorfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("cryptobiolin", 75)
	B1.reagents.add_reagent("water", 50)
	B1.reagents.add_reagent("mutetoxin", 50)
	B1.reagents.add_reagent("spore", 75)
	B1.reagents.add_reagent("itching_powder", 50)
	B2.reagents.add_reagent("fluorosurfactant", 150)
	B2.reagents.add_reagent("mutagen", 150)
	beakers += B1
	beakers += B2

/obj/item/weapon/grenade/chem_grenade/tuberculosis
 	name = "Fungal tuberculosis grenade"
 	desc = "WARNING: GRENADE WILL RELEASE DEADLY SPORES CONTAINING ACTIVE AGENTS. SEAL SUIT AND AIRFLOW BEFORE USE."
 	stage = READY

/obj/item/weapon/grenade/chem_grenade/tuberculosis/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("potassium", 50)
	B1.reagents.add_reagent("phosphorus", 50)
	B1.reagents.add_reagent("fungalspores", 200)
	B2.reagents.add_reagent("blood", 250)
	B2.reagents.add_reagent("sugar", 50)

	beakers += B1
	beakers += B2

#undef EMPTY
#undef WIRED
#undef READY
=======
/obj/item/weapon/grenade/chem_grenade
	name = "grenade casing"
	icon_state = "chemg"
	item_state = "flashbang"
	desc = "A hand made chemical grenade."
	w_class = W_CLASS_SMALL
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/device/assembly_holder/detonator = null
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/inserted_cores = 0
	var/obj/item/slime_extract/E = null	//for large and Ex grenades
	var/obj/item/slime_extract/C = null	//for Ex grenades
	var/obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade/reservoir = null
	var/extract_uses = 0
	var/mob/primed_by = "N/A" //"name (ckey)". For logging purposes

/obj/item/weapon/grenade/chem_grenade/attack_self(mob/user as mob)
	if(!stage || stage==1)
		if(detonator)
//				detonator.loc=src.loc
			detonator.detached()
			usr.put_in_hands(detonator)
			detonator=null
			stage=0
			icon_state = initial(icon_state)
		else if(beakers.len)
			for(var/obj/B in beakers)
				if(istype(B))
					beakers -= B
					user.put_in_hands(B)
					E = null
					C = null
					inserted_cores = 0
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
	if(stage > 1 && !active && clown_check(user))
		to_chat(user, "<span class='attack'>You prime \the [name]!</span>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src].</font>")
		log_admin("ATTACK: [user] ([user.ckey]) primed \a [src].")
		message_admins("ATTACK: [user] ([user.ckey]) primed \a [src].")
		primed_by = "[user] ([user.ckey])"

		activate()
		add_fingerprint(user)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.throw_mode_on()

/obj/item/weapon/grenade/chem_grenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, "<span class='warning'> Assembly must contain one igniter.</span>")
			return
		if(!det.secured)
			to_chat(user, "<span class='warning'> Assembly must be secured with screwdriver.</span>")
			return
		path = 1
		to_chat(user, "<span class='notice'>You add [W] to the metal casing.</span>")
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
		user.remove_from_mob(det)
		det.loc = src
		detonator = det
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1
	else if(istype(W,/obj/item/stack/cable_coil/) && !beakers.len)
		var/obj/item/stack/cable_coil/coil = W
		if(coil.amount < 2) return
		coil.use(2)
		var/obj/item/weapon/electrolyzer/E = new /obj/item/weapon/electrolyzer
		to_chat(user, "<span class='notice'>You tightly coil the wire around the metal casing.</span>")
		playsound(get_turf(src), 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		user.before_take_item(src)
		user.put_in_hands(E)
		qdel(src)
	else if(istype(W,/obj/item/weapon/screwdriver) && path != 2)
		if(stage == 1)
			path = 1
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				name = "grenade"
			else
//					to_chat(user, "<span class='warning'>You need to add at least one beaker before locking the assembly.</span>")
				to_chat(user, "<span class='warning'>You lock the empty assembly.</span>")
				name = "fake grenade"
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				to_chat(user, "<span class='warning'>You trigger the assembly!</span>")
				prime()
				return
			else
				to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
				name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 2)
			to_chat(user, "<span class='warning'> The grenade can not hold more containers.</span>")
			return
		else
			if (istype(W,/obj/item/slime_extract))
				if (inserted_cores > 0)
					to_chat(user, "<span class='warning'> This type of grenade cannot hold more than one slime core.</span>")
				else
					if(user.drop_item(W, src))
						to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
						beakers += W
						stage = 1
						name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else if(W.reagents.total_volume)
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
					beakers += W
					stage = 1
					name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				to_chat(user, "<span class='warning'> \the [W] is empty.</span>")
	else if (istype(W,/obj/item/slime_extract))
		to_chat(user, "<span class='warning'> This grenade case is too small for a slime core to fit in it.</span>")
	else if(iscrowbar(W))
		to_chat(user, "You begin pressing \the [W] into \the [src].")
		if(do_after(user, src, 30))
			to_chat(user, "You poke a hole in \the [src].")
			if(src.loc == user)
				user.drop_item(src, force_drop = 1)
				var/obj/item/weapon/fuel_reservoir/I = new (get_turf(user))
				user.put_in_hands(I)
				qdel(src)
			else
				new /obj/item/weapon/fuel_reservoir(get_turf(src.loc))
				qdel(src)

/obj/item/weapon/grenade/chem_grenade/examine(mob/user)
	..()
	if(detonator)
		to_chat(user, "<span class='info'>With an attached [detonator.name]</span>")

/obj/item/weapon/grenade/chem_grenade/Crossed(AM as mob|obj)
	if(detonator)
		detonator.Crossed(AM)
	..()

/obj/item/weapon/grenade/chem_grenade/on_found(AM as mob|obj)
	if(detonator)
		detonator.on_found(AM)
	..()

/obj/item/weapon/grenade/chem_grenade/activate(mob/user as mob)
	if(active) return

	if(detonator)
		if(!isigniter(detonator.a_left))
			detonator.a_left.activate()
			active = 1
		if(!isigniter(detonator.a_right))
			detonator.a_right.activate()
			active = 1
	if(active)
		icon_state = initial(icon_state) + "_active"

		if(user)
			log_attack("<font color='red'>[user.name] ([user.ckey]) primed \a [src]</font>")
			log_admin("ATTACK: [user] ([user.ckey]) primed \a [src]")
			message_admins("ATTACK: [user] ([user.ckey]) primed \a [src]")
			primed_by = "[user] ([user.ckey])"

	return

/obj/item/weapon/grenade/chem_grenade/proc/primed(var/primed = 1)
	if(active)
		icon_state = initial(icon_state) + (primed?"_primed":"_active")

/obj/item/weapon/grenade/chem_grenade/prime()
	if(!stage || stage<2) return

	//if(prob(reliability))
	var/has_reagents = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		if(G.reagents.total_volume) has_reagents = 1

	active = 0
	if(!has_reagents)
		icon_state = initial(icon_state) +"_locked"
		playsound(get_turf(src), 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(get_turf(src), 'sound/effects/bamfgas.ogg', 50, 1)

	visible_message("<span class='warning'>[bicon(src)] \The [src] bursts open.</span>")

	reservoir = new /obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade() //acts like a stasis beaker, so the chemical reactions don't occur before all the slime reactions have occured

	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(reservoir, G.reagents.total_volume)
	for(var/obj/item/slime_extract/S in beakers)		//checking for reagents inside the slime extracts
		S.reagents.trans_to(reservoir, S.reagents.total_volume)
	if (E != null)
		extract_uses = E.Uses
		for(var/i=1,i<=extract_uses,i++)//<-------//exception for slime extracts injected with steroids. The grenade will repeat its checks untill all its remaining uses are gone
			if (reservoir.reagents.has_reagent(PLASMA, 5))
				reservoir.reagents.trans_id_to(E, PLASMA, 5)		//If the grenade contains a slime extract, the grenade will check in this order
			else if (reservoir.reagents.has_reagent(BLOOD, 5))	//for any Plasma -> Blood ->or Water among the reagents of the other containers
				reservoir.reagents.trans_id_to(E, BLOOD, 5)		//and inject 5u of it into the slime extract.
			else if (reservoir.reagents.has_reagent(WATER, 5))
				reservoir.reagents.trans_id_to(E, WATER, 5)
			else if (reservoir.reagents.has_reagent(SUGAR, 5))
				reservoir.reagents.trans_id_to(E, SUGAR, 5)
		if(E.reagents.total_volume)						  //<-------//exception for slime reactions that produce new reagents. The grenade checks if any
			E.reagents.trans_to(reservoir, E.reagents.total_volume)	//reagents are left in the slime extracts after the slime reactions occured
		if (C != null)
			extract_uses = C.Uses
			for(var/j=1,j<=extract_uses,j++)	//why don't anyone ever uses "while" directives anyway?
				if (reservoir.reagents.has_reagent(PLASMA, 5))
					reservoir.reagents.trans_id_to(C, PLASMA, 5)	//since the order in which slime extracts are inserted matters (in the case of an Ex grenade)
				else if (reservoir.reagents.has_reagent(BLOOD, 5))//this allow users to plannify which reagent will get into which extract.
					reservoir.reagents.trans_id_to(C, BLOOD, 5)
				else if (reservoir.reagents.has_reagent(WATER, 5))
					reservoir.reagents.trans_id_to(C, WATER, 5)
				else if (reservoir.reagents.has_reagent(SUGAR, 5))
					reservoir.reagents.trans_id_to(C, SUGAR, 5)
			if(C.reagents.total_volume)
				C.reagents.trans_to(reservoir, C.reagents.total_volume)

		reservoir.reagents.update_total()

	investigation_log(I_CHEMS, "has detonated, containing [reservoir.reagents.get_reagent_ids(1)] - Primed by: [primed_by]")

	reservoir.reagents.trans_to(src, reservoir.reagents.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(affected_area, get_turf(src)))
			if( A == src ) continue
			src.reagents.reaction(A, 1, 10)

	invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(50)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.
	/*else
		icon_state = initial(icon_state) + "_locked"
		crit_fail = 1
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.loc = get_turf(src.loc)*/

/obj/item/weapon/grenade/chem_grenade/New()
	. = ..()
	create_reagents(1000)

/obj/item/weapon/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/slime_extract)
	origin_tech = "combat=3;materials=3"
	affected_area = 4

obj/item/weapon/grenade/chem_grenade/exgrenade
	name = "EX Chem Grenade"
	desc = "A specially designed large grenade that can hold three containers."
	icon_state = "ex_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass, /obj/item/slime_extract)
	origin_tech = "combat=4;materials=3;engineering=2"
	affected_area = 4

obj/item/weapon/grenade/chem_grenade/exgrenade/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/assembly_holder) && (!stage || stage==1) && path != 2)
		var/obj/item/device/assembly_holder/det = W
		if(istype(det.a_left,det.a_right.type) || (!isigniter(det.a_left) && !isigniter(det.a_right)))
			to_chat(user, "<span class='warning'> Assembly must contain one igniter.</span>")
			return
		if(!det.secured)
			to_chat(user, "<span class='warning'> Assembly must be secured with screwdriver.</span>")
			return
		path = 1
		to_chat(user, "<span class='notice'>You insert [W] into the grenade.</span>")
		playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
		user.remove_from_mob(det)
		det.loc = src
		detonator = det
		icon_state = initial(icon_state) +"_ass"
		name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
		stage = 1
	else if(istype(W,/obj/item/weapon/screwdriver) && path != 2)
		if(stage == 1)
			path = 1
			if(beakers.len)
				to_chat(user, "<span class='notice'>You lock the assembly.</span>")
				name = "EX Grenade"
			else
				to_chat(user, "<span class='notice'>You lock the empty assembly.</span>")
				name = "fake grenade"
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
			icon_state = initial(icon_state) +"_locked"
			stage = 2
		else if(stage == 2)
			if(active && prob(95))
				to_chat(user, "<span class='attack'>You trigger the assembly!</span>")
				prime()
				return
			else
				to_chat(user, "<span class='notice'>You unlock the assembly.</span>")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 25, -3)
				name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
				icon_state = initial(icon_state) + (detonator?"_ass":"")
				stage = 1
				active = 0
	else if(is_type_in_list(W, allowed_containers) && (!stage || stage==1) && path != 2)
		path = 1
		if(beakers.len == 3)
			to_chat(user, "<span class='warning'> The grenade can not hold more containers.</span>")
			return
		else
			if (istype(W,/obj/item/slime_extract))
				if (inserted_cores > 1)
					to_chat(user, "<span class='warning'>You cannot fit more than two slime cores in this grenade.</span>")
				else
					if(user.drop_item(W, src))
						to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
						beakers += W
						stage = 1
						name = "unsecured grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else if(W.reagents.total_volume)
				if(user.drop_item(W, src))
					to_chat(user, "<span class='notice'>You add \the [W] to the assembly.</span>")
					beakers += W
					stage = 1
					name = "unsecured EX grenade with [beakers.len] containers[detonator?" and detonator":""]"
			else
				to_chat(user, "<span class='warning'> \the [W] is empty.</span>")

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/metalfoam/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(ALUMINUM, 30)
	B2.reagents.add_reagent(FOAMING_AGENT, 10)
	B2.reagents.add_reagent(PACID, 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/incendiary/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(ALUMINUM, 15)
	//B1.reagents.add_reagent(FUEL,20)
	B2.reagents.add_reagent(PLASMA, 15)
	B2.reagents.add_reagent(SACID, 15)
	//B1.reagents.add_reagent(FUEL,20)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	path = 1
	stage = 2

/obj/item/weapon/grenade/chem_grenade/antiweed/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(PLANTBGONE, 25)
	B1.reagents.add_reagent(POTASSIUM, 25)
	B2.reagents.add_reagent(PHOSPHORUS, 25)
	B2.reagents.add_reagent(SUGAR, 25)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = "grenade"

/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "Cleaner Grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/cleaner/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(FLUOROSURFACTANT, 40)
	B2.reagents.add_reagent(WATER, 40)
	B2.reagents.add_reagent(CLEANER, 10)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/grenade/chem_grenade/wind
	name = "wind grenade"
	desc = "Designed to perfectly bring an empty five-by-five room back into a filled, breathable state. Larger rooms will require additional gas sources."
	stage = 2
	path = 1

/obj/item/weapon/grenade/chem_grenade/wind/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(VAPORSALT, 50)
	B2.reagents.add_reagent(OXYGEN, 10)
	B2.reagents.add_reagent(NITROGEN, 40)

	detonator = new/obj/item/device/assembly_holder/timer_igniter(src)

	beakers += B1
	beakers += B2
	icon_state = initial(icon_state) +"_locked"

/obj/item/weapon/reagent_containers/glass/beaker/noreactgrenade
	name = "grenade reservoir"
	desc = "..."
	icon_state = null
	volume = 1000
	flags = FPRINT  | OPENCONTAINER | NOREACT
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
