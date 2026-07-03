#define PARTY_COOLDOWN_LENGTH_MIN (6 MINUTES)
#define PARTY_COOLDOWN_LENGTH_MAX (12 MINUTES)

/datum/station_trait/lucky_winner
	name = "Счастливый победитель"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	show_in_report = TRUE
	report_message = "Ваша станция выиграла главный приз ежегодного благотворительного мероприятия. В бар будут периодически доставлять бесплатные закуски."
	trait_processes = TRUE
	COOLDOWN_DECLARE(party_cooldown)

/datum/station_trait/lucky_winner/on_round_start()
	. = ..()
	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

/datum/station_trait/lucky_winner/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, party_cooldown))
		return

	COOLDOWN_START(src, party_cooldown, rand(PARTY_COOLDOWN_LENGTH_MIN, PARTY_COOLDOWN_LENGTH_MAX))

	var/pizza_type_to_spawn = pick(list(
		/obj/item/pizzabox/margherita,
		/obj/item/pizzabox/mushroom,
		/obj/item/pizzabox/meat,
		/obj/item/pizzabox/vegetable,
		/obj/item/pizzabox/pineapple
	))

	var/area/bar_area = pick(GLOB.bar_areas)
	podspawn(list(
		"target" = pick(bar_area.contents),
		"path" = /obj/structure/closet/supplypod/teleporter, // BANDASTATION EDIT - Original: "path" = /obj/structure/closet/supplypod/centcompod,
		"spawn" = list(
			pizza_type_to_spawn,
			/obj/item/reagent_containers/cup/glass/bottle/beer = 6
		)
	))

#undef PARTY_COOLDOWN_LENGTH_MIN
#undef PARTY_COOLDOWN_LENGTH_MAX

/datum/station_trait/galactic_grant
	name = "Галактический грант"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Ваша станция получила специальный грант. Вашему отделу снабжения выделены дополнительные средства."

/datum/station_trait/galactic_grant/on_round_start()
	var/datum/bank_account/cargo_bank = SSeconomy.get_dep_account(ACCOUNT_CAR)
	cargo_bank.adjust_money(rand(2000, 5000))

/datum/station_trait/premium_internals_box
	name = "Премиальные коробки"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Коробки экипажа для снаряжения вашей команды были увеличены в размерах и заполнены дополнительным снаряжением."
	trait_to_give = STATION_TRAIT_PREMIUM_INTERNALS

/datum/station_trait/bountiful_bounties
	name = "Щедрые награды"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Похоже, коллекционеры в этой системе особенно заинтересованы в наградах и готовы заплатить больше, чтобы увидеть их выполнение."

/datum/station_trait/bountiful_bounties/on_round_start()
	SSeconomy.bounty_modifier *= 1.2

///A positive station trait that scatters a bunch of lit glowsticks throughout maintenance
/datum/station_trait/glowsticks
	name = "Вечеринка со светящимися палочками"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 2
	show_in_report = TRUE
	report_message = "У нас в запасе имелось много светящихся палочек, поэтому мы разбросали часть из них по техническим тоннелям (ещё пару напольный ламп)."

/datum/station_trait/glowsticks/New()
	..()
	RegisterSignal(SSticker, COMSIG_TICKER_ENTER_PREGAME, PROC_REF(on_pregame))

/datum/station_trait/glowsticks/proc/on_pregame(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(light_up_the_night))

