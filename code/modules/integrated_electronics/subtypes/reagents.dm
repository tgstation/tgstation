#define IC_SMOKE_REAGENTS_MINIMUM_UNITS 10

/obj/item/integrated_circuit/reagent
	category_text = "Reagent"
	resistance_flags = UNACIDABLE | FIRE_PROOF
	cooldown_per_use = 10
	var/volume = 0

/obj/item/integrated_circuit/reagent/Initialize()
	. = ..()
	if(volume)
		create_reagents(volume, OPENCONTAINER)
		push_vol()

/obj/item/integrated_circuit/reagent/proc/push_vol()
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	push_data()

// Hydroponics trays have no reagents holder and handle reagents in their own snowflakey way.
// This is a dirty hack to make injecting reagents into them work.
// TODO: refactor that.
/obj/item/integrated_circuit/reagent/proc/inject_tray(obj/machinery/hydroponics/tray, atom/movable/source, amount)
	var/atom/movable/acting_object = get_object()
	var/list/trays = list(tray)
	var/visi_msg = "[acting_object] transfers fluid into [tray]"

	if(amount > 30 && source.reagents.total_volume >= 30 && tray.using_irrigation)
		trays = tray.FindConnected()
		if (trays.len > 1)
			visi_msg += ", setting off the irrigation system"

	acting_object.visible_message("<span class='notice'>[visi_msg].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, 1)

	var/split = round(amount/trays.len)

	for(var/obj/machinery/hydroponics/H in trays)
		var/datum/reagents/temp_reagents = new /datum/reagents()
		temp_reagents.my_atom = H

		source.reagents.trans_to(temp_reagents, split)
		H.applyChemicals(temp_reagents)

		temp_reagents.clear_reagents()
		qdel(temp_reagents)

/obj/item/integrated_circuit/reagent/injector
	name = "integrated hypo-injector"
	desc = "This scary looking thing is able to pump liquids into, or suck liquids out of, whatever it's pointed at."
	icon_state = "injector"
	extended_desc = "This autoinjector can push up to 30 units of reagents into another container or someone else outside of the machine. The target \
	must be adjacent to the machine, and if it is a person, they cannot be wearing thick clothing. Negative given amounts makes the injector suck out reagents instead."

	volume = 30

	complexity = 20
	cooldown_per_use = 6 SECONDS
	inputs = list(
		"target" = IC_PINTYPE_REF,
		"injection amount" = IC_PINTYPE_NUMBER
		)
	inputs_default = list(
		"2" = 5
		)
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"inject" = IC_PINTYPE_PULSE_IN,
		"on injected" = IC_PINTYPE_PULSE_OUT,
		"on fail" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN

		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 15
	var/direction_mode = SYRINGE_INJECT
	var/transfer_amount = 10
	var/busy = FALSE

/obj/item/integrated_circuit/reagent/injector/on_reagent_change(changetype)
	push_vol()

/obj/item/integrated_circuit/reagent/injector/on_data_written()
	var/new_amount = get_pin_data(IC_INPUT, 2)
	if(new_amount < 0)
		new_amount = -new_amount
		direction_mode = SYRINGE_DRAW
	else
		direction_mode = SYRINGE_INJECT
	if(isnum(new_amount))
		new_amount = CLAMP(new_amount, 0, volume)
		transfer_amount = new_amount


/obj/item/integrated_circuit/reagent/injector/do_work(ord)
	switch(ord)
		if(1)
			inject()
		if(4)
			set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
			push_data()

/obj/item/integrated_circuit/reagent/injector/proc/inject()
	set waitfor = FALSE // Don't sleep in a proc that is called by a processor without this set, otherwise it'll delay the entire thing
	var/atom/movable/AM = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/atom/movable/acting_object = get_object()

	if(busy || !check_target(AM))
		activate_pin(3)
		return

	if(!AM.reagents)
		if(istype(AM, /obj/machinery/hydroponics) && direction_mode == SYRINGE_INJECT && reagents.total_volume && transfer_amount)//injection into tray.
			inject_tray(AM, src, transfer_amount)
			activate_pin(2)
			return
		activate_pin(3)
		return

	if(direction_mode == SYRINGE_INJECT)
		if(!reagents.total_volume || !AM.is_injectable() || AM.reagents.holder_full())
			activate_pin(3)
			return

		if(isliving(AM))
			var/mob/living/L = AM
			if(!L.can_inject(null, 0))
				activate_pin(3)
				return

			//Always log attemped injections for admins
			var/contained = reagents.log_list()
			log_combat(src, L, "attempted to inject", addition="which had [contained]")
			L.visible_message("<span class='danger'>[acting_object] is trying to inject [L]!</span>", \
								"<span class='userdanger'>[acting_object] is trying to inject you!</span>")
			busy = TRUE
			if(do_atom(src, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject,null,0)))
				var/fraction = min(transfer_amount/reagents.total_volume, 1)
				reagents.reaction(L, INJECT, fraction)
				reagents.trans_to(L, transfer_amount)
				log_combat(src, L, "injected", addition="which had [contained]")
				L.visible_message("<span class='danger'>[acting_object] injects [L] with its needle!</span>", \
									"<span class='userdanger'>[acting_object] injects you with its needle!</span>")
			else
				busy = FALSE
				activate_pin(3)
				return
			busy = FALSE

		else
			reagents.trans_to(AM, transfer_amount)

	if(direction_mode == SYRINGE_DRAW)
		if(reagents.total_volume >= reagents.maximum_volume)
			acting_object.visible_message("[acting_object] tries to draw from [AM], but the injector is full.")
			activate_pin(3)
			return

		var/tramount = abs(transfer_amount)

		if(isliving(AM))
			var/mob/living/L = AM
			L.visible_message("<span class='danger'>[acting_object] is trying to take a blood sample from [L]!</span>", \
								"<span class='userdanger'>[acting_object] is trying to take a blood sample from you!</span>")
			busy = TRUE
			if(do_atom(src, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject,null,0)))
				if(L.transfer_blood_to(src, tramount))
					L.visible_message("<span class='danger'>[acting_object] takes a blood sample from [L]!</span>", \
					"<span class='userdanger'>[acting_object] takes a blood sample from you!</span>")
				else
					L.visible_message("<span class='warning'>[acting_object] fails to take a blood sample from [L].</span>", \
								"<span class='userdanger'>[acting_object] fails to take a blood sample from you!</span>")
					busy = FALSE
					activate_pin(3)
					return
			busy = FALSE

		else
			if(!AM.reagents.total_volume)
				acting_object.visible_message("<span class='notice'>[acting_object] tries to draw from [AM], but it is empty!</span>")
				activate_pin(3)
				return

			if(!AM.is_drawable())
				activate_pin(3)
				return
			tramount = min(tramount, AM.reagents.total_volume)
			AM.reagents.trans_to(src, tramount)
	activate_pin(2)



