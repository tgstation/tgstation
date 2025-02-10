#define UNDERSIZED_SPEED_SLOWDOWN 0.5
#define UNDERSIZED_HUNGER_MOD 1.0
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
	icon = FA_ICON_EXPAND_ARROWS_ALT
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	/// Saves refs to the original (normal size) organs, which are on ice in nullspace in case this quirk gets removed somehow.
	var/list/obj/item/organ/old_organs
	var/list/undersized_traits = list(
		TRAIT_HATED_BY_DOGS,
		TRAIT_UNDENSE,
	)

/datum/quirk/undersized/add(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.mob_size = MOB_SIZE_TINY

	human_holder.add_traits(undersized_traits, QUIRK_TRAIT)

	human_holder.can_be_held = TRUE //makes u scoopable
	human_holder.max_grab = 1 //you are too weak to aggro grab
	human_holder.blood_volume_normal = BLOOD_VOLUME_UNDERSIZED
	human_holder.physiology.hunger_mod *= UNDERSIZED_HUNGER_MOD // This does nothing but I left it incase anyone wants to fuck with it
	human_holder.add_movespeed_modifier(/datum/movespeed_modifier/undersized)

	RegisterSignal(human_holder, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_gain_limb))

	for(var/obj/item/bodypart/bodypart as anything in human_holder.bodyparts)
		on_gain_limb(src, bodypart, special = FALSE)

	human_holder.transform = human_holder.transform.Scale(0.5)
	human_holder.maptext_height = 24

	human_holder.AddComponent( \
		/datum/component/squashable, \
		squash_chance = UNDERSIZED_SQUASH_CHANCE, \
		squash_damage = UNDERSIZED_SQUASH_DAMAGE, \
		squash_flags = UNDERSIZED_SHOULD_GIB, \
	)

	var/datum/action/cooldown/spell/adjust_sprite_size/shrink/action = new(src)
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


	human_holder.blood_volume_normal = BLOOD_VOLUME_NORMAL
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

	human_holder.can_be_held = FALSE
	human_holder.density = 1
	human_holder.max_grab = 3
	human_holder.remove_traits(TRAIT_HATED_BY_DOGS)

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

//this is about to get cringe and poorly designed.
//ensmallening spell begin

/datum/action/cooldown/spell/adjust_sprite_size/shrink
	name = "Shrink Held Item"

/datum/action/cooldown/spell/adjust_sprite_size/shrink/cast(mob/living/cast_on)
	. = ...() //face holding back tears emoji

	var/obj/item/to_change = cast_on.get_active_held_item() || cast_on.get_inactive_held_item()
	if(!to_change)
		to_chat(cast_on, span_notice("Nothing to shrink!"))
		return

	if(!cast_on)
		owner.balloon_alert(owner, "no item in hand!")
		return FALSE

	var/datum/component/existing_component = to_change.GetComponent(/datum/component/embiggened/shrink)
	if(existing_component)
		owner.balloon_alert(owner, "already shrunk, unshrunking!")
		qdel(existing_component)
		return FALSE

	to_change.AddComponent(/datum/component/embiggened/shrink)
	owner.balloon_alert(owner, "item shrank")
	return TRUE

/datum/component/embiggened/shrink
	// This component is used to mark items that have been embiggened by the Oversized quirk's spell.
	// It's used to prevent the spell from embiggening the same item multiple times.

/datum/component/embiggened/shrink/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	old_name = parent_atom.name
	old_transform = parent_atom.transform
	parent_atom.transform = parent_atom.transform.Scale(0.8, 0.8)
	if(istype(parent_atom, /atom/movable))
		parent_atom.name = "tiny [parent_atom.name]"

/datum/component/embiggened/shrink/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/atom/owner = parent
	if(owner)
		examine_list += span_notice("Whether by modification or manufacture, this is clearly intended for sentients probably half your size.")

//ensmallening spell end

#undef UNDERSIZED_HUNGER_MOD
#undef UNDERSIZED_SPEED_SLOWDOWN
#undef UNDERSIZED_HARM_DAMAGE_BONUS
#undef UNDERSIZED_KICK_EFFECTIVENESS_BONUS
#undef UNDERSIZED_SQUASH_CHANCE
#undef UNDERSIZED_SQUASH_DAMAGE
#undef UNDERSIZED_SHOULD_GIB
