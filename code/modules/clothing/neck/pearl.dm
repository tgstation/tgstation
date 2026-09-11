#define LEFT "left"
#define RIGHT "right"

/*
 * an artifact which allows someone to have both legs and a cerulean tail
 * swapping to the latter only when the wearer is wet, and granting control by (un)equipping
 */
/obj/item/clothing/neck/necklace/pearl
	name = "black pearl necklace"
	desc = "A necklace of black pearls gathered from somewhere within the \"Abyss\" region of planet Moryana, \
		a strange infusion seems to actively swirl within the tiny dark beads."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "beads"
	color = "#121011"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/bone = HALF_SHEET_MATERIAL_AMOUNT / 2, /datum/material/glass = SMALL_MATERIAL_AMOUNT / 2)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// what tail to spawn?
	var/tail_type = /obj/item/organ/tail/fish/cerulean
	/// storage var for the real tail, if we had any. so we can swap without untailing ourselves
	var/obj/item/organ/real_tail
	/// storage var for the ghastly fake tail bound to our necklace. resets only when unequipped
	var/obj/item/organ/ephemeral_tail
	/// storage var for the legs. if we already had a cerulean tail, these legs will be ghastly fake and reset upon unequip. if we werent, our actual legs will be stored here if we had any and not reset
	var/alist/ephemeral_limbs = alist(
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/obj/item/clothing/neck/necklace/pearl/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/obj/item/clothing/neck/necklace/pearl/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/clothing/neck/necklace/pearl/proc/on_equip(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_NECK || !ishuman(equipper))
		return

	RegisterSignal(equipper, SIGNAL_ADDTRAIT(TRAIT_IS_WET), PROC_REF(on_wet))
	RegisterSignal(equipper, SIGNAL_REMOVETRAIT(TRAIT_IS_WET), PROC_REF(on_dry))

	set_up(equipper)
	if(equipper.has_status_effect(/datum/status_effect/fire_handler/wet_stacks))
		on_wet(equipper)
	else
		on_dry(equipper)

/obj/item/clothing/neck/necklace/pearl/proc/on_drop(obj/item/source, mob/dropper)
	SIGNAL_HANDLER

	if(!ishuman(dropper))
		return

	UnregisterSignal(dropper, list(SIGNAL_ADDTRAIT(TRAIT_IS_WET), SIGNAL_REMOVETRAIT(TRAIT_IS_WET)))

	restore_owner(dropper)
	real_tail = null
	ephemeral_tail = null
	ephemeral_limbs = alist(
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/// set up our vars and spawn the fake tail or fake legs, whichever is needed
/obj/item/clothing/neck/necklace/pearl/proc/set_up(mob/living/carbon/human/equipper)
	if(!isnull(ephemeral_tail) || isnull(equipper.dna))
		return

	real_tail = equipper.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	ephemeral_tail = new tail_type
	for(var/zone in ephemeral_limbs)
		ephemeral_limbs[zone] = (equipper.get_bodypart(zone) && !istype(real_tail, /obj/item/organ/tail/fish/cerulean)) ? equipper.get_bodypart(zone) : gift_leg(equipper, zone)
		equipper.dna.species.bodypart_overrides[zone] = ephemeral_limbs[zone].type
	update_healthdoll(equipper)

/// restore our original appearance and organs/limbs. delete the fake spooky bits
/obj/item/clothing/neck/necklace/pearl/proc/restore_owner(mob/living/carbon/human/dropper)
	if(ephemeral_tail)
		if(ephemeral_tail.owner)
			ephemeral_tail.Remove(dropper, TRUE)
			//extra code to prevent deletion if tail and owner broke up and tail found a new relationship
			qdel(ephemeral_tail)

	if(istype(real_tail, /obj/item/organ/tail/fish/cerulean))
		detach_limbs(dropper)
		for(var/zone in ephemeral_limbs)
			//ditto but legs
			qdel(ephemeral_limbs[zone])
	else
		attach_limbs(dropper)

	if(real_tail)
		if(!real_tail.owner)
			real_tail.Insert(dropper, TRUE)

	clear_mood_events(dropper)
	dropper.dna.species.bodypart_overrides = GLOB.species_prototypes[dropper.dna.species.type].bodypart_overrides.Copy()
	update_healthdoll(dropper)

/// if cerulean, or the character has one of their tails, gift a new set of legs. bcuz it wouldnt make sense to have this item useless on ceruleans
/obj/item/clothing/neck/necklace/pearl/proc/gift_leg(mob/living/carbon/human/equipper, zone)
	var/left_or_right = findtext(zone, "l_") ? LEFT : RIGHT
	var/type_path

	if(equipper.dna.species.bodypart_overrides[zone])
		if(equipper.dna.species.digitigrade_customization && equipper.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)
			type_path = text2path("/obj/item/bodypart/leg/[left_or_right]/digitigrade") //:steam_happy:
			return new type_path(equipper)
		else
			type_path = equipper.dna.species.bodypart_overrides[zone]
			return new type_path(equipper)
	else
		type_path = text2path("/obj/item/bodypart/leg/[left_or_right]")
		return new type_path(equipper)

/// swap our stuff when we become wet
/obj/item/clothing/neck/necklace/pearl/proc/on_wet(mob/living/carbon/human/wetter)
	SIGNAL_HANDLER

	detach_limbs(wetter)

	if(real_tail)
		if(wetter.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == real_tail)
			real_tail.Remove(wetter, TRUE)
			real_tail.moveToNullspace()
	if(ephemeral_tail)
		if(!ephemeral_tail.owner)
			ephemeral_tail.Insert(wetter, TRUE)

	clear_mood_events(wetter)
	var/obj/item/bodypart/chest/tail_holder = wetter.get_bodypart(BODY_ZONE_CHEST)
	if(!ephemeral_tail.owner || tail_holder != ephemeral_tail.owner.get_bodypart(BODY_ZONE_CHEST))
		return
	if(wetter.wear_suit?.supports_variations_flags & CERULEAN_VARIATIONS)
		tail_holder?.remove_bodypart_texture(/datum/bodypart_texture/mesh)

/// swap our stuff when we become dry
/obj/item/clothing/neck/necklace/pearl/proc/on_dry(mob/living/carbon/human/dryer)
	SIGNAL_HANDLER

	if(ephemeral_tail && dryer.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == ephemeral_tail)
		ephemeral_tail.Remove(dryer, TRUE)
	if(real_tail)
		if(!real_tail.owner && !(TRAIT_BLOCK_ATTACHING_LEGS in real_tail.organ_traits))
			real_tail.Insert(dryer, TRUE)
		else if(istype(real_tail, /obj/item/organ/tail/fish/cerulean) && dryer.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == real_tail)
			real_tail.Remove(dryer, TRUE)
	attach_limbs(dryer)
	clear_mood_events(dryer)

/// the limb attachening
/obj/item/clothing/neck/necklace/pearl/proc/attach_limbs(mob/living/carbon/human/dryer, obj/item/bodypart/leg/ephemeral_limb)
	for(var/zone in ephemeral_limbs)
		ephemeral_limb = ephemeral_limbs[zone]
		if(dryer.get_bodypart(zone) || !ephemeral_limb)
			continue
		if(!ephemeral_limb.can_attach_limb(dryer, FALSE))
			continue
		if(ephemeral_limb.try_attach_limb(dryer, TRUE))
			ephemeral_limb.update_draw_color()
			ephemeral_limb.update_limb(FALSE, TRUE)

	dryer.regenerate_icons()

/// the limb detachening
/obj/item/clothing/neck/necklace/pearl/proc/detach_limbs(mob/living/carbon/human/wetter, obj/item/bodypart/leg/ephemeral_limb)
	for(var/zone in ephemeral_limbs)
		ephemeral_limb = wetter.get_bodypart(zone)
		if(!ephemeral_limb)
			continue
		ephemeral_limb.drop_limb(TRUE, FALSE)
		ephemeral_limb.moveToNullspace()

	wetter.regenerate_icons()

/// why are there so many
/obj/item/clothing/neck/necklace/pearl/proc/clear_mood_events(mob/living/equipper)
	var/static/list/tail_moods = list(
		/datum/mood_event/tail_lost,
		/datum/mood_event/tail_balance_lost,
		/datum/mood_event/tail_regained_wrong,
		/datum/mood_event/tail_regained_species,
		/datum/mood_event/tail_regained_right,
	)

	for(var/mood_event as anything in tail_moods)
		equipper.clear_mood_event(mood_event)

/// so you can see your legs damage
/obj/item/clothing/neck/necklace/pearl/proc/update_healthdoll(mob/equipper)
	var/atom/movable/screen/healthdoll/doll = equipper.hud_used?.screen_objects[HUD_MOB_HEALTHDOLL]
	doll?.update_body_zones()
	doll?.update_appearance()

/obj/item/clothing/neck/necklace/pearl/abyssal
	tail_type = /obj/item/organ/tail/fish/cerulean/abyssal

/obj/item/clothing/neck/necklace/pearl/skeleton
	tail_type = /obj/item/organ/tail/fish/cerulean/skeletal

#undef LEFT
#undef RIGHT
