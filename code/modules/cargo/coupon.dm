/obj/item/coupon
	name = "coupon"
	desc = "It doesn't matter if you didn't want it before, what matters now is that you've got a coupon for it!"
	icon_state = "data_1"
	icon = 'icons/obj/card.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	var/datum/supply_pack/discounted_pack
	var/discount_pct_off = 0.05
	var/obj/machinery/computer/cargo/inserted_console

/obj/item/coupon/Initialize()
	. = ..()
	discounted_pack = pick(subtypesof(/datum/supply_pack/goody))
	discount_pct_off = pickweight(list(0.10 = 3, 0.15 = 5, 0.20 = 6, 0.25 = 4, 0.50 = 2))
	name = "coupon - [round(discount_pct_off * 100)]% off [initial(discounted_pack.name)]"

/obj/item/coupon/attack_obj(obj/O, mob/living/user)
	if(!istype(O, /obj/machinery/computer/cargo))
		return ..()

	inserted_console = O
	LAZYADD(inserted_console.loaded_coupons, src)
	inserted_console.say("Coupon for [initial(discounted_pack.name)] applied!")
	forceMove(inserted_console)

/obj/item/coupon/Destroy()
	if(inserted_console)
		LAZYREMOVE(inserted_console.loaded_coupons, src)
	. = ..()
