/obj/item/clothing/shoes/sneakers

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	icon_state = "black"
	mob_overlay_state = "black"
	desc = "A pair of black shoes."
	custom_price = 20

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"
	mob_overlay_state = "brown"

/obj/item/clothing/shoes/sneakers/brown/captain
	mob_overlay_state = "captain"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/hop
	mob_overlay_state = "hop"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/ce
	mob_overlay_state = "chief"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/rd
	mob_overlay_state = "director"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/cmo
	mob_overlay_state = "medical"	//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/brown/qm
	mob_overlay_state = "cargo"		//Exists for washing machines. Is not different from brown shoes in any way.

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	icon_state = "blue"
	mob_overlay_state = "blue"

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	icon_state = "green"
	mob_overlay_state = "green"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	icon_state = "yellow"
	mob_overlay_state = "yellow"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	icon_state = "purple"
	mob_overlay_state = "purple"

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	icon_state = "brown"
	mob_overlay_state = "brown"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"
	mob_overlay_state = "red"

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01
	mob_overlay_state = "white"

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"
	mob_overlay_state = "rainbow"

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	icon_state = "orange"
	mob_overlay_state = "orange"

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	// Note: not using istype here because we want to ignore all subtypes
	if (H.type == /obj/item/restraints/handcuffs && !chained)
		qdel(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/shoes/sneakers/orange/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/C = user
		if(C.shoes == src && chained == 1)
			to_chat(user, "<span class='warning'>You need help taking these off!</span>")
			return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/c = m
		if(c.shoes == src && chained == 1)
			to_chat(c, "<span class='warning'>You need help taking these off!</span>")
			return
	return ..()

