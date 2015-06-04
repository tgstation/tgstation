//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = 0
	var/bananium = 0
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
			usr << "<span class='warning'>You ran out of bananium!</span>"
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	if(bananium > 0)
		var/sheet_amount = round(bananium / 2000)
		if(sheet_amount > 0)
			var/obj/item/stack/sheet/mineral/bananium/M = new/obj/item/stack/sheet/mineral/bananium(get_turf(loc))
			M.amount = sheet_amount
			bananium -= sheet_amount * 2000
			user << "<span class='notice'>You retrieve [sheet_amount] sheets of bananium.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attackby(obj/item/O, mob/user, params)
	if(istype(O,/obj/item/stack/sheet/mineral/bananium))
		var/obj/item/stack/sheet/mineral/bananium/M = O
		bananium += 2000 * M.amount
		user << "<span class='notice'>You insert [M.amount] bananium sheets into the prototype shoes.</span>"
		M.use(M.amount)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	user << "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]. There is [bananium] bananium left.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click()
	if(bananium > 0)
		on = !on
		update_icon()
		usr << "<span class='notice'>You [on ? "activate" : "deactivate"] the prototype shoes.</span>"
	else
		usr << "<span class='warning'>You need bananium to turn the prototype shoes on!</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon()
	if(on)
		icon_state = "clown_prototype_on"
	else
		icon_state = "clown_prototype_off"
	usr.update_inv_shoes()