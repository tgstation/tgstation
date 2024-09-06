/obj/item/stack/medical/suture/bloody
	name = "hemostatic suture"
	desc = "Bloodclotting agent-infused sterile sutures used to seal up cuts and lacerations and reverse critical bleedings."
	icon = 'modular_doppler/food_replicator/icons/medicine.dmi'
	icon_state = "hemo_suture"
	heal_brute = 7
	stop_bleeding = 1
	grind_results = list(/datum/reagent/medicine/coagulant = 2)
	merge_type = /obj/item/stack/medical/suture/bloody

/obj/item/stack/medical/suture/bloody/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	if(healed_mob.blood_volume <= BLOOD_VOLUME_SAFE)
		healed_mob.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 2)
		healed_mob.adjustOxyLoss(-amount_healed)

/obj/item/stack/medical/mesh/bloody
	name = "hemostatic mesh"
	desc = "A hemostatic mesh used to dress burns and stimulate hemopoiesis. Due to its blood-related purpose, it is worse at sanitizing infections."
	icon = 'modular_doppler/food_replicator/icons/medicine.dmi'
	icon_state = "hemo_mesh"
	heal_burn = 7
	sanitization = 0.5
	flesh_regeneration = 1.75
	stop_bleeding = 0.25
	grind_results = list(/datum/reagent/medicine/coagulant = 2)
	merge_type = /obj/item/stack/medical/mesh/bloody

/obj/item/stack/medical/mesh/bloody/update_icon_state()
	if(is_open)
		return ..()

	icon_state = "hemo_mesh_closed"

/obj/item/stack/medical/mesh/bloody/post_heal_effects(amount_healed, mob/living/carbon/healed_mob, mob/user)
	. = ..()
	if(healed_mob.blood_volume <= BLOOD_VOLUME_SAFE)
		healed_mob.reagents.add_reagent(/datum/reagent/medicine/salglu_solution, 2)
		healed_mob.adjustOxyLoss(-amount_healed)

/obj/item/reagent_containers/hypospray/medipen/glucose
	name = "pressurised glucose medipen"
	desc = "A medipen for keeping yourself going during prolonged EVA shifts, injects a dose of glucose into your bloodstream. Recommended for use in low-pressure environments."
	icon = 'modular_doppler/food_replicator/icons/medicine.dmi'
	icon_state = "glupen"
	inhand_icon_state = "stimpen"
	base_icon_state = "glupen"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/consumable/nutriment/glucose = 15)

/obj/item/reagent_containers/hypospray/medipen/glucose/inject(mob/living/affected_mob, mob/user)
	if(lavaland_equipment_pressure_check(get_turf(user)))
		amount_per_transfer_from_this = initial(amount_per_transfer_from_this)
		return ..()

	if(DOING_INTERACTION(user, DOAFTER_SOURCE_SURVIVALPEN))
		to_chat(user,span_notice("You are too busy to use \the [src]!"))
		return

	to_chat(user,span_notice("You start manually releasing the low-pressure gauge..."))
	if(!do_after(user, 10 SECONDS, affected_mob, interaction_key = DOAFTER_SOURCE_SURVIVALPEN))
		return

	amount_per_transfer_from_this = initial(amount_per_transfer_from_this) * 0.5
	return ..()
