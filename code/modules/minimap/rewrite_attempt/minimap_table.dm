
/obj/machinery/minimap_table
	name = "gorlex holotable"
	desc = "Shows a minimap, funky!"
	icon = 'icons/obj/machines/minimap_table.dmi'
	icon_state = "off"
	processing_flags = START_PROCESSING_MANUALLY
	var/hologram_icon_file = 'icons/obj/machines/minimap_table_hologram.dmi'
	var/target_z = 2
	var/datum/minimap/minimap
	var/list/mob/viewers = list()
	var/active = FALSE
	var/startup = FALSE
	var/animation_x = -15
	var/animation_y = 18

/obj/machinery/minimap_table/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(set_minimap))

/obj/machinery/minimap_table/Destroy(force)
	. = ..()
	for(var/mob/viewer as anything in viewers)
		viewer.hud_used.remove_screen_object(HUD_TAC_MINIMAP)
	viewers = null

/obj/machinery/minimap_table/interact(mob/user)
	. = ..()
	if(!is_operational || isnull(minimap) || isnull(user.hud_used))
		return FALSE
	if(active)
		show_minimap(user)
		return TRUE

	addtimer(CALLBACK(src, PROC_REF(activate), user), 5.1 SECONDS, TIMER_UNIQUE | TIMER_CLIENT_TIME)

	startup = TRUE
	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/machinery/minimap_table/proc/activate(mob/activator)
	if(active)
		return
	startup = FALSE
	active = TRUE
	show_minimap(activator)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/minimap_table/proc/show_minimap(mob/user)
	var/atom/movable/screen/minimap_display/instanced = new(null, user.hud_used, minimap)
	user.hud_used.add_screen_object(instanced, HUD_TAC_MINIMAP, HUD_GROUP_STATIC, update_screen = TRUE)
	viewers |= user

/obj/machinery/minimap_table/proc/set_minimap()
	minimap = get_minimap_for_z(target_z)

/obj/machinery/minimap_table/on_set_is_operational()
	update_appearance()

/obj/machinery/minimap_table/proc/offset_hologram_overlays(icon_state = "idle")
	var/mutable_appearance/anim = mutable_appearance(hologram_icon_file, icon_state, ABOVE_MOB_LAYER)
	anim.pixel_x = animation_x
	anim.pixel_y = animation_y

	var/mutable_appearance/emissive = emissive_appearance(hologram_icon_file, icon_state, src, ABOVE_MOB_LAYER, effect_type = EMISSIVE_NO_BLOOM)
	emissive.pixel_x = animation_x
	emissive.pixel_y = animation_y

	return list(anim, emissive)

/obj/machinery/minimap_table/update_overlays()
	. = ..()
	if(!is_operational)
		return
	. += mutable_appearance(icon, "idle")
	. += emissive_appearance(icon, "idle", src)
	if(startup)
		. += offset_hologram_overlays("startup")
	if(active)
		. += offset_hologram_overlays("idle")

