/obj/item/gun/medbeam/stimbeam
	name = "Stimgun"
	icon_state = "stimgun"
	item_state = "stimgun"
	desc = "They're not steroids, they're amplifiers."
	var/chemid = "fervoxazine"
	var/max_chem_amount = 8
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/medbeam/stimbeam/on_beam_tick(var/mob/living/target)
	var/current_chem_amount = target.reagents.get_reagent_amount(chemid)
	var/chem_gain_rate_addition = 0.4 - (0.4 * (current_chem_amount / max_chem_amount))
	to_chat(world, "[current_chem_amount] [chem_gain_rate_addition]")
	target.reagents.add_reagent(chemid, REAGENTS_METABOLISM + chem_gain_rate_addition)
	if(chem_gain_rate_addition > 0)
		new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
	else
		return

/obj/effect/ebeam/stimgun
	name = "stimbeam"
