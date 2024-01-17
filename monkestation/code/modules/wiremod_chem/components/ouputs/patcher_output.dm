/obj/structure/chemical_tank/patcher
	name = "remote patcher"
	desc = "While anchored, patchs anyone who walks over it with some stored chemicals."
	icon_state = "sprayer"
	component_name = "Patcher Output"
	density = FALSE
	reagent_flags =  TRANSPARENT

	var/max_inject = 50
	var/inject_amount = 10

/obj/structure/chemical_tank/patcher/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/chemical_tank/patcher/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(!anchored)
		return
	if(!iscarbon(AM))
		return

	visible_message("[name] slaps [AM] with a patch containing [inject_amount] units.")
	reagents.trans_to(AM, inject_amount, methods = TOUCH)

/obj/structure/chemical_tank/patcher/AltClick(mob/user)
	. = ..()
	var/inject_choice = tgui_input_number(user, "How much to put into a patch?", "[name]", inject_amount, max_inject, 1)
	if(inject_choice)
		inject_amount = inject_choice
