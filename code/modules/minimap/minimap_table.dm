
/obj/machinery/minimap_table
	name = "reconnaissance platform"
	desc = "This holographic projector displays a constant stream of tactical information, enabling cinematic planning and strategizing. \
		Currently, it appears to be monitoring a nearby station and tracking key targets for a clandestine operation."
	icon = 'icons/obj/machines/minimap_table.dmi'
	icon_state = "off"
	processing_flags = START_PROCESSING_MANUALLY
	light_range = 4
	light_power = 2
	light_color = LIGHT_COLOR_INTENSE_RED
	light_system = OVERLAY_LIGHT
	density = TRUE
	bound_width = 64
	SET_BASE_PIXEL(0, 2)
	/// Hologram icon sheet used for startup/idle/closing projection effects.
	var/hologram_icon_file = 'icons/obj/machines/minimap_table_hologram.dmi'
	/// Z-trait used to resolve the minimap level this table displays.
	var/target_z_trait = ZTRAIT_STATION
	/// Cached minimap datum currently displayed by this table.
	var/datum/minimap/minimap
	/// Users currently viewing the table-projected minimap HUD.
	var/list/mob/viewers = list()
	/// Whether the table is currently active and projecting.
	var/active = FALSE
	/// Whether startup animation/state is currently in progress.
	var/startup = FALSE
	/// Pixel X offset for projected hologram overlays.
	var/animation_x = -15
	/// Pixel Y offset for projected hologram overlays.
	var/animation_y = 18
	/// Startup/closing animation duration.
	var/animation_duration = 5.1 SECONDS
	/// Max distance at which users can interact with the table.
	var/interactivity_range = 3
	/// Proximity monitor used to close viewers leaving interaction range.
	var/datum/proximity_monitor/proximity
	/// Light helper used for pulsing hologram illumination.
	var/datum/light_middleman/middleman
	/// Lowest alpha value used by the pulsing light animation.
	var/flicker_min_alpha = 150
	/// HUD elements used by the holotable minimap view.
	var/list/table_huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/nuclear,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down,
	)

/obj/machinery/minimap_table/Initialize(mapload)
	. = ..()
	proximity = new(src, interactivity_range)

	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "holotable")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_pulsate))
		middleman.being_overriding_light()

/obj/machinery/minimap_table/Destroy(force)
	for(var/mob/viewer as anything in viewers)
		remove_table_huds(viewer.hud_used)
	viewers = null
	QDEL_NULL(proximity)
	QDEL_NULL(middleman)
	minimap = null
	return ..()

/obj/machinery/minimap_table/post_machine_initialize()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(set_minimap))

/obj/machinery/minimap_table/RangedAttackOn(mob/attacker, list/modifiers)
	if(get_dist(src, attacker) > interactivity_range)
		return
	interact(attacker)

/obj/machinery/minimap_table/interact(mob/user)
	. = ..()
	if(!is_operational || isnull(minimap) || isnull(user.hud_used))
		return FALSE
	if(!isnull(user.hud_used.screen_objects[HUD_TAC_MINIMAP]))
		hide_minimap(user)
		return TRUE
	if(active)
		show_minimap(user)
		return TRUE

	addtimer(CALLBACK(src, PROC_REF(activate), user), animation_duration, TIMER_UNIQUE | TIMER_CLIENT_TIME)

	startup = TRUE
	play_animation("startup")
	return TRUE

/obj/machinery/minimap_table/proc/play_animation(icon_state = "startup", duration = animation_duration)
	var/image/img = image(hologram_icon_file, src, icon_state, ABOVE_MOB_LAYER, dir, animation_x, animation_y)
	var/image/emissive_img = image(hologram_icon_file, src, icon_state, ABOVE_MOB_LAYER, dir, animation_x, animation_y)
	emissive_img.plane = EMISSIVE_PLANE
	emissive_img.color = _EMISSIVE_COLOR_NO_BLOOM(1)

	flick_overlay_global(img, GLOB.clients, duration)
	flick_overlay_global(emissive_img, GLOB.clients, duration)

/obj/machinery/minimap_table/proc/activate(mob/activator)
	if(active || !is_operational)
		return
	startup = FALSE
	active = TRUE
	if(activator && get_dist(src, activator) <= interactivity_range)
		show_minimap(activator)
	update_appearance(UPDATE_OVERLAYS)
	light_pulsate()

