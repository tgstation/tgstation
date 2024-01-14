/obj/item/precursor_tank
	name = "precursor tank"
	desc = "A tank that stores precursors for useful in the manufacturer."

	icon = 'monkestation/code/modules/wiremod_chem/icons/items.dmi'
	icon_state = "precursor_tank"

	w_class = WEIGHT_CLASS_HUGE
	force = 10
	throwforce = 13
	throw_speed = 2
	throw_range = 4
	item_flags = NO_PIXEL_RANDOM_DROP

	var/stored_precursor = 2500
	var/max_precursor = 2500

/obj/item/precursor_tank/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=10, force_wielded=10)

/obj/item/precursor_tank/pre_attack(atom/A, mob/living/user, params)
	if(istype(A, /obj/machinery/chem_dispenser))
		if(!do_after(user, 3 SECONDS, A))
			return TRUE
		var/obj/machinery/chem_dispenser/dispenser = A
		var/missing = max_precursor - stored_precursor
		if(!missing)
			return TRUE
		var/max_units = round(dispenser.cell.charge * 0.1)
		var/min_result = min(missing, max_units)

		dispenser.cell.charge -= max(0, min_result * 10)
		stored_precursor += min_result
		user.visible_message(span_notice("[user] fills up the [src] from the [dispenser]."), span_notice("You fill up the [src] from the [dispenser]."))
		return TRUE
	return ..()

/obj/item/precursor_tank/examine(mob/user)
	. = ..()
	. += span_notice("The [name] currently has [stored_precursor] out of [max_precursor] stored.")
