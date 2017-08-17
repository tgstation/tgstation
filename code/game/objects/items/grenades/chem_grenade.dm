#define EMPTY 1
#define WIRED 2
#define READY 3

/obj/item/grenade/chem_grenade
	name = "chemical grenade"
	desc = "A custom made grenade."
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	var/stage = EMPTY
	var/list/beakers = list()
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly_holder/nadeassembly = null
	var/assemblyattacher
	var/ignition_temp = 10 // The amount of heat added to the reagents when this grenade goes off.
	var/threatscale = 1 // Used by advanced grenades to make them slightly more worthy.
	var/no_splash = FALSE //If the grenade deletes even if it has no reagents to splash with. Used for slime core reactions.

/obj/item/grenade/chem_grenade/Initialize()
	. = ..()
	create_reagents(1000)
	stage_change() // If no argument is set, it will change the stage to the current stage, useful for stock grenades that start READY.

/obj/item/grenade/chem_grenade/examine(mob/user)
	display_timer = (stage == READY && !nadeassembly)	//show/hide the timer based on assembly state
	..()


/obj/item/grenade/chem_grenade/attack_self(mob/user)
	if(stage == READY &&  !active)
		if(nadeassembly)
			nadeassembly.attack_self(user)
		else if(clown_check(user))
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			message_admins("[ADMIN_LOOKUPFLW(usr)] has primed a [name] for detonation at [A.name][ADMIN_JMP(bombturf)].")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] [COORD(bombturf)].")
			to_chat(user, "<span class='warning'>You prime the [name]! [det_time / 10] second\s!</span>")
			playsound(user.loc, 'sound/weapons/armbomb.ogg', 60, 1)
			active = 1
			icon_state = initial(icon_state) + "_active"
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()

			addtimer(CALLBACK(src, .proc/prime), det_time)


/obj/item/grenade/chem_grenade/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver))
		if(stage == WIRED)
			if(beakers.len)
				stage_change(READY)
				to_chat(user, "<span class='notice'>You lock the [initial(name)] assembly.</span>")
				playsound(loc, I.usesound, 25, -3)
			else
				to_chat(user, "<span class='warning'>You need to add at least one beaker before locking the [initial(name)] assembly!</span>")
		else if(stage == READY && !nadeassembly)
			det_time = det_time == 50 ? 30 : 50	//toggle between 30 and 50
			to_chat(user, "<span class='notice'>You modify the time delay. It's set for [det_time / 10] second\s.</span>")
		else if(stage == EMPTY)
			to_chat(user, "<span class='warning'>You need to add an activation mechanism!</span>")

	else if(stage == WIRED && is_type_in_list(I, allowed_containers))
		. = 1 //no afterattack
		if(beakers.len == 2)
			to_chat(user, "<span class='warning'>[src] can not hold more containers!</span>")
			return
		else
			if(I.reagents.total_volume)
				if(!user.transferItemToLoc(I, src))
					return
				to_chat(user, "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>")
				beakers += I
			else
				to_chat(user, "<span class='warning'>[I] is empty!</span>")

	else if(stage == EMPTY && istype(I, /obj/item/device/assembly_holder))
		. = 1 // no afterattack
		var/obj/item/device/assembly_holder/A = I
		if(isigniter(A.a_left) == isigniter(A.a_right))	//Check if either part of the assembly has an igniter, but if both parts are igniters, then fuck it
			return
		if(!user.transferItemToLoc(I, src))
			return

		nadeassembly = A
		A.master = src
		assemblyattacher = user.ckey

		stage_change(WIRED)
		to_chat(user, "<span class='notice'>You add [A] to the [initial(name)] assembly.</span>")

	else if(stage == EMPTY && istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			det_time = 50 // In case the cable_coil was removed and readded.
			stage_change(WIRED)
			to_chat(user, "<span class='notice'>You rig the [initial(name)] assembly.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire the assembly!</span>")
			return

	else if(stage == READY && istype(I, /obj/item/wirecutters) && !active)
		stage_change(WIRED)
		to_chat(user, "<span class='notice'>You unlock the [initial(name)] assembly.</span>")

	else if(stage == WIRED && istype(I, /obj/item/wrench))
		if(beakers.len)
			for(var/obj/O in beakers)
				O.loc = get_turf(src)
			beakers = list()
			to_chat(user, "<span class='notice'>You open the [initial(name)] assembly and remove the payload.</span>")
			return // First use of the wrench remove beakers, then use the wrench to remove the activation mechanism.
		if(nadeassembly)
			nadeassembly.loc = get_turf(src)
			nadeassembly.master = null
			nadeassembly = null
		else // If "nadeassembly = null && stage == WIRED", then it most have been cable_coil that was used.
			new /obj/item/stack/cable_coil(get_turf(src),1)
		stage_change(EMPTY)
		to_chat(user, "<span class='notice'>You remove the activation mechanism from the [initial(name)] assembly.</span>")
	else
		return ..()

/obj/item/grenade/chem_grenade/proc/stage_change(N)
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
/obj/item/grenade/chem_grenade/receive_signal()
	prime()


/obj/item/grenade/chem_grenade/Crossed(atom/movable/AM)
	if(nadeassembly)
		nadeassembly.Crossed(AM)

/obj/item/grenade/chem_grenade/on_found(mob/finder)
	if(nadeassembly)
		nadeassembly.on_found(finder)

/obj/item/grenade/chem_grenade/prime()
	if(stage != READY)
		return

	var/list/datum/reagents/reactants = list()
	for(var/obj/item/reagent_containers/glass/G in beakers)
		reactants += G.reagents

	if(!chem_splash(get_turf(src), affected_area, reactants, ignition_temp, threatscale) && !no_splash)
		playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
		if(beakers.len)
			for(var/obj/O in beakers)
				O.loc = get_turf(src)
			beakers = list()
		stage_change(EMPTY)
		return

	if(nadeassembly)
		var/mob/M = get_mob_by_ckey(assemblyattacher)
		var/mob/last = get_mob_by_ckey(nadeassembly.fingerprintslast)
		var/turf/T = get_turf(src)
		var/area/A = get_area(T)
		message_admins("grenade primed by an assembly, attached by [ADMIN_LOOKUPFLW(M)] and last touched by [ADMIN_LOOKUPFLW(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] [ADMIN_JMP(T)]</a>.")
		log_game("grenade primed by an assembly, attached by [key_name(M)] and last touched by [key_name(last)] ([nadeassembly.a_left.name] and [nadeassembly.a_right.name]) at [A.name] [COORD(T)]")

	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A grenade detonated at [DA.name] [COORD(DT)]")

	update_mob()

	qdel(src)

//Large chem grenades accept slime cores and use the appropriately.
/obj/item/grenade/chem_grenade/large
	name = "large grenade"
	desc = "A custom made large grenade. It affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/reagent_containers/glass, /obj/item/reagent_containers/food/condiment,
								/obj/item/reagent_containers/food/drinks)
	origin_tech = "combat=3;engineering=3"
	affected_area = 5
	ignition_temp = 25 // Large grenades are slightly more effective at setting off heat-sensitive mixtures than smaller grenades.
	threatscale = 1.1	// 10% more effective.

