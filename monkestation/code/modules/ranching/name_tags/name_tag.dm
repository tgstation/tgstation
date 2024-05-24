/datum/keybinding/mob/show_names
	hotkey_keys = list("Ctrl")
	name = "show_names"
	full_name = "Show Names"
	description = "Lets you see peoples names."
	keybind_signal = COMSIG_KB_MOB_SHOW_NAMES_DOWN

/datum/keybinding/mob/show_names/down(client/user)
	. = ..()
	if(.)
		return
	for(var/atom/movable/screen/plane_master/name_tags/name_tag as anything in user.mob?.hud_used.get_true_plane_masters(PLANE_NAME_TAGS))
		name_tag.alpha = 255

/datum/keybinding/mob/show_names/up(client/user)
	. = ..()
	if(.)
		return
	for(var/atom/movable/screen/plane_master/name_tags/name_tag as anything in user.mob?.hud_used.get_true_plane_masters(PLANE_NAME_TAGS))
		name_tag.alpha = 0

/mob
	var/obj/effect/name_tag/name_tag
	var/atom/movable/screen/name_shadow/shadow

/mob/Initialize(mapload)
	. = ..()
	name_tag = new(src)
	//SET_PLANE_EXPLICIT(name_tag, PLANE_NAME_TAGS, src)
	update_name_tag()
	vis_contents += name_tag

/mob/Login()
	. = ..()
	if(client && isliving(src) && (!iscyborg(src) && !isaicamera(src) && !isAI(src)))
		shadow = new()
		shadow.loc = src
		SET_PLANE_EXPLICIT(shadow, PLANE_NAME_TAGS_BLOCKER, src)
		client.screen += shadow
		hud_used.always_visible_inventory += shadow

/mob/Logout()
	. = ..()
	if(client && isliving(src) && (!iscyborg(src) && !isaicamera(src) && !isAI(src)))
		client.screen -= shadow
		shadow.UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
		hud_used?.always_visible_inventory -= shadow
		QDEL_NULL(shadow)

/mob/Destroy()
	. = ..()
	vis_contents -= name_tag
	QDEL_NULL(name_tag)
	if(client || shadow)
		client?.screen -= shadow
		shadow.UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)
		hud_used?.always_visible_inventory -= shadow
		QDEL_NULL(shadow)

/mob/proc/update_name_tag(passed_name)
	if(!passed_name)
		passed_name = name

	var/the_check = findtext(passed_name, " the")
	if(the_check)
		passed_name = copytext(passed_name, 1, the_check)
	name_tag.set_name(name)


/obj/effect/name_tag
	plane = PLANE_NAME_TAGS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	name = ""
	maptext_x = -64
	maptext_y = -13 //directly below characters

	maptext_width = 160
	maptext_height = 48
	icon = null // we want nothing
	appearance_flags = PIXEL_SCALE
	alpha = 180

/obj/effect/name_tag/New(mob/user)
	RegisterSignal(user, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_z))

/obj/effect/name_tag/proc/hide()
	alpha = 0

/obj/effect/name_tag/proc/show()
	alpha = 255

/obj/effect/name_tag/proc/set_name(incoming_name)
	maptext = "<span class='pixel c ol'><span style='font-size: 6px; text-align: center;'>[incoming_name]</span></span>"

/obj/effect/name_tag/proc/update_z(datum/source, turf/old_turf, turf/new_turf, same_z_layer)
	SET_PLANE(src, PLANE_TO_TRUE(src.plane), new_turf)

/atom/movable/screen/plane_master/name_tags
	name = "name tag plane"
	plane = PLANE_NAME_TAGS
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	critical = PLANE_CRITICAL_DISPLAY
	render_relay_planes = list(RENDER_PLANE_GAME_WORLD)
	alpha = 0

/atom/movable/screen/plane_master/name_tags/Initialize(mapload)
	. = ..()
	add_filter("vision_cone", 1, alpha_mask_filter(render_source = OFFSET_RENDER_TARGET(NAME_TAG_RENDER_TARGET, offset), flags = MASK_INVERSE))

/atom/movable/screen/plane_master/name_tag_blocker
	name = "name tag blocker blocker"
	documentation = "This is one of those planes that's only used as a filter. It masks out things that want to be hidden by fov.\
		<br>Literally just contains FOV images, or masks."
	plane = PLANE_NAME_TAGS_BLOCKER
	render_target = NAME_TAG_RENDER_TARGET
	render_relay_planes = list()

/atom/movable/screen/name_shadow
	icon = 'monkestation/code/modules/ranching/name_tags/covers.dmi'
	icon_state = "alpha-blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = PLANE_NAME_TAGS_BLOCKER
	screen_loc = "BOTTOM,LEFT"
