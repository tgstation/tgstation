/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/grill_fuel = 0
	var/grilling

/obj/machinery/grill/examine(mob/user)
	. = ..()
	if(grilling)
		. += "You can see \a [grilling] on the [src]."

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/trash/coal))
		qdel(I)
		to_chat(user, "<span class='notice'>You put the [I] in [src].</span>")
		grill_fuel += 500
		return
	if(istype(I, /obj/item/stack/sheet/mineral/wood))
		qdel(I)
		to_chat(user, "<span class='notice'>You put the [I] in [src].</span>")
		var/obj/item/stack/S = I
		grill_fuel += (50 * S.amount)
		return
	if(I.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, "<span class='warning'>You don't feel it would be wise to grill [I]...</span>")
		return ..()
	if(istype(I, /obj/item/reagent_containers))
		if(istype(I, /obj/item/reagent_containers/food))
			if(HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & (ABSTRACT | DROPDEL)))
				return ..()
			else if(!grill_fuel)
				to_chat(user, "<span class='notice'>There is not enough fuel.</span>")
			else if(!grilling && user.transferItemToLoc(I, src))
				grilling = I
				to_chat(user, "<span class='notice'>You put the [I] on [src].</span>")
				var/mutable_appearance/grilled_food = new(I)
				grilled_food.plane = FLOAT_PLANE
				grilled_food.layer = FLOAT_LAYER
				grilled_food.pixel_x = 0
				grilled_food.pixel_y = 5
				add_overlay(grilled_food)
				return
		grill_fuel += (20 * (I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy)))
		I.reagents.remove_reagent(/datum/reagent/consumable/monkey_energy, I.reagents.get_reagent_amount(/datum/reagent/consumable/monkey_energy))
	..()

/obj/machinery/grill/process()
	..()
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
			cut_overlays()
			I.forceMove(drop_location())
			if(Adjacent(user) && !issilicon(user))
				user.put_in_hands(grilling)
			grilling = null
			return
	return ..()

/obj/machinery/grill/proc/give_grill_marks(to_what)
	var/obj/item/reagent_containers/food/I = to_what
	var/index = "[REF(initial(icon))]-[initial(icon_state)]"
	var/static/list/grill_icons = list()
	var/icon/grill_icon = grill_icons[index]
	var/mutable_appearance/grill_marks
	grill_icon = icon(initial(I.icon), initial(I.icon_state), , 1)	//we only want to apply grill marks to the initial icon_state for each object
	grill_icon.Blend("#fff", ICON_ADD) 	//fills the icon_state with white (except where it's transparent)
	grill_icon.Blend(icon('icons/obj/kitchen.dmi', "grillmarks"), ICON_MULTIPLY) //adds grill marks and the remaining white areas become transparant
	grill_icon = fcopy_rsc(grill_icon)
	grill_icons[index] = grill_icon
	grill_marks = grill_icon
	if(!grill_marks)
		I.add_overlay(grill_marks)
		grill_marks.alpha = 0
	else
		grill_marks.alpha += 5


/obj/machinery/grill/unwrenched
	anchored = FALSE
