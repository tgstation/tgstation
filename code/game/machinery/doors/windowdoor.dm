/obj/machinery/door/window
	name = "Window Door"
	desc = "A sliding glass door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	var/base_state = "left"
	var/health = 100
	visible = 0.0
	use_power = 0
	flags = ON_BORDER
	opacity = 0
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/dismantled = 0 // To avoid playing the glass shatter sound on Destroy()
	var/secure = 0
	explosion_resistance = 5
	air_properties_vary_with_direction = 1
	ghost_read=0
	machine_flags = EMAGGABLE
	soundeffect = 'sound/machines/windowdoor.ogg'
	var/shard = /obj/item/weapon/shard
	penetration_dampening = 2

/obj/machinery/door/window/New()
	..()
	if ((istype(src.req_access) && src.req_access.len) || istext(req_access))
		src.icon_state = "[src.icon_state]"
		src.base_state = src.icon_state
	return

/obj/machinery/door/window/Destroy()
	density = 0
	if (!dismantled)
		playsound(src, "shatter", 70, 1)
	..()

/obj/machinery/door/window/examine(mob/user as mob)
	..()
	if(secure)
		to_chat(user, "It is a secure windoor, it is stronger and closes more quickly.")

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

//used in the AStar algorithm to determinate if the turf the door is on is passable
/obj/machinery/door/window/CanAStarPass(var/obj/item/weapon/card/id/ID, var/to_dir)
	return !density || (dir != to_dir) || check_access(ID)


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
	playsound(get_turf(src), soundeffect, 100, 1)
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
	playsound(get_turf(src), soundeffect, 100, 1)
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
		getFromPool(shard, loc)
		getFromPool(/obj/item/stack/cable_coil,src.loc,2)
		qdel(src)
		return

/obj/machinery/door/window/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage)
		take_damage(round(Proj.damage / 2))
	..()

//When an object is thrown at the window
/obj/machinery/door/window/hitby(AM as mob|obj)

	..()
	visible_message("<span class='warning'>The glass door was hit by [AM].</span>", 1)
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
		user.delayNextAttack(8)
		src.health = max(0, src.health - 25)
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='warning'>\The [user] smashes against \the [src.name].</span>", 1)
		if (src.health <= 0)
			getFromPool(shard, loc)
			getFromPool(/obj/item/stack/cable_coil, loc, 2)
			qdel(src)
	else
		return src.attack_hand(user)


/obj/machinery/door/window/attack_animal(mob/user as mob)
	if(src.operating)
		return
	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	user.delayNextAttack(8)
	src.health = max(0, src.health - M.melee_damage_upper)
	playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
	visible_message("<span class='warning'>\The [M] [M.attacktext] against \the [src.name].</span>", 1)
	if (src.health <= 0)
		getFromPool(shard, loc)
		getFromPool(/obj/item/stack/cable_coil, loc, 2)
		qdel(src)


/obj/machinery/door/window/attack_hand(mob/user as mob)
	return src.attackby(user, user)

/obj/machinery/door/window/attackby(obj/item/weapon/I as obj, mob/user as mob)
	// Make emagged/open doors able to be deconstructed
	if (!src.density && src.operating != 1 && istype(I, /obj/item/weapon/crowbar))
		user.visible_message("[user] removes the electronics from the windoor assembly.", "You start to remove the electronics from the windoor assembly.")
		playsound(get_turf(src), 'sound/items/Crowbar.ogg', 100, 1)
		if (do_after(user, src, 40) && src && !src.density && src.operating != 1)
			to_chat(user, "<span class='notice'>You removed the windoor electronics!</span>")
			make_assembly(user)
			src.dismantled = 1 // Don't play the glass shatter sound
			qdel(src)
		return

	//If it's in the process of opening/closing or emagged, ignore the click
	if (src.operating)
		return

	//If it's a weapon, smash windoor. Unless it's an id card, agent card, ect.. then ignore it (Cards really shouldnt damage a door anyway)
	if(src.density && istype(I, /obj/item/weapon) && !istype(I, /obj/item/weapon/card))
		var/aforce = I.force
		user.delayNextAttack(8)
		if(I.damtype == BRUTE || I.damtype == BURN)
			src.health = max(0, src.health - aforce)
		playsound(get_turf(src), 'sound/effects/Glasshit.ogg', 75, 1)
		visible_message("<span class='danger'>[src] was hit by [I].</span>")
		if (src.health <= 0)
			getFromPool(shard, loc)
			getFromPool(/obj/item/stack/cable_coil, src.loc, 2)
			qdel(src)
		return

	src.add_fingerprint(user)
	if (!src.requiresID())
		//don't care who they are or what they have, act as if they're NOTHING
		user = null

	if (isrobot(user))
		if (src.density)
			return open()
		else
			return close()

	if (!src.allowed(user) && src.density)
		flick(text("[]deny", src.base_state), src)

	return ..()

