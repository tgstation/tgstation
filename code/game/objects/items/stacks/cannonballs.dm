/obj/item/stack/cannonball
	name = "cannonballs"
	desc = "A stack of heavy plasteel cannonballs. Gunnery for the space age!"
	icon_state = "cannonballs"
	max_amount = 14
	singular_name = "cannonball"
	merge_type = /obj/item/stack/cannonball
	throwforce = 10
	flags_1 = CONDUCT_1
	custom_materials = list(/datum/material/alloy/plasteel=MINERAL_MATERIAL_AMOUNT)
	resistance_flags = FIRE_PROOF
	throw_speed = 5
	throw_range = 3
	///the type of projectile this type of cannonball item turns into.
	var/obj/projectile/projectile_type = /obj/projectile/bullet/cannonball

/obj/item/stack/cannonball/update_icon_state()
	if(amount == 1)
		icon_state = "initial(icon_state)"
	else
		icon_state = "cannonballs_[min(amount, 14)]"


/obj/item/stack/cannonball/fourteen
	amount = 14

/obj/item/stack/cannonball/shellball
	name = "explosive shellball"
	desc = "An explosive anti-materiel and counter-battery projectile cannonball. Makes great work out of any wall, for easy entrances."
	icon_state = "cannonballs"
	color = "#FF0000"
	merge_type = /obj/item/stack/cannonball/shellball
	projectile_type = /obj/projectile/bullet/cannonball/explosive

/obj/item/stack/cannonball/shellball/fourteen
	amount = 14
