/obj/structure/vendomatpack
	name = "Vending machine recharge pack"
	desc = "Drag it on a vending machine to replenish its products."
	icon = 'icons/obj/vending_pack.dmi'
	icon_state = "generic"
	density = 1
	flags = FPRINT
	var/targetvendomat = /obj/machinery/vending

/obj/structure/vendomatpack/undefined
	//a placeholder for vending machines that don't have their own recharge packs

/obj/structure/vendomatpack/boozeomat
	name = "Booze-O-Mat recharge pack"
	targetvendomat = /obj/machinery/vending/boozeomat
	icon_state = "boozeomat"

/obj/structure/vendomatpack/assist
	name = "Vendomat recharge pack"
	targetvendomat = /obj/machinery/vending/assist
	icon_state = "vendomat"

/obj/structure/vendomatpack/coffee
	name = "Hot Drinks machine recharge pack"
	targetvendomat = /obj/machinery/vending/coffee
	icon_state = "coffee"

/obj/structure/vendomatpack/snack
	name = "Getmore Chocolate Corp recharge pack"
	targetvendomat = /obj/machinery/vending/snack
	icon_state = "snack"

/obj/structure/vendomatpack/cola
	name = "Robust Softdrinks recharge pack"
	targetvendomat = /obj/machinery/vending/cola
	icon_state = "Cola_Machine"

/obj/structure/vendomatpack/cigarette
	name = "Cigarette machine recharge pack"
	targetvendomat = /obj/machinery/vending/cigarette
	icon_state = "cigs"

/obj/structure/vendomatpack/medical
	name = "NanoMed Plus recharge pack"
	targetvendomat = /obj/machinery/vending/medical
	icon_state = "med"

/obj/structure/vendomatpack/security
	name = "SecTech recharge pack"
	targetvendomat = /obj/machinery/vending/security
	icon_state = "sec"

/obj/structure/vendomatpack/hydronutrients
	name = "NutriMax recharge pack"
	targetvendomat = /obj/machinery/vending/hydronutrients
	icon_state = "nutri"

/obj/structure/vendomatpack/hydroseeds
	name = "MegaSeed Servitor recharge pack"
	targetvendomat = /obj/machinery/vending/hydroseeds
	icon_state = "seeds"

/obj/structure/vendomatpack/dinnerware
	name = "Dinnerware recharge pack"
	targetvendomat = /obj/machinery/vending/dinnerware
	icon_state = "dinnerware"

/obj/structure/vendomatpack/sovietsoda
	name = "BODA recharge pack"
	targetvendomat = /obj/machinery/vending/sovietsoda
	icon_state = "sovietsoda"

/obj/structure/vendomatpack/tool
	name = "YouTool recharge pack"
	targetvendomat = /obj/machinery/vending/tool
	icon_state = "tool"

/obj/structure/vendomatpack/engivend
	name = "Engi-Vend recharge pack"
	targetvendomat = /obj/machinery/vending/engivend
	icon_state = "engivend"

/obj/structure/vendomatpack/autodrobe
	name = "AutoDrobe recharge pack"
	targetvendomat = /obj/machinery/vending/autodrobe
	icon_state = "theater"

/obj/structure/vendomatpack/hatdispenser
	name = "Hatlord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/hatdispenser
	icon_state = "hats"

/obj/structure/vendomatpack/suitdispenser
	name = "Suitlord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/suitdispenser
	icon_state = "suits"

/obj/structure/vendomatpack/shoedispenser
	name = "Shoelord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/shoedispenser
	icon_state = "shoes"

/obj/structure/vendomatpack/discount
	name = "Discount Dan's recharge pack"
	targetvendomat = /obj/machinery/vending/discount
	icon_state = "discout"

/obj/structure/vendomatpack/groans
	name = "Groans Soda recharge pack"
	targetvendomat = /obj/machinery/vending/groans
	icon_state = "groans"

/obj/structure/vendomatpack/shoedispenser
	name = "Shoelord 9000 recharge pack"
	targetvendomat = /obj/machinery/vending/shoedispenser
	icon_state = "shoes"

/obj/structure/vendomatpack/discount
	name = "Discount Dan's recharge pack"
	targetvendomat = /obj/machinery/vending/discount
	icon_state = "discout"

/obj/structure/vendomatpack/groans
	name = "Groans Soda recharge pack"
	targetvendomat = /obj/machinery/vending/groans
	icon_state = "groans"

/obj/structure/vendomatpack/magivend
	name = "MagiVend recharge pack"
	targetvendomat = /obj/machinery/vending/magivend
	icon_state = "MagiVend"

/obj/structure/vendomatpack/nazivend
	name = "Nazivend recharge pack"
	targetvendomat = /obj/machinery/vending/nazivend
	icon_state = "nazi"

/obj/structure/vendomatpack/sovietvend
	name = "KomradeVendtink recharge pack"
	targetvendomat = /obj/machinery/vending/sovietvend
	icon_state = "soviet"


//////EMPTY PACKS//////

/obj/item/emptyvendomatpack
	name = "Empty vendomat recharge pack"
	desc = "You could return it to cargo or just flatten it."
	icon = 'icons/obj/vending_pack.dmi'
	icon_state = "generic"
	item_state = "syringe_kit"
	w_class = 4.0
	flags = FPRINT|TABLEPASS

	var/foldable = /obj/item/stack/sheet/cardboard
	var/foldable_amount = 4

	autoignition_temperature = 522 // Kelvin
	fire_fuel = 2

/obj/item/emptyvendomatpack/attack_self()
	usr << "<span class='notice'>You fold [src] flat.</span>"
	new src.foldable(get_turf(src),foldable_amount)
	qdel(src)


//////CARGO STACKS OF PACKS//////

/obj/structure/stackopacks
	name = "stack of recharge packs"
	desc = "A bunch of hefty carboard boxes."
	icon = 'icons/obj/storage.dmi'
	icon_state = "stackopack"
	density = 1
	flags = FPRINT

/obj/structure/stackopacks/attack_hand(mob/user as mob)
	user << "<span class='notice'>You need some wirecutters to remove the coil first!</span>"
	return

/obj/structure/stackopacks/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/wirecutters) || istype(W,/obj/item/weapon/shard) || istype(W,/obj/item/weapon/kitchenknife) || istype(W,/obj/item/weapon/circular_saw) || istype(W, /obj/item/weapon/hatchet) || istype(W, /obj/item/weapon/kitchen/utensil/knife))
		var/turf/T = get_turf(src)
		for(var/obj/O in contents)
			O.loc = T
		user << "<span class='notice'>You remove the protective coil.</span>"
		del(src)
	else
		return attack_hand(user)

/obj/structure/stackopacks/attack_animal(mob/living/simple_animal/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.loc = T
	M << "<span class='notice'>You rip the protective coil apart.</span>"
	del(src)

/obj/structure/stackopacks/attack_paw(mob/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.loc = T
	M << "<span class='notice'>You rip the protective coil apart.</span>"
	del(src)

/obj/structure/stackopacks/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	var/turf/T = get_turf(src)
	for(var/obj/O in contents)
		O.loc = T
	M << "<span class='notice'>You rip the protective coil apart.</span>"
	del(src)

