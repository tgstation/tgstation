/obj/machinery/plumbing/liquid_input_pump
	name = "liquid input pump"
	desc = "Pump used to siphon liquids from a location into the plumbing pipenet."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	density = TRUE
	idle_power_usage = 10
	active_power_usage = 1000
	buffer = 300

	var/turned_on = FALSE
	var/height_regulator = 0

	var/is_working = FALSE

	var/drain_flat = 20
	var/drain_percent = 0.4

/obj/machinery/plumbing/liquid_input_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE

/obj/machinery/plumbing/liquid_input_pump/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be anchored first!</span>")
		return
	to_chat(user, "<span class='notice'>You turn [src] [turned_on ? "off" : "on"].</span>")
	turned_on = !turned_on

/obj/machinery/plumbing/liquid_input_pump/CtrlClick(mob/living/user)
	if(anchored)
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	var/new_height = input(user, "Set new height regulation:\n([0]-[LIQUID_HEIGHT_CONSIDER_FULL_TILE]. Use 0 to disable the regulation)\nThe pump will only siphon if environment is above the regulation", "Liquid Pump") as num|null
	if(QDELETED(src))
		return
	if(new_height)
		height_regulator = sanitize_integer(new_height, 0, LIQUID_HEIGHT_CONSIDER_FULL_TILE, 0)

/obj/machinery/plumbing/liquid_input_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's currently [turned_on ? "ON" : "OFF"].</span>"
	. += "<span class='notice'>It's height regulator [height_regulator ? "points at [height_regulator]" : "is disabled"]. (Ctrl-click to change)</span>"

/obj/machinery/plumbing/liquid_input_pump/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply, bolt)

/obj/machinery/plumbing/liquid_input_pump/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = initial(icon_state) + "-open"
	else if(is_working)
		icon_state = initial(icon_state) + "-on"
	else
		icon_state = initial(icon_state)

/obj/machinery/plumbing/liquid_input_pump/proc/can_pump()
	if(!turned_on || !anchored || panel_open || !isturf(loc) || reagents.total_volume == reagents.maximum_volume)
		return FALSE

	var/turf/T = loc

	if(!T.liquids)
		return FALSE

	if(height_regulator && T.liquids.height < height_regulator)
		return FALSE

	return TRUE

/obj/machinery/plumbing/liquid_input_pump/process(delta_time)
	var/last_pumped = is_working
	is_working = can_pump()
	if(is_working != last_pumped)
		update_icon_state()
	if(!is_working)
		return

	var/turf/T = loc

	var/target_value = delta_time * (drain_flat + (T.liquids.total_reagents * drain_percent))
	//Free space handling
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(target_value > free_space)
		target_value = free_space

	var/datum/reagents/tempr = T.liquids.take_reagents_flat(target_value)
	tempr.trans_to(src, tempr.total_volume)
	qdel(tempr)

/obj/machinery/plumbing/liquid_output_pump
	name = "liquid output pump"
	desc = "Pump used to dump liquids out from a plumbing pipenet into a location."
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	anchored = FALSE
	density = TRUE
	idle_power_usage = 10
	active_power_usage = 1000
	buffer = 300

	var/turned_on = FALSE
	var/height_regulator = 0

	var/is_working = FALSE

	var/drain_flat = 20
	var/drain_percent = 0.4

/obj/machinery/plumbing/liquid_output_pump/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		turned_on = FALSE

/obj/machinery/plumbing/liquid_output_pump/attack_hand(mob/user)
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be anchored first!</span>")
		return
	to_chat(user, "<span class='notice'>You turn [src] [turned_on ? "off" : "on"].</span>")
	turned_on = !turned_on

/obj/machinery/plumbing/liquid_output_pump/CtrlClick(mob/living/user)
	if(anchored)
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	var/new_height = input(user, "Set new height regulation:\n([0]-[LIQUID_HEIGHT_CONSIDER_FULL_TILE]. Use 0 to disable the regulation)\nThe pump will only siphon if environment is below the regulation", "Liquid Pump") as num|null
	if(QDELETED(src))
		return
	if(new_height)
		height_regulator = sanitize_integer(new_height, 0, LIQUID_HEIGHT_CONSIDER_FULL_TILE, 0)

/obj/machinery/plumbing/liquid_output_pump/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's currently [turned_on ? "ON" : "OFF"].</span>"
	. += "<span class='notice'>It's height regulator [height_regulator ? "points at [height_regulator]" : "is disabled"]. (Ctrl-click to change)</span>"

/obj/machinery/plumbing/liquid_output_pump/proc/can_pump()
	if(!turned_on || !anchored || panel_open || !isturf(loc) || reagents.total_volume == 0)
		return FALSE
	if(height_regulator)
		var/turf/T = loc
		if(T.liquids && T.liquids.height >= height_regulator)
			return FALSE
	return TRUE

/obj/machinery/plumbing/liquid_output_pump/process(delta_time)
	var/last_pumped = is_working
	is_working = can_pump()
	if(is_working != last_pumped)
		update_icon_state()
	if(!is_working)
		return

	var/turf/T = loc

	var/target_value = delta_time * (drain_flat + (reagents.total_volume * drain_percent))
	if(target_value > reagents.total_volume)
		target_value = reagents.total_volume

	var/datum/reagents/tempr = new(10000)
	reagents.trans_to(tempr, target_value, no_react = TRUE)
	T.add_liquid_from_reagents(tempr)
	qdel(tempr)

/obj/machinery/plumbing/liquid_output_pump/Initialize(mapload, bolt)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

/obj/machinery/plumbing/liquid_output_pump/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = initial(icon_state) + "-open"
	else if(is_working)
		icon_state = initial(icon_state) + "-on"
	else
		icon_state = initial(icon_state)

/obj/item/construction/plumbing/engineering
	name = "engineering plumbing constructor"
	desc = "A type of plumbing constructor designed to rapidly deploy the machines needed for logistics regarding fluids."
	icon = 'modular_skyrat/modules/liquids/icons/obj/tools.dmi'
	icon_state = "plumberer_engi"
	has_ammobar = TRUE

/obj/item/construction/plumbing/engineering/set_plumbing_designs()
	plumbing_design_types = list(
	/obj/machinery/plumbing/input = 5,
	/obj/machinery/plumbing/output = 5,
	/obj/machinery/plumbing/tank = 20,
	/obj/machinery/plumbing/acclimator = 10,
	/obj/machinery/plumbing/filter = 5,
	/obj/machinery/plumbing/splitter = 5,
	/obj/machinery/plumbing/disposer = 10,
	/obj/machinery/plumbing/liquid_input_pump = 20,
	/obj/machinery/plumbing/liquid_output_pump = 20
)
