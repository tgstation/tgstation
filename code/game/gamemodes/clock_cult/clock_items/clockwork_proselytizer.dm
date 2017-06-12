//Clockwork proselytizer: Converts applicable objects to Ratvarian variants.
/obj/item/clockwork/clockwork_proselytizer
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A dual-use construction tool that creates clockwork objects. It uses wisdom and potential to function."
	icon_state = "clockwork_proselytizer"
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	flags = NOBLUDGEON
	var/repairing = null //what we're currently repairing, if anything
	var/speed_multiplier = 1 //how fast this proselytizer works
	var/requires_resources = TRUE //if the proselytizer needs wisdom and potential to function
	var/mode = PROSELYTIZER_MODE_CONVERSION //The operating mode of the proselytizer

/obj/item/clockwork/clockwork_proselytizer/scarab
	name = "scarab proselytizer"
	clockwork_desc = "A cogscarab's internal proselytizer. It can only be successfully used by a cogscarab."
	item_state = "nothing"
	w_class = WEIGHT_CLASS_TINY
	speed_multiplier = 0.5
	var/debug = FALSE

/obj/item/clockwork/clockwork_proselytizer/scarab/proselytize(atom/target, mob/living/user)
	if(!debug && !isdrone(user))
		return 0
	return ..()

/obj/item/clockwork/clockwork_proselytizer/scarab/debug
	clockwork_desc = "A cogscarab's internal proselytizer. It can convert nearly any object into a Ratvarian variant."
	debug = TRUE

/obj/item/clockwork/clockwork_proselytizer/ratvar_act()
	if(GLOB.ratvar_awakens)
		speed_multiplier = initial(speed_multiplier) * 0.25
		requires_resources = FALSE
	else
		speed_multiplier = initial(speed_multiplier)
		requires_resources = TRUE

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		to_chat(user, "<span class='brass italics'>It's been empowered by Ratvar, and doesn't need Wisdom or Potential to function!</span>")
		to_chat(user, "<span class='brass'>It's set to <b>[mode]</b> mode.</span>")
		switch(mode)
			if(PROSELYTIZER_MODE_CONVERSION)
				to_chat(user, "<span class='brass'>In this mode, it can be used to <b>convert walls, floors, windows, airlocks, and a variety of other objects</b> to clockwork variants.</span>")
				to_chat(user, "<span class='brass'>It also <b>repair clockwork structures and mobs</b> by attacking them, at a rate of <b>1 Wisdom per 10 health.</b></span>")
				to_chat(user, "<span class='brass'>It requires <b>1 Wisdom</b> per object conversion.</span>")
				to_chat(user, "<span class='brass'><b>Current Wisdom:</b> [GLOB.clockwork_wisdom]/[GLOB.max_clockwork_wisdom]</span>")
			if(PROSELYTIZER_MODE_CONSTRUCTION)
				to_chat(user, "<span class='alloy'>In this mode, it can be used to build clockwork structures, walls, and floors from scratch using Potential and Wisdom.</span>")
				to_chat(user, "<span class='alloy'>It requires <b>1 Wisdom per construction, and variable Wisdom and Potential depending on the object.</b></span>")

/obj/item/clockwork/clockwork_proselytizer/pre_attackby(atom/target, mob/living/user, params)
	if(!target || !user || !is_servant_of_ratvar(user) || istype(target, /obj/item/weapon/storage))
		return TRUE
	if(mode == PROSELYTIZER_MODE_CONVERSION)
		return proselytize(target, user)
	else if(mode == PROSELYTIZER_MODE_CONSTRUCTION)
		return construct(target, user)

//A note here; return values are for if we CAN BE PUT ON A TABLE, not IF WE ARE SUCCESSFUL, unless no_table_check is TRUE
/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user, silent, no_table_check)
	if(!target || !user)
		return FALSE
	if(repairing)
		if(!silent)
			to_chat(user, "<span class='warning'>You are currently repairing [repairing] with [src]!</span>")
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

	var/target_type = target.type

	if(!proselytize_checks(proselytize_values, target, target_type, user, silent))
		return FALSE

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
	if(requires_resources)
		ADJUST_CLOCKWORK_WISDOM(-1)
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
	if(no_table_check)
		return TRUE
	return FALSE

//The following two procs are heavy wizardry.
//(for actual wizardry see wizard.dm)
//What these procs do is they take an existing list of values, which they then modify.
//This(modifying an existing object, in this case the list) is the only way to get information OUT of a do_after callback, which this is used as.

//The proselytize check proc.
/obj/item/clockwork/clockwork_proselytizer/proc/proselytize_checks(list/proselytize_values, atom/target, expected_type, mob/user, silent) //checked constantly while proselytizing
	if(!islist(proselytize_values) || QDELETED(target) || QDELETED(user))
		return FALSE
	if(repairing)
		return FALSE
	if(target.type != expected_type)
		return FALSE
	if(!HAS_CLOCKWORK_WISDOM(1) && requires_resources)
		to_chat(user, "<span class='warning'>There's no Wisdom available to use! Wait for some to regenerate first.</span>")
		return
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
	if(!HAS_CLOCKWORK_WISDOM(1) && requires_resources)
		if(!silent)
			to_chat(user, "<span class='warning'>There's no available wisdom to repair [target]! Wait for some to regenerate.</span>")
		return
	repair_values["healing_for_cycle"] = min(repair_values["amount_to_heal"], PROSELYTIZER_REPAIR_PER_TICK)
	return TRUE

///////////////////////////

/obj/item/clockwork/clockwork_proselytizer/proc/construct(atom/target, mob/living/user)
	var/list/costs = list("wisdom" = 0, "potential" = 0)
	return