/obj/item/integrated_circuit/reagent/pump
	name = "reagent pump"
	desc = "Moves liquids safely inside a machine, or even nearby it."
	icon_state = "reagent_pump"
	extended_desc = "This is a pump which will move liquids from the source ref to the target ref. The third pin determines \
	how much liquid is moved per pulse, between 0 and 50. The pump can move reagents to any open container inside the machine, or \
	outside the machine if it is adjacent to the machine."

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
		new_amount = CLAMP(new_amount, 0, 50)
		transfer_amount = new_amount

/obj/item/integrated_circuit/reagent/pump/do_work()
	var/atom/movable/source = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/atom/movable/target = get_pin_data_as_type(IC_INPUT, 2, /atom/movable)

	// Check for invalid input.
	if(!check_target(source) || !check_target(target))
		return

	// If the pump is pumping backwards, swap target and source.
	if(!direction_mode)
		var/temp_source = source
		source = target
		target = temp_source

	if(!source.reagents)
		return

	if(!target.reagents)
		// Hydroponics trays have no reagents holder and handle reagents in their own snowflakey way.
		// This is a dirty hack to make injecting reagents into them work.
		if(istype(target, /obj/machinery/hydroponics) && source.reagents.total_volume)
			inject_tray(target, source, transfer_amount)
			activate_pin(2)
		return

	if(!source.is_drainable() || !target.is_refillable())
		return

	source.reagents.trans_to(target, transfer_amount)
	activate_pin(2)

