// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire connection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto

///Cap for how fast cells charge, as a percentage per second (.01 means cellcharge is capped to 1% per second)
#define CHARGELEVEL 0.01
///Charge percentage at which the lights channel stops working
#define APC_CHANNEL_LIGHT_TRESHOLD 15
///Charge percentage at which the equipment channel stops working
#define APC_CHANNEL_EQUIP_TRESHOLD 30
///Charge percentage at which the APC icon indicates discharging
#define APC_CHANNEL_ALARM_TRESHOLD 75

/obj/machinery/power/apc
	name = "area power controller"
	desc = "A control terminal for the area's electrical systems."
	icon = 'icons/obj/machines/wallmounts.dmi'
	icon_state = "apc0"
	use_power = NO_POWER_USE
	req_access = null
	max_integrity = 200
	integrity_failure = 0.25
	damage_deflection = 10
	resistance_flags = FIRE_PROOF
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON
	interaction_flags_click = ALLOW_SILICON_REACH
	processing_flags = START_PROCESSING_MANUALLY

	///Range of the light emitted when on
	var/light_on_range = 1.5
	///Reference to our area
	var/area/area
	///Mapper helper to tie an apc to another area
	var/areastring = null
	///Reference to our internal cell
	var/obj/item/stock_parts/power_store/cell
	///Initial cell charge %
	var/start_charge = 90
	///Type of cell we start with
	var/cell_type = /obj/item/stock_parts/power_store/battery/upgraded //Base cell has 2500 capacity. Enter the path of a different cell you want to use. cell determines charge rates, max capacity, ect. These can also be changed with other APC vars, but isn't recommended to minimize the risk of accidental usage of dirty editted APCs
	///State of the cover (closed, opened, removed)
	var/opened = APC_COVER_CLOSED
	///Is the APC shorted and not working?
	var/shorted = FALSE
	///State of the lighting channel (off, auto off, on, auto on)
	var/lighting = APC_CHANNEL_AUTO_ON
	///State of the equipment channel (off, auto off, on, auto on)
	var/equipment = APC_CHANNEL_AUTO_ON
	///State of the environmental channel (off, auto off, on, auto on)
	var/environ = APC_CHANNEL_AUTO_ON
	///Is the apc working
	var/operating = TRUE
	///State of the apc charging (not charging, charging, fully charged)
	var/charging = APC_NOT_CHARGING
	///Previous state of charging, to detect the change
	var/last_charging
	///Can the APC charge?
	var/chargemode = TRUE
	///Is the apc interface locked?
	var/locked = TRUE
	///Is the apc cover locked?
	var/coverlocked = TRUE
	///Is the AI locked from using the APC
	var/aidisabled = FALSE
	///Reference to our cable terminal
	var/obj/machinery/power/terminal/terminal = null
	///Amount of power used by the lighting channel
	var/lastused_light = 0
	///Amount of power used by the equipment channel
	var/lastused_equip = 0
	///Amount of power used by the environmental channel
	var/lastused_environ = 0
	///Total amount of power used by the three channels
	var/lastused_total = 0
	///Total amount of power put into the battery
	var/lastused_charge = 0
	///State of the apc external power (no power, low power, has power)
	var/main_status = APC_NO_POWER
	powernet = FALSE // set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	///Is the apc hacked by a malf ai?
	var/malfhack = FALSE //New var for my changes to AI malf. --NeoFite
	///Reference to our ai hacker
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	///Counter for displaying the hacked overlay to mobs within view
	var/hacked_flicker_counter = 0
	///State of the electronics inside (missing, installed, secured)
	var/has_electronics = APC_ELECTRONICS_MISSING
	///used for the Blackout malf module
	var/overload = 1
	///used for counting how many times it has been hit, used for Aliens at the moment
	var/beenhit = 0
	///Reference to the shunted ai inside
	var/mob/living/silicon/ai/occupier = null
	///Is there an AI being transferred out of us?
	var/transfer_in_progress = FALSE
	///buffer state that makes apcs not shut off channels immediately as long as theres some power left, effect visible in apcs only slowly losing power
	var/long_term_power = 10
	///Automatically name the APC after the area is in
	var/auto_name = FALSE
	///Time to allow the APC to regain some power and to turn the channels back online
	var/failure_timer = 0
	///Forces an update on the power use to ensure that the apc has enough power
	var/force_update = FALSE
	///Should the emergency lights be on?
	var/emergency_lights = FALSE
	///Should the nighshift lights be on?
	var/nightshift_lights = FALSE
	///Tracks if lights channel was set to nightshift / reduced power usage mode automatically due to low power.
	var/low_power_nightshift_lights = FALSE
	///Time when the nightshift where turned on last, to prevent spamming
	var/last_nightshift_switch = 0
	///Stores the flags for the icon state
	var/update_state = -1
	///Stores the flag for the overlays
	var/update_overlay = -1
	///Used to stop process from updating the icons too much
	var/icon_update_needed = FALSE
	///Reference to our remote control
	var/mob/remote_control_user = null
	///Represents a signel source of power alarms for this apc
	var/datum/alarm_handler/alarm_manager
	/// Offsets the object by APC_PIXEL_OFFSET (defined in apc_defines.dm) pixels in the direction we want it placed in. This allows the APC to be embedded in a wall, yet still inside an area (like mapping).
	var/offset_old
	/// Used for apc helper called cut_AI_wire to make apc's wore responsible for ai connectione mended.
	var/cut_AI_wire = FALSE
	/// Used for apc helper called unlocked to make apc unlocked.
	var/unlocked = FALSE
	/// Used for apc helper called syndicate_access to make apc's required access syndicate_access.
	var/syndicate_access = FALSE
	/// Used for apc helper called away_general_access to make apc's required access away_general_access.
	var/away_general_access = FALSE
	/// Used for apc helper called cell_5k to install 5k cell into apc.
	var/cell_5k = FALSE
	/// Used for apc helper called cell_10k to install 10k cell into apc.
	var/cell_10k = FALSE
	/// Used for apc helper called no_charge to make apc's charge at 0% meter.
	var/no_charge = FALSE
	/// Used for apc helper called full_charge to make apc's charge at 100% meter.
	var/full_charge = FALSE
	///When did the apc generate last malf ai processing time.
	COOLDOWN_DECLARE(malf_ai_pt_generation)
	armor_type = /datum/armor/power_apc

