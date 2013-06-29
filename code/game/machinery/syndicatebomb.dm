/obj/machinery/syndicatebomb
	icon = 'icons/obj/assemblies.dmi'
	name = "Syndicate Bomb"
	icon_state = "syndicate-bomb-inactive"
	desc = "A large and menacing device. Can be bolted down with a wrench."

	anchored = 0
	density = 0
	layer = MOB_LAYER - 0.1 //so people can't hide it and it's REALLY OBVIOUS
	unacidable = 1

	var/datum/wires/syndicatebomb/wires = null
	var/timer = 60
	var/open_panel = 0 	//are the wires exposed?
	var/active = 0		//is the bomb counting down?
	var/defused = 0		//is the bomb capable of exploding?

/obj/machinery/syndicatebomb/process()
	if(active && !defused && (timer > 0)) 	//Tick Tock
		playsound(loc, 'sound/items/timer.ogg', 5, 0)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		processing_objects.Remove(src)
		explosion(src.loc,2,5,11)
		del(src)
		return
	if(!active || defused)					//Counter terrorists win
		processing_objects.Remove(src)
		return

/obj/machinery/syndicatebomb/New()
	wires = new(src)
	..()


/obj/machinery/syndicatebomb/examine()
	..()
	usr << "A digital display on it reads \"[timer]\"."


/obj/machinery/syndicatebomb/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/wrench))
		if(!anchored)
			if(!isturf(src.loc) || istype(src.loc, /turf/space))
				user << "<span class='notice'>The bomb must be placed on solid ground to attach it</span>"
			else
				user << "<span class='notice'>You firmly wrench the bomb to the floor</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 1
				if(active)
					user << "<span class='notice'>The bolts lock in place</span>"
		else
			if(!active)
				user << "<span class='notice'>You wrench the bomb from the floor</span>"
				playsound(loc, 'sound/items/ratchet.ogg', 50, 1)
				anchored = 0
			else
				user << "<span class='warning'>The bolts are locked down!</span>"

	else if(istype(I, /obj/item/weapon/screwdriver))
		open_panel = !open_panel
		if(!active)
			icon_state = "syndicate-bomb-inactive[open_panel ? "-wires" : ""]"
		else
			icon_state = "syndicate-bomb-active[open_panel ? "-wires" : ""]"
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"

	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		if(open_panel)
			wires.Interact(user)

	else
		..()

/obj/machinery/syndicatebomb/attack_hand(var/mob/user)
	if(anchored)
		if(open_panel)
			wires.Interact(user)
		else if(!active)
			settings()
		else
			user << "<span class='notice'>The bomb is bolted to the floor!</span>"
	else if(!active)
		settings()

/obj/machinery/syndicatebomb/proc/settings(var/mob/user)
	var/newtime = input(usr, "Please set the timer.", "Timer", "[timer]") as num
	newtime = Clamp(newtime, 30, 60000)
	if(in_range(src, usr) && isliving(usr)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("\blue \icon[src] timer set for [timer] seconds.")
	if(alert(usr,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, usr) && isliving(usr))
		if(defused || active)
			if(defused)
				src.loc.visible_message("\blue \icon[src] Device error: User intervention required")
			return
		else
			src.loc.visible_message("\red \icon[src] [timer] seconds until detonation, please clear the area.")
			playsound(loc, 'sound/machines/click.ogg', 30, 1)
			icon_state = "syndicate-bomb-active"
			active = 1
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			var/log_str = "[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>."
			bombers += log_str
			message_admins(log_str)
			log_game(log_str)
			processing_objects.Add(src) //Ticking down