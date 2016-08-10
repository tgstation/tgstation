// Global var to track modular computers
var/list/global_modular_computers = list()

// Modular Computer - device that runs various programs and operates with hardware
// DO NOT SPAWN THIS TYPE. Use /laptop/ or /console/ instead.
/obj/machinery/modular_computer/
	name = "modular computer"
	desc = "An advanced computer."

	var/battery_powered = 0											// Whether computer should be battery powered. It is set automatically
	use_power = 0
	var/hardware_flag = 0											// A flag that describes this device type
	var/last_power_usage = 0										// Power usage during last tick

	// Modular computers can run on various devices. Each DEVICE (Laptop, Console, Tablet,..)
	// must have it's own DMI file. Icon states must be called exactly the same in all files, but may look differently
	// If you create a program which is limited to Laptops and Consoles you don't have to add it's icon_state overlay for Tablets too, for example.

	icon = null
	icon_state = null
	var/icon_state_unpowered = null									// Icon state when the computer is turned off
	var/screen_icon_state_menu = "menu"								// Icon state overlay when the computer is turned on, but no program is loaded that would override the screen.
	var/screen_icon_screensaver = "standby"							// Icon state overlay when the computer is powered, but not 'switched on'.
	var/max_hardware_size = 0										// Maximal hardware size. Currently, tablets have 1, laptops 2 and consoles 3. Limits what hardware types can be installed.
	var/steel_sheet_cost = 10										// Amount of steel sheets refunded when disassembling an empty frame of this computer.
	var/light_strength = 0											// Light luminosity when turned on
	var/base_active_power_usage = 100								// Power usage when the computer is open (screen is active) and can be interacted with. Remember hardware can use power too.
	var/base_idle_power_usage = 10									// Power usage when the computer is idle and screen is off (currently only applies to laptops)

	var/_max_damage = 100
	var/_break_damage = 50

	var/obj/item/weapon/computer_hardware/tesla_link/tesla_link		// Tesla Link component of this computer. Allows remote charging from nearest APC.

	var/obj/item/modular_computer/processor/cpu = null				// CPU that handles most logic while this type only handles power and other specific things.

/obj/machinery/modular_computer/attack_ghost(mob/dead/observer/user)
	if(cpu)
		cpu.attack_ghost(user)

/obj/machinery/modular_computer/emag_act(mob/user)
	return cpu ? cpu.emag_act(user) : 1

/obj/machinery/modular_computer/update_icon()
	icon_state = icon_state_unpowered
	cut_overlays()

	if(!cpu || !cpu.enabled)
		if (!(stat & NOPOWER) || battery_powered)
			add_overlay(screen_icon_screensaver)
		SetLuminosity(0)
		return
	SetLuminosity(light_strength)
	if(cpu.active_program)
		add_overlay(cpu.active_program.program_icon_state ? cpu.active_program.program_icon_state : screen_icon_state_menu)
	else
		overlays.Add(screen_icon_state_menu)

// Eject ID card from computer, if it has ID slot with card inside.
/obj/machinery/modular_computer/verb/eject_id()
	set name = "Eject ID"
	set category = "Object"
	set src in view(1)

	if(cpu)
		cpu.eject_id()

// Eject ID card from computer, if it has ID slot with card inside.
/obj/machinery/modular_computer/verb/eject_usb()
	set name = "Eject Portable Device"
	set category = "Object"
	set src in view(1)

	if(cpu)
		cpu.eject_usb()

/obj/machinery/modular_computer/New()
	..()
	cpu = new(src)
	cpu.physical = src
	global_modular_computers.Add(src)

/obj/machinery/modular_computer/Destroy()
	if(cpu)
		qdel(cpu)
		cpu = null
	return ..()

// On-click handling. Turns on the computer if it's off and opens the GUI.
/obj/machinery/modular_computer/attack_hand(mob/user)
	if(cpu)
		cpu.attack_self(user) // CPU is an item, that's why we route attack_hand to attack_self

/obj/machinery/modular_computer/examine(mob/user)
	. = ..()
	if(cpu)
		cpu.examine(user)

