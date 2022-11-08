/obj/item/clothing/gloves/color
	dying_key = DYE_REGISTRY_GLOVES
	greyscale_colors = null

/obj/item/clothing/gloves/color/yellow
	desc = "These gloves provide protection against electric shock. The thickness of the rubber makes your fingers seem bigger."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	siemens_coefficient = 0
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 0)
	resistance_flags = NONE
	custom_price = PAYCHECK_CREW * 10
	custom_premium_price = PAYCHECK_COMMAND * 6
	cut_type = /obj/item/clothing/gloves/cut
	clothing_traits = list(TRAIT_CHUNKYFINGERS)

/obj/item/clothing/gloves/color/yellow/heavy
	name = "ceramic-lined insulated gloves"
	desc = "A cheaper make of the standard insulated gloves, using internal ceramic lining to make up for the sub-par rubber material. The extra weight makes them more bulky to use."
	slowdown = 1
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/toy/sprayoncan
	name = "spray-on insulation applicator"
	desc = "What is the number one problem facing our station today?"
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "sprayoncan"

/obj/item/toy/sprayoncan/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && proximity)
		var/mob/living/carbon/C = target
		var/mob/living/carbon/U = user
		var/success = C.equip_to_slot_if_possible(new /obj/item/clothing/gloves/color/yellow/sprayon, ITEM_SLOT_GLOVES, qdel_on_fail = TRUE, disable_warning = TRUE)
		if(success)
			if(C == user)
				C.visible_message(span_notice("[U] sprays their hands with glittery rubber!"))
			else
				C.visible_message(span_warning("[U] sprays glittery rubber on the hands of [C]!"))
		else
			C.visible_message(span_warning("The rubber fails to stick to [C]'s hands!"))

/obj/item/clothing/gloves/color/yellow/sprayon
	desc = "How're you gonna get 'em off, nerd?"
	name = "spray-on insulated gloves"
	icon_state = "sprayon"
	inhand_icon_state = null
	item_flags = DROPDEL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = ACID_PROOF
	var/charges_remaining = 10

/obj/item/clothing/gloves/color/yellow/sprayon/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/gloves/color/yellow/sprayon/equipped(mob/user, slot)
	. = ..()
	RegisterSignal(user, COMSIG_LIVING_SHOCK_PREVENTED, .proc/use_charge)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, .proc/use_charge)

/obj/item/clothing/gloves/color/yellow/sprayon/proc/use_charge()
	SIGNAL_HANDLER

	charges_remaining--
	if(charges_remaining <= 0)
		var/turf/location = get_turf(src)
		location.visible_message(span_warning("[src] crumble[p_s()] away into nothing.")) // just like my dreams after working with .dm
		qdel(src)

/obj/item/clothing/gloves/color/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap knockoffs of the coveted ones - no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	siemens_coefficient = 1 //Set to a default of 1, gets overridden in Initialize()
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 25, FIRE = 0, ACID = 0)
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/cut

/obj/item/clothing/gloves/color/fyellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/color/fyellow/old
	desc = "Old and worn out insulated gloves, hopefully they still work."
	name = "worn out insulated gloves"

/obj/item/clothing/gloves/color/fyellow/old/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0,0,0.5,0.5,0.5,0.75)

/obj/item/clothing/gloves/cut
	desc = "These gloves would protect the wearer from electric shock... if the fingers were covered."
	name = "fingerless insulated gloves"
	icon_state = "yellowcut"
	inhand_icon_state = "ygloves"
	greyscale_colors = null
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/cut/heirloom
	desc = "The old gloves your great grandfather stole from Engineering, many moons ago. They've seen some tough times recently."

/obj/item/clothing/gloves/color/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	greyscale_colors = "#2f2e31"
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE
	cut_type = /obj/item/clothing/gloves/fingerless

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	greyscale_colors = "#2f2e31"
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	custom_price = PAYCHECK_CREW * 1.5
	undyeable = TRUE
	clothing_traits = list(TRAIT_FINGERPRINT_PASSTHROUGH)

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	greyscale_colors = "#ff9300"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	greyscale_colors = "#da0000"


