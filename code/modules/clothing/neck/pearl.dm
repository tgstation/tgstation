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
	color = "#272526"
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

/obj/item/clothing/neck/necklace/pearl/equipped(mob/living/user, slot)
	. = ..()
	if(slot != ITEM_SLOT_NECK || !ishuman(user))
		return

	RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_IS_WET), PROC_REF(on_wet))
	RegisterSignal(user, SIGNAL_REMOVETRAIT(TRAIT_IS_WET), PROC_REF(on_dry))

	set_up(user)
	if(user.has_status_effect(/datum/status_effect/fire_handler/wet_stacks))
		on_wet(user)
	else
		on_dry(user)

/obj/item/clothing/neck/necklace/pearl/dropped(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return

	UnregisterSignal(user, list(SIGNAL_ADDTRAIT(TRAIT_IS_WET), SIGNAL_REMOVETRAIT(TRAIT_IS_WET)))

	restore_owner(user)
	real_tail = null
	ephemeral_tail = null
	ephemeral_limbs = alist(
		BODY_ZONE_L_LEG = null,
		BODY_ZONE_R_LEG = null,
	)

/// set up our vars and spawn the fake tail or fake legs, whichever is needed
/obj/item/clothing/neck/necklace/pearl/proc/set_up(mob/living/carbon/human/user)
	if(!isnull(ephemeral_tail) || isnull(user.dna))
		return

	real_tail = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL)
	ephemeral_tail = new tail_type
	for(var/zone in ephemeral_limbs)
		ephemeral_limbs[zone] = (user.get_bodypart(zone) && !istype(real_tail, /obj/item/organ/tail/fish/cerulean)) ? user.get_bodypart(zone) : gift_leg(user, zone)
		user.dna.species.bodypart_overrides[zone] = ephemeral_limbs[zone].type
	update_healthdoll(user)

/// restore our original appearance and organs/limbs. delete the fake spooky bits
/obj/item/clothing/neck/necklace/pearl/proc/restore_owner(mob/living/carbon/human/user)
	if(ephemeral_tail)
		if(ephemeral_tail.owner)
			ephemeral_tail.Remove(user, TRUE)
			//extra code to prevent deletion if tail and owner broke up and tail found a new relationship
			qdel(ephemeral_tail)

	if(istype(real_tail, /obj/item/organ/tail/fish/cerulean))
		detach_limbs(user)
		for(var/zone in ephemeral_limbs)
			//ditto but legs
			qdel(ephemeral_limbs[zone])
	else
		attach_limbs(user)

	if(real_tail)
		if(!real_tail.owner)
			real_tail.Insert(user, TRUE)

	clear_mood_events(user)
	user.dna.species.bodypart_overrides = GLOB.species_prototypes[user.dna.species.type].bodypart_overrides.Copy()
	user.regenerate_icons()
	update_healthdoll(user)

/// if cerulean, or the character has one of their tails, gift a new set of legs. bcuz it wouldnt make sense to have this item useless on ceruleans
/obj/item/clothing/neck/necklace/pearl/proc/gift_leg(mob/living/carbon/human/user, zone)
	var/left_or_right = findtext(zone, "l_")
	var/type_path

	if(user.dna.species.bodypart_overrides[zone])
		if(user.dna.species.digitigrade_customization && user.dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)
			type_path = left_or_right ? /obj/item/bodypart/leg/left/digitigrade : /obj/item/bodypart/leg/right/digitigrade //:steam_happy:
			return new type_path(user)
		else
			type_path = user.dna.species.bodypart_overrides[zone]
			return new type_path(user)
	else
		type_path = left_or_right ? /obj/item/bodypart/leg/left : /obj/item/bodypart/leg/right
		return new type_path(user)

