/obj/item/stack/spacecash  //Don't use base space cash stacks. Any other space cash stack can merge with them, and could cause potential money duping exploits.
	name = "space cash"
	singular_name = "bill"
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash"
	amount = 1
	max_amount = INFINITY
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/value = 0
	grind_results = list(/datum/reagent/cellulose = 10)

/obj/item/stack/spacecash/Initialize()
	. = ..()
	update_desc()

/obj/item/stack/spacecash/proc/update_desc()
	var/total_worth = get_item_credit_value()
	desc = "It's worth [total_worth] credit[( total_worth > 1 ) ? "s" : ""] in total."

/obj/item/stack/spacecash/get_item_credit_value()
	return (amount*value)

/obj/item/stack/spacecash/merge(obj/item/stack/S)
	. = ..()
	update_desc()

/obj/item/stack/spacecash/use(used, transfer = FALSE)
	. = ..()
	update_desc()

/obj/item/stack/spacecash/update_icon_state()
	var/cash_value = get_item_credit_value()
	switch(cash_value)
		if(1 to 9)
			icon_state = "spacecash"
		if(10 to 19)
			icon_state = "spacecash10"
		if(20 to 49)
			icon_state = "spacecash20"
		if(50 to 99)
			icon_state = "spacecash50"
		if(100 to 199)
			icon_state = "spacecash100"
		if(200 to 499)
			icon_state = "spacecash200"
		if(500 to 999)
			icon_state = "spacecash500"
		if(1000 to 9999)
			icon_state = "spacecash1000"
		if(10000 to INFINITY)
			icon_state = "spacecash10000"

/obj/item/stack/spacecash/c1
	icon_state = "spacecash"
	singular_name = "one credit bill"
	value = 1

/obj/item/stack/spacecash/c10
	icon_state = "spacecash10"
	singular_name = "ten credit bill"
	value = 10

/obj/item/stack/spacecash/c20
	icon_state = "spacecash20"
	singular_name = "twenty credit bill"
	value = 20

/obj/item/stack/spacecash/c50
	icon_state = "spacecash50"
	singular_name = "fifty credit bill"
	value = 50

/obj/item/stack/spacecash/c100
	icon_state = "spacecash100"
	singular_name = "one hundred credit bill"
	value = 100

/obj/item/stack/spacecash/c200
	icon_state = "spacecash200"
	singular_name = "two hundred credit bill"
	value = 200

/obj/item/stack/spacecash/c500
	icon_state = "spacecash500"
	singular_name = "five hundred credit bill"
	value = 500

/obj/item/stack/spacecash/c1000
	icon_state = "spacecash1000"
	singular_name = "one thousand credit bill"
	value = 1000

/obj/item/stack/spacecash/c10000
	icon_state = "spacecash10000"
	singular_name = "ten thousand credit bill"
	value = 10000
