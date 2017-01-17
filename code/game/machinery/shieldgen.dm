/obj/structure/emergency_shield
	name = "emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	density = 1
	opacity = 0
	anchored = 1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200
	obj_integrity = 200 //The shield can only take so much beating (prevents perma-prisons)
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/emergency_shield/New()
	src.setDir(pick(1,2,3,4))
	..()
	air_update_turf(1)

/obj/structure/emergency_shield/Destroy()
	opacity = 0
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/emergency_shield/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/emergency_shield/CanPass(atom/movable/mover, turf/target, height)
	if(!height) return 0
	else return ..()

/obj/structure/emergency_shield/emp_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, "energy", 0)

/obj/structure/emergency_shield/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/EMPulse.ogg', 75, 1)
		if(BRUTE)
			playsound(loc, 'sound/effects/EMPulse.ogg', 75, 1)

/obj/structure/emergency_shield/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage was dealt
		opacity = 1
		spawn(20)
			opacity = 0

/obj/structure/emergency_shield/sanguine
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	icon_state = "shield-red"
	obj_integrity = 60
	max_integrity = 60

/obj/structure/emergency_shield/sanguine/emp_act(severity)
	return

/obj/structure/emergency_shield/invoker
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
	color = "#FF0000"
	obj_integrity = 20
	max_integrity = 20
	mouse_opacity = 0

/obj/structure/emergency_shield/invoker/emp_act(severity)
	return

/obj/machinery/shieldgen
	name = "anti-breach shielding projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = 1
	opacity = 0
	anchored = 0
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(access_engine)
	max_integrity = 100
	obj_integrity = 100
	var/active = 0
	var/list/deployed_shields = list()
	var/locked = 0
	var/shield_range = 4

/obj/machinery/shieldgen/Destroy()
	for(var/obj/structure/emergency_shield/ES in deployed_shields)
		qdel(ES)
	deployed_shields = list()
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	if(active)
		return 0 //If it's already turned on, how did this get called?

	active = 1
	update_icon()

	for(var/turf/target_tile in range(shield_range, src))
		if(isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	if(!active)
		return 0 //If it's already off, how did this get called?

	active = 0
	update_icon()

	for(var/obj/structure/emergency_shield/ES in deployed_shields)
		qdel(ES)
	deployed_shields.Cut()

/obj/machinery/shieldgen/process()
	if((stat & BROKEN) && active)
		if(deployed_shields.len && prob(5))
			qdel(pick(deployed_shields))


/obj/machinery/shieldgen/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat && BROKEN))
			stat |= BROKEN
			locked = pick(0,1)
			update_icon()

/obj/machinery/shieldgen/attack_hand(mob/user)
	if(locked)
		user << "<span class='warning'>The machine is locked, you are unable to use it!</span>"
		return
	if(panel_open)
		user << "<span class='warning'>The panel must be closed before operating this machine!</span>"
		return

	if (active)
		user.visible_message("[user] deactivated \the [src].", \
			"<span class='notice'>You deactivate \the [src].</span>", \
			"<span class='italics'>You hear heavy droning fade out.</span>")
		shields_down()
	else
		if(anchored)
			user.visible_message("[user] activated \the [src].", \
				"<span class='notice'>You activate \the [src].</span>", \
				"<span class='italics'>You hear heavy droning.</span>")
			shields_up()
		else
			user << "<span class='warning'>The device must first be secured to the floor!</span>"
	return

