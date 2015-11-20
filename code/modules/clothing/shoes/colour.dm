/obj/item/clothing/shoes/sneakers

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	icon_state = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	icon_state = "blue"

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	icon_state = "green"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	icon_state = "yellow"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	icon_state = "purple"

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	icon_state = "brown"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	icon_state = "orange"

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (src.chained)
		src.chained = null
		src.slowdown = SHOES_SLOWDOWN
		new /obj/item/weapon/restraints/handcuffs( user.loc )
		src.icon_state = "orange"
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	if ((istype(H, /obj/item/weapon/restraints/handcuffs) && !( src.chained )))
		//H = null
		if (src.icon_state != "orange") return
		if(istype(H, /obj/item/weapon/restraints/handcuffs/cable))
			return 0
		qdel(H)
		src.chained = 1
		src.slowdown = 15
		src.icon_state = "orange1"
	return

/obj/item/clothing/shoes/sneakers/orange/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/C = user
		if(C.shoes == src && src.chained == 1)
			user << "<span class='warning'>You need help taking these off!</span>"
			return
	..()
