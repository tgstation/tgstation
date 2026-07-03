

/datum/round_event_control/shuttle_insurance
	name = "Shuttle Insurance"
	typepath = /datum/round_event/shuttle_insurance
	max_occurrences = 1
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "A sketchy but legit insurance offer."

/datum/round_event_control/shuttle_insurance/can_spawn_event(players, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	if(!SSeconomy.get_dep_account(ACCOUNT_CAR))
		return FALSE //They can't pay?
	if(SSshuttle.shuttle_purchased == SHUTTLEPURCHASE_FORCED)
		return FALSE //don't do it if there's nothing to insure
	if(istype(SSshuttle.emergency, /obj/docking_port/mobile/emergency/shuttle_build))
		return FALSE //this shuttle prevents the catastrophe event from happening making this event effectively useless
	if(EMERGENCY_AT_LEAST_DOCKED)
		return FALSE //catastrophes won't trigger so no point
	return TRUE

/datum/round_event/shuttle_insurance
	var/ship_name = "\"In the Unlikely Event\""
	var/datum/comm_message/insurance_message
	var/insurance_evaluation = 0

/datum/round_event/shuttle_insurance/announce(fake)
	priority_announce("Входящий подпространственный вызов. Защищенный канал открыт на всех коммуникационных консолях.", "Входящее сообщение", SSstation.announcer.get_rand_report_sound())

/datum/round_event/shuttle_insurance/setup()
	ship_name = pick(strings(PIRATE_NAMES_FILE, "rogue_names"))
	for(var/shuttle_id in SSmapping.shuttle_templates)
		var/datum/map_template/shuttle/template = SSmapping.shuttle_templates[shuttle_id]
		if(template.name == SSshuttle.emergency.name) //found you slackin
			insurance_evaluation = template.credit_cost/2
			break
	if(!insurance_evaluation)
		insurance_evaluation = 5000 //gee i dunno

/datum/round_event/shuttle_insurance/start()
	insurance_message = new("Страховка шаттла", "Привет, приятель, говорит капитан судна [ship_name]. Не могу не заметить, что у тебя там дикий и сумасшедший шаттл БЕЗ СТРАХОВКИ! Безумие! А что, если с ним что-нибудь случится?! Мы провели быструю оценку тарифов в этом секторе и возьмем всего [insurance_evaluation] за страховку вашего шаттла в случае любой катастрофы.", list("Приобрести страховку.","Отклонить предложение."))
	insurance_message.answer_callback = CALLBACK(src, PROC_REF(answered))
	GLOB.communications_controller.send_message(insurance_message, unique = TRUE)

/datum/round_event/shuttle_insurance/proc/answered()
	if(EMERGENCY_AT_LEAST_DOCKED)
		priority_announce("Друзья, вы опоздали с покупкой страховки. Наши агенты уже покинули ваш сектор.",sender_override = ship_name, color_override = "red")
		return
	if(insurance_message && insurance_message.answered == 1)
		var/datum/bank_account/station_balance = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(!station_balance?.adjust_money(-insurance_evaluation))
			priority_announce("Вы не прислали нам достаточно денег за страховку шаттла. На языке космических дилетантов это считается мошенничеством. Мы оставим ваши деньги себе, мошенники!", sender_override = ship_name, color_override = "red")
			return
		priority_announce("Благодарим вас за покупку страховки для шаттла!", sender_override = ship_name, color_override = "red")
		SSshuttle.shuttle_insurance = TRUE
