/obj/item/stack/cannonball
	name = "cannonballs"
	desc = "A stack of heavy plasteel cannonballs. Gunnery for the space age!"
	icon_state = "cannonballs"
	base_icon_state = "cannonballs"
	max_amount = 14
	singular_name = "cannonball"
	merge_type = /obj/item/stack/cannonball
	throwforce = 10
	flags_1 = CONDUCT_1
	custom_materials = list(/datum/material/alloy/plasteel=SHEET_MATERIAL_AMOUNT)
	resistance_flags = FIRE_PROOF
	throw_speed = 5
	throw_range = 3
	///the type of projectile this type of cannonball item turns into.
	var/obj/projectile/projectile_type = /obj/projectile/bullet/cannonball

/obj/item/stack/cannonball/update_icon_state()
	. = ..()
	icon_state = (amount == 1) ? "[base_icon_state]" : "[base_icon_state]_[min(amount, 14)]"

/obj/item/stack/cannonball/fourteen
	amount = 14

/obj/item/stack/cannonball/shellball
	name = "explosive shellballs"
	singular_name = "explosive shellball"
	desc = "An explosive anti-materiel and counter-battery projectile cannonball. Makes great work out of any wall, for easy entrances."
	color = "#FF0000"
	merge_type = /obj/item/stack/cannonball/shellball
	projectile_type = /obj/projectile/bullet/cannonball/explosive

/obj/item/stack/cannonball/shellball/seven
	amount = 7

/obj/item/stack/cannonball/shellball/fourteen
	amount = 14

/obj/item/stack/cannonball/emp
	name = "malfunction shots"
	singular_name = "malfunction shot"
	icon_state = "emp_cannonballs"
	base_icon_state = "emp_cannonballs"
	desc = "A shot filled with two chambers that combine on impact, creating a chemical EMP. What does any of that mean? Who knows. Modern piracy really lost its soul with these newfangled things."
	max_amount = 4
	merge_type = /obj/item/stack/cannonball/emp
	projectile_type = /obj/projectile/bullet/cannonball/emp

/obj/item/stack/cannonball/the_big_one
	name = "\"The Biggest Ones\""
	singular_name = "\"The Biggest One\""
	desc = "An insane amount of explosives jammed into a massive cannonball. The last cannonball you'll ever fire in a fight, mostly because there'll be nothing left to shoot at afterwards."
	max_amount = 5
	icon_state = "biggest_cannonballs"
	base_icon_state = "biggest_cannonballs"
	merge_type = /obj/item/stack/cannonball/the_big_one
	projectile_type = /obj/projectile/bullet/cannonball/biggest_one

/obj/item/stack/cannonball/the_big_one/five
	amount = 5

/obj/item/stack/cannonball/trashball
	name = "trashballs"
	singular_name = "trashball"
	desc = "A clump of tightly packed garbage. It'll work as a cannonball, but it may be unhealthy to actually put this in a real cannon."
	max_amount = 4
	icon_state = "trashballs"
	base_icon_state = "trashballs"
	merge_type = /obj/item/stack/cannonball/trashball
	projectile_type = /obj/projectile/bullet/cannonball/trashball

/obj/item/stack/cannonball/trashball/four
	amount = 4
