/mob/living/simple_animal/eminence
	name = "Преосвященство"
	desc = "Светящийся шарик."
	icon = 'massmeta/icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mob_biotypes = list(MOB_SPIRIT)
	incorporeal_move = INCORPOREAL_MOVE_EMINENCE
	invisibility = INVISIBILITY_OBSERVER
	health = INFINITY
	maxHealth = INFINITY
	healable = FALSE
	sight = SEE_SELF
	throwforce = 0

	see_in_dark = 8
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 0, BURN = 0, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	status_flags = 0
	wander = FALSE
	density = FALSE
	movement_type = FLYING
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = FALSE
	hud_possible = list(ANTAG_HUD)
	hud_type = /datum/hud/revenant

	var/calculated_cogs = 0
	var/cogs = 0

	var/mob/living/selected_mob = null

/mob/living/simple_animal/eminence/ClickOn(atom/A, params)
	. = ..()
	if(!.)
		A.eminence_act(src)

/mob/living/simple_animal/eminence/proc/cog_change()
	//Calculate cogs
	if(calculated_cogs != GLOB.installed_integration_cogs)
		var/difference = GLOB.installed_integration_cogs - calculated_cogs
		calculated_cogs += difference
		cogs += difference
		to_chat(src, span_brass("Получаю [difference] шестерней!"))

//Cannot gib the eminence.
/mob/living/simple_animal/eminence/gib()
	return

/mob/living/simple_animal/eminence/UnarmedAttack(atom/A)
	return FALSE

/mob/living/simple_animal/eminence/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return FALSE

/mob/living/simple_animal/eminence/Initialize(mapload)
	. = ..()
	GLOB.clockcult_eminence = src
	//Add spells
	var/datum/action/cooldown/spell/eminence/reebe/spell_reebe = new(src)
	spell_reebe.Grant(src)
	var/datum/action/cooldown/spell/eminence/station/spell_station = new(src)
	spell_station.Grant(src)
	var/datum/action/cooldown/spell/eminence/servant_warp/spell_servant_warp = new(src)
	spell_servant_warp.Grant(src)
	var/datum/action/cooldown/spell/eminence/mass_recall/mass_recall = new(src)
	mass_recall.Grant(src)
	var/datum/action/cooldown/spell/eminence/linked_abscond/linked_abscond = new(src)
	linked_abscond.Grant(src)
	var/datum/action/cooldown/spell/eminence/trigger_event/trigger_event = new(src)
	trigger_event.Grant(src)
	//Wooooo, you are a ghost
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_TRUE_NIGHT_VISION, INNATE_TRAIT)
	cog_change()

/mob/living/simple_animal/eminence/Login()
	. = ..()
	var/datum/antagonist/servant_of_ratvar/S = add_servant_of_ratvar(src, silent=TRUE)
	S.prefix = CLOCKCULT_PREFIX_EMINENCE
	to_chat(src, span_large_brass("Я Преосвященство!"))
	to_chat(src, span_brass("Кликаем на разные штуки и они начинают работать!"))
	to_chat(src, span_brass("Большая часть заклинаний требует цель. Клик для выбора цели!"))

/mob/living/simple_animal/eminence/update_health_hud()
	return //we use no hud

/mob/living/simple_animal/eminence/med_hud_set_health()
	return //we use no hud

/mob/living/simple_animal/eminence/med_hud_set_status()
	return //we use no hud

/mob/living/simple_animal/eminence/ex_act(severity, target)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/eminence/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/eminence/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/eminence/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/eminence/say_verb(message as text)
	if(GLOB.say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, span_danger("Не могу говорить."))
		return
	if(message)
		hierophant_message(message, src, span="<span class='large_brass'>", say=FALSE)

/mob/living/simple_animal/eminence/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	return FALSE

/mob/living/simple_animal/eminence/Move(atom/newloc, direct)
	if(istype(get_area(newloc), /area/station/service/chapel))
		to_chat(usr, span_warning("Не могу покинуть святые земли!"))
		return
	. = ..()

/mob/living/simple_animal/eminence/bullet_act(obj/projectile/Proj)
	return BULLET_ACT_FORCE_PIERCE