/// swap our stuff when we become wet
/obj/item/clothing/neck/necklace/pearl/proc/on_wet(mob/living/carbon/human/user)
	SIGNAL_HANDLER

	detach_limbs(user)

	if(real_tail)
		if(user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == real_tail)
			real_tail.Remove(user, TRUE)
			real_tail.moveToNullspace()
	if(ephemeral_tail)
		if(!ephemeral_tail.owner)
			ephemeral_tail.Insert(user, TRUE)
	playsound(user, 'sound/effects/magic/staff_change.ogg', 35, TRUE)
	apply_wibbly_filters(user)
	addtimer(CALLBACK(src, PROC_REF(remove_wibbly), user), 2 DECISECONDS, TIMER_DELETE_ME)
	clear_mood_events(user)
	var/obj/item/bodypart/chest/tail_holder = user.get_bodypart(BODY_ZONE_CHEST)
	if(!ephemeral_tail.owner || tail_holder != ephemeral_tail.owner.get_bodypart(BODY_ZONE_CHEST))
		return
	if((user.wear_suit?.bodyshapes_with_variations & BODYSHAPE_CERULEAN) || (user.wear_suit?.supports_variations_flags & CERULEAN_MASKING))
		tail_holder?.remove_bodypart_texture(/datum/bodypart_texture/mesh)

/// swap our stuff when we become dry
/obj/item/clothing/neck/necklace/pearl/proc/on_dry(mob/living/carbon/human/user)
	SIGNAL_HANDLER

	if(ephemeral_tail && user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == ephemeral_tail)
		ephemeral_tail.Remove(user, TRUE)
	if(real_tail)
		if(!real_tail.owner && !(TRAIT_BLOCK_ATTACHING_LEGS in real_tail.organ_traits))
			real_tail.Insert(user, TRUE)
		else if(istype(real_tail, /obj/item/organ/tail/fish/cerulean) && user.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL) == real_tail)
			real_tail.Remove(user, TRUE)
	playsound(user, 'sound/effects/magic/staff_change.ogg', 35, TRUE)
	apply_wibbly_filters(user)
	addtimer(CALLBACK(src, PROC_REF(remove_wibbly), user), 2 DECISECONDS, TIMER_DELETE_ME)
	attach_limbs(user)
	clear_mood_events(user)

/// the limb attachening
/obj/item/clothing/neck/necklace/pearl/proc/attach_limbs(mob/living/carbon/human/user, obj/item/bodypart/leg/ephemeral_limb)
	for(var/zone in ephemeral_limbs)
		ephemeral_limb = ephemeral_limbs[zone]
		if(user.get_bodypart(zone) || !ephemeral_limb)
			continue
		if(!ephemeral_limb.can_attach_limb(user, FALSE))
			continue
		if(ephemeral_limb.try_attach_limb(user, TRUE))
			ephemeral_limb.update_draw_color()
			ephemeral_limb.update_limb(FALSE, TRUE)

	user.regenerate_icons()

/// the limb detachening
/obj/item/clothing/neck/necklace/pearl/proc/detach_limbs(mob/living/carbon/human/user, obj/item/bodypart/leg/ephemeral_limb)
	for(var/zone in ephemeral_limbs)
		ephemeral_limb = user.get_bodypart(zone)
		if(!ephemeral_limb)
			continue
		ephemeral_limb.drop_limb(TRUE, FALSE)
		ephemeral_limb.moveToNullspace()

	user.regenerate_icons()

/// why are there so many
/obj/item/clothing/neck/necklace/pearl/proc/clear_mood_events(mob/living/user)
	var/static/list/tail_moods = list(
		/datum/mood_event/tail_lost,
		/datum/mood_event/tail_balance_lost,
		/datum/mood_event/tail_regained_wrong,
		/datum/mood_event/tail_regained_species,
		/datum/mood_event/tail_regained_right,
	)

	for(var/mood_event in tail_moods)
		user.clear_mood_event(mood_event)

/// so you can see your legs damage
/obj/item/clothing/neck/necklace/pearl/proc/update_healthdoll(mob/user)
	var/atom/movable/screen/healthdoll/doll = user.hud_used?.screen_objects[HUD_MOB_HEALTHDOLL]
	doll?.update_body_zones()
	doll?.update_appearance()

/// removes the wibbly filter
/obj/item/clothing/neck/necklace/pearl/proc/remove_wibbly(mob/user)
	if(isnull(user))
		return
	remove_wibbly_filters(user)

/obj/item/clothing/neck/necklace/pearl/abyss
	tail_type = /obj/item/organ/tail/fish/cerulean/abyss

/obj/item/clothing/neck/necklace/pearl/skeleton
	tail_type = /obj/item/organ/tail/fish/cerulean/skeletal
