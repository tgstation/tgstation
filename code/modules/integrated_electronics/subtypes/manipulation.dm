/obj/item/integrated_circuit/manipulation
	category_text = "Manipulation"

/obj/item/integrated_circuit/manipulation/weapon_firing
	name = "weapon firing mechanism"
	desc = "This somewhat complicated system allows one to slot in a gun, direct it towards a position, and remotely fire it."
	extended_desc = "The firing mechanism can slot in most ranged weapons, ballistic and energy.  \
	The first and second inputs need to be numbers.  They are coordinates for the gun to fire at, relative to the machine itself.  \
	The 'fire' activator will cause the mechanism to attempt to fire the weapon at the coordinates, if possible.  Note that the \
	normal limitations to firearms, such as ammunition requirements and firing delays, still hold true if fired by the mechanism."
	complexity = 20
	w_class = WEIGHT_CLASS_SMALL
	size = 3
	inputs = list(
		"target X rel" = IC_PINTYPE_NUMBER,
		"target Y rel" = IC_PINTYPE_NUMBER
		)
	outputs = list()
	activators = list(
		"fire" = IC_PINTYPE_PULSE_IN
	)
	var/obj/item/weapon/gun/installed_gun = null
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_COMBAT = 4)
	power_draw_per_use = 50 // The targeting mechanism uses this.  The actual gun uses its own cell for firing if it's an energy weapon.

/obj/item/integrated_circuit/manipulation/weapon_firing/Destroy()
	qdel(installed_gun)
	..()

/obj/item/integrated_circuit/manipulation/weapon_firing/attackby(var/obj/O, var/mob/user)
	if(istype(O, /obj/item/weapon/gun))
		var/obj/item/weapon/gun/gun = O
		if(installed_gun)
			user << "<span class='warning'>There's already a weapon installed.</span>"
			return
		user.drop_from_inventory(gun)
		installed_gun = gun
		size += gun.w_class
		gun.forceMove(src)
		user << "<span class='notice'>You slide \the [gun] into the firing mechanism.</span>"
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
	else
		..()

/obj/item/integrated_circuit/manipulation/weapon_firing/attack_self(var/mob/user)
	if(installed_gun)
		installed_gun.forceMove(get_turf(src))
		user << "<span class='notice'>You slide \the [installed_gun] out of the firing mechanism.</span>"
		size = initial(size)
		playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
		installed_gun = null
	else
		user << "<span class='notice'>There's no weapon to remove from the mechanism.</span>"

/obj/item/integrated_circuit/manipulation/weapon_firing/do_work()
	if(!installed_gun)
		return

	var/datum/integrated_io/target_x = inputs[1]
	var/datum/integrated_io/target_y = inputs[2]

	if(src.assembly)
		if(isnum(target_x.data))
			target_x.data = round(target_x.data)
		if(isnum(target_y.data))
			target_y.data = round(target_y.data)

		var/turf/T = get_turf(src.assembly)

		if(target_x.data == 0 && target_y.data == 0) // Don't shoot ourselves.
			return

		// We need to do this in order to enable relative coordinates, as locate() only works for absolute coordinates.
		var/i
		if(target_x.data > 0)
			i = abs(target_x.data)
			while(i > 0)
				T = get_step(T, EAST)
				i--
		else
			i = abs(target_x.data)
			while(i > 0)
				T = get_step(T, WEST)
				i--

		i = 0
		if(target_y.data > 0)
			i = abs(target_y.data)
			while(i > 0)
				T = get_step(T, NORTH)
				i--
		else if(target_y.data < 0)
			i = abs(target_y.data)
			while(i > 0)
				T = get_step(T, SOUTH)
				i--

		if(!T)
			return
		installed_gun.Fire_userless(T)

/obj/item/integrated_circuit/manipulation/locomotion
	name = "locomotion circuit"
	desc = "This allows a machine to move in a given direction."
	icon_state = "locomotion"
	extended_desc = "The circuit accepts a 'dir' number as a direction to move towards.<br>\
	Pulsing the 'step towards dir' activator pin will cause the machine to move a meter in that direction, assuming it is not \
	being held, or anchored in some way.  It should be noted that the ability to move is dependant on the type of assembly that this circuit inhabits."
	w_class = WEIGHT_CLASS_SMALL
	complexity = 20
