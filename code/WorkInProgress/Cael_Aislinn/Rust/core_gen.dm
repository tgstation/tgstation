//the core [tokamaka generator] big funky solenoid, it generates an EM field

/*
when the core is turned on, it generates [creates] an electromagnetic field
the em field attracts plasma, and suspends it in a controlled torus (doughnut) shape, oscillating around the core

the field strength is directly controllable by the user
field strength = sqrt(energy used by the field generator)

the size of the EM field = field strength / k
(k is an arbitrary constant to make the calculated size into tilewidths)

1 tilewidth = below 5T
3 tilewidth = between 5T and 12T
5 tilewidth = between 10T and 25T
7 tilewidth = between 20T and 50T
(can't go higher than 40T)

energy is added by a gyrotron, and lost when plasma escapes
energy transferred from the gyrotron beams is reduced by how different the frequencies are (closer frequencies = more energy transferred)

frequency = field strength * (stored energy / stored moles of plasma) * x
(where x is an arbitrary constant to make the frequency something realistic)
the gyrotron beams' frequency and energy are hardcapped low enough that they won't heat the plasma much

energy is generated in considerable amounts by fusion reactions from injected particles
fusion reactions only occur when the existing energy is above a certain level, and it's near the max operating level of the gyrotron. higher energy reactions only occur at higher energy levels
a small amount of energy constantly bleeds off in the form of radiation

the field is constantly pulling in plasma from the surrounding [local] atmosphere
at random intervals, the field releases a random percentage of stored plasma in addition to a percentage of energy as intense radiation

the amount of plasma is a percentage of the field strength, increased by frequency
*/

/*
- VALUES -

max volume of plasma storeable by the field = the total volume of a number of tiles equal to the (field tilewidth)^2

*/

#define MAX_FIELD_FREQ 1000
#define MIN_FIELD_FREQ 1
#define MAX_FIELD_STR 1000
#define MIN_FIELD_STR 1

/obj/machinery/power/rust_core
	name = "RUST Tokamak core"
	desc = "Enormous solenoid for generating extremely high power electromagnetic fields"
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "core0"
	density = 1
	var/obj/effect/rust_em_field/owned_field
	var/field_strength = 1//0.01
	var/field_frequency = 1
	var/id_tag = "allan, don't forget to set the ID of this one too"
	req_access = list(access_engine)
	//
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 500	//multiplied by field strength
	var/cached_power_avail = 0
	directwired = 1
	anchored = 0

	var/locked = 1
	var/remote_access_enabled = 1

	machine_flags = WRENCHMOVE | FIXED2WORK | WELD_FIXED | EMAGGABLE

/obj/machinery/power/rust_core/process()
	if(stat & BROKEN || !powernet)
		Shutdown()

	cached_power_avail = avail()
	//luminosity = round(owned_field.field_strength/10)
	//luminosity = max(luminosity,1)

/obj/machinery/power/rust_core/wrenchAnchor(mob/user)
	if(owned_field)
		user << "Turn off \the [src] first."
		return -1
	return ..()

/obj/machinery/power/rust_core/weldToFloor(var/obj/item/weapon/weldingtool/WT, mob/user)
	if(..() == 1)
		switch(state)
			if(1)
				connect_to_network()
				src.directwired = 1
			if(2)
				disconnect_from_network()
				src.directwired = 0
		return 1
	return -1

