/obj/structure/destructible/clockwork/gear_base
	name = "шестерня"
	desc = "Большая шестерня, лежащая на полу на уровне ног."
	clockwork_desc = "Большая шестерня, лежащая на полу на уровне ног."
	anchored = FALSE
	break_message = span_warning("О, это сломалось. Я думаю, вы могли бы сообщить об этом кодировщикам или просто игнорировать это сообщение и продолжать убивать этих чертовых еретиков, пришедших сломать Ковчег.")
	var/default_icon_state = "gear_base"
	var/unwrenched_suffix = "_unwrenched"
	var/list/transmission_sigils
	var/depowered = FALSE	//Makes sure the depowered proc is only called when its depowered and not while its depowered
	var/minimum_power = 0	//Minimum operation power

/obj/structure/destructible/clockwork/gear_base/Initialize(mapload)
	. = ..()
	update_icon_state()
	transmission_sigils = list()
	for(var/obj/structure/destructible/clockwork/sigil/transmission/ST in range(src, SIGIL_TRANSMISSION_RANGE))
		link_to_sigil(ST)

/obj/structure/destructible/clockwork/gear_base/Destroy()
	. = ..()
	for(var/obj/structure/destructible/clockwork/sigil/transmission/ST in transmission_sigils)
		ST.linked_structures -= src

/obj/structure/destructible/clockwork/gear_base/attackby(obj/item/I, mob/user, params)
	if(is_servant_of_ratvar(user) && I.tool_behaviour == TOOL_WRENCH)
		to_chat(user, span_notice("Начинаю [anchored ? "откручивать" : "прикручивать"] [src]."))
		if(I.use_tool(src, user, 20, volume=50))
			to_chat(user, span_notice("Успешно [anchored ? "откручиваю" : "прикручиваю"] [src]."))
			set_anchored(!anchored)
			update_icon_state()
		return TRUE
	else
		return ..()

/obj/structure/destructible/clockwork/gear_base/update_icon_state()
	. = ..()
	icon_state = default_icon_state
	if(!anchored)
		icon_state += unwrenched_suffix

/obj/structure/destructible/clockwork/gear_base/proc/link_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/T)
	transmission_sigils |= T
	T.linked_structures |= src

/obj/structure/destructible/clockwork/gear_base/proc/unlink_to_sigil(obj/structure/destructible/clockwork/sigil/transmission/T)
	if(!(T in transmission_sigils))
		return
	transmission_sigils -= T
	T.linked_structures -= src
	if(!LAZYLEN(transmission_sigils))
		depowered()
		depowered = TRUE

//Power procs, for all your power needs, that is... if you have any

/obj/structure/destructible/clockwork/gear_base/proc/update_power()
	if(depowered)
		if(GLOB.clockcult_power > minimum_power && LAZYLEN(transmission_sigils))
			repowered()
			depowered = FALSE
			return TRUE
		return FALSE
	else
		if(GLOB.clockcult_power <= minimum_power || !LAZYLEN(transmission_sigils))
			depowered()
			depowered = TRUE
			return FALSE
		return TRUE

/obj/structure/destructible/clockwork/gear_base/proc/check_power(amount)
	if(!LAZYLEN(transmission_sigils))
		return FALSE
	if(depowered)
		return FALSE
	if(GLOB.clockcult_power < amount)
		return FALSE
	return TRUE

/obj/structure/destructible/clockwork/gear_base/proc/use_power(amount)
	update_power()
	if(!check_power(amount))
		return FALSE
	GLOB.clockcult_power -= amount
	update_power()
	return TRUE

//We lost power
/obj/structure/destructible/clockwork/gear_base/proc/depowered()
	return

/obj/structure/destructible/clockwork/gear_base/proc/repowered()
	return
