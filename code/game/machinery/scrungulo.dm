#define PA_CONSTRUCTION_UNSECURED  0
#define PA_CONSTRUCTION_UNWIRED    1
#define PA_CONSTRUCTION_PANEL_OPEN 2
#define PA_CONSTRUCTION_COMPLETE   3

/obj/effect/accelerated_particle
	name = "Accelerated Particles"
	desc = "Small things moving very fast."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "particle"
	anchored = TRUE
	density = FALSE
	var/movement_range = 10
	var/energy = 10
	var/speed = 1

/obj/effect/accelerated_particle/weak
	movement_range = 8
	energy = 5

/obj/effect/accelerated_particle/strong
	movement_range = 15
	energy = 15

/obj/effect/accelerated_particle/powerful
	movement_range = 20
	energy = 50


/obj/effect/accelerated_particle/New(loc)
	..()

	addtimer(CALLBACK(src, .proc/move), 1)


/obj/effect/accelerated_particle/Bump(atom/A)
	if(A)
		if(isliving(A))
			toxmob(A)
		else if(istype(A, /obj/machinery/the_singularitygen))
			var/obj/machinery/the_singularitygen/S = A
			S.energy += energy
		else if(istype(A, /obj/singularity))
			var/obj/singularity/S = A
			S.energy += energy
		else if(istype(A, /obj/structure/blob))
			var/obj/structure/blob/B = A
			B.take_damage(energy*0.6)
			movement_range = 0

/obj/effect/accelerated_particle/Cross(atom/A)
	. = ..()
	if(isliving(A))
		toxmob(A)


/obj/effect/accelerated_particle/ex_act(severity, target)
	qdel(src)

/obj/effect/accelerated_particle/singularity_pull()
	return

/obj/effect/accelerated_particle/proc/toxmob(mob/living/M)
	M.rad_act(energy*6)

/obj/effect/accelerated_particle/proc/move()
	if(!step(src,dir))
		forceMove(get_step(src,dir))
	movement_range--
	if(movement_range == 0)
		qdel(src)
	else
		sleep(speed)
		move()

/obj/structure/particle_accelerator/particle_emitter
	name = "EM Containment Grid"
	desc = "This launches the Alpha particles, might not want to stand near this end."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	var/fire_delay = 50
	var/last_shot = 0

/obj/structure/particle_accelerator/particle_emitter/center
	icon_state = "emitter_center"
	reference = "emitter_center"

/obj/structure/particle_accelerator/particle_emitter/left
	icon_state = "emitter_left"
	reference = "emitter_left"

/obj/structure/particle_accelerator/particle_emitter/right
	icon_state = "emitter_right"
	reference = "emitter_right"

/obj/structure/particle_accelerator/particle_emitter/proc/set_delay(delay)
	if(delay >= 0)
		fire_delay = delay
		return 1
	return 0

/obj/structure/particle_accelerator/particle_emitter/proc/emit_particle(strength = 0)
	if((last_shot + fire_delay) <= world.time)
		last_shot = world.time
		var/turf/T = get_turf(src)
		var/obj/effect/accelerated_particle/P
		switch(strength)
			if(0)
				P = new/obj/effect/accelerated_particle/weak(T)
			if(1)
				P = new/obj/effect/accelerated_particle(T)
			if(2)
				P = new/obj/effect/accelerated_particle/strong(T)
			if(3)
				P = new/obj/effect/accelerated_particle/powerful(T)
		P.setDir(dir)
		return 1
	return 0

/obj/machinery/particle_accelerator/control_box
	name = "Particle Accelerator Control Console"
	desc = "This controls the density of the particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "control_box"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 500
	active_power_usage = 10000
	dir = NORTH
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	var/strength_upper_limit = 2
	var/interface_control = TRUE
	var/list/obj/structure/particle_accelerator/connected_parts
	var/assembled = FALSE
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/active = FALSE
	var/strength = 0
	var/powered = FALSE

/obj/machinery/particle_accelerator/control_box/Initialize()
	. = ..()
	wires = new /datum/wires/particle_accelerator/control_box(src)
	connected_parts = list()

/obj/machinery/particle_accelerator/control_box/Destroy()
	if(active)
		toggle_power()
	for(var/CP in connected_parts)
		var/obj/structure/particle_accelerator/part = CP
		part.master = null
	connected_parts.Cut()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/particle_accelerator/control_box/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
		return TRUE

