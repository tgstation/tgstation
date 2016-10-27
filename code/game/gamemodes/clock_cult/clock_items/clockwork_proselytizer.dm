
/obj/item/clockwork/clockwork_proselytizer //Clockwork proselytizer (yes, that's a real word): Converts applicable objects to Ratvarian variants.
	name = "clockwork proselytizer"
	desc = "An odd, L-shaped device that hums with energy."
	clockwork_desc = "A device that allows the replacing of mundane objects with Ratvarian variants. It requires liquified Replicant Alloy to function."
	icon_state = "clockwork_proselytizer"
	w_class = 3
	force = 5
	flags = NOBLUDGEON
	var/stored_alloy = 0 //Requires this to function; each chunk of replicant alloy provides REPLICANT_ALLOY_UNIT
	var/max_alloy = REPLICANT_ALLOY_UNIT * 10
	var/uses_alloy = TRUE
	var/metal_to_alloy = FALSE
	var/repairing = null //what we're currently repairing, if anything

/obj/item/clockwork/clockwork_proselytizer/preloaded
	stored_alloy = REPLICANT_WALL_MINUS_FLOOR+REPLICANT_WALL_TOTAL

/obj/item/clockwork/clockwork_proselytizer/scarab
	name = "scarab proselytizer"
	clockwork_desc = "A cogscarab's internal proselytizer. It can only be successfully used by a cogscarab and requires liquified Replicant Alloy to function."
	metal_to_alloy = TRUE
	item_state = "nothing"
	w_class = 1
	var/debug = FALSE

/obj/item/clockwork/clockwork_proselytizer/scarab/proselytize(atom/target, mob/living/user)
	if(!debug && !isdrone(user))
		return 0
	return ..()

/obj/item/clockwork/clockwork_proselytizer/scarab/debug
	clockwork_desc = "A cogscarab's internal proselytizer. It can convert nearly any object into a Ratvarian variant."
	uses_alloy = FALSE
	debug = TRUE

/obj/item/clockwork/clockwork_proselytizer/examine(mob/living/user)
	..()
	if(is_servant_of_ratvar(user) || isobserver(user))
		user << "<span class='brass'>Can be used to convert walls, floors, windows, airlocks, windoors, and grilles to clockwork variants.</span>"
		user << "<span class='brass'>Can also form some objects into Replicant Alloy, as well as reform Clockwork Walls into Clockwork Floors, and vice versa.</span>"
		if(metal_to_alloy)
			user << "<span class='alloy'>It can convert rods, metal, and plasteel to liquified replicant alloy at a low rate.</span>"
		if(uses_alloy)
			user << "<span class='alloy'>It has <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy stored.</span>"
			user << "<span class='alloy'>Use it on a Tinkerer's Cache, strike it with Replicant Alloy, or attack Replicant Alloy with it to add additional liquified alloy.</span>"
			user << "<span class='alloy'>Use it in-hand to remove stored liquified alloy.</span>"

/obj/item/clockwork/clockwork_proselytizer/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user) && uses_alloy)
		if(!can_use_alloy(REPLICANT_ALLOY_UNIT))
			user << "<span class='warning'>[src] [stored_alloy ? "Lacks enough":"Contains no"] alloy to reform[stored_alloy ? "":" any"] into solidified alloy!</span>"
			return
		modify_stored_alloy(-REPLICANT_ALLOY_UNIT)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		new/obj/item/clockwork/component/replicant_alloy(user.loc)
		user << "<span class='brass'>You force [stored_alloy ? "some":"all"] of the alloy in [src]'s compartments to reform and solidify. \
		It now contains <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy.</span>"

/obj/item/clockwork/clockwork_proselytizer/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/clockwork/component/replicant_alloy) && is_servant_of_ratvar(user) && uses_alloy)
		if(!can_use_alloy(-REPLICANT_ALLOY_UNIT))
			user << "<span class='warning'>[src]'s replicant alloy compartments are full!</span>"
			return 0
		modify_stored_alloy(REPLICANT_ALLOY_UNIT)
		playsound(user, 'sound/machines/click.ogg', 50, 1)
		clockwork_say(user, text2ratvar("Transmute into fuel."), TRUE)
		user << "<span class='brass'>You force [I] to liquify and pour it into [src]'s compartments. It now contains <b>[stored_alloy]/[max_alloy]</b> units of liquified alloy.</span>"
		user.drop_item()
		qdel(I)
		return 1
	else
		return ..()

