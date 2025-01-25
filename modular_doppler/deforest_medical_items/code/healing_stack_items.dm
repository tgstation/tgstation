// Helps recover burn wounds much faster, while not healing much damage directly
/obj/item/stack/medical/ointment/red_sun
	name = "red sun balm"
	singular_name = "red sun balm"
	desc = "A popular brand of ointment for handling anything under the red sun, which tends to be terrible burns. \
		Which red sun may this be referencing? Not even the producers of the balm are sure."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "balm"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "bandage"
	gender = PLURAL
	novariants = TRUE
	amount = 12
	max_amount = 12
	self_delay = 4 SECONDS
	other_delay = 2 SECONDS
	heal_burn = 5
	heal_brute = 5
	flesh_regeneration = 5
	sanitization = 3
	grind_results = list(/datum/reagent/medicine/oxandrolone = 3)
	merge_type = /obj/item/stack/medical/ointment/red_sun
	custom_price = PAYCHECK_LOWER * 1.5

/obj/item/stack/medical/ointment/red_sun/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.reagents.add_reagent(/datum/reagent/medicine/lidocaine, 2)

// Good splints, not too good anything else
/obj/item/stack/medical/gauze/alu_splint
	name = "aluminum splints"
	singular_name = "aluminum splint"
	desc = "A roll of aluminum sheet, made for use as a splint when wrapped around a damaged area. \
		Has a lining for what little comfort it would be able to provide, meaning technically... \
		you could use it as a bandage. It doesn't seem like the greatest idea however."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "subsplint"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	inhand_icon_state = "sampler"
	novariants = TRUE
	max_amount = 3
	amount = 3
	splint_factor = 0.35
	burn_cleanliness_bonus = 0.75
	absorption_rate = 0.075
	absorption_capacity = 4
	merge_type = /obj/item/stack/medical/gauze/alu_splint
	custom_price = PAYCHECK_LOWER * 2

// Gauze that are especially good at treating burns, but are terrible splints
/obj/item/stack/medical/gauze/sterilized
	name = "sealed aseptic gauze"
	singular_name = "sealed aseptic gauze"
	desc = "A small roll of elastic material specially treated to be entirely sterile, and sealed in plastic just to be sure. \
		These make excellent treatment against burn wounds, but due to their small nature are sub-par for serving as \
		bone wound wrapping."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "burndaid"
	inhand_icon_state = null
	novariants = TRUE
	max_amount = 6
	amount = 6
	splint_factor = 1.2
	burn_cleanliness_bonus = 0.1
	merge_type = /obj/item/stack/medical/gauze/sterilized
	custom_price = PAYCHECK_LOWER * 1.5

/obj/item/stack/medical/gauze/sterilized/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	healed_mob.reagents.add_reagent(/datum/reagent/space_cleaner/sterilizine, 5)
	healed_mob.reagents.expose(healed_mob, TOUCH, 1)

// Works great at sealing bleed wounds, but does little to actually heal them
/obj/item/stack/medical/suture/coagulant
	name = "coagulant-F packet"
	singular_name = "coagulant-F packet"
	desc = "A small packet of fabricated coagulant for bleeding. Not as effective as some \
		other methods of coagulating wounds, but is more effective than plain sutures. \
		The downsides? It repairs less of the actual damage that's there."
	icon = 'modular_doppler/deforest_medical_items/icons/stack_items.dmi'
	icon_state = "clotter_slow"
	inhand_icon_state = null
	novariants = TRUE
	amount = 12
	max_amount = 12
	repeating = FALSE
	heal_brute = 0
	stop_bleeding = 2
	merge_type = /obj/item/stack/medical/suture/coagulant
	custom_price = PAYCHECK_LOWER * 1.5
