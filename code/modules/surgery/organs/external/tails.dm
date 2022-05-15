#define WAG_ABLE (1<<0)
#define WAG_WAGGING (1<<1)

///Tail parent, it doesn't do very much.
/obj/item/organ/external/tail
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_TAIL
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	organ_flags = ORGAN_EDIBLE
	feature_key = "tail"
	render_key = "tail"
	dna_block = DNA_TAIL_BLOCK
	///Does this tail have a wagging sprite, and is it currently wagging?
	var/wag_flags = NONE


/obj/item/organ/external/tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
	return TRUE

/obj/item/organ/external/tail/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(.)
		RegisterSignal(reciever, COMSIG_ORGAN_WAG_TAIL, .proc/wag)

/obj/item/organ/external/tail/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_ORGAN_WAG_TAIL)

/obj/item/organ/external/tail/generate_icon_cache()
	. = list()
	. += "[sprite_datum.icon_state]"
	. += "[feature_key]"
	if((wag_flags & WAG_ABLE) && (wag_flags & WAG_WAGGING))
		. += "wagging"
	return jointext(., "_")

/obj/item/organ/external/tail/proc/wag()
	if(!(wag_flags & WAG_ABLE))
		return

	if(!(wag_flags & WAG_WAGGING))
		render_key = "wagging[render_key]"
		wag_flags |= WAG_WAGGING
	else
		render_key = initial(render_key)
		wag_flags &= ~WAG_WAGGING

	owner.update_body_parts()

/obj/item/organ/external/tail/cat
	preference = "feature_human_tail"
	color_source = ORGAN_COLOR_HAIR
	wag_flags = WAG_ABLE


/obj/item/organ/external/tail/cat/get_global_feature_list()
	return GLOB.tails_list_human

