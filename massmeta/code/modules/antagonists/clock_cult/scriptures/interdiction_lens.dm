#define INTERDICTION_LENS_RANGE 5

/datum/clockcult/scripture/create_structure/interdiction
	name = "Линза запрета"
	desc = "Создает устройство, которое будет замедлять не служащих поблизости и повредить механизированные экзокостюмы. Требуется мощность от сигилы передачи."
	tip = "Создайте блокирующую линзу, чтобы замедлить вражеское нападение."
	button_icon_state = "Interdiction Lens"
	power_cost = 500
	invokation_time = 80
	invokation_text = list("О великий господин...", "пусть твое божество заблокирует посторонних.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/interdiction_lens
	cogs_required = 4
	category = SPELLTYPE_STRUCTURES

/obj/structure/destructible/clockwork/gear_base/interdiction_lens
	name = "линза запрета"
	desc = "Завораживающий свет, который мигает в ритме, на который невозможно перестать залипать."
	clockwork_desc = "Небольшое устройство, которое будет замедлять атакующих поблизости при небольшой стоимости энергии."
	default_icon_state = "interdiction_lens"
	anchored = TRUE
	break_message = span_warning("Линза запрета разбивается на несколько фрагментов, которые плавно падают на землю.")
	max_integrity = 150
	atom_integrity = 150
	minimum_power = 5
	var/enabled = FALSE			//Misnomer - Whether we want to be enabled or not, processing would be if we are enabled
	var/processing = FALSE
	var/obj/item/borg/projectile_dampen/clockcult/internal_dampener

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Initialize(mapload)
	internal_dampener = new
	. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Destroy()
	if(enabled)
		STOP_PROCESSING(SSobj, src)
	QDEL_NULL(internal_dampener)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		if(!anchored)
			to_chat(user, span_warning("[src] хочет быть прикрученной к полу!"))
			return
		enabled = !enabled
		to_chat(user, span_brass("Дёргаю переключатель на [src], переводя её в режим [enabled?"ВКЛ":"ВЫКЛ"]!"))
		if(enabled)
			if(update_power())
				repowered()
			else
				enabled = FALSE
				to_chat(user, span_warning("[src] не может найти источник энергии!"))
		else
			depowered()
	else
		. = ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/process()
	if(!anchored)
		enabled = FALSE
		STOP_PROCESSING(SSobj, src)
		update_icon_state()
		return
	if(prob(5))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	for(var/mob/living/L in viewers(INTERDICTION_LENS_RANGE, src))
		if(!is_servant_of_ratvar(L) && use_power(5))
			L.apply_status_effect(STATUS_EFFECT_INTERDICTION)
	for(var/obj/vehicle/sealed/mecha/M in dview(INTERDICTION_LENS_RANGE, src, SEE_INVISIBLE_MINIMUM))
		if(use_power(5))
			M.emp_act(EMP_HEAVY)
			M.take_damage(80)
			do_sparks(4, TRUE, M)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/repowered()
	if(enabled)
		if(!processing)
			START_PROCESSING(SSobj, src)
			processing = TRUE
		icon_state = "interdiction_lens_active"
		flick("interdiction_lens_recharged", src)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/depowered()
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE
	icon_state = "interdiction_lens"
	flick("interdiction_lens_discharged", src)

/obj/item/borg/projectile_dampen/clockcult
	name = "культистский глушитель снарядов"
