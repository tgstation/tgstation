//Clockwork proselytizer: Converts applicable objects to Ratvarian variants.
/obj/item/clockwork/clockwork_proselytizer
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires power to function."
	icon_state = "clockwork_proselytizer"
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	flags = NOBLUDGEON
	var/stored_power = 0 //Requires power to function
	var/max_power = CLOCKCULT_POWER_UNIT * 10
	var/uses_power = TRUE
	var/metal_to_power = FALSE
	var/repairing = null //what we're currently repairing, if anything
	var/obj/effect/clockwork/sigil/transmission/recharging = null //the sigil we're charging from, if any
	var/speed_multiplier = 1 //how fast this proselytizer works
	var/charge_rate = MIN_CLOCKCULT_POWER //how much power we gain every two seconds
	var/charge_delay = 2 //how many proccess ticks remain before we can start to charge

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_power = POWER_WALL_MINUS_FLOOR+POWER_WALL_TOTAL

/obj/item/clockwork/clockwork_proselytizer/scarab
	name = "scarab proselytizer"
	clockwork_desc = "A cogscarab's internal proselytizer. It can only be successfully used by a cogscarab and requires power to function."
	metal_to_power = TRUE
	item_state = "nothing"
	w_class = WEIGHT_CLASS_TINY
	speed_multiplier = 0.5
	charge_rate = MIN_CLOCKCULT_POWER * 2
	var/debug = FALSE

/obj/item/clockwork/clockwork_proselytizer/scarab/proselytize(atom/target, mob/living/user)
	if(!debug && !isdrone(user))
		return 0
	return ..()

/obj/item/clockwork/clockwork_proselytizer/scarab/debug
	clockwork_desc = "A cogscarab's internal proselytizer. It can convert nearly any object into a Ratvarian variant."
	uses_power = FALSE
	debug = TRUE

/obj/item/clockwork/clockwork_proselytizer/cyborg
	name = "cyborg proselytizer"
	clockwork_desc = "A cyborg's internal proselytizer. It is capable of using the cyborg's power in addition to stored power."
	metal_to_power = TRUE

/obj/item/clockwork/clockwork_proselytizer/cyborg/get_power() //returns power and cyborg's power
	var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
	var/borg_power = 0
	var/current_charge = 0
	if(istype(R) && R.cell)
		current_charge = R.cell.charge
		while(current_charge > MIN_CLOCKCULT_POWER)
			current_charge -= MIN_CLOCKCULT_POWER
			borg_power += MIN_CLOCKCULT_POWER
	return ..() + borg_power

/obj/item/clockwork/clockwork_proselytizer/cyborg/get_max_power()
	var/mob/living/silicon/robot/R = get_atom_on_turf(src, /mob/living)
	var/cell_maxcharge = 0
	if(istype(R) && R.cell)
		cell_maxcharge = R.cell.maxcharge
	return ..() + cell_maxcharge

/obj/item/clockwork/clockwork_proselytizer/cyborg/can_use_power(amount)
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

/obj/item/clockwork/clockwork_proselytizer/cyborg/modify_stored_power(amount)
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

/obj/item/clockwork/clockwork_proselytizer/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clockwork/clockwork_proselytizer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clockwork/clockwork_proselytizer/process()
	if(!charge_rate)
		return
	var/mob/living/L = get_atom_on_turf(src, /mob/living)
	if(istype(L) && is_servant_of_ratvar(L))
		if(charge_delay)
			charge_delay--
			return
		modify_stored_power(charge_rate)
		for(var/obj/item/clockwork/clockwork_proselytizer/S in L.GetAllContents()) //no multiple proselytizers
			if(S == src)
				continue
			S.charge_delay = 2
	else
		charge_delay = 2

