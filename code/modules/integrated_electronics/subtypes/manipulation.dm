/obj/item/integrated_circuit/manipulation
	category_text = "Manipulation"

/obj/item/integrated_circuit/manipulation/weapon_firing
	name = "weapon firing mechanism"
	desc = "This somewhat complicated system allows one to slot in a gun, direct it towards a position, and remotely fire it."
	extended_desc = "The firing mechanism can slot in any energy weapon. \
	The first and second inputs need to be numbers which correspond to coordinates for the gun to fire at relative to the machine itself. \
	The 'fire' activator will cause the mechanism to attempt to fire the weapon at the coordinates, if possible. Mode is switch between \
	lethal (TRUE) or stun (FALSE) modes. It uses the internal battery of the weapon."
	complexity = 20
	w_class = WEIGHT_CLASS_SMALL
	size = 3
	inputs = list(
		"target X rel" = IC_PINTYPE_NUMBER,
		"target Y rel" = IC_PINTYPE_NUMBER,
		"mode"         = IC_PINTYPE_BOOLEAN
		)
	outputs = list("reference to gun" = IC_PINTYPE_REF)
	activators = list(
		"fire" = IC_PINTYPE_PULSE_IN

	)
	var/obj/item/gun/energy/installed_gun = null
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 0
	var/mode = FALSE

	var/stun_projectile = null		//stun mode projectile type
	var/stun_projectile_sound
	var/lethal_projectile = null	//lethal mode projectile type
	var/lethal_projectile_sound



/obj/item/integrated_circuit/manipulation/weapon_firing/Destroy()
	qdel(installed_gun)
	..()

/obj/item/integrated_circuit/manipulation/weapon_firing/attackby(var/obj/O, var/mob/user)
	if(istype(O, /obj/item/gun/energy))
		var/obj/item/gun/gun = O
		if(installed_gun)
			to_chat(user, "<span class='warning'>There's already a weapon installed.</span>")
			return

		user.transferItemToLoc(gun,src)
		installed_gun = gun
		var/list/gun_properties = gun.get_turret_properties()
		to_chat(user, "<span class='notice'>You slide \the [gun] into the firing mechanism.</span>")
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		stun_projectile = gun_properties["stun_projectile"]
		stun_projectile_sound = gun_properties["stun_projectile_sound"]
		lethal_projectile = gun_properties["lethal_projectile"]
		lethal_projectile_sound = gun_properties["lethal_projectile_sound"]
		if(gun_properties["shot_delay"])
			cooldown_per_use = gun_properties["shot_delay"]*10
		if(cooldown_per_use<30)
			cooldown_per_use = 40
		if(gun_properties["reqpower"])
			power_draw_per_use = gun_properties["reqpower"]
		set_pin_data(IC_OUTPUT, 1, WEAKREF(installed_gun))
		push_data()
	else
		..()

/obj/item/integrated_circuit/manipulation/weapon_firing/attack_self(var/mob/user)
	if(installed_gun)
		installed_gun.forceMove(drop_location())
		to_chat(user, "<span class='notice'>You slide \the [installed_gun] out of the firing mechanism.</span>")
		size = initial(size)
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		installed_gun = null
		set_pin_data(IC_OUTPUT, 1, WEAKREF(null))
		push_data()
	else
		to_chat(user, "<span class='notice'>There's no weapon to remove from the mechanism.</span>")

/obj/item/integrated_circuit/manipulation/weapon_firing/do_work()
	if(!installed_gun)
		return
	set_pin_data(IC_OUTPUT, 1, WEAKREF(installed_gun))
	push_data()
	var/datum/integrated_io/xo = inputs[1]
	var/datum/integrated_io/yo = inputs[2]
	var/datum/integrated_io/mode1 = inputs[3]

	mode = mode1.data
	if(assembly)
		if(isnum(xo.data))
			xo.data = round(xo.data, 1)
		if(isnum(yo.data))
			yo.data = round(yo.data, 1)

		var/turf/T = get_turf(assembly)
		var/target_x = CLAMP(T.x + xo.data, 0, world.maxx)
		var/target_y = CLAMP(T.y + yo.data, 0, world.maxy)

		shootAt(locate(target_x, target_y, T.z))

