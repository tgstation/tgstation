/obj/structure/reflector
	name = "reflector base"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_map"
	desc = "A base for reflector assemblies."
	anchored = FALSE
	density = FALSE
	///Icon state of this specific reflector type
	var/deflector_icon_state
	///The reference to the overlay we'll use once we've built the reflector.
	var/image/deflector_overlay
	///Is the build finished?
	var/finished = FALSE
	///Only for mapped reflectors or admin spawned, can't be rotated or deconstructed
	var/admin = FALSE
	///Can this reflector be rotated?
	var/can_rotate = TRUE
	///The sheet types of the frame that are dropped from disassembling the reflector
	var/frame_build_stack_type = /obj/item/stack/sheet/iron
	///Amount of sheets needed to build the frame.
	var/frame_build_stack_amount = 5
	///The sheet types of the final build that are dropped from disassembling the reflector
	var/build_stack_type = /obj/item/stack/sheet/iron
	///Amount of sheets needed to build the reflector.
	var/build_stack_amount = 0
	///Typecache of the projectiles allowed to be reflected
	var/list/allowed_projectile_typecache = list(
		/obj/projectile/beam,
		/obj/projectile/energy/nuclear_particle,
		)
	///The angle of the reflector
	var/rotation_angle = -1
	///Amount of energy to be given per deflector hit for each nuclear particle
	var/particle_power_increase

/obj/structure/reflector/Initialize(mapload)
	. = ..()
	icon_state = "reflector_base"
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(deflector_icon_state)
		deflector_overlay = image(icon, deflector_icon_state)
		add_overlay(deflector_overlay)

	if(rotation_angle == -1)
		set_angle(dir2angle(dir))
	else
		set_angle(rotation_angle)

	if(admin)
		can_rotate = FALSE

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/reflector,
	))

/obj/structure/reflector/examine(mob/user)
	. = ..()
	if(finished)
		. += "It is set to [rotation_angle] degrees, and the rotation is [can_rotate ? "unlocked" : "locked"]."
		if(!admin)
			if(can_rotate)
				. += span_notice("Alt-click to adjust its direction.")
			else
				. += span_notice("Use screwdriver to unlock the rotation.")

/obj/structure/reflector/proc/set_angle(new_angle)
	if(can_rotate)
		rotation_angle = new_angle
		if(deflector_overlay)
			cut_overlay(deflector_overlay)
			deflector_overlay.transform = turn(matrix(), new_angle)
			add_overlay(deflector_overlay)


/obj/structure/reflector/setDir(new_dir)
	return ..(NORTH)

/obj/structure/reflector/bullet_act(obj/projectile/P)
	var/pdir = P.dir
	var/pangle = P.Angle
	var/ploc = get_turf(P)
	if(!finished || !allowed_projectile_typecache[P.type] || !(P.dir in GLOB.cardinals))
		return ..()

	if(istype(P, /obj/projectile/energy/nuclear_particle) && particle_power_increase)
		var/obj/projectile/energy/nuclear_particle/reflecting_particle = P
		reflecting_particle.internal_power = max(reflecting_particle.internal_power + particle_power_increase, 0)
		if(particle_power_increase > 0)
			reflecting_particle.range += 10
		reflecting_particle.update_colours()

	if(auto_reflect(P, pdir, ploc, pangle) != BULLET_ACT_FORCE_PIERCE)
		return ..()
	return BULLET_ACT_FORCE_PIERCE

/obj/structure/reflector/proc/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	P.ignore_source_check = TRUE
	P.range = P.decayedRange
	P.decayedRange = max(P.decayedRange--, 0)
	return BULLET_ACT_FORCE_PIERCE

/obj/structure/reflector/tool_act(mob/living/user, obj/item/tool, tool_type, is_right_clicking)
	if(admin)
		return FALSE
	return ..()

