//==================================//
// !      Dimensional Gate        ! //
//==================================//
/datum/clockcult/scripture/create_structure/dimensional_gate
	name = "Dimensional Gate"
	desc = "Creates a Dimensional Gate, a structure which allows you to warp to Reebe."
	tip = "Essential for the cult, the one of the few way to get to Reebe."
	button_icon_state = "dimensional_gate"
	power_cost = 2000
	invokation_time = 15 SECONDS
	invokation_text = list("Когда мы прощаемся и возвращаемся к звездам...", "мы найдем дорогу домой.")
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/dimensional_gate
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/create_structure/dimensional_gate/check_special_requirements()
	if(!..())
		return FALSE
	var/area/gate_location = get_area(invoker)
	if(!is_station_level(gate_location.z))
		to_chat(invoker, span_warning("You can summon a dimensional gate only on the station!"))
		return FALSE
	for(var/obj/structure/destructible/clockwork/gear_base/dimensional_gate/gate as anything in GLOB.dimensional_gates)
		var/area/used_location = get_area(gate)
		if(used_location == gate_location)
			to_chat(invoker, span_warning("You've already summoned a gate in this area! You have to summon again somewhere else!"))
			return FALSE
	return TRUE

/datum/clockcult/scripture/create_structure/dimensional_gate/begin_invoke(mob/living/M, obj/item/clockwork/clockwork_slab/slab, bypass_unlock_checks)
	invokation_time = 15 SECONDS + (5 SECONDS * GLOB.dimensional_gates.len)
	. = ..()

//===============
// Dimensional Gate Structure
//===============

GLOBAL_LIST_EMPTY(dimensional_gates)

/obj/structure/destructible/clockwork/gear_base/dimensional_gate
	name = "dimensional gate"
	desc = "A portal in a bronze frame."
	clockwork_desc = "A portal in a bronze frame. Use it to warp to Reebe."
	default_icon_state = "dimensional_gate"
	max_integrity = 300
	atom_integrity = 300
	anchored = TRUE
	break_message = span_warning("The dimensional gate shatters!")
	can_unanchor = FALSE

/obj/structure/destructible/clockwork/gear_base/dimensional_gate/Initialize()
	. = ..()
	GLOB.dimensional_gates += src

/obj/structure/destructible/clockwork/gear_base/dimensional_gate/Destroy()
	. = ..()
	GLOB.dimensional_gates -= src

/obj/structure/destructible/clockwork/gear_base/dimensional_gate/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!is_servant_of_ratvar(user))
		to_chat(user, span_warning("Пытаюсь засунуть руку в [src], но чуть не обжигаю её!"))
		return
	var/client_color = user.client.color
	animate(user.client, color = "#AF0AAF", time = 2.5 SECONDS)
	if(!anchored)
		to_chat(user, span_brass("Стоит прикрутить [src] для начала."))
		return
	user.balloon_alert(user,"warping to Reebe...")
	if(!do_after(user, 2.5 SECONDS, src))
		if(user.client)
			animate(user.client, color = client_color, time = 10)
		user.balloon_alert(user,"warp failed!")
		return
	var/turf/T = get_turf(pick(GLOB.servant_spawns))
	if(!T)
		to_chat(user, span_warning("Error, no valid teleport locations found!"))
	try_warp_servant(user, T, TRUE)
	var/prev_alpha = user.alpha
	user.alpha = 0
	animate(user, alpha=prev_alpha, time=10)
	if(user.client)
		animate(user.client, color = client_color, time = 25)
