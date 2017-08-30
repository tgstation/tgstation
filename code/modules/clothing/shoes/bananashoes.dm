//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_BANANIUM), 200000, TRUE)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	if(on)
		if(footstep > 1)//honks when its on
			playsound(src, 'sound/items/bikehorn.ogg', 75, 1)
			footstep = 0
		else
			footstep++

		new/obj/item/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180))) //honk
		GET_COMPONENT(bananium, /datum/component/material_container)
		bananium.use_amount_type(100, MAT_BANANIUM)
		if(bananium.amount(MAT_BANANIUM) < 100)
			on = !on
			flags_1 &= ~NOSLIP_1
			update_icon()
			to_chat(loc, "<span class='warning'>You ran out of bananium!</span>")
	else
		..()

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	GET_COMPONENT(bananium, /datum/component/material_container)
	var/sheet_amount = bananium.retrieve_all()
	if(sheet_amount)
		to_chat(user, "<span class='notice'>You retrieve [sheet_amount] sheets of bananium from the prototype shoes.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot retrieve any bananium from the prototype shoes.</span>")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The shoes are [on ? "enabled" : "disabled"]</span>")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click(mob/user)
	GET_COMPONENT(bananium, /datum/component/material_container)
	if(bananium.amount(MAT_BANANIUM))
		on = !on
		update_icon()
		to_chat(user, "<span class='notice'>You [on ? "activate" : "deactivate"] the prototype shoes.</span>")
		if(on)
			flags_1 |= NOSLIP_1
		else
			flags_1 &= ~NOSLIP_1
	else
		to_chat(user, "<span class='warning'>You need bananium to turn the prototype shoes on!</span>")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/update_icon()
	if(on)
		icon_state = "clown_prototype_on"
	else
		icon_state = "clown_prototype_off"
	usr.update_inv_shoes()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()