/datum/armor/power_apc
	melee = 20
	bullet = 20
	laser = 10
	energy = 100
	bomb = 30
	fire = 90
	acid = 50

/obj/machinery/power/apc/get_save_vars()
	. = ..()
	if(!auto_name)
		. -= NAMEOF(src, name)
	. += NAMEOF(src, opened)
	. += NAMEOF(src, coverlocked)
	. += NAMEOF(src, lighting)
	. += NAMEOF(src, equipment)
	. += NAMEOF(src, environ)

	. += NAMEOF(src, cell_type)
	if(cell_type)
		start_charge = cell.charge / cell.maxcharge // only used in Initialize() so direct edit is fine
		. += NAMEOF(src, start_charge)

	// TODO save the wire data but need to include states for cute wires, signalers attached to wires, etc.
	//. += NAMEOF(src, shorted)
	//. += NAMEOF(src, locked)
	return .

/obj/machinery/power/apc/Initialize(mapload, ndir)
	. = ..()
	//APCs get added to their own processing tasks for the machines subsystem.
	if (!(datum_flags & DF_ISPROCESSING))
		datum_flags |= DF_ISPROCESSING
		SSmachines.processing_apcs += src

	//Pixel offset its appearance based on its direction
	dir = ndir
	switch(dir)
		if(NORTH)
			offset_old = pixel_y
			pixel_y = APC_PIXEL_OFFSET
		if(SOUTH)
			offset_old = pixel_y
			pixel_y = -APC_PIXEL_OFFSET
		if(EAST)
			offset_old = pixel_x
			pixel_x = APC_PIXEL_OFFSET
		if(WEST)
			offset_old = pixel_x
			pixel_x = -APC_PIXEL_OFFSET

	var/image/hud_image = image(icon = 'icons/mob/huds/hud.dmi', icon_state = "apc_hacked")
	hud_image.pixel_w = pixel_x
	hud_image.pixel_z = pixel_y
	hud_list = list(
		MALF_APC_HUD = hud_image
	)

	//Assign it to its area. If mappers already assigned an area string fast load the area from it else get the current area
	var/area/our_area = get_area(loc)
	if(areastring)
		area = get_area_instance_from_text(areastring)
		if(!area)
			area = our_area
			stack_trace("Bad areastring path for [src], [areastring]")
	else if(isarea(our_area) && areastring == null)
		area = our_area
	if(area)
		if(area.apc)
			log_mapping("Duplicate APC created at [AREACOORD(src)] [area.type]. Original at [AREACOORD(area.apc)] [area.type].")
		area.apc = src

	//Initialize name & access of the apc. Name requires area to be assigned first
	if(!req_access)
		req_access = list(ACCESS_ENGINE_EQUIP)
	if(auto_name)
		name = "\improper [get_area_name(area, TRUE)] APC"

	//Initialize its electronics
	set_wires(new /datum/wires/apc(src))
	alarm_manager = new(src)
	AddElement(/datum/element/atmos_sensitive, mapload)
	// for apcs created during map load make them fully functional
	if(mapload)
		has_electronics = APC_ELECTRONICS_SECURED
		// is starting with a power cell installed, create it and set its charge level
		if(cell_type)
			cell = new cell_type(src)
			cell.charge = start_charge * cell.maxcharge / 100 // (convert percentage to actual value)
		make_terminal()
		///This is how we test to ensure that mappers use the directional subtypes of APCs, rather than use the parent and pixel-shift it themselves.
		if(abs(offset_old) != APC_PIXEL_OFFSET)
			log_mapping("APC: ([src]) at [AREACOORD(src)] with dir ([dir] | [uppertext(dir2text(dir))]) has pixel_[dir & (WEST|EAST) ? "x" : "y"] value [offset_old] - should be [dir & (SOUTH|EAST) ? "-" : ""][APC_PIXEL_OFFSET]. Use the directional/ helpers!")
	// For apcs created during the round players need to configure them from scratch
	else
		opened = APC_COVER_OPENED
		operating = FALSE
		set_machine_stat(machine_stat | MAINT)

	//Make the apc visually interactive
	register_context()
	addtimer(CALLBACK(src, PROC_REF(update)), 0.5 SECONDS)
	RegisterSignal(SSdcs, COMSIG_GLOB_GREY_TIDE, PROC_REF(grey_tide))
	update_appearance()

	var/static/list/hovering_mob_typechecks = list(
		/mob/living/silicon = list(
			SCREENTIP_CONTEXT_CTRL_LMB = "Toggle power",
			SCREENTIP_CONTEXT_ALT_LMB = "Toggle equipment power",
			SCREENTIP_CONTEXT_SHIFT_LMB = "Toggle lighting power",
			SCREENTIP_CONTEXT_CTRL_SHIFT_LMB = "Toggle environment power",
		)
	)

	AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = "Toggle interface lock")
	AddElement(/datum/element/contextual_screentip_mob_typechecks, hovering_mob_typechecks)
	find_and_hang_on_wall()