/obj/machinery/particle_accelerator/control_box/proc/update_state()
	if(construction_state < PA_CONSTRUCTION_COMPLETE)
		use_power = NO_POWER_USE
		assembled = FALSE
		active = FALSE
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = null
			part.powered = FALSE
			part.update_icon()
		connected_parts.Cut()
		return
	if(!part_scan())
		use_power = IDLE_POWER_USE
		active = FALSE
		connected_parts.Cut()

/obj/machinery/particle_accelerator/control_box/update_icon_state()
	. = ..()
	if(active)
		icon_state = "control_boxp1"
	else
		if(use_power)
			if(assembled)
				icon_state = "control_boxp"
			else
				icon_state = "ucontrol_boxp"
		else
			switch(construction_state)
				if(PA_CONSTRUCTION_UNSECURED, PA_CONSTRUCTION_UNWIRED)
					icon_state = "control_box"
				if(PA_CONSTRUCTION_PANEL_OPEN)
					icon_state = "control_boxw"
				else
					icon_state = "control_boxc"

/obj/machinery/particle_accelerator/control_box/proc/strength_change()
	for(var/CP in connected_parts)
		var/obj/structure/particle_accelerator/part = CP
		part.strength = strength
		part.update_icon()

/obj/machinery/particle_accelerator/control_box/proc/add_strength(s)
	if(assembled && (strength < strength_upper_limit))
		strength++
		strength_change()

		message_admins("PA Control Computer increased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)]")
		log_game("PA Control Computer increased to [strength] by [key_name(usr)] in [AREACOORD(src)]")
		investigate_log("increased to <font color='red'>[strength]</font> by [key_name(usr)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)

/obj/machinery/particle_accelerator/control_box/proc/remove_strength(s)
	if(assembled && (strength > 0))
		strength--
		strength_change()

		message_admins("PA Control Computer decreased to [strength] by [ADMIN_LOOKUPFLW(usr)] in [ADMIN_VERBOSEJMP(src)]")
		log_game("PA Control Computer decreased to [strength] by [key_name(usr)] in [AREACOORD(src)]")
		investigate_log("decreased to <font color='green'>[strength]</font> by [key_name(usr)] at [AREACOORD(src)]", INVESTIGATE_SINGULO)

/obj/machinery/particle_accelerator/control_box/power_change()
	. = ..()
	if(machine_stat & NOPOWER)
		active = FALSE
		use_power = NO_POWER_USE
	else if(!machine_stat && construction_state == PA_CONSTRUCTION_COMPLETE)
		use_power = IDLE_POWER_USE

/obj/machinery/particle_accelerator/control_box/process()
	if(active)
		//a part is missing!
		if(connected_parts.len < 6)
			investigate_log("lost a connected part; It <font color='red'>powered down</font>.", INVESTIGATE_SINGULO)
			toggle_power()
			update_icon()
			return
		//emit some particles
		for(var/obj/structure/particle_accelerator/particle_emitter/PE in connected_parts)
			PE.emit_particle(strength)

/obj/machinery/particle_accelerator/control_box/proc/part_scan()
	var/ldir = turn(dir,-90)
	var/rdir = turn(dir,90)
	var/odir = turn(dir,180)
	var/turf/T = loc

	assembled = FALSE
	critical_machine = FALSE

	var/obj/structure/particle_accelerator/fuel_chamber/F = locate() in orange(1,src)
	if(!F)
		return FALSE

	setDir(F.dir)
	connected_parts.Cut()

	T = get_step(T,rdir)
	if(!check_part(T, /obj/structure/particle_accelerator/fuel_chamber))
		return FALSE
	T = get_step(T,odir)
	if(!check_part(T, /obj/structure/particle_accelerator/end_cap))
		return FALSE
	T = get_step(T,dir)
	T = get_step(T,dir)
	if(!check_part(T, /obj/structure/particle_accelerator/power_box))
		return FALSE
	T = get_step(T,dir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/center))
		return FALSE
	T = get_step(T,ldir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/left))
		return FALSE
	T = get_step(T,rdir)
	T = get_step(T,rdir)
	if(!check_part(T, /obj/structure/particle_accelerator/particle_emitter/right))
		return FALSE

	assembled = TRUE
	critical_machine = TRUE	//Only counts if the PA is actually assembled.
	return TRUE

