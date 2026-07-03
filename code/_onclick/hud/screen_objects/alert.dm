//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want

/**
 *Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 *category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 *path is a type path of the actual alert type to throw
 *severity is an optional number that will be placed at the end of the icon_state for this alert
 *for example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 *new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 *flicks are forwarded to master
 *override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */
/mob/proc/throw_alert(category, type, severity, atom/new_master, override = FALSE, timeout_override, no_anim = FALSE)

	if(!category || QDELETED(src))
		return

	var/datum/weakref/master_ref
	if(isatom(new_master))
		master_ref = WEAKREF(new_master)
	var/atom/movable/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return thealert
		if(master_ref && thealert.master_ref && master_ref != thealert.master_ref)
			var/datum/current_master = thealert.master_ref.resolve()
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [current_master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(!thealert.timeout)
				// No need to update existing alert
				return thealert
			// Reset timeout of existing alert
			var/timeout = timeout_override || initial(thealert.timeout)
			addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), timeout)
			thealert.timeout = world.time + timeout - world.tick_lag
			return thealert
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
	thealert.owner = src

	if(new_master)
		thealert.master_ref = master_ref
		thealert.RegisterSignal(new_master, COMSIG_ATOM_UPDATE_APPEARANCE, TYPE_PROC_REF(/atom/movable/screen/alert, on_master_update_appearance))
		thealert.update_appearance()
	else if(severity)
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	if(!no_anim)
		thealert.transform = matrix(32, 0, MATRIX_TRANSLATE)
		animate(thealert, transform = matrix(), time = 1 SECONDS, easing = ELASTIC_EASING)
	if(timeout_override)
		thealert.timeout = timeout_override
	if(thealert.timeout)
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

// Proc to check for an alert
/mob/proc/has_alert(category)
	return !isnull(alerts[category])

/atom/movable/screen/alert
	icon = 'icons/hud/screen_alert.dmi'
	icon_state = "template"
	name = "Alert"
	desc = "Something seems to have gone wrong with this alert, so report this bug please"
	mouse_opacity = MOUSE_OPACITY_ICON
	/// do we glow to represent we do stuff when clicked
	var/clickable_glow = FALSE
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/owner //Alert owner

	/// Boolean. If TRUE, the Click() proc will attempt to Click() on the master first if there is a master.
	var/click_master = TRUE

	///If set true, instead of using the default icon file for screen alerts, it will use the hud's ui style
	var/use_user_hud_icon = USER_HUD_STYLE_IGNORE
	///If set, this overlay will be added to the icon.
	var/overlay_state
	///The file to fetch the overlay from
	var/overlay_icon = 'icons/hud/screen_alert.dmi'

/atom/movable/screen/alert/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	if(PERFORM_ALL_TESTS(focus_only/screen_alert_overlay) && overlay_state && !icon_exists(overlay_icon, overlay_state))
		stack_trace("overlay_state: \"[overlay_state || "null"]\" that couldn't be found overlay_icon: \"[overlay_icon || "null"]\"")
	if(clickable_glow)
		add_filter("clickglow", 2, outline_filter(color = COLOR_GOLD, size = 1))
		mouse_over_pointer = MOUSE_HAND_POINTER
	if(overlay_state)
		update_appearance()

/atom/movable/screen/alert/MouseEntered(location,control,params)
	. = ..()
	if(!QDELETED(src))
		openToolTip(usr,src,params,title = name,content = desc,theme = alerttooltipstyle)

/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)

/atom/movable/screen/alert/proc/on_master_update_appearance(datum/source)
	SIGNAL_HANDLER
	update_appearance()

/atom/movable/screen/alert/update_overlays()
	. = ..()
	var/atom/our_master = master_ref?.resolve()
	if(istype(our_master) && !QDELETED(our_master))
		. += add_atom_icon(our_master)
	if(overlay_state)
		. += mutable_appearance(overlay_icon, overlay_state)

///Returns a copy of the appearance of the atom, with its base pixel coordinates. Useful for overlays
/atom/movable/screen/alert/proc/add_atom_icon(atom/atom)
	var/mutable_appearance/atom_appearance = new(atom)
	atom_appearance.appearance_flags = KEEP_TOGETHER
	atom_appearance.layer = FLOAT_LAYER
	atom_appearance.plane = FLOAT_PLANE
	atom_appearance.dir = SOUTH
	atom_appearance.pixel_x = atom.base_pixel_x
	atom_appearance.pixel_y = atom.base_pixel_y
	atom_appearance.pixel_w = atom.base_pixel_w
	atom_appearance.pixel_z = atom.base_pixel_z
	return strip_appearance_underlays(atom_appearance)

/atom/movable/screen/alert/Click(location, control, params)
	SHOULD_CALL_PARENT(TRUE)

	..()
	if(!usr || !GET_CLIENT(usr) || usr != owner)
		return FALSE
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK)) // screen objects don't do the normal Click() stuff so we'll cheat
		to_chat(usr, boxed_message(jointext(examine(usr), "\n")))
		return FALSE
	if(!click_master)
		return TRUE
	var/datum/our_master = master_ref?.resolve()
	if(our_master)
		return usr.client.Click(our_master, location, control, params)

	return TRUE

/atom/movable/screen/alert/Destroy()
	. = ..()
	severity = 0
	master_ref = null
	owner = null
	screen_loc = ""

/atom/movable/screen/alert/examine(mob/user)
	return list(
		span_boldnotice(name),
		span_info(desc),
	)