/obj/machinery/power/apc/Destroy()
	if(malfai)
		malfai.hacked_apcs -= src
		malfai = null
	disconnect_from_area()
	QDEL_NULL(alarm_manager)
	if(occupier)
		malfvacate(TRUE)
	if(cell)
		QDEL_NULL(cell)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/apc/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	disrupt_duration *= 0.1 // so, turns out, failure timer is in seconds, not deciseconds; without this, disruptions last 10 times as long as they probably should
	energy_fail(disrupt_duration)
	return TRUE

/obj/machinery/power/apc/on_set_is_operational(old_value)
	update_area_power_usage(!old_value)

/obj/machinery/power/apc/update_name(updates)
	. = ..()
	if(auto_name)
		name = "\improper [get_area_name(area, TRUE)] APC"

/obj/machinery/power/apc/proc/assign_to_area(area/target_area = get_area(src))
	if(area == target_area)
		return

	disconnect_from_area()
	area = target_area
	update_area_power_usage(TRUE)
	area.apc = src
	auto_name = TRUE

	update_appearance(UPDATE_NAME)

/obj/machinery/power/apc/proc/update_area_power_usage(state)
	//apc is non functional so force disable
	if(state && (has_electronics != APC_ELECTRONICS_SECURED || (machine_stat & (BROKEN | MAINT)) || QDELETED(cell)))
		state = FALSE

	//no change in value
	if(state == area.power_light && state == area.power_equip && state == area.power_environ)
		return

	area.power_light = state
	area.power_equip = state
	area.power_environ = state

	area.power_change()

