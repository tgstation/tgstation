/obj/structure/emergency_shield
	name = "emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	density = 1
	opacity = 0
	anchored = 1
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200 //The shield can only take so much beating (prevents perma-prisons)
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/emergency_shield/New()
	src.setDir(pick(1,2,3,4))
	..()
	air_update_turf(1)

/obj/structure/emergency_shield/Destroy()
	density = 0
	air_update_turf(1)
	return ..()

/obj/structure/emergency_shield/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/emergency_shield/CanPass(atom/movable/mover, turf/target, height)
	if(!height)
		return FALSE
	else
		return ..()

/obj/structure/emergency_shield/emp_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, "energy", 0)

/obj/structure/emergency_shield/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)

/obj/structure/emergency_shield/take_damage(damage, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.) //damage was dealt
		new /obj/effect/temp_visual/impact_effect/ion(loc)

/obj/structure/emergency_shield/sanguine
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	icon_state = "shield-red"
	max_integrity = 60

/obj/structure/emergency_shield/sanguine/emp_act(severity)
	return

/obj/structure/emergency_shield/invoker
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
	color = "#FF0000"
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
	req_access = list(GLOB.access_engine)
	max_integrity = 100
	var/active = FALSE
	var/list/deployed_shields
	var/locked = 0
	var/shield_range = 4