//Gas alerts
// Gas alerts are continuously thrown/cleared by:
// * /obj/item/organ/lungs/proc/check_breath()
// * /mob/living/carbon/check_breath()
// * /mob/living/carbon/human/check_breath()
// * /datum/element/atmos_requirements/proc/on_non_stasis_life()
// * /mob/living/simple_animal/handle_environment()

/atom/movable/screen/alert/not_enough_oxy
	name = "Удушье (Нехватка O2)"
	desc = "Недостаток кислорода. Используйте средства защиты дыхания или найдите источник O2."
	icon_state = ALERT_NOT_ENOUGH_OXYGEN

/atom/movable/screen/alert/too_much_oxy
	name = "Удушье (O2)"
	desc = "Воздух перенасыщен кислородом! Используйте средства защиты дыхания или найдите место с воздухом."
	icon_state = ALERT_TOO_MUCH_OXYGEN

/atom/movable/screen/alert/not_enough_nitro
	name = "Удушье (Нехватка N2)"
	desc = "Недостаток азота. Используйте средства защиты дыхания или найдите источник N2."
	icon_state = ALERT_NOT_ENOUGH_NITRO

/atom/movable/screen/alert/too_much_nitro
	name = "Удушье (N2)"
	desc = "Воздух перенасыщен азотом! Используйте средства защиты дыхания или найдите место с воздухом."
	icon_state = ALERT_TOO_MUCH_NITRO

/atom/movable/screen/alert/not_enough_co2
	name = "Удушье (Нехватка CO2)"
	desc = "Недостаток углекислого газа. Используйте средства защиты дыхания или найдите источник CO2."
	icon_state = ALERT_NOT_ENOUGH_CO2

/atom/movable/screen/alert/too_much_co2
	name = "Удушье (CO2)"
	desc = "Воздух перенасыщен углекислым газом! Используйте средства защиты дыхания или найдите место с воздухом."
	icon_state = ALERT_TOO_MUCH_CO2

/atom/movable/screen/alert/not_enough_plas
	name = "Удушье (Нехватка плазмы)"
	desc = "Недостаток плазмы. Используйте средства защиты дыхания или найдите источник плазмы."
	icon_state = ALERT_NOT_ENOUGH_PLASMA

/atom/movable/screen/alert/too_much_plas
	name = "Удушье (Плазма)"
	desc = "Воздух отравлен плазмой! Используйте средства защиты дыхания или найдите место с воздухом."
	icon_state = ALERT_TOO_MUCH_PLASMA

/atom/movable/screen/alert/not_enough_n2o
	name = "Удушье (Нехватка N2O)"
	desc = "Недостаток оксида азота. Используйте средства защиты дыхания или найдите источник N2O."
	icon_state = ALERT_NOT_ENOUGH_N2O

/atom/movable/screen/alert/too_much_n2o
	name = "Удушье (N2O)"
	desc = "Воздух перенасыщен оксидом азота! Используйте средства защиты дыхания или найдите место с воздухом."
	icon_state = ALERT_TOO_MUCH_N2O

/atom/movable/screen/alert/not_enough_water
	name = "Обезвоживание (Нехватка H2O)"
	desc = "Вам не хватает воды! Окунитесь в воду (например, примите душ) или найдите место с водяным паром."
	icon_state = ALERT_NOT_ENOUGH_WATER

//End gas alerts

/atom/movable/screen/alert/bronchodilated
	name = "Bronchodilated"
	desc = "You feel like your lungs are larger than usual! You're taking deeper breaths!"
	icon_state = "bronchodilated"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_icon = 'icons/obj/medical/organs/organs.dmi'
	overlay_state = "lungs"

/atom/movable/screen/alert/bronchoconstricted
	name = "Bronchocontracted"
	desc = "You feel like your lungs are smaller than usual! You might need a higher pressure environment/internals to breathe!"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "bronchoconstricted"

/atom/movable/screen/alert/gross
	name = "Мерзко"
	desc = "Это было довольно противно..."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Очень мерзко"
	desc = "Вы чувствуете себя не очень хорошо..."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "ОТВРАЩЕНИЕ"
	desc = "Вас очень сильно мутит и, кажется, сейчас вас стошнит..."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "gross3"

/atom/movable/screen/alert/hot
	name = "Слишком горячо"
	desc = "Ваше тело нагрето до предела! Найдите место попрохладнее и снимите любую изолирующую одежду, например, пожарный костюм."
	icon_state = "hot"

/atom/movable/screen/alert/cold
	name = "Слишком холодно"
	desc = "Вы ужасно замерзли! Найдите что-нибудь потеплее и снимите любую изолирующую одежду, например, скафандр."
	icon_state = "cold"

/atom/movable/screen/alert/lowpressure
	name = "Низкое давление"
	desc = "Воздух вокруг опасно разрежен. Скафандр защитит вас."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "Высокое давление"
	desc = "Воздух вокруг опасно плотный. Противопожарный костюм защитит вас."
	icon_state = "highpressure"

/atom/movable/screen/alert/hypnosis
	name = "Гипноз"
	desc = "Что-то гипнотизирует вас, но вы не уверены, что именно."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "hypnosis"
	var/phrase

/atom/movable/screen/alert/mind_control
	name = "Контроль разума"
	desc = "Ваш разум захвачен! Нажмите, чтобы просмотреть команду контроля разума."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "mind_control"
	clickable_glow = TRUE
	var/command

/atom/movable/screen/alert/mind_control/Click()
	. = ..()
	if(!.)
		return
	to_chat(owner, span_mind_control("[command]"))

