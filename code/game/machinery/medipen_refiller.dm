/obj/machinery/medipen_refiller
	name = "Medipen Refiller"
	desc = "A machine that refills used medipens with new synthetized chemicals, the process may damage the injector."
	icon = 'icons/obj/machines/medipen_refiller.dmi'
	icon_state = "medipen_refiller"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/medipen_refiller
	idle_power_usage = 100
	/// current charges counter
	var/charges = 0
	/// maximum charges it can have
	var/max_charges = 1
	/// prob of recharging on process * 2
	var/recharge_rate = 2
	/// list of medipen subtypes it can refill
	var/list/allowed = list()
	/// var to prevent glitches in the animation
	var/busy = FALSE

/obj/machinery/medipen_refiller/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It has [charges] charges stored and can hold a maximum of [max_charges] charges.</span>"

/obj/machinery/medipen_refiller/process()
	if(charges < max_charges && prob(recharge_rate))
		charges++

/obj/machinery/medipen_refiller/Initialize()
	. = ..()
	RefreshParts()
	RegisterSignal(src, COMSIG_PARENT_ATTACKBY, .proc/check_refill)
	START_PROCESSING(SSobj,src)

/obj/machinery/medipen_refiller/Destroy()
	UnregisterSignal(src, COMSIG_PARENT_ATTACKBY)
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/machinery/medipen_refiller/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/MB in component_parts)
		recharge_rate = MB.rating*2
		max_charges = MB.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		allowed = list(/obj/item/reagent_containers/hypospray/medipen)
		var/T = M.rating
		if(T >= 2)
			allowed += /obj/item/reagent_containers/hypospray/medipen/atropine
			allowed += /obj/item/reagent_containers/hypospray/medipen/salbutamol
		if(T >= 3)
			allowed += /obj/item/reagent_containers/hypospray/medipen/oxandrolone
			allowed += /obj/item/reagent_containers/hypospray/medipen/salacid
		if(T >= 4)
			allowed += /obj/item/reagent_containers/hypospray/medipen/penacid
		return TRUE

/// proc that handles the messages and animation, calls refill to end the animation
/obj/machinery/medipen_refiller/proc/check_refill(datum/source, obj/item/I, mob/user)
	if(busy)
		to_chat(user, "<span class='danger'>The machine is busy.</span>")
		return
	if(!istype(I, /obj/item/reagent_containers/hypospray/medipen))
		to_chat(user, "<span class='danger'>The machine doesn't recognize [I.name] as a valid object!</span>")
		return
	var/obj/item/reagent_containers/hypospray/medipen/P = I
	if(!(LAZYFIND(allowed, P.type)))
		to_chat(user, "<span class='danger'>Error! Unknown schematics.</span>")
		return
	if(P.reagents && P.reagents.reagent_list.len)
		to_chat(user, "<span class='notice'>The medipen is already filled.</span>")
		return
	if(!charges)
		to_chat(user, "<span class='danger'>Not enough energy stored, please wait.</span>")
		return
	if(prob(80))
		busy = TRUE
		add_overlay("active")
		addtimer(CALLBACK(src, .proc/refill, P, user), 30)
		charges--
		to_chat(user, "<span class='notice'>Medipen refilled.</span>")
	else
		to_chat(user, "<span class='danger'>The medipen was too damaged breaking apart.</span>")
	qdel(P)

/// refills the medipen
/obj/machinery/medipen_refiller/proc/refill(obj/item/reagent_containers/hypospray/medipen/P, mob/user)
	new P.type(loc)
	cut_overlays()
	busy = FALSE
