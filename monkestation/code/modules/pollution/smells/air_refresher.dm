/obj/item/air_refresher
	name = "air refresher"
	desc = "A bottle packed with sickly strong fragrance, with an easy to use pressurized release nozzle."
	icon = 'monkestation/icons/obj/air_refresher.dmi'
	icon_state = "air_refresher"
	inhand_icon_state = "cleaner"
	worn_icon_state = "spraybottle"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	var/uses_remaining = 20

/obj/item/air_refresher/examine(mob/user)
	. = ..()
	if(uses_remaining)
		. += "It has [uses_remaining] use\s left."
	else
		. += "It is empty."

/obj/item/air_refresher/afterattack(atom/attacked, mob/user, proximity)
	. = ..()
	if(.)
		return
	if(uses_remaining <= 0)
		to_chat(user, span_warning("\The [src] is empty!"))
		return TRUE
	uses_remaining--
	var/turf/aimed_turf = get_turf(attacked)
	aimed_turf.pollute_turf(/datum/pollutant/fragrance/air_refresher, 200)
	user.visible_message(span_notice("[user] sprays the air around with \the [src]."), span_notice("You spray the air around with \the [src]."))
	user.changeNext_move(CLICK_CD_RANGE*2)
	playsound(aimed_turf, 'sound/effects/spray2.ogg', 50, TRUE, -6)
	return TRUE

/obj/machinery/pollution_scrubber
	name = "Pollution Scrubber"
	desc = "A scrubber that will process the air and filter out any contaminants."
	icon = 'monkestation/icons/obj/pollution_scrubber.dmi'
	icon_state = "scrubber"
	var/scrub_amount = 2
	var/on = FALSE

/obj/machinery/pollution_scrubber/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	on = !on
	balloon_alert(user, "scrubber turned [on ? "on" : "off"]")
	update_appearance()

/obj/machinery/pollution_scrubber/update_icon(updates)
	. = ..()
	if(on)
		icon_state = "scrubber_on"
	else
		icon_state = "scrubber"

/obj/machinery/pollution_scrubber/process()
	if(machine_stat)
		return
	if(on && isopenturf(get_turf(src)))
		var/turf/open/open_turf = get_turf(src)
		if(open_turf.pollution)
			open_turf.pollution.scrub_amount(scrub_amount)
			use_power(100)