/obj/machinery/shieldgen/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src.loc, W.usesound, 100, 1)
		panel_open = !panel_open
		if(panel_open)
			user << "<span class='notice'>You open the panel and expose the wiring.</span>"
		else
			user << "<span class='notice'>You close the panel.</span>"
	else if(istype(W, /obj/item/stack/cable_coil) && (stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			user << "<span class='warning'>You need one length of cable to repair [src]!</span>"
			return
		user << "<span class='notice'>You begin to replace the wires...</span>"
		if(do_after(user, 30, target = src))
			if(coil.get_amount() < 1)
				return
			coil.use(1)
			obj_integrity = max_integrity
			stat &= ~BROKEN
			user << "<span class='notice'>You repair \the [src].</span>"
			update_icon()

	else if(istype(W, /obj/item/weapon/wrench))
		if(locked)
			user << "<span class='warning'>The bolts are covered! Unlocking this would retract the covers.</span>"
			return
		if(!anchored && !isinspace())
			playsound(src.loc, W.usesound, 100, 1)
			user << "<span class='notice'>You secure \the [src] to the floor!</span>"
			anchored = 1
		else if(anchored)
			playsound(src.loc, W.usesound, 100, 1)
			user << "<span class='notice'>You unsecure \the [src] from the floor!</span>"
			if(active)
				user << "<span class='notice'>\The [src] shuts off!</span>"
				shields_down()
			anchored = 0

	else if(W.GetID())
		if(allowed(user))
			locked = !locked
			user << "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>"
		else
			user << "<span class='danger'>Access denied.</span>"

	else
		return ..()

/obj/machinery/shieldgen/emag_act()
	if(!(stat & BROKEN))
		stat |= BROKEN
		obj_integrity = 0
		update_icon()

/obj/machinery/shieldgen/update_icon()
	if(active)
		icon_state = (stat & BROKEN) ? "shieldonbr":"shieldon"
	else
		icon_state = (stat & BROKEN) ? "shieldoffbr":"shieldoff"









#define maxstoredpower 500
/obj/machinery/shieldwallgen
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "Shield_Gen"
	anchored = 0
	density = 1
	req_access = list(access_teleporter)
	flags = CONDUCT
	use_power = 0
	obj_integrity = 300
	max_integrity = 300
	var/active = 0
	var/power = 0
	var/steps = 0
	var/last_check = 0
	var/check_delay = 10
	var/recalc = 0
	var/locked = 1
	var/obj/structure/cable/attached		// the attached cable
	var/storedpower = 0

/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return 0
	var/turf/T = src.loc

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet		// find the powernet of the connected cable

	if(!PN)
		power = 0
		return 0

	var/surplus = max(PN.avail-PN.load, 0)
	var/shieldload = min(rand(50,200), surplus)
	if(shieldload==0 && !storedpower)		// no cable or no power, and no power stored
		power = 0
		return 0
	else
		power = 1	// IVE GOT THE POWER!
		if(PN) //runtime errors fixer. They were caused by PN.newload trying to access missing network in case of working on stored power.
			storedpower += shieldload
			PN.load += shieldload //uses powernet power.

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	if(!anchored)
		user << "<span class='warning'>\The [src] needs to be firmly secured to the floor first!</span>"
		return 1
	if(locked && !issilicon(user))
		user << "<span class='warning'>The controls are locked!</span>"
		return 1
	if(power != 1)
		user << "<span class='warning'>\The [src] needs to be powered by wire underneath!</span>"
		return 1

	if(active >= 1)
		active = 0
		icon_state = "Shield_Gen"

		user.visible_message("[user] turned \the [src] off.", \
			"<span class='notice'>You turn off \the [src].</span>", \
			"<span class='italics'>You hear heavy droning fade out.</span>")
		cleanup()
	else
		active = 1
		icon_state = "Shield_Gen +a"
		user.visible_message("[user] turned \the [src] on.", \
			"<span class='notice'>You turn on \the [src].</span>", \
			"<span class='italics'>You hear heavy droning.</span>")
	add_fingerprint(user)

/obj/machinery/shieldwallgen/process()
	power()
	if(power)
		storedpower -= 50 //this way it can survive longer and survive at all
	storedpower = Clamp(storedpower, 0, maxstoredpower)


	if(active == 1)
		if(!anchored)
			active = 0
			return
		setup_field(1)
		setup_field(2)
		setup_field(4)
		setup_field(8)
		src.active = 2
	if(active >= 1)
		if(power == 0)
			visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", \
				"<span class='italics'>You hear heavy droning fade out.</span>")
			icon_state = "Shield_Gen"
			active = 0
			cleanup(1)
			cleanup(2)
			cleanup(4)
			cleanup(8)

/obj/machinery/shieldwallgen/proc/setup_field(NSEW = 0)
	var/turf/T = src.loc
	var/turf/T2 = src.loc
	var/obj/machinery/shieldwallgen/G
	var/steps = 0
	var/oNSEW = 0

	if(!NSEW)//Make sure its ran right
		return

	if(NSEW == 1)
		oNSEW = 2
	else if(NSEW == 2)
		oNSEW = 1
	else if(NSEW == 4)
		oNSEW = 8
	else if(NSEW == 8)
		oNSEW = 4

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for another generator
		T = get_step(T2, NSEW)
		T2 = T
		steps += 1
		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			steps -= 1
			if(!G.active)
				return
			G.cleanup(oNSEW)
			break

	if(isnull(G))
		return

	T2 = src.loc

	for(var/dist = 0, dist < steps, dist += 1) // creates each field tile
		var/field_dir = get_dir(T2,get_step(T2, NSEW))
		T = get_step(T2, NSEW)
		T2 = T
		var/obj/machinery/shieldwall/CF = new/obj/machinery/shieldwall/(src, G) //(ref to this gen, ref to connected gen)
		CF.loc = T
		CF.setDir(field_dir)


/obj/machinery/shieldwallgen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			user << "<span class='warning'>Turn off the field generator first!</span>"
			return

		else if(!anchored && !isinspace()) //Can't fasten this thing in space
			playsound(src.loc, W.usesound, 75, 1)
			user << "<span class='notice'>You secure the external reinforcing bolts to the floor.</span>"
			anchored = 1
			return

		else //You can unfasten it tough, if you somehow manage to fasten it.
			playsound(src.loc, W.usesound, 75, 1)
			user << "<span class='notice'>You undo the external reinforcing bolts.</span>"
			anchored = 0
			return

	if(W.GetID())
		if (allowed(user))
			locked = !locked
			user << "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>"
		else
			user << "<span class='danger'>Access denied.</span>"

	else
		add_fingerprint(user)
		return ..()

/obj/machinery/shieldwallgen/proc/cleanup(NSEW)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/shieldwallgen/G
	var/turf/T = src.loc
	var/turf/T2 = src.loc

	for(var/dist = 0, dist <= 9, dist += 1) // checks out to 8 tiles away for fields
		T = get_step(T2, NSEW)
		T2 = T
		if(locate(/obj/machinery/shieldwall) in T)
			F = (locate(/obj/machinery/shieldwall) in T)
			qdel(F)

		if(locate(/obj/machinery/shieldwallgen) in T)
			G = (locate(/obj/machinery/shieldwallgen) in T)
			if(!G.active)
				break

/obj/machinery/shieldwallgen/Destroy()
	cleanup(1)
	cleanup(2)
	cleanup(4)
	cleanup(8)
	return ..()



//////////////Containment Field START
/obj/machinery/shieldwall
	name = "shield wall"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	anchored = 1
	density = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	luminosity = 3
	var/needs_power = 0
	var/active = 1
	var/delay = 5
	var/last_active
	var/mob/U
	var/obj/machinery/shieldwallgen/gen_primary
	var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/New(var/obj/machinery/shieldwallgen/A, var/obj/machinery/shieldwallgen/B)
	..()
	src.gen_primary = A
	src.gen_secondary = B
	if(A && B)
		needs_power = 1
	for(var/mob/living/L in get_turf(src.loc))
		visible_message("<span class='danger'>\The [src] is suddenly occupying the same space as \the [L]'s organs!</span>")
		L.gib()

/obj/machinery/shieldwall/attack_hand(mob/user)
	return


/obj/machinery/shieldwall/process()
	if(needs_power)
		if(isnull(gen_primary)||isnull(gen_secondary))
			qdel(src)
			return

		if(!(gen_primary.active)||!(gen_secondary.active))
			qdel(src)
			return

		if(prob(50))
			gen_primary.storedpower -= 10
		else
			gen_secondary.storedpower -=10

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/EMPulse.ogg', 75, 1)
		if(BRUTE)
			playsound(loc, 'sound/effects/EMPulse.ogg', 75, 1)

//the shield wall is immune to damage but it drains the stored power of the generators.
/obj/machinery/shieldwall/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount)

/obj/machinery/shieldwall/proc/drain_power(drain_amount)
	if(needs_power)
		var/obj/machinery/shieldwallgen/G
		if(prob(50))
			G = gen_primary
		else
			G = gen_secondary
		G.storedpower -= drain_amount

/obj/machinery/shieldwall/bullet_act(obj/item/projectile/P)
	. = ..()
	drain_power(P.damage)


/obj/machinery/shieldwall/ex_act(severity, target)
	if(needs_power)
		var/drain_amount = 20
		switch(severity)
			if(1)
				drain_amount = 200
			if(2)
				drain_amount = 50
		drain_power(drain_amount)


/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0) return 1

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(20)
	else
		if (istype(mover, /obj/item/projectile))
			return prob(10)
		else
			return !src.density
