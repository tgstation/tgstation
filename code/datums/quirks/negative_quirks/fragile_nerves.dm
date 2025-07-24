/datum/quirk/fragile_nerves
	name = "Fragile Nerves"
	desc = "Whenever you lose an arm or leg, the nerves in the stump are permanently damaged. A new limb cannot be attached!"
	icon = FA_ICON_CIRCLE_NODES
	value = -4
	mob_trait = TRAIT_FRAGILE_NERVES
	gain_text = span_danger("Your arms and legs feel irreplaceable.")
	lose_text = span_notice("Your arms and legs feel replaceable.")
	medical_record_text = "Patient's motor nerves are extremely fragile, rendering reattachment of extremities infeasible."
	quirk_flags = QUIRK_HUMAN_ONLY
	hardcore_value = 4