/obj/item/integrated_circuit/reagent/storage
	cooldown_per_use = 1
	name = "reagent storage"
	desc = "Stores liquid inside the device away from electrical components. It can store up to 60u."
	icon_state = "reagent_storage"
	extended_desc = "This is effectively an internal beaker."

	volume = 60

	complexity = 4
	inputs = list()
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list("push ref" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH



/obj/item/integrated_circuit/reagent/storage/do_work()
	set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
	push_data()

/obj/item/integrated_circuit/reagent/storage/on_reagent_change(changetype)
	push_vol()

/obj/item/integrated_circuit/reagent/storage/big
	name = "big reagent storage"
	icon_state = "reagent_storage_big"
	desc = "Stores liquid inside the device away from electrical components. Can store up to 180u."

	volume = 180

	complexity = 16
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/cryo
	name = "cryo reagent storage"
	desc = "Stores liquid inside the device away from electrical components. It can store up to 60u. This will also prevent reactions."
	icon_state = "reagent_storage_cryo"
	extended_desc = "This is effectively an internal cryo beaker."

	complexity = 8
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/cryo/Initialize()
	. = ..()
	ENABLE_BITFIELD(reagents.flags, NO_REACT)

/obj/item/integrated_circuit/reagent/storage/grinder
	name = "reagent grinder"
	desc = "This is a reagent grinder. It accepts a ref to something, and refines it into reagents. It can store up to 100u."
	icon_state = "blender"
	extended_desc = ""
	inputs = list(
		"target" = IC_PINTYPE_REF,
		)
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"grind" = IC_PINTYPE_PULSE_IN,
		"on grind" = IC_PINTYPE_PULSE_OUT,
		"on fail" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	volume = 100
	power_draw_per_use = 150
	complexity = 16
	spawn_flags = IC_SPAWN_RESEARCH


/obj/item/integrated_circuit/reagent/storage/grinder/do_work(ord)
	switch(ord)
		if(1)
			grind()
		if(4)
			set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
			push_data()

/obj/item/integrated_circuit/reagent/storage/grinder/proc/grind()
	if(reagents.total_volume >= reagents.maximum_volume)
		activate_pin(3)
		return FALSE
	var/obj/item/I = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(istype(I)&&(I.grind_results)&&check_target(I)&&(I.on_grind(src) != -1))
		reagents.add_reagent_list(I.grind_results)
		if(I.reagents)
			I.reagents.trans_to(src, I.reagents.total_volume)
		qdel(I)
		activate_pin(2)
		return TRUE
	activate_pin(3)
	return FALSE

/obj/item/integrated_circuit/reagent/storage/juicer
	name = "reagent juicer"
	desc = "This is a reagent juicer. It accepts a ref to something and refines it into reagents. It can store up to 100u."
	icon_state = "blender"
	extended_desc = ""
	inputs = list(
		"target" = IC_PINTYPE_REF,
		)
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"juice" = IC_PINTYPE_PULSE_IN,
		"on juice" = IC_PINTYPE_PULSE_OUT,
		"on fail" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	volume = 100
	power_draw_per_use = 150
	complexity = 16
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/juicer/do_work(ord)
	switch(ord)
		if(1)
			juice()
		if(4)
			set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
			push_data()

/obj/item/integrated_circuit/reagent/storage/juicer/proc/juice()
	if(reagents.total_volume >= reagents.maximum_volume)
		activate_pin(3)
		return FALSE
	var/obj/item/I = get_pin_data_as_type(IC_INPUT, 1, /obj/item)
	if(istype(I)&&check_target(I)&&(I.juice_results)&&(I.on_juice() != -1))
		reagents.add_reagent_list(I.juice_results)
		qdel(I)
		activate_pin(2)
		return TRUE
	activate_pin(3)
	return FALSE



/obj/item/integrated_circuit/reagent/storage/scan
	name = "reagent scanner"
	desc = "Stores liquid inside the device away from electrical components. It can store up to 60u. On pulse this beaker will send list of contained reagents."
	icon_state = "reagent_scan"
	extended_desc = "Mostly useful for filtering reagents."

	complexity = 8
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF,
		"list of reagents" = IC_PINTYPE_LIST
		)
	activators = list(
		"scan" = IC_PINTYPE_PULSE_IN,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/reagent/storage/scan/do_work(ord)
	switch(ord)
		if(1)
			var/cont[0]
			for(var/datum/reagent/RE in reagents.reagent_list)
				cont += RE
			set_pin_data(IC_OUTPUT, 3, cont)
			push_data()
		if(2)
			set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
			push_data()

/obj/item/integrated_circuit/reagent/filter
	name = "reagent filter"
	desc = "Filters liquids by list of desired or unwanted reagents."
	icon_state = "reagent_filter"
	extended_desc = "This is a filter which will move liquids from the source to its target. \
	If the amount in the fourth pin is positive, it will move all reagents except those in the unwanted list. \
	If the amount in the fourth pin is negative, it will only move the reagents in the wanted list. \
	The third pin determines how many reagents are moved per pulse, between 0 and 50. Amount is given for each separate reagent."

	complexity = 8
	inputs = list(
		"source" = IC_PINTYPE_REF,
		"target" = IC_PINTYPE_REF,
		"injection amount" = IC_PINTYPE_NUMBER,
		"list of reagents" = IC_PINTYPE_LIST
		)
	inputs_default = list(
		"3" = 5
		)
	outputs = list()
	activators = list(
		"transfer reagents" = IC_PINTYPE_PULSE_IN,
		"on transfer" = IC_PINTYPE_PULSE_OUT
		)
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
		new_amount = CLAMP(new_amount, 0, 50)
		transfer_amount = new_amount

/obj/item/integrated_circuit/reagent/filter/do_work()
	var/atom/movable/source = get_pin_data_as_type(IC_INPUT, 1, /atom/movable)
	var/atom/movable/target = get_pin_data_as_type(IC_INPUT, 2, /atom/movable)
	var/list/demand = get_pin_data(IC_INPUT, 4)

	// Check for invalid input.
	if(!check_target(source) || !check_target(target))
		return

	if(!source.reagents || !target.reagents)
		return

	// FALSE in those procs makes mobs invalid targets.
	if(!source.is_drawable(FALSE) || !target.is_injectable(FALSE))
		return

	if(target.reagents.maximum_volume - target.reagents.total_volume <= 0)
		return

	for(var/datum/reagent/G in source.reagents.reagent_list)
		if(!direction_mode)
			if(G in demand)
				source.reagents.trans_id_to(target, G.type, transfer_amount)
		else
			if(!(G in demand))
				source.reagents.trans_id_to(target, G.type, transfer_amount)
	activate_pin(2)
	push_data()

/obj/item/integrated_circuit/reagent/storage/heater
	name = "chemical heater"
	desc = "Stores liquid inside the device away from electrical components. It can store up to 60u. It will heat or cool the reagents \
	to the target temperature when turned on."
	icon_state = "heater"
	complexity = 8
	inputs = list(
		"target temperature" = IC_PINTYPE_NUMBER,
		"on" = IC_PINTYPE_BOOLEAN
		)
	inputs_default = list("1" = 300)
	outputs = list("volume used" = IC_PINTYPE_NUMBER,"self reference" = IC_PINTYPE_SELFREF,"temperature" = IC_PINTYPE_NUMBER)
	spawn_flags = IC_SPAWN_RESEARCH
	var/heater_coefficient = 0.1

/obj/item/integrated_circuit/reagent/storage/heater/on_data_written()
	if(get_pin_data(IC_INPUT, 2))
		power_draw_idle = 30
	else
		power_draw_idle = 0

/obj/item/integrated_circuit/reagent/storage/heater/Initialize()
	.=..()
	START_PROCESSING(SScircuit, src)

/obj/item/integrated_circuit/reagent/storage/heater/Destroy()
	STOP_PROCESSING(SScircuit, src)
	return ..()

/obj/item/integrated_circuit/reagent/storage/heater/process()
	if(!power_draw_idle)
		return
	var/target_temperature = get_pin_data(IC_INPUT, 1)
	if(reagents.chem_temp > target_temperature)
		reagents.chem_temp += min(-1, (target_temperature - reagents.chem_temp) * heater_coefficient)
	if(reagents.chem_temp < target_temperature)
		reagents.chem_temp += max(1, (target_temperature - reagents.chem_temp) * heater_coefficient)

	reagents.chem_temp = round(reagents.chem_temp)
	reagents.handle_reactions()
	set_pin_data(IC_OUTPUT, 3, reagents.chem_temp)
	push_data()


/obj/item/integrated_circuit/reagent/smoke
	name = "smoke generator"
	desc = "Unlike most electronics, creating smoke is completely intentional."
	icon_state = "smoke"
	extended_desc = "This smoke generator creates clouds of smoke on command. It can also hold liquids inside, which will go \
	into the smoke clouds when activated. The reagents are consumed when the smoke is made."
	ext_cooldown = 1
	volume = 100
	complexity = 20
	cooldown_per_use = 1 SECONDS
	inputs = list()
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"create smoke" = IC_PINTYPE_PULSE_IN,
		"on smoked" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 20
	var/smoke_radius = 5
	var/notified = FALSE

/obj/item/integrated_circuit/reagent/smoke/on_reagent_change(changetype)
	//reset warning only if we have reagents now
	if(changetype == ADD_REAGENT)
		notified = FALSE
	push_vol()
/obj/item/integrated_circuit/reagent/smoke/do_work(ord)
	switch(ord)
		if(1)
			if(!reagents || (reagents.total_volume < IC_SMOKE_REAGENTS_MINIMUM_UNITS))
				return
			var/location = get_turf(src)
			var/datum/effect_system/smoke_spread/chem/S = new
			S.attach(location)
			playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
			if(S)
				S.set_up(reagents, smoke_radius, location, notified)
				if(!notified)
					notified = TRUE
				S.start()
			reagents.clear_reagents()
			activate_pin(2)
		if(3)
			set_pin_data(IC_OUTPUT, 2, WEAKREF(src))
			push_data()

// - Integrated extinguisher - //
/obj/item/integrated_circuit/reagent/extinguisher
	name = "integrated extinguisher"
	desc = "This circuit sprays any of its contents out like an extinguisher."
	icon_state = "injector"
	extended_desc = "This circuit can hold up to 30 units of any given chemicals. On each use, it sprays these reagents like a fire extinguisher."

	volume = 30

	complexity = 20
	cooldown_per_use = 6 SECONDS
	inputs = list(
		"target X rel" = IC_PINTYPE_NUMBER,
		"target Y rel" = IC_PINTYPE_NUMBER
		)
	outputs = list(
		"volume" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"spray" = IC_PINTYPE_PULSE_IN,
		"on sprayed" = IC_PINTYPE_PULSE_OUT,
		"on fail" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 15
	var/busy = FALSE

/obj/item/integrated_circuit/reagent/extinguisher/Initialize()
	.=..()
	set_pin_data(IC_OUTPUT,2, src)

/obj/item/integrated_circuit/reagent/extinguisher/on_reagent_change(changetype)
	push_vol()

/obj/item/integrated_circuit/reagent/extinguisher/do_work()
	//Check if enough volume
	set_pin_data(IC_OUTPUT, 1, reagents.total_volume)
	if(!reagents || reagents.total_volume < 5 || busy)
		push_data()
		activate_pin(3)
		return

	playsound(loc, 'sound/effects/extinguish.ogg', 75, 1, -3)
	//Get the tile on which the water particle spawns
	var/turf/Spawnpoint = get_turf(src)
	if(!Spawnpoint)
		push_data()
		activate_pin(3)
		return

	//Get direction and target turf for each water particle
	var/turf/T = locate(Spawnpoint.x + get_pin_data(IC_INPUT, 1),Spawnpoint.y + get_pin_data(IC_INPUT, 2),Spawnpoint.z)
	if(!T)
		push_data()
		activate_pin(3)
		return
	var/direction = get_dir(Spawnpoint, T)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)
	busy = TRUE

	// Create list with particles and their targets
	var/list/water_particles=list()
	for(var/a=0, a<5, a++)
		var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src))
		water_particles[W] = pick(the_targets)
		var/datum/reagents/R = new/datum/reagents(5)
		W.reagents = R
		R.my_atom = W
		reagents.trans_to(W,1)

	//Make em move dat ass, hun
	addtimer(CALLBACK(src, /obj/item/integrated_circuit/reagent/extinguisher/proc/move_particles, water_particles), 2)

