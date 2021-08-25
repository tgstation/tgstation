/// Applied to clients when they receive an admin popup, alerting them to
/// their ticket.
/datum/component/admin_popup
	/// The user's most active ticket. If this is resolved, closed, or replied to,
	/// then the component will delete itself.
	var/datum/admin_help/ticket

	var/atom/movable/screen/admin_popup/admin_popup

/datum/component/admin_popup/Initialize(datum/admin_help/ticket)
	if (!istype(parent, /client))
		return COMPONENT_INCOMPATIBLE

	if (!istype(ticket))
		return COMPONENT_INCOMPATIBLE

	create_notice()

	RegisterSignal(ticket, COMSIG_ADMIN_HELP_INACTIVE, .proc/delete_self)
	RegisterSignal(ticket, COMSIG_ADMIN_HELP_REPLIED, .proc/delete_self)
	RegisterSignal(ticket, COMSIG_PARENT_QDELETING, .proc/delete_self)

/datum/component/admin_popup/Destroy(force, silent)
	var/client/parent_client = parent

	parent_client?.screen -= admin_popup
	QDEL_NULL(admin_popup)

	if (!QDELETED(ticket))
		UnregisterSignal(ticket, list(
			COMSIG_ADMIN_HELP_INACTIVE,
			COMSIG_ADMIN_HELP_REPLIED,
			COMSIG_PARENT_QDELETING,
		))

		ticket = null

	return ..()

/datum/component/admin_popup/proc/create_notice()
	QDEL_NULL(admin_popup)
	admin_popup = new

	var/client/parent_client = parent
	admin_popup.maptext_width = getviewsize(parent_client.view_size.getView())[1] * world.icon_size
	parent_client.screen += admin_popup

/datum/component/admin_popup/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)

/// The UI element for admin popups
/atom/movable/screen/admin_popup
	icon = null
	icon_state = null
	plane = ABOVE_HUD_PLANE
	layer = ADMIN_POPUP_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "TOP-5,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""

	var/static/list/colors = list(
		COLOR_RED,
		COLOR_ORANGE,
		COLOR_YELLOW,
		COLOR_LIME,
		COLOR_CYAN,
		COLOR_PURPLE,
	)

	var/last_color = 0
	var/last_update = 0

/atom/movable/screen/admin_popup/New(loc, ...)
	. = ..()

	START_PROCESSING(SSobj, src)
	update_text()

/atom/movable/screen/admin_popup/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/atom/movable/screen/admin_popup/process(delta_time)
	update_text()

/atom/movable/screen/admin_popup/proc/update_text()
	// Even if processing time changes, we want this to remain slow.
	// We want to pester them into reading their ticket, not give them a seizure!
	if (world.time - last_update < 2 SECONDS)
		return

	last_color = (last_color % colors.len) + 1

	var/message = "<b style='color: [colors[last_color]]; text-align: center; font-size: 32px'>"
	message += "HEY! An admin is trying to talk to you!<br>Check your chat window, and click their name to respond!"
	message += "</b>"

	maptext = MAPTEXT(message)
	last_update = world.time

/// Tries to give the target an admin popup.
/// If it fails, will send the error to the passed admin.
/proc/give_admin_popup(client/target, client/admin, message)
	log_admin("[key_name(admin)] sent an admin popup to [key_name(target)].")

	var/datum/admin_help/current_ticket = target.current_ticket
	if (!current_ticket)
		to_chat(admin, span_warning("[key_name(target)] had no active ahelp, aborting."))
		return

	admin.cmd_admin_pm(target, message)
	target.AddComponent(/datum/component/admin_popup, current_ticket)