/obj/item/grenade/chem_grenade/large/prime()
	if(stage != READY)
		return

	for(var/obj/item/slime_extract/S in beakers)
		if(S.Uses)
			for(var/obj/item/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(S, G.reagents.total_volume)

			//If there is still a core (sometimes it's used up)
			//and there are reagents left, behave normally,
			//otherwise drop it on the ground for timed reactions like gold.

			if(S)
				if(S.reagents && S.reagents.total_volume)
					for(var/obj/item/reagent_containers/glass/G in beakers)
						S.reagents.trans_to(G, S.reagents.total_volume)
				else
					S.forceMove(get_turf(src))
					no_splash = TRUE
	..()

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
/obj/item/grenade/chem_grenade/large/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/slime_extract) && stage == WIRED)
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, "<span class='notice'>You add [I] to the [initial(name)] assembly.</span>")
		beakers += I
	else
		return ..()

/obj/item/grenade/chem_grenade/cryo // Intended for rare cryogenic mixes. Cools the area moderately upon detonation.
	name = "cryo grenade"
	desc = "A custom made cryogenic grenade. It rapidly cools its contents upon detonation."
	icon_state = "cryog"
	affected_area = 2
	ignition_temp = -100

/obj/item/grenade/chem_grenade/pyro // Intended for pyrotechnical mixes. Produces a small fire upon detonation, igniting potentially flammable mixtures.
	name = "pyro grenade"
	desc = "A custom made pyrotechnical grenade. It heats up and ignites its contents upon detonation."
	icon_state = "pyrog"
	origin_tech = "combat=4;engineering=4"
	affected_area = 3
	ignition_temp = 500 // This is enough to expose a hotspot.

/obj/item/grenade/chem_grenade/adv_release // Intended for weaker, but longer lasting effects. Could have some interesting uses.
	name = "advanced release grenade"
	desc = "A custom made advanced release grenade. It is able to be detonated more than once. Can be configured using a multitool."
	icon_state = "timeg"
	origin_tech = "combat=3;engineering=4"
	var/unit_spread = 10 // Amount of units per repeat. Can be altered with a multitool.

/obj/item/grenade/chem_grenade/adv_release/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/multitool))
		switch(unit_spread)
			if(0 to 24)
				unit_spread += 5
			if(25 to 99)
				unit_spread += 25
			else
				unit_spread = 5
		to_chat(user, "<span class='notice'> You set the time release to [unit_spread] units per detonation.</span>")
		return
	..()

/obj/item/grenade/chem_grenade/adv_release/prime()
	if(stage != READY)
		return

	var/total_volume = 0
	for(var/obj/item/reagent_containers/RC in beakers)
		total_volume += RC.reagents.total_volume
	if(!total_volume)
		qdel(src)
		qdel(nadeassembly)
		return
	var/fraction = unit_spread/total_volume
	var/datum/reagents/reactants = new(unit_spread)
	reactants.my_atom = src
	for(var/obj/item/reagent_containers/RC in beakers)
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
		addtimer(CALLBACK(src, .proc/prime), det_time)
	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A grenade detonated at [DA.name] ([DT.x], [DT.y], [DT.z])")