/atom/movable/screen/alert/embeddedobject
	name = "Застрявший предмет"
	desc = "Что-то застряло в вашей плоти и вызывает сильное кровотечение. Со временем оно может выпасть, но хирургическое вмешательство - \
		самый безопасный способ. Если готовы рискнуть, то осмотрите себя и нажмите на подчеркнутый пункт, чтобы извлечь предмет."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "embeddedobject"
	clickable_glow = TRUE

/atom/movable/screen/alert/embeddedobject/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/carbon_owner = owner
	return carbon_owner.check_self_for_injuries()

/atom/movable/screen/alert/negative
	name = "Отрицательная гравитация"
	desc = "Вас тянет вверх. Хотя Вам больше не придется беспокоиться о том, что упадете вниз, но можете случайно упасть вверх!"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "negative"

/atom/movable/screen/alert/weightless
	name = "Невесомость"
	desc = "Сила тяжести перестала влиять на вас, и вы бесцельно перемещаетесь в пространстве. Вам понадобится что-то большое и тяжелое, например, \
		стена или решетка, чтобы оттолкнуться, если захотите двигаться. Реактивный ранец обеспечит свободу движений. Пара магбутсов \
		позволит вам нормально передвигаться по полу. Если их нет, вы можете бросать предметы, пользоваться огнетушителем \
		или стрелять из оружия, чтобы передвигаться в соответствии с 3-м законом Ньютона."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "weightless"

/atom/movable/screen/alert/highgravity
	name = "Высокая гравитация"
	desc = "Вас давит высокая гравитация, из-за чего подбор предметов и передвижение замедлятся."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "paralysis"

/atom/movable/screen/alert/veryhighgravity
	name = "Сокрушительная гравитация"
	desc = "Вас давит высокая гравитация, из-за чего подбор предметов и передвижение замедлятся. Также вы чувствуете как ваши кости начинают трещать!"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "paralysis"

/atom/movable/screen/alert/fire
	name = "В огне"
	desc = "Вы горите! Катайтесь по полу, используйте огнетушитель или выйдите в пространство с вакуумом."
	icon_state = "fire"
	clickable_glow = TRUE

/atom/movable/screen/alert/fire/Click()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_owner = owner
	if(!living_owner.can_resist())
		return FALSE

	living_owner.changeNext_move(CLICK_CD_RESIST)
	if(!(living_owner.mobility_flags & MOBILITY_MOVE))
		return FALSE

	return handle_stop_drop_roll(owner)

/atom/movable/screen/alert/fire/proc/handle_stop_drop_roll(mob/living/roller)
	return roller.resist_fire()

/atom/movable/screen/alert/give // information set when the give alert is made
	icon_state = "template"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	clickable_glow = TRUE
	/// The offer we're linked to, yes this is suspiciously like a status effect alert
	var/datum/status_effect/offering/offer
	/// Additional text displayed in the description of the alert.
	var/additional_desc_text = "Нажмите на уведомление, чтобы взять, или Shift+ЛКМ чтобы изучить его."
	/// Text to override what appears in screentips for the alert
	var/screentip_override_text
	/// Whether the offered item can be examined by shift-clicking the alert
	var/examinable = TRUE

/atom/movable/screen/alert/give/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	register_context()

/atom/movable/screen/alert/give/Destroy()
	offer = null
	return ..()

/atom/movable/screen/alert/give/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = screentip_override_text || "Взять [offer.offered_item.name]"
	context[SCREENTIP_CONTEXT_SHIFT_LMB] = "Изучить"
	return CONTEXTUAL_SCREENTIP_SET

/**
 * Handles assigning most of the variables for the alert that pops up when an item is offered
 *
 * Handles setting the name, description and icon of the alert and tracking the living mob giving
 * and the item being offered.
 * Arguments:
 * * taker - The living mob receiving the alert
 * * offer - The status effect connected to the offer being made
 */
/atom/movable/screen/alert/give/proc/setup(mob/living/taker, datum/status_effect/offering/offer)
	src.offer = offer

	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	var/receiving_name = get_receiving_name(taker, offerer, receiving)
	name = "[offerer] предлагает [receiving_name]"
	desc = "[offerer] предлагает [receiving_name]. [additional_desc_text]"
	icon_state = "template"
	cut_overlays()
	add_overlay(receiving)

/**
 * Called right before `setup()`, to do any sort of logic to change the name of
 * what's displayed as the name of what's being offered in the alert. Use this to
 * add pronouns and the like, or to totally override the displayed name!
 * Also the best place to make changes to `additional_desc_text` before `setup()`
 * without having to override `setup()` entirely.
 *
 * Arguments:
 * * taker - The person receiving the alert
 * * offerer - The person giving the alert and item
 * * receiving - The item being given by the offerer
 *
 * Returns a string that will be displayed in the alert, which is `receiving.name`
 * by default.
 */
/atom/movable/screen/alert/give/proc/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	return receiving.name

/atom/movable/screen/alert/give/Click(location, control, params)
	. = ..()
	if(!.)
		return

	if(!isliving(usr))
		CRASH("User for [src] is of type \[[usr.type]\]. This should never happen.")

	handle_transfer()

/atom/movable/screen/alert/give/examine(mob/user)
	if(!examinable)
		return ..()

	return list(
		span_boldnotice(name),
		span_info("[offer.owner] предлагает Вам предмет (нажмите на уведомление чтобы взять!):"),
		"<hr>[jointext(offer.offered_item.examine(user), "\n")]",
	)

/// An overrideable proc used simply to hand over the item when claimed, this is a proc so that high-fives can override them since nothing is actually transferred
/atom/movable/screen/alert/give/proc/handle_transfer()
	var/mob/living/taker = owner
	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	taker.take(offerer, receiving)
	SEND_SIGNAL(offerer, COMSIG_LIVING_ITEM_GIVEN, taker, receiving)