/obj/item/clockwork/clockwork_proselytizer/afterattack(atom/target, mob/living/user, proximity_flag, params)
	if(!target || !user || !proximity_flag)
		return 0
	if(!is_servant_of_ratvar(user))
		return ..()
	proselytize(target, user)

/obj/item/clockwork/clockwork_proselytizer/proc/modify_stored_alloy(amount)
	if(can_use_alloy(RATVAR_ALLOY_CHECK)) //Ratvar makes it free
		amount = 0
	stored_alloy = Clamp(stored_alloy + amount, 0, max_alloy)
	return 1

/obj/item/clockwork/clockwork_proselytizer/proc/can_use_alloy(amount)
	if(amount == RATVAR_ALLOY_CHECK)
		if(ratvar_awakens || !uses_alloy)
			return TRUE
		else
			return FALSE
	if(stored_alloy - amount < 0)
		return FALSE
	if(stored_alloy - amount > max_alloy)
		return FALSE
	return TRUE

/obj/item/clockwork/clockwork_proselytizer/proc/proselytize(atom/target, mob/living/user)
	if(!target || !user)
		return 0
	var/target_type = target.type
	var/list/proselytize_values = target.proselytize_vals(user, src) //relevant values for proselytizing stuff, given as an associated list
	if(!islist(proselytize_values))
		if(proselytize_values != TRUE) //if we get true, fail, but don't send a message for whatever reason
			user << "<span class='warning'>[target] cannot be proselytized!</span>"
		return 0
	if(repairing)
		user << "<span class='warning'>You are currently repairing [repairing] with [src]!</span>"
		return 0
	if(!uses_alloy)
		proselytize_values["alloy_cost"] = 0

	if(!can_use_alloy(proselytize_values["alloy_cost"]))
		if(stored_alloy - proselytize_values["alloy_cost"] < 0)
			user << "<span class='warning'>You need <b>[proselytize_values["alloy_cost"]]</b> liquified alloy to proselytize [target]!</span>"
		else if(stored_alloy - proselytize_values["alloy_cost"] > max_alloy)
			user << "<span class='warning'>You have too much liquified alloy stored to proselytize [target]!</span>"
		return 0

	if(can_use_alloy(RATVAR_ALLOY_CHECK)) //Ratvar makes it faster
		proselytize_values["operation_time"] *= 0.5

	user.visible_message("<span class='warning'>[user]'s [name] begins tearing apart [target]!</span>", "<span class='brass'>You begin proselytizing [target]...</span>")
	playsound(target, 'sound/machines/click.ogg', 50, 1)
	if(proselytize_values["operation_time"] && !do_after(user, proselytize_values["operation_time"], target = target))
		return 0
	if(!can_use_alloy(proselytize_values["alloy_cost"])) //Check again to prevent bypassing via spamclick
		return 0
	if(!target || target.type != target_type)
		return 0
	if(repairing)
		return 0
	user.visible_message("<span class='warning'>[user]'s [name] disgorges a chunk of metal and shapes it over what's left of [target]!</span>", \
	"<span class='brass'>You proselytize [target].</span>")
	playsound(target, 'sound/items/Deconstruct.ogg', 50, 1)
	var/new_thing_type = proselytize_values["new_obj_type"]
	if(isturf(target))
		var/turf/T = target
		T.ChangeTurf(new_thing_type)
	else
		if(proselytize_values["dir_in_new"])
			new new_thing_type(get_turf(target), proselytize_values["spawn_dir"])
		else
			var/atom/A = new new_thing_type(get_turf(target))
			A.setDir(proselytize_values["spawn_dir"])
		qdel(target)
	modify_stored_alloy(-proselytize_values["alloy_cost"])
	return 1
