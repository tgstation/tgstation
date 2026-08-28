/obj/item/skillchip/self_surgery
	name = "4U70-P3R4710N skillchip"
	desc = "A skillchip containing old Nanotrasen medical training protocols, which one could use to perform surgical operations on themselves. \
		This one doesn't look like it's in the best condition - bit rot has probably rendered it somewhat risky to use."
	auto_traits = list(TRAIT_SELF_SURGERY)
	skill_name = "Self Surgery"
	skill_description = "Allows you to perform surgery on yourself."
	skill_icon = FA_ICON_USER_DOCTOR
	activate_message = span_notice("You realize there's nothing stopping you from performing surgery on yourself.")
	deactivate_message = span_notice("You suddenly feel like you should never perform surgery on yourself.")

/obj/item/skillchip/self_surgery/Initialize(mapload, is_removable)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)