/atom/movable/screen/alert/give/highfive
	additional_desc_text = "Нажмите на уведомление чтобы дать пять!"
	screentip_override_text = "Дать пять"
	examinable = FALSE
	/// Tracks active "to slow"ing so we can't spam click
	var/too_slowing_this_guy = FALSE

/atom/movable/screen/alert/give/highfive/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	return "a high-five"

/atom/movable/screen/alert/give/highfive/setup(mob/living/taker, datum/status_effect/offering/offer)
	. = ..()
	RegisterSignal(offer.owner, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(check_fake_out))

/atom/movable/screen/alert/give/highfive/handle_transfer()
	if(too_slowing_this_guy)
		return

	var/mob/living/taker = owner
	var/mob/living/offerer = offer.owner
	var/obj/item/receiving = offer.offered_item
	if(!QDELETED(receiving) && offerer.is_holding(receiving))
		receiving.on_offer_taken(offerer, taker)
		return

	too_slow_p1()

/// If the person who offered the high five no longer has it when we try to accept it, we get pranked hard
/atom/movable/screen/alert/give/highfive/proc/too_slow_p1()
	var/mob/living/rube = owner
	var/mob/living/offerer = offer?.owner
	if(QDELETED(rube) || QDELETED(offerer))
		qdel(src)
		return

	too_slowing_this_guy = TRUE
	offerer.visible_message(span_notice("[rube] спешит, чтобы дать пять [offerer], но..."), span_nicegreen("[rube] попался на твой трюк, как и планировалось, бросившись за несуществующей пятнюней! Классика!"), ignored_mobs=rube)
	to_chat(rube, span_nicegreen("Ты тянешься, чтобы дать [offerer] пять, но..."))
	addtimer(CALLBACK(src, PROC_REF(too_slow_p2), offerer, rube), 0.5 SECONDS)

/// Part two of the ultimate prank
/atom/movable/screen/alert/give/highfive/proc/too_slow_p2()
	var/mob/living/rube = owner
	var/mob/living/offerer = offer?.owner
	if(!QDELETED(rube) && !QDELETED(offerer))
		offerer.visible_message(span_danger("[offerer] убирает руку от шлепка [rube] в последнюю секунду, полностью уклоняясь от пятюни!"), span_nicegreen("[rube] не удается коснуться вашей руки, выставляя себя на посмешище!"), span_hear("Вы слышите разочаровывающий звук того, как плоть не соприкасается с плотью!"), ignored_mobs=rube)
		to_chat(rube, span_userdanger("[uppertext("НЕТ! [offerer] ОТДЕРГИВАЕТ СВОЮ РУКУ! ТЫ ДЕЙСТВУЕШЬ СЛИШКОМ МЕДЛЕННО!")]"))
		playsound(offerer, 'sound/items/weapons/thudswoosh.ogg', 100, TRUE, 1)
		rube.Knockdown(1 SECONDS)
		offerer.add_mood_event("high_five", /datum/mood_event/down_low)
		rube.add_mood_event("high_five", /datum/mood_event/too_slow)
		offerer.remove_status_effect(/datum/status_effect/offering/no_item_received/high_five)

	qdel(src)