/obj/machinery/power/apc/proc/disconnect_from_area()
	if(isnull(area))
		return

	update_area_power_usage(FALSE)
	area.apc = null
	area = null

/obj/machinery/power/apc/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == cell)
		cell = null
		charging = APC_NOT_CHARGING
		update_appearance()
		if(!QDELING(src))
			SStgui.update_uis(src)

/obj/machinery/power/apc/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		if(opened != APC_COVER_REMOVED)
			. += "The cover is broken and can probably be <i>pried</i> off with enough force."
			return
		if(terminal && has_electronics)
			. += "The cover is missing but can be replaced using a new frame."
		return
	if(opened)
		if(has_electronics && terminal)
			. += "The cover is [opened == APC_COVER_REMOVED?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"]."
		else
			. += {"It's [ !terminal ? "not" : "" ] wired up.\n
			The electronics are[!has_electronics?"n't":""] installed."}
	else
		if(machine_stat & MAINT)
			. += "The cover is closed. Something is wrong with it. It doesn't work."
		else if(malfhack)
			. += "The cover is broken. It may be hard to force it open."
		else
			. += "The cover is closed."

/obj/machinery/power/apc/atom_break(damage_flag)
	. = ..()
	if(.)
		operating = FALSE
		if(occupier)
			malfvacate(TRUE)
		update()

	if(opened != APC_COVER_REMOVED)
		opened = APC_COVER_REMOVED
		coverlocked = FALSE
		visible_message(span_warning("The APC cover is knocked down!"))
		update_appearance()

/obj/machinery/power/apc/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Apc", name)
		ui.open()

/obj/machinery/power/apc/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked,
		"failTime" = failure_timer,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"chargingPowerDisplay" = display_power(lastused_charge),
		"totalLoad" = display_power(lastused_total),
		"coverLocked" = coverlocked,
		"remoteAccess" = (user == remote_control_user),
		"siliconUser" = HAS_SILICON_ACCESS(user),
		"malfStatus" = get_malf_status(user),
		"emergencyLights" = !emergency_lights,
		"nightshiftLights" = nightshift_lights,
		"disable_nightshift_toggle" = low_power_nightshift_lights,

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = display_power(lastused_equip),
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on" = list("eqp" = 2),
					"off" = list("eqp" = 1),
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = display_power(lastused_light),
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on" = list("lgt" = 2),
					"off" = list("lgt" = 1),
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = display_power(lastused_environ),
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on" = list("env" = 2),
					"off" = list("env" = 1),
				)
			)
		)
	)
	return data

/obj/machinery/power/apc/proc/connect_remote_access(mob/remote_user)
	if(opened)
		return
	remote_control_user = remote_user
	ui_interact(remote_user)
	remote_user.log_message("remotely accessed [src].", LOG_GAME)
	say("Remote access detected.[locked ? " Interface unlocked." : ""]")
	to_chat(remote_control_user, span_danger("[icon2html(src, remote_control_user)] Connected to [src]."))
	if(locked)
		playsound(src, 'sound/machines/terminal/terminal_on.ogg', 25, FALSE)
		locked = FALSE
	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', 50, FALSE)
	update_appearance()

