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
/obj/item/sea_map
	name = "Trench Map"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"

/obj/item/sea_map/attack_self(mob/user, modifiers)
	. = ..()
	if(!user.client)
		return

	if (!SShotspots.map)
		return
	ui_interact(user)

/obj/item/sea_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrenchMap", name)
		ui.open()

/obj/item/sea_map/ui_data(mob/user)
	var/list/data = list()
	var/list/hotspot_list = list()
	for (var/datum/hotspot/listed_spot in SShotspots.generated_hotspots)
		var/list/details = list()
		details["center_y"] = listed_spot.center.y
		details["center_x"] = listed_spot.center.x
		details["radius"] = listed_spot.radius
		details["locked"] = listed_spot.can_drift
		hotspot_list += list(details)
	data["hotspots"] = hotspot_list
	if(!SSassets.cache["trenchmap.png"])
		SSassets.transport.register_asset("trenchmap.png", SShotspots.map)
	SSassets.transport.send_assets(user, list("trenchmap.png" = SShotspots.map))
	data["map_image"] = SSassets.transport.get_asset_url("trenchmap.png")
	data["map"] = SShotspots.finished_map
	return data