//////////////////////////////
////// PREMADE GRENADES //////
//////////////////////////////

/obj/item/grenade/chem_grenade/metalfoam
	name = "metal foam grenade"
	desc = "Used for emergency sealing of air breaches."
	stage = READY

/obj/item/grenade/chem_grenade/metalfoam/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("aluminium", 30)
	B2.reagents.add_reagent("foaming_agent", 10)
	B2.reagents.add_reagent("facid", 10)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/incendiary
	name = "incendiary grenade"
	desc = "Used for clearing rooms of living things."
	stage = READY

/obj/item/grenade/chem_grenade/incendiary/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("stable_plasma", 25)
	B2.reagents.add_reagent("sacid", 25)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/grenade/chem_grenade/antiweed/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("plantbgone", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

/obj/item/grenade/chem_grenade/cleaner/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("cleaner", 10)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/ez_clean
	name = "cleaner grenade"
	desc = "Waffle Co.-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = READY

/obj/item/grenade/chem_grenade/ez_clean/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 40)
	B2.reagents.add_reagent("water", 40)
	B2.reagents.add_reagent("ez_clean", 60) //ensures a  t h i c c  distribution

	beakers += B1
	beakers += B2



/obj/item/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	stage = READY

/obj/item/grenade/chem_grenade/teargas/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("condensedcapsaicin", 60)
	B1.reagents.add_reagent("potassium", 40)
	B2.reagents.add_reagent("phosphorus", 40)
	B2.reagents.add_reagent("sugar", 40)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/facid
	name = "acid grenade"
	desc = "Used for melting armoured opponents."
	stage = READY

/obj/item/grenade/chem_grenade/facid/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("facid", 290)
	B1.reagents.add_reagent("potassium", 10)
	B2.reagents.add_reagent("phosphorus", 10)
	B2.reagents.add_reagent("sugar", 10)
	B2.reagents.add_reagent("facid", 280)

	beakers += B1
	beakers += B2


/obj/item/grenade/chem_grenade/colorful
	name = "colorful grenade"
	desc = "Used for wide scale painting projects."
	stage = READY

/obj/item/grenade/chem_grenade/colorful/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent("colorful_reagent", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/glitter
	name = "generic glitter grenade"
	desc = "You shouldn't see this description."
	stage = READY
	var/glitter_type = "glitter"

/obj/item/grenade/chem_grenade/glitter/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)

	B1.reagents.add_reagent(glitter_type, 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/glitter/pink
	name = "pink glitter bomb"
	desc = "For that HOT glittery look."
	glitter_type = "pink_glitter"

/obj/item/grenade/chem_grenade/glitter/blue
	name = "blue glitter bomb"
	desc = "For that COOL glittery look."
	glitter_type = "blue_glitter"

/obj/item/grenade/chem_grenade/glitter/white
	name = "white glitter bomb"
	desc = "For that somnolent glittery look."
	glitter_type = "white_glitter"

/obj/item/grenade/chem_grenade/clf3
	name = "clf3 grenade"
	desc = "BURN!-brand foaming clf3. In a special applicator for rapid purging of wide areas."
	stage = READY

/obj/item/grenade/chem_grenade/clf3/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("fluorosurfactant", 250)
	B1.reagents.add_reagent("clf3", 50)
	B2.reagents.add_reagent("water", 250)
	B2.reagents.add_reagent("clf3", 50)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/bioterrorfoam
	name = "Bio terror foam grenade"
	desc = "Tiger Cooperative chemical foam grenade. Causes temporary irration, blindness, confusion, mutism, and mutations to carbon based life forms. Contains additional spore toxin"
	stage = READY

/obj/item/grenade/chem_grenade/bioterrorfoam/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("cryptobiolin", 75)
	B1.reagents.add_reagent("water", 50)
	B1.reagents.add_reagent("mutetoxin", 50)
	B1.reagents.add_reagent("spore", 75)
	B1.reagents.add_reagent("itching_powder", 50)
	B2.reagents.add_reagent("fluorosurfactant", 150)
	B2.reagents.add_reagent("mutagen", 150)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/tuberculosis
 	name = "Fungal tuberculosis grenade"
 	desc = "WARNING: GRENADE WILL RELEASE DEADLY SPORES CONTAINING ACTIVE AGENTS. SEAL SUIT AND AIRFLOW BEFORE USE."
 	stage = READY

/obj/item/grenade/chem_grenade/tuberculosis/Initialize()
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/bluespace/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/bluespace/B2 = new(src)

	B1.reagents.add_reagent("potassium", 50)
	B1.reagents.add_reagent("phosphorus", 50)
	B1.reagents.add_reagent("fungalspores", 200)
	B2.reagents.add_reagent("blood", 250)
	B2.reagents.add_reagent("sugar", 50)

	beakers += B1
	beakers += B2
