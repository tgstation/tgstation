/obj/item/stack/spacecash
	name = "space cash"
	desc = "It's worth 1 credit."
	singular_name = "bill"
	icon = 'icons/obj/economy.dmi'
	icon_state = "spacecash"
	amount = 1
	max_amount = 20
	throwforce = 0
	throw_speed = 2
	throw_range = 2
	w_class = 1.0
	burn_state = 0 //Burnable

/obj/item/stack/spacecash/New(loc, amount = 0)
	..()
	name = CURRENCY(amount)
	update_icon()

/obj/item/stack/spacecash/examine(mob/living/user)
	user << "It's worth [amount] [CURRENCY(amount)]."

/obj/item/stack/spacecash/attack_self(mob/living/user)
	var/splitamt = input(user, "How much do you want to split off from the stack?", "Stackin' Cash", amount / 2) as num
	var/obj/item/stack/F = new src.type( user, 1)
	F.copy_evidences(src)
	user.put_in_hands(F)
	add_fingerprint(user)
	F.add_fingerprint(user)
	use(splitamt)

/obj/item/stack/spacecash/update_icon()
	switch(amount)
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
		else
			icon_state = "spacecash1000"
			
/obj/item/stack/spacecash/c10
	icon_state = "spacecash10"
	amount = 10

/obj/item/stack/spacecash/c20
	icon_state = "spacecash20"
	amount = 20

/obj/item/stack/spacecash/c50
	icon_state = "spacecash50"
	amount = 50

/obj/item/stack/spacecash/c100
	icon_state = "spacecash100"
	amount = 100

/obj/item/stack/spacecash/c200
	icon_state = "spacecash200"
	amount = 200

/obj/item/stack/spacecash/c500
	icon_state = "spacecash500"
	amount = 500

/obj/item/stack/spacecash/c1000
	icon_state = "spacecash1000"
	amount = 1000