/obj/item/clockwork/clockwork_proselytizer/ratvar_act()
	if(GLOB.ratvar_awakens)
		uses_power = FALSE
		speed_multiplier = initial(speed_multiplier) * 0.25
	else
		uses_power = initial(uses_power)
		speed_multiplier = initial(speed_multiplier)

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='brass'>Can be used to convert walls, floors, windows, airlocks, and a variety of other objects to clockwork variants.</span>")
		to_chat(user, "<span class='brass'>Can also form some objects into Brass sheets, as well as reform Clockwork Walls into Clockwork Floors, and vice versa.</span>")
		if(uses_power)
			if(metal_to_power)
				to_chat(user, "<span class='alloy'>It can convert rods, metal, plasteel, and brass to power at rates of <b>1:[POWER_ROD]W</b>, <b>1:[POWER_METAL]W</b>, \
				<b>1:[POWER_PLASTEEL]W</b>, and <b>1:[POWER_FLOOR]W</b>, respectively.</span>")
			else
				to_chat(user, "<span class='alloy'>It can convert brass to power at a rate of <b>1:[POWER_FLOOR]W</b>.</span>")
			to_chat(user, "<span class='alloy'>It is storing <b>[get_power()]W/[get_max_power()]W</b> of power, and is gaining <b>[charge_rate*0.5]W</b> of power per second.</span>")
			to_chat(user, "<span class='alloy'>Use it in-hand to produce <b>5</b> brass sheets at a cost of <b>[POWER_WALL_TOTAL]W</b> power.</span>")

/obj/item/clockwork/clockwork_proselytizer/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user))
		if(uses_power)
			if(!can_use_power(POWER_WALL_TOTAL))
				to_chat(user, "<span class='warning'>[src] requires <b>[POWER_WALL_TOTAL]W</b> of power to produce brass sheets!</span>")
				return
			modify_stored_power(-POWER_WALL_TOTAL)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new/obj/item/stack/tile/brass(user.loc, 5)
		to_chat(user, "<span class='brass'>You user [stored_power ? "some":"all"] of [src]'s power to produce some brass sheets. It now stores <b>[get_power()]W/[get_max_power()]W</b> of power.</span>")

/obj/item/clockwork/clockwork_proselytizer/pre_attackby(atom/target, mob/living/user, params)
	if(!target || !user || !is_servant_of_ratvar(user) || istype(target, /obj/item/weapon/storage))
		return TRUE
	return proselytize(target, user)

/obj/item/clockwork/clockwork_proselytizer/proc/get_power()
	return stored_power

/obj/item/clockwork/clockwork_proselytizer/proc/get_max_power()
	return max_power

/obj/item/clockwork/clockwork_proselytizer/proc/modify_stored_power(amount)
	stored_power = Clamp(stored_power + amount, 0, max_power)
	return TRUE

