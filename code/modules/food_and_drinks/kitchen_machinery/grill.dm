//I JUST WANNA GRILL FOR GOD'S SAKE

#define GRILL_FUELUSAGE_IDLE 0.5
#define GRILL_FUELUSAGE_ACTIVE 5

/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = NO_POWER_USE
	var/grill_fuel = 0
	var/obj/item/reagent_containers/food/grilled_item
	var/grill_time = 0
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Initialize()
	. = ..()
	grill_loop = new(list(src), FALSE)

/obj/machinery/grill/update_icon_state()
	if(grilled_item)
		icon_state = "grill"
	else if(grill_fuel > 0)
		icon_state = "grill_on"
	else
		icon_state = "grill_open"

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/mineral/coal) || istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/S = I
		var/stackamount = S.get_amount()
		to_chat(user, "<span class='notice'>You put [stackamount] [I]s in [src].</span>")
		if(istype(I, /obj/item/stack/sheet/mineral/coal))
			grill_fuel += (500 * stackamount)
		else
			grill_fuel += (50 * stackamount)
		S.use(stackamount)
		update_icon()
		return
	if(I.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "<span class='warning'>You don't feel it would be wise to grill [I]...</span>")
		return ..()
	if(istype(I, /obj/item/reagent_containers/food/drinks))
		if(I.reagents.has_reagent(/datum/reagent/consumable/monkey_energy))
			grill_fuel += (20 * (I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy)))
			to_chat(user, "<span class='notice'>You pour the Monkey Energy in [src].</span>")
			I.reagents.remove_reagent(/datum/reagent/consumable/monkey_energy, I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy))
			update_icon()
			return
	else if(IS_EDIBLE(I))
		if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & (ABSTRACT | DROPDEL)))
			return ..()
		else if(HAS_TRAIT(I, TRAIT_FOOD_GRILLED))
			to_chat(user, "<span class='notice'>[I] has already been grilled!</span>")
			return
		else if(grill_fuel <= 0)
			to_chat(user, "<span class='warning'>There is not enough fuel!</span>")
			return
		else if(!grilled_item && user.transferItemToLoc(I, src))
			grilled_item = I
			RegisterSignal(grilled_item, COMSIG_GRILL_COMPLETED, .proc/GrillCompleted)
			ADD_TRAIT(grilled_item, TRAIT_FOOD_GRILLED, "boomers")
			to_chat(user, "<span class='notice'>You put the [grilled_item] on [src].</span>")
			update_icon()
			grill_loop.start()
			return

	..()

/obj/machinery/grill/process(delta_time)
	..()
	update_icon()
	if(grill_fuel <= 0)
		return
	else
		grill_fuel -= GRILL_FUELUSAGE_IDLE * delta_time
		if(DT_PROB(0.5, delta_time))
			var/datum/effect_system/smoke_spread/bad/smoke = new
			smoke.set_up(1, loc)
			smoke.start()
	if(grilled_item)
		SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, src, delta_time)
		grill_time += delta_time
		grilled_item.reagents.add_reagent(/datum/reagent/consumable/char, 0.5 * delta_time)
		grill_fuel -= GRILL_FUELUSAGE_ACTIVE * delta_time
		grilled_item.AddComponent(/datum/component/sizzle)

/obj/machinery/grill/Exited(atom/movable/AM)
	if(AM == grilled_item)
		finish_grill()
		grilled_item = null
	..()

/obj/machinery/grill/Destroy()
	grilled_item = null
	. = ..()

/obj/machinery/grill/handle_atom_del(atom/A)
	if(A == grilled_item)
		grilled_item = null
	. = ..()

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(default_unfasten_wrench(user, I) != CANT_UNFASTEN)
		return TRUE

/obj/machinery/grill/deconstruct(disassembled = TRUE)
	finish_grill()
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/iron(loc, 5)
		new /obj/item/stack/rods(loc, 5)
	..()

/obj/machinery/grill/attack_ai(mob/user)
	return

/obj/machinery/grill/attack_hand(mob/user, list/modifiers)
	if(grilled_item)
		to_chat(user, "<span class='notice'>You take out [grilled_item] from [src].</span>")
		grilled_item.forceMove(drop_location())
		update_icon()
		return
	return ..()

/obj/machinery/grill/proc/finish_grill()
	switch(grill_time) //no 0-20 to prevent spam
		if(20 to 30)
			grilled_item.name = "lightly-grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been lightly grilled."
		if(30 to 80)
			grilled_item.name = "grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been grilled."
			grilled_item.foodtype |= FRIED
		if(80 to 100)
			grilled_item.name = "heavily grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been heavily grilled."
			grilled_item.foodtype |= FRIED
		if(100 to INFINITY) //grill marks reach max alpha
			grilled_item.name = "Powerfully Grilled [grilled_item.name]"
			grilled_item.desc = "A [grilled_item.name]. Reminds you of your wife, wait, no, it's prettier!"
			grilled_item.foodtype |= FRIED
	grill_time = 0
	UnregisterSignal(grilled_item, COMSIG_GRILL_COMPLETED, .proc/GrillCompleted)
	grill_loop.stop()

///Called when a food is transformed by the grillable component
/obj/machinery/grill/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	grilled_item = grilled_result //use the new item!!

/obj/machinery/grill/unwrenched
	anchored = FALSE

#undef GRILL_FUELUSAGE_IDLE
#undef GRILL_FUELUSAGE_ACTIVE
