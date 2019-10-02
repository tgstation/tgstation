//I JUST WANNA GRILL FOR GOD'S SAKE

/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/grill_fuel = 0
	var/grilling
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Initialize()
	..()
	grill_loop = new(list(src), FALSE)

/obj/machinery/grill/update_icon()
	if(grilling)
		icon_state = "grill"
	else if(!grill_fuel)
		icon_state = "grill_open"
	else
		icon_state = "grill_on"

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/trash/coal))
		qdel(I)
		to_chat(user, "<span class='notice'>You put the [I] in [src].</span>")
		grill_fuel += 500
		update_icon()
		return
	if(istype(I, /obj/item/stack/sheet/mineral/wood))
		qdel(I)
		to_chat(user, "<span class='notice'>You put the [I] in [src].</span>")
		var/obj/item/stack/S = I
		grill_fuel += (50 * S.amount)
		update_icon()
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
			else if(!grilling && user.transferItemToLoc(I, src))
				grilling = I
				to_chat(user, "<span class='notice'>You put the [I] on [src].</span>")
				update_icon()
				grill_loop.start()
				return
		else
			grill_fuel += (20 * (I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy)))
			I.reagents.remove_reagent(/datum/reagent/consumable/monkey_energy, I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy))
			update_icon()
			return
	..()

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
	if(grilling)
		var/obj/item/reagent_containers/food/I = grilling
		I.reagents.add_reagent(/datum/reagent/smoke_powder, 1)
		grill_fuel -= 10
		I.AddComponent(/datum/component/sizzle)

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/machinery/grill/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/metal(loc, 5)
		new /obj/item/stack/rods(loc, 5)
	qdel(src)

/obj/machinery/grill/attack_ai(mob/user)
	return

/obj/machinery/grill/attack_hand(mob/user)
	if(grilling)
		var/obj/item/reagent_containers/food/I = grilling
		if(I.loc == src)
			I.name = "grilled [I.name]"
			to_chat(user, "<span class='notice'>You take out [grilling] from [src].</span>")
			I.forceMove(drop_location())
			if(Adjacent(user) && !issilicon(user))
				user.put_in_hands(grilling)
			grilling = null
			update_icon()
			grill_loop.stop()
			return
	return ..()

/obj/machinery/grill/unwrenched
	anchored = FALSE
