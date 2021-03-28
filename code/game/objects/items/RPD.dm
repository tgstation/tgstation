/*
CONTAINS:
RPD
*/

#define ATMOS_CATEGORY 0
#define DISPOSALS_CATEGORY 1
#define TRANSIT_CATEGORY 2

#define BUILD_MODE (1<<0)
#define WRENCH_MODE (1<<1)
#define DESTROY_MODE (1<<2)
#define PAINT_MODE (1<<3)


GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Pipe", /obj/machinery/atmospherics/pipe/simple, TRUE),
		new /datum/pipe_info/pipe("Manifold", /obj/machinery/atmospherics/pipe/manifold, TRUE),
		new /datum/pipe_info/pipe("4-Way Manifold", /obj/machinery/atmospherics/pipe/manifold4w, TRUE),
		new /datum/pipe_info/pipe("Layer Adapter", /obj/machinery/atmospherics/pipe/layer_manifold, TRUE),
		new /datum/pipe_info/pipe("Multi-Deck Adapter", /obj/machinery/atmospherics/pipe/multiz, FALSE),
	),
	"Devices" = list(
		new /datum/pipe_info/pipe("Connector", /obj/machinery/atmospherics/components/unary/portables_connector, TRUE),
		new /datum/pipe_info/pipe("Gas Pump", /obj/machinery/atmospherics/components/binary/pump, TRUE),
		new /datum/pipe_info/pipe("Volume Pump", /obj/machinery/atmospherics/components/binary/volume_pump, TRUE),
		new /datum/pipe_info/pipe("Gas Filter", /obj/machinery/atmospherics/components/trinary/filter, TRUE),
		new /datum/pipe_info/pipe("Gas Mixer", /obj/machinery/atmospherics/components/trinary/mixer, TRUE),
		new /datum/pipe_info/pipe("Passive Gate", /obj/machinery/atmospherics/components/binary/passive_gate, TRUE),
		new /datum/pipe_info/pipe("Injector", /obj/machinery/atmospherics/components/unary/outlet_injector, TRUE),
		new /datum/pipe_info/pipe("Scrubber", /obj/machinery/atmospherics/components/unary/vent_scrubber, TRUE),
		new /datum/pipe_info/pipe("Unary Vent", /obj/machinery/atmospherics/components/unary/vent_pump, TRUE),
		new /datum/pipe_info/pipe("Passive Vent", /obj/machinery/atmospherics/components/unary/passive_vent, TRUE),
		new /datum/pipe_info/pipe("Manual Valve", /obj/machinery/atmospherics/components/binary/valve, TRUE),
		new /datum/pipe_info/pipe("Digital Valve", /obj/machinery/atmospherics/components/binary/valve/digital, TRUE),
		new /datum/pipe_info/pipe("Pressure Valve", /obj/machinery/atmospherics/components/binary/pressure_valve, TRUE),
		new /datum/pipe_info/pipe("Temperature Gate", /obj/machinery/atmospherics/components/binary/temperature_gate, TRUE),
		new /datum/pipe_info/pipe("Temperature Pump", /obj/machinery/atmospherics/components/binary/temperature_pump, TRUE),
		new /datum/pipe_info/meter("Meter"),
	),
	"Heat Exchange" = list(
		new /datum/pipe_info/pipe("Pipe", /obj/machinery/atmospherics/pipe/heat_exchanging/simple, FALSE),
		new /datum/pipe_info/pipe("Manifold", /obj/machinery/atmospherics/pipe/heat_exchanging/manifold, FALSE),
		new /datum/pipe_info/pipe("4-Way Manifold", /obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w, FALSE),
		new /datum/pipe_info/pipe("Junction", /obj/machinery/atmospherics/pipe/heat_exchanging/junction, FALSE),
		new /datum/pipe_info/pipe("Heat Exchanger", /obj/machinery/atmospherics/components/unary/heat_exchanger, FALSE),
	)
))