/// If someone examine_more's the offerer while they're trying to pull a too-slow, it'll tip them off to the offerer's trickster ways
/atom/movable/screen/alert/give/highfive/proc/check_fake_out(mob/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(QDELETED(offer.offered_item))
		examine_list += span_warning("Рука [source] напряжена, и кажется, что [source] вот-вот её отдёрнет...")

/atom/movable/screen/alert/give/hand
	screentip_override_text = "Взять руку"
	examinable = FALSE

/atom/movable/screen/alert/give/hand/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	additional_desc_text = "Нажмите на это уведомление, чтобы вас могли таскать!"
	return "[offerer.p_their()] [receiving.name]"

/atom/movable/screen/alert/give/hand/helping

/atom/movable/screen/alert/give/hand/helping/get_receiving_name(mob/living/taker, mob/living/offerer, obj/item/receiving)
	. = ..()
	additional_desc_text = "Нажмите на это уведомление, чтобы вам помогли подняться!"

/// Gives the player the option to succumb while in critical condition
/atom/movable/screen/alert/succumb
	name = "Сдаться"
	desc = "Покиньте этот бренный мир."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_icon = 'icons/mob/simple/mob.dmi'
	overlay_state = "ghost"
	clickable_glow = TRUE
	var/static/list/death_titles = list(
		"Покойной ночи, милый принц",
		"Игра окончена, чувак",
		"Конечная",
		"Живи долго и счастливо",
		"Увидимся, космический ковбой...",
		"Это было честью",
		"Занавес. Титры",
		"Всё хорошее когда-нибудь заканчивается"
	)

/atom/movable/screen/alert/succumb/Click(location, control, params)
	. = ..()
	if(!.)
		return
	var/mob/living/living_owner = owner
	if(!CAN_SUCCUMB(living_owner) && !HAS_TRAIT(living_owner, TRAIT_SUCCUMB_OVERRIDE)) //checked again in [mob/living/verb/succumb()]
		return

	var/title = pick(death_titles)

	//Succumbing with a message
	var/last_whisper = tgui_input_text(usr, "Что Вы хотите сказать напоследок?", title, max_length = CHAT_MESSAGE_MAX_LENGTH, encode = FALSE) // saycode already handles sanitization
	if(isnull(last_whisper))
		return
	if(length(last_whisper))
		living_owner.say("#[last_whisper]")
	living_owner.succumb(whispered = length(last_whisper) > 0)

//ALIENS

/atom/movable/screen/alert/alien_plas
	name = "Плазма"
	desc = "Здесь легковоспламеняемая плазма в воздухе. Если она загорится, то вас поджарит."
	icon_state = ALERT_XENO_PLASMA
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Слишком горячо"
	desc = "Здесь слишком горячо! Выбегайте в космос или уходите от огня. Стоя на траве, вы будете исцеляться."
	icon_state = ALERT_XENO_FIRE
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Крах Матриархата"
	desc = "Ваша королева была убита. Вы теряете разум улья и страдаете от замедления. Новая королева не может быть сделана, пока вы не поправитесь."
	icon_state = ALERT_XENO_NOQUEEN
	alerttooltipstyle = "alien"

//BLOBS

/atom/movable/screen/alert/nofactory
	name = "Нет фабрики"
	desc = "У вас нет фабрики, и вы медленно умираете!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

// BLOODCULT

/atom/movable/screen/alert/bloodsense
	name = "Чувство Крови"
	desc = "Позволяет вам чувствовать кровь, которой манипулирует тёмная магия."
	icon_state = "cult_sense"
	alerttooltipstyle = "cult"
	var/static/image/narnar
	var/angle = 0
	var/mob/living/basic/construct/construct_owner

/atom/movable/screen/alert/bloodsense/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	narnar = new('icons/hud/screen_alert.dmi', "mini_nar")
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/bloodsense/Destroy()
	construct_owner = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/bloodsense/process()
	var/atom/blood_target

	if(!owner.mind)
		return

	if(isconstruct(owner))
		construct_owner = owner
	else
		construct_owner = null

	// construct track
	if(construct_owner?.seeking && construct_owner.construct_master)
		blood_target = construct_owner.construct_master
		desc = "Ваше Чувство Крови указывает на [construct_owner.construct_master]"

	// cult track
	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(antag)
		var/datum/objective/sacrifice/sac_objective = locate() in antag.cult_team.objectives
		if(antag.cult_team.blood_target)
			if(!get_turf(antag.cult_team.blood_target))
				antag.cult_team.unset_blood_target()
			else
				blood_target = antag.cult_team.blood_target
		if(!blood_target)
			if(sac_objective && !sac_objective.check_completion())
				if(icon_state == "runed_sense0")
					return
				animate(src, transform = null, time = 1, loop = 0)
				angle = 0
				cut_overlays()
				icon_state = "runed_sense0"
				desc = "Нар'Си требует принести в жертву [sac_objective.target] до начала ритуала призыва."
				add_overlay(sac_objective.sac_image)
			else
				var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
				if(!summon_objective)
					return
				var/list/location_list = list()
				for(var/area/area_to_check in summon_objective.summon_spots)
					location_list += area_to_check.get_original_area_name()
				desc = "Жертвоприношение завершено, призовите Нар'Си! Призыв может быть осуществлен только в [english_list(location_list)]!"
				if(icon_state == "runed_sense1")
					return
				animate(src, transform = null, time = 1, loop = 0)
				angle = 0
				cut_overlays()
				icon_state = "runed_sense1"
				add_overlay(narnar)
			return

	// actual tracking
	var/turf/P = get_turf(blood_target)
	var/turf/Q = get_turf(owner)
	if(!P || !Q || (P.z != Q.z)) //The target is on a different Z level, we cannot sense that far.
		icon_state = "runed_sense2"
		desc = "Вы больше не ощущаете присутствие своей цели."
		return
	if(isliving(blood_target))
		var/mob/living/real_target = blood_target
		desc = "Отслеживается [real_target.real_name] в [get_area_name(blood_target)]"
	else
		desc = "Отслеживается [blood_target] в [get_area_name(blood_target)]."

	var/target_angle = get_angle(Q, P)
	var/target_dist = get_dist(P, Q)
	cut_overlays()
	switch(target_dist)
		if(0 to 1)
			icon_state = "runed_sense2"
		if(2 to 8)
			icon_state = "arrow8"
		if(9 to 15)
			icon_state = "arrow7"
		if(16 to 22)
			icon_state = "arrow6"
		if(23 to 29)
			icon_state = "arrow5"
		if(30 to 36)
			icon_state = "arrow4"
		if(37 to 43)
			icon_state = "arrow3"
		if(44 to 50)
			icon_state = "arrow2"
		if(51 to 57)
			icon_state = "arrow1"
		if(58 to 64)
			icon_state = "arrow0"
		if(65 to 400)
			icon_state = "arrow"
	var/difference = target_angle - angle
	angle = target_angle
	if(!difference)
		return
	var/matrix/final = matrix(transform)
	final.Turn(difference)
	animate(src, transform = final, time = 5, loop = 0)


//GUARDIANS

/atom/movable/screen/alert/status_effect/instealth
	name = "В скрытности"
	desc = "Вы в скрытности и ваша следующая атака нанесёт бонусный урон!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Отсутствует батарея"
	desc = "Батарея юнита отсутствует. Модули недоступны, пока батарея не будет установлена. Робототехника может оказать помощь."
	icon_state = "no_cell"

/atom/movable/screen/alert/emptycell
	name = "Без питания"
	desc = "Ядро юнита разряжено. Модули недоступны, пока батарея не будет заряжена."
	icon_state = "empty_cell"

/atom/movable/screen/alert/emptycell/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance(updates=UPDATE_DESC)

/atom/movable/screen/alert/emptycell/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_borgcharger_areas))
		desc += " Станции зарядки доступны в [english_list(GLOB.roundstart_station_borgcharger_areas)]."

