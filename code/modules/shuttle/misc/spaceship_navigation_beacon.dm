/obj/machinery/spaceship_navigation_beacon
	name = "radio navigation gigabeacon"
	desc = "Устройство, которое постоянно передает своё местоположение на частотах, обычно используемых для флотской навигации. Используется для создания путевых точек в неизведанных или неосвоенных районах."
	icon = 'icons/obj/machines/navigation_beacon.dmi'
	icon_state = "beacon_active"
	base_icon_state = "beacon"
	density = TRUE

	/// Locked beacons cannot be jumped to by ships.
	var/locked = FALSE
	/// Time between automated messages.
	var/automatic_message_cooldown = 5 MINUTES
	/// Next world tick to send an automatic message.
	var/next_automatic_message_time
	/// Our internal radio.
	var/obj/item/radio/radio

/obj/machinery/spaceship_navigation_beacon/Initialize(mapload)
	. = ..()
	SSshuttle.beacon_list |= src

	name = "[initial(src.name)] [z]-[rand(0, 999)]"

	var/static/list/multitool_tips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Переименовать маяк",
			SCREENTIP_CONTEXT_RMB = "Заблокировать/Разблокировать маяк",
		)
	)
	AddElement(/datum/element/contextual_screentip_tools, multitool_tips)

	radio = new(src)
	radio.set_listening(FALSE)
	radio.set_frequency(FREQ_RADIO_NAV_BEACON)
	radio.freqlock = RADIO_FREQENCY_LOCKED
	radio.recalculateChannels()

	START_PROCESSING(SSmachines, src)
	COOLDOWN_START(src, next_automatic_message_time, automatic_message_cooldown)

/obj/machinery/spaceship_navigation_beacon/emp_act(severity)
	. = ..()
	locked = TRUE
	update_appearance(UPDATE_ICON_STATE)

/obj/machinery/spaceship_navigation_beacon/Destroy()
	SSshuttle.beacon_list -= src
	return ..()

/obj/machinery/spaceship_navigation_beacon/update_icon_state()
	icon_state = "[base_icon_state][locked ? "_locked" : "_active"]"
	return ..()

/obj/machinery/spaceship_navigation_beacon/multitool_act(mob/living/user, obj/item/tool)
	..()

	var/chosen_tag = tgui_input_text(user, "Введите новое название для маяка", "Реклассификация маяка", max_length = MAX_NAME_LEN)
	if(!chosen_tag)
		return

	var/new_name = "[initial(src.name)] [chosen_tag]"
	if(new_name && Adjacent(user))
		name = new_name
		balloon_alert_to_viewers("маяк переименован")

	return TRUE

/obj/machinery/spaceship_navigation_beacon/multitool_act_secondary(mob/living/user, obj/item/tool)
	..()

	locked = !locked

	balloon_alert_to_viewers("[!locked ? "разблокирован" : "заблокирован"]")
	update_icon_state()

	return TRUE

/obj/machinery/spaceship_navigation_beacon/examine()
	.=..()
	. += span_notice("На корпусе написана рабочая частота: '[FREQ_RADIO_NAV_BEACON / 10] кГц'.")
	if(locked)
		. += span_warning("Мигающая красная лампа на передней панели указывает на то, что маяк ЗАБЛОКИРОВАН.")
	else
		. += span_notice("Мигающая зеленая лампа на передней панели указывает на то, что маяк доступен для навигации.")

/obj/machinery/spaceship_navigation_beacon/process(seconds_per_tick)
	if(COOLDOWN_FINISHED(src, next_automatic_message_time) && radio)
		var/automatic_nav_message = "[src]. Сектор [z]. Маяк [locked ? "Заблокирован" : "Доступен"]. Координаты: [x] Долготы, [y] Широты."

		say("[automatic_nav_message]") // BANDASTATION EDIT

		COOLDOWN_START(src, next_automatic_message_time, automatic_message_cooldown)

// Item used to actually make nav beacons

/obj/item/folded_navigation_gigabeacon
	name = "compact radio navigation gigabeacon"
	desc = "Мобильный радионавигационный гигамаяк. Устройство, которое постоянно передает своё местоположение на частотах, обычно используемых для флотской навигации. Используется для создания путевых точек в неизведанных или неосвоенных районах. Необходимо разложить перед использованием."
	icon = 'icons/obj/machines/navigation_beacon.dmi'
	icon_state = "beacon_folded"

/obj/item/folded_navigation_gigabeacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 3 SECONDS, /obj/machinery/spaceship_navigation_beacon)

/obj/item/folded_navigation_gigabeacon/examine()
	.=..()
	. += span_notice("На задней панели есть инструкции на множестве галактических языков, подробно описывающих как установить прибор <b>руками</b> без специальных инструментов.")
	. += span_notice("На корпусе написана рабочая частота: '[FREQ_RADIO_NAV_BEACON / 10] кГц'.")
