#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with metal, plasteel, glass or compressed matter cartridges."
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=100000)
	req_access_txt = "11"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/sheetmultiplier	= 4 //Controls the amount of matter added for each glass/metal sheet, triple for plasteel
	var/plasteelmultiplier = 3 //Plasteel is worth 3 times more than glass or metal
	var/plasmarglassmultiplier = 2 //50% less plasma than in plasteel
	var/rglassmultiplier = 1.5 //One metal sheet, half a glass sheet
	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>"
	var/has_ammobar = FALSE	//controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10	//amount of divisions in the ammo indicator overlay/number of ammo indicator states

/obj/item/construction/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/construction/examine(mob/user)
	..()
	to_chat(user, "\A [src]. It currently holds [matter]/[max_matter] matter-units." )

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	. = ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(iscyborg(user))
		return
	var/loaded = 0
	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = W
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, "<span class='warning'>[src] can't hold any more matter-units!</span>")
			return
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/metal) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, plasteelmultiplier*sheetmultiplier, user) //12 matter for 1 plasteel sheet
	else if(istype(W, /obj/item/stack/sheet/plasmarglass))
		loaded = loadwithsheets(W, plasmarglassmultiplier*sheetmultiplier, user) //8 matter for one plasma rglass sheet
	else if(istype(W, /obj/item/stack/sheet/rglass))
		loaded = loadwithsheets(W, rglassmultiplier*sheetmultiplier, user) //6 matter for one rglass sheet
	if(loaded)
		to_chat(user, "<span class='notice'>[src] now holds [matter]/[max_matter] matter-units.</span>")
	else
		return ..()
	update_icon()	//ensures that ammo counters (if present) get updated

/obj/item/construction/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='notice'>You insert [amount_to_use] [S.name] sheets into [src]. </span>")
		return 1
	to_chat(user, "<span class='warning'>You can't insert any more [S.name] sheets into [src]!</span>")
	return 0

/obj/item/construction/proc/activate()
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

/obj/item/construction/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20))
		spark_system.start()

/obj/item/construction/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	matter -= amount
	update_icon()
	return 1

/obj/item/construction/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src)	//somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(!(A in view(7, get_turf(user))))
		to_chat(user, "<span class='warning'>The \'Out of Range\' light on [src] blinks red.</span>")
		return FALSE
	else
		return TRUE

/obj/item/construction/proc/prox_check(proximity)
	if(proximity)
		return TRUE
	else
		return FALSE


/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_matter = 160
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	var/mode = 1
	var/ranged = FALSE
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them

/obj/item/construction/rcd/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide..</span>")
	return (BRUTELOSS)

/obj/item/construction/rcd/verb/toggle_window_type(mob/user)
	var/window_type_name
	if (window_type == /obj/structure/window/fulltile)
		window_type = /obj/structure/window/reinforced/fulltile
		window_type_name = "reinforced glass"
	else
		window_type = /obj/structure/window/fulltile
		window_type_name = "glass"

	to_chat(user, "<span class='notice'>You change \the [src]'s window mode to [window_type_name].</span>")

/obj/item/construction/rcd/proc/change_airlock_access(mob/user)
	if (!ishuman(user) && !user.has_unlimited_silicon_privilege)
		return

	var/t1 = ""

	if(use_one_access)
		t1 += "Restriction Type: <a href='?src=[REF(src)];access=one'>At least one access required</a><br>"
	else
		t1 += "Restriction Type: <a href='?src=[REF(src)];access=one'>All accesses required</a><br>"

	t1 += "<a href='?src=[REF(src)];access=all'>Remove All</a><br>"

	var/accesses = ""
	accesses += "<div align='center'><b>Access</b></div>"
	accesses += "<table style='width:100%'>"
	accesses += "<tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
	accesses += "</tr><tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%' valign='top'>"
		for(var/A in get_region_accesses(i))
			if(A in conf_access)
				accesses += "<a href='?src=[REF(src)];access=[A]'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
			else
				accesses += "<a href='?src=[REF(src)];access=[A]'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
			accesses += "<br>"
		accesses += "</td>"
	accesses += "</tr></table>"
	t1 += "<tt>[accesses]</tt>"

	t1 += "<p><a href='?src=[REF(src)];close=1'>Close</a></p>\n"

	var/datum/browser/popup = new(user, "rcd_access", "Access Control", 900, 500)
	popup.set_content(t1)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()
	onclose(user, "rcd_access")

/obj/item/construction/rcd/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return

	if (href_list["close"])
		usr << browse(null, "window=rcd_access")
		return

	if (href_list["access"])
		toggle_access(href_list["access"])
		change_airlock_access(usr)

/obj/item/construction/rcd/proc/toggle_access(acc)
	if (acc == "all")
		conf_access = null
	else if(acc == "one")
		use_one_access = !use_one_access
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null

/obj/item/construction/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = airlock_type
	var/ic = initial(proto.icon)
	var/mutable_appearance/MA = mutable_appearance(ic, "closed")
	if(!initial(proto.glass))
		MA.overlays += "fill_closed"
	//Not scaling these down to button size because they look horrible then, instead just bumping up radius.
	return MA

/obj/item/construction/rcd/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)	
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/glass)
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research),
		"Freezer" = get_airlock_image(/obj/machinery/door/airlock/freezer),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/hatch),
		"Maintenance Hatch" = get_airlock_image(/obj/machinery/door/airlock/maintenance_hatch)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering/glass),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical/glass),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research/glass),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science/glass),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external/glass),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external/glass)
	)

	var/airlockcat = show_radial_menu(user, src , solid_or_glass_choices, custom_check = CALLBACK(src,.proc/check_menu,user))
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , solid_choices, radius = 42, custom_check = CALLBACK(src,.proc/check_menu,user))
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Freezer")
						airlock_type = /obj/machinery/door/airlock/freezer
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/hatch
					if("Maintenance Hatch")
						airlock_type = /obj/machinery/door/airlock/maintenance_hatch
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src,.proc/check_menu,user))
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering/glass
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science/glass
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/external/glass
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/glass
				airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock
			airlock_glass = FALSE

