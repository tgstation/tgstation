//banana flavored chaos and horror ahead

/obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "mk-honk prototype shoes"
	desc = "Lost prototype of advanced clown tech. Powered by bananium, these shoes leave a trail of chaos in their wake."
	icon_state = "clown_prototype_off"
	actions_types = list(/datum/action/item_action/toggle)
	var/on = FALSE
	var/always_noslip = FALSE

/obj/item/clothing/shoes/clown_shoes/banana_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(MAT_BANANIUM), 200000, TRUE, /obj/item/stack)
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 75)
	if(always_noslip)
		clothing_flags |= NOSLIP

/obj/item/clothing/shoes/clown_shoes/banana_shoes/step_action()
	. = ..()
	GET_COMPONENT(bananium, /datum/component/material_container)
	if(on)
		if(bananium.amount(MAT_BANANIUM) < 100)
			on = !on
			if(!always_noslip)
				clothing_flags &= ~NOSLIP
			update_icon()
			to_chat(loc, "<span class='warning'>You ran out of bananium!</span>")
		else
			new /obj/item/grown/bananapeel/specialpeel(get_step(src,turn(usr.dir, 180))) //honk
			bananium.use_amount_type(100, MAT_BANANIUM)

/obj/item/clothing/shoes/clown_shoes/banana_shoes/attack_self(mob/user)
	GET_COMPONENT(bananium, /datum/component/material_container)
	var/sheet_amount = bananium.retrieve_all()
	if(sheet_amount)
		to_chat(user, "<span class='notice'>You retrieve [sheet_amount] sheets of bananium from the prototype shoes.</span>")
	else
		to_chat(user, "<span class='notice'>You cannot retrieve any bananium from the prototype shoes.</span>")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The shoes are [on ? "enabled" : "disabled"].</span>")

/obj/item/clothing/shoes/clown_shoes/banana_shoes/ui_action_click(mob/user)
	GET_COMPONENT(bananium, /datum/component/material_container)
	if(bananium.amount(MAT_BANANIUM))
		on = !on
		update_icon()
		to_chat(user, "<span class='notice'>You [on ? "activate" : "deactivate"] the prototype shoes.</span>")
		if(!always_noslip)
			if(on)
				clothing_flags |= NOSLIP
			else
				clothing_flags &= ~NOSLIP
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
