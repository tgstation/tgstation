// MARK: Tajaran tail
/obj/item/organ/tail/tajaran
	name = "tajaran tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/tajaran
	wag_flags = WAG_ABLE
	dna_block = /datum/dna_block/feature/accessory/tajaran_tail
	var/datum/bodypart_overlay/mutant/tajaran_tail_markings/tail_markings_overlay

/obj/item/organ/tail/tajaran/on_mob_insert(mob/living/carbon/owner)
	. = ..()
	add_verb(owner, /mob/living/carbon/human/proc/emote_wag)

/obj/item/organ/tail/tajaran/on_mob_remove(mob/living/carbon/owner)
	. = ..()
	remove_verb(owner, /mob/living/carbon/human/proc/emote_wag)

/datum/bodypart_overlay/mutant/tail/tajaran
	feature_key = FEATURE_TAJARAN_TAIL

/datum/bodypart_overlay/mutant/tail/tajaran/get_global_feature_list()
	return SSaccessories.feature_list[FEATURE_TAJARAN_TAIL]

// MARK: Tajaran tail markings
/datum/bodypart_overlay/mutant/tajaran_tail_markings
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	feature_key = FEATURE_TAJARAN_TAIL_MARKINGS
	var/wagging = FALSE
	var/tail_markings_key = NONE
	var/tajaran_tail_markings_color = "#FFFFFF"

/datum/bodypart_overlay/mutant/tajaran_tail_markings/get_global_feature_list()
	return SSaccessories.feature_list[FEATURE_TAJARAN_TAIL_MARKINGS]

/datum/bodypart_overlay/mutant/tajaran_tail_markings/get_base_icon_state()
	return (!isnull(tail_markings_key) ? "[tail_markings_key]_" : "") + (wagging ? "wagging_" : "") + sprite_datum.icon_state

/datum/bodypart_overlay/mutant/tajaran_tail_markings/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	. = ..()
	var/mob/living/carbon/human/human = bodypart_owner.owner
	if(!istype(human))
		return TRUE

	if(human.wear_suit && (human.wear_suit?.flags_inv & HIDEJUMPSUIT))
		return FALSE

/datum/bodypart_overlay/mutant/tajaran_tail_markings/override_color(rgb_value)
	return tajaran_tail_markings_color

/obj/item/organ/tail/tajaran/on_bodypart_insert(obj/item/bodypart/bodypart)
	var/data = ..()
	insert_tail_markings(bodypart)
	return data

/obj/item/organ/tail/tajaran/on_bodypart_remove(obj/item/bodypart/bodypart)
	remove_tail_markings(bodypart)
	return ..()

/obj/item/organ/tail/tajaran/proc/insert_tail_markings(obj/item/bodypart/bodypart)
	if(tail_markings_overlay)
		return

	var/datum/sprite_accessory/tails/tajaran/tail_sprite_datum = bodypart_overlay.sprite_datum

	if(!istype(tail_sprite_datum))
		return

	var/tail_markings_key = tail_sprite_datum.icon_state
	if(!tail_markings_key)
		return

	var/mob/living/carbon/human/owner = bodypart.owner
	var/feature_name = bodypart.owner.dna.features[FEATURE_TAJARAN_TAIL_MARKINGS]
	if (feature_name && istype(owner, /mob/living/carbon/human))
		tail_markings_overlay = new
		tail_markings_overlay.tail_markings_key = tail_markings_key
		tail_markings_overlay.color_source = ORGAN_COLOR_OVERRIDE
		tail_markings_overlay.tajaran_tail_markings_color = owner.dna.features[FEATURE_TAJARAN_TAIL_MARKINGS_COLOR]
		tail_markings_overlay.set_appearance_from_name(feature_name)
		bodypart.add_bodypart_overlay(tail_markings_overlay)

/obj/item/organ/tail/tajaran/proc/remove_tail_markings(obj/item/bodypart/bodypart)
	if(!tail_markings_overlay)
		return
	bodypart.remove_bodypart_overlay(tail_markings_overlay)
	QDEL_NULL(tail_markings_overlay)

/obj/item/organ/tail/tajaran/start_wag(mob/living/carbon/organ_owner, stop_after = INFINITY)
	if(tail_markings_overlay)
		tail_markings_overlay.wagging = TRUE
	return ..()

/obj/item/organ/tail/tajaran/stop_wag(mob/living/carbon/organ_owner)
	if(tail_markings_overlay)
		tail_markings_overlay.wagging = FALSE
	return ..()