GLOBAL_LIST_INIT(disposal_pipe_recipes, list(
	"Disposal Pipes" = list(
		new /datum/pipe_info/disposal("Pipe", /obj/structure/disposalpipe/segment, PIPE_BENDABLE),
		new /datum/pipe_info/disposal("Junction", /obj/structure/disposalpipe/junction, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Y-Junction", /obj/structure/disposalpipe/junction/yjunction),
		new /datum/pipe_info/disposal("Sort Junction", /obj/structure/disposalpipe/sorting/mail, PIPE_TRIN_M),
		new /datum/pipe_info/disposal("Trunk", /obj/structure/disposalpipe/trunk),
		new /datum/pipe_info/disposal("Bin", /obj/machinery/disposal/bin, PIPE_ONEDIR),
		new /datum/pipe_info/disposal("Outlet", /obj/structure/disposaloutlet),
		new /datum/pipe_info/disposal("Chute", /obj/machinery/disposal/delivery_chute),
	)
))

GLOBAL_LIST_INIT(transit_tube_recipes, list(
	"Transit Tubes" = list(
		new /datum/pipe_info/transit("Straight Tube", /obj/structure/c_transit_tube, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Straight Tube with Crossing", /obj/structure/c_transit_tube/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Curved Tube", /obj/structure/c_transit_tube/curved, PIPE_UNARY_FLIPPABLE),
		new /datum/pipe_info/transit("Diagonal Tube", /obj/structure/c_transit_tube/diagonal, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Diagonal Tube with Crossing", /obj/structure/c_transit_tube/diagonal/crossing, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Junction", /obj/structure/c_transit_tube/junction, PIPE_UNARY_FLIPPABLE),
	),
	"Station Equipment" = list(
		new /datum/pipe_info/transit("Through Tube Station", /obj/structure/c_transit_tube/station, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Station", /obj/structure/c_transit_tube/station/reverse, PIPE_UNARY),
		new /datum/pipe_info/transit("Transit Tube Pod", /obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))

/datum/pipe_info
	var/name
	var/icon_state
	var/id = -1
	var/dirtype = PIPE_BENDABLE
	var/all_layers

/datum/pipe_info/proc/Render(dispenser)
	var/dat = "<li><a href='?src=[REF(dispenser)]&[Params()]'>[name]</a></li>"

	// Stationary pipe dispensers don't allow you to pre-select pipe directions.
	// This makes it impossble to spawn bent versions of bendable pipes.
	// We add a "Bent" pipe type with a preset diagonal direction to work around it.
	if(istype(dispenser, /obj/machinery/pipedispenser) && (dirtype == PIPE_BENDABLE || dirtype == /obj/item/pipe/binary/bendable))
		dat += "<li><a href='?src=[REF(dispenser)]&[Params()]&dir=[NORTHEAST]'>Bent [name]</a></li>"

	return dat

/datum/pipe_info/proc/Params()
	return ""

/datum/pipe_info/proc/get_preview(selected_dir)
	var/list/dirs
	switch(dirtype)
		if(PIPE_STRAIGHT, PIPE_BENDABLE)
			dirs = list("[NORTH]" = "Vertical", "[EAST]" = "Horizontal")
			if(dirtype == PIPE_BENDABLE)
				dirs += list("[NORTHWEST]" = "West to North", "[NORTHEAST]" = "North to East",
							"[SOUTHWEST]" = "South to West", "[SOUTHEAST]" = "East to South")
		if(PIPE_TRINARY)
			dirs = list("[NORTH]" = "West South East", "[SOUTH]" = "East North West",
						"[EAST]" = "North West South", "[WEST]" = "South East North")
		if(PIPE_TRIN_M)
			dirs = list("[NORTH]" = "North East South", "[SOUTHWEST]" = "North West South",
						"[NORTHEAST]" = "South East North", "[SOUTH]" = "South West North",
						"[WEST]" = "West North East", "[SOUTHEAST]" = "West South East",
						"[NORTHWEST]" = "East North West", "[EAST]" = "East South West",)
		if(PIPE_UNARY)
			dirs = list("[NORTH]" = "North", "[SOUTH]" = "South", "[WEST]" = "West", "[EAST]" = "East")
		if(PIPE_ONEDIR)
			dirs = list("[SOUTH]" = name)
		if(PIPE_UNARY_FLIPPABLE)
			dirs = list("[NORTH]" = "North", "[EAST]" = "East", "[SOUTH]" = "South", "[WEST]" = "West",
						"[NORTHEAST]" = "North Flipped", "[SOUTHEAST]" = "East Flipped", "[SOUTHWEST]" = "South Flipped", "[NORTHWEST]" = "West Flipped")


	var/list/rows = list()
	var/list/row = list("previews" = list())
	var/i = 0
	for(var/dir in dirs)
		var/numdir = text2num(dir)
		var/flipped = ((dirtype == PIPE_TRIN_M) || (dirtype == PIPE_UNARY_FLIPPABLE)) && (ISDIAGONALDIR(numdir))
		row["previews"] += list(list("selected" = (numdir == selected_dir), "dir" = dir2text(numdir), "dir_name" = dirs[dir], "icon_state" = icon_state, "flipped" = flipped))
		if(i++ || dirtype == PIPE_ONEDIR)
			rows += list(row)
			row = list("previews" = list())
			i = 0

	return rows

/datum/pipe_info/pipe/New(label, obj/machinery/atmospherics/path, use_five_layers)
	name = label
	id = path
	all_layers = use_five_layers
	icon_state = initial(path.pipe_state)
	var/obj/item/pipe/c = initial(path.construction_type)
	dirtype = initial(c.RPD_type)

/datum/pipe_info/pipe/Params()
	return "makepipe=[id]&type=[dirtype]"

/datum/pipe_info/meter
	icon_state = "meter"
	dirtype = PIPE_ONEDIR

/datum/pipe_info/meter/New(label)
	name = label

/datum/pipe_info/meter/Params()
	return "makemeter=[id]&type=[dirtype]"

/datum/pipe_info/disposal/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path

	icon_state = initial(path.icon_state)
	if(ispath(path, /obj/structure/disposalpipe))
		icon_state = "con[icon_state]"

	dirtype = dt

/datum/pipe_info/disposal/Params()
	return "dmake=[id]&type=[dirtype]"

/datum/pipe_info/transit/New(label, obj/path, dt=PIPE_UNARY)
	name = label
	id = path
	dirtype = dt
	icon_state = initial(path.icon_state)
	if(dt == PIPE_UNARY_FLIPPABLE)
		icon_state = "[icon_state]_preview"

/obj/item/pipe_dispenser
	name = "Rapid Pipe Dispenser (RPD)"
	desc = "A device used to rapidly pipe things."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rpd"
	worn_icon_state = "RPD"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 10
	throwforce = 10
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=75000, /datum/material/glass=37500)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/working = 0
	var/p_dir = NORTH
	var/p_flipped = FALSE
	var/paint_color = "grey"
	var/atmos_build_speed = 5 //deciseconds (500ms)
	var/disposal_build_speed = 5
	var/transit_build_speed = 5
	var/destroy_speed = 5
	var/paint_speed = 5
	var/category = ATMOS_CATEGORY
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/ducting_layer = DUCT_LAYER_DEFAULT
	var/datum/pipe_info/recipe
	var/static/datum/pipe_info/first_atmos
	var/static/datum/pipe_info/first_disposal
	var/static/datum/pipe_info/first_transit
	var/mode = BUILD_MODE | DESTROY_MODE | WRENCH_MODE
	/// Bitflags for upgrades
	var/upgrade_flags

/obj/item/pipe_dispenser/Initialize()
	. = ..()
	spark_system = new
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(!first_atmos)
		first_atmos = GLOB.atmos_pipe_recipes[GLOB.atmos_pipe_recipes[1]][1]
	if(!first_disposal)
		first_disposal = GLOB.disposal_pipe_recipes[GLOB.disposal_pipe_recipes[1]][1]
	if(!first_transit)
		first_transit = GLOB.transit_tube_recipes[GLOB.transit_tube_recipes[1]][1]

	recipe = first_atmos

/obj/item/pipe_dispenser/Destroy()
	qdel(spark_system)
	spark_system = null
	return ..()

/obj/item/pipe_dispenser/examine(mob/user)
	. = ..()
	. += "You can scroll your mouse wheel to change the piping layer."

/obj/item/pipe_dispenser/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_HANDS)
		RegisterSignal(user, COMSIG_MOUSE_SCROLL_ON, .proc/mouse_wheeled)
	else
		UnregisterSignal(user,COMSIG_MOUSE_SCROLL_ON)

/obj/item/pipe_dispenser/dropped(mob/user, silent)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/pipe_dispenser/cyborg_unequip(mob/user)
	UnregisterSignal(user, COMSIG_MOUSE_SCROLL_ON)
	return ..()

/obj/item/pipe_dispenser/attack_self(mob/user)
	ui_interact(user)

/obj/item/pipe_dispenser/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rpd_upgrade))
		install_upgrade(W, user)
		return TRUE
	return ..()

