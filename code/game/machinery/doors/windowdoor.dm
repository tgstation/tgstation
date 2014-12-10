/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 150.0 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	visible = 0.0
	use_power = 0
	flags = ON_BORDER
	opacity = 0
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	explosion_resistance = 5
	air_properties_vary_with_direction = 1
	ghost_read=0

/obj/machinery/door/window/New()
	..()

	machine_flags |= EMAGGABLE // Why is this here?

	if (src.req_access && src.req_access.len)
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	return

/obj/machinery/door/window/Destroy()
	density = 0
	playsound(src, "shatter", 70, 1)
	..()

/obj/machinery/door/window/Bumped(atom/movable/AM as mob|obj)
	if (!ismob(AM))
		var/obj/machinery/bot/bot = AM
		if(istype(bot))
			if(density && src.check_access(bot.botcard))
				open()
				sleep(50)
				close()
		else if(istype(AM, /obj/mecha))
			var/obj/mecha/mecha = AM
			if(density)
				if(mecha.occupant && src.allowed(mecha.occupant))
					open()
					sleep(50)
					close()
		return
	if (!( ticker ))
		return
	if (src.operating)
		return
	if (src.density && src.allowed(AM))
		open()
		// What.
		if(src.check_access(null))
			sleep(50)
		else //secure doors close faster
			sleep(20)
		close()
	return

/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/machinery/door/window/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/machinery/door/window/open()
	if (src.operating == 1) //doors can still open when emag-disabled
		return 0
	if (!ticker)
		return 0
	if(!src.operating) //in case of emag
		src.operating = 1
	flick(text("[]opening", src.base_state), src)
	playsound(get_turf(src), 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = text("[]open", src.base_state)
	sleep(10)

	explosion_resistance = 0
	src.density = 0
//	src.sd_SetOpacity(0)	//TODO: why is this here? Opaque windoors? ~Carn
	update_nearby_tiles()

	if(operating == 1) //emag again
		src.operating = 0
	return 1

/obj/machinery/door/window/close()
	if (src.operating)
		return 0
	src.operating = 1
	flick(text("[]closing", src.base_state), src)
	playsound(get_turf(src), 'sound/machines/windowdoor.ogg', 100, 1)
	src.icon_state = src.base_state

	src.density = 1
	explosion_resistance = initial(explosion_resistance)
//	if(src.visible)
//		SetOpacity(1)	//TODO: why is this here? Opaque windoors? ~Carn
	update_nearby_tiles()

	sleep(10)

	src.operating = 0
	return 1

/obj/machinery/door/window/proc/take_damage(var/damage)
	src.health = max(0, src.health - damage)
	if (src.health <= 0)
		getFromPool(/obj/item/weapon/shard, loc)
		var/obj/item/weapon/cable_coil/CC = new /obj/item/weapon/cable_coil(src.loc)
		CC.amount = 2
		src.density = 0
		del(src)
		return

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)

	..()
	visible_message("\red <B>The glass door was hit by [AM].</B>", 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 100, 1)
	take_damage(tforce)
	//..() //Does this really need to be here twice? The parent proc doesn't even do anything yet. - Nodrak
	return

/obj/machinery/door/window/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/door/window/attack_paw(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/humanoid) || istype(user, /mob/living/carbon/slime/adult))
		if(src.operating)
			return
		user.changeNext_move(8)
		src.health = max(0, src.health - 25)
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("\red <B>[user] smashes against the [src.name].</B>", 1)
		if (src.health <= 0)
			getFromPool(/obj/item/weapon/shard, loc)
			var/obj/item/weapon/cable_coil/CC = new /obj/item/weapon/cable_coil(src.loc)
			CC.amount = 2
			src.density = 0
			del(src)
	else
		return src.attack_hand(user)


/obj/machinery/door/window/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/window/attackby(obj/item/weapon/I as obj, mob/user as mob)
	//If it's in the process of opening/closing, ignore the click
	if (src.operating)
		return

	//ninja swords? You may pass.
	if (src.density && istype(I, /obj/item/weapon/melee/energy/blade))
		hackOpen(I, user)
		return 1

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/aforce = I.force
		user.changeNext_move(8)
		if(I.damtype == BRUTE || I.damtype == BURN)
			src.health = max(0, src.health - aforce)
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("\red <B>[src] was hit by [I].</B>")
		if (src.health <= 0)
			getFromPool(/obj/item/weapon/shard, loc)
			var/obj/item/weapon/cable_coil/CC = new /obj/item/weapon/cable_coil(src.loc)
			CC.amount = 2
			src.density = 0
			del(src)
		return

	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null
		
	if (isrobot(user))
		if (src.density)
			open()
		else
			close()

	if (!src.allowed(user) && src.density)
		flick(text("[]deny", src.base_state), src)

	..()

	return

/obj/machinery/door/window/emag(mob/user)
	var used_emag = (/obj/item/weapon/card/emag in user.contents) //TODO: Find a better way of checking this
	return hackOpen(used_emag, user)

/obj/machinery/door/window/proc/hackOpen(obj/item/I, mob/user)
	src.operating = -1
	if(istype(I, /obj/item/weapon/melee/energy/blade))
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(5, 0, src.loc)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)
		playsound(get_turf(src), 'sound/weapons/blade1.ogg', 50, 1)
		visible_message("\blue The glass door was sliced open by [user]!")
	flick("[src.base_state]spark", src)
	sleep(6)
	open()
	return 1

/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	var/id_tag = null
	health = 300.0 //Stronger doors for prison (regular window door health is 200)
