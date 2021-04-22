
//Only sort gloves into here if they come with some special ability above just stat changes.

/obj/item/clothing/gloves/cargo_gauntlet
	name = "H.A.U.L. gauntlets"
	desc = "These clunky gauntlets allow you to drag things with more confidence on them not getting nabbed from you."
	icon_state = "haul_gauntlet"
	inhand_icon_state = "bgloves"
	transfer_prints = FALSE
	equip_delay_self = 4 SECONDS
	equip_delay_other = 6 SECONDS
	clothing_traits = list(TRAIT_CHUNKYFINGERS, TRAIT_SAFERCARRY)
	undyeable = TRUE