/datum/station_trait/glowsticks/proc/light_up_the_night()
	var/list/glowsticks = list(
		/obj/item/flashlight/glowstick,
		/obj/item/flashlight/glowstick/red,
		/obj/item/flashlight/glowstick/blue,
		/obj/item/flashlight/glowstick/cyan,
		/obj/item/flashlight/glowstick/orange,
		/obj/item/flashlight/glowstick/yellow,
		/obj/item/flashlight/glowstick/pink,
	)
	for(var/area/station/maintenance/maint in GLOB.areas)
		var/list/turfs = get_area_turfs(maint)
		for(var/i in 1 to round(length(turfs) * 0.115))
			CHECK_TICK
			var/turf/open/chosen = pick_n_take(turfs)
			if(!istype(chosen))
				continue
			var/skip_this = FALSE
			for(var/atom/movable/mov as anything in chosen) //stop glowing sticks from spawning on windows
				if(mov.density && !(mov.pass_flags_self & LETPASSTHROW))
					skip_this = TRUE
					break
			if(skip_this)
				continue
			if(prob(3.4)) ///Rare, but this is something that can survive past the lifespawn of glowsticks.
				new /obj/machinery/light/floor(chosen)
				continue
			var/stick_type = pick(glowsticks)
			var/obj/item/flashlight/glowstick/stick = new stick_type(chosen, rand(10, 45))
			///we want a wider range, otherwise they'd all burn out in about 20 minutes.
			stick.turn_on()

/datum/station_trait/strong_supply_lines
	name = "Сильные линии снабжения"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Цены в этой системе занижены. ПОКУПАЙТЕ-ПОКУПАЙТЕ-ПОКУПАЙТЕ!"
	blacklist = list(/datum/station_trait/distant_supply_lines)

/datum/station_trait/strong_supply_lines/on_round_start()
	SSeconomy.pack_price_modifier *= 0.8

/datum/station_trait/filled_maint
	name = "Заполненные технические тоннели"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Наши рабочие случайно забыли часть своих личных вещей в технических тоннелях."
	blacklist = list(/datum/station_trait/empty_maint)
	trait_to_give = STATION_TRAIT_FILLED_MAINT

	// This station trait is checked when loot drops initialize, so it's too late
	can_revert = FALSE

/datum/station_trait/quick_shuttle
	name = "Быстрый шаттл"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "Благодаря близости к нашей станции снабжения, грузовой шаттл быстрее доставит груз в отдел снабжения."
	blacklist = list(/datum/station_trait/slow_shuttle)

/datum/station_trait/quick_shuttle/on_round_start()
	. = ..()
	SSshuttle.supply.callTime *= 0.5

/datum/station_trait/deathrattle_department
	name = "отдел с предсмертным хрипом"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	abstract_type = /datum/station_trait/deathrattle_department
	blacklist = list(/datum/station_trait/deathrattle_all)

	var/department_to_apply_to
	var/department_name = "department"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_department/New()
	. = ..()
	deathrattle_group = new("[department_name] group")
	blacklist += subtypesof(/datum/station_trait/deathrattle_department) - type //All but ourselves
	report_message = "Всем сотрудникам [department_name] был установлен имплант, который будет оповещать друг друга в случае смерти одного из них. Это должно повысить безопасность труда!"
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))


/datum/station_trait/deathrattle_department/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	if(!(job.departments_bitflags & department_to_apply_to))
		return

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)


/datum/station_trait/deathrattle_department/service
	name = "Отдел обслуживания с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SERVICE
	department_name = "Service"

/datum/station_trait/deathrattle_department/cargo
	name = "Отдел снабжения с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_CARGO
	department_name = "Cargo"

/datum/station_trait/deathrattle_department/engineering
	name = "Инженерный отдел с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_ENGINEERING
	department_name = "Engineering"

/datum/station_trait/deathrattle_department/command
	name = "Командование с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_COMMAND
	department_name = "Command"

/datum/station_trait/deathrattle_department/science
	name = "Научный отдел с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SCIENCE
	department_name = "Science"

/datum/station_trait/deathrattle_department/security
	name = "Отдел безопасности с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_SECURITY
	department_name = "Security"

/datum/station_trait/deathrattle_department/medical
	name = "Медицинский отдел с предсмертным хрипом"
	weight = 1
	department_to_apply_to = DEPARTMENT_BITFLAG_MEDICAL
	department_name = "Medical"