/obj/machinery/particle_accelerator/control_box/proc/check_part(turf/T, type)
	var/obj/structure/particle_accelerator/PA = locate(/obj/structure/particle_accelerator) in T
	if(istype(PA, type) && (PA.construction_state == PA_CONSTRUCTION_COMPLETE))
		if(PA.connect_master(src))
			connected_parts.Add(PA)
			return TRUE
	return FALSE

/obj/machinery/particle_accelerator/control_box/proc/toggle_power()
	active = !active
	investigate_log("turned [active?"<font color='green'>ON</font>":"<font color='red'>OFF</font>"] by [usr ? key_name(usr) : "outside forces"] at [AREACOORD(src)]", INVESTIGATE_SINGULO)
	message_admins("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? ADMIN_LOOKUPFLW(usr) : "outside forces"] in [ADMIN_VERBOSEJMP(src)]")
	log_game("PA Control Computer turned [active ?"ON":"OFF"] by [usr ? "[key_name(usr)]" : "outside forces"] at [AREACOORD(src)]")
	if(active)
		use_power = ACTIVE_POWER_USE
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = strength
			part.powered = TRUE
			part.update_icon()
	else
		use_power = IDLE_POWER_USE
		for(var/CP in connected_parts)
			var/obj/structure/particle_accelerator/part = CP
			part.strength = null
			part.powered = FALSE
			part.update_icon()
	return TRUE

/obj/machinery/particle_accelerator/control_box/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += "Looks like it's not attached to the flooring."
		if(PA_CONSTRUCTION_UNWIRED)
			. += "It is missing some cables."
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += "The panel is open."

/obj/machinery/particle_accelerator/control_box/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	construction_state = anchorvalue ? PA_CONSTRUCTION_UNWIRED : PA_CONSTRUCTION_UNSECURED
	update_state()
	update_icon()

/obj/machinery/particle_accelerator/control_box/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(W.tool_behaviour == TOOL_WRENCH && !isinspace())
				W.play_tool_sound(src, 75)
				set_anchored(TRUE)
				user.visible_message("<span class='notice'>[user.name] secures the [name] to the floor.</span>", \
					"<span class='notice'>You secure the external bolts.</span>")
				user.changeNext_move(CLICK_CD_MELEE)
				return //set_anchored handles the rest of the stuff we need to do.
		if(PA_CONSTRUCTION_UNWIRED)
			if(W.tool_behaviour == TOOL_WRENCH)
				W.play_tool_sound(src, 75)
				set_anchored(FALSE)
				user.visible_message("<span class='notice'>[user.name] detaches the [name] from the floor.</span>", \
					"<span class='notice'>You remove the external bolts.</span>")
				user.changeNext_move(CLICK_CD_MELEE)
				return //set_anchored handles the rest of the stuff we need to do.
			else if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = W
				if(CC.use(1))
					user.visible_message("<span class='notice'>[user.name] adds wires to the [name].</span>", \
						"<span class='notice'>You add some wires.</span>")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(W.tool_behaviour == TOOL_WIRECUTTER)//TODO:Shock user if its on?
				user.visible_message("<span class='notice'>[user.name] removes some wires from the [name].</span>", \
					"<span class='notice'>You remove some wires.</span>")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] closes the [name]'s access panel.</span>", \
					"<span class='notice'>You close the access panel.</span>")
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] opens the [name]'s access panel.</span>", \
					"<span class='notice'>You open the access panel.</span>")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		user.changeNext_move(CLICK_CD_MELEE)
		update_state()
		update_icon()
		return

	return ..()

/obj/machinery/particle_accelerator/control_box/blob_act(obj/structure/blob/B)
	if(prob(50))
		qdel(src)

/obj/machinery/particle_accelerator/control_box/interact(mob/user)
	if(construction_state == PA_CONSTRUCTION_PANEL_OPEN)
		wires.interact(user)
	else
		..()

/obj/machinery/particle_accelerator/control_box/proc/is_interactive(mob/user)
	if(!interface_control)
		to_chat(user, "<span class='alert'>ERROR: Request timed out. Check wire contacts.</span>")
		return FALSE
	if(construction_state != PA_CONSTRUCTION_COMPLETE)
		return FALSE
	return TRUE

/obj/machinery/particle_accelerator/control_box/ui_status(mob/user)
	if(is_interactive(user))
		return ..()
	return UI_CLOSE

