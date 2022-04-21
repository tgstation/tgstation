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
#define REPROGRAM_MODE (1<<3)

GLOBAL_LIST_INIT(atmos_pipe_recipes, list(
	"Pipes" = list(
		new /datum/pipe_info/pipe("Pipe", /obj/machinery/atmospherics/pipe/smart, TRUE),
		new /datum/pipe_info/pipe("Layer Adapter", /obj/machinery/atmospherics/pipe/layer_manifold, TRUE),
		new /datum/pipe_info/pipe("Color Adapter", /obj/machinery/atmospherics/pipe/color_adapter, TRUE),
		new /datum/pipe_info/pipe("Bridge Pipe", /obj/machinery/atmospherics/pipe/bridge_pipe, TRUE),
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
		new /datum/pipe_info/transit("Through Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser, PIPE_STRAIGHT),
		new /datum/pipe_info/transit("Terminus Tube Dispenser Station", /obj/structure/c_transit_tube/station/dispenser/reverse, PIPE_UNARY),
		new /datum/pipe_info/transit("Transit Tube Pod", /obj/structure/c_transit_tube_pod, PIPE_ONEDIR),
	)
))

/datum/pipe_info
	var/name
	var/icon_state
	var/id = -1
	var/dirtype = PIPE_BENDABLE
	var/all_layers

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
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 100, ACID = 50)
	resistance_flags = FIRE_PROOF
	///Sparks system used when changing device in the UI
	var/datum/effect_system/spark_spread/spark_system
	///Direction of the device we are going to spawn, set up in the UI
	var/p_dir = NORTH
	///Initial direction of the smart pipe we are going to spawn, set up in the UI
	var/p_init_dir = ALL_CARDINALS
	///Is the device of the flipped type?
	var/p_flipped = FALSE
	///Color of the device we are going to spawn
	var/paint_color = "green"
	///Speed of building atmos devices
	var/atmos_build_speed = 0.5 SECONDS
	///Speed of building disposal devices
	var/disposal_build_speed = 0.5 SECONDS
	///Speed of building transit devices
	var/transit_build_speed = 0.5 SECONDS
	///Speed of removal of unwrenched devices
	var/destroy_speed = 0.5 SECONDS
	///Speed of reprogramming connectable directions of smart pipes
	var/reprogram_speed = 0.5 SECONDS
	///Category currently active (Atmos, disposal, transit)
	var/category = ATMOS_CATEGORY
	///Piping layer we are going to spawn the atmos device in
	var/piping_layer = PIPING_LAYER_DEFAULT
	///Layer for disposal ducts
	var/ducting_layer = DUCT_LAYER_DEFAULT
	///Stores the current device to spawn
	var/datum/pipe_info/recipe
	///Stores the first atmos device
	var/static/datum/pipe_info/first_atmos
	///Stores the first disposal device
	var/static/datum/pipe_info/first_disposal
	///Stores the first transit device
	var/static/datum/pipe_info/first_transit
	///The modes that are allowed for the RPD
	var/mode = BUILD_MODE | DESTROY_MODE | WRENCH_MODE | REPROGRAM_MODE
	/// Bitflags for upgrades
	var/upgrade_flags

/obj/item/pipe_dispenser/Initialize(mapload)
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
	. += "You can right click a pipe to set the RPD to its color and layer."

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

/obj/item/pipe_dispenser/pre_attack(atom/target, mob/user, params)
	if(istype(target, /obj/item/rpd_upgrade/unwrench))
		install_upgrade(target, user)
		return TRUE
	return ..()