/obj/machinery/power/rust_core/emag(mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
		return

/obj/machinery/power/rust_core/attackby(obj/item/W, mob/user)

	if(..())
		return 1

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			user << "\red The lock seems to be broken"
			return
		if(src.allowed(user))
			if(owned_field)
				src.locked = !src.locked
				user << "The controls are now [src.locked ? "locked." : "unlocked."]"
			else
				src.locked = 0 //just in case it somehow gets locked
				user << "\red The controls can only be locked when the [src] is online"
		else
			user << "\red Access denied."
		return

/obj/machinery/power/rust_core/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/power/rust_core/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/power/rust_core/interact(mob/user)
	if(stat & BROKEN)
		user.unset_machine()
		user << browse(null, "window=core_gen")
		return
	if(!istype(user, /mob/living/silicon) && get_dist(src, user) > 1)
		user.unset_machine()
		user << browse(null, "window=core_gen")
		return

	var/dat = ""
	if(stat & NOPOWER || locked || state != 2)
		dat += "<i>The console is dark and nonresponsive.</i>"
	else

		// KINDA-AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\Documents\Projects\vgstation13\code\WorkInProgress\Cael_Aislinn\Rust\core_gen.dm:187: dat += "<b>RUST Tokamak pattern Electromagnetic Field Generator</b><br>"
		dat += {"<b>RUST Tokamak pattern Electromagnetic Field Generator</b><br>
			<b>Device ID tag: </b> [id_tag ? id_tag : "UNSET"] <a href='?src=\ref[src];new_id_tag=1'>\[Modify\]</a><br>
			<a href='?src=\ref[src];toggle_active=1'>\[[owned_field ? "Deactivate" : "Activate"]\]</a><br>
			<a href='?src=\ref[src];toggle_remote=1'>\[[remote_access_enabled ? "Disable remote access to this device" : "Enable remote access to this device"]\]</a><br>
			<hr>
			<b>Field strength:</b> [field_strength]Wm^3<br>
			<a href='?src=\ref[src];str=-1000'>\[----\]</a>
		<a href='?src=\ref[src];str=-100'>\[--- \]</a>
		<a href='?src=\ref[src];str=-10'>\[--  \]</a>
		<a href='?src=\ref[src];str=-1'>\[-   \]</a>
		<a href='?src=\ref[src];str=1'>\[+   \]</a>
		<a href='?src=\ref[src];str=10'>\[++  \]</a>
		<a href='?src=\ref[src];str=100'>\[+++ \]</a>
		<a href='?src=\ref[src];str=1000'>\[++++\]</a><br>
		<b>Field frequency:</b> [field_frequency]MHz<br>
		<a href='?src=\ref[src];freq=-1000'>\[----\]</a>
		<a href='?src=\ref[src];freq=-100'>\[--- \]</a>
		<a href='?src=\ref[src];freq=-10'>\[--  \]</a>
		<a href='?src=\ref[src];freq=-1'>\[-   \]</a>
		<a href='?src=\ref[src];freq=1'>\[+   \]</a>
		<a href='?src=\ref[src];freq=10'>\[++  \]</a>
		<a href='?src=\ref[src];freq=100'>\[+++ \]</a>
		<a href='?src=\ref[src];freq=1000'>\[++++\]</a><br>"}
		// END KINDA-AUTOFIX

		var/font_colour = "green"
		if(cached_power_avail < active_power_usage)
			font_colour = "red"
		else if(cached_power_avail < active_power_usage * 2)
			font_colour = "orange"
		dat += "<b>Power status:</b> <font color=[font_colour]>[active_power_usage]/[cached_power_avail] W</font><br>"

	user << browse(dat, "window=core_gen;size=500x300")
	onclose(user, "core_gen")
	user.set_machine(src)

/obj/machinery/power/rust_core/Topic(href, href_list)
	if(href_list["str"])
		var/dif = text2num(href_list["str"])
		field_strength = min(max(field_strength + dif, MIN_FIELD_STR), MAX_FIELD_STR)
		active_power_usage = 5 * field_strength	//change to 500 later
		if(owned_field)
			owned_field.ChangeFieldStrength(field_strength)

	if(href_list["freq"])
		var/dif = text2num(href_list["freq"])
		field_frequency = min(max(field_frequency + dif, MIN_FIELD_FREQ), MAX_FIELD_FREQ)
		if(owned_field)
			owned_field.ChangeFieldFrequency(field_frequency)

	if(href_list["toggle_active"])
		if(!Startup())
			Shutdown()

	if( href_list["toggle_remote"] )
		remote_access_enabled = !remote_access_enabled

	if(href_list["new_id_tag"])
		if(usr)
			id_tag = input("Enter a new ID tag", "Tokamak core ID tag", id_tag) as text|null

	if(href_list["close"])
		usr << browse(null, "window=core_gen")
		usr.unset_machine()

	if(href_list["extern_update"])
		var/obj/machinery/computer/rust_core_control/C = locate(href_list["extern_update"])
		if(C)
			C.updateDialog()

	src.updateDialog()

/obj/machinery/power/rust_core/proc/Startup()
	if(owned_field)
		return
	owned_field = new(src.loc)
	owned_field.ChangeFieldStrength(field_strength)
	owned_field.ChangeFieldFrequency(field_frequency)
	icon_state = "core1"
	luminosity = 1
	use_power = 2
	return 1

/obj/machinery/power/rust_core/proc/Shutdown()
	//todo: safety checks for field status
	if(owned_field)
		icon_state = "core0"
		del(owned_field)
		luminosity = 0
		use_power = 1

/obj/machinery/power/rust_core/proc/AddParticles(var/name, var/quantity = 1)
	if(owned_field)
		owned_field.AddParticles(name, quantity)
		return 1
	return 0

/obj/machinery/power/rust_core/bullet_act(var/obj/item/projectile/Proj)
	if(owned_field)
		return owned_field.bullet_act(Proj)
	return 0