/atom/movable/screen/alert/lowcell
	name = "Низкий заряд"
	desc = "Ядро юнита на низком заряде."
	icon_state = "low_cell"

/atom/movable/screen/alert/lowcell/Initialize(mapload, datum/hud/hud_owner)
	. = ..()
	update_appearance(updates=UPDATE_DESC)

/atom/movable/screen/alert/lowcell/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_borgcharger_areas))
		desc += " Станции зарядки доступны в [english_list(GLOB.roundstart_station_borgcharger_areas)]."

//MECH

/atom/movable/screen/alert/lowcell/mech/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_mechcharger_areas))
		desc += " Зарядники мехов доступны в [english_list(GLOB.roundstart_station_mechcharger_areas)]."

/atom/movable/screen/alert/emptycell/mech/update_desc()
	. = ..()
	desc = initial(desc)
	if(length(GLOB.roundstart_station_mechcharger_areas))
		desc += " Зарядники мехов доступны в [english_list(GLOB.roundstart_station_mechcharger_areas)]."

//Ethereal

/atom/movable/screen/alert/lowcell/ethereal
	name = "Низкий заряд в крови"
	desc = "Ваш заряд в крови на низком уровне, найдите источник энергии! Воспользуйтесь станцией подзарядки, съешьте какую-нибудь пищу для эфириалов или воспользуйтесь источником энергии от ламп, элементов питания или ЛКП (для этого щелкните правой кнопкой мыши в боевом режиме)."

/atom/movable/screen/alert/emptycell/ethereal
	name = "Нет заряда в крови"
	desc = "У вас закончился заряд в крови, найдите источник энергии! Воспользуйтесь станцией подзарядки, съешьте какую-нибудь пищу для эфириалов или воспользуйтесь источником энергии от ламп, элементов питания или ЛКП (для этого щелкните правой кнопкой мыши в боевом режиме)."

/atom/movable/screen/alert/ethereal_overcharge
	name = "Перегрузка заряда в крови"
	desc = "Ваш заряд опасно высок, найдите выход для своей энергии! Щелкните правой кнопкой мыши на ЛКП, не находясь в боевом режиме."
	icon_state = "cell_overcharge"

//MODsuit unique
/atom/movable/screen/alert/nocore
	name = "Отсутствует ядро"
	desc = "Ядро юнита отсутствует. Модули недоступны, пока ядро не будет установлено. Робототехника может оказать помощь."
	icon_state = "no_cell"

/atom/movable/screen/alert/emptycell/plasma
	name = "Без питания"
	desc = "Плазменное ядро юнита разряжено. Модули недоступны, пока ядро не будет заряжено. \
		Заряд может быть заполнен плазменным топливом."

/atom/movable/screen/alert/emptycell/plasma/update_desc()
	. = ..()
	desc = initial(desc)

/atom/movable/screen/alert/lowcell/plasma
	name = "Низкий заряд"
	desc = "Плазменное ядро юнита на низком заряде. Заряд может быть заполнен плазменным топливом."

/atom/movable/screen/alert/lowcell/plasma/update_desc()
	. = ..()
	desc = initial(desc)

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Взломан"
	desc = "Обнаружено опасное нестандартное оборудование. Пожалуйста, убедитесь, что любое использование этого оборудования соответствует законам юнита, если таковые имеются."
	icon_state = ALERT_HACKED

/atom/movable/screen/alert/locked
	name = "Заблокирован"
	desc = "Юнит был дистанционно заблокирован. Использование консоли управления робототехникой в кабинете директора исследований \
		вашим мастером-ИИ или квалифицированным органиком, могут решить эту проблему. Робототехники могут оказать дополнительную помощь."
	icon_state = ALERT_LOCKED

/atom/movable/screen/alert/newlaw
	name = "Законы обновлены"
	desc = "Возможно, законы были загружены или удалены из данного юнита. Пожалуйста, будьте в курсе любых изменений \
		чтобы оставаться в соответствии с самыми последними законами."
	icon_state = ALERT_NEW_LAW
	timeout = 30 SECONDS

/atom/movable/screen/alert/hackingapc
	name = "Взлом ЛКП"
	desc = "Происходит взлом локального контроллера питания. Когда процесс \
		завершится, вы получите исключительный контроль над ним и получите \
		дополнительное время обработки для разблокировки новых неисправностей."
	icon_state = ALERT_HACKING_APC
	timeout = 60 SECONDS
	clickable_glow = TRUE
	var/atom/target = null

/atom/movable/screen/alert/hackingapc/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/silicon/ai/ai_owner = owner
	var/turf/target_turf = get_turf(target)
	if(target_turf)
		ai_owner.eyeobj.setLoc(target_turf)

//MECHS

/atom/movable/screen/alert/low_mech_integrity
	name = "Мех повреждён"
	desc = "Низкая целостность меха."
	icon_state = "low_mech_integrity"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/revival
	name = "Возрождение"
	desc = "Кто-то пытается возродить вас. Вернитесь в тело, если хотите чтобы вас оживили!"
	icon_state = "template"
	timeout = 30 SECONDS
	clickable_glow = TRUE

/atom/movable/screen/alert/revival/Click()
	. = ..()
	if(!.)
		return
	var/mob/dead/observer/dead_owner = owner
	dead_owner.reenter_corpse()

