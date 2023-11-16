/datum/reagent/consumable/kvass
	name = "Kvass"
	description = "Kvaaaaaaass."
	color = "#351300"
	taste_description = "mmmmm kvass"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED

/datum/glass_style/drinking_glass/kvass
	required_drink_type = /datum/reagent/consumable/kvass
	name = "glass of Kvass"
	desc = "A glass of Kvaaaaaaass."
	icon = 'massmeta/icons/drinks/drinks.dmi'
	icon_state = "kvass"

/datum/reagent/consumable/kvass/on_mob_life(mob/living/carbon/affected_mob, delta_time, times_fired)
	affected_mob.adjustToxLoss(-0.5, FALSE, required_biotype = affected_biotype)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.5 * REM * delta_time, required_organ_flag = ORGAN_ORGANIC)
	for(var/datum/reagent/toxin/R in affected_mob.reagents.reagent_list)
		affected_mob.reagents.remove_reagent(R.type, 2.5 * REM * delta_time)
	..()

/datum/export/large/reagent_dispenser/kvass
	unit_name = "kvasstank"
	export_types = list(/obj/structure/reagent_dispensers/kvasstank)

/datum/supply_pack/materials/kvasstank
	name = "Kvass Tank Crate"
	desc = "Contains a yellow barrel full of kvass"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/structure/reagent_dispensers/kvasstank)
	crate_name = "kvass tank crate"
	crate_type = /obj/structure/closet/crate/large

/obj/structure/reagent_dispensers/kvasstank
	name = "kvass tank"
	desc = "Yellow barrel full of divine liquid."
	icon = 'massmeta/icons/drinks/chemical_tanks.dmi'
	icon_state = "kvass"
	reagent_id = /datum/reagent/consumable/kvass
	openable = TRUE
