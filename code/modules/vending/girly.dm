/obj/machinery/vending/girly
	name = "Girly Stuffs"
	desc = "A Girl-thing dispensor, who knew?"
	icon_state = "girly"
	product_slogans = "Forever Kawaii!!"
	products = list(/obj/item/storage/lockbox/girlkey = 1,
					/obj/item/clothing/under/schoolgirl/locked = 2,
					/obj/item/clothing/under/schoolgirl/locked/blue = 2,
					/obj/item/clothing/under/schoolgirl/locked/red = 2,
					/obj/item/clothing/under/schoolgirl/locked/orange = 2,
					/obj/item/clothing/under/schoolgirl/locked/green = 2,
					/obj/item/firing_pin/girl = 5,
					/obj/item/sleepsack = 3)
	refill_canister = /obj/item/vending_refill/girly
	product_ads = "Pretty Princess Power!"
	default_price = 10000
	extra_price = 5000
	payment_department = NO_FREEBIES
	girl_locked = TRUE

/obj/machinery/vending/girly/emag_act(mob/user)
	to_chat(user, "<span class='notice'>You cannot Emag [src].</span>")
	return

/obj/item/vending_refill/girly
	machine_name = "Girly Stuffs"
	icon_state = "refill_girly"