/obj/item/integrated_circuit/manipulation
	category_text = "Manipulation"

/obj/item/integrated_circuit/manipulation/weapon_firing
	name = "weapon firing mechanism"
	desc = "This somewhat complicated system allows one to slot in a gun, direct it towards a position, and remotely fire it."
	extended_desc = "The firing mechanism can slot in any energy weapon. \
	The first and second inputs need to be numbers which correspond to coordinates for the gun to fire at relative to the machine itself. \
	The 'fire' activator will cause the mechanism to attempt to fire the weapon at the coordinates, if possible. Mode will switch between \
	lethal (TRUE) or stun (FALSE) modes. It uses the internal battery of the weapon itself, not the assembly. If you wish to fire the gun while the circuit is in \
	hand, you will need to use an assembly that is a gun."
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
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 0
	ext_cooldown = 1
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
			cooldown_per_use = 30
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
	if(!installed_gun || !installed_gun.handle_pins())
		return
	if(!isturf(assembly.loc) && !(assembly.can_fire_equipped && ishuman(assembly.loc)))
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

		assembly.visible_message("<span class='danger'>[assembly] fires [installed_gun]!</span>")
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
	Pulsing the 'step towards dir' activator pin will cause the machine to move one step in that direction, assuming it is not \
	being held, or anchored in some way. It should be noted that the ability to move is dependant on the type of assembly that this circuit inhabits; only drone assemblies can move."
	w_class = WEIGHT_CLASS_SMALL
	complexity = 10
	cooldown_per_use = 1
	ext_cooldown = 1
	inputs = list("direction" = IC_PINTYPE_DIR)
	outputs = list("obstacle" = IC_PINTYPE_REF)
	activators = list("step towards dir" = IC_PINTYPE_PULSE_IN,"on step"=IC_PINTYPE_PULSE_OUT,"blocked"=IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_MOVEMENT
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
					set_pin_data(IC_OUTPUT, 1, WEAKREF(assembly.collw))
					push_data()
					activate_pin(3)
					return FALSE
	return FALSE

/obj/item/integrated_circuit/manipulation/grenade
	name = "grenade primer"
	desc = "This circuit comes with the ability to attach most types of grenades and prime them at will."
	extended_desc = "The time between priming and detonation is limited to between 1 to 12 seconds, but is optional. \
					If the input is not set, not a number, or a number less than 1, the grenade's built-in timing will be used. \
					Beware: Once primed, there is no aborting the process!"
	icon_state = "grenade"
	complexity = 30
	cooldown_per_use = 10
	inputs = list("detonation time" = IC_PINTYPE_NUMBER)
	outputs = list()
	activators = list("prime grenade" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
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
	desc = "Used to uproot weeds and harvest/plant trays."
	icon_state = "plant_m"
	extended_desc = "The circuit accepts a reference to a hydroponic tray or an item on an adjacent tile. \
	Mode input (0-harvest, 1-uproot weeds, 2-uproot plant, 3-plant seed) determines action. \
	Harvesting outputs a list of the harvested plants."
	w_class = WEIGHT_CLASS_TINY
	complexity = 10
	inputs = list("tray" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER,"item" = IC_PINTYPE_REF)
	outputs = list("result" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50

/obj/item/integrated_circuit/manipulation/plant_module/do_work()
	..()
	var/obj/acting_object = get_object()
	var/obj/OM = get_pin_data_as_type(IC_INPUT, 1, /obj)
	var/obj/O = get_pin_data_as_type(IC_INPUT, 3, /obj/item)

	if(!check_target(OM))
		push_data()
		activate_pin(2)
		return

	if(istype(OM,/obj/structure/spacevine) && check_target(OM) && get_pin_data(IC_INPUT, 2) == 2)
		qdel(OM)
		push_data()
		activate_pin(2)
		return

	var/obj/machinery/hydroponics/TR = OM
	if(istype(TR))
		switch(get_pin_data(IC_INPUT, 2))
			if(0)
				var/list/harvest_output = TR.attack_hand()
				for(var/i in 1 to length(harvest_output))
					harvest_output[i] = WEAKREF(harvest_output[i])

				if(harvest_output.len)
					set_pin_data(IC_OUTPUT, 1, harvest_output)
					push_data()
			if(1)
				TR.weedlevel = 0
				TR.update_icon()
			if(2)
				if(TR.myseed) //Could be that they're just using it as a de-weeder
					TR.age = 0
					TR.plant_health = 0
					if(TR.harvest)
						TR.harvest = FALSE //To make sure they can't just put in another seed and insta-harvest it
					qdel(TR.myseed)
					TR.myseed = null
				TR.weedlevel = 0 //Has a side effect of cleaning up those nasty weeds
				TR.dead = 0
				TR.update_icon()
			if(3)
				if(!check_target(O))
					activate_pin(2)
					return FALSE

				else if(istype(O, /obj/item/seeds) && !istype(O, /obj/item/seeds/sample))
					if(!TR.myseed)
						if(istype(O, /obj/item/seeds/kudzu))
							investigate_log("had Kudzu planted in it by [acting_object] at [AREACOORD(src)]","kudzu")
						acting_object.visible_message("<span class='notice'>[acting_object] plants [O].</span>")
						TR.dead = 0
						TR.myseed = O
						TR.age = 1
						TR.plant_health = TR.myseed.endurance
						TR.lastcycle = world.time
						O.forceMove(TR)
						TR.update_icon()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/seed_extractor
	name = "seed extractor module"
	desc = "Used to extract seeds from grown produce."
	icon_state = "plant_m"
	extended_desc = "The circuit accepts a reference to a plant item and extracts seeds from it, outputting the results to a list."
	complexity = 8
	inputs = list("target" = IC_PINTYPE_REF)
	outputs = list("result" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50

/obj/item/integrated_circuit/manipulation/seed_extractor/do_work()
	..()
	var/obj/O = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!check_target(O))
		push_data()
		activate_pin(2)
		return

	var/list/seed_output = seedify(O, -1)
	for(var/i in 1 to length(seed_output))
		seed_output[i] = WEAKREF(seed_output[i])

	if(seed_output.len)
		set_pin_data(IC_OUTPUT, 1, seed_output)
		push_data()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/grabber
	name = "grabber"
	desc = "A circuit with its own inventory for items. Used to grab and store things."
	icon_state = "grabber"
	extended_desc = "This circuit accepts a reference to an object to be grabbed, and can store up to 10 objects. Modes: 1 to grab, 0 to eject the first object, and -1 to eject all objects. If you throw something from a grabber's inventory with a thrower, the grabber will update its outputs accordingly."
	w_class = WEIGHT_CLASS_SMALL
	size = 3
	cooldown_per_use = 5
	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_NUMBER)
	outputs = list("first" = IC_PINTYPE_REF, "last" = IC_PINTYPE_REF, "amount" = IC_PINTYPE_NUMBER,"contents" = IC_PINTYPE_LIST)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	var/max_items = 10

/obj/item/integrated_circuit/manipulation/grabber/do_work()
	var/max_w_class = assembly.w_class
	var/atom/movable/acting_object = get_object()
	var/turf/T = get_turf(acting_object)
	var/obj/item/AM = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(!QDELETED(AM) && !istype(AM, /obj/item/electronic_assembly) && !istype(AM, /obj/item/transfer_valve) && !istype(AM, /obj/item/twohanded) && !istype(assembly.loc, /obj/item/implant/storage))
		var/mode = get_pin_data(IC_INPUT, 2)
		if(mode == 1)
			if(check_target(AM))
				var/weightcheck = FALSE
				if (AM.w_class <= max_w_class)
					weightcheck = TRUE
				else
					weightcheck = FALSE
				if((contents.len < max_items) && (weightcheck))
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
	update_outputs()
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/grabber/proc/update_outputs()
	if(contents.len)
		set_pin_data(IC_OUTPUT, 1, WEAKREF(contents[1]))
		set_pin_data(IC_OUTPUT, 2, WEAKREF(contents[contents.len]))
	else
		set_pin_data(IC_OUTPUT, 1, null)
		set_pin_data(IC_OUTPUT, 2, null)
	set_pin_data(IC_OUTPUT, 3, contents.len)
	set_pin_data(IC_OUTPUT, 4, contents)
	push_data()

/obj/item/integrated_circuit/manipulation/grabber/attack_self(var/mob/user)
	if(contents.len)
		var/turf/T = get_turf(src)
		var/obj/item/U
		for(U in contents)
			U.forceMove(T)
	update_outputs()
	push_data()

/obj/item/integrated_circuit/manipulation/claw
	name = "pulling claw"
	desc = "Circuit which can pull things.."
	icon_state = "pull_claw"
	extended_desc = "This circuit accepts a reference to a thing to be pulled. Modes: 0 for release. 1 for pull."
	w_class = WEIGHT_CLASS_SMALL
	size = 3
	cooldown_per_use = 5
	complexity = 10
	inputs = list("target" = IC_PINTYPE_REF,"mode" = IC_PINTYPE_INDEX,"dir" = IC_PINTYPE_DIR)
	outputs = list("is pulling" = IC_PINTYPE_BOOLEAN)
	activators = list("pulse in" = IC_PINTYPE_PULSE_IN,"pulse out" = IC_PINTYPE_PULSE_OUT,"released" = IC_PINTYPE_PULSE_OUT,"pull to dir" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	ext_cooldown = 1
	var/max_grab = GRAB_PASSIVE

/obj/item/integrated_circuit/manipulation/claw/do_work(ord)
	var/obj/acting_object = get_object()
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/mode = get_pin_data(IC_INPUT, 2)
	switch(ord)
		if(1)
			mode = CLAMP(mode, GRAB_PASSIVE, max_grab)
			if(AM)
				if(check_target(AM, exclude_contents = TRUE))
					acting_object.start_pulling(AM,mode)
					if(acting_object.pulling)
						set_pin_data(IC_OUTPUT, 1, TRUE)
					else
						set_pin_data(IC_OUTPUT, 1, FALSE)
			push_data()

		if(4)
			if(acting_object.pulling)
				var/dir = get_pin_data(IC_INPUT, 3)
				var/turf/G =get_step(get_turf(acting_object),dir)
				var/atom/movable/pullee = acting_object.pulling
				var/turf/Pl = get_turf(pullee)
				var/turf/F = get_step_towards(Pl,G)
				if(acting_object.Adjacent(F))
					if(!step_towards(pullee, F))
						F = get_step_towards2(Pl,G)
						if(acting_object.Adjacent(F))
							step_towards(pullee, F)
	activate_pin(2)

/obj/item/integrated_circuit/manipulation/claw/stop_pulling()
	set_pin_data(IC_OUTPUT, 1, FALSE)
	activate_pin(3)
	push_data()
	..()



/obj/item/integrated_circuit/manipulation/thrower
	name = "thrower"
	desc = "A compact launcher to throw things from inside or nearby tiles."
	extended_desc = "The first and second inputs need to be numbers which correspond to the coordinates to throw objects at relative to the machine itself. \
	The 'fire' activator will cause the mechanism to attempt to throw objects at the coordinates, if possible. Note that the \
	projectile needs to be inside the machine, or on an adjacent tile, and must be medium sized or smaller. The assembly \
	must also be a gun if you wish to throw something while the assembly is in hand."
	complexity = 25
	w_class = WEIGHT_CLASS_SMALL
	size = 2
	cooldown_per_use = 10
	ext_cooldown = 1
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
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 50

/obj/item/integrated_circuit/manipulation/thrower/do_work()
	var/max_w_class = assembly.w_class
	var/target_x_rel = round(get_pin_data(IC_INPUT, 1))
	var/target_y_rel = round(get_pin_data(IC_INPUT, 2))
	var/obj/item/A = get_pin_data_as_type(IC_INPUT, 3, /obj/item)

	if(!A || A.anchored || A.throwing || A == assembly || istype(A, /obj/item/twohanded) || istype(A, /obj/item/transfer_valve))
		return

	if (istype(assembly.loc, /obj/item/implant/storage)) //Prevents the more abusive form of chestgun.
		return

	if(max_w_class && (A.w_class > max_w_class))
		return

	if(!assembly.can_fire_equipped && ishuman(assembly.loc))
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

	// If the item is in a grabber circuit we'll update the grabber's outputs after we've thrown it.
	var/obj/item/integrated_circuit/manipulation/grabber/G = A.loc

	var/x_abs = CLAMP(T.x + target_x_rel, 0, world.maxx)
	var/y_abs = CLAMP(T.y + target_y_rel, 0, world.maxy)
	var/range = round(CLAMP(sqrt(target_x_rel*target_x_rel+target_y_rel*target_y_rel),0,8),1)

	assembly.visible_message("<span class='danger'>[assembly] has thrown [A]!</span>")
	log_attack("[assembly] [REF(assembly)] has thrown [A].")
	A.forceMove(drop_location())
	A.throw_at(locate(x_abs, y_abs, T.z), range, 3)

	// If the item came from a grabber now we can update the outputs since we've thrown it.
	if(G)
		G.update_outputs()

/obj/item/integrated_circuit/manipulation/matman
	name = "material manager"
	desc = "This circuit is designed for automatic storage and distribution of materials."
	extended_desc = "The first input takes a ref of a machine with a material container. \
					Second input is used for inserting material stacks into the internal material storage. \
					Inputs 3-13 are used to transfer materials between target machine and circuit storage. \
					Positive values will take that number of materials from another machine. \
					Negative values will fill another machine from internal storage. Outputs show current stored amounts of mats."
	icon_state = "grabber"
	complexity = 16
	inputs = list(
		"target" 				= IC_PINTYPE_REF,
		"sheets to insert"	 	= IC_PINTYPE_NUMBER,
		"Metal"				 	= IC_PINTYPE_NUMBER,
		"Glass"					= IC_PINTYPE_NUMBER,
		"Silver"				= IC_PINTYPE_NUMBER,
		"Gold"					= IC_PINTYPE_NUMBER,
		"Diamond"				= IC_PINTYPE_NUMBER,
		"Uranium"				= IC_PINTYPE_NUMBER,
		"Solid Plasma"			= IC_PINTYPE_NUMBER,
		"Bluespace Mesh"		= IC_PINTYPE_NUMBER,
		"Bananium"				= IC_PINTYPE_NUMBER,
		"Titanium"				= IC_PINTYPE_NUMBER,
		)
	outputs = list(
		"self ref" 				= IC_PINTYPE_REF,
		"Total amount"		 	= IC_PINTYPE_NUMBER,
		"Metal"				 	= IC_PINTYPE_NUMBER,
		"Glass"					= IC_PINTYPE_NUMBER,
		"Silver"				= IC_PINTYPE_NUMBER,
		"Gold"					= IC_PINTYPE_NUMBER,
		"Diamond"				= IC_PINTYPE_NUMBER,
		"Uranium"				= IC_PINTYPE_NUMBER,
		"Solid Plasma"			= IC_PINTYPE_NUMBER,
		"Bluespace Mesh"		= IC_PINTYPE_NUMBER,
		"Bananium"				= IC_PINTYPE_NUMBER,
		"Titanium"				= IC_PINTYPE_NUMBER
		)
	activators = list(
		"insert sheet" = IC_PINTYPE_PULSE_IN,
		"transfer mats" = IC_PINTYPE_PULSE_IN,
		"on success" = IC_PINTYPE_PULSE_OUT,
		"on failure" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN,
		"on push ref" = IC_PINTYPE_PULSE_IN
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 40
	ext_cooldown = 1
	cooldown_per_use = 10
	var/list/mtypes = list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE)

/obj/item/integrated_circuit/manipulation/matman/Initialize()
	var/datum/component/material_container/materials = AddComponent(/datum/component/material_container,
	list(MAT_METAL, MAT_GLASS, MAT_SILVER, MAT_GOLD, MAT_DIAMOND, MAT_PLASMA, MAT_URANIUM, MAT_BANANIUM, MAT_TITANIUM, MAT_BLUESPACE), 0,
	FALSE, list(/obj/item/stack), CALLBACK(src, .proc/is_insertion_ready), CALLBACK(src, .proc/AfterMaterialInsert))
	materials.max_amount =100000
	materials.precise_insertion = TRUE
	.=..()

/obj/item/integrated_circuit/manipulation/matman/proc/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
	GET_COMPONENT(materials, /datum/component/material_container)
	set_pin_data(IC_OUTPUT, 2, materials.total_amount)
	for(var/I in 1 to mtypes.len)
		var/datum/material/M = materials.materials[mtypes[I]]
		if(M)
			set_pin_data(IC_OUTPUT, I+2, M.amount)
	push_data()

/obj/item/integrated_circuit/manipulation/matman/proc/is_insertion_ready(mob/user)
	return TRUE

/obj/item/integrated_circuit/manipulation/matman/do_work(ord)
	GET_COMPONENT(materials, /datum/component/material_container)
	var/atom/movable/H = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	if(!check_target(H))
		activate_pin(4)
		return
	var/turf/T = get_turf(H)
	switch(ord)
		if(1)
			var/obj/item/stack/sheet/S = H
			if(!S)
				activate_pin(4)
				return
			if(materials.insert_stack(S, CLAMP(get_pin_data(IC_INPUT, 2),0,100), multiplier = 1) )
				AfterMaterialInsert()
				activate_pin(3)
			else
				activate_pin(4)
		if(2)
			GET_COMPONENT_FROM(mt, /datum/component/material_container, H)
			var/suc
			for(var/I in 1 to mtypes.len)
				var/datum/material/M = materials.materials[mtypes[I]]
				if(M)
					var/U = CLAMP(get_pin_data(IC_INPUT, I+2),-100000,100000)
					if(!U)
						continue
					if(!mt) //Invalid input
						if(U>0)
							if(materials.retrieve_amount(U, mtypes[I], T))
								suc = TRUE
					else
						if(mt.transer_amt_to(materials, U, mtypes[I]))
							suc = TRUE
			if(suc)
				AfterMaterialInsert()
				activate_pin(3)
			else
				activate_pin(4)
		if(5)
			set_pin_data(IC_OUTPUT, 1, WEAKREF(src))
			AfterMaterialInsert()
			activate_pin(6)

/obj/item/integrated_circuit/manipulation/matman/Destroy()
	GET_COMPONENT(materials, /datum/component/material_container)
	materials.retrieve_all()
	.=..()