/obj/item/integrated_circuit/manipulation/weapon_firing/proc/shootAt(turf/target)

	var/turf/T = get_turf(src)
	var/turf/U = target
	if(!istype(T) || !istype(U))
		return
	if(!installed_gun.cell)
		return
	if(!installed_gun.cell.charge)
		return
	var/obj/item/ammo_casing/energy/shot = installed_gun.ammo_type[mode?2:1]
	if(installed_gun.cell.charge < shot.e_cost)
		return
	if(!shot)
		return
	update_icon()
	var/obj/item/projectile/A
	if(!mode)
		A = new stun_projectile(T)
		playsound(loc, stun_projectile_sound, 75, 1)
	else
		A = new lethal_projectile(T)
		playsound(loc, lethal_projectile_sound, 75, 1)


	installed_gun.cell.use(shot.e_cost)
	//Shooting Code:
	A.preparePixelProjectile(target, src)
	A.fire()
	return A

/obj/item/integrated_circuit/manipulation/locomotion
	name = "locomotion circuit"
	desc = "This allows a machine to move in a given direction."
	icon_state = "locomotion"
	extended_desc = "The circuit accepts a 'dir' number as a direction to move towards.<br>\
	Pulsing the 'step towards dir' activator pin will cause the machine to move a meter in that direction, assuming it is not \
	being held, or anchored in some way. It should be noted that the ability to move is dependant on the type of assembly that this circuit inhabits."
	w_class = WEIGHT_CLASS_SMALL
	complexity = 20
	inputs = list("direction" = IC_PINTYPE_DIR)
	outputs = list()
	activators = list("step towards dir" = IC_PINTYPE_PULSE_IN,"on step"=IC_PINTYPE_PULSE_OUT,"blocked"=IC_PINTYPE_PULSE_OUT)
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
				if(step(assembly, wanted_dir.data))
					activate_pin(2)
					return
				else
					activate_pin(3)
					return FALSE
	return FALSE

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
	var/obj/item/grenade/attached_grenade
	var/pre_attached_grenade_type

/obj/item/integrated_circuit/manipulation/grenade/Initialize()
	. = ..()
	if(pre_attached_grenade_type)
		var/grenade = new pre_attached_grenade_type(src)
		attach_grenade(grenade)

/obj/item/integrated_circuit/manipulation/grenade/Destroy()
	if(attached_grenade && !attached_grenade.active)
		attached_grenade.forceMove(loc)
	detach_grenade()
	return ..()

/obj/item/integrated_circuit/manipulation/grenade/attackby(var/obj/item/grenade/G, var/mob/user)
	if(istype(G))
		if(attached_grenade)
			to_chat(user, "<span class='warning'>There is already a grenade attached!</span>")
		else if(user.transferItemToLoc(G,src))
			user.visible_message("<span class='warning'>\The [user] attaches \a [G] to \the [src]!</span>", "<span class='notice'>You attach \the [G] to \the [src].</span>")
			attach_grenade(G)
			G.forceMove(src)
	else
		return ..()

/obj/item/integrated_circuit/manipulation/grenade/attack_self(var/mob/user)
	if(attached_grenade)
		user.visible_message("<span class='warning'>\The [user] removes \an [attached_grenade] from \the [src]!</span>", "<span class='notice'>You remove \the [attached_grenade] from \the [src].</span>")
		user.put_in_hands(attached_grenade)
		detach_grenade()
	else
		return ..()

