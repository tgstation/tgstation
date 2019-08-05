/**Basic plumbing object.
* It doesn't really hold anything special, YET.
* Objects that are plumbing but not a subtype are as of writing liquid pumps and the reagent_dispenser tank
* Also please note that the plumbing component is toggled on and off by the component using a signal from default_unfasten_wrench, so dont worry about it
*/
/obj/machinery/plumbing
	name = "pipe thing"
	icon = 'icons/obj/plumbing/plumbers.dmi'
	icon_state = "pump"
	density = TRUE
	active_power_usage = 30
	use_power = ACTIVE_POWER_USE
	///Plumbing machinery is always gonna need reagents, so we might aswell put it here
	var/buffer = 50
	///Flags for reagents, like INJECTABLE, TRANSPARENT bla bla everything thats in DEFINES/reagents.dm
	var/reagent_flags = TRANSPARENT

/obj/machinery/plumbing/Initialize(mapload)
	. = ..()
	create_reagents(buffer, reagent_flags)

///We can empty beakers in here and everything
/obj/machinery/plumbing/input
	name = "input gate"
	desc = "Can be manually filled with reagents from containers."
	icon_state = "pipe_input"
	reagent_flags = TRANSPARENT | REFILLABLE

/obj/machinery/plumbing/input/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply)

/obj/machinery/plumbing/input/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE

///We can fill beakers in here and everything. we dont inheret from input because it has nothing that we need
/obj/machinery/plumbing/output
	name = "output gate"
	desc = "A manual output for plumbing systems, for taking reagents directly into containers."
	icon_state = "pipe_output"
	reagent_flags = TRANSPARENT | DRAINABLE

/obj/machinery/plumbing/output/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand)

/obj/machinery/plumbing/output/wrench_act(mob/living/user, obj/item/I)
	..()
	default_unfasten_wrench(user, I)
	return TRUE