/obj/machinery/minimap_table/proc/deactivate()
	if(!active)
		return
	active = FALSE
	update_appearance(UPDATE_OVERLAYS)
	var/obj/effect/abstract/main_light = middleman.primary_intercept
	animate(main_light, time = 1 SECONDS)
	play_animation("closing")

/obj/machinery/minimap_table/proc/light_pulsate()
	SIGNAL_HANDLER
	var/obj/effect/abstract/main_light = middleman.primary_intercept
	var/matrix/center = matrix()
	// center it since we're a 2x2 machine
	center.Translate(16, 0)
	main_light.transform = center
	if(!active)
		return


	var/matrix/bigTransform = matrix()
	var/matrix/smallTransform = matrix()
	smallTransform.Add(center)
	bigTransform.Add(center)

	bigTransform.Scale(1.25)
	smallTransform.Scale(0.75)

	animate(main_light, alpha = flicker_min_alpha, time = 2 SECONDS, loop = -1, easing = SINE_EASING)
	animate(alpha = 255, time = 2 SECONDS)
	animate(transform = bigTransform, time = 3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL, easing = SINE_EASING)
	animate(transform = smallTransform, time = 3 SECONDS)

/obj/machinery/minimap_table/proc/deactive_without_viewers()
	if(!length(viewers))
		deactivate()

/obj/machinery/minimap_table/proc/show_minimap(mob/user)
	add_table_huds(user.hud_used)
	viewers |= user

/obj/machinery/minimap_table/proc/hide_minimap(mob/user)
	remove_table_huds(user.hud_used)
	viewers -= user
	if(!length(viewers))
		addtimer(CALLBACK(src, PROC_REF(deactive_without_viewers)), 10 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/machinery/minimap_table/proc/add_table_huds(datum/hud/hud)
	var/target_z = resolve_target_z()
	var/allow_draw = can_user_draw(hud?.mymob)
	for(var/element in table_huds)
		var/hud_element_type = table_huds[element]
		var/instanced = new hud_element_type(null, hud, minimap, null, target_z, MINIMAP_ANNOTATION_TAG_NUCLEAR, allow_draw)
		hud.add_screen_object(instanced, element, HUD_GROUP_STATIC, update_screen = TRUE)

/obj/machinery/minimap_table/proc/can_user_draw(mob/user)
	return HAS_TRAIT(user, TRAIT_MINIMAP_TABLE_DRAW)

/obj/machinery/minimap_table/proc/remove_table_huds(datum/hud/hud)
	for(var/element in table_huds)
		hud.remove_screen_object(element)

/obj/machinery/minimap_table/proc/resolve_target_z()
	if(isnull(target_z_trait))
		return null
	var/list/trait_levels = SSmapping.levels_by_trait(target_z_trait)
	if(length(trait_levels))
		var/top_level
		for(var/level in trait_levels)
			if(isnull(top_level) || level > top_level)
				top_level = level
		return top_level
	return null

/obj/machinery/minimap_table/proc/set_minimap()
	var/target_z = resolve_target_z()
	minimap = get_minimap_for_z(target_z)

/obj/machinery/minimap_table/on_set_is_operational()
	update_appearance()
	set_light_on(is_operational)

	if(!is_operational)
		deactivate()

/obj/machinery/minimap_table/update_overlays()
	. = ..()
	if(!is_operational)
		return
	. += mutable_appearance(icon, "idle")
	. += emissive_appearance(icon, "idle", src)
	if(active)
		var/holo_state = "idle"
		var/mutable_appearance/idle = mutable_appearance(hologram_icon_file, holo_state, ABOVE_MOB_LAYER)
		idle.pixel_x = animation_x
		idle.pixel_y = animation_y
		. += idle

		var/mutable_appearance/emissive = emissive_appearance(hologram_icon_file, holo_state, src, ABOVE_MOB_LAYER, effect_type = EMISSIVE_NO_BLOOM)
		emissive.pixel_x = animation_x
		emissive.pixel_y = animation_y
		. += emissive

/obj/machinery/minimap_table/OnProximityExit(atom/movable/gone)
	if(!active || !ismob(gone))
		return
	var/mob/mob_gone = gone
	var/list/adjacent = orange(interactivity_range, src)
	if(mob_gone in adjacent)
		return
	if(mob_gone in viewers)
		hide_minimap(gone)
