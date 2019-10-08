/// charge is worth 1 credit but how much real power do you need for 1 charge?
#define ENERGY_TO_EXPORT_CHARGE_COEF 0.001

/obj/machinery/power/battery
	name = "export battery"
	desc = "A heavy-duty battery used for power transportation and rapid deployment on cell based ship engines."
	icon = 'icons/obj/machines/battery.dmi'
	icon_state = "battery"

	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/battery

	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 1
	integrity_failure = 100
	var/tesla_flags = TESLA_MOB_DAMAGE | TESLA_OBJ_DAMAGE
	///used to lower process() expensiveness
	var/full = FALSE
	///charge currently in the cell, it's set by refresh parts()
	var/charge = 0
	///max cell capacity, it's set by refresh parts()
	var/max_charge = 1
	///the % that goes on the owner when sold in the cargo shuttle
	var/taxes = 0
	///owner's bank account
	var/datum/bank_account/owner

/obj/machinery/power/battery/Initialize()
	. = ..()
	RefreshParts()
	START_PROCESSING(SSobj, src)

/obj/machinery/power/battery/RefreshParts()
	active_power_usage = 0
	max_charge = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		active_power_usage += 200 * C.rating
		max_charge += 2000 * C.rating
	full = FALSE
	update_icon()

/obj/machinery/power/battery/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's currently [charge/max_charge*100]% full.</span>"
	if(owner)
		. += "<span class='notice'>It's owner is [owner.account_holder] and the taxing is are set to [taxes]%.</span>"
	else
		. += "<span class='notice'>It has no owner.</span>"


/obj/machinery/power/battery/update_icon()
	cut_overlays()
	var/newlevel = round(charge/max_charge*4)
	add_overlay("battery_[newlevel]")
	if(stat & BROKEN)
		add_overlay("battery_faulty")
	if(owner)
		add_overlay("battery_owner")

/obj/machinery/power/battery/process()
	if(!full && anchored && powernet && powernet.avail)
		add_load(active_power_usage)
		charge += active_power_usage*ENERGY_TO_EXPORT_CHARGE_COEF
		if(charge >= max_charge)
			charge = max_charge
			full = TRUE

	if(stat & BROKEN && prob(20) && ((charge/max_charge) > 0.3))
		tesla_zap(src, 10, charge, tesla_flags)
		charge -= charge/2
		full = FALSE
	update_icon()

/obj/machinery/power/battery/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/machinery/power/battery/obj_destruction()
	explosion(src, -1, 0, 1, 1, flame_range = 5)
	return ..()

/obj/machinery/power/battery/_try_interact(mob/user)
	if(stat & BROKEN)
		var/check_range = TRUE
		do_sparks(5, TRUE, src)
		electrocute_mob(user, get_area(src), src, 0.7, check_range)
	return ..()

/obj/machinery/power/battery/emp_act(severity)
	. = ..()
	charge -= charge/2
	full = FALSE

/obj/machinery/power/battery/attackby(obj/item/I, mob/user, params)

	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		if(owner)
			to_chat(user, "<span class='warning'>The battery already has an owner.</span>")
			return
		if(C?.registered_account)
			owner = C.registered_account
			to_chat(user, "<span class='notice'>Your account has been linked.</span>")
			update_icon()
			return
	if(I.tool_behaviour == TOOL_MULTITOOL)
		var/mob/living/carbon/human/H
		var/obj/item/card/id/C
		if(ishuman(user))
			H = user
			C = H.get_idcard(FALSE)
			if(C?.registered_account && C.registered_account == owner)
				taxes = input(user, "Enter taxes percent", "tax", 100) as num|null
				to_chat(user, "<span class='notice'>You set taxes to [taxes]%.</span>")
				return
			else
				to_chat(user, "<span class='warning'>You dont have a valid account.</span>")
				return
	if(I.tool_behaviour == TOOL_WELDER && user.a_intent != INTENT_HARM)
		if(obj_integrity < max_integrity)
			if(I.use_tool(src, user, 0, volume = 50, amount = 1))
				user.visible_message("<span class='notice'>[user] repairs some damage to [name].</span>", "<span class='notice'>You repair some damage to \the [src].</span>")
				obj_integrity += min(10, max_integrity-obj_integrity)
				if(obj_integrity == max_integrity)
					to_chat(user, "<span class='notice'>It looks to be fully repaired now.</span>")
					stat &= ~BROKEN
					update_icon()
		return TRUE

	return ..()

/obj/machinery/power/battery/default_unfasten_wrench(mob/user, obj/item/I, time = 20)
	. = ..()
	if(. == SUCCESSFUL_UNFASTEN)
		if(anchored)
			connect_to_network()
		else
			disconnect_from_network()
		update_cable_icons_on_turf(get_turf(src))
