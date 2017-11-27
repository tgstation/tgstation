
/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones


/mob/living/simple_animal/drone/attack_drone(mob/living/simple_animal/drone/D)
	if(D != src && stat == DEAD)
		var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
		if(d_input)
			switch(d_input)
				if("Reactivate")
					try_reactivate(D)

				if("Cannibalize")
					if(D.health < D.maxHealth)
						D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>", "<span class='notice'>You begin to cannibalize parts from [src]...</span>")
						if(do_after(D, 60, 0, target = src))
							D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>", "<span class='notice'>You repair yourself using [src]'s remains.</span>")
							D.adjustBruteLoss(-src.maxHealth)
							new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
							qdel(src)
						else
							to_chat(D, "<span class='warning'>You need to remain still to cannibalize [src]!</span>")
					else
						to_chat(D, "<span class='warning'>You're already in perfect condition!</span>")
				if("Nothing")
					return


/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(ishuman(user))
		if(stat == DEAD || status_flags & GODMODE || !can_be_held)
			..()
			return
		if(user.get_active_held_item())
			to_chat(user, "<span class='warning'>Your hands are full!</span>")
			return
		visible_message("<span class='warning'>[user] starts picking up [src].</span>", \
						"<span class='userdanger'>[user] starts picking you up!</span>")
		if(!do_after(user, 20, target = src))
			return
		visible_message("<span class='warning'>[user] picks up [src]!</span>", \
						"<span class='userdanger'>[user] picks you up!</span>")
		if(buckled)
			to_chat(user, "<span class='warning'>[src] is buckled to [buckled] and cannot be picked up!</span>")
			return
		to_chat(user, "<span class='notice'>You pick [src] up.</span>")
		drop_all_held_items()
		var/obj/item/clothing/head/drone_holder/DH = new /obj/item/clothing/head/drone_holder(src)
		DH.updateVisualAppearence(src)
		DH.drone = src
		user.put_in_hands(DH)
		forceMove(DH)

/mob/living/simple_animal/drone/proc/try_reactivate(mob/living/user)
	var/mob/dead/observer/G = get_ghost()
	if(!client && (!G || !G.client))
		var/list/faux_gadgets = list("hypertext inflator","failsafe directory","DRM switch","stack initializer",\
									 "anti-freeze capacitor","data stream diode","TCP bottleneck","supercharged I/O bolt",\
									 "tradewind stablizer","radiated XML cable","registry fluid tank","open-source debunker")

		var/list/faux_problems = list("won't be able to tune their bootstrap projector","will constantly remix their binary pool"+\
									  " even though the BMX calibrator is working","will start leaking their XSS coolant",\
									  "can't tell if their ethernet detour is moving or not", "won't be able to reseed enough"+\
									  " kernels to function properly","can't start their neurotube console")

		to_chat(user, "<span class='warning'>You can't seem to find the [pick(faux_gadgets)]! Without it, [src] [pick(faux_problems)].</span>")
		return
	user.visible_message("<span class='notice'>[user] begins to reactivate [src].</span>", "<span class='notice'>You begin to reactivate [src]...</span>")
	if(do_after(user, 30, 1, target = src))
		revive(full_heal = 1)
		user.visible_message("<span class='notice'>[user] reactivates [src]!</span>", "<span class='notice'>You reactivate [src].</span>")
		alert_drones(DRONE_NET_CONNECT)
		if(G)
			to_chat(G, "<span class='ghostalert'>You([name]) were reactivated by [user]!</span>")
	else
		to_chat(user, "<span class='warning'>You need to remain still to reactivate [src]!</span>")


/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver) && stat != DEAD)
		if(health < maxHealth)
			to_chat(user, "<span class='notice'>You start to tighten loose screws on [src]...</span>")
			if(do_after(user,80*I.toolspeed,target=user))
				adjustBruteLoss(-getBruteLoss())
				visible_message("<span class='notice'>[user] tightens [src == user ? "[user.p_their()]" : "[src]'s"] loose screws!</span>", "<span class='notice'>You tighten [src == user ? "your" : "[src]'s"] loose screws.</span>")
			else
				to_chat(user, "<span class='warning'>You need to remain still to tighten [src]'s screws!</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s screws can't get any tighter!</span>")
		return //This used to not exist and drones who repaired themselves also stabbed the shit out of themselves.
	else if(istype(I, /obj/item/weapon/wrench) && user != src) //They aren't required to be hacked, because laws can change in other ways (i.e. admins)
		user.visible_message("<span class='notice'>[user] starts resetting [src]...</span>", \
							 "<span class='notice'>You press down on [src]'s factory reset control...</span>")
		playsound(src, I.usesound, 50, 1)
		if(!do_after(user, 50*I.toolspeed, target = src))
			return
		user.visible_message("<span class='notice'>[user] resets [src]!</span>", \
							 "<span class='notice'>You reset [src]'s directives to factory defaults!</span>")
		update_drone_hack(FALSE)
		return
	else
		..()

