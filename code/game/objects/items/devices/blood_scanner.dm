/obj/item/blood_scanner
	name = "hemoanalytic scanner"
	icon = 'icons/obj/devices/scanner.dmi'
	icon_state = "bloodscanner"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "This Me-Lo Tech branded medical device"
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2, /datum/material/glass=SMALL_MATERIAL_AMOUNT*2)

/obj/item/blood_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!istype(interacting_with, /mob/living/carbon))
		to_chat(user, span_warning("[src] is incompatible."))
		return NONE
	var/mob/living/carbon/poked_guy = interacting_with
	if(!user.can_read(src) || user.is_blind())
		to_chat(user, span_warning("You are unable to read [src]'s screen!"))
		return
	var/obj/item/bodypart/poked_bit = poked_guy.get_bodypart(check_zone(user.zone_selected))
	if(!poked_bit)
		return
	user.visible_message(span_notice("[user] pricks [poked_guy] with [src]."), span_notice("You begin scanning [poked_guy] with [src]."), ignored_mobs = poked_guy)
	to_chat(poked_guy, span_notice("[user] slides the needle of [src] into your [poked_bit] and begins pressing buttons."))
	if(do_after(user, 2 SECONDS, poked_guy))
		var/render_list = list()
		var/oxy_loss = poked_guy.getOxyLoss()
		var/tox_loss = poked_guy.getToxLoss()
		render_list += "<span class='notice ml-1'>Blood Type: [poked_guy?.dna?.blood_type]</span>\n"
		if(oxy_loss > 50)//if they have knockout levels of suffocation damage
			render_list += "<span class='danger ml-1'>Warning: Hypoxic blood oxygen levels.</span>\n"
		if(poked_guy.blood_volume <= BLOOD_VOLUME_SAFE)
			render_list += "<span class='danger ml-1'>Warning: Dangerously low blood flow.</span>\n"
		if(tox_loss > 10)
			render_list += "<span class='danger ml-1'>Warning: Toxic buildup detected in bloodstream.</span>\n"
		if(poked_guy.has_status_effect(/datum/status_effect/eigenstasium))
			render_list += "<span class='danger ml-1'>Warning: Dimensional instability detected. Administer stabilizers.</span>\n"
		if(poked_guy.has_reagent(/datum/reagent/gold/cursed) || poked_guy.has_status_effect(/datum/status_effect/midas_blight))
			render_list += "<span class='danger ml-1'>Warning: Hemo-aurificating hexes present.</span>\n" //can it detect normal things? barely. But ancient greed-cursed magicks? Spot on.
		if(HAS_TRAIT_FROM(poked_guy, TRAIT_NODEATH, /datum/reagent/inverse/penthrite))
			render_list += "<span class='danger ml-1'>Warning: Frankensteinian revivification in progress.</span>\n" //patient is currently an immortal drug-zombie
		if(poked_guy.has_status_effect(/datum/status_effect/high_blood_pressure))
			render_list += "<span class='danger ml-1'>Warning: Dangerously high blood pressure.</span>\n"
		if(HAS_TRAIT(poked_guy, TRAIT_IMMUNODEFICIENCY))
			render_list += "<span class='danger ml-1'>Warning: Low immune cell concentration.</span>\n" //it doe
		to_chat(user, boxed_message(jointext(render_list, "")), type = MESSAGE_TYPE_INFO)

	else
		if(prob(25))
			poked_bit?.force_wound_upwards(/datum/wound/pierce/bleed/moderate/needle_fail, wound_source = "idiot moved with a needle in them")
			user.visible_message(span_warning("[src]'s needle is ripped out, tearing a hole in [poked_guy]'s [poked_bit]!"), span_warning("Damnit! The needle is torn out, making a tiny hole in [poked_guy.p_their()] [poked_bit]"), ignored_mobs = poked_guy)
			to_chat(poked_guy, span_userdanger("<b>OWWW!</b> The needle of [src] is ripped out, tearing a small hole in your [poked_bit]!"))
		return

	return ITEM_INTERACT_SUCCESS

/obj/item/blood_scanner/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	if(!istype(interacting_with, /mob/living/carbon))
		to_chat(user, span_warning("The [src] is incompatible."))
		return NONE
	var/mob/living/carbon/poked_guy = interacting_with
	if(!user.can_read(src) || user.is_blind())
		to_chat(user, span_warning("You are unable to read the [src]'s screen!"))
		return
	var/obj/item/bodypart/poked_bit = poked_guy.get_bodypart(check_zone(user.zone_selected))
	user.visible_message(span_notice("[user] pricks [poked_guy] with [src]."), span_notice("You begin scanning [poked_guy] with [src]."), ignored_mobs = poked_guy)
	to_chat(poked_guy, span_notice("[user] slides the needle of [src] into your [poked_bit] and begins pressing buttons."))
	var/success = do_after(user, 2 SECONDS, poked_guy)
	if(success)
		chemscan(user, poked_guy, reagent_types_to_check = /datum/reagent/medicine)
	else
		if(prob(25))
			poked_bit?.force_wound_upwards(/datum/wound/pierce/bleed/moderate/needle_fail, wound_source = "idiot moved with a needle in them")
			user.visible_message(span_warning("[src]'s needle is ripped out, tearing a hole in [poked_guy]'s [poked_bit]!"), span_warning("Damnit! The needle is torn out, making a tiny hole in [poked_guy.p_their()] [poked_bit]"), ignored_mobs = poked_guy)
			to_chat(poked_guy, span_userdanger("<b>OWWW!</b> The needle of [src] is ripped out, tearing a small hole in your [poked_bit]!"))
		return

	return ITEM_INTERACT_SUCCESS


