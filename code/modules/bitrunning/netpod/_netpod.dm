#define BASE_DISCONNECT_DAMAGE 40
#define SCANNING_TOGGLE_COOLDOWN 5

/obj/machinery/netpod
	name = "netpod"

	base_icon_state = "netpod"
	circuit = /obj/item/circuitboard/machine/netpod
	desc = "Связущее звено с сетевым миром. Здесь есть множество кабелей для подключения себя к виртуальному домену."
	icon = 'icons/obj/machines/bitrunning.dmi'
	icon_state = "netpod"
	max_integrity = 300
	obj_flags = BLOCKS_CONSTRUCTION
	state_open = TRUE
	interaction_flags_mouse_drop = NEED_HANDS | NEED_DEXTERITY

	/// Whether we have an ongoing connection
	var/connected = FALSE
	/// A player selected outfit by clicking the netpod
	var/datum/outfit/netsuit = /datum/outfit/job/bitrunner
	/// Holds this to see if it needs to generate a new one
	var/datum/weakref/avatar_ref
	/// The linked quantum server
	var/datum/weakref/server_ref
	/// The amount of brain damage done from force disconnects
	var/disconnect_damage
	/// Static list of outfits to select from
	var/list/cached_outfits = list()
	/// Whether bit avatars become visually similar to their bitrunner on first creation
	var/copy_body = FALSE
	/// The next time copy_body can be toggled
	var/scanning_can_toggle = 0


/obj/machinery/netpod/post_machine_initialize()
	. = ..()

	disconnect_damage = BASE_DISCONNECT_DAMAGE
	find_server()

	RegisterSignal(src, COMSIG_ATOM_TAKE_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(src, COMSIG_MACHINERY_POWER_LOST, PROC_REF(on_power_loss))
	RegisterSignals(src, list(COMSIG_QDELETING,	COMSIG_MACHINERY_BROKEN),PROC_REF(on_broken))

	register_context()
	update_appearance()


/obj/machinery/netpod/Destroy()
	. = ..()

	QDEL_LIST(cached_outfits)


/obj/machinery/netpod/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = "Выбрать одежду"
	else
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER && !occupant && !state_open)
			context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Закрыть" : "Открыть"] панель"

		if(held_item.tool_behaviour == TOOL_CROWBAR)
			if(isnull(occupant))
				if(panel_open)
					context[SCREENTIP_CONTEXT_LMB] = "Разобрать"
				else
					context[SCREENTIP_CONTEXT_LMB] = "[state_open ? "Открыть" : "Закрыть"] кожух"
			else
				context[SCREENTIP_CONTEXT_LMB] = "Выломать"

	context[SCREENTIP_CONTEXT_ALT_LMB] = "[copy_body ? "Выключить" : "Включить"] скан"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/netpod/examine(mob/user)
	. = ..()

	. += span_notice("Панель технического обслуживания может быть [panel_open ? "прикручена" : "откручена"] при помощи [EXAMINE_HINT("отвертки")].")
	if(isnull(occupant))
		if(panel_open)
			. += span_notice("Её можно поддеть [EXAMINE_HINT("ломом")].")
		else
			. += span_notice("Её люк можно поддеть [EXAMINE_HINT("ломом")] и [state_open ? "закрыть" : "открыть"].")

	if(isnull(server_ref?.resolve()))
		. += span_infoplain("Оно ни к чему не подключено.")
		. += span_infoplain("Нетподы должны быть построены на расстоянии 4-х тайлов от сервера.")
		return

	if(!isobserver(user))
		. += span_infoplain("Перетащите себя на под, чтобы начать подключение.")
		. += span_infoplain("Под имеет ограниченные возможности реанимации. Нахождение в поде может вылечить некоторые ранения.")
		. += span_infoplain("Имеется система безопасности, оповещающая пользователя, если начнётся вмешательство с подом.")
		if(copy_body)
			. += span_infoplain("В настоящее время включено сканирование пользователя, благодаря чему аватары будут выглядят как пользователь при первом его создании.")
		. += span_infoplain("Альт-ЛКМ чтобы [copy_body ? "выключить" : "включить"] сканирование пользователя.")

	if(isnull(occupant))
		. += span_infoplain("Сейчас внутри пусто.")
		return

	. += span_infoplain("Сейчас внутри находится - [occupant].")

	if(isobserver(user))
		. += span_notice("Как наблюдатель, вы можете щелкнуть по этому нетподу, чтобы перейти к его аватару.")
		return

	. += span_notice("Оно может быть насильно открыто монтировкой, но системы безопасности оповестят пользователя.")


/obj/machinery/netpod/update_icon_state()
	if(!is_operational)
		icon_state = base_icon_state
		return ..()

	if(state_open)
		icon_state = base_icon_state + "_open_active"
		return ..()

	if(panel_open)
		icon_state = base_icon_state + "_panel"
		return ..()

	icon_state = base_icon_state + "_closed"
	if(occupant)
		icon_state += "_active"

	return ..()


/obj/machinery/netpod/mouse_drop_receive(mob/target, mob/user, params)
	var/mob/living/carbon/player = user

	if(!iscarbon(player) || !is_operational || !state_open || player.buckled)
		return

	close_machine(target)


/obj/machinery/netpod/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!state_open && user == occupant)
		container_resist_act(user)


/obj/machinery/netpod/attack_ghost(mob/dead/observer/our_observer)
	var/our_target = avatar_ref?.resolve()
	if(isnull(our_target) || !our_observer.orbit(our_target))
		return ..()


/// When the server is upgraded, drops brain damage a little
/obj/machinery/netpod/proc/on_server_upgraded(obj/machinery/quantum_server/source)
	SIGNAL_HANDLER

	disconnect_damage = BASE_DISCONNECT_DAMAGE * (1 - source.servo_bonus)

/obj/machinery/netpod/click_alt(mob/user)
	if(world.time < scanning_can_toggle)
		return CLICK_ACTION_BLOCKING
	copy_body = !copy_body
	scanning_can_toggle = world.time + SCANNING_TOGGLE_COOLDOWN
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	user.balloon_alert_to_viewers(user, "сканирование [copy_body ? "включено" : "выключено"]")
	return CLICK_ACTION_SUCCESS

#undef BASE_DISCONNECT_DAMAGE
#undef SCANNING_TOGGLE_COOLDOWN
