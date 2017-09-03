//Replica Fabricator: Converts applicable objects to Ratvarian variants.
/obj/item/clockwork/replica_fabricator
	name = "replica fabricator"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires power to function."
	icon_state = "replica_fabricator"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	flags_1 = NOBLUDGEON_1
	var/stored_power = 0 //Requires power to function
	var/max_power = CLOCKCULT_POWER_UNIT * 10
	var/uses_power = TRUE
	var/repairing = null //what we're currently repairing, if anything
	var/obj/effect/clockwork/sigil/transmission/recharging = null //the sigil we're charging from, if any
	var/speed_multiplier = 1 //how fast this fabricator works
	var/charge_rate = MIN_CLOCKCULT_POWER //how much power we gain every two seconds
	var/charge_delay = 2 //how many proccess ticks remain before we can start to charge

/obj/item/clockwork/replica_fabricator/preloaded
	stored_power = POWER_WALL_MINUS_FLOOR+POWER_WALL_TOTAL

/obj/item/clockwork/replica_fabricator/scarab
	name = "scarab fabricator"
	clockwork_desc = "A cogscarab's internal fabricator. It can only be successfully used by a cogscarab and requires power to function."
	item_state = "nothing"
	w_class = WEIGHT_CLASS_TINY
	speed_multiplier = 0.5
	charge_rate = MIN_CLOCKCULT_POWER * 2
	var/debug = FALSE

/obj/item/clockwork/replica_fabricator/scarab/fabricate(atom/target, mob/living/user)
	if(!debug && !isdrone(user))
		return 0
	return ..()

/obj/item/clockwork/replica_fabricator/scarab/debug
	clockwork_desc = "A cogscarab's internal fabricator. It can convert nearly any object into a Ratvarian variant."
	uses_power = FALSE
	debug = TRUE

/obj/item/clockwork/replica_fabricator/cyborg
	name = "cyborg fabricator"
	clockwork_desc = "A cyborg's internal fabricator. It is capable of using the cyborg's power in addition to stored power."

/obj/item/clockwork/replica_fabricator/cyborg/get_power() //returns power and cyborg's power
	var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
	var/borg_power = 0
	var/current_charge = 0
	if(istype(R) && R.cell)
		current_charge = R.cell.charge
		while(current_charge > MIN_CLOCKCULT_POWER)
			current_charge -= MIN_CLOCKCULT_POWER
			borg_power += MIN_CLOCKCULT_POWER
	return ..() + borg_power

/obj/item/clockwork/replica_fabricator/cyborg/get_max_power()
	var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
	var/cell_maxcharge = 0
	if(istype(R) && R.cell)
		cell_maxcharge = R.cell.maxcharge
	return ..() + cell_maxcharge

/obj/item/clockwork/replica_fabricator/cyborg/can_use_power(amount)
	if(amount != RATVAR_POWER_CHECK)
		var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
		var/current_charge = 0
		if(istype(R) && R.cell)
			current_charge = R.cell.charge
			while(amount > 0 && stored_power - amount < 0) //amount is greater than 0 and stored power minus the amount is still less than 0
				current_charge -= MIN_CLOCKCULT_POWER
				amount -= MIN_CLOCKCULT_POWER
		if(current_charge < 0)
			return FALSE
	. = ..()

/obj/item/clockwork/replica_fabricator/cyborg/modify_stored_power(amount)
	var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
	if(istype(R) && R.cell && amount)
		if(amount < 0)
			while(amount < 0 && stored_power + amount < 0) //amount is less than 0 and stored alloy plus the amount is less than 0
				R.cell.use(MIN_CLOCKCULT_POWER)
				amount += MIN_CLOCKCULT_POWER
		else
			while(amount > 0 && R.cell.charge + MIN_CLOCKCULT_POWER < R.cell.maxcharge) //amount is greater than 0 and cell charge plus MIN_CLOCKCULT_POWER is less than maximum cell charge
				R.cell.give(MIN_CLOCKCULT_POWER)
				amount -= MIN_CLOCKCULT_POWER
	. = ..()

/obj/item/clockwork/replica_fabricator/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clockwork/replica_fabricator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clockwork/replica_fabricator/process()
	if(!charge_rate)
		return
	var/mob/living/L = get_atom_on_turf(src, /mob/living)
	if(istype(L) && is_servant_of_ratvar(L))
		if(charge_delay)
			charge_delay--
			return
		modify_stored_power(charge_rate)
		for(var/obj/item/clockwork/replica_fabricator/S in L.GetAllContents()) //no multiple fabricators
			if(S == src)
				continue
			S.charge_delay = 2
	else
		charge_delay = 2

