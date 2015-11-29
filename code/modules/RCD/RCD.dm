//Main class for the modular RCD system.
/obj/item/device/rcd
	name				= "\improper Rapid-Construction-Device (RCD)"
	desc				= "Used to rapidly construct things, or deconstruct them, for that matter."

	icon				= 'icons/obj/RCD.dmi'
	icon_state			= "rcd"

	flags				= FPRINT
	siemens_coefficient	= 1
	w_class				= 3
	siemens_coefficient	= 1
	force				= 10
	throwforce			= 10
	throw_speed			= 1
	throw_range			= 5
	starting_materials	= list(MAT_IRON = 50000)
	w_type				= RECYK_ELECTRONIC
	melt_temperature	= MELTPOINT_STEEL // Lots of metal
	origin_tech			= "engineering=4;materials=2"

	var/datum/rcd_schematic/selected
	var/list/schematics	= list(/datum/rcd_schematic/test)	//list of schematics, in definitions of RCD subtypes, no organization is needed, in New() these get organized.
	var/sparky			= 1			//Make sparks. LOTS OF SPARKS.

	var/busy			= 0

	var/datum/html_interface/rcd/interface
	var/datum/effect/effect/system/spark_spread/spark_system
	
	var/obj/screen/close/closer

/obj/item/device/rcd/New()
	. = ..()

	interface = new(src, sanitize(name))	//interface gets created BEFORE the schematics get created, so they can modify the HEAD content (RPD pipe colour picker).

	init_schematics()

	rebuild_ui()

	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

//create and organize the schematics
/obj/item/device/rcd/proc/init_schematics()
	var/list/old_schematics = schematics
	schematics = list()

	for(var/path in old_schematics)
		var/datum/rcd_schematic/C = new path(src)
		if(!schematics[C.category])
			schematics[C.category] = list()

		schematics[C.category] += C

/obj/item/device/rcd/Destroy()
	for(var/cat in schematics)
		for(var/datum/rcd_schematic/C in schematics[cat])
			qdel(C)

	schematics		= null

	qdel(interface)
	qdel(spark_system)

	interface		= null
	spark_system	= null

	. = ..()

/obj/item/device/rcd/dropped(var/mob/living/dropped_by)
	..()
	if(istype(dropped_by))
		dropped_by.hud_used.toggle_show_schematics_display(null,1, src)

/obj/item/device/rcd/attack_self(var/mob/user)
	interface.show(user)

