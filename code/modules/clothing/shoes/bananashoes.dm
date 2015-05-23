//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = 0
	var/datum/mineral_container/bananium
	action_button_name = "Toggle Shoes"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/New()
	..()
	bananium = new/datum/mineral_container(loc,/obj/item/stack/sheet/mineral/bananium,200000)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	if(on)
		if(footstep > 1)//honks when activated
			playsound(src, "sound/items/bikehorn.ogg", 75, 1)
			footstep = 0
		else
			footstep++

		new/obj/item/weapon/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180)), 5) //honk
		bananium.use_amount(100)
		if(bananium.amount < 100)
			on = !on
			update_icon()
			usr << "<span class='warning'>You ran out of bananium!</span>"
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	var/sheet_amount = bananium.retrieve_all()
	if(sheet_amount)
		user << "<span class='notice'>You retrieve [sheet_amount] sheets of bananium from the prototype shoes.</span>"
	else
		user << "<span class='notice'>You cannot retrieve any bananium from the prototype shoes.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attackby(obj/item/O, mob/user, params)
	var/sheet_amount = bananium.insert_sheet(O)
	if(sheet_amount > 0)
		user << "<span class='notice'>You insert [sheet_amount] bananium sheets into the prototype shoes.</span>"
		var/obj/item/stack/sheet/S = O
		S.use(sheet_amount)
	else if(sheet_amount < 0)
		user << "<span class='notice'>You can only fit bananium sheets into these shoes!</span>"
	else
		user << "<span class='notice'>You cannot insert more bananium into the prototype shoes.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	user << "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]. There is [bananium.amount] bananium left.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click()
	if(bananium.amount > 0)
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