/obj/item/clockwork/replica_fabricator/ratvar_act()
	if(GLOB.ratvar_awakens)
		uses_power = FALSE
		speed_multiplier = initial(speed_multiplier) * 0.25
	else
		uses_power = initial(uses_power)
		speed_multiplier = initial(speed_multiplier)

/obj/item/clockwork/replica_fabricator/examine(mob/living/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='brass'>Can be used to replace walls, floors, tables, windows, windoors, and airlocks with Clockwork variants.</span>")
		to_chat(user, "<span class='brass'>Can construct Clockwork Walls on Clockwork Floors and deconstruct Clockwork Walls to Clockwork Floors.</span>")
		if(uses_power)
			to_chat(user, "<span class='alloy'>It can consume floor tiles, rods, metal, and plasteel for power at rates of <b>2:[DisplayPower(POWER_ROD)]</b>, <b>1:[DisplayPower(POWER_ROD)]</b>, <b>1:[DisplayPower(POWER_METAL)]</b>, \
			and <b>1:[DisplayPower(POWER_PLASTEEL)]</b>, respectively.</span>")
			to_chat(user, "<span class='alloy'>It can also consume brass sheets for power at a rate of <b>1:[DisplayPower(POWER_FLOOR)]</b>.</span>")
			to_chat(user, "<span class='alloy'>It is storing <b>[DisplayPower(get_power())]/[DisplayPower(get_max_power())]</b> of power[charge_rate ? ", and is gaining <b>[DisplayPower(charge_rate*0.5)]</b> of power per second":""].</span>")
			to_chat(user, "<span class='alloy'>Use it in-hand to produce <b>5</b> brass sheets at a cost of <b>[DisplayPower(POWER_WALL_TOTAL)]</b> power.</span>")

/obj/item/clockwork/replica_fabricator/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user))
		if(uses_power)
			if(!can_use_power(POWER_WALL_TOTAL))
				to_chat(user, "<span class='warning'>[src] requires <b>[DisplayPower(POWER_WALL_TOTAL)]</b> of power to produce brass sheets!</span>")
				return
			modify_stored_power(-POWER_WALL_TOTAL)
		playsound(src, 'sound/items/deconstruct.ogg', 50, 1)
		new/obj/item/stack/tile/brass(user.loc, 5)
		to_chat(user, "<span class='brass'>You use [stored_power ? "some":"all"] of [src]'s power to produce <b>5</b> brass sheets. It now stores <b>[DisplayPower(get_power())]/[DisplayPower(get_max_power())]</b> of power.</span>")

/obj/item/clockwork/replica_fabricator/pre_attackby(atom/target, mob/living/user, params)
	if(!target || !user || !is_servant_of_ratvar(user) || istype(target, /obj/item/storage))
		return TRUE
	return fabricate(target, user)

/obj/item/clockwork/replica_fabricator/proc/get_power()
	return stored_power

/obj/item/clockwork/replica_fabricator/proc/get_max_power()
	return max_power

/obj/item/clockwork/replica_fabricator/proc/modify_stored_power(amount)
	stored_power = Clamp(stored_power + amount, 0, max_power)
	return TRUE

/obj/item/clockwork/replica_fabricator/proc/can_use_power(amount)
	if(amount == RATVAR_POWER_CHECK)
		if(GLOB.ratvar_awakens || !uses_power)
			return TRUE
		else
			return FALSE
	if(stored_power - amount < 0)
		return FALSE
	if(stored_power - amount > max_power)
		return FALSE
	return TRUE