/obj/machinery/door/window/emag(mob/user)
	var used_emag = (/obj/item/weapon/card/emag in user.contents) //TODO: Find a better way of checking this
	return hackOpen(used_emag, user)

/obj/machinery/door/window/proc/hackOpen(obj/item/I, mob/user)
	src.operating = -1

	if (src.electronics)
		src.electronics.icon_state = "door_electronics_smoked"

	flick("[src.base_state]spark", src)
	sleep(6)
	open()
	return 1

/**
 * Returns whether the door opens to the left. This is counter-clockwise
 * w.r.t. the tile it is on.
 */
/obj/machinery/door/window/proc/is_left_opening()
	return src.base_state == "left" || src.base_state == "leftsecure"

/**
 * Deconstructs a windoor properly. You probably want to delete
 * the windoor after calling this.
 * @return The new /obj/structure/windoor_assembly created.
 */
/obj/machinery/door/window/proc/make_assembly(mob/user as mob)
	// Windoor assembly
	var/obj/structure/windoor_assembly/WA = new /obj/structure/windoor_assembly(src.loc)
	set_assembly(user, WA)
	return WA

/obj/machinery/door/window/proc/set_assembly(mob/user as mob, var/obj/structure/windoor_assembly/WA)
	WA.name = "Near finished Windoor Assembly"
	WA.dir = src.dir
	WA.anchored = 1
	WA.facing = (is_left_opening() ? "l" : "r")
	WA.secure = ""
	WA.state = "02"
	WA.update_icon()

	WA.fingerprints += src.fingerprints
	WA.fingerprintshidden += src.fingerprints
	WA.fingerprintslast = user.ckey

	// Pop out electronics
	var/obj/item/weapon/circuitboard/airlock/AE = (src.electronics ? src.electronics : new /obj/item/weapon/circuitboard/airlock(src.loc))
	if (src.electronics)
		src.electronics = null
		AE.loc = src.loc
	else
		// Straight from /obj/machinery/door/airlock/attackby()
		if (src.req_access && src.req_access.len > 0)
			AE.conf_access = src.req_access
		else if (src.req_one_access && src.req_one_access.len > 0)
			AE.conf_access = src.req_one_access
			AE.one_access = 1

/obj/machinery/door/window/brigdoor
	name = "Secure Window Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(access_security)
	secure = 1
	var/id_tag = null
	health = 200
	penetration_dampening = 4

/obj/machinery/door/window/brigdoor/make_assembly(mob/user as mob)
	var/obj/structure/windoor_assembly/WA = ..(user)
	WA.secure = "secure_"
	WA.update_icon()
	return WA

/obj/machinery/door/window/plasma
	name = "Plasma Window Door"
	desc = "A sliding glass door strengthened by plasma."
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	health = 300
	shard = /obj/item/weapon/shard/plasma
	penetration_dampening = 6

/obj/machinery/door/window/plasma/make_assembly(mob/user as mob)
	// Windoor assembly
	var/obj/structure/windoor_assembly/plasma/WA = new /obj/structure/windoor_assembly/plasma(src.loc)
	set_assembly(user, WA)
	return WA

/obj/machinery/door/window/plasma/secure
	name = "Secure Plasma Window Door"
	icon_state = "leftsecure"
	base_state = "leftsecure"
	health = 400
	secure = 1
	penetration_dampening = 8

/obj/machinery/door/window/plasma/secure/make_assembly(mob/user as mob)
	var/obj/structure/windoor_assembly/plasma/WA = ..(user)
	WA.secure = "secure_"
	WA.update_icon()
	return WA
