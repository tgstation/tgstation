/obj/item/reagent_containers/pill/patch
	name = "patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/medical/chemical.dmi'
	icon_state = "bandaid_blank"
	inhand_icon_state = null
	possible_transfer_amounts = list()
	volume = 40
	apply_type = PATCH
	apply_method = "apply"
	self_delay = 30 // three seconds
	dissolvable = FALSE

/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return FALSE
	if(!ishuman(eater))
		return TRUE
	var/mob/living/carbon/human/human_eater = eater
	var/obj/item/bodypart/affecting = human_eater.get_bodypart(check_zone(user.zone_selected))
	if(!affecting)
		to_chat(user, span_warning("The limb is missing!"))
		return FALSE

	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, span_notice("Medicine won't work on an inorganic limb!"))
		return FALSE

	return TRUE // Masks were stopping people from "eating" patches. Thanks, inheritance.

/obj/item/reagent_containers/pill/patch/libital
	name = "libital patch (brute)"
	desc = "A pain reliever. Does minor liver damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/libital = 2, /datum/reagent/medicine/granibitaluri = 8) //10 iterations
	icon_state = "bandaid_brute"

/obj/item/reagent_containers/pill/patch/aiuri
	name = "aiuri patch (burn)"
	desc = "Helps with burn injuries. Does minor eye damage. Diluted with Granibitaluri."
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 2, /datum/reagent/medicine/granibitaluri = 8)
	icon_state = "bandaid_burn"

/obj/item/reagent_containers/pill/patch/synthflesh
	name = "synthflesh patch"
	desc = "Helps with brute and burn injuries. Slightly toxic."
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 20)
	icon_state = "bandaid_both"

/obj/item/reagent_containers/pill/patch/ondansetron
	name = "ondansetron patch"
	desc = "Alleviates nausea. May cause drowsiness."
	list_reagents = list(/datum/reagent/medicine/ondansetron = 10)
	icon_state = "bandaid_toxin"

// Patch styles for chem master

/obj/item/reagent_containers/pill/patch/style
	icon_state = "bandaid_blank"
/obj/item/reagent_containers/pill/patch/style/brute
	icon_state = "bandaid_brute_2"
/obj/item/reagent_containers/pill/patch/style/burn
	icon_state = "bandaid_burn_2"
/obj/item/reagent_containers/pill/patch/style/bruteburn
	icon_state = "bandaid_both"
/obj/item/reagent_containers/pill/patch/style/toxin
	icon_state = "bandaid_toxin_2"
/obj/item/reagent_containers/pill/patch/style/oxygen
	icon_state = "bandaid_suffocation_2"
/obj/item/reagent_containers/pill/patch/style/omni
	icon_state = "bandaid_mix"
/obj/item/reagent_containers/pill/patch/style/bruteplus
	icon_state = "bandaid_brute"
/obj/item/reagent_containers/pill/patch/style/burnplus
	icon_state = "bandaid_burn"
/obj/item/reagent_containers/pill/patch/style/toxinplus
	icon_state = "bandaid_toxin"
/obj/item/reagent_containers/pill/patch/style/oxygenplus
	icon_state = "bandaid_suffocation"
/obj/item/reagent_containers/pill/patch/style/monkey
	icon_state = "bandaid_monke"
/obj/item/reagent_containers/pill/patch/style/clown
	icon_state = "bandaid_clown"
/obj/item/reagent_containers/pill/patch/style/one
	icon_state = "bandaid_1"
/obj/item/reagent_containers/pill/patch/style/two
	icon_state = "bandaid_2"
/obj/item/reagent_containers/pill/patch/style/three
	icon_state = "bandaid_3"
/obj/item/reagent_containers/pill/patch/style/four
	icon_state = "bandaid_4"
/obj/item/reagent_containers/pill/patch/style/exclamation
	icon_state = "bandaid_exclaimationpoint"
/obj/item/reagent_containers/pill/patch/style/question
	icon_state = "bandaid_questionmark"
/obj/item/reagent_containers/pill/patch/style/colonthree
	icon_state = "bandaid_colonthree"
