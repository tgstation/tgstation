/// Allows items to have different sharpness for right click attacks
/datum/component/alternative_sharpness
	/// Sharpness we change the attack to
	var/alt_sharpness = NONE
	/// Overrides for continuous attack verbs when performing an alt attack
	var/verbs_continuous = null
	/// Overrides for simple attack verbs when performing an alt attack
	var/verbs_simple = null
	/// Value by which we offset our force during the attack
	var/force_mod = 0
	/// Are we currently performing an alt attack?
	var/alt_attacking = FALSE
	/// Trait required for us to trigger
	var/required_trait = null
	/// Hitsound that overrides our current hitsound if defined.
	var/alt_hitsound = null
	// Old values before we overrode them
	var/base_continuous = null
	var/base_simple = null
	var/base_sharpness = NONE
	var/base_hitsound = null

/datum/component/alternative_sharpness/Initialize(alt_sharpness, verbs_continuous = null, verbs_simple = null, force_mod = 0, required_trait = null, alt_hitsound = null,)
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/weapon = parent
	src.alt_sharpness = alt_sharpness
	src.verbs_continuous = verbs_continuous
	src.verbs_simple = verbs_simple
	src.force_mod = force_mod
	src.required_trait = required_trait
	src.alt_hitsound = alt_hitsound
	base_continuous = weapon.attack_verb_continuous
	base_simple = weapon.attack_verb_simple
	base_hitsound = weapon.hitsound

/datum/component/alternative_sharpness/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_secondary_attack))
	RegisterSignal(parent, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/datum/component/alternative_sharpness/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PRE_ATTACK_SECONDARY,
		COMSIG_TRANSFORMING_ON_TRANSFORM,
	))

/datum/component/alternative_sharpness/proc/on_secondary_attack(obj/item/source, atom/target, mob/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER

	if (alt_attacking || (required_trait && !HAS_TRAIT(source, required_trait)))
		return

	alt_attacking = TRUE
	MODIFY_ATTACK_FORCE(attack_modifiers, force_mod)
	base_sharpness = source.sharpness
	source.sharpness = alt_sharpness
	if (!isnull(verbs_continuous))
		source.attack_verb_continuous = verbs_continuous

	if (!isnull(verbs_simple))
		source.attack_verb_simple = verbs_simple

	if(!isnull(alt_hitsound))
		source.hitsound = alt_hitsound

	// I absolutely despise this but this is geniunely the best way to do this without creating and hooking up to a dozen signals and still risking failure edge cases
	addtimer(CALLBACK(src, PROC_REF(disable_alt_attack)), 1)

/datum/component/alternative_sharpness/proc/disable_alt_attack()
	var/obj/item/weapon = parent
	alt_attacking = FALSE
	weapon.attack_verb_continuous = base_continuous
	weapon.attack_verb_simple = base_simple
	weapon.sharpness = base_sharpness
	weapon.hitsound = base_hitsound

// If our weapon is transforming, we listen for the transformation to adjust our base_hitsound as needed so we're not caught out by the callback adding inappropriate values.
/datum/component/alternative_sharpness/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	base_continuous = source.attack_verb_continuous
	base_simple = source.attack_verb_simple
	base_sharpness = source.sharpness
	base_hitsound = source.hitsound