/**
 * Installs an upgrade into the RPD
 *
 * Installs an upgrade into the RPD checking if it is already installed
 * Arguments:
 * * rpd_up - RPD upgrade
 * * user - mob that use upgrade on RPD
 */
/obj/item/pipe_dispenser/proc/install_upgrade(obj/item/rpd_upgrade/rpd_up, mob/user)
	if(rpd_up.upgrade_flags& upgrade_flags)
		to_chat(user, "<span class='warning'>[src] has already installed this upgrade!</span>")
		return
	upgrade_flags |= rpd_up.upgrade_flags
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(rpd_up)

/obj/item/pipe_dispenser/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] points the end of the RPD down [user.p_their()] throat and presses a button! It looks like [user.p_theyre()] trying to commit suicide...</span>")
	playsound(get_turf(user), 'sound/machines/click.ogg', 50, TRUE)
	playsound(get_turf(user), 'sound/items/deconstruct.ogg', 50, TRUE)
	return(BRUTELOSS)

/obj/item/pipe_dispenser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/pipes),
	)

/obj/item/pipe_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RapidPipeDispenser", name)
		ui.open()

/obj/item/pipe_dispenser/ui_data(mob/user)
	var/list/data = list(
		"category" = category,
		"piping_layer" = piping_layer,
		"ducting_layer" = ducting_layer,
		"preview_rows" = recipe.get_preview(p_dir),
		"categories" = list(),
		"selected_color" = paint_color,
		"paint_colors" = GLOB.pipe_paint_colors,
		"mode" = mode
	)

	var/list/recipes
	switch(category)
		if(ATMOS_CATEGORY)
			recipes = GLOB.atmos_pipe_recipes
		if(DISPOSALS_CATEGORY)
			recipes = GLOB.disposal_pipe_recipes
		if(TRANSIT_CATEGORY)
			recipes = GLOB.transit_tube_recipes
	for(var/c in recipes)
		var/list/cat = recipes[c]
		var/list/r = list()
		for(var/i in 1 to cat.len)
			var/datum/pipe_info/info = cat[i]
			r += list(list("pipe_name" = info.name, "pipe_index" = i, "selected" = (info == recipe), "all_layers" = info.all_layers))
		data["categories"] += list(list("cat_name" = c, "recipes" = r))

	return data