/obj/structure/reflector/screwdriver_act(mob/living/user, obj/item/tool)
	can_rotate = !can_rotate
	to_chat(user, span_notice("You [can_rotate ? "unlock" : "lock"] [src]'s rotation."))
	tool.play_tool_sound(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/reflector/wrench_act(mob/living/user, obj/item/tool)
	if(anchored)
		to_chat(user, span_warning("Unweld [src] from the floor first!"))
		return TOOL_ACT_TOOLTYPE_SUCCESS
	user.visible_message(span_notice("[user] starts to dismantle [src]."), span_notice("You start to dismantle [src]..."))
	if(!tool.use_tool(src, user, 8 SECONDS, volume=50))
		return
	to_chat(user, span_notice("You dismantle [src]."))
	new frame_build_stack_type(drop_location(), frame_build_stack_amount)
	if(build_stack_amount)
		new build_stack_type(drop_location(), build_stack_amount)
	qdel(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/reflector/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount=0))
		return
	if(atom_integrity < max_integrity)
		user.visible_message(span_notice("[user] starts to repair [src]."),
							span_notice("You begin repairing [src]..."),
							span_hear("You hear welding."))
		if(tool.use_tool(src, user, 4 SECONDS, volume=40))
			atom_integrity = max_integrity
			user.visible_message(span_notice("[user] repairs [src]."), \
								span_notice("You finish repairing [src]."))
	else if(!anchored)
		user.visible_message(span_notice("[user] starts to weld [src] to the floor."),
							span_notice("You start to weld [src] to the floor..."),
							span_hear("You hear welding."))
		if (tool.use_tool(src, user, 2 SECONDS, volume=50))
			set_anchored(TRUE)
			to_chat(user, span_notice("You weld [src] to the floor."))
	else
		user.visible_message(span_notice("[user] starts to cut [src] free from the floor."),
							span_notice("You start to cut [src] free from the floor..."),
							span_hear("You hear welding."))
		if (tool.use_tool(src, user, 2 SECONDS, volume=50))
			set_anchored(FALSE)
			to_chat(user, span_notice("You cut [src] free from the floor."))

	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/reflector/attackby(obj/item/W, mob/user, params)
	if(admin)
		return
	//Finishing the frame
	else if(istype(W, /obj/item/stack/sheet))
		if(finished)
			return
		var/obj/item/stack/sheet/S = W
		if(istype(S, /obj/item/stack/sheet/glass))
			if(S.use(5))
				new /obj/structure/reflector/single(drop_location())
				qdel(src)
			else
				to_chat(user, span_warning("You need five sheets of glass to create a reflector!"))
				return
		if(istype(S, /obj/item/stack/sheet/rglass))
			if(S.use(10))
				new /obj/structure/reflector/double(drop_location())
				qdel(src)
			else
				to_chat(user, span_warning("You need ten sheets of reinforced glass to create a double reflector!"))
				return
		if(istype(S, /obj/item/stack/sheet/mineral/diamond))
			if(S.use(1))
				new /obj/structure/reflector/box(drop_location())
				qdel(src)
		if(istype(S, /obj/item/stack/sheet/plastitaniumglass))
			if(S.use(5))
				new /obj/structure/reflector/single/plastitaniumglass(drop_location())
				qdel(src)
			else
				to_chat(user, span_warning("You need five sheets of plastitanium glass to create a nuclear reflector!"))
				return
	else
		return ..()

/obj/structure/reflector/proc/rotate(mob/user)
	if (!can_rotate || admin)
		to_chat(user, span_warning("The rotation is locked!"))
		return FALSE
	var/new_angle = tgui_input_number(user, "New angle for primary reflection face", "Reflector Angle", rotation_angle, 360)
	if(isnull(new_angle) || QDELETED(user) || QDELETED(src) || !usr.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return FALSE
	set_angle(SIMPLIFY_DEGREES(new_angle))
	return TRUE

/obj/structure/reflector/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	else if(finished)
		rotate(user)


//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	deflector_icon_state = "reflector"
	desc = "An angled mirror for reflecting laser beams and nuclear particles."
	density = TRUE
	finished = TRUE
	build_stack_type = /obj/item/stack/sheet/glass
	build_stack_amount = 5

/obj/structure/reflector/single/plastitaniumglass
	name = "nuclear reflector"
	deflector_icon_state = "nuclear_reflector"
	desc = "An angled mirror for reflecting laser beams and nuclear particles. It increases the nuclear particles internal energy after each reflection."
	build_stack_type = /obj/item/stack/sheet/plastitaniumglass
	build_stack_amount = 5
	particle_power_increase = 500

/obj/structure/reflector/single/anchored
	anchored = TRUE

/obj/structure/reflector/single/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/single/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	if(abs(incidence) > 90 && abs(incidence) < 270)
		return FALSE
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.set_angle_centered(new_angle)
	return ..()

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	deflector_icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting laser beams and nuclear particles."
	density = TRUE
	finished = TRUE
	build_stack_type = /obj/item/stack/sheet/rglass
	build_stack_amount = 10

/obj/structure/reflector/double/anchored
	anchored = TRUE

/obj/structure/reflector/double/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/double/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.set_angle_centered(new_angle)
	return ..()

//BOX

/obj/structure/reflector/box
	name = "reflector box"
	deflector_icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser beams and nuclear particles in a single direction."
	density = TRUE
	finished = TRUE
	build_stack_type = /obj/item/stack/sheet/mineral/diamond
	build_stack_amount = 1
	particle_power_increase = -100

/obj/structure/reflector/box/anchored
	anchored = TRUE

/obj/structure/reflector/box/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/box/auto_reflect(obj/projectile/P)
	P.set_angle_centered(rotation_angle)
	return ..()

/obj/structure/reflector/ex_act()
	if(admin)
		return FALSE
	return ..()

/obj/structure/reflector/singularity_act()
	if(admin)
		return
	else
		return ..()

//	USB

/obj/item/circuit_component/reflector
	display_name = "Reflector"
	desc = "Allows you to adjust the angle of a reflector."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	///angle the reflector will be set to at trigger unless locked
	var/datum/port/input/angle

	var/obj/structure/reflector/attached_reflector

/obj/item/circuit_component/reflector/populate_ports()
	angle = add_input_port("Angle", PORT_TYPE_NUMBER)

/obj/item/circuit_component/reflector/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/structure/reflector))
		attached_reflector = parent

/obj/item/circuit_component/reflector/unregister_usb_parent(atom/movable/parent)
	attached_reflector = null
	return ..()

/obj/item/circuit_component/reflector/input_received(datum/port/input/port)
	attached_reflector?.set_angle(angle.value)
