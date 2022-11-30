// Modular Computer - device that runs various programs and operates with hardware
// DO NOT SPAWN THIS TYPE. Use /laptop/ or /console/ instead.
/obj/machinery/modular_computer
	name = "modular computer"
	desc = "You shouldn't see this. If you do, report it." //they should be examining the processor instead

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.
	icon = 'icons/obj/modular_console.dmi'
	icon_state = null

	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION * 0.05
	///The power cell, null by default as we use the APC we're in
	var/internal_cell = null
	///A flag that describes this device type
	var/hardware_flag = NONE
	///Power usage during last tick
	var/last_power_usage = 0
	/// Amount of programs that can be ran at once
	var/max_idle_programs = 4


	///Icon state when the computer is turned off.
	var/icon_state_unpowered = null
	///Icon state when the computer is turned on.
	var/icon_state_powered = null
	///Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/screen_icon_state_menu = "menu"
	///Icon state overlay when the computer is powered, but not 'switched on'.
	var/screen_icon_screensaver = "standby"
	///Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/steel_sheet_cost = 10
	///Light luminosity when turned on
	var/light_strength = 0
	///Power usage when the computer is open (screen is active) and can be interacted with.
	var/base_active_power_usage = 100
	///Power usage when the computer is idle and screen is off (currently only applies to laptops)
	var/base_idle_power_usage = 10

	///CPU that handles most logic while this type only handles power and other specific things.
	var/obj/item/modular_computer/processor/cpu

/obj/machinery/modular_computer/Initialize(mapload)
	. = ..()
	cpu = new(src)
	cpu.physical = src

/obj/machinery/modular_computer/Destroy()
	QDEL_NULL(cpu)
	return ..()

/obj/machinery/modular_computer/examine(mob/user)
	if(cpu)
		return cpu.examine(user)
	return ..()

/obj/machinery/modular_computer/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(cpu)
		cpu.attack_ghost(user)

/obj/machinery/modular_computer/emag_act(mob/user)
	if(!cpu)
		to_chat(user, span_warning("You'd need to turn the [src] on first."))
		return FALSE
	return cpu.emag_act(user)

/obj/machinery/modular_computer/update_appearance(updates)
	. = ..()
	set_light(cpu?.enabled ? light_strength : 0)

/obj/machinery/modular_computer/update_icon_state()
	if(!cpu || !cpu.enabled || !cpu.use_power() || (machine_stat & NOPOWER))
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered
	return ..()

/obj/machinery/modular_computer/update_overlays()
	. = ..()
	if(!cpu)
		return .

	if(cpu.enabled && cpu.use_power())
		. += cpu.active_program?.program_icon_state || screen_icon_state_menu
	else if(!(machine_stat & NOPOWER))
		. += screen_icon_screensaver

	if(cpu.get_integrity() <= cpu.integrity_failure * cpu.max_integrity)
		. += "bsod"
		. += "broken"
	return .

/// Eats the "source" arg because update_icon actually expects args now.
/obj/machinery/modular_computer/proc/relay_icon_update(datum/source, updates, updated)
	SIGNAL_HANDLER
	return update_icon(updates)

/obj/machinery/modular_computer/AltClick(mob/user)
	. = ..()
	if(!can_interact(user))
		return
	if(cpu)
		cpu.AltClick(user)

//ATTACK HAND IGNORING PARENT RETURN VALUE
// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/machinery/modular_computer/interact(mob/user)
	if(cpu)
		return cpu.interact(user)
	return ..()

// Modular computers can have battery in them, we handle power in previous proc, so prevent this from messing it up for us.
/obj/machinery/modular_computer/power_change()
	if(cpu?.use_power()) // If it still has a power source, PC wouldn't go offline.
		set_machine_stat(machine_stat & ~NOPOWER)
		update_appearance()
		return
	return ..()

/obj/machinery/modular_computer/screwdriver_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.screwdriver_act(user, tool)
	return ..()

/obj/machinery/modular_computer/wrench_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.wrench_act(user, tool)
	return ..()

/obj/machinery/modular_computer/welder_act(mob/user, obj/item/tool)
	if(cpu)
		return cpu.welder_act(user, tool)
	return ..()

/obj/machinery/modular_computer/attackby(obj/item/W as obj, mob/living/user)
	if (cpu && !user.combat_mode && !(flags_1 & NODECONSTRUCT_1))
		return cpu.attackby(W, user)
	return ..()

/obj/machinery/modular_computer/attacked_by(obj/item/attacking_item, mob/living/user)
	if (cpu)
		return cpu.attacked_by(attacking_item, user)
	return ..()

// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/machinery/modular_computer/ex_act(severity)
	if(!cpu)
		return ..()

	switch(severity)
		if(EXPLODE_DEVASTATE)
			SSexplosions.high_mov_atom += cpu
		if(EXPLODE_HEAVY)
			SSexplosions.med_mov_atom += cpu
		if(EXPLODE_LIGHT)
			SSexplosions.low_mov_atom += cpu
	return ..()

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/machinery/modular_computer/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	if(cpu)
		cpu.emp_act(severity)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/machinery/modular_computer/bullet_act(obj/projectile/Proj)
	if(cpu)
		return cpu.bullet_act(Proj)
	return ..()
