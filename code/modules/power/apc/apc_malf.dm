/obj/machinery/power/apc/proc/get_malf_status(mob/living/silicon/ai/malf)
	if(!istype(malf) || !malf.malf_picker)
		return APC_AI_NO_MALF
	if(malfai != malf)
		return APC_AI_NO_HACK
	if(occupier == malf)
		return APC_AI_HACK_SHUNT_HERE
	if(istype(malf.loc, /obj/machinery/power/apc))
		return APC_AI_HACK_SHUNT_ANOTHER
	return APC_AI_HACK_NO_SHUNT

/obj/machinery/power/apc/proc/malfhack(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(get_malf_status(malf) != APC_AI_NO_HACK)
		return
	if(malf.malfhacking)
		to_chat(malf, span_warning("Вы уже взламываете ЛКП!"))
		return
	to_chat(malf, span_notice("Запуск взлома систем ЛКП. Это займет некоторое время, в течении которого вы не сможете выполнять другие действия."))
	malf.malfhack = src
	malf.malfhacking = addtimer(CALLBACK(malf, TYPE_PROC_REF(/mob/living/silicon/ai/, malfhacked), src), 30 SECONDS + 10*malf.hacked_apcs.len SECONDS, TIMER_STOPPABLE)

	var/atom/movable/screen/alert/hackingapc/hacking_apc
	hacking_apc = malf.throw_alert(ALERT_HACKING_APC, /atom/movable/screen/alert/hackingapc)
	hacking_apc.target = src

/obj/machinery/power/apc/proc/malfoccupy(mob/living/silicon/ai/malf)
	if(!istype(malf))
		return
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, span_warning("Вы должны сначала эвакуироваться из вашего текущего ЛКП!"))
		return
	if(!malf.can_shunt)
		to_chat(malf, span_warning("Перемещение невозможно!"))
		return
	if(!is_station_level(z))
		return
	INVOKE_ASYNC(src, PROC_REF(malfshunt), malf)

/obj/machinery/power/apc/proc/malfshunt(mob/living/silicon/ai/malf)
	var/confirm = tgui_alert(malf, "Вы уверены, что хотите переместиться? Это извлечёт вас из ядра!", "Переместиться в [name]?", list("Да", "Нет"))
	if(confirm != "Да")
		return
	malf.ShutOffDoomsdayDevice()
	occupier = malf
	if (isturf(malf.loc)) // create a deactivated AI core if the AI isn't coming from an emergency mech shunt
		malf.create_core_link(new /obj/structure/ai_core(malf.loc, CORE_STATE_FINISHED, malf.make_mmi()))
	malf.forceMove(src) // move INTO the APC, not to its tile
	if(!findtext(occupier.name, "Копия ЛКП"))
		occupier.name = "Копия ЛКП [malf.name]"
	malf.shunted = TRUE
	occupier.eyeobj.name = "[occupier.name] (Глаз ИИ)"
	occupier.eyeobj.forceMove(src.loc)
	for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
		disk_pinpointers.switch_mode_to(TRACK_MALF_AI) //Pinpointer will track the shunted AI
	var/datum/action/innate/core_return/return_action = new
	return_action.Grant(occupier)
	occupier.cancel_camera()

/obj/machinery/power/apc/proc/malfvacate(forced)
	if(!occupier)
		return
	SEND_SIGNAL(occupier, COMSIG_SILICON_AI_VACATE_APC, occupier)
	SEND_SIGNAL(src, COMSIG_SILICON_AI_VACATE_APC, occupier)
	if(forced)
		occupier.forceMove(drop_location())
		INVOKE_ASYNC(occupier, TYPE_PROC_REF(/mob/living, death))
		occupier.gib(DROP_ALL_REMAINS)
		occupier = null
		return

	if(!occupier.nuking) //Pinpointers go back to tracking the nuke disk, as long as the AI (somehow) isn't mid-nuking.
		for(var/obj/item/pinpointer/nuke/disk_pinpointers in GLOB.pinpointer_list)
			disk_pinpointers.switch_mode_to(TRACK_NUKE_DISK)
			disk_pinpointers.alert = FALSE

	if(occupier.linked_core)
		occupier.shunted = FALSE
		occupier.resolve_core_link()
		occupier = null
	else
		stack_trace("An AI: [occupier] has vacated an APC with no linked core and without being gibbed.")


/obj/machinery/power/apc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(card.AI)
		to_chat(user, span_warning("[card.declent_ru(NOMINATIVE)] уже занята!"))
		return FALSE
	if(!occupier)
		to_chat(user, span_warning("В [declent_ru(DATIVE)] ничего нет для передачи!"))
		return FALSE
	if(!occupier.mind || !occupier.client)
		to_chat(user, span_warning("[occupier] неактивен или уничтожен!"))
		return FALSE
	if(occupier.linked_core) //if they have an active linked_core, they can't be transferred from an APC
		to_chat(user, span_warning("[occupier] блокирует все попытки передачи!") )
		return FALSE
	if(transfer_in_progress)
		to_chat(user, span_warning("Передача уже выполняется!"))
		return FALSE
	if(interaction != AI_TRANS_TO_CARD || occupier.stat)
		return FALSE
	var/turf/user_turf = get_turf(user)
	if(!user_turf)
		return FALSE
	transfer_in_progress = TRUE
	user.visible_message(span_notice("[user] вставляет [card.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]..."), span_notice("Процесс передачи запущен. Отправлен запрос на подтверждение ИИ..."))
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	SEND_SOUND(occupier, sound('sound/announcer/notice/notice2.ogg')) //To alert the AI that someone's trying to card them if they're tabbed out
	if(tgui_alert(occupier, "[user] пытается переместить вас в [card.name]. Вы согласны с этим?", "Перемещение ИИ", list("Да - Переместить", "Нет - Остаться")) == "Нет - Остаться")
		to_chat(user, span_danger("ИИ отклонил запрос на передачу. Процесс прерван."))
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 50, TRUE)
		transfer_in_progress = FALSE
		return FALSE
	if(user.loc != user_turf)
		to_chat(user, span_danger("Местоположение изменено. Процесс прерван."))
		to_chat(occupier, span_warning("[user] отошёл! Передача отменена."))
		transfer_in_progress = FALSE
		return FALSE
	to_chat(user, span_notice("ИИ принял запрос. Передача сохранённого сознания в [card.declent_ru(ACCUSATIVE)]..."))
	to_chat(occupier, span_notice("Начало передачи. Вы будете перемещены в [card.declent_ru(ACCUSATIVE)] в ближайшее время."))
	if(!do_after(user, 5 SECONDS, target = src))
		to_chat(occupier, span_warning("[user] прервали! Передача отменена."))
		transfer_in_progress = FALSE
		return FALSE
	if(!occupier || !card)
		transfer_in_progress = FALSE
		return FALSE
	user.visible_message(span_notice("[user] перемещает [occupier] в [card.declent_ru(ACCUSATIVE)]!"), span_notice("Передача завершена! [occupier] теперь сохранён в [card.declent_ru(ACCUSATIVE)]."))
	to_chat(occupier, span_notice("Передача завершена! Вы были сохранены в [card.name] у [user]."))
	occupier.forceMove(card)
	card.AI = occupier
	occupier.shunted = FALSE
	occupier.cancel_camera()
	occupier = null
	transfer_in_progress = FALSE
	return TRUE
