//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = 0
	var/bananium = 0 //maximum should be 200000, or 100 sheets of bananium
	action_button_name = "Toggle Shoes"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	if(on)
		if(footstep > 1)//honks when activated
			playsound(src, "sound/items/bikehorn.ogg", 75, 1)
			footstep = 0
		else
			footstep++

		new/obj/item/weapon/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180)), 5) //honk
		bananium -= 100
		if(bananium < 100)
			on = !on
			update_icon()
			usr << "<span class='danger'>You ran out of bananium!</span>"
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user) //retrieves bananium from shoes
	if(bananium > 0)
		var/sheet_amount = round(bananium / 2000)
		if(sheet_amount > 0)
			var/obj/item/stack/sheet/mineral/bananium/M = new/obj/item/stack/sheet/mineral/bananium(get_turf(loc))
			user << "<span class='notice'>You retrieve [sheet_amount] sheets of bananium.</span>"
			if(sheet_amount > 50)
				M.amount = 50
				bananium -= 50 * 2000
				sheet_amount -= 50
				M = new/obj/item/stack/sheet/mineral/bananium(get_turf(loc))
			M.amount = sheet_amount
			bananium -= sheet_amount * 2000
		else
			user << "<span class='notice'>You cannot retrieve any bananium from the prototype shoes.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attackby(obj/item/O, mob/user) //inserts bananium into shoes
	if(istype(O,/obj/item/stack/sheet/mineral/bananium))
		if(bananium <= 200000) //100 sheets worth of bananium max
			var/obj/item/stack/sheet/mineral/bananium/M = O
			var/amount = round(100 - (bananium/2000))
			if(amount > 0)
				if(amount > M.amount)
					amount = M.amount
				bananium += 2000 * amount
				user << "<span class='notice'>You insert [amount] bananium sheets into the prototype shoes.</span>"

				M.use(amount)
				return

		user << "<span class='notice'>You cannot insert more bananium into the prototype shoes.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	user << "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]. There is [bananium] bananium left.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click()
	if(bananium > 0)
		on = !on
		update_icon()
		usr << "You [on ? "activate" : "deactivate"] the prototype shoes."
	else
		usr << "You need bananium to turn the prototype shoes on."

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon()
	if(on)
		icon_state = "clown_prototype_on"
	else
		icon_state = "clown_prototype_off"
	usr.update_inv_shoes()