/client/verb/debug_generate_maps()
	set name = "MINIMAP GENERATION TEST (Debug)"
	set desc = "meow meow meow"
	set category = "mrrrp mrrrp mrrrow"

	GLOB.minimaps.Cut()

	rustg_time_reset("meow_all")
	for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		var/datum/minimap/z_minimap = new
		GLOB.minimaps[z] = z_minimap
		rustg_time_reset("meow")
		z_minimap.load_z(z)
		var/time_ms = rustg_time_milliseconds("meow")
		message_admins("Minimap generated for Z [z] in [time_ms] ms")
		fcopy(z_minimap.base_map, "tmp/minimaps/minimap_[SSmapping.current_map.map_name].[z].png")
	var/total_ms = rustg_time_milliseconds("meow_all")
	message_admins("total generation time of [total_ms] ms")

/client/verb/debug_toggle_minimap()
	set name = "MINIMAP DISPLAY TEST (Debug)"
	set desc = "Toggle the rewrite minimap on your HUD."
	set category = "mrrrp mrrrp mrrrow"

	var/datum/hud/hud = mob.hud_used
	if(!hud)
		to_chat(src, span_warning("No HUD found."))
		return

	// Toggle off if already visible.
	if(hud.screen_objects[HUD_TAC_MINIMAP])
		hud.remove_screen_object(HUD_TAC_MINIMAP)
		to_chat(src, span_notice("Minimap hidden."))
		return

	var/datum/minimap/minimap = get_minimap_for_z(mob.z)
	if(!minimap)
		to_chat(src, span_notice("No minimap generated for z=[mob.z]."))
		return

	var/atom/movable/screen/minimap_display/display = new(null, hud, minimap)
	hud.add_screen_object(display, HUD_TAC_MINIMAP, HUD_GROUP_STATIC, update_screen = TRUE)
	to_chat(src, span_notice("Minimap shown for z=[mob.z]."))