/obj/machinery/particle_accelerator/control_box/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ParticleAccelerator", name)
		ui.open()

/obj/machinery/particle_accelerator/control_box/ui_data(mob/user)
	var/list/data = list()
	data["assembled"] = assembled
	data["power"] = active
	data["strength"] = strength
	return data

/obj/machinery/particle_accelerator/control_box/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("power")
			if(wires.is_cut(WIRE_POWER))
				return
			toggle_power()
			. = TRUE
		if("scan")
			part_scan()
			. = TRUE
		if("add_strength")
			if(wires.is_cut(WIRE_STRENGTH))
				return
			add_strength()
			. = TRUE
		if("remove_strength")
			if(wires.is_cut(WIRE_STRENGTH))
				return
			remove_strength()
			. = TRUE

	update_icon()


/*Composed of 7 parts :
 3 Particle Emitters
 1 Power Box
 1 Fuel Chamber
 1 End Cap
 1 Control computer
 Setup map
   |EC|
 CC|FC|
   |PB|
 PE|PE|PE
*/
/obj/structure/particle_accelerator
	name = "Particle Accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 80)

	var/obj/machinery/particle_accelerator/control_box/master = null
	var/construction_state = PA_CONSTRUCTION_UNSECURED
	var/reference = null
	var/powered = 0
	var/strength = null

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			. += "Looks like it's not attached to the flooring."
		if(PA_CONSTRUCTION_UNWIRED)
			. += "It is missing some cables."
		if(PA_CONSTRUCTION_PANEL_OPEN)
			. += "The panel is open."

/obj/structure/particle_accelerator/Destroy()
	construction_state = PA_CONSTRUCTION_UNSECURED
	if(master)
		master.connected_parts -= src
		master.assembled = 0
		master = null
	return ..()

/obj/structure/particle_accelerator/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )


/obj/structure/particle_accelerator/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	construction_state = anchorvalue ? PA_CONSTRUCTION_UNWIRED : PA_CONSTRUCTION_UNSECURED
	update_state()
	update_icon()

/obj/structure/particle_accelerator/attackby(obj/item/W, mob/user, params)
	var/did_something = FALSE

	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED)
			if(W.tool_behaviour == TOOL_WRENCH && !isinspace())
				W.play_tool_sound(src, 75)
				set_anchored(TRUE)
				user.visible_message("<span class='notice'>[user.name] secures the [name] to the floor.</span>", \
					"<span class='notice'>You secure the external bolts.</span>")
				user.changeNext_move(CLICK_CD_MELEE)
				return //set_anchored handles the rest of the stuff we need to do.
		if(PA_CONSTRUCTION_UNWIRED)
			if(W.tool_behaviour == TOOL_WRENCH)
				W.play_tool_sound(src, 75)
				set_anchored(FALSE)
				user.visible_message("<span class='notice'>[user.name] detaches the [name] from the floor.</span>", \
					"<span class='notice'>You remove the external bolts.</span>")
				user.changeNext_move(CLICK_CD_MELEE)
				return //set_anchored handles the rest of the stuff we need to do.
			else if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/CC = W
				if(CC.use(1))
					user.visible_message("<span class='notice'>[user.name] adds wires to the [name].</span>", \
						"<span class='notice'>You add some wires.</span>")
					construction_state = PA_CONSTRUCTION_PANEL_OPEN
					did_something = TRUE
		if(PA_CONSTRUCTION_PANEL_OPEN)
			if(W.tool_behaviour == TOOL_WIRECUTTER)//TODO:Shock user if its on?
				user.visible_message("<span class='notice'>[user.name] removes some wires from the [name].</span>", \
					"<span class='notice'>You remove some wires.</span>")
				construction_state = PA_CONSTRUCTION_UNWIRED
				did_something = TRUE
			else if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] closes the [name]'s access panel.</span>", \
					"<span class='notice'>You close the access panel.</span>")
				construction_state = PA_CONSTRUCTION_COMPLETE
				did_something = TRUE
		if(PA_CONSTRUCTION_COMPLETE)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message("<span class='notice'>[user.name] opens the [name]'s access panel.</span>", \
					"<span class='notice'>You open the access panel.</span>")
				construction_state = PA_CONSTRUCTION_PANEL_OPEN
				did_something = TRUE

	if(did_something)
		user.changeNext_move(CLICK_CD_MELEE)
		update_state()
		update_icon()
		return

	return ..()