/atom/movable/screen/alert/notify_action
	name = "Происходит что-то интересное!"
	desc = "Сюда можно нажать, чтобы посмотреть на происходящее."
	icon_state = "template"
	use_user_hud_icon = USER_HUD_STYLE_PREFS
	timeout = 30 SECONDS
	clickable_glow = TRUE
	/// Weakref to the target atom to use the action on
	var/datum/weakref/target_ref
	/// If we want to interact on click rather than jump/orbit
	var/click_interact = FALSE

/atom/movable/screen/alert/notify_action/Click()
	. = ..()
	if(!.)
		return

	var/atom/target = target_ref?.resolve()
	if(isnull(target) || !isobserver(owner) || target == owner)
		return

	var/mob/dead/observer/ghost_owner = owner

	if(click_interact)
		ghost_owner.jump_to_interact(target)
		return

	ghost_owner.observer_view(target)

/atom/movable/screen/alert/poll_alert
	name = "Ищем кандидатов"
	icon_state = "template"
	use_user_hud_icon = USER_HUD_STYLE_PREFS
	timeout = 30 SECONDS
	ghost_screentips = TRUE
	/// If true you need to call START_PROCESSING manually
	var/show_time_left = FALSE
	/// MA for maptext showing time left for poll
	var/mutable_appearance/time_left_overlay
	/// MA for overlay showing that you're signed up to poll
	var/mutable_appearance/signed_up_overlay
	/// MA for maptext overlay showing how many polls are stacked together
	var/mutable_appearance/stacks_overlay
	/// MA for maptext overlay showing how many candidates are signed up to a poll
	var/mutable_appearance/candidates_num_overlay
	/// MA for maptext overlay of poll's role name or question
	var/mutable_appearance/role_overlay
	/// If set, on Click() it'll register the player as a candidate
	var/datum/candidate_poll/poll

/atom/movable/screen/alert/poll_alert/Initialize(mapload)
	. = ..()
	signed_up_overlay = mutable_appearance('icons/hud/screen_gen.dmi', icon_state = "selector")
	register_context()

/atom/movable/screen/alert/poll_alert/proc/set_role_overlay()
	var/role_or_only_question = poll.role || "?"
	role_overlay = new
	role_overlay.screen_loc = screen_loc
	role_overlay.maptext = MAPTEXT("<span style='text-align: right; color: #B3E3FC'>[full_capitalize(role_or_only_question)]</span>")
	role_overlay.maptext_width = 128
	role_overlay.transform = role_overlay.transform.Translate(-128, 0)
	add_overlay(role_overlay)

/atom/movable/screen/alert/poll_alert/Destroy()
	QDEL_NULL(role_overlay)
	QDEL_NULL(time_left_overlay)
	QDEL_NULL(stacks_overlay)
	QDEL_NULL(candidates_num_overlay)
	QDEL_NULL(signed_up_overlay)
	if(poll)
		poll.alert_buttons -= src
	poll = null
	return ..()

/atom/movable/screen/alert/poll_alert/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	var/left_click_text
	if(poll)
		if(owner in poll.signed_up)
			left_click_text = "Покинуть"
		else
			left_click_text = "Присоединиться"
		context[SCREENTIP_CONTEXT_LMB] = "[left_click_text]"
		if(poll.ignoring_category)
			var/selected_never = FALSE
			if(owner.ckey in GLOB.poll_ignore[poll.ignoring_category])
				selected_never = TRUE
			context[SCREENTIP_CONTEXT_ALT_LMB] = selected_never ? "Разрешить приглашения в этом раунде" : "Не приглашать в этом раунде"
		if(poll.jump_to_me && isobserver(owner))
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "Переместиться к событию"
	return CONTEXTUAL_SCREENTIP_SET

/atom/movable/screen/alert/poll_alert/process()
	if(show_time_left)
		var/timeleft = timeout - world.time
		if(timeleft <= 0)
			return PROCESS_KILL
		cut_overlay(time_left_overlay)
		time_left_overlay = new
		time_left_overlay.maptext = MAPTEXT("<span style='color: [(timeleft <= 10 SECONDS) ? "red" : "white"]'><b>[ceil(timeleft / (1 SECONDS))]</b></span>")
		time_left_overlay.transform = time_left_overlay.transform.Translate(4, 19)
		add_overlay(time_left_overlay)

/atom/movable/screen/alert/poll_alert/Click(location, control, params)
	. = ..()
	if(!. || isnull(poll))
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, ALT_CLICK) && poll.ignoring_category)
		set_never_round()
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK) && poll.jump_to_me)
		jump_to_jump_target()
		return
	handle_sign_up()

/atom/movable/screen/alert/poll_alert/proc/handle_sign_up()
	if(owner in poll.signed_up)
		poll.remove_candidate(owner)
	else if(!(owner.ckey in GLOB.poll_ignore[poll.ignoring_category]))
		poll.sign_up(owner)
	update_signed_up_overlay()

/atom/movable/screen/alert/poll_alert/proc/set_never_round()
	if(!(owner.ckey in GLOB.poll_ignore[poll.ignoring_category]))
		poll.do_never_for_this_round(owner)
		color = "red"
		update_signed_up_overlay()
		return
	poll.undo_never_for_this_round(owner)
	color = initial(color)

/atom/movable/screen/alert/poll_alert/proc/jump_to_jump_target()
	if(!poll?.jump_to_me || !isobserver(owner))
		return
	var/turf/target_turf = get_turf(poll.jump_to_me)
	if(target_turf && isturf(target_turf))
		owner.abstract_move(target_turf)

/atom/movable/screen/alert/poll_alert/Topic(href, href_list)
	if(href_list["never"])
		set_never_round()
		return
	if(href_list["signup"])
		handle_sign_up()
	if(href_list["jump"])
		jump_to_jump_target()
		return

