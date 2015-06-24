
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
							D.visible_message("[D] begins to reactivate [src].", "<span class='notice'>You begin to reactivate [src]...</span>")
							if(do_after(user,30,needhand = 1, target = src))
								health = health_repair_max
								stat = CONSCIOUS
								icon_state = icon_living
								dead_mob_list -= src
								living_mob_list += src
								D.visible_message("[D] reactivates [src]!", "<span class='notice'>You reactivate [src].</span>")
								alert_drones(DRONE_NET_CONNECT)
								if(G)
									G << "<span class='boldnotice'>DRONE NETWORK: </span><span class='ghostalert'>You were reactivated by [D]!</span>"
							else
								D << "<span class='warning'>You need to remain still to reactivate [src]!</span>"

						if("Cannibalize")
							if(D.health < D.maxHealth)
								D.visible_message("[D] begins to cannibalize parts from [src].", "<span class='notice'>You begin to cannibalize parts from [src]...</span>")
								if(do_after(D, 60,5,0))
									D.visible_message("[D] repairs itself using [src]'s remains!", "<span class='notice'>You repair yourself using [src]'s remains.</span>")
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
		src << "<span class='danger'>[user] is trying to pick you up!</span>"
		if(buckled)
			user << "<span class='warning'>[src] is buckled to the [buckled.name] and cannot be picked up!</span>"
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
		if(health < health_repair_max)
			user << "<span class='notice'>You start to tighten loose screws on [src]...</span>"
			if(do_after(user,80))
				var/repair = health_repair_max - health
				adjustBruteLoss(-repair)
				visible_message("[user] tightens [src == user ? "their" : "[src]'s"] loose screws!", "<span class='notice'>You tighten [src == user ? "their" : "[src]'s"] loose screws.</span>")
			else
				user << "<span class='warning'>You need to remain still to tighten [src]'s screws!</span>"
		else
			user << "<span class='warning'>[src]'s screws can't get any tighter!</span>"
	else
		..()