/**
 * Disconnects anyone using this APC via an APC control console and locks the interface.
 * arguments:
 * mute - whether the APC should announce the disconnection locally
 */
/obj/machinery/power/apc/proc/disconnect_remote_access(mute = FALSE)
	// nothing to disconnect from
	if(isnull(remote_control_user))
		return
	locked = TRUE
	to_chat(remote_control_user, span_danger("[icon2html(src, remote_control_user)] Disconnected from [src]."))
	if(!mute)
		say("Remote access canceled. Interface locked.")
		playsound(src, 'sound/machines/terminal/terminal_off.ogg', 25, FALSE)
		playsound(src, 'sound/machines/terminal/terminal_alert.ogg', 50, FALSE)
	update_appearance()
	remote_control_user = null

/obj/machinery/power/apc/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(!QDELETED(remote_control_user) && user == remote_control_user)
		. = UI_INTERACTIVE

/obj/machinery/power/apc/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user

	if(. || !can_use(user, 1) || (locked && !HAS_SILICON_ACCESS(user) && !failure_timer && action != "toggle_nightshift"))
		return
	switch(action)
		if("lock")
			if(HAS_SILICON_ACCESS(user))
				if((obj_flags & EMAGGED) || (machine_stat & (BROKEN|MAINT)) || remote_control_user)
					to_chat(user, span_warning("The APC does not respond to the command!"))
				else
					locked = !locked
					update_appearance()
					. = TRUE
		if("cover")
			coverlocked = !coverlocked
			. = TRUE
		if("breaker")
			toggle_breaker(user)
			. = TRUE
		if("toggle_nightshift")
			toggle_nightshift_lights(user)
			. = TRUE
		if("charge")
			chargemode = !chargemode
			if(!chargemode)
				charging = APC_NOT_CHARGING
				update_appearance()
			. = TRUE
		if("channel")
			if(params["eqp"])
				equipment = setsubsystem(text2num(params["eqp"]))
				update_appearance()
				update()
			else if(params["lgt"])
				lighting = setsubsystem(text2num(params["lgt"]))
				update_appearance()
				update()
			else if(params["env"])
				environ = setsubsystem(text2num(params["env"]))
				update_appearance()
				update()
			. = TRUE
		if("overload")
			if(HAS_SILICON_ACCESS(user))
				overload_lighting()
				. = TRUE
		if("hack")
			if(get_malf_status(user))
				malfhack(user)
		if("occupy")
			if(get_malf_status(user))
				malfoccupy(user)
		if("deoccupy")
			if(get_malf_status(user))
				malfvacate()
		if("reboot")
			failure_timer = 0
			force_update = FALSE
			update_appearance()
			update()
		if("emergency_lighting")
			emergency_lights = !emergency_lights
			for(var/obj/machinery/light/area_light as anything in get_lights())
				if(!initial(area_light.no_low_power)) //If there was an override set on creation, keep that override
					area_light.no_low_power = emergency_lights
					INVOKE_ASYNC(area_light, TYPE_PROC_REF(/obj/machinery/light/, update), FALSE)
				CHECK_TICK
	return TRUE

/obj/machinery/power/apc/ui_close(mob/user)
	. = ..()
	if(user == remote_control_user)
		disconnect_remote_access()

/// Returns a list of lights powered/controlled by src
/obj/machinery/power/apc/proc/get_lights()
	var/list/lights = list()
	for(var/list/zlevel_turfs as anything in area.get_zlevel_turf_lists())
		for(var/turf/area_turf as anything in zlevel_turfs)
			for(var/obj/machinery/light/found_light in area_turf)
				lights += found_light
	return lights

/**
 * APC early processing. This gets processed after any other machine on the powernet does.
 * This adds up the total static power usage for the apc's area, then draw that power usage from the grid or APC cell.
 */
