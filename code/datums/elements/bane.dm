/// Deals extra damage to mobs of a certain type, species, or biotype.
/// This doesn't directly modify the normal damage of the weapon, instead it applies its own damage separately ON TOP of normal damage
/// ie. a sword that does 10 damage with a bane element attached that has a 0.5 damage_multiplier will do:
/// 10 damage from the swords normal attack + 5 damage (50%) from the bane element
/datum/element/bane
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// can be a mob or a species.
	var/target_type
	/// multiplier of the extra damage based on the force of the item.
	var/damage_multiplier
	/// Added after the above.
	var/added_damage
	/// If it requires combat mode on to deal the extra damage or not.
	var/requires_combat_mode
	/// if we want it to only affect a certain mob biotype
	var/mob_biotypes

/datum/element/bane/Attach(datum/target, target_type = /mob/living, mob_biotypes = NONE, damage_multiplier=1, added_damage = 0, requires_combat_mode = TRUE)
	. = ..()

	if(!ispath(target_type, /mob/living) && !ispath(target_type, /datum/species))
		return ELEMENT_INCOMPATIBLE

	src.target_type = target_type
	src.damage_multiplier = damage_multiplier
	src.added_damage = added_damage
	src.requires_combat_mode = requires_combat_mode
	src.mob_biotypes = mob_biotypes
	target.AddElementTrait(TRAIT_ON_HIT_EFFECT, REF(src), /datum/element/on_hit_effect)
	RegisterSignal(target, COMSIG_ON_HIT_EFFECT, PROC_REF(do_bane))

/datum/element/bane/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ON_HIT_EFFECT)
	REMOVE_TRAIT(source, TRAIT_ON_HIT_EFFECT, REF(src))
	return ..()

/datum/element/bane/proc/do_bane(datum/element_owner, mob/living/bane_applier, mob/living/baned_target, hit_zone, throw_hit)
	if(!check_biotype_path(bane_applier, baned_target))
		return
	if(SEND_SIGNAL(element_owner, COMSIG_OBJECT_PRE_BANING, baned_target) & COMPONENT_CANCEL_BANING)
		return

	var/force_boosted
	var/applied_dam_type

	if(isitem(element_owner))
		var/obj/item/item_owner = element_owner
		force_boosted = item_owner.force
		applied_dam_type = item_owner.damtype
	else if(isprojectile(element_owner))
		var/obj/projectile/projectile_owner = element_owner
		force_boosted = projectile_owner.damage
		applied_dam_type = projectile_owner.damage_type
	else if (isliving(element_owner))
		var/mob/living/living_owner = element_owner
		force_boosted = (living_owner.melee_damage_lower + living_owner.melee_damage_upper) / 2
		//commence crying. yes, these really are the same check. FUCK.
		if(isbasicmob(living_owner))
			var/mob/living/basic/basic_owner = living_owner
			applied_dam_type = basic_owner.melee_damage_type
		else if(isanimal(living_owner))
			var/mob/living/simple_animal/simple_owner = living_owner
			applied_dam_type = simple_owner.melee_damage_type
		else
			return
	else
		return

	var/extra_damage = max(0, (force_boosted * damage_multiplier) + added_damage)
	baned_target.apply_damage(extra_damage, applied_dam_type, hit_zone)
	SEND_SIGNAL(baned_target, COMSIG_LIVING_BANED, bane_applier, baned_target) // for extra effects when baned.
	SEND_SIGNAL(element_owner, COMSIG_OBJECT_ON_BANING, baned_target)

/**
 * Checks typepaths and the mob's biotype, returning TRUE if correct and FALSE if wrong.
 * Additionally checks if combat mode is required, and if so whether it's enabled or not.
 */
/datum/element/bane/proc/check_biotype_path(atom/bane_applier, atom/target)
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target
	if(isliving(bane_applier) && bane_applier)
		var/mob/living/living_bane_applier = bane_applier
		if(requires_combat_mode && !living_bane_applier.combat_mode)
			return FALSE
	var/is_correct_biotype = living_target.mob_biotypes & mob_biotypes
	if(mob_biotypes && !(is_correct_biotype))
		return FALSE
	if(ispath(target_type, /mob/living))
		return istype(living_target, target_type)
	else //species type
		return is_species(living_target, target_type)
