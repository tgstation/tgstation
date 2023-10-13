///this is a pile of shitcode, so its seperated from the actual controller because i will be coming back in the future to fix it

/datum/controller/subsystem/hotspots/proc/generate_map()
	if(map)
		return
	///we load a blank map before we edit it each tile is a 2x2 pixel so map size is 510
	map = icon('monkestation/icons/misc/map_files.dmi', "blank_map")

	var/turf_color
	///brutal
	for(var/x = 1, x <= world.maxx, x++)
		for(var/y = 1, y <= world.maxy, y++)
			var/turf/T = locate(x,y, SSmapping.levels_by_trait(ZTRAIT_MINING)[1])
			if(istype(T, /turf/closed/mineral/random/ocean))
				turf_color = "solid"
			else if(T.loc && (istype(T.loc, /area/station) || istype(T.loc, /area/mine)))
				turf_color = "station"
			else if(istype(T, /turf/open/floor/plating/ocean))
				turf_color = "nothing"
			else
				turf_color = "other"

			///draw the map with the color chosen
			map.DrawBox(colors[turf_color], x * 2, y * 2, x * 2 + 1, y * 2 + 1)

/datum/controller/subsystem/hotspots/proc/generate_finalized_map()
	if(!map)
		return

	///points on the map we than translate to colors and sqaures on the map
	var/list/hotspots = list()
	for (var/datum/hotspot/listed_spot in generated_hotspots)
		if(listed_spot.can_drift)
			hotspots += {"<div class='hotspot' style='bottom: [listed_spot.center.y * 2]px; left: [listed_spot.center.x * 2]px; width: [listed_spot.radius * 4 + 2]px; height: [listed_spot.radius * 4 + 2]px; margin-left: -[listed_spot.radius * 2]px; margin-bottom: -[listed_spot.radius * 2]px;'></div>"}
		else
			hotspots += {"<div class='hotspot_locked' style='bottom: [listed_spot.center.y * 2]px; left: [listed_spot.center.x * 2]px; width: [listed_spot.radius * 4 + 2]px; height: [listed_spot.radius * 4 + 2]px; margin-left: -[listed_spot.radius * 2]px; margin-bottom: -[listed_spot.radius * 2]px;'></div>"}
	///using html because idk how to transport a generated icon into tgui. so this is the best i could come up with.
	finished_map = {"
			<!doctype html>
				<html>
					<head>
						<title>Trench Map</title>
						<meta http-equiv="X-UA-Compatible" content="IE=edge;">

						<style type="text/css">
						body {
							background: black;
							color: white;
							font-family: Verdana, Geneva, Tahoma, sans-serif;
						}
						#map {
							position: relative;
							height: 510px;
							width: 510px;
							overflow: hidden;
							margin: 0 auto;
						}
						#map img {
							position: absolute;
							bottom: 0
							left: 0;
						}
						.hotspot {
							position: absolute;
							background: rgba(255, 120, 120, 0.6);
						}
						.hotspot_locked {
							position: absolute;
							background: rgba(255, 0, 0, 0.8);
						}
						.key {
							text-align: center;
							margin-top: 0.5em;
						}
						.key > span {
							white-space: nowrap;
							display: inline-block;
							margin: 0 0.5em;
						}
						.key > span > span {
							display: inline-block;
							height: 1em;
							width: 1em;
							border: 1px solid white;
						}
						.empty { background-color: [colors["empty"]]; }
						.solid { background-color: [colors["solid"]]; }
						.station { background-color: [colors["station"]]; }
						.other { background-color: [colors["other"]]; }
						.vent_unlocked { background-color: rgb(255, 120, 120); }
						.vent_locked { background-color: rgb(255, 0, 0); }
					</style>

				</head>
				<body>
					<div id='map'>
						<img src="trenchmap.png" height="510">
						[hotspots.Join("")]
					</div>
					<div class='key'>
						<span><span class='solid'></span>Trench Wall</span>
						<span><span class='station'></span> Station</span>
						<span><span class='other'></span> Unknown</span>
						<span><span class='vent_unlocked'></span> Hotspot</span>
						<span><span class='vent_locked'></span> Locked Hotspot</span>
					</div>
				</body>
			</html>
	"}
/obj/item/sea_map
	name = "Trench Map"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"

/obj/item/sea_map/attack_self(mob/user, modifiers)
	. = ..()
	if(!user.client)
		return

	if (!SShotspots.finished_map || !SShotspots.map)
		return
	user.client << browse_rsc(SShotspots.map, "trenchmap.png")
	ui_interact(user)

/obj/item/sea_map/ui_interact(mob/user, datum/tgui/ui)
	user.client << browse_rsc(SShotspots.map, "trenchmap.png")
	if(!SSassets.cache["trenchmap.png"])
		SSassets.transport.register_asset("trenchmap.png", SShotspots.finished_map)
	SSassets.transport.send_assets(user, list("trenchmap.png" = SShotspots.finished_map))

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrenchMap", name)
		ui.open()

/obj/item/sea_map/ui_data()
	var/list/data = list()
	data["map"] = SShotspots.finished_map
	return data
