#define COUPON_OMEN "omen"

/obj/item/coupon
	name = "coupon"
	desc = "It doesn't matter if you didn't want it before, what matters now is that you've got a coupon for it!"
	icon_state = "data_1"
	icon = 'icons/obj/card.dmi'
	item_flags = NOBLUDGEON
	atom_size = WEIGHT_CLASS_TINY
	var/datum/supply_pack/discounted_pack
	var/discount_pct_off = 0.05
	var/obj/machinery/computer/cargo/inserted_console

/// Choose what our prize is :D
/obj/item/coupon/proc/generate(rig_omen=FALSE)
	discounted_pack = pick(subtypesof(/datum/supply_pack/goody))
	var/list/chances = list("0.10" = 4, "0.15" = 8, "0.20" = 10, "0.25" = 8, "0.50" = 4, COUPON_OMEN = 1)
	if(rig_omen)
		discount_pct_off = COUPON_OMEN
	else
		discount_pct_off = pick_weight(chances)
	if(discount_pct_off == COUPON_OMEN)
		name = "coupon - fuck you"
		desc = "The small text reads, 'You will be slaughtered'... That doesn't sound right, does it?"
		if(ismob(loc))
			var/mob/M = loc
			to_chat(M, span_warning("The coupon reads '<b>fuck you</b>' in large, bold text... is- is that a prize, or?"))
			M.AddComponent(/datum/component/omen, TRUE, src)
	else
		discount_pct_off = text2num(discount_pct_off)
		name = "coupon - [round(discount_pct_off * 100)]% off [initial(discounted_pack.name)]"

/obj/item/coupon/attack_atom(obj/O, mob/living/user, params)
	if(!istype(O, /obj/machinery/computer/cargo))
		return ..()
	if(discount_pct_off == COUPON_OMEN)
		to_chat(user, span_warning("\The [O] validates the coupon as authentic, but refuses to accept it..."))
		O.say("Coupon fulfillment already in progress...")
		return

	inserted_console = O
	LAZYADD(inserted_console.loaded_coupons, src)
	inserted_console.say("Coupon for [initial(discounted_pack.name)] applied!")
	forceMove(inserted_console)

/obj/item/coupon/Destroy()
	if(inserted_console)
		LAZYREMOVE(inserted_console.loaded_coupons, src)
		inserted_console = null
	. = ..()

#undef COUPON_OMEN
