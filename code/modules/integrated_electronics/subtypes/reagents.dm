/obj/item/integrated_circuit/reagent
	category_text = "Reagent"
	var/volume = 0
	resistance_flags = UNACIDABLE | FIRE_PROOF

/obj/item/integrated_circuit/reagent/New()
	..()
	if(volume)
		create_reagents(volume)

/obj/item/integrated_circuit/reagent/smoke
	name = "smoke generator"
	desc = "Unlike most electronics, creating smoke is completely intentional."
	icon_state = "smoke"
	extended_desc = "This smoke generator creates clouds of smoke on command.  It can also hold liquids inside, which will go \
	into the smoke clouds when activated.  The reagents are consumed when smoke is made."
	container_type = OPENCONTAINER_1
	complexity = 20
	cooldown_per_use = 1 SECONDS
	inputs = list()
	outputs = list("volume used" = IC_PINTYPE_NUMBER,"self reference" = IC_PINTYPE_REF)
	activators = list("create smoke" = IC_PINTYPE_PULSE_IN,"on smoked" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	volume = 100
	power_draw_per_use = 20
	var/smoke_radius = 5
	var/notified = FALSE

/obj/item/integrated_circuit/reagent/smoke/on_reagent_change(changetype)
	//reset warning only if we have reagents now
	if(changetype == ADD_REAGENT)
		notified = FALSE
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	push_data()


/obj/item/integrated_circuit/reagent/smoke/interact(mob/user)
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()
	..()

/obj/item/integrated_circuit/reagent/smoke/do_work()
	var/location = get_turf(src)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(reagents, smoke_radius, location, notified)
		if(!notified)
			notified = TRUE
		S.start()

	if(reagents)
		reagents.clear_reagents()
	activate_pin(2)


/obj/item/integrated_circuit/reagent/injector
	name = "integrated hypo-injector"
	desc = "This scary looking thing is able to pump liquids into whatever it's pointed at."
	icon_state = "injector"
	extended_desc = "This autoinjector can push reagents into another container or someone else outside of the machine.  The target \
	must be adjacent to the machine, and if it is a person, they cannot be wearing thick clothing. Negative given amount makes injector suck out reagents."
	container_type = OPENCONTAINER_1
	complexity = 20
	cooldown_per_use = 6 SECONDS
	inputs = list("target" = IC_PINTYPE_REF, "injection amount" = IC_PINTYPE_NUMBER)
	inputs_default = list("2" = 5)
	outputs = list("volume used" = IC_PINTYPE_NUMBER,"self reference" = IC_PINTYPE_REF)
	activators = list("inject" = IC_PINTYPE_PULSE_IN, "on injected" = IC_PINTYPE_PULSE_OUT, "on fail" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	volume = 30
	power_draw_per_use = 15
	var/direction_mode = SYRINGE_INJECT
	var/transfer_amount = 10
	var/busy = FALSE

/obj/item/integrated_circuit/reagent/injector/interact(mob/user)
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()
	..()


/obj/item/integrated_circuit/reagent/injector/on_reagent_change(changetype)
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	push_data()

/obj/item/integrated_circuit/reagent/injector/on_data_written()
	var/new_amount = get_pin_data(IC_INPUT, 2)
	if(new_amount < 0)
		new_amount = -new_amount
		direction_mode = SYRINGE_DRAW
	else
		direction_mode = SYRINGE_INJECT
	if(isnum(new_amount))
		new_amount = Clamp(new_amount, 0, volume)
		transfer_amount = new_amount

/obj/item/integrated_circuit/reagent/proc/inject_tray(var/obj/machinery/hydroponics/H,var/atom/movable/SO,var/A)
		var/datum/reagents/S = new /datum/reagents() //This is a strange way, but I don't know of a better one so I can't fix it at the moment...
		S.my_atom = H
		SO.reagents.trans_to(S,A)
		H.applyChemicals(S)
		S.clear_reagents()
		qdel(S)

/obj/item/integrated_circuit/reagent/injector/do_work()
	set waitfor = FALSE // Don't sleep in a proc that is called by a processor without this set, otherwise it'll delay the entire thing
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	if(!istype(AM)||!Adjacent(AM)||busy)
		activate_pin(3)
		return
	if(istype(AM,/obj/machinery/hydroponics)&&(direction_mode==SYRINGE_INJECT)&&(reagents.total_volume))//injection into tray.
		inject_tray(AM,src,transfer_amount)
		activate_pin(2)
		return
	if(!AM.reagents)
		activate_pin(3)
		return
	if(direction_mode == SYRINGE_INJECT)
		if(!reagents.total_volume) // Empty
			activate_pin(3)
			return
		if(AM.is_injectable())
			if(AM.reagents.total_volume>=AM.reagents.maximum_volume)
				activate_pin(3)
				return
			if(isliving(AM))
				var/mob/living/L = AM
				if(!L.can_inject(null, 0))
					activate_pin(3)
					return
				//Always log attemped injections for admins
				var/list/rinject = list()
				for(var/datum/reagent/R in reagents.reagent_list)
					rinject += R.name
				var/contained = english_list(rinject)
				add_logs(src, L, "attemped to inject", addition="which had [contained]") //TODO: proper logging (maybe last touched and assembled)
				L.visible_message("<span class='danger'>[src] is trying to inject [L]!</span>", \
										"<span class='userdanger'>[src] is trying to inject you!</span>")
				busy = TRUE
				if(do_atom(src, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject,null,0)))
					var/fraction = min(transfer_amount/reagents.total_volume, 1)
					reagents.reaction(L, INJECT, fraction)
					reagents.trans_to(L, transfer_amount)
					L.visible_message("<span class='danger'>[src] injects [L] with its needle!</span>", \
											"<span class='userdanger'>[src] injects you with its needle!</span>")
				else
					busy = FALSE
					activate_pin(3)
					return
				busy = FALSE
			else
				reagents.trans_to(AM, transfer_amount)
		else
			activate_pin(3)
			return
	else
		if(reagents.total_volume >= reagents.maximum_volume) // Full
			activate_pin(3)
			return
		var/tramount = Clamp(min(transfer_amount, reagents.maximum_volume - reagents.total_volume), 0, reagents.maximum_volume)
		if(isliving(AM))
			var/mob/living/L = AM
			L.visible_message("<span class='danger'>[src] is trying to take a blood sample from [L]!</span>", \
									"<span class='userdanger'>[src] is trying to take a blood sample from you!</span>")
			busy = TRUE
			if(do_atom(src, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject,null,0)))
				if(L.transfer_blood_to(src, tramount))
					L.visible_message("[src] takes a blood sample from [L].")
				else
					busy = FALSE
					activate_pin(3)
					return
			busy = FALSE
		else
			if(!AM.reagents.total_volume || !AM.is_drawable())
				activate_pin(3)
				return
			AM.reagents.trans_to(src, tramount)
	activate_pin(2)