/atom/movable/screen/alert/poll_alert/proc/update_signed_up_overlay()
	if(owner in poll.signed_up)
		add_overlay(signed_up_overlay)
	else
		cut_overlay(signed_up_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_candidates_number_overlay()
	cut_overlay(candidates_num_overlay)
	if(!length(poll.signed_up))
		return
	candidates_num_overlay = new
	candidates_num_overlay.maptext = MAPTEXT("<span style='text-align: right; color: aqua'>[length(poll.signed_up)]</span>")
	candidates_num_overlay.transform = candidates_num_overlay.transform.Translate(-4, 2)
	add_overlay(candidates_num_overlay)

/atom/movable/screen/alert/poll_alert/proc/update_stacks_overlay()
	cut_overlay(stacks_overlay)
	var/stack_number = 1
	for(var/datum/candidate_poll/other_poll as anything in SSpolling.currently_polling)
		if(other_poll != poll && other_poll.poll_key == poll.poll_key && !other_poll.finished)
			stack_number++
	if(stack_number <= 1)
		return
	stacks_overlay = new
	stacks_overlay.maptext = MAPTEXT("<span style='color: yellow'>[stack_number]x</span>")
	stacks_overlay.transform = stacks_overlay.transform.Translate(3, 2)
	stacks_overlay.layer = layer
	add_overlay(stacks_overlay)

//OBJECT-BASED

/atom/movable/screen/alert/buckled
	name = "Пристёгнуты"
	desc = "Вы были к чему-то пристёгнуты. Нажмите на это уведомление, чтобы отстегнуться, если вы не в наручниках."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "buckled"
	click_master = FALSE
	clickable_glow = TRUE

/atom/movable/screen/alert/buckled/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner

	if(!living_owner.can_resist())
		return
	living_owner.changeNext_move(CLICK_CD_RESIST)
	if(living_owner.last_special <= world.time)
		return living_owner.resist_buckle()

/atom/movable/screen/alert/restrained
	icon_state = "template"
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	clickable_glow = TRUE

/atom/movable/screen/alert/restrained/handcuffed
	name = "Закованы"
	desc = "Вы закованы и не можете действовать. Если вас тащат, то не сможете двигаться. Нажмите на уведомление, чтобы освободиться."
	click_master = FALSE

/atom/movable/screen/alert/restrained/legcuffed
	name = "Скованы ноги"
	desc = "У вас скованы ноги, что значительно замедляет вашу ходьбу. Нажмите на уведомление, чтобы освободиться."
	click_master = FALSE

/atom/movable/screen/alert/restrained/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/living_owner = owner

	if(!living_owner.can_resist())
		return

	living_owner.changeNext_move(CLICK_CD_RESIST)
	if((living_owner.mobility_flags & MOBILITY_MOVE) && (living_owner.last_special <= world.time))
		return living_owner.resist_restraints()

/atom/movable/screen/alert/shoes
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_icon = /obj/item/clothing/shoes/sneakers::icon
	overlay_state = /obj/item/clothing/shoes/sneakers::icon_state
	clickable_glow = TRUE

/atom/movable/screen/alert/shoes/Click()
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/carbon_owner = owner

	if(!carbon_owner.can_resist() || !carbon_owner.shoes)
		return

	carbon_owner.changeNext_move(CLICK_CD_RESIST)
	carbon_owner.shoes.handle_tying(carbon_owner)

/atom/movable/screen/alert/shoes/untied
	name = "Развязаны шнурки"
	desc = "Ваши шнурки на обуви развязаны! Нажмите на уведомление или обувь, чтобы завязать их."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_icon = /obj/item/clothing/shoes/sneakers::icon
	overlay_state = /obj/item/clothing/shoes/sneakers::icon_state

/atom/movable/screen/alert/shoes/knotted
	name = "Завязанные узлом шнурки"
	desc = "Кто-то завязал шнурки на обуви вместе! Нажмите на уведомление или обувь, чтобы развязать узел."

/atom/movable/screen/alert/unpossess_object
	name = "Отвязаться"
	desc = "Вы вселились в объект. Нажмите на уведомление, чтобы отвязаться от предмета."
	use_user_hud_icon = USER_HUD_STYLE_INHERIT
	overlay_state = "buckled"
	clickable_glow = TRUE

/atom/movable/screen/alert/unpossess_object/Click()
	. = ..()
	if(!.)
		return

	qdel(owner.GetComponent(/datum/component/object_possession))

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

/// Gets the placement for the alert based on its index
/datum/hud/proc/get_ui_alert_placement(index)
	// Only has support for 5 slots currently
	if(index > 5)
		return ""

	return "EAST-1:28,CENTER+[6 - index]:[29 - (index * 2)]"

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return FALSE
	var/list/alerts = mymob.alerts
	if(hud_version != HUD_STYLE_STANDARD)
		for(var/i in 1 to alerts.len)
			screenmob.client.screen -= alerts[alerts[i]]
		return TRUE

	var/user_pref_hud = ui_style2icon(mymob.client?.prefs?.read_preference(/datum/preference/choiced/ui_style))
	for(var/i in 1 to length(alerts))
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		switch(alert.use_user_hud_icon)
			if(USER_HUD_STYLE_INHERIT)
				alert.icon = ui_style
			if(USER_HUD_STYLE_PREFS)
				if(user_pref_hud)
					alert.icon = user_pref_hud
		alert.screen_loc = get_ui_alert_placement(i)
		screenmob.client.screen |= alert
	if(!viewmob)
		for(var/viewer in mymob.observers)
			reorganize_alerts(viewer)
	return TRUE