//	size = 5
	inputs = list("direction" = IC_PINTYPE_DIR)
	outputs = list()
	activators = list("step towards dir" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 100

/obj/item/integrated_circuit/manipulation/locomotion/do_work()
	..()
	var/turf/T = get_turf(src)
	if(T && assembly)
		if(assembly.anchored || !assembly.can_move())
			return
		if(assembly.loc == T) // Check if we're held by someone.  If the loc is the floor, we're not held.
			var/datum/integrated_io/wanted_dir = inputs[1]
			if(isnum(wanted_dir.data))
				step(assembly, wanted_dir.data)


/obj/item/integrated_circuit/manipulation/grenade
	name = "grenade primer"
	desc = "This circuit comes with the ability to attach most types of grenades at prime them at will."
	extended_desc = "Time between priming and detonation is limited to between 1 to 12 seconds but is optional. \
					If unset, not a number, or a number less than 1 then the grenade's built-in timing will be used. \
					Beware: Once primed there is no aborting the process!"
	icon_state = "grenade"
	complexity = 30
	inputs = list("detonation time" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list("prime grenade" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_COMBAT = 4)
	var/obj/item/weapon/grenade/attached_grenade
	var/pre_attached_grenade_type

/obj/item/integrated_circuit/manipulation/grenade/New()
	..()
	if(pre_attached_grenade_type)
		var/grenade = new pre_attached_grenade_type(src)
		attach_grenade(grenade)

/obj/item/integrated_circuit/manipulation/grenade/Destroy()
	if(attached_grenade && !attached_grenade.active)
		attached_grenade.dropInto(loc)
	detach_grenade()
	. =..()

/obj/item/integrated_circuit/manipulation/grenade/attackby(var/obj/item/weapon/grenade/G, var/mob/user)
	if(istype(G))
		if(attached_grenade)
			to_chat(user, "<span class='warning'>There is already a grenade attached!</span>")
		else if(user.unEquip(G, force=1))
			user.visible_message("<span class='warning'>\The [user] attaches \a [G] to \the [src]!</span>", "<span class='notice'>You attach \the [G] to \the [src].</span>")
			attach_grenade(G)
			G.forceMove(src)
	else
		..()

/obj/item/integrated_circuit/manipulation/grenade/attack_self(var/mob/user)
	if(attached_grenade)
		user.visible_message("<span class='warning'>\The [user] removes \an [attached_grenade] from \the [src]!</span>", "<span class='notice'>You remove \the [attached_grenade] from \the [src].</span>")
		user.put_in_any_hand_if_possible(attached_grenade) || attached_grenade.dropInto(loc)
		detach_grenade()
	else
		..()

/obj/item/integrated_circuit/manipulation/grenade/do_work()
	if(attached_grenade && !attached_grenade.active)
		var/datum/integrated_io/detonation_time = inputs[1]
		if(isnum(detonation_time.data) && detonation_time.data > 0)
			attached_grenade.det_time = between(1, detonation_time.data, 12) SECONDS
		attached_grenade.activate()
		var/atom/holder = loc
		log_and_message_admins("activated a grenade assembly. Last touches: Assembly: [holder.fingerprintslast] Circuit: [fingerprintslast] Grenade: [attached_grenade.fingerprintslast]")

// These procs do not relocate the grenade, that's the callers responsibility
/obj/item/integrated_circuit/manipulation/grenade/proc/attach_grenade(var/obj/item/weapon/grenade/G)
	attached_grenade = G
	destroyed_event.register(attached_grenade, src, /obj/item/integrated_circuit/manipulation/grenade/proc/detach_grenade)
	size += G.w_class
	desc += " \An [attached_grenade] is attached to it!"

/obj/item/integrated_circuit/manipulation/grenade/proc/detach_grenade()
	if(!attached_grenade)
		return
	destroyed_event.unregister(attached_grenade, src, /obj/item/integrated_circuit/manipulation/grenade/proc/detach_grenade)
	attached_grenade = null
	size = initial(size)
	desc = initial(desc)

/obj/item/integrated_circuit/manipulation/grenade/frag
	pre_attached_grenade_type = /obj/item/weapon/grenade/explosive
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_COMBAT = 10)
	spawn_flags = null			// Used for world initializing, see the #defines above.

/obj/item/integrated_circuit/manipulation/shocker
	name = "shocker circuit"
	desc = "Used to shock adjastent creatures with electricity."
	icon_state = "shocker"
	extended_desc = "The circuit accepts a reference to creature,who needs to be shocked. It can shock target on adjacent tiles. \
	Severity determines  hardness of shock and it's power consumption. It's given between 0 and 60."
	w_class = WEIGHT_CLASS_TINY
	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"severity" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list("shock" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 0

/obj/item/integrated_circuit/manipulation/shocker/on_data_written()
	var/s = get_pin_data(IC_INPUT, 2)
	power_draw_per_use = Clamp(s,0,60)*4

/obj/item/integrated_circuit/manipulation/shocker/do_work()
	..()
	var/turf/T = get_turf(src)
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /mob/living)
	if(!istype(AM,/mob/living)) //Invalid input
		return
	var/mob/living/M = AM
	if(!M.Adjacent(T))
		return //Can't reach
	to_chat(M, "<span class='danger'>You feel a sharp shock!</span>")
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, M)
	s.start()
	M.stun_effect_act(0, Clamp(get_pin_data(IC_INPUT, 2),0,60), null)


