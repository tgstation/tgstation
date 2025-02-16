#define UNDERSIZED_SPEED_SLOWDOWN 0.5
#define UNDERSIZED_HUNGER_MOD 0.5
#define UNDERSIZED_HARM_DAMAGE_BONUS -10
#define UNDERSIZED_KICK_EFFECTIVENESS_BONUS -5
#define UNDERSIZED_SQUASH_CHANCE 100
#define UNDERSIZED_SQUASH_DAMAGE 20
#define UNDERSIZED_SHOULD_GIB FALSE

/datum/quirk/undersized
	name = "Undersized"
	desc = "You're a tiny little creature, with all the benefits and mostly consequences that result."
	gain_text = span_notice("Woah everything looks huge!...")
	lose_text = span_notice("Woah, now I look huge too!")
	medical_record_text = "Patient is abnormally small."
	value = 0
	mob_trait = TRAIT_UNDERSIZED
	icon = FA_ICON_PERSON_FALLING
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	/// Saves refs to the original (normal size) organs, which are on ice in nullspace in case this quirk gets removed somehow.
	var/list/obj/item/organ/old_organs
	var/list/undersized_traits = list(
		TRAIT_HATED_BY_DOGS,
		TRAIT_UNDENSE,
		TRAIT_EASILY_WOUNDED,
		TRAIT_GRABWEAKNESS,
	)

/datum/quirk/undersized/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder

	human_holder.add_traits(undersized_traits, QUIRK_TRAIT)
	human_holder.mob_size = MOB_SIZE_TINY
	human_holder.held_w_class = WEIGHT_CLASS_TINY
	human_holder.can_be_held = TRUE //makes u scoopable
	human_holder.worn_slot_flags = ITEM_SLOT_HEAD|ITEM_SLOT_BACKPACK

	passtable_on(human_holder, QUIRK_TRAIT)

	human_holder.max_grab = GRAB_AGGRESSIVE //you are too weak to neck slam or strangle
	human_holder.physiology.hunger_mod *= UNDERSIZED_HUNGER_MOD
	human_holder.add_movespeed_modifier(/datum/movespeed_modifier/undersized)

	RegisterSignal(human_holder, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_gain_limb))
	RegisterSignal(human_holder, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS, PROC_REF(damage_weakness))

	for(var/obj/item/bodypart/bodypart as anything in human_holder.bodyparts)
		on_gain_limb(src, bodypart, special = FALSE)

	human_holder.transform = human_holder.transform.Scale(0.5)
	human_holder.maptext_height = 24

	human_holder.AddComponent( \
		/datum/component/squashable_carbons, \
		squash_chance = UNDERSIZED_SQUASH_CHANCE, \
		squash_damage = UNDERSIZED_SQUASH_DAMAGE, \
		squash_flags = UNDERSIZED_SHOULD_GIB, \
	)

	var/datum/action/cooldown/spell/adjust_sprite_size_small/action = new(src)
	action.Grant(human_holder)

/datum/quirk/undersized/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.mob_size = MOB_SIZE_HUMAN

	human_holder.transform = human_holder.transform.Scale(2)
	human_holder.maptext_height = 32

	var/obj/item/bodypart/arm/left/left_arm = human_holder.get_bodypart(BODY_ZONE_L_ARM)
	if(left_arm)
		left_arm.unarmed_damage_high = initial(left_arm.unarmed_damage_high)

	var/obj/item/bodypart/arm/right/right_arm = human_holder.get_bodypart(BODY_ZONE_R_ARM)
	if(right_arm)
		right_arm.unarmed_damage_high = initial(right_arm.unarmed_damage_high)

	var/obj/item/bodypart/leg/left_leg = human_holder.get_bodypart(BODY_ZONE_L_LEG)
	if (left_leg)
		left_leg.unarmed_effectiveness = initial(left_leg.unarmed_effectiveness)

	var/obj/item/bodypart/leg/right_leg = human_holder.get_bodypart(BODY_ZONE_R_LEG)
	if (right_leg)
		right_leg.unarmed_effectiveness = initial(right_leg.unarmed_effectiveness)

	for(var/obj/item/bodypart/bodypart as anything in human_holder.bodyparts)
		bodypart.name = replacetext(bodypart.name, "tiny ", "")

	UnregisterSignal(human_holder, COMSIG_CARBON_POST_ATTACH_LIMB)
	UnregisterSignal(human_holder, COMSIG_MOB_APPLY_DAMAGE_MODIFIERS)

	human_holder.remove_traits(undersized_traits)

	human_holder.mob_size = MOB_SIZE_HUMAN
	human_holder.held_w_class = WEIGHT_CLASS_NORMAL
	human_holder.can_be_held = FALSE
	human_holder.worn_slot_flags = null

	passtable_off(human_holder, QUIRK_TRAIT)

	human_holder.max_grab = GRAB_KILL
	human_holder.physiology.hunger_mod /= UNDERSIZED_HUNGER_MOD
	human_holder.remove_movespeed_modifier(/datum/movespeed_modifier/undersized)


	for(var/obj/item/organ/organ_to_restore in old_organs)
		old_organs -= organ_to_restore

		if(QDELETED(organ_to_restore))
			continue

		var/obj/item/organ/brain/possibly_a_brain = organ_to_restore
		if(istype(possibly_a_brain))
			var/obj/item/organ/brain/current_brain = human_holder.get_organ_slot(ORGAN_SLOT_BRAIN)
			possibly_a_brain.brainmob = current_brain.brainmob

		organ_to_restore.replace_into(quirk_holder)

	var/datum/component/squashable/component = human_holder.GetComponent(/datum/component/squashable)
	qdel(component)