/obj/item/device/rcd/proc/rebuild_ui()
	var/dat = ""

	dat += {"
	<b>Selected:</b> <span id="selectedname"></span>
	<h2>Options</h2>
	<div id="schematic_options">
	</div>
	<h2>Available schematics</h2>
	"}
	for(var/cat in schematics)
		dat += "<b>[cat]:</b><ul style='list-style-type:disc'>"
		var/list/L = schematics[cat]
		for(var/i = 1 to L.len)	//So we have the indexes.
			var/datum/rcd_schematic/C = L[i]
			dat += "<li><a href='?src=\ref[interface];cat=[cat];index=[i]'>[C.name]</a></li>"

		dat += "</ul>"

	interface.updateLayout(dat)

	if(selected)
		update_options_menu()
		interface.updateContent("selectedname",			selected.name)

/obj/item/device/rcd/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(href_list["cat"] && href_list["index"] && !busy)	//Change selected schematic.
		var/list/L = schematics[href_list["cat"]]
		if(!L)
			return 1

		var/datum/rcd_schematic/C = L[Clamp(text2num(href_list["index"]), 1, L.len)]
		if(!istype(C))
			return 1

		if(selected && !selected.deselect(usr, C))
			return 1

		if(!C.select(usr, selected))
			return 1

		spark()

		selected = C
		update_options_menu()
		interface.updateContent("selectedname", selected.name)

		return 1

	else if(selected)	//The href didn't get handled by us so we pass it down to the selected schematic.
		return selected.Topic(href, href_list)

/obj/item/device/rcd/afterattack(var/atom/A, var/mob/user)
	if(!selected)
		return 1

	if(selected.flags ^ (RCD_SELF_SANE | RCD_RANGE) && !(user.Adjacent(A) && A.Adjacent(user)))	//If RCD_SELF_SANE and RCD_RANGE are disabled we use adjacency.
		return 1

	if(selected.flags & RCD_RANGE && selected.flags ^ RCD_SELF_SANE && get_dist(A, user) > 1)	//RCD_RANGE is used AND we're NOT SELF_SANE, use range(1)
		return 1

	if(selected.flags & RCD_GET_TURF)	//Get the turf because RCD_GET_TURF is on.
		A = get_turf(A)

	if(selected.flags ^ RCD_SELF_SANE && get_energy(user) < selected.energy_cost)	//Handle energy amounts, but only if not SELF_SANE.
		return 1

	busy	= 1	//Busy to prevent switching schematic while it's in use.
	var/t	= selected.attack(A, user)
	if(!t)	//No errors
		if(selected.flags ^ RCD_SELF_COST)	//Handle energy costs unless the schematic does it itself.
			use_energy(selected.energy_cost, user)
	else
		if(istext(t))
			to_chat(user, "<span class='warning'>\the [src]'s error light flickers: [t]</span>")
		else
			to_chat(user, "<span class='warning'>\the [src]'s error light flickers.</span>")

	busy = 0

	return 1

/obj/item/device/rcd/proc/spark()
	if(sparky)
		spark_system.start()

/obj/item/device/rcd/proc/get_energy(var/mob/user)
	return INFINITY

/obj/item/device/rcd/proc/use_energy(var/amount, var/mob/user)
	return

/obj/item/device/rcd/proc/update_options_menu()
	if(selected)
		for(var/client/client in interface.clients)
			selected.send_assets(client)

		interface.updateContent("schematic_options", selected.get_HTML(args))
	else
		interface.updateContent("schematic_options", " ")

/obj/item/device/rcd/borg/attack_self(var/mob/living/user)
	if(!selected || user.shown_schematics_background || !selected.show(user))
		user.hud_used.toggle_show_schematics_display(schematics["Construction"], 0, src)

/obj/item/device/rcd/borg
	var/cell_power_per_energy = 30

/obj/item/device/rcd/borg/use_energy(var/amount, var/mob/user)
	if(!isrobot(user))
		return

	var/mob/living/silicon/robot/R = user

	if(!R.cell)
		return

	R.cell.use(amount * cell_power_per_energy)

/obj/item/device/rcd/borg/get_energy(var/mob/user)
	if(!isrobot(user))
		return 0

	var/mob/living/silicon/robot/R = user

	if(!R.cell)
		return

	return R.cell.charge / cell_power_per_energy

//Matter based RCDs.
/obj/item/device/rcd/matter
	var/matter			= 0
	var/max_matter		= 30

/obj/item/device/rcd/matter/attack_self(var/mob/living/user)
	if(!selected || user.shown_schematics_background || !selected.show(user))
		user.hud_used.toggle_show_schematics_display(schematics["Construction"], 0, src)

/obj/item/device/rcd/matter/examine(var/mob/user)
	..()
	to_chat(user, "It currently holds [matter]/[max_matter] matter-units.")

/obj/item/device/rcd/matter/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(istype(W, /obj/item/weapon/rcd_ammo))
		if((matter + 10) > max_matter)
			to_chat(user, "<span class='notice'>\the [src] can't hold any more matter-units.</span>")
			return 1

		qdel(W)
		matter += 10
		playsound(get_turf(src), 'sound/machines/click.ogg', 20, 1)
		to_chat(user, "<span class='notice'>\the [src] now holds [matter]/[max_matter] matter-units.</span>")
		return 1

	if(isscrewdriver(W))
		to_chat(user, "<span class='notice'>You unscrew the access panel and release the cartridge chamber.</span>")
		while(matter >= 10)
			new /obj/item/weapon/rcd_ammo(user.loc)
			matter -= 10

		return 1

/obj/item/device/rcd/matter/use_energy(var/amount, var/mob/user)
	matter -= amount
	to_chat(user, "<span class='notice'>\the [src] currently holds [matter]/[max_matter] matter-units.")

/obj/item/device/rcd/matter/get_energy(var/mob/user)
	return matter

/obj/item/device/rcd/proc/show_default(var/mob/living/user)
	if(selected)
		if(selected.show(user,1)) return
	user.hud_used.toggle_show_schematics_display(null, 1, src)