/obj/item/integrated_circuit/manipulation/grabber
	name = "grabber"
	desc = "A circuit with it's own inventory for small/medium items, used to grab and store things."
	icon_state = "grabber"
	extended_desc = "The circuit accepts a reference to thing to be grabbed. It can store up to 10 things. Modes: 1 for grab. 0 for eject the first thing. -1 for eject all."
	w_class = WEIGHT_CLASS_SMALL
	size = 3

	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
/*
/obj/item/integrated_circuit/manipulation/thrower/New()
	processing_objects |= src

/obj/item/integrated_circuit/manipulation/thrower/Destroy()
	processing_objects -= src

/obj/item/integrated_circuit/manipulation/thrower/process()
	set_pin_data(IC_OUTPUT, 1, weakref(contents[1]))
	set_pin_data(IC_OUTPUT, 2, weakref(contents[contents.len]))
	set_pin_data(IC_OUTPUT, 3, src.contents.len)
	push_data()
*/
/obj/item/integrated_circuit/manipulation/grabber/do_work()
	var/turf/T = get_turf(src)
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	var/mode = get_pin_data(IC_INPUT, 2)
	if(mode == 1)
		if(AM.Adjacent(T))
			if(contents.len < 10)
				if(istype(AM,/obj/item))
					var obj/item/A = AM
					if(A.w_class < WEIGHT_CLASS_SMALL)
						AM.loc = src
				else if(istype(AM,/mob))
					var mob/A = AM
					if(istiny(A))
						AM.loc = src
	if(mode == 0)
		if(contents.len)
			var/obj/item/U = contents[1]
			U.loc = T
	if(mode == -1)
		if(contents.len)
			var/obj/item/U
			for(U in contents)
				U.loc = T
	set_pin_data(IC_OUTPUT, 1, weakref(contents[1]))
	set_pin_data(IC_OUTPUT, 2, weakref(contents[contents.len]))
	set_pin_data(IC_OUTPUT, 3, src.contents.len)
	push_data()
	activate_pin(2)



/obj/item/integrated_circuit/manipulation/thrower
	name = "thrower"
	desc = "A compact launcher to throw things from inside or nearby tiles"
	extended_desc = "The first and second inputs need to be numbers.  They are coordinates to throw thing at, relative to the machine itself.  \
	The 'fire' activator will cause the mechanism to attempt to throw thing at the coordinates, if possible.  Note that the \
	projectile need to be inside the machine, or to be on an adjacent tile, and to be up to medium size."
	complexity = 15
	w_class = WEIGHT_CLASS_SMALL
	size = 2
	inputs = list(
		"target X rel" = IC_PINTYPE_NUMBER,
		"target Y rel" = IC_PINTYPE_NUMBER,
		"projectile" = IC_PINTYPE_REF
		)
	outputs = list()
	activators = list(
		"fire" = IC_PINTYPE_PULSE_IN
	)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3, TECH_COMBAT = 4)
	power_draw_per_use = 50



/obj/item/integrated_circuit/manipulation/thrower/do_work()

	var/datum/integrated_io/target_x = inputs[1]
	var/datum/integrated_io/target_y = inputs[2]
	var/datum/integrated_io/projectile = inputs[3]
	if(!isweakref(projectile.data))
		return
	var/obj/item/A = projectile.data.resolve()
	if(A.anchored)
		return
	if(A.w_class>WEIGHT_CLASS_SMALL)
		return
	var/turf/T = get_turf(src.assembly)
	var/turf/TP = get_turf(A)
	if(!(TP.Adjacent(T)))
		return
	if(src.assembly)
		if(isnum(target_x.data))
			target_x.data = round(target_x.data)
		if(isnum(target_y.data))
			target_y.data = round(target_y.data)



		if(target_x.data == 0 && target_y.data == 0)
			return

		// We need to do this in order to enable relative coordinates, as locate() only works for absolute coordinates.
		var/i
		if(target_x.data > 0)
			i = abs(target_x.data)
			while(i > 0)
				T = get_step(T, EAST)
				i--
		else
			i = abs(target_x.data)
			while(i > 0)
				T = get_step(T, WEST)
				i--

		i = 0
		if(target_y.data > 0)
			i = abs(target_y.data)
			while(i > 0)
				T = get_step(T, NORTH)
				i--
		else if(target_y.data < 0)
			i = abs(target_y.data)
			while(i > 0)
				T = get_step(T, SOUTH)
				i--

		if(!T)
			return

		A.loc = get_turf(src)
		A.throw_at(T, round(Clamp(sqrt(target_x.data*target_x.data+target_y.data*target_y.data),0,8),1), 3, assembly)