/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	if(do_after(user, rcd_results["delay"] * delay_mod, target = A))
		if(checkResource(rcd_results["cost"], user))
			if(A.rcd_act(user, src, rcd_results["mode"]))
				useResource(rcd_results["cost"], user)
				activate()
				playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
				return TRUE

/obj/item/construction/rcd/Initialize()
	. = ..()
	GLOB.rcd_list += src

/obj/item/construction/rcd/Destroy()
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/attack_self(mob/user)
	..()
	var/list/choices = list(
		"Airlock" = image(icon = 'icons/obj/interface.dmi', icon_state = "airlock"),
		"Deconstruct" = image(icon= 'icons/obj/interface.dmi', icon_state = "delete"),
		"Grilles & Windows" = image(icon = 'icons/obj/interface.dmi', icon_state = "grillewindow"),
		"Floors & Walls" = image(icon = 'icons/obj/interface.dmi', icon_state = "wallfloor")
	)
	if(mode == RCD_AIRLOCK)
		choices += list(
		"Change Access" = image(icon = 'icons/obj/interface.dmi', icon_state = "access"),
		"Change Airlock Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "airlocktype")
		)
	else if(mode == RCD_WINDOWGRILLE)
		choices += list(
			"Change Window Type" = image(icon = 'icons/obj/interface.dmi', icon_state = "windowtype")
		)
	var/choice = show_radial_menu(user,src,choices, custom_check = CALLBACK(src,.proc/check_menu,user))
	if(!check_menu(user))
		return
	switch(choice)
		if("Floors & Walls")
			mode = RCD_FLOORWALL
		if("Airlock")
			mode = RCD_AIRLOCK
		if("Deconstruct")
			mode = RCD_DECONSTRUCT
		if("Grilles & Windows")
			mode = RCD_WINDOWGRILLE
		if("Change Access")
			change_airlock_access(user)
			return
		if("Change Airlock Type")
			change_airlock_setting(user)
			return
		if("Change Window Type")
			toggle_window_type(user)
			return
		else
			return
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	to_chat(user, "<span class='notice'>You change RCD's mode to '[choice]'.</span>")

/obj/item/construction/rcd/proc/target_check(atom/A, mob/user) // only returns true for stuff the device can actually work with
	if((isturf(A) && A.density && mode==RCD_DECONSTRUCT) || (isturf(A) && !A.density) || (istype(A, /obj/machinery/door/airlock) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/grille) || (istype(A, /obj/structure/window) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/girder))
		return TRUE
	else
		return FALSE

/obj/item/construction/rcd/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	rcd_create(A, user)

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, .proc/detonate_pulse_explode), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/construction/rcd/update_icon()
	..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		cut_overlays()	//To prevent infinite stacking of overlays
		add_overlay("[icon_state]_charge[ratio]")

/obj/item/construction/rcd/Initialize()
	. = ..()
	update_icon()

/obj/item/construction/rcd/borg
	no_ammo_message = "<span class='warning'>Insufficient charge.</span>"
	desc = "A device used to rapidly build walls and floors."
	canRturf = TRUE
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/syndicate
	icon_state = "ircd"
	item_state = "ircd"
	energyfactor = 66

/obj/item/construction/rcd/loaded
	matter = 160

/obj/item/construction/rcd/combat
	name = "industrial RCD"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	materials = list(MAT_METAL=12000, MAT_GLASS=8000)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	materials = list(MAT_METAL=48000, MAT_GLASS=32000)
	ammoamt = 160


/obj/item/construction/rcd/combat/admin
	name = "admin RCD"
	max_matter = INFINITY
	matter = INFINITY


// Ranged RCD


/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity. Reload with metal, plasteel, glass or compressed matter cartridges."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE

/obj/item/construction/rcd/arcd/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	if(target_check(A,user))
		user.Beam(A,icon_state="rped_upgrade",time=30)
	rcd_create(A,user)



// RAPID LIGHTING DEVICE



/obj/item/construction/rld
	name = "rapid-light-device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with metal, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	var/mode = LIGHT_MODE
	actions_types = list(/datum/action/item_action/pick_color)

	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	var/color_choice = null


/obj/item/construction/rld/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		color_choice = input(user,"","Choose Color",color_choice) as color
	else
		..()

/obj/item/construction/rld/update_icon()
	icon_state = "rld-[round(matter/35)]"
	..()


/obj/item/construction/rld/attack_self(mob/user)
	..()
	switch(mode)
		if(REMOVE_MODE)
			mode = LIGHT_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Permanent Light Construction'.</span>")
		if(LIGHT_MODE)
			mode = GLOW_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Light Launcher'.</span>")
		if(GLOW_MODE)
			mode = REMOVE_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Deconstruct'.</span>")


/obj/item/construction/rld/proc/checkdupes(var/target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing [A]...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user))
							return 0
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a wall light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 0)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.CanAtmosPass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, "<span class='warning'>Valid target not found...</span>")
							playsound(src.loc, 'sound/misc/compiler-failure.ogg', 30, 1)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.light_color = L.color
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a floor light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 1)
					if(do_after(user, floordelay, target = A))
						if(!istype(F))
							return 0
						if(!useResource(floorcost, user))
							return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, "<span class='notice'>You fire a glowstick!</span>")
				var/obj/item/flashlight/glowstick/G  = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE

#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