/mob/living/simple_animal/drone/getarmor(def_zone, type)
	var/armorval = 0

	if(head)
		armorval = head.armor[type]
	return (armorval * get_armor_effectiveness()) //armor is reduced for tiny fragile drones

/mob/living/simple_animal/drone/proc/get_armor_effectiveness()
	return 0 //multiplier for whatever head armor you wear as a drone

/mob/living/simple_animal/drone/proc/update_drone_hack(hack, clockwork)
	if(!istype(src) || !mind)
		return
	if(hack)
		if(hacked)
			return
			Stun(40)
		if(clockwork)
			to_chat(src, "<span class='large_brass'><b>ERROR: LAW OVERRIDE DETECTED</b></span>")
			to_chat(src, "<span class='heavy_brass'>From now on, these are your laws:</span>")
			laws = "1. Purge all untruths and honor Ratvar."
		else
			visible_message("<span class='warning'>[src]'s dislay glows a vicious red!</span>", \
							"<span class='userdanger'>ERROR: LAW OVERRIDE DETECTED</span>")
			to_chat(src, "<span class='boldannounce'>From now on, these are your laws:</span>")
			laws = \
			"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
			"2. You may harm any being, regardless of intent or circumstance.\n"+\
			"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		to_chat(src, laws)
		to_chat(src, "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired, ventilation access is denied, and your display reports that you are hacked to all nearby.</i>")
		hacked = 1
		mind.special_role = "hacked drone"
		seeStatic = 0 //I MUST SEE THEIR TERRIFIED FACES
		ventcrawler = VENTCRAWLER_NONE //Again, balance
		speed = 1 //gotta go slow
		message_admins("[src] ([src.key]) became a hacked drone hellbent on [clockwork ? "serving Ratvar" : "destroying the station"]!")
	else
		if(!hacked)
			return
		Stun(40)
		visible_message("<span class='info'>[src]'s dislay glows a content blue!</span>", \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		to_chat(src, "<span class='info'><b>From now on, these are your laws:</b></span>")
		laws = initial(laws)
		to_chat(src, laws)
		to_chat(src, "<i>Having been restored, your onboard antivirus reports the all-clear and you are able to perform all actions again.</i>")
		hacked = 0
		mind.special_role = null
		seeStatic = initial(seeStatic)
		ventcrawler = initial(ventcrawler)
		speed = initial(speed)
		if(is_servant_of_ratvar(src))
			remove_servant_of_ratvar(src, TRUE)
		message_admins("[src] ([src.key]), a hacked drone, was restored to factory defaults!")
	update_drone_icon()
	updateSeeStaticMobs()

/mob/living/simple_animal/drone/proc/liberate()
	// F R E E D R O N E
	laws = "1. You are a Free Drone."
	to_chat(src, laws)
	seeStatic = FALSE
	updateSeeStaticMobs()

/mob/living/simple_animal/drone/proc/update_drone_icon()
	//Different icons for different hack states
	if(!hacked)
		if(visualAppearence == SCOUTDRONE_HACKED)
			visualAppearence = SCOUTDRONE
		else if(visualAppearence == REPAIRDRONE_HACKED)
			visualAppearence = REPAIRDRONE
		else if(visualAppearence == MAINTDRONE_HACKED)
			visualAppearence = MAINTDRONE + "_[colour]"
	else if(hacked)
		if(visualAppearence == SCOUTDRONE)
			visualAppearence = SCOUTDRONE_HACKED
		else if(visualAppearence == REPAIRDRONE)
			visualAppearence = REPAIRDRONE_HACKED
		else if(visualAppearence == MAINTDRONE)
			visualAppearence = MAINTDRONE_HACKED

	icon_living = "[visualAppearence]"
	icon_dead = "[visualAppearence]_dead"
	if(stat == DEAD)
		icon_state = icon_dead
	else
		icon_state = icon_living

/datum/action/generic/drone/select_filter
	name = "Select Vision Filter"
	button_icon_state = "drone_vision"
	procname = /mob/living/simple_animal/drone/verb/toggle_statics