/obj/item/integrated_circuit/manipulation/grenade/do_work()
	if(attached_grenade && !attached_grenade.active)
		var/datum/integrated_io/detonation_time = inputs[1]
		var/dt
		if(isnum(detonation_time.data) && detonation_time.data > 0)
			dt = CLAMP(detonation_time.data, 1, 12)*10
		else
			dt = 15
		addtimer(CALLBACK(attached_grenade, /obj/item/grenade.proc/prime), dt)
		var/atom/holder = loc
		message_admins("activated a grenade assembly. Last touches: Assembly: [holder.fingerprintslast] Circuit: [fingerprintslast] Grenade: [attached_grenade.fingerprintslast]")

// These procs do not relocate the grenade, that's the callers responsibility
/obj/item/integrated_circuit/manipulation/grenade/proc/attach_grenade(var/obj/item/grenade/G)
	attached_grenade = G
	G.forceMove(src)
	desc += " \An [attached_grenade] is attached to it!"

/obj/item/integrated_circuit/manipulation/grenade/proc/detach_grenade()
	if(!attached_grenade)
		return
	attached_grenade.forceMove(drop_location())
	attached_grenade = null
	desc = initial(desc)

/obj/item/integrated_circuit/manipulation/plant_module
	name = "plant manipulation module"
	desc = "Used to uproot weeds or harvest plants in trays."
	icon_state = "plant_m"
	extended_desc = "The circuit accepts a reference to a hydroponic tray in an adjacent tile. \
	Mode(0- harvest, 1-uproot weeds, 2-uproot plant) determinies action."
	w_class = WEIGHT_CLASS_TINY
	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out"=IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50

/obj/item/integrated_circuit/manipulation/plant_module/do_work()
	..()
	var/turf/T = get_turf(src)
	var/obj/OM = get_pin_data_as_type(IC_INPUT, 1, /obj)
	if(istype(OM,/obj/structure/spacevine) && get_pin_data(IC_INPUT, 2) == 2)
		qdel(OM)
		activate_pin(2)
		return
	var/obj/machinery/hydroponics/AM = OM
	if(!istype(AM)) //Invalid input
		return FALSE
	var/mob/living/M = get_turf(AM)
	if(!M.Adjacent(T))
		return //Can't reach
	switch(get_pin_data(IC_INPUT, 2))
		if(0)
			if(AM.myseed)
				if(AM.harvest)
					AM.myseed.harvest()
					AM.harvest = 0
					AM.lastproduce = AM.age
					if(!AM.myseed.get_gene(/datum/plant_gene/trait/repeated_harvest))
						qdel(AM.myseed)
						AM.myseed = null
						AM.dead = 0
					AM.update_icon()
		if(1)
			AM.weedlevel = 0
		if(2)
			if(AM.myseed) //Could be that they're just using it as a de-weeder
				AM.age = 0
				AM.plant_health = 0
				if(AM.harvest)
					AM.harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
				qdel(AM.myseed)
				AM.myseed = null
			AM.weedlevel = 0 //Has a side effect of cleaning up those nasty weeds
			AM.dead = 0
			AM.update_icon()
		else
			activate_pin(2)
			return FALSE
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/grabber
	name = "grabber"
	desc = "A circuit which is used to grab and store tiny to small objects within it's self-contained inventory."
	icon_state = "grabber"
	extended_desc = "The circuit accepts a reference to an object to be grabbed and can store up to 10 objects. Modes: 1 to grab, 0 to eject the first object, and -1 to eject all objects."
	w_class = WEIGHT_CLASS_SMALL
	size = 3

	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER,"contents" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	var/max_w_class = WEIGHT_CLASS_NORMAL
	var/max_items = 10