// Process currently calls handle_power(), may be expanded in future if more things are added.
/obj/machinery/modular_computer/process()
	if(cpu)
		// Keep names in sync.
		cpu.name = src.name
		cpu.process(1)

// Checks all hardware pieces to determine if name matches, if yes, returns the hardware piece, otherwise returns null
/obj/machinery/modular_computer/proc/find_hardware_by_name(N)
	if(tesla_link && (tesla_link.name == N))
		return tesla_link
	return null

// Used in following function to reduce copypaste
/obj/machinery/modular_computer/proc/power_failure(malfunction = 0)
	if(cpu && cpu.enabled) // Shut down the computer
		visible_message("<span class='danger'>\The [src]'s screen flickers [cpu.battery_module ? "\"BATTERY [malfunction ? "MALFUNCTION" : "CRITICAL"]\"" : "\"EXTERNAL POWER LOSS\""] warning as it shuts down unexpectedly.</span>")
		if(cpu)
			cpu.shutdown_computer(0)
		battery_powered = 0
	stat |= NOPOWER
	update_icon()

// Called by cpu item's process() automatically, handles our power interaction.
/obj/machinery/modular_computer/proc/handle_power()
	if(cpu.battery_module && cpu.battery_module.battery.charge <= 0) // Battery-run but battery is depleted.
		power_failure()
		return 0
	else if(!cpu.battery_module && (!powered() || !tesla_link || !tesla_link.enabled || !tesla_link.check_functionality())) // Not battery run, but lacking APC connection.
		power_failure()
		return 0
	else if(stat & NOPOWER)
		stat &= ~NOPOWER

	if(cpu.battery_module && cpu.battery_module.battery.charge)
		battery_powered = 1
	else
		battery_powered = 0

	var/power_usage = cpu.screen_on ? base_active_power_usage : base_idle_power_usage
	for(var/C in src.cpu.get_all_components())
		var/obj/item/weapon/computer_hardware/CH = C
		if(CH.enabled)
			power_usage += CH.power_usage

	// Wireless APC connection exists.
	if(tesla_link && tesla_link.enabled && tesla_link.check_functionality())
		idle_power_usage = power_usage
		active_power_usage = idle_power_usage + 100 	// APCLink only charges at 100W rate, but covers any power usage.
		use_power = 1
		// Battery is not fully charged. Begin slowly recharging.
		if(cpu.battery_module && (cpu.battery_module.battery.charge < cpu.battery_module.battery.maxcharge))
			use_power = 2

		if(cpu.battery_module && powered() && (use_power == 2)) // Battery charging itself
			cpu.battery_module.battery.give(100 * CELLRATE)
		else if(cpu.battery_module && !powered()) // Unpowered, but battery covers the usage.
			cpu.battery_module.battery.use(idle_power_usage * CELLRATE)

	else	// No wireless connection run only on battery.
		use_power = 0
		if (cpu.battery_module)
			if(!cpu.battery_module.check_functionality())
				power_failure(1)
				return
			cpu.battery_module.battery.use(power_usage * CELLRATE)
	cpu.last_power_usage = power_usage

// Modular computers can have battery in them, we handle power in previous proc, so prevent this from messing it up for us.
/obj/machinery/modular_computer/power_change()
	if(battery_powered)
		return
	..()

/obj/machinery/modular_computer/attackby(var/obj/item/weapon/W as obj, mob/user)
	if(cpu)
		return cpu.attackby(W, user)
	return ..()


// Stronger explosions cause serious damage to internal components
// Minor explosions are mostly mitigitated by casing.
/obj/machinery/modular_computer/ex_act(severity)
	if(cpu)
		cpu.ex_act(severity)

// EMPs are similar to explosions, but don't cause physical damage to the casing. Instead they screw up the components
/obj/machinery/modular_computer/emp_act(severity)
	if(cpu)
		cpu.emp_act(severity)

// "Stun" weapons can cause minor damage to components (short-circuits?)
// "Burn" damage is equally strong against internal components and exterior casing
// "Brute" damage mostly damages the casing.
/obj/machinery/modular_computer/bullet_act(obj/item/projectile/Proj)
	if(cpu)
		cpu.bullet_act(Proj)