//A note here; return values are for if we CAN BE PUT ON A TABLE, not IF WE ARE SUCCESSFUL, unless no_table_check is TRUE
/obj/item/clockwork/replica_fabricator/proc/fabricate(atom/target, mob/living/user, silent, no_table_check)
	if(!target || !user)
		return FALSE
	if(repairing)
		if(!silent)
			to_chat(user, "<span class='warning'>You are currently repairing [repairing] with [src]!</span>")
		return FALSE
	if(recharging)
		if(!silent)
			to_chat(user, "<span class='warning'>You are currently recharging [src] from the [recharging.sigil_name]!</span>")
		return FALSE
	var/list/fabrication_values = target.fabrication_vals(user, src, silent) //relevant values for fabricating stuff, given as an associated list
	if(!islist(fabrication_values))
		if(fabrication_values != TRUE) //if we get true, fail, but don't send a message for whatever reason
			if(!isturf(target)) //otherwise, if we didn't get TRUE and the original target wasn't a turf, try to fabricate the turf
				return fabricate(get_turf(target), user, no_table_check)
			if(!silent)
				to_chat(user, "<span class='warning'>[target] cannot be fabricated!</span>")
			if(!no_table_check)
				return TRUE
		return FALSE
	if(can_use_power(RATVAR_POWER_CHECK))
		fabrication_values["power_cost"] = 0

	var/turf/Y = get_turf(user)
	if(!Y || (Y.z != ZLEVEL_STATION && Y.z != ZLEVEL_CENTCOM && Y.z != ZLEVEL_MINING && Y.z != ZLEVEL_LAVALAND))
		fabrication_values["operation_time"] *= 2
		if(fabrication_values["power_cost"] > 0)
			fabrication_values["power_cost"] *= 2

	var/target_type = target.type

	if(!fabricate_checks(fabrication_values, target, target_type, user, silent))
		return FALSE

	fabrication_values["operation_time"] *= speed_multiplier

	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(fabrication_values["operation_time"])
		if(!silent)
			var/atom/A = fabrication_values["new_obj_type"]
			if(A)
				user.visible_message("<span class='warning'>[user]'s [name] starts ripping [target] apart!</span>", \
				"<span class='brass'>You start fabricating \a [initial(A.name)] from [target]...</span>")
			else
				user.visible_message("<span class='warning'>[user]'s [name] starts consuming [target]!</span>", \
				"<span class='brass'>Your [name] starts consuming [target]...</span>")
		if(!do_after(user, fabrication_values["operation_time"], target = target, extra_checks = CALLBACK(src, .proc/fabricate_checks, fabrication_values, target, target_type, user, TRUE)))
			return FALSE
		if(!silent)
			var/atom/A = fabrication_values["new_obj_type"]
			if(A)
				user.visible_message("<span class='warning'>[user]'s [name] replaces [target] with \a [initial(A.name)]!</span>", \
				"<span class='brass'>You fabricate \a [initial(A.name)] from [target].</span>")
			else
				user.visible_message("<span class='warning'>[user]'s [name] consumes [target]!</span>", \
				"<span class='brass'>Your [name] consumes [target].</span>")
	else
		if(!silent)
			var/atom/A = fabrication_values["new_obj_type"]
			if(A)
				user.visible_message("<span class='warning'>[user]'s [name] rips apart [target], replacing it with \a [initial(A.name)]!</span>", \
				"<span class='brass'>You fabricate \a [initial(A.name)] from [target].</span>")
			else
				user.visible_message("<span class='warning'>[user]'s [name] rapidly consumes [target]!</span>", \
				"<span class='brass'>Your [name] consumes [target].</span>")

	playsound(target, 'sound/items/deconstruct.ogg', 50, 1)
	var/new_thing_type = fabrication_values["new_obj_type"]
	if(isturf(target)) //if our target is a turf, we're just going to ChangeTurf it and assume it'll work out.
		var/turf/T = target
		T.ChangeTurf(new_thing_type)
	else
		if(new_thing_type)
			if(fabrication_values["dir_in_new"])
				new new_thing_type(get_turf(target), fabrication_values["spawn_dir"]) //please verify that your new object actually wants to get a dir in New()
			else
				var/atom/A = new new_thing_type(get_turf(target))
				A.setDir(fabrication_values["spawn_dir"])
		if(!fabrication_values["no_target_deletion"]) //for some cases where fabrication_vals() modifies the object but doesn't want it deleted
			qdel(target)
	modify_stored_power(-fabrication_values["power_cost"])
	if(no_table_check)
		return TRUE
	return FALSE

//The following three procs are heavy wizardry.
//What these procs do is they take an existing list of values, which they then modify.
//This(modifying an existing object, in this case the list) is the only way to get information OUT of a do_after callback, which this is used as.