//This whole proc is a loop
/obj/item/integrated_circuit/reagent/extinguisher/proc/move_particles(var/list/particles, var/repetitions=0)
	//Check if there's anything in here first
	if(!particles || particles.len == 0)
		return
	// Second loop: Get all the water particles and make them move to their target
	for(var/obj/effect/particle_effect/water/W in particles)
		var/turf/my_target = particles[W]
		if(!W)
			continue
		step_towards(W,my_target)
		if(!W.reagents)
			continue
		W.reagents.reaction(get_turf(W))
		for(var/A in get_turf(W))
			W.reagents.reaction(A)
		if(W.loc == my_target)
			break
	if(repetitions < 4)
		repetitions++	//Can't have math operations in addtimer(CALLBACK())
		addtimer(CALLBACK(src, /obj/item/integrated_circuit/reagent/extinguisher/proc/move_particles, particles, repetitions), 2)
	else
		push_data()
		activate_pin(2)
		busy = FALSE


// - Drain circuit - //
/obj/item/integrated_circuit/reagent/drain
	name = "chemical drain circuit"
	desc = "This circuit either eliminates reagents by creating a puddle or can suck up chemicals on tiles."
	icon_state = "injector"
	extended_desc = "Set mode to FALSE to eliminate reagents and TRUE to drain."

	volume = 20

	complexity = 10
	inputs = list(
		"mode" = IC_PINTYPE_BOOLEAN
		)
	outputs = list(
		"volume" = IC_PINTYPE_NUMBER,
		"self reference" = IC_PINTYPE_SELFREF
		)
	activators = list(
		"drain" = IC_PINTYPE_PULSE_IN,
		"on drained" = IC_PINTYPE_PULSE_OUT,
		"on fail" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_IN
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 15


/obj/item/integrated_circuit/reagent/drain/Initialize()
	.=..()
	set_pin_data(IC_OUTPUT,2, src)


/obj/item/integrated_circuit/reagent/drain/do_work()
	if(get_pin_data(IC_OUTPUT, 1, reagents.total_volume))
		if(!reagents || !reagents.total_volume)
			push_data()
			activate_pin(3)
			return
		// Put the reagents on the floortile the assembly is on
		reagents.reaction(get_turf(src))
		reagents.clear_reagents()
		push_data()
		activate_pin(2)
		return

	else
		if(reagents)
			if(reagents.total_volume >= volume)
				push_data()
				activate_pin(3)
				return
		// Favorably, drain it from a chemicals pile, else, try something different
		var/obj/effect/decal/cleanable/drainedchems = locate(/obj/effect/decal/cleanable) in get_turf(src)
		if(!drainedchems || !drainedchems.reagents || drainedchems.reagents.total_volume == 0)
			push_data()
			activate_pin(3)
			return
		drainedchems.reagents.trans_to(src, 30, 0.5)
		if(drainedchems.reagents.total_volume == 0)
			qdel(drainedchems)
	push_data()
	activate_pin(2)


/obj/item/integrated_circuit/reagent/drain/on_reagent_change(changetype)
	push_vol()


// - Beaker Connector - //
/obj/item/integrated_circuit/input/beaker_connector
	category_text = "Reagent"
	cooldown_per_use = 1
	name = "beaker slot"
	desc = "Lets you add a beaker to your assembly and remove it even when the assembly is closed."
	icon_state = "reagent_storage"
	extended_desc = "It can help you extract reagents easier."
	complexity = 4

	inputs = list()
	outputs = list(
		"volume used" = IC_PINTYPE_NUMBER,
		"current beaker" = IC_PINTYPE_REF
		)
	activators = list(
		"on insert" = IC_PINTYPE_PULSE_OUT,
		"on remove" = IC_PINTYPE_PULSE_OUT,
		"push ref" = IC_PINTYPE_PULSE_OUT
		)

	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	can_be_asked_input = TRUE
	demands_object_input = TRUE
	can_input_object_when_closed = TRUE

	var/obj/item/reagent_containers/glass/beaker/current_beaker


/obj/item/integrated_circuit/input/beaker_connector/attackby(var/obj/item/reagent_containers/I, var/mob/living/user)
	//Check if it truly is a reagent container
	if(!istype(I,/obj/item/reagent_containers/glass/beaker))
		to_chat(user,"<span class='warning'>The [I.name] doesn't seem to fit in here.</span>")
		return

	//Check if there is no other beaker already inside
	if(current_beaker)
		to_chat(user,"<span class='notice'>There is already a reagent container inside.</span>")
		return

	//The current beaker is the one we just attached, its location is inside the circuit
	current_beaker = I
	user.transferItemToLoc(I,src)

	to_chat(user,"<span class='warning'>You put the [I.name] inside the beaker connector.</span>")

	//Set the pin to a weak reference of the current beaker
	push_vol()
	set_pin_data(IC_OUTPUT, 2, WEAKREF(current_beaker))
	push_data()
	activate_pin(1)
	activate_pin(3)


/obj/item/integrated_circuit/input/beaker_connector/ask_for_input(mob/user)
	attack_self(user)


/obj/item/integrated_circuit/input/beaker_connector/attack_self(mob/user)
	//Check if no beaker attached
	if(!current_beaker)
		to_chat(user, "<span class='notice'>There is currently no beaker attached.</span>")
		return

	//Remove beaker and put in user's hands/location
	to_chat(user, "<span class='notice'>You take [current_beaker] out of the beaker connector.</span>")
	user.put_in_hands(current_beaker)
	current_beaker = null
	//Remove beaker reference
	push_vol()
	set_pin_data(IC_OUTPUT, 2, null)
	push_data()
	activate_pin(2)
	activate_pin(3)


/obj/item/integrated_circuit/input/beaker_connector/proc/push_vol()
	var/beakerVolume = 0
	if(current_beaker)
		beakerVolume = current_beaker.reagents.total_volume

	set_pin_data(IC_OUTPUT, 1, beakerVolume)
	push_data()


/obj/item/reagent_containers/glass/beaker/on_reagent_change()
	..()
	if(istype(loc,/obj/item/integrated_circuit/input/beaker_connector))
		var/obj/item/integrated_circuit/input/beaker_connector/current_circuit = loc
		current_circuit.push_vol()