/datum/station_trait/deathrattle_all
	name = "Вся станция с предсмертным хрипом"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "Всем сотрудникам станции имплантировали устройство, которое будет оповещать друг друга в случае смерти одного из них. Это должно повысить безопасность труда!"
	var/datum/deathrattle_group/deathrattle_group

/datum/station_trait/deathrattle_all/New()
	. = ..()
	deathrattle_group = new("station group")
	blacklist = subtypesof(/datum/station_trait/deathrattle_department)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/deathrattle_all/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/obj/item/implant/deathrattle/implant_to_give = new()
	deathrattle_group.register(implant_to_give)
	implant_to_give.implant(spawned, spawned, TRUE, TRUE)

/datum/station_trait/cybernetic_revolution
	name = "Кибернетическая революция"
	trait_type = STATION_TRAIT_POSITIVE
	show_in_report = TRUE
	weight = 1
	report_message = "Новые тренды кибернетики добрались и до станции! У каждого есть какой-нибудь кибернетический имплант."
	trait_to_give = STATION_TRAIT_CYBERNETIC_REVOLUTION
	/// List of all job types with the cybernetics they should receive.
	var/static/list/job_to_cybernetic = list(
		/datum/job/assistant = /obj/item/organ/heart/cybernetic, //real cardiac
		/datum/job/atmospheric_technician = /obj/item/organ/cyberimp/mouth/breathing_tube,
		/datum/job/bartender = /obj/item/organ/liver/cybernetic/tier3,
		/datum/job/bitrunner = /obj/item/organ/eyes/robotic/thermals,
		/datum/job/botanist = /obj/item/organ/cyberimp/chest/nutriment,
		/datum/job/captain = /obj/item/organ/heart/cybernetic/tier3,
		/datum/job/cargo_technician = /obj/item/organ/stomach/cybernetic/tier2,
		/datum/job/chaplain = /obj/item/organ/cyberimp/brain/anti_drop,
		/datum/job/chemist = /obj/item/organ/liver/cybernetic/tier2,
		/datum/job/chief_engineer = /obj/item/organ/cyberimp/chest/thrusters,
		/datum/job/chief_medical_officer = /obj/item/organ/cyberimp/chest/reviver,
		/datum/job/clown = /obj/item/organ/cyberimp/brain/anti_stun, //HONK!
		/datum/job/cook = /obj/item/organ/cyberimp/chest/nutriment/plus,
		/datum/job/coroner = /obj/item/organ/tongue/bone, //hes got a bone to pick with you
		/datum/job/curator = /obj/item/organ/cyberimp/brain/connector,
		/datum/job/detective = /obj/item/organ/lungs/cybernetic/tier3,
		/datum/job/doctor = /obj/item/organ/cyberimp/arm/toolkit/surgery,
		/datum/job/geneticist = /obj/item/organ/fly, //we don't care about implants, we have cancer.
		/datum/job/head_of_personnel = /obj/item/organ/eyes/robotic,
		/datum/job/head_of_security = /obj/item/organ/eyes/robotic/thermals,
		/datum/job/human_ai = /obj/item/organ/brain/cybernetic,
		/datum/job/janitor = /obj/item/organ/eyes/robotic/xray,
		/datum/job/lawyer = /obj/item/organ/heart/cybernetic/tier2,
		/datum/job/mime = /obj/item/organ/tongue/robot, //...
		/datum/job/paramedic = /obj/item/organ/cyberimp/eyes/hud/medical,
		/datum/job/prisoner = /obj/item/organ/eyes/robotic/shield,
		/datum/job/psychologist = /obj/item/organ/ears/cybernetic/whisper,
		/datum/job/pun_pun = /obj/item/organ/cyberimp/arm/strongarm,
		/datum/job/quartermaster = /obj/item/organ/stomach/cybernetic/tier3,
		/datum/job/research_director = /obj/item/organ/cyberimp/bci,
		/datum/job/roboticist = /obj/item/organ/cyberimp/eyes/hud/diagnostic,
		/datum/job/scientist = /obj/item/organ/ears/cybernetic,
		/datum/job/security_officer = /obj/item/organ/cyberimp/arm/toolkit/flash,
		/datum/job/shaft_miner = /obj/item/organ/monster_core/rush_gland,
		/datum/job/station_engineer = /obj/item/organ/cyberimp/arm/toolkit/toolset,
		/datum/job/warden = /obj/item/organ/cyberimp/eyes/hud/security,
		// BANDASTATION ADD - START
		/datum/job/nanotrasen_representative = /obj/item/organ/cyberimp/arm/toolkit/paperwork,
		/datum/job/blueshield = /obj/item/organ/cyberimp/arm/toolkit/flash,
		/datum/job/magistrate = /obj/item/organ/cyberimp/arm/toolkit/paperwork,
		/datum/job/explorer = /obj/item/organ/cyberimp/arm/toolkit/toolset,
		// BANDASTATION ADD - END
	)