/obj/machinery/power/apc/proc/early_process()
	if(!QDELETED(cell) && cell.charge < cell.maxcharge)
		last_charging = charging
		charging = APC_NOT_CHARGING
	if(isnull(area))
		return

	var/total_static_energy_usage = 0
	if(operating)
		total_static_energy_usage += APC_CHANNEL_IS_ON(lighting) * area.energy_usage[AREA_USAGE_STATIC_LIGHT]
		total_static_energy_usage += APC_CHANNEL_IS_ON(equipment) * area.energy_usage[AREA_USAGE_STATIC_EQUIP]
		total_static_energy_usage += APC_CHANNEL_IS_ON(environ) * area.energy_usage[AREA_USAGE_STATIC_ENVIRON]
	area.clear_usage()

	if(total_static_energy_usage) //Use power from static power users.
		var/grid_used = min(terminal?.surplus(), total_static_energy_usage)
		terminal?.add_load(grid_used)
		if(total_static_energy_usage > grid_used && !QDELETED(cell))
			cell.use(total_static_energy_usage - grid_used, force = TRUE)

/obj/machinery/power/apc/proc/late_process(seconds_per_tick)
	if(icon_update_needed)
		update_appearance()
	if(machine_stat & (BROKEN|MAINT))
		return
	if(!area || !area.requires_power)
		return
	if(failure_timer)
		failure_timer--
		force_update = TRUE
		return

	if(obj_flags & EMAGGED || malfai)
		hacked_flicker_counter = hacked_flicker_counter - 1
		if(hacked_flicker_counter <= 0)
			flicker_hacked_icon()
		if(COOLDOWN_FINISHED(src, malf_ai_pt_generation) && cell.use(60 KILO JOULES)>0 && malfai.malf_picker.processing_time<MALF_MAX_PP) // Over time generation of malf points for the ai controlling it, costs a bit of power
			COOLDOWN_START(src, malf_ai_pt_generation, 30 SECONDS)
			malfai.malf_picker.processing_time += 1



	//dont use any power from that channel if we shut that power channel off
	if(operating)
		lastused_light = APC_CHANNEL_IS_ON(lighting) ? area.energy_usage[AREA_USAGE_LIGHT] + area.energy_usage[AREA_USAGE_STATIC_LIGHT] : 0
		lastused_equip = APC_CHANNEL_IS_ON(equipment) ? area.energy_usage[AREA_USAGE_EQUIP] + area.energy_usage[AREA_USAGE_STATIC_EQUIP] : 0
		lastused_environ = APC_CHANNEL_IS_ON(environ) ? area.energy_usage[AREA_USAGE_ENVIRON] + area.energy_usage[AREA_USAGE_STATIC_ENVIRON] : 0
	else
		lastused_light = 0
		lastused_equip = 0
		lastused_environ = 0

	lastused_charge = charging == APC_CHARGING ? area.energy_usage[AREA_USAGE_APC_CHARGE] : 0

	lastused_total = lastused_light + lastused_equip + lastused_environ + lastused_charge

	//store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/excess = surplus()

	if(!avail())
		main_status = APC_NO_POWER
	else if(excess <= 0)
		main_status = APC_LOW_POWER
	else
		main_status = APC_HAS_POWER

	if(cell && !shorted) //need to check to make sure the cell is still there since rigged/corrupted cells can randomly explode after give().
		// set channels depending on how much charge we have left
		if(cell.charge <= 0) // zero charge, turn all off
			equipment = autoset(equipment, AUTOSET_FORCE_OFF)
			lighting = autoset(lighting, AUTOSET_FORCE_OFF)
			environ = autoset(environ, AUTOSET_FORCE_OFF)
			alarm_manager.send_alarm(ALARM_POWER)
			if(!nightshift_lights || (nightshift_lights && !low_power_nightshift_lights))
				low_power_nightshift_lights = TRUE
				INVOKE_ASYNC(src, PROC_REF(set_nightshift), TRUE)
		else if(cell.percent() < APC_CHANNEL_LIGHT_TRESHOLD) // turn off lighting & equipment
			equipment = autoset(equipment, AUTOSET_OFF)
			lighting = autoset(lighting, AUTOSET_OFF)
			environ = autoset(environ, AUTOSET_ON)
			alarm_manager.send_alarm(ALARM_POWER)
			if(!nightshift_lights || (nightshift_lights && !low_power_nightshift_lights))
				low_power_nightshift_lights = TRUE
				INVOKE_ASYNC(src, PROC_REF(set_nightshift), TRUE)
		else if(cell.percent() < APC_CHANNEL_EQUIP_TRESHOLD) // turn off equipment
			equipment = autoset(equipment, AUTOSET_OFF)
			lighting = autoset(lighting, AUTOSET_ON)
			environ = autoset(environ, AUTOSET_ON)
			alarm_manager.send_alarm(ALARM_POWER)
			if(!nightshift_lights || (nightshift_lights && !low_power_nightshift_lights))
				low_power_nightshift_lights = TRUE
				INVOKE_ASYNC(src, PROC_REF(set_nightshift), TRUE)
		else // otherwise all can be on
			equipment = autoset(equipment, AUTOSET_ON)
			lighting = autoset(lighting, AUTOSET_ON)
			environ = autoset(environ, AUTOSET_ON)
			if(nightshift_lights && low_power_nightshift_lights)
				low_power_nightshift_lights = FALSE
				if(!SSnightshift.nightshift_active)
					INVOKE_ASYNC(src, PROC_REF(set_nightshift), FALSE)
			if(cell.percent() > APC_CHANNEL_ALARM_TRESHOLD)
				alarm_manager.clear_alarm(ALARM_POWER)

	else // no cell, switch everything off
		charging = APC_NOT_CHARGING
		equipment = autoset(equipment, AUTOSET_FORCE_OFF)
		lighting = autoset(lighting, AUTOSET_FORCE_OFF)
		environ = autoset(environ, AUTOSET_FORCE_OFF)
		alarm_manager.send_alarm(ALARM_POWER)

	// update icon & area power if anything changed
	if(last_lt != lighting || last_eq != equipment || last_en != environ || force_update)
		force_update = FALSE
		queue_icon_update()
		update()
	else if(charging != last_charging)
		queue_icon_update()

