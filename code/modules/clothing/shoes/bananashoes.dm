//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = 0
	var/datum/material_container/bananium
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/New()
	..()
	bananium = new/datum/material_container(src,list(MAT_BANANIUM),200000)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	if(on)
		if(footstep > 1)//honks when its on
			playsound(src, "sound/items/bikehorn.ogg", 75, 1)
			footstep = 0
		else
			footstep++

		new/obj/item/weapon/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180))) //honk
		bananium.use_amount_type(100, MAT_BANANIUM)
		if(bananium.amount(MAT_BANANIUM) < 100)
			on = !on
			flags &= ~NOSLIP
			update_icon()
			loc << "<span class='warning'>You ran out of bananium!</span>"
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	var/sheet_amount = bananium.retrieve_all()
	if(sheet_amount)
		user << "<span class='notice'>You retrieve [sheet_amount] sheets of bananium from the prototype shoes.</span>"
	else
		user << "<span class='notice'>You cannot retrieve any bananium from the prototype shoes.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attackby(obj/item/O, mob/user, params)
	if(!bananium.get_item_material_amount(O))
		user << "<span class='notice'>This item has no bananium!</span>"
		return
	if(!user.dropItemToGround(O))
		user << "<span class='notice'>You can't drop [O]!</span>"
		return

	var/bananium_amount = bananium.insert_item(O)
	if(bananium_amount)
		user << "<span class='notice'>You insert [O] into the prototype shoes.</span>"
		qdel(O)
	else
		user << "<span class='notice'>You are unable to insert more bananium!</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	var/ban_amt = bananium.amount(MAT_BANANIUM)
	user << "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]. There is [ban_amt ? ban_amt : "no"] bananium left.</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click(mob/user)
	if(bananium.amount(MAT_BANANIUM))
		on = !on
		update_icon()
		user << "<span class='notice'>You [on ? "activate" : "deactivate"] the prototype shoes.</span>"
		if(on)
			flags |= NOSLIP
		else
			flags &= ~NOSLIP
	else
		user << "<span class='warning'>You need bananium to turn the prototype shoes on!</span>"

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon()
	if(on)
		icon_state = "clown_prototype_on"
	else
		icon_state = "clown_prototype_off"
	usr.update_inv_shoes()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