/obj/structure/particle_accelerator/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron (loc, 5)
	qdel(src)

/obj/structure/particle_accelerator/Move()
	. = ..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it <font color='red'>powered down</font>.", INVESTIGATE_SINGULO)


/obj/structure/particle_accelerator/update_icon_state()
	. = ..()
	switch(construction_state)
		if(PA_CONSTRUCTION_UNSECURED,PA_CONSTRUCTION_UNWIRED)
			icon_state="[reference]"
		if(PA_CONSTRUCTION_PANEL_OPEN)
			icon_state="[reference]w"
		if(PA_CONSTRUCTION_COMPLETE)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()

/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O.dir == dir)
		master = O
		return 1
	return 0

///////////
// PARTS //
///////////


/obj/structure/particle_accelerator/end_cap
	name = "Alpha Particle Generation Array"
	desc = "This is where Alpha particles are generated from \[REDACTED\]."
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/power_box
	name = "Particle Focusing EM Lens"
	desc = "This uses electromagnetic waves to focus the Alpha particles."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "power_box"
	reference = "power_box"

/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"

/datum/wires/particle_accelerator/control_box
	holder_type = /obj/machinery/particle_accelerator/control_box
	proper_name = "Particle Accelerator"

/datum/wires/particle_accelerator/control_box/New(atom/holder)
	wires = list(
		WIRE_POWER, WIRE_STRENGTH, WIRE_LIMIT,
		WIRE_INTERFACE
	)
	add_duds(2)
	..()

/datum/wires/particle_accelerator/control_box/interactable(mob/user)
	. = ..()
	var/obj/machinery/particle_accelerator/control_box/C = holder
	if(. && C.construction_state == 2)
		return TRUE

/datum/wires/particle_accelerator/control_box/on_pulse(wire)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_POWER)
			C.toggle_power()
		if(WIRE_STRENGTH)
			C.add_strength()
		if(WIRE_INTERFACE)
			C.interface_control = !C.interface_control
		if(WIRE_LIMIT)
			C.visible_message("<span class='notice'>[icon2html(C, viewers(holder))]<b>[C]</b> makes a large whirring noise.</span>")

/datum/wires/particle_accelerator/control_box/on_cut(wire, mend)
	var/obj/machinery/particle_accelerator/control_box/C = holder
	switch(wire)
		if(WIRE_POWER)
			if(C.active == !mend)
				C.toggle_power()
		if(WIRE_STRENGTH)
			for(var/i = 1; i < 3; i++)
				C.remove_strength()
		if(WIRE_INTERFACE)
			if(!mend)
				C.interface_control = FALSE
		if(WIRE_LIMIT)
			C.strength_upper_limit = (mend ? 2 : 3)
			if(C.strength_upper_limit < C.strength)
				C.remove_strength()

/datum/wires/particle_accelerator/control_box/emp_pulse() // to prevent singulo from pulsing wires
	return

/////SINGULARITY SPAWNER
/obj/machinery/the_singularitygen
	name = "Gravitational Singularity Generator"
	desc = "An odd device which produces a Gravitational Singularity when set up."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "TheSingGen"
	anchored = FALSE
	density = TRUE
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF

	// You can buckle someone to the singularity generator, then start the engine. Fun!
	can_buckle = TRUE
	buckle_lying = 0
	buckle_requires_restraints = TRUE

	var/energy = 0
	var/creation_type = /obj/singularity

/obj/machinery/the_singularitygen/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		default_unfasten_wrench(user, W, 0)
	else
		return ..()

/obj/machinery/the_singularitygen/process(delta_time)
	if(energy > 0)
		if(energy >= 200)
			var/turf/T = get_turf(src)
			SSblackbox.record_feedback("tally", "engine_started", 1, type)
			var/obj/singularity/S = new creation_type(T, 50)
			transfer_fingerprints_to(S)
			qdel(src)
		else
			energy -= delta_time * 0.5

/obj/machinery/the_singularitygen/red
	creation_type = /obj/singularity/red
	anchored = TRUE

/obj/machinery/the_singularitygen/green
	creation_type = /obj/singularity/green
	anchored = TRUE

/turf/open/floor/glass/hardlight
	name = "hardlight bridge"
	desc = "Wow, it's almost like the hit 2011 video game \"Portal 2\"!"
	icon = 'icons/turf/floors.dmi'
	icon_state = "hardlight"
	base_icon_state = "hardlight"
	smoothing_flags = NONE
	canSmoothWith = null
	smoothing_groups = null

