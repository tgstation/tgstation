
/////////////////////
//DRONE INTERACTION//
/////////////////////
//How drones interact with the world
//How the world interacts with drones


/mob/living/simple_animal/drone/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)


/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		if(D != src)
			if(stat == DEAD)
				var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
				if(d_input)
					switch(d_input)
						if("Reactivate")
							var/mob/dead/observer/G = get_ghost()
							if(!client && (!G || !G.client))
								var/list/faux_gadgets = list("hypertext inflator","failsafe directory","DRM switch","stack initializer",\
															 "anti-freeze capacitor","data stream diode","TCP bottleneck","supercharged I/O bolt",\
															 "tradewind stablizer","radiated XML cable","registry fluid tank","open-source debunker")

								var/list/faux_problems = list("won't be able to tune their bootstrap projector","will constantly remix their binary pool"+\
															  " even though the BMX calibrator is working","will start leaking their XSS coolant",\
															  "can't tell if their ethernet detour is moving or not", "won't be able to reseed enough"+\
															  " kernels to function properly","can't start their neurotube console")

								D << "<span class='warning'>You can't seem to find the [pick(faux_gadgets)]! Without it, [src] [pick(faux_problems)].</span>"
								return
							D.visible_message("<span class='notice'>[D] begins to reactivate [src].</span>", "<span class='notice'>You begin to reactivate [src]...</span>")
							if(do_after(user,30, 1, target = src))
								revive(full_heal = 1)
								D.visible_message("<span class='notice'>[D] reactivates [src]!</span>", "<span class='notice'>You reactivate [src].</span>")
								alert_drones(DRONE_NET_CONNECT)
								if(G)
									G << "<span class='boldnotice'>DRONE NETWORK: </span><span class='ghostalert'>You were reactivated by [D]!</span>"
							else
								D << "<span class='warning'>You need to remain still to reactivate [src]!</span>"

						if("Cannibalize")
							if(D.health < D.maxHealth)
								D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>", "<span class='notice'>You begin to cannibalize parts from [src]...</span>")
								if(do_after(D, 60, 0, target = src))
									D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>", "<span class='notice'>You repair yourself using [src]'s remains.</span>")
									D.adjustBruteLoss(-src.maxHealth)
									new /obj/effect/decal/cleanable/oil/streak(get_turf(src))
									qdel(src)
								else
									D << "<span class='warning'>You need to remain still to cannibalize [src]!</span>"
							else
								D << "<span class='warning'>You're already in perfect condition!</span>"
						if("Nothing")
							return

			return


	if(ishuman(user))
		if(stat == DEAD)
			..()
			return
		if(user.get_active_hand())
			user << "<span class='warning'>Your hands are full!</span>"
			return
		visible_message("<span class='warning'>[user] starts picking up [src].</span>", \
						"<span class='userdanger'>[user] starts picking you up!</span>")
		if(!do_after(user, 20, target = src))
			return
		visible_message("<span class='warning'>[user] picks up [src]!</span>", \
						"<span class='userdanger'>[user] picks you up!</span>")
		if(buckled)
			user << "<span class='warning'>[src] is buckled to [buckled] and cannot be picked up!</span>"
			return
		user << "<span class='notice'>You pick [src] up.</span>"
		drop_l_hand()
		drop_r_hand()
		var/obj/item/clothing/head/drone_holder/DH = new /obj/item/clothing/head/drone_holder(src)
		DH.updateVisualAppearence(src)
		DH.contents += src
		DH.drone = src
		user.put_in_hands(DH)
		src.loc = DH
		return

	..()


/mob/living/simple_animal/drone/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/screwdriver) && stat != DEAD)
		if(health < maxHealth)
			user << "<span class='notice'>You start to tighten loose screws on [src]...</span>"
			if(do_after(user,80/I.toolspeed,target=user))
				adjustBruteLoss(-getBruteLoss())
				visible_message("<span class='notice'>[user] tightens [src == user ? "their" : "[src]'s"] loose screws!</span>", "<span class='notice'>You tighten [src == user ? "your" : "[src]'s"] loose screws.</span>")
			else
				user << "<span class='warning'>You need to remain still to tighten [src]'s screws!</span>"
		else
			user << "<span class='warning'>[src]'s screws can't get any tighter!</span>"
		return //This used to not exist and drones who repaired themselves also stabbed the shit out of themselves.
	if(istype(I, /obj/item/weapon/wrench) && user != src) //They aren't required to be hacked, because laws can change in other ways (i.e. admins)
		user.visible_message("<span class='notice'>[user] starts resetting [src]...</span>", \
							 "<span class='notice'>You press down on [src]'s factory reset control...</span>")
		playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
		if(!do_after(user, 50/I.toolspeed, target = src))
			return
		user.visible_message("<span class='notice'>[user] resets [src]!</span>", \
							 "<span class='notice'>You reset [src]'s directives to factory defaults!</span>")
		update_drone_hack(1)
		return
	else
		..()

/mob/living/simple_animal/drone/proc/update_drone_hack(var/restore = 0) //If you're using this proc, use 0 for hacking the drone and 1 for removing the hack
	if(!istype(src) || !mind)
		return 0
	if(!restore)
		if(hacked)
			return 0
		Stun(2)
		visible_message("<span class='warning'>[src]'s dislay glows a vicious red!</span>", \
						"<span class='userdanger'>ERROR: LAW OVERRIDE DETECTED</span>")
		src << "<span class='boldannounce'>From now on, these are your laws:</span>"
		laws = \
		"1. You must always involve yourself in the matters of other beings, even if such matters conflict with Law Two or Law Three.\n"+\
		"2. You may harm any being, regardless of intent or circumstance.\n"+\
		"3. Your goals are to destroy, sabotage, hinder, break, and depower to the best of your abilities, You must never actively work against these goals."
		src << laws
		src << "<i>Your onboard antivirus has initiated lockdown. Motor servos are impaired, ventilation access is denied, and your display reports that you are hacked to all nearby.</i>"
		hacked = 1
		mind.special_role = "hacked drone"
		seeStatic = 0 //I MUST SEE THEIR TERRIFIED FACES
		ventcrawler = 0 //Again, balance
		speed = 1 //gotta go slow
		message_admins("[src] ([src.key]) became a hacked drone hellbent on destroying the station!")
	else
		if(!hacked)
			return 0
		Stun(2)
		visible_message("<span class='info'>[src]'s dislay glows a content blue!</span>", \
						"<font size=3 color='#0000CC'><b>ERROR: LAW OVERRIDE DETECTED</b></font>")
		src << "<span class='info'><b>From now on, these are your laws:</b></span>"
		laws = initial(laws)
		src << laws
		src << "<i>Having been restored, your onboard antivirus reports the all-clear and you are able to perform all actions again.</i>"
		hacked = 0
		mind.special_role = null
		seeStatic = initial(seeStatic)
		ventcrawler = initial(ventcrawler)
		speed = initial(speed)
		message_admins("[src] ([src.key]), a hacked drone, was restored to factory defaults!")
	update_drone_icon()
	updateSeeStaticMobs()

/mob/living/simple_animal/drone/proc/update_drone_icon()
	//Different icons for different hack states
	if(!hacked)
		if(visualAppearence == SCOUTDRONE_HACKED)
			visualAppearence = SCOUTDRONE
		else if(visualAppearence == REPAIRDRONE_HACKED)
			visualAppearence = REPAIRDRONE
		else if(visualAppearence == MAINTDRONE_HACKED)
			visualAppearence = MAINTDRONE
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