/mob/living/simple_animal/eminence/proc/run_global_event(datum/round_event_control/E)
	E.preRunEvent()
	E.runEvent()
	SSevents.reschedule()

//Eminence abilities

/datum/action/cooldown/spell/eminence
	invocation_type = INVOCATION_NONE
	button_icon = 'massmeta/icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	spell_requirements = NONE
	cooldown_time = 0
	cooldown_reduction_per_rank = 0
	var/cog_cost

/datum/action/cooldown/spell/eminence/IsAvailable(feedback = FALSE)
	var/mob/living/simple_animal/eminence/eminence = owner
	if(!istype(eminence))
		return FALSE
	if(eminence.cogs < cog_cost)
		if(feedback)
			owner.balloon_alert(owner, "not enough cogs!")
		return FALSE
	return ..()

/datum/action/cooldown/spell/eminence/proc/consume_cogs(mob/living/simple_animal/eminence/eminence)
	eminence?.cogs -= cog_cost

//=====Warp to Reebe=====
/datum/action/cooldown/spell/eminence/reebe
	name = "Вернуться на Риби"
	desc = "Телепортирует меня на Риби."
	button_icon_state = "Abscond"

/datum/action/cooldown/spell/eminence/reebe/cast(atom/cast_on)
	. = ..()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.celestial_gateway
	if(G)
		owner.forceMove(get_turf(G))
		SEND_SOUND(owner, sound('sound/magic/magic_missile.ogg'))
		flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(owner, span_warning("Ой-ой!"))

//=====Warp to station=====
/datum/action/cooldown/spell/eminence/station
	name = "Перейти к станции"
	desc = "Телепортировать себя к станции."
	button_icon_state = "warp_down"

/datum/action/cooldown/spell/eminence/station/cast(atom/cast_on)
	. = ..()
	if(!is_station_level(owner.z))
		owner.forceMove(get_turf(pick(GLOB.generic_event_spawns)))
		SEND_SOUND(owner, sound('sound/magic/magic_missile.ogg'))
		flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)
	else
		to_chat(owner, span_warning("Да я уже на станции!"))

//=====Teleport to servant=====
/datum/action/cooldown/spell/eminence/servant_warp
	name = "Перейти к служителю"
	desc = "Телепортировать себя к нему."
	button_icon_state = "Spatial Warp"

/datum/action/cooldown/spell/eminence/servant_warp/cast(atom/cast_on)
	. = ..()
	//Get a list of all servants
	var/choice = tgui_input_list(owner, "Выберем же его", "Перемещение к...", GLOB.all_servants_of_ratvar)
	if(!choice)
		return
	for(var/mob/living/L in GLOB.all_servants_of_ratvar)
		if(L.name == choice)
			choice = L
			break
	if(!isliving(choice))
		to_chat(owner, span_warning("Не могу!"))
		return
	var/mob/living/M = choice
	if(!is_servant_of_ratvar(M))
		to_chat(owner, span_warning("Это больше не служитель Ратвара!"))
		return
	var/turf/T = get_turf(M)
	owner.forceMove(get_turf(T))
	SEND_SOUND(owner, sound('sound/magic/magic_missile.ogg'))
	flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)

//=====Mass Recall=====
/datum/action/cooldown/spell/eminence/mass_recall
	name = "Инициировать массовый призыв"
	desc = "Инициирует массовый призыв, возвращая всех к ковчегу. ОДНОРАЗОВОЕ!"
	button_icon_state = "Spatial Gateway"

/datum/action/cooldown/spell/eminence/mass_recall/cast(atom/cast_on)
	. = ..()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/C = GLOB.celestial_gateway
	if(!C)
		return
	C.begin_mass_recall()
	var/datum/action/cooldown/spell/eminence/mass_recall/mass_recall = locate() in owner.actions
	QDEL_NULL(mass_recall)

//=====Linked Abscond=====
/datum/action/cooldown/spell/eminence/linked_abscond
	name = "Связанное возвышение"
	desc = "Телепортирует цель на Риби, если она не будет двигаться 7 секунд. Стоит 1 шестерню."
	button_icon_state = "Linked Abscond"
	cooldown_time = 180 SECONDS
	cog_cost = 1

