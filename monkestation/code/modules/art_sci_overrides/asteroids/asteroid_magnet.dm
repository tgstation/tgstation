#define STATUS_OKAY "OK"
#define MAX_COLLISIONS_BEFORE_ABORT 10

/obj/machinery/asteroid_magnet
	name = "asteroid magnet computer"
	icon_state = "blackbox"
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

	/// Templates available to succ in
	var/list/datum/mining_template/available_templates
	/// All templates in the "map".
	var/list/datum/mining_template/templates_on_map
	/// The map that stores asteroids
	var/datum/cartesian_plane/map
	/// The currently selected template
	var/datum/mining_template/selected_template

	/// Center turf X, set in mapping
	VAR_PRIVATE/center_x = 0
	/// Center turf Y, set in mapping
	VAR_PRIVATE/center_y = 0
	/// The center turf
	VAR_PRIVATE/turf/center_turf
	/// The size (chebyshev) of the available area, set in mapping
	var/area_size = 0

	var/coords_x = 0
	var/coords_y = 0

	var/ping_result = "N/A<div style='visibility: hidden;'>...</div>"

	/// Status of the user interface
	var/status = STATUS_OKAY

/obj/machinery/asteroid_magnet/Initialize(mapload)
	. = ..()
	if(mapload)
		SSmaterials.InitializeTemplates()
		if(!center_x || !center_y)
			stack_trace("Asteroid magnet does not have X or Y coordinates, deleting.")
			return INITIALIZE_HINT_QDEL

		if(!area_size)
			stack_trace("Asteroid magnet does not have a valid size, deleting.")
			return INITIALIZE_HINT_QDEL

	center_turf = locate(center_x, center_y, z)
	available_templates = list()
	templates_on_map = list()

	GenerateMap()

/obj/machinery/asteroid_magnet/Topic(href, href_list)
	. = ..()
	if(.)
		return

	var/list/map_offsets = map.return_offsets()
	var/list/map_bounds = map.return_bounds()
	var/value = text2num(href_list["x"] || href_list["y"])
	if(!isnull(value)) // round(null) = 0
		value = round(value, 1)
		if("x" in href_list)
			coords_x = WRAP(coords_x + map_offsets[1] + value, map_bounds[1] + map_offsets[1], map_bounds[2] + map_offsets[1])
			coords_x -= map_offsets[1]
			updateUsrDialog()

		else if("y" in href_list)
			coords_y = WRAP(coords_y + map_offsets[2] + value, map_bounds[3] + map_offsets[2], map_bounds[4] + map_offsets[2])
			coords_y -= map_offsets[2]
			updateUsrDialog()
		return

	if(href_list["ping"])
		ping(coords_x, coords_y)
		updateUsrDialog()
		return

	if(href_list["select"])
		var/datum/mining_template/T = locate(href_list["select"]) in available_templates
		if(!T)
			return
		selected_template = T
		updateUsrDialog()
		return

	if(href_list["summon_selected"])
		summon_sequence()
		return

/obj/machinery/asteroid_magnet/ui_interact(mob/user, datum/tgui/ui)
	var/content = list()

	content += {"
	<div style='width: 100%; display: flex; flex-wrap: wrap; justify-content: center; align-items: stretch;'>
	<fieldset class='computerPane' style='margin-right: 2em; display: inline-block; min-width: 45%;'>
		<legend class='computerLegend'>
			<b>Magnet Controls</b>
		</legend>
	"}

	// X selector
	content += {"
		<fieldset class='computerPaneNested'>
			<legend class='computerLegend' style='margin: auto'>
				<b>X-Axis</b>
			</legend>
			<div style='display: flex; justify-content: center; gap: 5px'>
				<div style='display: inline-block'>[button_element(src, "-100", "x=-100")]</div>
				<div style='display: inline-block'>[button_element(src, "-10", "x=-10")]</div>
				<div style='display: inline-block'>[button_element(src, "-1", "x=-1")]</div>
				<div style='display: inline-block; padding: 0.5em'>
					<span class='computerLegend'>[coords_x]</span>
				</div>
				<div style='display: inline-block'>[button_element(src, "1", "x=1")]</div>
				<div style='display: inline-block'>[button_element(src, "10", "x=10")]</div>
				<div style='display: inline-block'>[button_element(src, "100", "x=100")]</div>
				<span style='visibility: hidden'>---</span>
			</div>
		</fieldset>
	"}

	// Y selector
	content += {"
		<fieldset class='computerPaneNested'>
			<legend class='computerLegend' style='margin: auto'>
				<b>Y-Axis</b>
			</legend>
			<div style='display: flex; justify-content: center'>
				<div style='display: inline-block'>[button_element(src, "-100", "y=-100")]</div>
				<div style='display: inline-block'>[button_element(src, "-10", "y=-10")]</div>
				<div style='display: inline-block'>[button_element(src, "-1", "y=-1")]</div>
				<div style='display: inline-block; padding: 0.5em'>
					<span class='computerLegend'>[coords_y]</span>
				</div>
				<div style='display: inline-block'>[button_element(src, "1", "y=1")]</div>
				<div style='display: inline-block'>[button_element(src, "10", "y=10")]</div>
				<div style='display: inline-block'>[button_element(src, "100", "y=100")]</div>
				<span style='visibility: hidden'>---</span>
			</div>
		</fieldset>
	"}

	// Ping button
	content += {"
		<fieldset class='computerPaneNested'>
			<legend class='computerLegend' style='margin: auto;'>
				<b>Ping</b>
			</legend>
			<div class='computerLegend' style='margin: auto; width:30%;'>
				[ping_result]
			</div>
			<div style='margin: auto; width: 10%'>
				[button_element(src, "PING", "ping=1")]
			</div>
		</fieldset>
	"}

	// Summoner
	content += {"
		<fieldset class='computerPaneNested'>
			<legend class='computerLegend' style='margin: auto;'>
				<b>Summon</b>
			</legend>
			<div class='computerLegend' style='margin: auto; width:30%'>
				[status]
			</div>
			<div style='margin: auto; width: 16.5%'>
				[button_element(src, "SUMMON", "summon_selected=1")]
			</div>
		</fieldset>
	"}

	// Close coordinates fieldset
	content += "</fieldset>"

	// Asteroids list fieldset
	content += {"
	<fieldset class='computerPane' style='display: inline-block; min-width: 45%;'>
		<legend class='computerLegend'>
			<b>Celestial Bodies</b>
		</legend>
	"}
	// Selected asteroid container
	var/asteroid_name
	var/asteroid_desc
	if(selected_template)
		asteroid_name = selected_template.name
		asteroid_desc = jointext(selected_template.get_description(), "")

	content += {"
		<div class="computerLegend" style="margin-bottom: 2em; width: 97%; height: 7em;">
			<div style='font-size: 200%; text-align: center'>
				[asteroid_name || "N/A"]
			</div>
			[asteroid_desc ? "<div style='text-align:left; margin-left:20%; display: flex; flex-direction: column'>[asteroid_desc]</div>" : "<div style='text-align: center'>N/A</div>"]
		</div>
	"}

	// Asteroid list container
	content += {"
		<div class='zebraTable' style='display: flex;flex-direction: column;width: 100%; height: 190px;overflow-y: auto'>
	"}

	var/i = 0
	for(var/datum/mining_template/template as anything in available_templates)
		i++
		var/bg_color = i % 2 == 0 ? "#7c5500" : "#533200"
		if(selected_template == template)
			bg_color = "#e67300 !important"
		content += {"
					<div class='highlighter' onclick='byondCall(\"[ref(template)]\")' style='width: 100%;height: 2em;background-color: [bg_color]'>
						<span class='computerText' style='padding-left: 10px'>[template.name] ([template.x],[template.y])</span>
					</div>
		"}

	content += "</div></fieldset></div>"

	content += {"
	<script>
	function byondCall(id){
		window.location = 'byond://?src=[ref(src)];select=' + id
	}
	</script>
	"}


	var/datum/browser/popup = new(user, "asteroidmagnet", name, 920, 475)
	popup.set_content(jointext(content,""))
	popup.set_window_options("can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;")
	popup.open()

/obj/machinery/asteroid_magnet/proc/ping(coords_x, coords_y)
	var/datum/mining_template/T = map.return_coordinate(coords_x, coords_y)
	if(T && !T.found)
		T.found = TRUE
		available_templates |= T
		templates_on_map -= T
		ping_result = "LOCATED"
		return

	var/datum/mining_template/closest
	var/lowest_dist = INFINITY
	for(var/datum/mining_template/asteroid as anything in templates_on_map)
		// Get the euclidean distance between the ping and the asteroid.
		var/dist = sqrt(((asteroid.x - coords_x) ** 2) + ((asteroid.y - coords_y) ** 2))
		if(dist < lowest_dist)
			closest = asteroid
			lowest_dist = dist

	if(closest)
		var/dx = closest.x - coords_x
		var/dy = closest.y - coords_y
		// Get the angle as 0 - 180 degrees
		var/angle = arccos(dy / sqrt((dx ** 2) + (dy ** 2)))
		if(dx < 0) // If the X-axis distance is negative, put it between 181 and 359. 180 and 360/0 are impossible, as that requires X == 0.
			angle = 360 - angle

		ping_result = "AZIMUTH<br>[round(angle, 0.01)]"
	else
		ping_result = "ERR"

/// Test to see if we should clear the magnet area.
/// Returns FALSE if it can clear, returns a string error message if it can't.
/obj/machinery/asteroid_magnet/proc/check_for_magnet_errors()
	. = FALSE
	if(isnull(selected_template))
		return "ERROR N1"

	for(var/mob/M as mob in range(area_size + 1, center_turf))
		if(isliving(M))
			return "ERROR C3"

/// Performs a full summoning sequence, including putting up boundaries, clearing out the area, and bringing in the new asteroid.
/obj/machinery/asteroid_magnet/proc/summon_sequence(datum/mining_template/template)
	var/magnet_error = check_for_magnet_errors()
	if(magnet_error)
		status = magnet_error
		updateUsrDialog()
		return

	var/area/station/cargo/mining/asteroid_magnet/A = get_area(center_turf)
	A.area_flags |= NOTELEPORT // We dont want people getting nuked during the generation sequence
	status = "Summoning[ellipsis()]"
	available_templates -= template
	updateUsrDialog()

	var/time = world.timeofday
	var/list/forcefields = PlaceForcefield()
	CleanupTemplate()
	PlaceTemplate(selected_template)

	/// This process should take ATLEAST 20 seconds
	time = (world.timeofday + 20 SECONDS) - time
	if(time > 0)
		addtimer(CALLBACK(src, PROC_REF(_FinishSummonSequence), forcefields), time)
	else
		_FinishSummonSequence(forcefields)
	return

/obj/machinery/asteroid_magnet/proc/_FinishSummonSequence(list/forcefields)
	QDEL_LIST(forcefields)

	var/area/station/cargo/mining/asteroid_magnet/A = get_area(center_turf)
	A.area_flags &= ~NOTELEPORT // Annnnd done

	status = STATUS_OKAY
	updateUsrDialog()

/// Summoning part of summon_sequence()
/obj/machinery/asteroid_magnet/proc/PlaceTemplate(datum/mining_template/template)
	PRIVATE_PROC(TRUE)
	template.Generate()

/// Places the forcefield boundary during summon_sequence
/obj/machinery/asteroid_magnet/proc/PlaceForcefield()
	PRIVATE_PROC(TRUE)
	. = list()
	var/list/turfs = RANGE_TURFS(area_size, center_turf) ^ RANGE_TURFS(area_size + 1, center_turf)
	for(var/turf/T as anything in turfs)
		. += new /obj/effect/forcefield/asteroid_magnet(T)


/// Cleanup our currently loaded mining template
/obj/machinery/asteroid_magnet/proc/CleanupTemplate()
	PRIVATE_PROC(TRUE)

	var/list/turfs_to_destroy = ReserveTurfsForAsteroidGeneration(center_turf, area_size, space_only = FALSE)
	for(var/turf/T as anything in turfs_to_destroy)
		CHECK_TICK

		for(var/atom/movable/AM as anything in T)
			CHECK_TICK
			if(isdead(AM) || iscameramob(AM) || iseffect(AM) || !(ismob(AM) || isobj(AM)))
				continue
			qdel(AM)

		T.ChangeTurf(/turf/baseturf_bottom)


/// Generates the random map for the magnet.
/obj/machinery/asteroid_magnet/proc/GenerateMap()
	PRIVATE_PROC(TRUE)
	map = new(-100, 100, -100, 100)

	// Generate common templates
	if(length(SSmaterials.template_paths_by_rarity["[MINING_COMMON]"]))
		for(var/i in 1 to 12)
			InsertTemplateToMap(pick(SSmaterials.template_paths_by_rarity["[MINING_COMMON]"]))

	/*
	// Generate uncommon templates
	for(var/i in 1 to 4)
		InsertTemplateToMap(pick(SSmaterials.template_paths_by_rarity["[MINING_UNCOMMON]"]))
	// Generate rare templates
	for(var/i in 1 to 2)
		InsertTemplateToMap(pick(SSmaterials.template_paths_by_rarity["[MINING_RARE]"]))
	*/

/obj/machinery/asteroid_magnet/proc/InsertTemplateToMap(path)
	PRIVATE_PROC(TRUE)

	var/collisions = 0
	var/datum/mining_template/template
	var/x
	var/y

	template = new path(center_turf, area_size)
	template.randomize()
	templates_on_map += template

	do
		x = rand(-100, 100)
		y = rand(-100, 100)

		if(map.return_coordinate(x, y))
			collisions++
		else
			map.set_coordinate(x, y, template)
			template.x = x
			template.y = y
			break

	while (collisions <= MAX_COLLISIONS_BEFORE_ABORT)

#undef MAX_COLLISIONS_BEFORE_ABORT
#undef STATUS_OKAY