/obj/item/pipe_dispenser/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!usr.canUseTopic(src, BE_CLOSE))
		return
	var/playeffect = TRUE
	switch(action)
		if("color")
			paint_color = params["paint_color"]
		if("category")
			category = text2num(params["category"])
			switch(category)
				if(DISPOSALS_CATEGORY)
					recipe = first_disposal
				if(ATMOS_CATEGORY)
					recipe = first_atmos
				if(TRANSIT_CATEGORY)
					recipe = first_transit
			p_dir = NORTH
			playeffect = FALSE
		if("piping_layer")
			piping_layer = text2num(params["piping_layer"])
			playeffect = FALSE
		if("ducting_layer")
			ducting_layer = text2num(params["ducting_layer"])
			playeffect = FALSE
		if("pipe_type")
			var/static/list/recipes
			if(!recipes)
				recipes = GLOB.disposal_pipe_recipes + GLOB.atmos_pipe_recipes + GLOB.transit_tube_recipes
			recipe = recipes[params["category"]][text2num(params["pipe_type"])]
			p_dir = NORTH
		if("setdir")
			p_dir = text2dir(params["dir"])
			p_flipped = text2num(params["flipped"])
			playeffect = FALSE
		if("mode")
			var/n = text2num(params["mode"])
			if(mode & n)
				mode &= ~n
			else
				mode |= n
	if(playeffect)
		spark_system.start()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 50, FALSE)
	return TRUE