/obj/item/integrated_circuit/reagent/pump
	name = "reagent pump"
	desc = "Moves liquids safely inside a machine, or even nearby it."
	icon_state = "reagent_pump"
	extended_desc = "This is a pump, which will move liquids from the source ref to the target ref.  The third pin determines \
	how much liquid is moved per pulse, between 0 and 50.  The pump can move reagents to any open container inside the machine, or \
	outside the machine if it is next to the machine.  Note that this cannot be used on entities."
	container_type = OPENCONTAINER_1
	complexity = 8
	inputs = list("source" = IC_PINTYPE_REF, "target" = IC_PINTYPE_REF, "injection amount" = IC_PINTYPE_NUMBER)
	inputs_default = list("3" = 5)
	outputs = list()
	activators = list("transfer reagents" = IC_PINTYPE_PULSE_IN, "on transfer" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/transfer_amount = 10
	var/direction_mode = SYRINGE_INJECT
	power_draw_per_use = 10

/obj/item/integrated_circuit/reagent/pump/on_data_written()
	var/new_amount = get_pin_data(IC_INPUT, 3)
	if(new_amount < 0)
		new_amount = -new_amount
		direction_mode = SYRINGE_DRAW
	else
		direction_mode = SYRINGE_INJECT
	if(isnum(new_amount))
		new_amount = Clamp(new_amount, 0, 50)
		transfer_amount = new_amount

/obj/item/integrated_circuit/reagent/pump/do_work()
	var/atom/movable/source = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/atom/movable/target = get_pin_data_as_type(IC_INPUT, 2, /atom/movable)

	if(!istype(source) || !istype(target) || !source.reagents) //Invalid input
		return
	if(Adjacent(source) && Adjacent(target))
		if(istype(target,/obj/machinery/hydroponics)&&(source.reagents.total_volume))//injection into tray.
			inject_tray(target,source,transfer_amount)
			activate_pin(2)
			return

		if(!target.reagents)
			return
		if(ismob(source) || ismob(target))
			return
		if(!source.is_open_container() || !target.is_open_container())
			return
		if(direction_mode)
			if(target.reagents.maximum_volume - target.reagents.total_volume <= 0) //full
				return
			source.reagents.trans_to(target, transfer_amount)
		else
			if(source.reagents.maximum_volume - source.reagents.total_volume <= 0)
				return
			target.reagents.trans_to(source, transfer_amount)
		activate_pin(2)

/obj/item/integrated_circuit/reagent/storage
	name = "reagent storage"
	desc = "Stores liquid inside, and away from electrical components.  Can store up to 60u."
	icon_state = "reagent_storage"
	extended_desc = "This is effectively an internal beaker."
	container_type = OPENCONTAINER_1
	complexity = 4
	inputs = list()
	outputs = list("volume used" = IC_PINTYPE_NUMBER,"self reference" = IC_PINTYPE_REF)
	activators = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	volume = 60


/obj/item/integrated_circuit/reagent/storage/interact(mob/user)
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()
	..()

/obj/item/integrated_circuit/reagent/storage/on_reagent_change(changetype)
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	push_data()

/obj/item/integrated_circuit/reagent/storage/cryo
	name = "cryo reagent storage"
	desc = "Stores liquid inside, and away from electrical components.  Can store up to 60u.  This will also suppress reactions."
	icon_state = "reagent_storage_cryo"
	extended_desc = "This is effectively an internal cryo beaker."
	container_type = OPENCONTAINER_1
	complexity = 8
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/cryo/New()
	. = ..()
	reagents.set_reacting(FALSE)

/obj/item/integrated_circuit/reagent/storage/big
	name = "big reagent storage"
	desc = "Stores liquid inside, and away from electrical components.  Can store up to 180u."
	icon_state = "reagent_storage_big"
	extended_desc = "This is effectively an internal beaker."
	container_type = OPENCONTAINER_1
	complexity = 16
	volume = 180
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/scan
	name = "reagent scanner"
	desc = "Stores liquid inside, and away from electrical components.  Can store up to 60u.  On pulse this beaker will send list of contained reagents."
	icon_state = "reagent_scan"
	extended_desc = "Mostly useful for reagent filter."
	container_type = OPENCONTAINER_1
	complexity = 8
	outputs = list("volume used" = IC_PINTYPE_NUMBER,"self reference" = IC_PINTYPE_REF,"list of reagents" = IC_PINTYPE_LIST)
	activators = list("scan" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/scan/do_work()
	var/cont[0]
	for(var/datum/reagent/RE in reagents.reagent_list)
		cont += RE.id
	set_pin_data(IC_OUTPUT, 3, cont)
	push_data()


/obj/item/integrated_circuit/reagent/filter
	name = "reagent filter"
	desc = "Filtering liquids by list of desired or unwanted reagents."
	icon_state = "reagent_filter"
	extended_desc = "This is a filter, which will move liquids from the source ref to the target ref. \
	It will move all reagents, except list, given in fourth pin if amount value is positive.\
	Or it will move only desired reagents if amount is negative, The third pin determines \
	how much reagent is moved per pulse, between 0 and 50. Amount is given for each separate reagent."
	container_type = OPENCONTAINER_1
	complexity = 8
	inputs = list("source" = IC_PINTYPE_REF, "target" = IC_PINTYPE_REF, "injection amount" = IC_PINTYPE_NUMBER, "list of reagents" = IC_PINTYPE_LIST)
	inputs_default = list("3" = 5)
	outputs = list()
	activators = list("transfer reagents" = IC_PINTYPE_PULSE_IN, "on transfer" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/transfer_amount = 10
	var/direction_mode = SYRINGE_INJECT
	power_draw_per_use = 10

/obj/item/integrated_circuit/reagent/filter/on_data_written()
	var/new_amount = get_pin_data(IC_INPUT, 3)
	if(new_amount < 0)
		new_amount = -new_amount
		direction_mode = SYRINGE_DRAW
	else
		direction_mode = SYRINGE_INJECT
	if(isnum(new_amount))
		new_amount = Clamp(new_amount, 0, 50)
		transfer_amount = new_amount

/obj/item/integrated_circuit/reagent/filter/do_work()
	var/atom/movable/source = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/atom/movable/target = get_pin_data_as_type(IC_INPUT, 2, /atom/movable)
	var/list/demand = get_pin_data(IC_INPUT, 4)
	if(!istype(source) || !istype(target)) //Invalid input
		return
	var/turf/T = get_turf(src)
	if(source.Adjacent(T) && target.Adjacent(T))
		if(!source.reagents || !target.reagents)
			return
		if(ismob(source) || ismob(target))
			return
		if(!source.is_open_container() || !target.is_open_container())
			return
		if(target.reagents.maximum_volume - target.reagents.total_volume <= 0)
			return
		for(var/datum/reagent/G in source.reagents.reagent_list)
			if (!direction_mode)
				if(G.id in demand)
					source.reagents.trans_id_to(target, G.id, transfer_amount)
			else
				if(!(G.id in demand))
					source.reagents.trans_id_to(target, G.id, transfer_amount)
		activate_pin(2)
		push_data()



