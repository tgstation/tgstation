#define LEFT "left"
#define RIGHT "right"

/*
 * a rare and magical necklace which allows someone to have both legs and a mermaid tail
 * swapping to the latter only when the wearer is wet, and granting contorl by (un)equipping
 */
/obj/item/clothing/neck/necklace/pearl
	name = "Pearl necklace"
	desc = "Get your mind out of the gutter."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "beads"
	color = "#ffffff"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// what tail to spawn? reminder to make an effect so this can become /obj/item/organ/tail/fish/cerulean/abyssal
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
	color = pick(GLOB.carp_colors)
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
	// also update our healthdoll so we can see if our legs get hurt
	var/atom/movable/screen/healthdoll/doll = equipper.hud_used?.screen_objects[HUD_MOB_HEALTHDOLL]
	doll?.update_body_zones()
	doll?.update_appearance()

/// restore our original appearance and organs/limbs. delete the fake spooky bits
/obj/item/clothing/neck/necklace/pearl/proc/restore_owner(mob/living/carbon/human/dropper)
	if(ephemeral_tail)
		if(!ephemeral_tail.owner)
			ephemeral_tail.Remove(dropper, TRUE)
			qdel(ephemeral_tail)

	if(istype(real_tail, /obj/item/organ/tail/fish/cerulean))
		detach_limbs(dropper)
		for(var/zone in ephemeral_limbs)
			qdel(ephemeral_limbs[zone])
	else
		attach_limbs(dropper)

	if(real_tail)
		if(!real_tail.owner)
			real_tail.Insert(dropper, TRUE)

	dropper.dna.species.bodypart_overrides = GLOB.species_prototypes[dropper.dna.species.type].bodypart_overrides
	var/atom/movable/screen/healthdoll/doll = equipper.hud_used?.screen_objects[HUD_MOB_HEALTHDOLL]
	doll?.update_body_zones()
	doll?.update_appearance()

/// if cerulean or character has one of their tails, gift a new set of legs. bcuz it wouldnt make sense to have this item useless on ceruleans
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
		else if(dryer.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == real_tail)
			real_tail.Remove(dryer, TRUE)
			var/datum/status_effect/organ_set_bonus/fish/bonus = dryer.has_status_effect(/datum/status_effect/organ_set_bonus/fish)
			bonus?.set_organs(bonus?.organs + 1, real_tail)
	attach_limbs(dryer)

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

#undef LEFT
#undef RIGHT