/datum/quirk/undersized/proc/on_gain_limb(datum/source, obj/item/bodypart/gained, special)
	SIGNAL_HANDLER

	if(findtext(gained.name, "undersized"))
		return

	if(istype(gained, /obj/item/bodypart/arm))
		var/obj/item/bodypart/arm/new_arm = gained
		new_arm.unarmed_damage_high = initial(new_arm.unarmed_damage_high) + UNDERSIZED_HARM_DAMAGE_BONUS

	else if(istype(gained, /obj/item/bodypart/leg))
		var/obj/item/bodypart/leg/new_leg = gained
		new_leg.unarmed_effectiveness = initial(new_leg.unarmed_effectiveness) + UNDERSIZED_KICK_EFFECTIVENESS_BONUS

	gained.name = "Tiny " + gained.name

/datum/movespeed_modifier/undersized
	multiplicative_slowdown = UNDERSIZED_SPEED_SLOWDOWN

/datum/quirk/undersized/proc/damage_weakness(datum/source, list/damage_mods, damage_amount, damagetype, def_zone, sharpness, attack_direction, obj/item/attacking_item)
	if(istype(attacking_item, /obj/item/melee/flyswatter))
		damage_mods += 50 // :)

//ensmallening spell begin

/datum/action/cooldown/spell/adjust_sprite_size_small
	name = "Shrink Held Item"
	desc = "Adjusts the sprite size of something you're holding, to more accurately reflect it being for you."
	button_icon_state = "charge"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

/datum/action/cooldown/spell/adjust_sprite_size_small/is_valid_target(atom/cast_on)
	return isliving(cast_on)

/datum/action/cooldown/spell/adjust_sprite_size_small/cast(mob/living/cast_on)
	. = ..()

	var/obj/item/to_change = cast_on.get_active_held_item() || cast_on.get_inactive_held_item()
	if(!to_change)
		to_chat(cast_on, span_notice("Nothing to Shrink!"))
		return

	if(!cast_on)
		owner.balloon_alert(owner, "no item in hand!")
		return FALSE

	var/datum/component/existing_component = to_change.GetComponent(/datum/component/emshranked)
	if(existing_component)
		owner.balloon_alert(owner, "already shrunk, removing!")
		qdel(existing_component)
		return FALSE

	to_change.AddComponent(/datum/component/emshranked)
	owner.balloon_alert(owner, "item shrank.")
	return TRUE

/datum/component/emshranked
	// This component is used to mark items that have been shrinked by the Oversized quirk's spell.
	// It's used to prevent the spell from shrunked the same item multiple times.

/datum/component/emshranked/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	old_name = parent_atom.name
	old_transform = parent_atom.transform
	parent_atom.transform = parent_atom.transform.Scale(0.8, 0.8)
	if(istype(parent_atom, /atom/movable))
		parent_atom.name = "tiny [parent_atom.name]"

/datum/component/emshranked/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/emshranked/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)

/datum/component/emshranked/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/owner = parent
	if(owner)
		examine_list += span_notice("Whether by modification or manufacture, this is clearly intended for sentients probably twice your size.")

/datum/component/emshranked/Destroy(force)
	var/atom/parent_atom = parent
	if(parent_atom)
		parent_atom.transform = old_transform // Revert the transform to original
		if(istype(parent_atom, /atom/movable))
			parent_atom.name = old_name // Revert the name to original
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	return ..()


//ensmallening spell end

#undef UNDERSIZED_HUNGER_MOD
#undef UNDERSIZED_SPEED_SLOWDOWN
#undef UNDERSIZED_HARM_DAMAGE_BONUS
#undef UNDERSIZED_KICK_EFFECTIVENESS_BONUS
#undef UNDERSIZED_SQUASH_CHANCE
#undef UNDERSIZED_SQUASH_DAMAGE
#undef UNDERSIZED_SHOULD_GIB
