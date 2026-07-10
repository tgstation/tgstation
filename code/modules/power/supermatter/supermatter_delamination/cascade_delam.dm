/datum/sm_delam/cascade
	name = "resonance cascade"

/datum/sm_delam/cascade/can_select(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.is_main_engine)
		return FALSE
	var/total_moles = sm.absorbed_gasmix.total_moles()
	if(total_moles < MOLE_PENALTY_THRESHOLD * sm.absorption_ratio)
		return FALSE
	for (var/gas_path in list(/datum/gas/antinoblium, /datum/gas/hypernoblium))
		var/percent = sm.gas_percentage[gas_path]
		if(!percent || percent < 0.4)
			return FALSE
	return TRUE

/datum/sm_delam/cascade/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(!..())
		return FALSE

	if(!announcement_triggered)
		announce_cascade(sm)

	sm.radio.talk_into(
		sm,
		"ОПАСНОСТЬ: ЧАСТОТА КОЛЕБАНИЙ ГИПЕРСТРУКТУРЫ ВЫШЛА ЗА ГРАНИЦЫ.",
		sm.damage >= sm.emergency_point ? sm.emergency_channel : sm.warning_channel
	)
	var/list/messages = list(
		"Пространство, кажется, искажается вокруг вас...",
		"Вы слышите пронзительный звон.",
		"Вы ощущаете покалывание, бегущее по спине.",
		"Что-то определённо не так.",
		"Вас накрывает волна тревожного предчувствия.",
	)
	dispatch_announcement_to_players(span_danger(pick(messages)), should_play_sound = FALSE)

	return TRUE

/datum/sm_delam/cascade/on_select(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	sm.warp = new(sm)
	sm.vis_contents += sm.warp
	animate(sm.warp, time = 1, transform = matrix().Scale(0.5,0.5))
	animate(time = 9, transform = matrix())

/datum/sm_delam/cascade/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	. = ..()
	message_admins("[ADMIN_VERBOSEJMP(sm)] will no longer cascade.")
	sm.vis_contents -= sm.warp
	QDEL_NULL(sm.warp)

/datum/sm_delam/cascade/delaminate(obj/machinery/power/supermatter_crystal/sm)
	log_delamination(sm)
	effect_explosion(sm)
	effect_emergency_state()
	effect_cascade_demoralize()
	priority_announce("В вашем секторе произошло событие резонансного сдвига типа «С». Сканирование указывает на локальный поток колебаний, влияющий на пространственную и гравитационную субструктуру. \
		Образовалось несколько резонансных точек. Пожалуйста, ожидайте.", "Ассоциация Обсерваторий Нанотрейзен", ANNOUNCER_SPANOMALIES)
	sleep(2 SECONDS)
	effect_strand_shuttle()
	sleep(5 SECONDS)
	var/obj/cascade_portal/rift = effect_evac_rift_start()
	RegisterSignal(rift, COMSIG_QDELETING, PROC_REF(end_round_holder))
	SSsupermatter_cascade.can_fire = TRUE
	SSsupermatter_cascade.cascade_initiated = TRUE
	effect_crystal_mass(sm, rift)
	return ..()

/datum/sm_delam/cascade/examine(obj/machinery/power/supermatter_crystal/sm)
	return list(span_bolddanger("The crystal is vibrating at immense speeds, warping space around it!"))

/datum/sm_delam/cascade/overlays(obj/machinery/power/supermatter_crystal/sm)
	return list()

/datum/sm_delam/cascade/count_down_messages(obj/machinery/power/supermatter_crystal/sm)
	var/list/messages = list()
	messages += "РАССЛОЕНИЕ КРИСТАЛЛА НЕИЗБЕЖНО. Суперматерия достигла критического нарушения целостности. Превышены пределы гармонических частот. Поле дестабилизации причинности не может быть задействовано."
	messages += "Гиперструктура кристалла возвращается к безопасным рабочим параметрам. Гармоническая частота восстановлена в пределах аварийных границ. Запущен антирезонансный фильтр."
	messages += "ожидайте резонансно-индуцированной стабилизации."
	return messages

/datum/sm_delam/cascade/proc/announce_cascade(obj/machinery/power/supermatter_crystal/sm)
	if(QDELETED(sm))
		return FALSE
	if(!can_select(sm))
		return FALSE
	if(!sm.should_alert_common())
		return FALSE

	priority_announce("Внимание: Сканирование аномалий дальнего действия регистрирует отклонение от нормы в количестве гармонического потока, исходящего от \
	объекта в пределах [station_name()], может произойти резонансный коллапс.",
	"Nanotrasen Star Observation Association", 'sound/announcer/alarm/airraid.ogg')
	announcement_triggered = TRUE
	return TRUE

/// Signal calls cant sleep, we gotta do this.
/datum/sm_delam/cascade/proc/end_round_holder()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(effect_evac_rift_end))
