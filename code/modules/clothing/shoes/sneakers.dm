/obj/item/clothing/shoes/sneakers
	dying_key = DYE_REGISTRY_SNEAKERS
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/shoes/sneakers/black
	name = "black shoes"
	desc = "A pair of black shoes."
	custom_price = PAYCHECK_CREW

	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT

/obj/item/clothing/shoes/sneakers/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	greyscale_colors = "#814112#ffffff"

/obj/item/clothing/shoes/sneakers/blue
	name = "blue shoes"
	greyscale_colors = "#16a9eb#ffffff"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/sneakers/green
	name = "green shoes"
	greyscale_colors = "#54eb16#ffffff"

/obj/item/clothing/shoes/sneakers/yellow
	name = "yellow shoes"
	greyscale_colors = "#ebe216#ffffff"

/obj/item/clothing/shoes/sneakers/purple
	name = "purple shoes"
	greyscale_colors = "#ad16eb#ffffff"

/obj/item/clothing/shoes/sneakers/red
	name = "red shoes"
	desc = "Stylish red shoes."
	greyscale_colors = "#ff2626#ffffff"

/obj/item/clothing/shoes/sneakers/white
	name = "white shoes"
	greyscale_colors = "#ffffff#ffffff"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/sneakers/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

	greyscale_colors = null
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_config_worn = null
	flags_1 = NONE

/obj/item/clothing/shoes/sneakers/orange
	name = "orange shoes"
	greyscale_colors = "#eb7016#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_orange
	greyscale_config_worn = /datum/greyscale_config/sneakers_orange_worn
	flags_1 = NONE

/obj/item/clothing/shoes/sneakers/orange/attack_self(mob/user)
	if (chained)
		chained = FALSE
		slowdown = SHOES_SLOWDOWN
		new /obj/item/restraints/handcuffs( user.loc )
		icon_state = initial(icon_state)
	return

/obj/item/clothing/shoes/sneakers/orange/attackby(obj/H, loc, params)
	..()
	// Note: not using istype here because we want to ignore all subtypes
	if (H.type == /obj/item/restraints/handcuffs && !chained)
		qdel(H)
		chained = TRUE
		slowdown = 15
		icon_state = "sneakers_chained"
	return

/obj/item/clothing/shoes/sneakers/orange/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/C = user
		if(C.shoes == src && chained == 1)
			to_chat(user, span_warning("You need help taking these off!"))
			return FALSE
	return ..()

/obj/item/clothing/shoes/sneakers/orange/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/c = m
		if(c.shoes == src && chained == 1)
			to_chat(c, span_warning("You need help taking these off!"))
			return
	return ..()

/obj/item/clothing/shoes/sneakers/mime
	name = "mime shoes"
	greyscale_colors = "#ffffff#ffffff"

/obj/item/clothing/shoes/sneakers/marisa
	desc = "A pair of magic black shoes."
	name = "magic shoes"
	worn_icon_state = "marisa"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers_marisa
	greyscale_config_worn = null
	strip_delay = 5
	equip_delay_other = 50
	permeability_coefficient = 0.9
	can_be_tied = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/sneakers/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	greyscale_colors = "#4e4e4e#4e4e4e"
