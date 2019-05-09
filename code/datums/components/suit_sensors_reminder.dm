#define SUIT_SENSORS_ALERT_LIFETIME 15 SECONDS

/datum/component/suit_sensors_reminder
	var/last_used = 0

/datum/component/suit_sensors_reminder/Initialize()
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_VOX, .proc/ai_vox)
	RegisterSignal(parent, COMSIG_MOVABLE_HEAR, .proc/on_hear)

/datum/component/suit_sensors_reminder/proc/ai_vox(datum/source, mob/living/silicon/ai/ai, list/words)
	var/turf/T = get_turf(parent)
	if(ai.z == T?.z && ("sensors" in words))
		try_notify(ai)

/datum/component/suit_sensors_reminder/proc/on_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if((SPAN_COMMAND in spans) && findtext(lowertext(message), "sensors"))
		try_notify(source)

/datum/component/suit_sensors_reminder/proc/try_notify(datum/source)
	if(world.time - last_used < SUIT_SENSORS_ALERT_LIFETIME)
		return
	var/mob/living/carbon/human/H = parent
	var/obj/item/clothing/under/U = H?.w_uniform
	if(!istype(U))
		return
	last_used = world.time
	var/obj/screen/alert/toggle_suit_sensors/notification = H.throw_alert("toggle_suit_sensors", /obj/screen/alert/toggle_suit_sensors)
	if(!notification)
		return
	var/ui_style = H.client?.prefs?.UI_style
	if(ui_style)
		notification.icon = ui_style2icon(ui_style)
	notification.desc = "[source] wants to remind you to toggle your suit sensors so that the medical staff can find you in the case of an emergency."
	var/mutable_appearance/overlay = new()
	overlay.icon = U.icon
	overlay.icon_state = U.icon_state
	overlay.layer = FLOAT_LAYER
	overlay.plane = FLOAT_PLANE
	notification.add_overlay(overlay)

/obj/screen/alert/toggle_suit_sensors
	name = "Toggle Suit Sensors"
	icon_state = "template"
	timeout = SUIT_SENSORS_ALERT_LIFETIME

/obj/screen/alert/toggle_suit_sensors/Click()
	if(!usr || !usr.client)
		return
	var/mob/living/carbon/human/H = usr
	var/obj/item/clothing/under/U = H?.w_uniform
	U?.toggle()

#undef SUIT_SENSORS_ALERT_LIFETIME
