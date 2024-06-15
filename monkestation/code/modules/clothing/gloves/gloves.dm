/obj/item/clothing/gloves/combat/maid
	name = "combat maid sleeves"
	desc = "These 'tactical' gloves and sleeves are fireproof and electrically insulated. Warm to boot."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "syndimaid_arms"

/obj/item/clothing/gloves/color/plasmaman
	icon = 'monkestation/icons/obj/clothing/plasmaman_gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/plasmaman_gloves.dmi'

/obj/item/clothing/gloves/latex/surgical
	name = "Black Latex gloves"
	desc = "Pricy sterile gloves that are thinner than latex. The lining allows for the person to operate \
	        quicker along with the faster use time of various chemical related items"
	icon = 'monkestation/icons/obj/clothing/surgeonlatex.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "surgeonlatex"
	armor_type = /datum/armor/surgeon
	clothing_traits = list(TRAIT_PERFECT_SURGEON, TRAIT_FASTMED)
	custom_premium_price = PAYCHECK_CREW * 6

/datum/armor/surgeon
    bio = 100
