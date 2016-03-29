#define EMPTY 1
#define WIRED 2
#define READY 3
#define MAXIMUM_PAYLOAD 4 // Maximum number of beakers that can be fitted inside the bomb.

/obj/machinery/chembomb
	icon = 'icons/obj/assemblies.dmi'
	name = "Chemical Bomb"
	icon_state = "chem-bomb"
	desc = "A large and menacing device. Can be bolted down permanently with a wrench to prevent tampering."

	anchored = 0
	density = 0
	layer = MOB_LAYER - 0.2 //so people can't hide it and it's REALLY OBVIOUS
	unacidable = 1

	var/timer = 60
	var/open_panel = 1 	//are the wires exposed?
	var/stage = EMPTY
	var/active = FALSE		//is the bomb counting down?
	var/defused = FALSE		//is the bomb capable of exploding?
	var/list/beakers = list()
	var/beepsound = 'sound/items/timer.ogg'

/obj/machinery/chembomb/process()
	if(active && !defused && (timer > 0)) 	//Tick Tock
		var/volume = (timer <= 10 ? 40 : 10) // Tick louder when the bomb is closer to being detonated.
		playsound(loc, beepsound, volume, 0)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		update_icon()
		if(stage == READY)
			prime()
		return
	if(!active || defused)					//Counter terrorists win
		if(defused && stage == READY)
			for (var/obj/item/I in beakers)
				I.loc = loc
				beakers -= I
			stage = EMPTY
		return

/obj/machinery/chembomb/New()
	create_reagents(500*MAXIMUM_PAYLOAD)
	wires 	= new /datum/wires/chembomb(src)
	update_icon()
	..()

/obj/machinery/chembomb/Destroy()
	qdel(wires)
	for(var/obj/item/I in beakers)
		beakers -= I
		qdel(I)
	wires = null
	beakers = null
	return ..()

/obj/machinery/chembomb/examine(mob/user)
	..()
	if(open_panel)
		switch(stage)
			if (EMPTY)
				user << "It looks completely disabled."
			if (WIRED)
				user << "There are no containers inside."
			if (READY)
				user << "There are \"[beakers.len]\" containers inside."
	user << "A digital display on it reads \"[timer]\"."

/obj/machinery/chembomb/update_icon()
	icon_state = "[initial(icon_state)][active ? "-active" : "-inactive"][open_panel ? "-wires" : ""]"

/obj/machinery/chembomb/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/wrench))
		if(!anchored)
			if(!isturf(src.loc) || istype(src.loc, /turf/space))
				user << "<span class='notice'>The bomb must be placed on solid ground to attach it.</span>"
			else
				user << "<span class='notice'>You firmly wrench the bomb to the floor.</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 1
				if(active)
					user << "<span class='notice'>The bolts lock in place.</span>"
		else
			if(!active)
				user << "<span class='notice'>You wrench the bomb from the floor.</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 0
			else
				user << "<span class='warning'>The bolts are locked down!</span>"

	else if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		update_icon()
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"

	else if(is_wire_tool(I) && open_panel)
		wires.interact(user)

	else if(istype(I, /obj/item/weapon/crowbar))
		if(!open_panel)
			user << "<span class='warning'>The cover is screwed on, it won't pry off!</span>"
	else if(istype(I, /obj/item/weapon/reagent_containers/glass/beaker) && stage != EMPTY && open_panel)
		if(beakers.len < MAXIMUM_PAYLOAD)
			if(!user.drop_item())
				return
			beakers += I
			user << "<span class='notice'>You place [I] into [src].</span>"
			I.loc = src
			if(stage == WIRED)
				stage = READY
		else
			user << "<span class='warning'>The [I] won't fit in the [src]!</span>"
	else if(stage == EMPTY && istype(I, /obj/item/stack/cable_coil) && open_panel)
		var/obj/item/stack/cable_coil/C = I
		if (C.use(1))
			stage = WIRED
			user << "<span class='notice'>You rig the [src].</span>"
		else
			user << "<span class='warning'>You need one length of coil to wire the explosive!</span>"
			return
	else
		..()

/obj/machinery/chembomb/attack_hand(mob/user)
	if(stage == READY && beakers.len && open_panel && !active)
		for (var/obj/item/I in beakers)
			I.loc = loc
			beakers -= I
		beakers = null
		stage = WIRED
		return
	interact(user)