/obj/item/pipe_dispenser/pre_attack_secondary(obj/machinery/atmospherics/target, mob/user, params)
	if(!istype(target, /obj/machinery/atmospherics))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target.pipe_color && target.piping_layer)
		paint_color = GLOB.pipe_color_name[target.pipe_color]
		piping_layer = target.piping_layer
		to_chat(user, span_notice("You change [src] to [paint_color] color and layer [piping_layer] pipes."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

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
		to_chat(user, span_warning("[src] has already installed this upgrade!"))
		return
	upgrade_flags |= rpd_up.upgrade_flags
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(rpd_up)

/obj/item/pipe_dispenser/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] points the end of the RPD down [user.p_their()] throat and presses a button! It looks like [user.p_theyre()] trying to commit suicide..."))
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

/obj/item/pipe_dispenser/ui_static_data(mob/user)
	var/list/data = list("paint_colors" = GLOB.pipe_paint_colors)
	return data

/obj/item/pipe_dispenser/ui_data(mob/user)
	var/list/data = list(
		"category" = category,
		"piping_layer" = piping_layer,
		"ducting_layer" = ducting_layer,
		"preview_rows" = recipe.get_preview(p_dir),
		"categories" = list(),
		"selected_color" = paint_color,
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

	var/list/init_directions = list("north" = FALSE, "south" = FALSE, "east" = FALSE, "west" = FALSE)
	for(var/direction in GLOB.cardinals)
		if(p_init_dir & direction)
			init_directions[dir2text(direction)] = TRUE
	data["init_directions"] = init_directions
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
			mode ^= n
		if("init_dir_setting")
			var/target_dir = p_init_dir ^ text2dir(params["dir_flag"])
			// Refuse to create a smart pipe that can only connect in one direction (it would act weirdly and lack an icon)
			if (ISNOTSTUB(target_dir))
				p_init_dir = target_dir
			else
				to_chat(usr, span_warning("\The [src]'s screen flashes a warning: Can't configure a pipe to only connect in one direction."))
				playeffect = FALSE
		if("init_reset")
			p_init_dir = ALL_CARDINALS
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
	if(istype(attack_target, /obj/machinery/atmospherics) && mode & BUILD_MODE)
		attack_target = get_turf(attack_target)
	var/can_make_pipe = (isturf(attack_target) || is_type_in_typecache(attack_target, make_pipe_whitelist))

	. = TRUE

	if((mode & DESTROY_MODE) && istype(attack_target, /obj/item/pipe) || istype(attack_target, /obj/structure/disposalconstruct) || istype(attack_target, /obj/structure/c_transit_tube) || istype(attack_target, /obj/structure/c_transit_tube_pod) || istype(attack_target, /obj/item/pipe_meter) || istype(attack_target, /obj/structure/disposalpipe/broken))
		to_chat(user, span_notice("You start destroying a pipe..."))
		playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
		if(do_after(user, destroy_speed, target = attack_target))
			activate()
			qdel(attack_target)
		return

	if(mode & REPROGRAM_MODE)
		// If this is a placed smart pipe, try to reprogram it
		var/obj/machinery/atmospherics/pipe/smart/S = attack_target
		if(istype(S))
			if (S.dir == ALL_CARDINALS)
				to_chat(user, span_warning("\The [S] has no unconnected directions!"))
				return
			var/old_init_dir = S.get_init_directions()
			if (old_init_dir == p_init_dir)
				to_chat(user, span_warning("\The [S] is already in this configuration!"))
				return
			// Check for differences in unconnected directions
			var/target_differences = (p_init_dir ^ old_init_dir) & ~S.connections
			if (!target_differences)
				to_chat(user, span_warning("\The [S] is already in this configuration for its unconnected directions!"))
				return

			to_chat(user, span_notice("You start reprogramming \the [S]..."))
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
			if(!do_after(user, reprogram_speed, target = S))
				return

			// Something else could have changed the target's state while we were waiting in do_after
			// Most of the edge cases don't matter, but atmos components being able to have live connections not described by initializable directions sounds like a headache at best and an exploit at worst

			// Double check to make sure that nothing has changed. If anything we were about to change was connected during do_after, abort
			if (target_differences & S.connections)
				to_chat(user, span_warning("\The [src]'s screen flashes a warning: Can't configure a pipe in a currently connected direction."))
				return
			// Grab the current initializable directions, which may differ from old_init_dir if someone else was working on the same pipe at the same time
			var/current_init_dir = S.get_init_directions()
			// Access p_init_dir directly. The RPD can change target layer and initializable directions (though not pipe type or dir) while working to dispense and connect a component,
			// and have it reflected in the final result. Reprogramming should be similarly consistent.
			var/new_init_dir = (current_init_dir & ~target_differences) | (p_init_dir & target_differences)
			// Don't make a smart pipe with only one connection
			if (ISSTUB(new_init_dir))
				to_chat(user, span_warning("\The [src]'s screen flashes a warning: Can't configure a pipe to only connect in one direction."))
				return
			S.set_init_directions(new_init_dir)
			// We're now reconfigured.
			// We can never disconnect from existing connections, but we can connect to previously unconnected directions, and should immediately do so
			var/newly_permitted_connections = new_init_dir & ~current_init_dir
			if(newly_permitted_connections)
				// We're allowed to connect in new directions. Recompute our nodes
				// Disconnect from everything that is currently connected
				for (var/i in 1 to S.device_type)
					// This is basically pipe.nullifyNode, but using it here would create a pitfall for others attempting to
					// copy and paste disconnection code for other components. Welcome to the atmospherics subsystem
					var/obj/machinery/atmospherics/node = S.nodes[i]
					if (!node)
						continue
					node.disconnect(S)
					S.nodes[i] = null
				// Get our new connections
				S.atmos_init()
				// Connect to our new connections
				for (var/obj/machinery/atmospherics/O in S.nodes)
					O.atmos_init()
					O.add_member(src)
				SSair.add_to_rebuild_queue(S)
			// Finally, update our internal state - update_pipe_icon also updates dir and connections
			S.update_pipe_icon()
			user.visible_message(span_notice("[user] reprograms the \the [S]."),span_notice("You reprogram \the [S]."))
			return
		// If this is an unplaced smart pipe, try to reprogram it
		var/obj/item/pipe/quaternary/I = attack_target
		if(istype(I) && ispath(I.pipe_type, /obj/machinery/atmospherics/pipe/smart))
			// An unplaced pipe never has any existing connections, so just directly assign the new configuration
			I.p_init_dir = p_init_dir
			I.update()

	if(mode & BUILD_MODE)
		switch(category) //if we've gotten this var, the target is valid
			if(ATMOS_CATEGORY) //Making pipes
				if(!can_make_pipe)
					return ..()
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if (recipe.type == /datum/pipe_info/meter)
					to_chat(user, span_notice("You start building a meter..."))
					if(do_after(user, atmos_build_speed, target = attack_target))
						activate()
						var/obj/item/pipe_meter/PM = new /obj/item/pipe_meter(get_turf(attack_target))
						PM.setAttachLayer(piping_layer)
						if(mode & WRENCH_MODE)
							PM.wrench_act(user, src)
				else
					if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))
						to_chat(user, span_notice("You can't build this object on the layer..."))
						return ..()
					to_chat(user, span_notice("You start building a pipe..."))
					if(do_after(user, atmos_build_speed, target = attack_target))
						if(recipe.all_layers == FALSE && (piping_layer == 1 || piping_layer == 5))//double check to stop cheaters (and to not waste time waiting for something that can't be placed)
							to_chat(user, span_notice("You can't build this object on the layer..."))
							return ..()
						activate()
						var/obj/machinery/atmospherics/path = queued_p_type
						var/pipe_item_type = initial(path.construction_type) || /obj/item/pipe
						var/obj/item/pipe/pipe_type = new pipe_item_type(
							get_turf(attack_target),
							queued_p_type,
							queued_p_dir,
							null,
							GLOB.pipe_paint_colors[paint_color],
							ispath(queued_p_type, /obj/machinery/atmospherics/pipe/smart) ? p_init_dir : null,
						)
						if(queued_p_flipped && istype(pipe_type, /obj/item/pipe/trinary/flippable))
							var/obj/item/pipe/trinary/flippable/F = pipe_type
							F.flipped = queued_p_flipped

						pipe_type.update()
						pipe_type.add_fingerprint(usr)
						pipe_type.set_piping_layer(piping_layer)
						if(ispath(queued_p_type, /obj/machinery/atmospherics) && !ispath(queued_p_type, /obj/machinery/atmospherics/pipe/color_adapter))
							pipe_type.add_atom_colour(GLOB.pipe_paint_colors[paint_color], FIXED_COLOUR_PRIORITY)
						if(mode & WRENCH_MODE)
							pipe_type.wrench_act(user, src)

			if(DISPOSALS_CATEGORY) //Making disposals pipes
				if(!can_make_pipe)
					return ..()
				attack_target = get_turf(attack_target)
				if(isclosedturf(attack_target))
					to_chat(user, span_warning("[src]'s error light flickers; there's something in the way!"))
					return
				to_chat(user, span_notice("You start building a disposals pipe..."))
				playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE)
				if(do_after(user, disposal_build_speed, target = attack_target))
					var/obj/structure/disposalconstruct/C = new (attack_target, queued_p_type, queued_p_dir, queued_p_flipped)

					if(!C.can_place())
						to_chat(user, span_warning("There's not enough room to build that here!"))
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
					to_chat(user, span_warning("[src]'s error light flickers; there's something in the way!"))
					return

				var/turf/target_turf = get_turf(attack_target)
				if(target_turf.is_blocked_turf(exclude_mobs = TRUE))
					to_chat(user, span_warning("[src]'s error light flickers; there's something in the way!"))
					return

				to_chat(user, span_notice("You start building a transit tube..."))
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
							tube.SimpleRotateFlip()

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
	if(source.incapacitated(IGNORE_RESTRAINTS|IGNORE_STASIS))
		return

	if(delta_y < 0)
		piping_layer = min(PIPING_LAYER_MAX, piping_layer + 1)
	else if(delta_y > 0)
		piping_layer = max(PIPING_LAYER_MIN, piping_layer - 1)
	else
		return
	SStgui.update_uis(src)
	to_chat(source, span_notice("You set the layer to [piping_layer]."))

#undef ATMOS_CATEGORY
#undef DISPOSALS_CATEGORY
#undef TRANSIT_CATEGORY

#undef BUILD_MODE
#undef DESTROY_MODE
#undef WRENCH_MODE
#undef REPROGRAM_MODE

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
