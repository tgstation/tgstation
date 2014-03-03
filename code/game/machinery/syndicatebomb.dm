/obj/machinery/syndicatebomb
	icon = 'icons/obj/assemblies.dmi'
	name = "syndicate bomb"
	icon_state = "syndicate-bomb"
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
	var/obj/item/weapon/bombcore/payload = /obj/item/weapon/bombcore/
	var/beepsound = 'sound/items/timer.ogg'

/obj/machinery/syndicatebomb/process()
	if(active && !defused && (timer > 0)) 	//Tick Tock
		var/volume = (timer <= 10 ? 30 : 5) // Tick louder when the bomb is closer to being detonated.
		playsound(loc, beepsound, volume, 0)
		timer--
	if(active && !defused && (timer <= 0))	//Boom
		active = 0
		timer = 60
		update_icon()
		if(payload in src)
			payload.detonate()
		return
	if(!active || defused)					//Counter terrorists win
		if(defused && payload in src)
			payload.defuse()
		return

/obj/machinery/syndicatebomb/New()
	wires 	= new(src)
	payload = new payload(src)
	update_icon()
	..()


/obj/machinery/syndicatebomb/examine()
	..()
	usr << "A digital display on it reads \"[timer]\"."

/obj/machinery/syndicatebomb/update_icon()
	icon_state = "[initial(icon_state)][active ? "-active" : "-inactive"][open_panel ? "-wires" : ""]"

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
		update_icon()
		user << "<span class='notice'>You [open_panel ? "open" : "close"] the wire panel.</span>"

	else if(istype(I, /obj/item/weapon/wirecutters) || istype(I, /obj/item/device/multitool) || istype(I, /obj/item/device/assembly/signaler ))
		if(open_panel)
			wires.Interact(user)

	else if(istype(I, /obj/item/weapon/crowbar))
		if(open_panel && isWireCut(WIRE_BOOM) && isWireCut(WIRE_UNBOLT) && isWireCut(WIRE_DELAY) && isWireCut(WIRE_PROCEED) && isWireCut(WIRE_ACTIVATE))
			if(payload)
				user << "<span class='notice'>You carefully pry out [payload].</span>"
				payload.loc = user.loc
				payload = null
			else
				user << "<span class='notice'>There isn't anything in here to remove!</span>"
		else if (open_panel)
			user << "<span class='notice'>The wires conneting the shell to the explosives are holding it down!</span>"
		else
			user << "<span class='notice'>The cover is screwed on, it won't pry off!</span>"
	else if(istype(I, /obj/item/weapon/bombcore))
		if(!payload)
			payload = I
			user << "<span class='notice'>You place [payload] into [src].</span>"
			user.drop_item()
			payload.loc = src
		else
			user << "<span class='notice'>[payload] is already loaded into [src], you'll have to remove it first.</span>"
	else
		..()

/obj/machinery/syndicatebomb/attack_hand(var/mob/user)
	interact(user)

/obj/machinery/syndicatebomb/attack_ai()
	return

/obj/machinery/syndicatebomb/interact(var/mob/user)
	if(wires)
		wires.Interact(user)
	if(!open_panel)
		if(!active)
			settings(user)
			return
		else if(anchored)
			user << "<span class='notice'>The bomb is bolted to the floor!</span>"
			return