//The fabricate check proc.
/obj/item/clockwork/replica_fabricator/proc/fabricate_checks(list/fabrication_values, atom/target, expected_type, mob/user, silent) //checked constantly while fabricating
	if(!islist(fabrication_values) || QDELETED(target) || QDELETED(user))
		return FALSE
	if(repairing || recharging)
		return FALSE
	if(target.type != expected_type)
		return FALSE
	if(can_use_power(RATVAR_POWER_CHECK))
		fabrication_values["power_cost"] = 0
	if(!can_use_power(fabrication_values["power_cost"]))
		if(stored_power - fabrication_values["power_cost"] < 0)
			if(!silent)
				var/atom/A = fabrication_values["new_obj_type"]
				if(A)
					to_chat(user, "<span class='warning'>You need <b>[DisplayPower(fabrication_values["power_cost"])]</b> power to fabricate \a [initial(A.name)] from [target]!</span>")
		else if(stored_power - fabrication_values["power_cost"] > max_power)
			if(!silent)
				var/atom/A = fabrication_values["new_obj_type"]
				if(A)
					to_chat(user, "<span class='warning'>Your [name] contains too much power to fabricate \a [initial(A.name)] from [target]!</span>")
				else
					to_chat(user, "<span class='warning'>Your [name] contains too much power to consume [target]!</span>")
		return FALSE
	return TRUE

//The repair check proc.
/obj/item/clockwork/replica_fabricator/proc/fabricator_repair_checks(list/repair_values, atom/target, mob/user, silent) //Exists entirely to avoid an otherwise unreadable series of checks.
	if(!islist(repair_values) || QDELETED(target) || QDELETED(user))
		return FALSE
	if(isliving(target)) //standard checks for if we can affect the target
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			if(!silent)
				to_chat(user, "<span class='warning'>[L] does not serve Ratvar!</span>")
			return FALSE
		if(L.health >= L.maxHealth || (L.flags_1 & GODMODE))
			if(!silent)
				to_chat(user, "<span class='warning'>[L == user ? "You are" : "[L] is"] at maximum health!</span>")
			return FALSE
		repair_values["amount_to_heal"] = L.maxHealth - L.health
	else if(isobj(target))
		if(istype(target, /obj/structure/destructible/clockwork))
			var/obj/structure/destructible/clockwork/C = target
			if(!C.can_be_repaired)
				if(!silent)
					to_chat(user, "<span class='warning'>[C] cannot be repaired!</span>")
				return FALSE
		var/obj/O = target
		if(O.obj_integrity >= O.max_integrity)
			if(!silent)
				to_chat(user, "<span class='warning'>[O] is at maximum integrity!</span>")
			return FALSE
		repair_values["amount_to_heal"] = O.max_integrity - O.obj_integrity
	else
		return FALSE
	if(repair_values["amount_to_heal"] <= 0) //nothing to heal!
		return FALSE
	repair_values["healing_for_cycle"] = min(repair_values["amount_to_heal"], FABRICATOR_REPAIR_PER_TICK) //modify the healing for this cycle
	repair_values["power_required"] = round(repair_values["healing_for_cycle"]*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER) //and get the power cost from that
	if(!can_use_power(RATVAR_POWER_CHECK) && !can_use_power(repair_values["power_required"]))
		if(!silent)
			to_chat(user, "<span class='warning'>You need at least <b>[DisplayPower(repair_values["power_required"])]</b> power to start repairin[target == user ? "g yourself" : "g [target]"], and at least \
			<b>[DisplayPower(repair_values["amount_to_heal"]*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)]</b> to fully repair [target == user ? "yourself" : "[target.p_them()]"]!</span>")
		return FALSE
	return TRUE

//The sigil charge check proc.
/obj/item/clockwork/replica_fabricator/proc/sigil_charge_checks(list/charge_values, obj/effect/clockwork/sigil/transmission/sigil, mob/user, silent)
	if(!islist(charge_values) || QDELETED(sigil) || QDELETED(user))
		return FALSE
	if(can_use_power(RATVAR_POWER_CHECK))
		return FALSE
	charge_values["power_gain"] = Clamp(sigil.power_charge, 0, POWER_WALL_MINUS_FLOOR)
	if(!charge_values["power_gain"])
		if(!silent)
			to_chat(user, "<span class='warning'>The [sigil.sigil_name] contains no power!</span>")
		return FALSE
	if(stored_power + charge_values["power_gain"] > max_power)
		if(!silent)
			to_chat(user, "<span class='warning'>Your [name] contains too much power to charge from the [sigil.sigil_name]!</span>")
		return FALSE
	return TRUE