/obj/item/clockwork/clockwork_proselytizer/proc/can_use_power(amount)
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
/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user, silent, no_table_check)
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
	var/list/proselytize_values = target.proselytize_vals(user, src, silent) //relevant values for proselytizing stuff, given as an associated list
	if(!islist(proselytize_values))
		if(proselytize_values != TRUE) //if we get true, fail, but don't send a message for whatever reason
			if(!isturf(target)) //otherwise, if we didn't get TRUE and the original target wasn't a turf, try to proselytize the turf
				return proselytize(get_turf(target), user, no_table_check)
			if(!silent)
				to_chat(user, "<span class='warning'>[target] cannot be proselytized!</span>")
			if(!no_table_check)
				return TRUE
		return FALSE
	if(can_use_power(RATVAR_POWER_CHECK))
		proselytize_values["power_cost"] = 0

	var/turf/Y = get_turf(user)
	if(!Y || (Y.z != ZLEVEL_STATION && Y.z != ZLEVEL_CENTCOM && Y.z != ZLEVEL_MINING && Y.z != ZLEVEL_LAVALAND))
		proselytize_values["operation_time"] *= 2
		if(proselytize_values["power_cost"] > 0)
			proselytize_values["power_cost"] *= 2

	var/target_type = target.type

	if(!proselytize_checks(proselytize_values, target, target_type, user, silent))
		return FALSE

	proselytize_values["operation_time"] *= speed_multiplier

	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(proselytize_values["operation_time"])
		if(!silent)
			user.visible_message("<span class='warning'>[user]'s [name] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
		if(!do_after(user, proselytize_values["operation_time"], target = target, extra_checks = CALLBACK(src, .proc/proselytize_checks, proselytize_values, target, target_type, user, TRUE)))
			return FALSE
		if(!silent)
			user.visible_message("<span class='warning'>[user]'s [name] covers [target] in golden energy!</span>", "<span class='brass'>You proselytize [target].</span>")
	else
		if(!silent)
			user.visible_message("<span class='warning'>[user]'s [name] tears apart [target], covering it in golden energy!</span>", "<span class='brass'>You proselytize [target].</span>")

	playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
	var/new_thing_type = proselytize_values["new_obj_type"]
	if(isturf(target)) //if our target is a turf, we're just going to ChangeTurf it and assume it'll work out.
		var/turf/T = target
		T.ChangeTurf(new_thing_type)
	else
		if(new_thing_type)
			if(proselytize_values["dir_in_new"])
				new new_thing_type(get_turf(target), proselytize_values["spawn_dir"]) //please verify that your new object actually wants to get a dir in New()
			else
				var/atom/A = new new_thing_type(get_turf(target))
				A.setDir(proselytize_values["spawn_dir"])
		if(!proselytize_values["no_target_deletion"]) //for some cases where proselytize_vals() modifies the object but doesn't want it deleted
			qdel(target)
	modify_stored_power(-proselytize_values["power_cost"])
	if(no_table_check)
		return TRUE
	return FALSE

//The following three procs are heavy wizardry.
//What these procs do is they take an existing list of values, which they then modify.
//This(modifying an existing object, in this case the list) is the only way to get information OUT of a do_after callback, which this is used as.

//The proselytize check proc.
/obj/item/clockwork/clockwork_proselytizer/proc/proselytize_checks(list/proselytize_values, atom/target, expected_type, mob/user, silent) //checked constantly while proselytizing
	if(!islist(proselytize_values) || QDELETED(target) || QDELETED(user))
		return FALSE
	if(repairing || recharging)
		return FALSE
	if(target.type != expected_type)
		return FALSE
	if(can_use_power(RATVAR_POWER_CHECK))
		proselytize_values["power_cost"] = 0
	if(!can_use_power(proselytize_values["power_cost"]))
		if(stored_power - proselytize_values["power_cost"] < 0)
			if(!silent)
				to_chat(user, "<span class='warning'>You need <b>[proselytize_values["power_cost"]]W</b> power to proselytize [target]!</span>")
		else if(stored_power - proselytize_values["power_cost"] > max_power)
			if(!silent)
				to_chat(user, "<span class='warning'>Your [name] contains too much power to proselytize [target]!</span>")
		return FALSE
	return TRUE

//The repair check proc.
/obj/item/clockwork/clockwork_proselytizer/proc/proselytizer_repair_checks(list/repair_values, atom/target, mob/user, silent) //Exists entirely to avoid an otherwise unreadable series of checks.
	if(!islist(repair_values) || QDELETED(target) || QDELETED(user))
		return FALSE
	if(isliving(target)) //standard checks for if we can affect the target
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			if(!silent)
				to_chat(user, "<span class='warning'>[L] does not serve Ratvar!</span>")
			return FALSE
		if(L.health >= L.maxHealth || (L.flags & GODMODE))
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
	repair_values["healing_for_cycle"] = min(repair_values["amount_to_heal"], PROSELYTIZER_REPAIR_PER_TICK) //modify the healing for this cycle
	repair_values["power_required"] = round(repair_values["healing_for_cycle"]*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER) //and get the power cost from that
	if(!can_use_power(RATVAR_POWER_CHECK) && !can_use_power(repair_values["power_required"]))
		if(!silent)
			to_chat(user, "<span class='warning'>You need at least <b>[repair_values["power_required"]]W</b> power to start repairin[target == user ? "g yourself" : "g [target]"], and at least \
			<b>[round(repair_values["amount_to_heal"]*MIN_CLOCKCULT_POWER, MIN_CLOCKCULT_POWER)]W</b> to fully repair [target == user ? "yourself" : "[target.p_them()]"]!</span>")
		return FALSE
	return TRUE

//The sigil charge check proc.
/obj/item/clockwork/clockwork_proselytizer/proc/sigil_charge_checks(list/charge_values, obj/effect/clockwork/sigil/transmission/sigil, mob/user, silent)
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
