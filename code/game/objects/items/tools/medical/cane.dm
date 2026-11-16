/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentleman. Or a clown."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "cane"
	inhand_icon_state = "stick"
	icon_angle = 135
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron= SMALL_MATERIAL_AMOUNT * 0.5)
	attack_verb_continuous = list("bludgeons", "whacks", "disciplines", "thrashes")
	attack_verb_simple = list("bludgeon", "whack", "discipline", "thrash")
	/// The amount of slowdown to reduce for a limbless leg
	var/limbless_slowdown_modifier = 0.6 // reduces slowdown by 40%
	/// Does this cause waddling when held
	var/causes_waddling = FALSE

/obj/item/cane/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/walking_aid, limbless_slowdown_modifier, get_walking_aid_required_trait(), causes_waddling)

/// Determines if a trait is required to be used as a walking aid (ex. foldable canes)
/obj/item/cane/proc/get_walking_aid_required_trait()
	return null

/obj/item/cane/crutch
	name = "medical crutch"
	desc = "A medical crutch used by people missing a leg. Not all that useful if you're missing both of them, though."
	icon = 'icons/obj/weapons/staff.dmi'
	icon_state = "crutch_med"
	inhand_icon_state = "crutch_med"
	icon_angle = 45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 12
	throwforce = 8
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.5)
	attack_verb_continuous = list("bludgeons", "whacks", "thrashes")
	attack_verb_simple = list("bludgeon", "whack", "thrash")
	limbless_slowdown_modifier = 0.4 // reduces slowdown by 60%
	causes_waddling = TRUE

/obj/item/cane/crutch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item)

/obj/item/cane/crutch/wood
	name = "wooden crutch"
	desc = "A handmade crutch. Also makes a decent bludgeon if you need it."
	icon_state = "crutch_wood"
	inhand_icon_state = "crutch_wood"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 5)

/obj/item/cane/white
	name = "white cane"
	desc = "Traditionally used by the blind to help them see. Folds down to be easier to transport."
	icon_state = "cane_white"
	inhand_icon_state = "cane_white"
	icon_angle = 45
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 6)

/obj/item/cane/white/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/cuffable_item)
	AddComponent( \
		/datum/component/transforming, \
		force_on = 7, \
		hitsound_on = hitsound, \
		w_class_on = WEIGHT_CLASS_BULKY, \
		clumsy_check = FALSE, \
		attack_verb_continuous_on = list("smacks", "strikes", "cracks", "beats"), \
		attack_verb_simple_on = list("smack", "strike", "crack", "beat"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

// White canes only provide support while extended
/obj/item/cane/white/get_walking_aid_required_trait()
	return TRAIT_TRANSFORM_ACTIVE

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback to the user and makes it show up inhand.
 */
/obj/item/cane/white/proc/on_transform(obj/item/source, mob/living/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, active ? "extended" : "collapsed")

	if(!HAS_TRAIT(src, TRAIT_BLIND_TOOL))
		ADD_TRAIT(src, TRAIT_BLIND_TOOL, INNATE_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_BLIND_TOOL, INNATE_TRAIT)

	playsound(src, 'sound/items/weapons/batonextend.ogg', 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE
