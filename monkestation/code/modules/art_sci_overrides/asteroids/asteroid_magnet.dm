GLOBAL_LIST_INIT(maps_magnet_center, list())

/obj/machinery/asteroid_magnet
	name = "asteroid magnet computer"
	icon_state = "blackbox"
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE

	/// Templates available to succ in
	var/list/datum/mining_template/available_templates
	/// All templates in the "map".
	var/list/datum/mining_template/all_templates
	/// The map that stores asteroids
	var/datum/cartesian_plane/map
	/// The currently selected template
	var/list/datum/mining_template/selected_template

	var/coords_x = 0
	var/coords_y = 0

	var/ping_result = "N/A"

	///this is the center of the area we wish to spawn stuff on. Set in strong dmm than its saved inside a global for later
	var/center_x
	var/center_y

	COOLDOWN_DECLARE(asteroid_cooldown)

/obj/machinery/asteroid_magnet/examine(mob/user)
	. = ..()
	if(asteroid_cooldown)
		. += span_notice("It seems to be cooling down, you estimate it will take about [DisplayTimeText(COOLDOWN_TIMELEFT(src, asteroid_cooldown))].")


/obj/machinery/asteroid_magnet/Initialize(mapload)
	. = ..()

	if(center_x || center_y)
		GLOB.maps_magnet_center = list(center_x, center_y)
	else if(length(GLOB.maps_magnet_center))
		center_x = GLOB.maps_magnet_center[1]
		center_y = GLOB.maps_magnet_center[2]

	available_templates = list()
	all_templates = list()
	map = new(-100, 100, -100, 100)

	var/turf/spawning_turf = locate(center_x, center_y, src.z)
	if(!spawning_turf)
		return

	var/datum/mining_template/simple_asteroid/A = new(spawning_turf, 5)
	A.x = 0
	A.y = 1
	all_templates += A
	map.set_coordinate(0, 1, A)
/*
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
		if(selected_template)
			available_templates += T
		selected_template = T
		available_templates -= T
		updateUsrDialog()
		return

/obj/machinery/asteroid_magnet/ui_interact(mob/user, datum/tgui/ui)
	var/content = list()

	content += {"
	<fieldset class='computerPane'>
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
			<div class='computerLegend' style='margin: auto; width:25%'>
				[ping_result]
			</div>
			<div style='margin: auto; width: 10%'>
				[button_element(src, "PING", "ping=1")]
			</div>
		</fieldset>
	"}

	// Close coordinates fieldset
	content += "</fieldset>"

	// Asteroids list fieldset
	content += {"
	<fieldset class='computerPane'>
		<legend class='computerLegend'>
			<b>Available Asteroids</b>
		</legend>
	"}

	content += {"
		<table class='zebraTable' style='min-width:100%;height: 560px;overflow-y: auto'>
	"}

	for(var/datum/mining_template/template as anything in available_templates)
		content += {"
					<tr class='highlighter' style='display: block;min-width: 100%' onclick='byondCall([ref(template)])'>
						<td>
						<span class='computerText' style='padding-left: 10px'>[template.name] ([template.x],[template.y])</span>
						</td>
					</tr>
		"}

	content += "</table></fieldset>"

	content += {"
	<script>
	function byondCall(id){
		window.location = 'byond://?src=[ref(src)];select=' + id
	}
	</script>
	"}


	var/datum/browser/popup = new(user, "asteroidmagnet", name, 460, 550)
	popup.set_content(jointext(content,""))
	popup.open()

/obj/machinery/asteroid_magnet/proc/ping(coords_x, coords_y)
	var/datum/mining_template/T = map.return_coordinate(coords_x, coords_y)
	if(T)
		ping_result = "LOCATED"
		available_templates += T
		return

	var/datum/mining_template/closest
	var/lowest_dist = INFINITY
	for(var/datum/mining_template/asteroid as anything in all_templates)
		var/dist = sqrt(((asteroid.x - coords_x) ** 2) + ((asteroid.y - coords_y) ** 2))
		if(dist < lowest_dist)
			closest = asteroid
			lowest_dist = dist

	if(closest)
		var/dx = closest.x - coords_x
		var/dy = closest.y - coords_y
		var/angle = arccos(dy / sqrt((dx ** 2) + (dy ** 2)))
		if(dx < 0)
			angle = 360 - angle

		ping_result = "AZIMUTH [angle]"
	else
		ping_result = "ERR"
*/ //DISABLED UNTIL FINISHED

/obj/machinery/asteroid_magnet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!COOLDOWN_FINISHED(src, asteroid_cooldown))
		return

	var/turf/turf = locate(center_x, center_y, src.z)
	var/datum/mining_template/simple_asteroid/template = new(turf, 3)
	CleanupAsteroidMagnet(template.center, template.size)

	var/list/turfs = ReserveTurfsForAsteroidGeneration(template.center, template.size)
	var/datum/callback/asteroid_cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(GenerateRoundAsteroid), template, template.center, /turf/closed/mineral/random/asteroid/tospace, null, turfs, TRUE)
	SSmapping.generate_asteroid(template, asteroid_cb)

	COOLDOWN_START(src, asteroid_cooldown, 5 MINUTES)