/obj/item/clothing/gloves/color/red/insulated
	name = "insulated gloves"
	desc = "These gloves provide protection against electric shock."
	siemens_coefficient = 0
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 50, FIRE = 0, ACID = 0)
	resistance_flags = NONE

/obj/item/clothing/gloves/color/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	inhand_icon_state = "rainbow_gloves"
	greyscale_colors = null

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	greyscale_colors = "#00b7ef"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	greyscale_colors = "#cc33ff"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	greyscale_colors = "#a8e61d"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	greyscale_colors = "#999999"

// Grey gloves intended to be paired with winter coats (specifically EVA winter coats)
/obj/item/clothing/gloves/color/grey/protects_cold
	name = "\proper Endotherm gloves"
	desc = "A pair of thick grey gloves, lined to protect the wearer from freezing cold."
	w_class = WEIGHT_CLASS_NORMAL
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	resistance_flags = NONE
	clothing_flags = THICKMATERIAL

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	greyscale_colors = "#c09f72"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	greyscale_colors = "#83613d"

/obj/item/clothing/gloves/color/captain
	desc = "Regal blue gloves, with a nice gold trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	inhand_icon_state = null
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 90, FIRE = 70, ACID = 50)
	resistance_flags = NONE

/obj/item/clothing/gloves/color/chief_engineer
	desc = "These gloves provide excellent heat and electric insulation. They are so thin you can barely feel them."
	name = "advanced insulated gloves"
	icon_state = "ce_insuls"
	inhand_icon_state = null
	greyscale_colors = null
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex
	name = "latex gloves"
	desc = "Cheap sterile gloves made from latex. Provides quicker carrying from a good grip."
	icon_state = "latex"
	inhand_icon_state = "latex_gloves"
	greyscale_colors = null
	siemens_coefficient = 0.3
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 0, ACID = 0)
	clothing_traits = list(TRAIT_QUICK_CARRY, TRAIT_FINGERPRINT_PASSTHROUGH)
	resistance_flags = NONE

/obj/item/clothing/gloves/color/latex/nitrile
	name = "nitrile gloves"
	desc = "Pricy sterile gloves that are thicker than latex. Excellent grip ensures very fast carrying of patients along with the faster use time of various chemical related items."
	icon_state = "nitrile"
	inhand_icon_state = "greyscale_gloves"
	greyscale_colors = "#99eeff"
	clothing_traits = list(TRAIT_QUICKER_CARRY, TRAIT_FASTMED)

/obj/item/clothing/gloves/color/latex/engineering
	name = "tinker's gloves"
	desc = "Overdesigned engineering gloves that have automated construction subrutines dialed in, allowing for faster construction while worn."
	icon = 'icons/obj/clothing/gloves.dmi'
	inhand_icon_state = "greyscale_gloves"
	icon_state = "clockwork_gauntlets"
	greyscale_colors = "#db6f05"
	siemens_coefficient = 0.8
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 70, FIRE = 0, ACID = 0)
	clothing_traits = list(TRAIT_QUICK_BUILD)
	custom_materials = list(/datum/material/iron=2000, /datum/material/silver=1500, /datum/material/gold = 1000)

/obj/item/clothing/gloves/color/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	greyscale_colors = "#ffffff"
	custom_price = PAYCHECK_CREW

/obj/item/clothing/gloves/kim
	name = "aerostatic gloves"
	desc = "Breathable red gloves for expert handling of a pen and notebook."
	icon_state = "aerostatic_gloves"
	greyscale_colors = "#a63814"

/obj/item/clothing/gloves/maid
	name = "maid arm covers"
	desc = "Cylindrical looking tubes that go over your arm, weird."
	icon_state = "maid_arms"
	inhand_icon_state = null
	greyscale_colors = null
