//==================================//
// !      Prosperity Prism     ! //
//==================================//
/datum/clockcult/scripture/create_structure/prosperityprism
	name = "Призма процветания"
	desc = "Создает призму, которая удаляет большое количество токсинов и небольшое количество других видов повреждений у ближайших слуг. Требуется сила от сигила передачи."
	tip = "Создайте призму процветания, чтобы исцелять слуг, используя компромисс механизмов, не получая при этом никакого ущерба."
	button_icon_state = "Prolonging Prism"
	power_cost = 300
	invokation_time = 80
	invokation_text = list("Ваш свет исцелит раны под моей кожей.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/prosperityprism
	cogs_required = 2
	category = SPELLTYPE_STRUCTURES

//Stargazer structure
/obj/structure/destructible/clockwork/gear_base/prosperityprism
	name = "призма процветания"
	desc = "Призма, которая, кажется, всегда пристально смотрит на меня."
	clockwork_desc = "Призма, которая исцеляет ближайших слуг от токсинов.."
	icon_state = "prolonging_prism"
	default_icon_state = "prolonging_prism"
	anchored = TRUE
	break_message = span_warning("Призма разваливается, токсичная жидкость утекает в воздух.")
	max_integrity = 150
	atom_integrity = 150
	minimum_power = 4
	var/powered = FALSE
	var/toggled_on = TRUE
	var/datum/reagents/holder

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	holder = new /datum/reagents(1000)
	holder.my_atom = src

/obj/structure/destructible/clockwork/gear_base/prosperityprism/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(LAZYLEN(holder.reagent_list))
		var/datum/effect_system/fluid_spread/smoke/chem/S = new
		var/turf_location = get_turf(src)
		S.attach(turf_location)
		S.set_up(3, holder = src, carry = holder, location = turf_location)
		S.start()
	QDEL_NULL(holder)
	. = ..()

/obj/structure/destructible/clockwork/gear_base/prosperityprism/update_icon_state()
	. = ..()
	icon_state = default_icon_state
	if(!anchored)
		icon_state += unwrenched_suffix
	else if(depowered || !powered)
		icon_state += "_inactive"

/obj/structure/destructible/clockwork/gear_base/prosperityprism/process()
	if(!anchored)
		toggled_on = FALSE
		update_icon_state()
		return
	if(!toggled_on || depowered)
		if(powered)
			powered = FALSE
			update_icon_state()
		return
	if(!powered)
		powered = TRUE
		update_icon_state()
	for(var/mob/living/L in range(4, src))
		if(!is_servant_of_ratvar(L))
			continue
		if(!L.toxloss && !L.staminaloss && !L.bruteloss && !L.fireloss)
			continue
		if(!L?.reagents?.reagent_list)
			continue
		if(use_power(2))
			L.adjustToxLoss(-10)
			L.adjustStaminaLoss(-10)
			L.adjustBruteLoss(-2)
			L.adjustFireLoss(-2)
			new /obj/effect/temp_visual/heal(get_turf(L), "#45dd8a")
			for(var/datum/reagent/R in L.reagents.reagent_list)
				if(istype(R, /datum/reagent/toxin))
					L.reagents.remove_reagent(R.type, 10)
					holder.add_reagent(R.type, 10)

/obj/structure/destructible/clockwork/gear_base/prosperityprism/attack_hand(mob/user)
	if(is_servant_of_ratvar(user))
		if(!anchored)
			to_chat(user, span_warning("[src] хочет быть прикрученной к полу!"))
			return
		toggled_on = !toggled_on
		to_chat(user, span_brass("Дёргаю [src], переводя её в режим [toggled_on?"ВКЛ":"ВЫКЛ"]!"))
	else
		. = ..()