/obj/item/integrated_circuit/manipulation/grabber/do_work()
	var/atom/movable/acting_object = get_object()
	var/turf/T = get_turf(acting_object)
	var/obj/item/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(AM)
		var/mode = get_pin_data(IC_INPUT, 2)

		if(mode == 1)
			if(check_target(AM))
				if((contents.len < max_items) && (!max_w_class || AM.w_class <= max_w_class))
					AM.forceMove(src)
		if(mode == 0)
			if(contents.len)
				var/obj/item/U = contents[1]
				U.forceMove(T)
		if(mode == -1)
			if(contents.len)
				var/obj/item/U
				for(U in contents)
					U.forceMove(T)
	if(contents.len)
		set_pin_data(IC_OUTPUT, 1, WEAKREF(contents[1]))
		set_pin_data(IC_OUTPUT, 2, WEAKREF(contents[contents.len]))
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	set_pin_data(IC_OUTPUT, 4, contents)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/grabber/attack_self(var/mob/user)
	if(contents.len)
		var/turf/T = get_turf(src)
		var/obj/item/U
		for(U in contents)
			U.forceMove(T)
	set_pin_data(IC_OUTPUT, 1, null)
	set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	push_data()

/obj/item/integrated_circuit/manipulation/claw
	name = "pulling claw"
	desc = "Circuit which can pull things.."
	icon_state = "pull_claw"
	extended_desc = "The circuit accepts a reference to thing to be pulled. Modes: 0 for release.1 for pull. 2 for gressive grab."
	w_class = WEIGHT_CLASS_SMALL
	size = 3

	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_INDEX)
	outputs = list("is pulling" = IC_PINTYPE_BOOLEAN)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT,"released" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	var/max_grab = GRAB_PASSIVE

/obj/item/integrated_circuit/manipulation/claw/do_work()
	var/obj/acting_object = get_object()
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/mode = get_pin_data(IC_INPUT, 2)
	mode = CLAMP(mode, GRAB_PASSIVE, max_grab)
	if(AM)
		if(check_target(AM, exclude_contents = TRUE))
			acting_object.start_pulling(AM,mode)
			if(acting_object.pulling)
				set_pin_data(IC_OUTPUT, 1, TRUE)
			else
				set_pin_data(IC_OUTPUT, 1, FALSE)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/claw/stop_pulling()
	..()
	set_pin_data(IC_OUTPUT, 1, FALSE)
	activate_pin(2)
	push_data()



/obj/item/integrated_circuit/manipulation/thrower
	name = "thrower"
	desc = "A compact launcher to throw things from inside or nearby tiles."
	extended_desc = "The first and second inputs need to be numbers which correspond to coordinates to throw objects at relative to the machine itself. \
	The 'fire' activator will cause the mechanism to attempt to throw objects at the coordinates, if possible. Note that the \
	projectile need to be inside the machine, or to be on an adjacent tile, and must be medium sized or smaller."
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
	power_draw_per_use = 50
	var/max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/integrated_circuit/manipulation/thrower/do_work()
	var/target_x_rel = round(get_pin_data(IC_INPUT, 1))
	var/target_y_rel = round(get_pin_data(IC_INPUT, 2))
	var/obj/item/A = get_pin_data_as_type(IC_INPUT, 3, /obj/item)

	if(!A || A.anchored || A.throwing)
		return

	if(max_w_class && (A.w_class > max_w_class))
		return

	// Is the target inside the assembly or close to it?
	if(!check_target(A, exclude_components = TRUE))
		return

	var/turf/T = get_turf(get_object())
	if(!T)
		return

	// If the item is in mob's inventory, try to remove it from there.
	if(ismob(A.loc))
		var/mob/living/M = A.loc
		if(!M.temporarilyRemoveItemFromInventory(A))
			return

	var/x_abs = CLAMP(T.x + target_x_rel, 0, world.maxx)
	var/y_abs = CLAMP(T.y + target_y_rel, 0, world.maxy)
	var/range = round(CLAMP(sqrt(target_x_rel*target_x_rel+target_y_rel*target_y_rel),0,8),1)

	A.forceMove(drop_location())
	A.throw_at(locate(x_abs, y_abs, T.z), range, 3)