// charge until the battery is full or to the treshold of the provided channel
/obj/machinery/power/apc/proc/charge_channel(channel = null, seconds_per_tick)
	if(!cell || shorted || !operating || !chargemode || !surplus() || !cell.used_charge())
		return

	// no overcharge past the next treshold
	var/need_charge_for_channel
	switch(channel)
		if(SSMACHINES_APCS_ENVIRONMENT)
			need_charge_for_channel = (cell.maxcharge * 0.05) - cell.charge
		if(SSMACHINES_APCS_LIGHTS)
			need_charge_for_channel = (cell.maxcharge * (APC_CHANNEL_LIGHT_TRESHOLD + 5) * 0.01) - cell.charge
		if(SSMACHINES_APCS_EQUIPMENT)
			need_charge_for_channel = (cell.maxcharge * (APC_CHANNEL_EQUIP_TRESHOLD + 5) * 0.01) - cell.charge
		else
			need_charge_for_channel = cell.used_charge()

	var/charging_used = area ? area.energy_usage[AREA_USAGE_APC_CHARGE] : 0
	var/remaining_charge_rate = min(cell.chargerate, cell.maxcharge * CHARGELEVEL) - charging_used
	var/need_charge = min(need_charge_for_channel, remaining_charge_rate) * seconds_per_tick
	//check if we can charge the battery
	if(need_charge < 0)
		return

	charge_cell(need_charge, cell = cell, grid_only = TRUE, channel = AREA_USAGE_APC_CHARGE)

	// show cell as fully charged if so
	if(cell.charge >= cell.maxcharge)
		cell.charge = cell.maxcharge
		charging = APC_FULLY_CHARGED
	else
		charging = APC_CHARGING

