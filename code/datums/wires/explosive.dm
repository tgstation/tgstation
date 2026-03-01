/datum/wires/explosive
	var/duds_number = 2 // All "dud" wires cause an explosion when cut or pulsed
	proper_name = "Explosive Device"
	randomize = TRUE // Prevents wires from showing up on blueprints

/datum/wires/explosive/New(atom/holder)
	add_duds(duds_number) // Duds also explode here.
	..()

/datum/wires/explosive/on_pulse(index)
	explode()

/datum/wires/explosive/on_cut(index, mend, source)
	if (!isnull(source))
		log_combat(source, holder, "cut the detonation wire for")
	explode()

/datum/wires/explosive/proc/explode()
	return

/datum/wires/explosive/chem_grenade
	duds_number = 1
	holder_type = /obj/item/grenade/chem_grenade
	var/fingerprint

/datum/wires/explosive/chem_grenade/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/grenade/chem_grenade/G = holder
	if(G.stage == GRENADE_WIRED)
		return TRUE

/datum/wires/explosive/chem_grenade/on_pulse(index)
	var/obj/item/grenade/chem_grenade/grenade = holder
	if(grenade.stage != GRENADE_READY)
		return
	. = ..()

/datum/wires/explosive/chem_grenade/on_cut(index, mend, source)
	var/obj/item/grenade/chem_grenade/grenade = holder
	if(grenade.stage != GRENADE_READY)
		return
	. = ..()

/datum/wires/explosive/chem_grenade/attach_assembly(color, obj/item/assembly/assembly)
	fingerprint = assembly.fingerprintslast
	var/obj/item/grenade/chem_grenade/grenade = holder
	if(!assembly.secured)
		assembly.toggle_secure()

	if(istype(assembly, /obj/item/assembly/timer))
		var/obj/item/assembly/timer/timer = assembly
		grenade.det_time = timer.saved_time SECONDS
		return ..()

	if(istype(assembly, /obj/item/assembly/prox_sensor))
		var/obj/item/assembly/prox_sensor/sensor = assembly
		grenade.landminemode = sensor
		sensor.proximity_monitor.set_ignore_if_not_on_turf(FALSE)
		sensor.time = grenade.det_time * 0.1
		return ..()

	if(!istype(assembly, /obj/item/assembly/health))
		return ..()

	var/obj/item/assembly/health/sensor = assembly
	if(!sensor.scanning)
		sensor.toggle_scan()
	return ..()

/datum/wires/explosive/chem_grenade/explode()
	var/obj/item/grenade/chem_grenade/grenade = holder
	var/obj/item/assembly/pulser = get_attached(get_wire(1))
	var/message = "\An [pulser] has pulsed [grenade] ([grenade.type]), which was installed by [fingerprint]"
	if(istype(pulser, /obj/item/assembly/voice))
		var/obj/item/assembly/voice/spoken_trigger = pulser
		message +=  " with the following activation message: \"[spoken_trigger.recorded]\""
	if(!grenade.dud_flags)
		message_admins(message)
	log_game(message)
	grenade.log_grenade(get_mob_by_ckey(fingerprint)) //Used in arm_grenade() too but this one conveys where the mob who triggered the bomb is
	if(grenade.landminemode)
		grenade.detonate() ///already armed
	else
		grenade.arm_grenade() //The one here conveys where the bomb was when it went boom


/datum/wires/explosive/chem_grenade/detach_assembly(color)
	var/obj/item/assembly/assembly = get_attached(color)
	if(!istype(assembly))
		return

	var/obj/item/grenade/chem_grenade/grenade = holder
	assemblies -= color
	assembly.connected = null
	assembly.holder = null
	assembly.forceMove(holder.drop_location())
	grenade.landminemode = null
	return assembly

/datum/wires/explosive/c4 // Also includes X4
	holder_type = /obj/item/grenade/c4

/datum/wires/explosive/c4/explode()
	var/obj/item/grenade/c4/bomb = holder
	bomb.detonate()

/datum/wires/explosive/pizza
	holder_type = /obj/item/pizzabox

/datum/wires/explosive/pizza/New(atom/holder)
	wires = list(
		WIRE_DISARM
	)
	add_duds(3) // Duds also explode here.
	..()

/datum/wires/explosive/pizza/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/item/pizzabox/pizza_bomb = holder
	if(pizza_bomb.open && pizza_bomb.bomb)
		return TRUE

/datum/wires/explosive/pizza/get_status()
	var/obj/item/pizzabox/pizza_bomb = holder
	var/list/status = list()
	status += "The red light is [pizza_bomb.bomb_active ? "on" : "off"]."
	status += "The green light is [pizza_bomb.bomb_defused ? "on": "off"]."
	return status

/datum/wires/explosive/pizza/on_pulse(wire)
	var/obj/item/pizzabox/pizza_bomb = holder
	if(wire == WIRE_DISARM) // Pulse to toggle
		pizza_bomb.bomb_defused = !pizza_bomb.bomb_defused
	else // Boom
		explode()

/datum/wires/explosive/pizza/on_cut(wire, mend, source)
	if (mend)
		return

	var/obj/item/pizzabox/pizza_bomb = holder
	if(wire == WIRE_DISARM) // Disarm and untrap the box.
		pizza_bomb.bomb_defused = TRUE
		return

	if(!pizza_bomb.bomb_defused)
		if (!isnull(source))
			log_combat(source, holder, "cut the detonation wire for")
		explode()

/datum/wires/explosive/pizza/explode()
	var/obj/item/pizzabox/pizza_bomb = holder
	pizza_bomb.bomb.detonate()
