/obj/item/implant/death_alarm
	name = "death alarm implant"
	actions_types = null
	/// Radio which is used for transmitting the alarm. Null by default and created on demand.
	var/obj/item/radio/my_radio = null

/obj/item/implant/death_alarm/Destroy()
	QDEL_NULL(my_radio)
	. = ..()

/obj/item/implant/death_alarm/implant(mob/living/target, mob/user, silent, force)
	. = ..()
	if(!.)
		return

	RegisterSignal(imp_in, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/death_alarm/removed(mob/living/source, silent, special)
	UnregisterSignal(imp_in, COMSIG_LIVING_DEATH)
	. = ..()

/obj/item/implant/death_alarm/activate()
	. = ..()
	var/turf/implanted_mob_turf = get_turf(imp_in)
	if(is_station_level(implanted_mob_turf.z) || is_mining_level(implanted_mob_turf.z))
		var/area/implanted_mob_area = get_area(imp_in)
		send_death_message("[imp_in.real_name] умер в [implanted_mob_area.name].")
	else
		send_death_message("[imp_in.real_name] умер за пределами действия сенсоров.")

/obj/item/implant/death_alarm/get_data()
	return {"
		<b>Характеристики импланта:</b>

		<b>Название:</b> Имплант оповещения о смерти

		<b>Срок службы:</b> Практически неограниченный

		<b>Важные замечания:</b> <font color='red'>Запрещено</font>

		<HR>
		<b>Подробности об импланте:</b>

		<b>Функция:</b> Автоматически отправляет сигнал тревоги в случае фатального состояния пользователя.
		Сигнал будет содержать информацию о возможном местоположении пользователя.

		<b>Отказ от ответственности:</b> Работоспособность может быть ограничена в зонах с сильными помехами или экранированием сигналов.
	"}

/obj/item/implant/death_alarm/proc/on_death(mob/user)
	SIGNAL_HANDLER

	activate()

/obj/item/implant/death_alarm/proc/send_death_message(message)
	PRIVATE_PROC(TRUE)

	setup_radio_if_not_exists()

	var/static/list/channels_for_alert = list(RADIO_CHANNEL_COMMAND, RADIO_CHANNEL_MEDICAL, RADIO_CHANNEL_SECURITY)
	for(var/channel in channels_for_alert)
		my_radio.talk_into(src, message, channel, list(SPAN_YELL), /datum/language/common)

/obj/item/implant/death_alarm/proc/setup_radio_if_not_exists()
	PRIVATE_PROC(TRUE)

	if(my_radio)
		return

	my_radio = new(src)
	my_radio.set_listening(FALSE)
	my_radio.freqlock = RADIO_FREQENCY_LOCKED
	my_radio.keyslot = new/obj/item/encryptionkey/ai()
	my_radio.recalculateChannels()

/obj/item/implanter/death_alarm
	name = "implanter (death_alarm)"
	imp_type = /obj/item/implant/death_alarm

/obj/item/implantcase/death_alarm
	name = "death alarm implant case"
	desc = "Стеклянный футляр, содержащий имплант-оповещатель о смерти."
	imp_type = /obj/item/implant/death_alarm