/obj/item/pipe_dispenser/pre_attack(atom/A, mob/user)
	if(!ISADVANCEDTOOLUSER(user) || istype(A, /turf/open/space/transit))
		return ..()

	var/atom/attack_target = A

	//So that changing the menu settings doesn't affect the pipes already being built.
	var/queued_p_type = recipe.id
	var/queued_p_dir = p_dir
	var/queued_p_flipped = p_flipped

	//Unwrench pipe before we build one over/paint it, but only if we're not already running a do_after on it already to prevent a potential runtime.
	if((mode & DESTROY_MODE) && (upgrade_flags & RPD_UPGRADE_UNWRENCH) && istype(attack_target, /obj/machinery/atmospherics) && !(DOING_INTERACTION_WITH_TARGET(user, attack_target)))
		attack_target = attack_target.wrench_act(user, src)
		if(!isatom(attack_target))
			CRASH("When attempting to call [A.type].wrench_act(), received the following non-atom return value: [attack_target]")

	//make sure what we're clicking is valid for the current category
	var/static/list/make_pipe_whitelist
	if(!make_pipe_whitelist)
		make_pipe_whitelist = typecacheof(list(/obj/structure/lattice, /obj/structure/girder, /obj/item/pipe, /obj/structure/window, /obj/structure/grille))
	if(istype(attack_target, /obj/machinery/atmospherics) && (mode & BUILD_MODE && !(mode & PAINT_MODE))) //Reduces pixelhunt when coloring is off.
		attack_target = get_turf(attack_target)
	var/can_make_pipe = (isturf(attack_target) || is_type_in_typecache(attack_target, make_pipe_whitelist))

	. = TRUE

	if((mode & DESTROY_MODE) && istype(attack_target, /obj/item/pipe) || istype(attack_target, /obj/structure/disposalconstruct) || istype(attack_target, /obj/structure/c_transit_tube) || istype(attack_target, /obj/structure/c_transit_tube_pod) || istype(attack_target, /obj/item/pipe_meter))
		to_chat(user, "<span class='notice'>You start destroying a pipe...</span>")
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
		if(do_after(user, destroy_speed, target = attack_target))
			activate()
			qdel(attack_target)
		return

	if((mode & PAINT_MODE))
		var/obj/machinery/atmospherics/M = attack_target
		if(istype(M) && M.paintable)
			to_chat(user, "<span class='notice'>You start painting \the [M] [paint_color]...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
			if(do_after(user, paint_speed, target = M))
				M.paint(GLOB.pipe_paint_colors[paint_color]) //paint the pipe
				user.visible_message("<span class='notice'>[user] paints \the [M] [paint_color].</span>","<span class='notice'>You paint \the [M] [paint_color].</span>")
			return
		var/obj/item/pipe/I = attack_target
		if(istype(I) && I.paintable)
			to_chat(user, "<span class='notice'>You start painting \the [I] [paint_color]...</span>")
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
			if(do_after(user, paint_speed, target = I))
				I.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY) //paint the pipe
				user.visible_message("<span class='notice'>[user] paints \the [I] [paint_color].</span>","<span class='notice'>You paint \the [I] [paint_color].</span>")
			return

	if(mode & BUILD_MODE)
		switch(category) //if we've gotten this var, the target is valid
			if(ATMOS_CATEGORY) //Making pipes
				if(!can_make_pipe)
					return ..()
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if (recipe.type == /datum/pipe_info/meter)
					to_chat(user, "<span class='notice'>You start building a meter...</span>")
					if(do_after(user, atmos_build_speed, target = attack_target))
						activate()
						var/obj/item/pipe_meter/PM = new /obj/item/pipe_meter(get_turf(attack_target))
						PM.setAttachLayer(piping_layer)
						if(mode & WRENCH_MODE)
							PM.wrench_act(user, src)
				else
					if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))
						to_chat(user, "<span class='notice'>You can't build this object on the layer...</span>")
						return ..()
					to_chat(user, "<span class='notice'>You start building a pipe...</span>")
					if(do_after(user, atmos_build_speed, target = attack_target))
						if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))//double check to stop cheaters (and to not waste time waiting for something that can't be placed)
							to_chat(user, "<span class='notice'>You can't build this object on the layer...</span>")
							return ..()
						activate()
						var/obj/machinery/atmospherics/path = queued_p_type
						var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
						var/obj/item/pipe/P = new pipe_item_type(get_turf(attack_target), queued_p_type, queued_p_dir)

						if(queued_p_flipped && istype(P, /obj/item/pipe/trinary/flippable))
							var/obj/item/pipe/trinary/flippable/F = P
							F.flipped = queued_p_flipped

						P.update()
						P.add_fingerprint(usr)
						P.setPipingLayer(piping_layer)
						if(findtext("[queued_p_type]", "/obj/machinery/atmospherics/pipe") && !findtext("[queued_p_type]", "layer_manifold"))
							P.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
						if(mode & WRENCH_MODE)
							P.wrench_act(user, src)

			if(DISPOSALS_CATEGORY) //Making disposals pipes
				if(!can_make_pipe)
					return ..()
				attack_target = get_turf(attack_target)
				if(isclosedturf(attack_target))
					to_chat(user, "<span class='warning'>[src]'s error light flickers; there's something in the way!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a disposals pipe...</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if(do_after(user, disposal_build_speed, target = attack_target))
					var/obj/structure/disposalconstruct/C = new (attack_target, queued_p_type, queued_p_dir, queued_p_flipped)

					if(!C.can_place())
						to_chat(user, "<span class='warning'>There's not enough room to build that here!</span>")
						qdel(C)
						return

					activate()

					C.add_fingerprint(usr)
					C.update_appearance()
					if(mode & WRENCH_MODE)
						C.wrench_act(user, src)
					return

			if(TRANSIT_CATEGORY) //Making transit tubes
				if(!can_make_pipe)
					return ..()
				attack_target = get_turf(attack_target)
				if(isclosedturf(attack_target))
					to_chat(user, "<span class='warning'>[src]'s error light flickers; there's something in the way!</span>")
					return
				to_chat(user, "<span class='notice'>You start building a transit tube...</span>")
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if(do_after(user, transit_build_speed, target = attack_target))
					activate()
					if(queued_p_type == /obj/structure/c_transit_tube_pod)
						var/obj/structure/c_transit_tube_pod/pod = new /obj/structure/c_transit_tube_pod(attack_target)
						pod.add_fingerprint(usr)
						if(mode & WRENCH_MODE)
							pod.wrench_act(user, src)

					else
						var/obj/structure/c_transit_tube/tube = new queued_p_type(attack_target)
						tube.setDir(queued_p_dir)

						if(queued_p_flipped)
							tube.setDir(turn(queued_p_dir, 45))
							tube.simple_rotate_flip()

						tube.add_fingerprint(usr)
						if(mode & WRENCH_MODE)
							tube.wrench_act(user, src)
					return
			else
				return ..()

/obj/item/pipe_dispenser/proc/activate()
	playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, TRUE)

/obj/item/pipe_dispenser/proc/mouse_wheeled(mob/source, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	if(source.incapacitated(ignore_restraints = TRUE, ignore_stasis = TRUE))
		return

	if(delta_y > 0)
		piping_layer = min(PIPING_LAYER_MAX, piping_layer + 1)
	else if(delta_y < 0)
		piping_layer = max(PIPING_LAYER_MIN, piping_layer - 1)
	else
		return
	to_chat(source, "<span class='notice'>You set the layer to [piping_layer].</span>")

#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY

#undef BUILD_MODE
#undef DESTROY_MODE
#undef PAINT_MODE
#undef WRENCH_MODE

/obj/item/rpd_upgrade
	name = "RPD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	/// Bitflags for upgrades
	var/upgrade_flags

/obj/item/rpd_upgrade/unwrench
	desc = "Adds reverse wrench mode to the RPD. Attention, due to budget cuts, the mode is hard linked to the destroy mode control button."
	upgrade_flags = RPD_UPGRADE_UNWRENCH