/obj/machinery/syndicatebomb/proc/settings(var/mob/user)
	var/newtime = input(user, "Please set the timer.", "Timer", "[timer]") as num
	newtime = Clamp(newtime, 60, 60000)
	if(in_range(src, user) && isliving(user)) //No running off and setting bombs from across the station
		timer = newtime
		src.loc.visible_message("\blue \icon[src] timer set for [timer] seconds.")
	if(alert(user,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, user) && isliving(user))
		if(defused || active)
			if(defused)
				src.loc.visible_message("\blue \icon[src] Device error: User intervention required")
			return
		else
			src.loc.visible_message("\red \icon[src] [timer] seconds until detonation, please clear the area.")
			playsound(loc, 'sound/machines/click.ogg', 30, 1)
			active = 1
			update_icon()
			add_fingerprint(user)

			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)
			if(payload && !istype(payload, /obj/item/weapon/bombcore/training))
				message_admins("[key_name(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> has primed a [name] ([payload]) for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
				log_game("[key_name(user)] has primed a [name] ([payload]) for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
				payload.adminlog = "The [src.name] that [key_name(user)] had primed detonated!"

/obj/machinery/syndicatebomb/proc/isWireCut(var/index)
	return wires.IsIndexCut(index)

///Bomb Subtypes///

/obj/machinery/syndicatebomb/training
	name = "training bomb"
	icon_state = "training-bomb"
	desc = "A salvaged syndicate device gutted of its explosives to be used as a training aid for aspiring bomb defusers."
	payload = /obj/item/weapon/bombcore/training/

/obj/machinery/syndicatebomb/badmin
	name = "generic summoning badmin bomb"
	desc = "Oh god what is in this thing?"
	payload = /obj/item/weapon/bombcore/badmin/summon/

/obj/machinery/syndicatebomb/badmin/clown
	name = "clown bomb"
	icon_state = "clown-bomb"
	desc = "HONK."
	payload = /obj/item/weapon/bombcore/badmin/summon/clown
	beepsound = 'sound/items/bikehorn.ogg'

/obj/machinery/syndicatebomb/badmin/varplosion
	payload = /obj/item/weapon/bombcore/badmin/explosion/

///Bomb Cores///

/obj/item/weapon/bombcore
	name = "bomb payload"
	desc = "A powerful secondary explosive of syndicate design and unknown composition, it should be stable under normal conditions..."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bombcore"
	item_state = "eshield0"
	w_class = 3.0
	origin_tech = "syndicate=6;combat=5"
	var/adminlog = null

/obj/item/weapon/bombcore/ex_act(severity) //Little boom can chain a big boom
	src.detonate()

/obj/item/weapon/bombcore/proc/detonate()
	if(adminlog)
		message_admins(adminlog)
		log_game(adminlog)
	explosion(get_turf(src),2,5,11, flame_range = 11)
	qdel(src)

/obj/item/weapon/bombcore/proc/defuse()
//Note: 	Because of how var/defused is used you shouldn't override this UNLESS you intend to set the var to 0 or
//			otherwise remove the core/reset the wires before the end of defuse(). It will repeatedly be called otherwise.

///Bomb Core Subtypes///

/obj/item/weapon/bombcore/training
	name = "dummy payload"
	desc = "A nanotrasen replica of a syndicate payload. Its not intended to explode but to announce that it WOULD have exploded, then rewire itself to allow for more training."
	origin_tech = null
	var/defusals = 0
	var/attempts = 0

/obj/item/weapon/bombcore/training/proc/reset()
	var/obj/machinery/syndicatebomb/holder = src.loc
	if(istype(holder))
		holder.open_panel = 0
		if(holder.wires)
			holder.wires.Shuffle()
		holder.defused = 0
		holder.update_icon()
		holder.updateDialog()

/obj/item/weapon/bombcore/training/detonate()
	var/obj/machinery/syndicatebomb/holder = src.loc
	if(istype(holder))
		attempts++
		holder.loc.visible_message("\red \icon[holder] Alert: Bomb has detonated. Your score is now [defusals] for [attempts]. Resetting wires...")
		reset()
	else
		qdel(src)

/obj/item/weapon/bombcore/training/defuse()
	var/obj/machinery/syndicatebomb/holder = src.loc
	if(istype(holder))
		attempts++
		defusals++
		holder.loc.visible_message("\blue \icon[holder] Alert: Bomb has been defused. Your score is now [defusals] for [attempts]! Resetting wires...")
		reset()

/obj/item/weapon/bombcore/badmin
	name = "badmin payload"
	desc = "If you're seeing this someone has either made a mistake or gotten dangerously savvy with var editing!"
	origin_tech = null

/obj/item/weapon/bombcore/badmin/defuse() //because we wouldn't want them being harvested by players
	var/obj/machinery/syndicatebomb/B = src.loc
	qdel(B)
	qdel(src)

/obj/item/weapon/bombcore/badmin/summon/
	var/summon_path = /obj/item/weapon/reagent_containers/food/snacks/cookie
	var/amt_summon = 1

/obj/item/weapon/bombcore/badmin/summon/detonate()
	var/obj/machinery/syndicatebomb/B = src.loc
	for(var/i = 0; i < amt_summon; i++)
		var/atom/movable/X = new summon_path
		X.loc = get_turf(src)
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(X, pick(NORTH,SOUTH,EAST,WEST))
	qdel(B)
	qdel(src)

/obj/item/weapon/bombcore/badmin/summon/clown
	summon_path = /mob/living/simple_animal/hostile/retaliate/clown
	amt_summon 	= 100

/obj/item/weapon/bombcore/badmin/summon/clown/defuse()
	playsound(src.loc, 'sound/misc/sadtrombone.ogg', 50)
	..()

/obj/item/weapon/bombcore/badmin/explosion/
	var/HeavyExplosion = 2
	var/MediumExplosion = 5
	var/LightExplosion = 11
	var/Flames = 11

/obj/item/weapon/bombcore/badmin/explosion/detonate()
	explosion(get_turf(src),HeavyExplosion,MediumExplosion,LightExplosion, flame_range = Flames)

///Syndicate Detonator (aka the big red button)///

/obj/item/device/syndicatedetonator
	name = "big red button"
	desc = "Nothing good can come of pressing a button this garish..."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = 1.0
	origin_tech = "syndicate=2"
	var/cooldown = 0
	var/detonated =	0
	var/existant =	0

/obj/item/device/syndicatedetonator/attack_self(mob/user as mob)
	if(!cooldown)
		for(var/obj/machinery/syndicatebomb/B in machines)
			if(B.active)
				B.timer = 0
				detonated++
			existant++
		playsound(user, 'sound/machines/click.ogg', 20, 1)
		user << "<span class='notice'>[existant] found, [detonated] triggered.</span>"
		if(detonated)
			var/turf/T = get_turf(src)
			var/area/A = get_area(T)
			detonated--
			var/log_str = "[key_name(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>[A.name] (JMP)</a>."
			bombers += log_str
			message_admins(log_str)
			log_game("[key_name(user)] has remotely detonated [detonated ? "syndicate bombs" : "a syndicate bomb"] using a [name] at [A.name]([T.x],[T.y],[T.z])")
		detonated =	0
		existant =	0
		cooldown = 1
		spawn(30) cooldown = 0



