
/obj/machinery/minimap_table
	name = "gorlex holotable"
	desc = "Shows a minimap, funky!"
	icon = 'icons/obj/machines/minimap_table.dmi'
	icon_state = "off"
	processing_flags = START_PROCESSING_MANUALLY
	light_range = 4
	light_power = 2
	light_on = FALSE
	light_color = LIGHT_COLOR_INTENSE_RED
	light_system = OVERLAY_LIGHT
	SET_BASE_PIXEL(0, 2)
	var/hologram_icon_file = 'icons/obj/machines/minimap_table_hologram.dmi'
	var/target_z = 2
	var/datum/minimap/minimap
	var/list/mob/viewers = list()
	var/active = FALSE
	var/startup = FALSE
	var/animation_x = -15
	var/animation_y = 18
	var/animation_duration = 5.1 SECONDS
	var/interactivity_range = 2
	var/datum/proximity_monitor/proximity
	var/mutable_appearance/anim
	var/mutable_appearance/emissive
	var/datum/light_middleman/middleman

/obj/machinery/minimap_table/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(set_minimap))
	proximity = new(src, interactivity_range)

	if(IS_OVERLAY_LIGHT_SYSTEM(light_system))
		middleman = new(src, "holotable")
		RegisterSignal(middleman, COMSIG_LIGHT_MIDDLEMAN_UPDATED, PROC_REF(light_pulsate))
		middleman.being_overriding_light()

/obj/machinery/minimap_table/Destroy(force)
	. = ..()
	for(var/mob/viewer as anything in viewers)
		viewer.hud_used.remove_screen_object(HUD_TAC_MINIMAP)
	viewers = null
	QDEL_NULL(anim)
	QDEL_NULL(emissive)

/obj/machinery/minimap_table/RangedAttackOn(mob/A, list/modifiers)
	if(get_dist(src, A) > interactivity_range)
		return
	interact(A)

/obj/machinery/minimap_table/interact(mob/user)
	. = ..()
	if(!is_operational || isnull(minimap) || isnull(user.hud_used))
		return FALSE
	if(!isnull(user.hud_used.screen_objects[HUD_TAC_MINIMAP]))
		hide_minmap(user)
		return TRUE
	if(active)
		show_minimap(user)
		return TRUE

	addtimer(CALLBACK(src, PROC_REF(activate), user), , TIMER_UNIQUE | TIMER_CLIENT_TIME)

	startup = TRUE
	offset_hologram_overlays("startup")
	flick_overlay_global(anim, GLOB.clients, animation_duration)
	return TRUE

/obj/machinery/minimap_table/proc/activate(mob/activator)
	if(active)
		return
	startup = FALSE
	active = TRUE
	if(activator && get_dist(src, activator) <= interactivity_range)
		show_minimap(activator)
	offset_hologram_overlays()

/obj/machinery/minimap_table/proc/light_pulsate()
	var/obj/effect/abstract/main_light = middleman.primary_intercept
	// center it since we're a 2x2 machine
	var/matrix/center = matrix()
	center.Translate(16, 0)
	main_light.transform = center

	var/matrix/bigTransform = matrix()
	var/matrix/smallTransform = matrix()
	bigTransform.Scale(1.25)
	smallTransform.Scale(0.75)

	animate(main_light, alpha = 100, time = 2 SECONDS, loop = -1)
	animate(alpha = 255, time = 2 SECONDS)
	animate(transform = bigTransform, time = 2 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(transform = smallTransform, time = 2 SECONDS)

/obj/machinery/minimap_table/proc/deactivate()
	if(!active)
		return
	active = FALSE
	cut_overlay(list(anim, emissive))

/obj/machinery/minimap_table/proc/deactive_without_viewers()
	if(!length(viewers))
		deactivate()

/obj/machinery/minimap_table/proc/show_minimap(mob/user)
	var/atom/movable/screen/minimap_display/instanced = new(null, user.hud_used, minimap)
	user.hud_used.add_screen_object(instanced, HUD_TAC_MINIMAP, HUD_GROUP_STATIC, update_screen = TRUE)
	viewers |= user

/obj/machinery/minimap_table/proc/hide_minmap(mob/user)
	user.hud_used.remove_screen_object(HUD_TAC_MINIMAP)
	viewers -= user
	if(!length(viewers))
		addtimer(CALLBACK(src, PROC_REF(deactive_without_viewers)), 10 SECONDS, TIMER_OVERRIDE | TIMER_UNIQUE)

/obj/machinery/minimap_table/proc/set_minimap()
	minimap = get_minimap_for_z(target_z)

/obj/machinery/minimap_table/on_set_is_operational()
	update_appearance()
	set_light_on(is_operational)

	if(!is_operational)
		deactivate()

/obj/machinery/minimap_table/proc/offset_hologram_overlays(holo_state)
	// cut_overlay(list(anim, emissive))
	anim = image(hologram_icon_file, src, holo_state, ABOVE_MOB_LAYER, dir, animation_x, animation_y)
	anim.pixel_x = animation_x
	anim.pixel_y = animation_y

	emissive = emissive_appearance(hologram_icon_file, holo_state, src, ABOVE_MOB_LAYER, effect_type = EMISSIVE_NO_BLOOM)
	emissive.pixel_x = animation_x
	emissive.pixel_y = animation_y

/obj/machinery/minimap_table/update_overlays()
	. = ..()
	if(!is_operational)
		return
	. += mutable_appearance(icon, "idle")
	. += emissive_appearance(icon, "idle", src)

/obj/machinery/minimap_table/OnProximityExit(atom/movable/gone)
	if(!active || !ismob(gone))
		return
	var/mob/mob_gone = gone
	var/list/adjacent = orange(interactivity_range, src)
	if(mob_gone in adjacent)
		return
	if(mob_gone in viewers)
		hide_minmap(gone)