/datum/station_trait/cybernetic_revolution/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_after_spawn))

/datum/station_trait/cybernetic_revolution/proc/on_job_after_spawn(datum/source, datum/job/job, mob/living/spawned, client/player_client)
	SIGNAL_HANDLER

	var/datum/quirk/body_purist/body_purist = /datum/quirk/body_purist
	if(initial(body_purist.name) in player_client.prefs.all_quirks)
		return
	var/cybernetic_type = job_to_cybernetic[job.type]
	if(!cybernetic_type)
		if(isAI(spawned))
			var/mob/living/silicon/ai/ai = spawned
			ai.eyeobj.relay_speech = TRUE //surveillance upgrade. the ai gets cybernetics too.
		return
	var/obj/item/organ/cybernetic = new cybernetic_type()
	cybernetic.Insert(spawned, special = TRUE, movement_flags = DELETE_IF_REPLACED)

/datum/station_trait/luxury_escape_pods
	name = "Роскошные спасательные капсулы"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	report_message = "В связи с хорошими показателями производительности мы снабдили вашу станцию роскошными спасательными капсулами."
	trait_to_give = STATION_TRAIT_BIGGER_PODS
	blacklist = list(/datum/station_trait/cramped_escape_pods)

/datum/station_trait/medbot_mania
	name = "Продвинутые медботы"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE
	report_message = "Медботы вашей станции получили обновление оборудования, что расширяет возможности лечения."
	trait_to_give = STATION_TRAIT_MEDBOT_MANIA

/datum/station_trait/random_event_weight_modifier/shuttle_loans
	name = "Арендованный шаттл"
	report_message = "Из-за участившихся пиратских нападений в вашем секторе в ближайшем космосе мало судов снабжения, готовых выполнить особые заказы. Ожидайте больше возможностей получить арендованный шаттл с немного более высокими выплатами."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 4
	event_control_path = /datum/round_event_control/shuttle_loan
	weight_multiplier = 2.5
	max_occurrences_modifier = 5 //All but one loan event will occur over the course of a round.
	trait_to_give = STATION_TRAIT_LOANER_SHUTTLE

/datum/station_trait/random_event_weight_modifier/wise_cows
	name = "Вторжение мудрых коров"
	report_message = "Блюспейс показания гармоник засекли необычные интерполяционные сигналы между вашим сектором и сельскохозяйственным сектором MMF-D-02. Ожидайте увеличения числа встреч с коровами."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 1
	event_control_path = /datum/round_event_control/wisdomcow
	weight_multiplier = 3
	max_occurrences_modifier = 10 //lotta cows

/datum/station_trait/random_event_weight_modifier/wise_cows/get_pulsar_message()
	var/advisory_string = "Уровень предупреждения: <b>Планета коров</b></center><BR>" //We're gonna go fast and we're gonna go far.
	advisory_string += "Уровень предупреждения для вашего сектора — планета коров. Мы не совсем понимаем, что это значит — модель, которую мы используем для создания отчётов об угрозах, раньше не давала подобных результатов. Берегитесь коров, наверное? Удачи!"
	return advisory_string