/obj/machinery/power/apc/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			locked = TRUE
		if(WIRE_POWER1, WIRE_POWER2)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				shorted = FALSE
		if(WIRE_AI)
			if(!wires.is_cut(WIRE_AI))
				aidisabled = FALSE
		if(APC_RESET_EMP)
			equipment = APC_CHANNEL_AUTO_ON
			environ = APC_CHANNEL_AUTO_ON
			update_appearance()
			update()

// overload all the lights in this APC area
/obj/machinery/power/apc/proc/overload_lighting()
	if(!operating || shorted)
		return
	if(cell && cell.use(0.02 * STANDARD_BATTERY_CHARGE))
		INVOKE_ASYNC(src, PROC_REF(break_lights))

/obj/machinery/power/apc/proc/break_lights()
	for(var/obj/machinery/light/breaked_light as anything in get_lights())
		breaked_light.on = TRUE
		breaked_light.break_light_tube()
		CHECK_TICK

/obj/machinery/power/apc/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return (exposed_temperature > 2000)

/obj/machinery/power/apc/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(min(exposed_temperature/100, 10), BURN)

/obj/machinery/power/apc/proc/report()
	return "[area.name] : [equipment]/[lighting]/[environ] ([lastused_total]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/grey_tide(datum/source, list/grey_tide_areas)
	SIGNAL_HANDLER

	if(!is_station_level(z))
		return

	for(var/area_type in grey_tide_areas)
		if(!istype(get_area(src), area_type))
			continue
		lighting = APC_CHANNEL_OFF //Escape (or sneak in) under the cover of darkness
		update_appearance(UPDATE_ICON)
		update()

///Used for cell_5k apc helper, which installs 5k cell into apc.
/obj/machinery/power/apc/proc/install_cell_5k()
	cell_type = /obj/item/stock_parts/power_store/battery/upgraded
	cell = new cell_type(src)

/// Used for cell_10k apc helper, which installs 10k cell into apc.
/obj/machinery/power/apc/proc/install_cell_10k()
	cell_type = /obj/item/stock_parts/power_store/battery/high
	cell = new cell_type(src)

/// Used for unlocked apc helper, which unlocks the apc.
/obj/machinery/power/apc/proc/unlock()
	locked = FALSE

/// Used for syndicate_access apc helper, which sets apc's required access to syndicate_access.
/obj/machinery/power/apc/proc/give_syndicate_access()
	req_access = list(ACCESS_SYNDICATE)

///Used for away_general_access apc helper, which set apc's required access to away_general_access.
/obj/machinery/power/apc/proc/give_away_general_access()
	req_access = list(ACCESS_AWAY_GENERAL)

/// Used for no_charge apc helper, which sets apc charge to 0%.
/obj/machinery/power/apc/proc/set_no_charge()
	cell.charge = 0

/// Used for full_charge apc helper, which sets apc charge to 100%.
/obj/machinery/power/apc/proc/set_full_charge()
	cell.charge = cell.maxcharge

/// Returns the cell's current charge.
/obj/machinery/power/apc/proc/charge()
	return cell.charge

/*Power module, used for APC construction*/
/obj/item/electronics/apc
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/// Returns the amount of time it will take the APC at its current trickle charge rate to reach a charge level. If the APC is functionally not charging, returns null.
/obj/machinery/power/apc/proc/time_to_charge(joules)
	var/required_joules = joules - charge()
	var/trickle_charge_power = energy_to_power(area.energy_usage[AREA_USAGE_APC_CHARGE])
	if(trickle_charge_power >= 1 KILO WATTS) // require at least a bit of charging
		return round(energy_to_power(required_joules / trickle_charge_power) * SSmachines.wait + SSmachines.wait, SSmachines.wait)

	return null

#undef CHARGELEVEL
#undef APC_CHANNEL_LIGHT_TRESHOLD
#undef APC_CHANNEL_EQUIP_TRESHOLD
#undef APC_CHANNEL_ALARM_TRESHOLD