/obj/machinery/shieldgen/Initialize(mapload)
	. = ..()
	deployed_shields = list()
	if(mapload && active && anchored)
		shields_up()

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	active = TRUE
	update_icon()

	for(var/turf/target_tile in range(shield_range, src))
		if(isspaceturf(target_tile) && !(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	active = FALSE
	update_icon()
	QDEL_LIST(deployed_shields)

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
		to_chat(user, "<span class='warning'>The machine is locked, you are unable to use it!</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>The panel must be closed before operating this machine!</span>")
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
			to_chat(user, "<span class='warning'>The device must first be secured to the floor!</span>")
	return

/obj/machinery/shieldgen/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		playsound(src.loc, W.usesound, 100, 1)
		panel_open = !panel_open
		if(panel_open)
			to_chat(user, "<span class='notice'>You open the panel and expose the wiring.</span>")
		else
			to_chat(user, "<span class='notice'>You close the panel.</span>")
	else if(istype(W, /obj/item/stack/cable_coil) && (stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of cable to repair [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to replace the wires...</span>")
		if(do_after(user, 30, target = src))
			if(coil.get_amount() < 1)
				return
			coil.use(1)
			obj_integrity = max_integrity
			stat &= ~BROKEN
			to_chat(user, "<span class='notice'>You repair \the [src].</span>")
			update_icon()

	else if(istype(W, /obj/item/weapon/wrench))
		if(locked)
			to_chat(user, "<span class='warning'>The bolts are covered! Unlocking this would retract the covers.</span>")
			return
		if(!anchored && !isinspace())
			playsound(src.loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You secure \the [src] to the floor!</span>")
			anchored = 1
		else if(anchored)
			playsound(src.loc, W.usesound, 100, 1)
			to_chat(user, "<span class='notice'>You unsecure \the [src] from the floor!</span>")
			if(active)
				to_chat(user, "<span class='notice'>\The [src] shuts off!</span>")
				shields_down()
			anchored = 0

	else if(W.GetID())
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

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

#define ACTIVE_SETUPFIELDS 1
#define ACTIVE_HASFIELDS 2
/obj/machinery/shieldwallgen
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "Shield_Gen"
	anchored = 0
	density = 1
	req_access = list(GLOB.access_teleporter)
	flags = CONDUCT
	use_power = NO_POWER_USE
	max_integrity = 300
	var/active = FALSE
	var/power = 0
	var/maximum_stored_power = 500
	var/locked = 1
	var/shield_range = 8
	var/obj/structure/cable/attached // the attached cable

/obj/machinery/shieldwallgen/xenobiologyaccess		//use in xenobiology containment
	name = "xenobiology shield wall generator"
	desc = "A shield generator meant for use in xenobiology."
	icon_state = "Shield_Gen"
	req_access = list(GLOB.access_xenobiology)

/obj/machinery/shieldwallgen/Destroy()
	for(var/d in GLOB.cardinal)
		cleanup_field(d)
	return ..()

/obj/machinery/shieldwallgen/proc/power()
	if(!anchored)
		power = 0
		return
	var/turf/T = get_turf(src)

	var/obj/structure/cable/C = T.get_cable_node()
	var/datum/powernet/PN
	if(C)
		PN = C.powernet //find the powernet of the connected cable

	if(!PN)
		return

	var/surplus = max(PN.avail - PN.load, 0)
	var/avail_power = min(rand(50,200), surplus)
	if(avail_power)
		power += avail_power
		PN.load += avail_power //uses powernet power.

/obj/machinery/shieldwallgen/process()
	power()
	use_stored_power(50)

/obj/machinery/shieldwallgen/proc/use_stored_power(amount)
	power = Clamp(power - amount, 0, maximum_stored_power)
	update_activity()

/obj/machinery/shieldwallgen/proc/update_activity()
	if(active)
		icon_state = "Shield_Gen +a"
		if(active == ACTIVE_SETUPFIELDS)
			var/fields = 0
			for(var/d in GLOB.cardinal)
				if(setup_field(d))
					fields++
			if(fields)
				active = ACTIVE_HASFIELDS
		if(!power)
			visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", \
				"<span class='italics'>You hear heavy droning fade out.</span>")
			icon_state = "Shield_Gen"
			active = FALSE
			for(var/d in GLOB.cardinal)
				cleanup_field(d)
	else
		icon_state = "Shield_Gen"
		for(var/d in GLOB.cardinal)
			cleanup_field(d)

/obj/machinery/shieldwallgen/proc/setup_field(direction)
	if(!direction)
		return

	var/turf/T = loc
	var/obj/machinery/shieldwallgen/G
	var/steps = 0
	var/opposite_direction = turn(direction, 180)

	for(var/i in 1 to shield_range) //checks out to 8 tiles away for another generator
		T = get_step(T, direction)
		G = (locate(/obj/machinery/shieldwallgen) in T)
		if(G)
			if(!G.active)
				return
			G.cleanup_field(opposite_direction)
			break
		else
			steps++

	if(!G || !steps) //no shield gen or no tiles between us and the gen
		return

	for(var/i in 1 to steps) //creates each field tile
		T = get_step(T, opposite_direction)
		new/obj/machinery/shieldwall(T, src, G)
	return TRUE

/obj/machinery/shieldwallgen/proc/cleanup_field(direction)
	var/obj/machinery/shieldwall/F
	var/obj/machinery/shieldwallgen/G
	var/turf/T = loc

	for(var/i in 1 to shield_range)
		T = get_step(T, direction)

		G = (locate(/obj/machinery/shieldwallgen) in T)
		if(G && !G.active)
			break

		F = (locate(/obj/machinery/shieldwall) in T)
		if(F && (F.gen_primary == src || F.gen_secondary == src)) //it's ours, kill it.
			qdel(F)

/obj/machinery/shieldwallgen/can_be_unfasten_wrench(mob/user, silent)
	if(active)
		if(!silent)
			to_chat(user, "<span class='warning'>Turn off the shield generator first!</span>")
		return FAILED_UNFASTEN
	return ..()

/obj/machinery/shieldwallgen/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench))
		default_unfasten_wrench(user, W, 0)

	else if(W.GetID())
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

	else
		add_fingerprint(user)
		return ..()

/obj/machinery/shieldwallgen/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first!</span>")
		return
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(!power)
		to_chat(user, "<span class='warning'>\The [src] needs to be powered by a wire!</span>")
		return

	if(active)
		user.visible_message("[user] turned \the [src] off.", \
			"<span class='notice'>You turn off \the [src].</span>", \
			"<span class='italics'>You hear heavy droning fade out.</span>")
		active = FALSE
		update_activity()
	else
		user.visible_message("[user] turned \the [src] on.", \
			"<span class='notice'>You turn on \the [src].</span>", \
			"<span class='italics'>You hear heavy droning.</span>")
		active = ACTIVE_SETUPFIELDS
		update_activity()
	add_fingerprint(user)


//////////////Containment Field START
/obj/machinery/shieldwall
	name = "shield wall"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	anchored = 1
	density = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 3
	var/needs_power = FALSE
	var/obj/machinery/shieldwallgen/gen_primary
	var/obj/machinery/shieldwallgen/gen_secondary

/obj/machinery/shieldwall/Initialize(mapload, obj/machinery/shieldwallgen/first_gen, obj/machinery/shieldwallgen/second_gen)
	. = ..()
	gen_primary = first_gen
	gen_secondary = second_gen
	if(gen_primary && gen_secondary)
		needs_power = TRUE
		setDir(get_dir(gen_primary, gen_secondary))
	for(var/mob/living/L in get_turf(src))
		visible_message("<span class='danger'>\The [src] is suddenly occupying the same space as \the [L]!</span>")
		L.gib()

/obj/machinery/shieldwall/Destroy()
	gen_primary = null
	gen_secondary = null
	return ..()

/obj/machinery/shieldwall/attack_hand(mob/user)
	return

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(!gen_primary || !gen_primary.active || !gen_secondary || !gen_secondary.active)
			qdel(src)
			return

		drain_power(10)

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)

//the shield wall is immune to damage but it drains the stored power of the generators.
/obj/machinery/shieldwall/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount)

/obj/machinery/shieldwall/proc/drain_power(drain_amount)
	if(needs_power && gen_primary)
		gen_primary.use_stored_power(drain_amount*0.5)
		if(gen_secondary) //using power may cause us to be destroyed
			gen_secondary.use_stored_power(drain_amount*0.5)

/obj/machinery/shieldwall/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return FALSE

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return prob(20)
	else
		if(istype(mover, /obj/item/projectile))
			return prob(10)
		else
			return !density
