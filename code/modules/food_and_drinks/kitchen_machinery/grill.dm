//I JUST WANNA GRILL FOR GOD'S SAKE

/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = NO_POWER_USE
	var/grill_fuel = 0
	var/grilled_item
	var/grill_time = 0
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Initialize()
	. = ..()
	grill_loop = new(list(src), FALSE)

/obj/machinery/grill/update_icon()
	if(grilled_item)
		icon_state = "grill"
	else if(grill_fuel)
		icon_state = "grill_on"
	else
		icon_state = "grill_open"

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/mineral/coal) || istype(I, /obj/item/stack/sheet/mineral/wood))
		var/obj/item/stack/S = I
		to_chat(user, "<span class='notice'>You put [S.amount] [I]s in [src].</span>")
		if(istype(I, /obj/item/stack/sheet/mineral/coal))
			add_fuel(500 * S.amount)
		else
			add_fuel(50 * S.amount)
		S.use(S.get_amount())
		return
	if(I.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "<span class='warning'>You don't feel it would be wise to grill [I]...</span>")
		return ..()
	if(istype(I, /obj/item/reagent_containers))
		if(istype(I, /obj/item/reagent_containers/food) && !istype(I, /obj/item/reagent_containers/food/drinks))
			if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & (ABSTRACT | DROPDEL)))
				return ..()
			else if(!grill_fuel)
				to_chat(user, "<span class='notice'>There is not enough fuel.</span>")
				return
			else if(!grilled_item && user.transferItemToLoc(I, src))
				grilled_item = I
				to_chat(user, "<span class='notice'>You put the [I] on [src].</span>")
				update_icon()
				grill_loop.start()
				return
		else
			if(I.reagents.has_reagent(/datum/reagent/consumable/monkey_energy))
				add_fuel(20 * (I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy)))
				to_chat(user, "<span class='notice'>You pour the Monkey Energy in [src].</span>")
				I.reagents.remove_reagent(/datum/reagent/consumable/monkey_energy, I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy))
				return
	..()

/obj/machinery/grill/proc/add_fuel(amount)
	grill_fuel += amount
	update_icon()

/obj/machinery/grill/process()
	..()
	update_icon()
	if(!grill_fuel)
		return
	else
		grill_fuel -= 1
		if(prob(1))
			var/datum/effect_system/smoke_spread/bad/smoke = new
			smoke.set_up(1, loc)
			smoke.start()
	if(grilled_item)
		grill_time += 1
		var/obj/item/reagent_containers/I = grilled_item
		I.reagents.add_reagent(/datum/reagent/consumable/char, 1)
		grill_fuel -= 10
		I.AddComponent(/datum/component/sizzle)

/obj/machinery/grill/Exited(atom/movable/AM)
	..()
	grilled_item = null

/obj/machinery/grill/Destroy()
	grilled_item = null
	. = ..()

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/grill/deconstruct(disassembled = TRUE)
	finish_grill()
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
		new /obj/item/stack/rods(loc, 5)
	..()

/obj/machinery/grill/attack_ai(mob/user)
	return

/obj/machinery/grill/attack_hand(mob/user)
	if(grilled_item)
		var/obj/item/reagent_containers/food/I = grilled_item
		finish_grill()
		to_chat(user, "<span class='notice'>You take out [grilled_item] from [src].</span>")
		I.forceMove(drop_location())
		user.put_in_hands(grilled_item)
		grilled_item = null
		update_icon()
		grill_loop.stop()
		grill_time = 0
		return
	return ..()

/obj/machinery/grill/proc/finish_grill()
	var/obj/item/reagent_containers/food/I = grilled_item
	switch(grill_time) //no 0-9 to prevent spam
		if(10 to 15)
			I.name = "lightly-grilled [I.name]"
			I.desc = "[I.desc] It's been lightly grilled."
		if(16 to 39)
			I.name = "grilled [I.name]"
			I.desc = "[I.desc] It's been grilled."
			I.foodtype |= FRIED
		if(40 to 50)
			I.name = "heavily grilled [I.name]"
			I.desc = "[I.desc] It's been heavily grilled."
			I.foodtype |= FRIED
		if(51 to INFINITY) //grill marks reach max alpha
			I.name = "Powerfully Grilled [I.name]"
			I.desc = "A very heavily-grilled [I.name]. Reminds you of your wife, wait, no, it's prettier!"
			I.foodtype |= FRIED

/obj/machinery/grill/unwrenched
	anchored = FALSE