/datum/station_trait/bright_day
	name = "Яркий день"
	report_message = "Звёзды светят ярко, а облаков меньше, чем обычно. На поверхности Ледяной Луны сегодня ясный день."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	show_in_report = TRUE
	trait_flags = STATION_TRAIT_PLANETARY
	trait_to_give = STATION_TRAIT_BRIGHT_DAY

/datum/station_trait/shuttle_sale
	name = "Распродажа шаттлов"
	report_message = "Команда экстренного реагирования Нанотрейзен отмечает рекордное количество вызовов шаттлов за последний квартал. На некоторые эвакуационные шаттлы действуют скидки!"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 4
	trait_to_give = STATION_TRAIT_SHUTTLE_SALE
	show_in_report = TRUE

/datum/station_trait/missing_wallet
	name = "Потерянный кошелек"
	report_message = "Ремонтный техник оставил свой бумажник где-то в шкафчике. Он был бы очень признателен, если бы вы нашли и вернули его по окончании смены."
	trait_type = STATION_TRAIT_POSITIVE
	weight = 5
	cost = STATION_TRAIT_COST_LOW
	show_in_report = TRUE

/datum/station_trait/missing_wallet/on_round_start()
	. = ..()

	var/obj/structure/closet/locker_to_fill = pick(GLOB.roundstart_station_closets)

	var/obj/item/storage/wallet/new_wallet = new(locker_to_fill)

	new /obj/item/stack/spacecash/c500(new_wallet)
	if(prob(25)) //Jackpot!
		new /obj/item/stack/spacecash/c1000(new_wallet)

	new /obj/item/card/id/advanced/technician_id(new_wallet)
	new_wallet.refreshID()

	if(prob(35))
		report_message += " Техник сообщает, что в последний раз помнит, что кошелек был рядом с [get_area_name(new_wallet)]."

	message_admins("A missing wallet has been placed in the [locker_to_fill] locker, in the [get_area_name(locker_to_fill)] area.")

/obj/item/card/id/advanced/technician_id
	name = "Repair Technician ID"
	desc = "Ремонтный техник? У нас здесь такого нет, одни ленивые инженеры! Видимо, это оставили на промежуточной смене..."
	registered_name = "Pluoxium LXVII"
	registered_age = 67
	trim = /datum/id_trim/technician_id

/datum/id_trim/technician_id
	access = list(ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MAINT_TUNNELS)
	assignment = "Repair Technician"
	trim_state = "trim_stationengineer"
	department_color = COLOR_ASSISTANT_GRAY

/// Spawns assistants with some gear, either gimmicky or functional. Maybe, one day, it will inspire an assistant to do something productive or fun
/datum/station_trait/assistant_gimmicks
	name = "Пилотный проект «Снаряжённые ассистенты»"
	report_message = "Отдел по работе с ассистентами Нанотрейзен проводит экспериментальную проверку, чтобы выяснить, поможет ли различное ассистентское оборудование повысить производительность!"
	trait_type = STATION_TRAIT_POSITIVE
	weight = 3
	trait_to_give = STATION_TRAIT_ASSISTANT_GIMMICKS
	show_in_report = TRUE
	blacklist = list(/datum/station_trait/colored_assistants)

/datum/station_trait/random_event_weight_modifier/assistant_gimmicks/get_pulsar_message()
	var/advisory_string = "Уровень предупреждения: <b>Серое небо</b></center><BR>"
	advisory_string += "Уровень предупреждения в вашем секторе — Серое небо. Наши датчики фиксируют аномальную активность среди ассистентов, назначенных на вашу станцию. Рекомендуем вам внимательно следить за хранилищем инструментов, мостиком, техническим хранилищем и бригом на предмет скопления людей или мелкого воровства."
	return advisory_string