/obj/machinery/chembomb/attack_ai()
	return

/obj/machinery/chembomb/interact(mob/user)
	wires.interact(user)
	if(!open_panel)
		if(!active && stage == READY)
			settings(user)
			return
		else if(anchored)
			user << "<span class='warning'>The bomb is bolted to the floor!</span>"
			return
		else if(stage != READY)
			user << "<span class='notice'>The bomb can't be activated without a payload.</span>"

/obj/machinery/chembomb/proc/settings(mob/user)
	var/newtime = input(user, "Please set the timer.", "Timer", "[timer]") as num
	newtime = Clamp(newtime, 60, 60000)
	if(in_range(src, user) && isliving(user)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("<span class='notice'>\icon[src] timer set for [timer] seconds.</span>")
	if(alert(user,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, user) && isliving(user))
		if(defused || active)
			if(defused)
				src.loc.visible_message("<span class='warning'>\icon[src] Device error: User intervention required.</span>")
			return
		else
			src.loc.visible_message("<span class='danger'>\icon[src] [timer] seconds until detonation, please clear the area.</span>")
			playsound(loc, 'sound/machines/click.ogg', 30, 1)
			active = 1
			update_icon()
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			var/has_reagents
			for(var/obj/item/I in beakers)
				if(I.reagents.total_volume)
					has_reagents = 1
			if(has_reagents)
				message_admins("[key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) has primed a [name] (CHEMBOMB) for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
				log_game("[key_name(user)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")

/obj/machinery/chembomb/proc/prime()
	if(stage != READY || !reagents)
		#ifdef DEBUG
		world << "Chembomb Reagents Issue!"
		#endif
		return

	var/has_reagents
	for(var/obj/item/I in beakers)
		if(I.reagents.total_volume)
			has_reagents = 1

	if(!has_reagents)
		playsound(loc, 'sound/items/Screwdriver2.ogg', 50, 1)
		return

	playsound(loc, 'sound/effects/bamf.ogg', 75, 1)

	var/turf/DT = get_turf(src)
	var/area/DA = get_area(DT)
	log_game("A chembomb detonated at [DA.name] ([DT.x], [DT.y], [DT.z])")

	mix_reagents()

	if(reagents.total_volume)	//The possible reactions didnt use up all reagents, so we spread it around.
		var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		var/list/viewable = view(7, loc)
		var/list/accessible = can_flood_from(loc, 7)
		var/list/reactable = accessible
		var/mycontents = GetAllContents()
		for(var/turf/T in accessible)
			for(var/atom/A in T.GetAllContents())
				if(A in mycontents) continue
				if(!(A in viewable)) continue
				reactable |= A
		if(!reactable.len) //Nothing to react with. Probably means we're in nullspace.
			qdel(src)
			return
		var/fraction = 1/reactable.len
		for(var/atom/A in reactable)
			reagents.reaction(A, TOUCH, fraction)

	qdel(src)

/obj/machinery/chembomb/proc/mix_reagents()
	var/total_temp
	for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
		G.reagents.trans_to(src, G.reagents.total_volume)
		total_temp += G.reagents.chem_temp
	reagents.chem_temp = total_temp

/obj/machinery/chembomb/proc/can_flood_from(myloc, maxrange)
	var/turf/myturf = get_turf(myloc)
	var/list/reachable = list(myloc)
	for(var/i=1; i<=maxrange; i++)
		var/list/turflist = list()
		for(var/turf/T in (orange(i, myloc) - orange(i-1, myloc)))
			turflist |= T
		for(var/turf/T in turflist)
			if( !(get_dir(T,myloc) in cardinal) && (abs(T.x - myturf.x) == abs(T.y - myturf.y) ))
				turflist.Remove(T)
				turflist.Add(T) // we move the purely diagonal turfs to the end of the list.
		for(var/turf/T in turflist)
			if(T in reachable) continue
			for(var/turf/NT in orange(1, T))
				if(!(NT in reachable)) continue
				if(!(get_dir(T,NT) in cardinal)) continue
				if(!NT.CanAtmosPass(T)) continue
				reachable |= T
				break
	return reachable

#undef EMPTY
#undef WIRED
#undef READY
#undef MAXIMUM_PAYLOAD