/obj/structure/terminal
	name = "Instruction Terminal"
	desc = "<span class='terminal'>SINGULARITY GENERATOR INSTRUCTIONS</span>"
	icon = 'icons/obj/singularity.dmi'
	icon_state = "terminal"
	anchored = TRUE
	layer = FLY_LAYER
	maptext_x = -6
	maptext_y = 26
	maptext_width = 48
	maptext = "<span class='maptext'><font color='red'>READ ME</font></span>"

/obj/structure/terminal/examine(mob/user)
	. = ..()
	. += "<span class='terminal'>1. Set up the particle accelerator by arranging the parts in a T shape with the particle emitters facing the generator.</span>"
	. += "<span class='terminal'>2. Attach the control box to the acceleration chamber.</span>"
	. += "<span class='terminal'>3. Anchor, wire and screw the parts of the accelerator.</span>"
	. += "<span class='terminal'>4. Anchor and power the PACmans.</span>"
	. += "<span class='terminal'>5. Weld the field generators and power them with emitters.</span>"
	. += "<span class='terminal'>6. Configure and turn on the particle accelerator.</span>"
	. += "<span class='terminal'>7. Reach stage three, the further objectives are optional.</span>"
	. += "<span class='terminal'>8. Use your team beacon in the other team's room to make the singularity home on it.</span>"
	. += "<span class='terminal'>9. Turn off the emitters and hide in the locker shelter.</span>"
	. += "<span class='terminal'>10. Don't die!</span>"

#undef PA_CONSTRUCTION_UNSECURED
#undef PA_CONSTRUCTION_UNWIRED
#undef PA_CONSTRUCTION_PANEL_OPEN
#undef PA_CONSTRUCTION_COMPLETE

GLOBAL_LIST_EMPTY(feud_buttons)

/obj/structure/feudbutton
	name = "big red button"
	desc = "A big, plastic red button."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	pixel_y = 4
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	light_color = LIGHT_COLOR_FLARE
	var/obj/structure/feudsign/sign

/obj/structure/feudbutton/Initialize()
	. = ..()
	GLOB.feud_buttons |= src

/obj/structure/feudbutton/Destroy()
	. = ..()
	GLOB.feud_buttons &= ~src

/obj/structure/feudbutton/attack_hand(mob/living/user)
	. = ..()
	if(!sign.button_ready)
		return
	sign.button_ready = FALSE
	playsound(src, 'sound/machines/buzz-sigh.ogg', 100, FALSE)
	balloon_alert_to_viewers("ping!")

/obj/structure/feudsign
	name = "feud board"
	desc = "Holds the secrets of the universe."
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	anchored = TRUE
	var/button_ready = TRUE
	var/strike_counter = 0

/obj/structure/feudsign/Initialize()
	. = ..()
	var/obj/item/feudcontrol/button = new /obj/item/feudcontrol(get_turf(src))
	button.sign = src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/feudsign/LateInitialize()
	. = ..()
	for(var/obj/structure/feudbutton/button in GLOB.feud_buttons)
		button.sign = src

/obj/structure/feudsign/proc/get_input(input, obj/item/feudcontrol/source)
	if(!COOLDOWN_FINISHED(source, button_cd))
		return
	if(input == "right")
		playsound(src, 'sound/machines/ping.ogg', 100, FALSE)
		add_overlay("right")
	if(input == "wrong")
		strike_counter += 1
		playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
		add_overlay("wrong[strike_counter]")
		if(strike_counter == 3)
			strike_counter = 0
	addtimer(CALLBACK(src, .proc/reset), 1 SECONDS)
	COOLDOWN_START(source, button_cd, 1.5 SECONDS)

/obj/structure/feudsign/proc/reset()
	cut_overlays()
	button_ready = TRUE

/obj/item/feudcontrol
	name = "feud control button"
	icon_state = "timer-igniter0"
	icon = 'icons/obj/assemblies.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/obj/structure/feudsign/sign
	COOLDOWN_DECLARE(button_cd)

/obj/item/feudcontrol/attack_self(mob/user, modifiers)
	. = ..()
	sign.get_input("right", src)

/obj/item/feudcontrol/attack_self_secondary(mob/user, modifiers)
	. = ..()
	sign.get_input("wrong", src)