/datum/action/cooldown/spell/eminence/linked_abscond/IsAvailable(feedback = FALSE)
	if(!..())
		return FALSE
	var/mob/living/simple_animal/eminence/E = owner
	if(!istype(E))
		return FALSE
	if(E.selected_mob && is_servant_of_ratvar(E.selected_mob))
		return TRUE
	return ..()

/datum/action/cooldown/spell/eminence/linked_abscond/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/eminence/E = owner
	if(!istype(E))
		to_chat(E, span_brass("Я Преосвященство! (ЧТО-ТО СЛОМАЛОСЬ)"))
		return FALSE
	if(!E.selected_mob || !is_servant_of_ratvar(E.selected_mob))
		E.selected_mob = null
		to_chat(owner, span_neovgre("Нужно бы выбрать цель для начала."))
		return FALSE
	var/mob/living/L = E.selected_mob
	if(!istype(L))
		to_chat(E, span_brass("Не могу взаимодействовать с этим!"))
		return FALSE
	to_chat(E, span_brass("Начинаю процесс возвышения [L]..."))
	to_chat(L, span_brass("Преосвященство возвышает меня..."))
	L.visible_message(span_warning("[L] вспыхивает."))
	if(do_after(E, 70, target=L))
		L.visible_message(span_warning("[L] исчезает!"))
		var/turf/T = get_turf(pick(GLOB.servant_spawns))
		try_warp_servant(L, T, FALSE)
		consume_cogs(E)
		return TRUE
	else
		to_chat(E, span_brass("Не вышло возвысить [L]."))
		return FALSE


//Trigger event
/datum/action/cooldown/spell/eminence/trigger_event
	name = "Манипуляция с реальностью"
	desc = "Меняем реальность используя окружение. Стоит 5 шестерёнок."
	button_icon_state = "Geis"
	cooldown_time = 300 SECONDS
	cog_cost = 5

/datum/action/cooldown/spell/eminence/trigger_event/cast(atom/cast_on)
	. = ..()
	var/picked_event = tgui_input_list(owner, "Что мы запустим?", "Манипуляция с реальностью", list(
		"Anomaly",
		"Brand Intelligence",
		"Camera Failure",
		"Communications Blackout",
		"Disease Outbreak",
		"Electrical Storm",
		"False Alarm",
		"Grid Check",
		"Mass Hallucination",
		"Processor Overload",
		"Radiation Storm"
	))
	if(!IsAvailable())
		return FALSE
	if(!picked_event)
		return FALSE
	if(picked_event == "Anomaly")
		picked_event = pick("Anomaly: Energetic Flux", "Anomaly: Pyroclastic", "Anomaly: Gravitational", "Anomaly: Bluespace")
	//Reschedule events
	//Get the picked event
	for(var/datum/round_event_control/E in SSevents.control)
		if(E.name == picked_event)
			var/mob/living/simple_animal/eminence/eminence = owner
			INVOKE_ASYNC(eminence, /mob/living/simple_animal/eminence.proc/run_global_event, E)
			consume_cogs(owner)
			return TRUE

/mob/living/eminence_act(mob/living/simple_animal/eminence/eminence)
	if(is_servant_of_ratvar(src) && !iseminence(src))
		eminence.selected_mob = src
		to_chat(eminence, span_brass("Выбираю [src]."))

/obj/machinery/light_switch/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("Начинаю манипулировать с [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		interact(eminence)

/obj/machinery/flasher/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("Начинаю манипулировать с [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		if(anchored)
			flash()

/obj/machinery/button/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("Начинаю манипулировать с [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		attack_hand(eminence)

/obj/machinery/firealarm/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	to_chat(usr, span_brass("Начинаю манипулировать с [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		attack_hand(eminence)

/obj/machinery/power/apc/eminence_act(mob/living/simple_animal/eminence/eminence)
	. = ..()
	ui_interact(eminence)

/obj/machinery/door/airlock/eminence_act(mob/living/simple_animal/eminence/eminence)
	..()
	to_chat(usr, span_brass("Начинаю манипулировать с [src]!"))
	if(do_after(eminence, 20, target=get_turf(eminence)))
		if(welded)
			to_chat(eminence, text("Шлюз заварен!"))
		else if(locked)
			to_chat(eminence, text("Болты опущены!"))
		else if(!density)
			close()
		else
			open()
