// Alternate PKC skins
/datum/atom_skin/crusher_skin
	abstract_type = /datum/atom_skin/crusher_skin
	change_base_icon_state = TRUE
	new_icon = 'icons/obj/mining.dmi'
	new_icon_state = "ipickaxe"
	/// Specifies the icon state for the crusher's appearance in hand. Should appear in both new_lefthand_file and new_righthand_file.
	var/new_inhand_icon = "ipickaxe"
	/// Specifies the icon file in which the crusher's projectile sprite is located.
	var/new_projectile_icon = 'icons/obj/weapons/guns/projectiles.dmi'
	/// For if the retool kit changes the projectile's appearance.
	var/new_projectile_icon_state
	/// Specifies the left hand inhand icon file. Don't forget to set the right hand file as well.
	var/new_lefthand_file
	/// Specifies the right hand inhand icon file. Don't forget to set the left hand file as well.
	var/new_righthand_file
	/// Specifies the worn icon file.
	var/new_worn_file
	/// Specifies the X dimensions of the new inhand, only relevant with different inhand files.
	var/new_inhandx
	/// Specifies the Y dimensions of the new inhand, only relevant with different inhand files.
	var/new_inhandy

/datum/atom_skin/crusher_skin/apply(obj/item/kinetic_crusher/apply_to)
	. = ..()
	APPLY_VAR_OR_RESET_INITIAL(apply_to, inhand_icon_state, new_inhand_icon, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, projectile_icon, new_projectile_icon, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, projectile_icon_state, new_projectile_icon_state, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, lefthand_file, new_lefthand_file, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, righthand_file, new_righthand_file, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, worn_icon, new_worn_file, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, worn_icon_state, new_icon_state, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, inhand_x_dimension, new_inhandx, reset_missing)
	APPLY_VAR_OR_RESET_INITIAL(apply_to, inhand_y_dimension, new_inhandy, reset_missing)

/datum/atom_skin/crusher_skin/clear_skin(obj/item/kinetic_crusher/clear_from)
	. = ..()
	RESET_INITIAL_IF_SET(clear_from, inhand_icon_state, new_inhand_icon)
	RESET_INITIAL_IF_SET(clear_from, projectile_icon, new_projectile_icon)
	RESET_INITIAL_IF_SET(clear_from, projectile_icon_state, new_projectile_icon_state)
	RESET_INITIAL_IF_SET(clear_from, lefthand_file, new_lefthand_file)
	RESET_INITIAL_IF_SET(clear_from, righthand_file, new_righthand_file)
	RESET_INITIAL_IF_SET(clear_from, worn_icon, new_worn_file)
	RESET_INITIAL_IF_SET(clear_from, worn_icon_state, new_icon_state)
	RESET_INITIAL_IF_SET(clear_from, inhand_x_dimension, new_inhandx)
	RESET_INITIAL_IF_SET(clear_from, inhand_y_dimension, new_inhandy)

/datum/atom_skin/crusher_skin/sword
	new_name = "proto-kinetic sword"
	preview_name = "Sword"
	new_icon_state = "crusher_sword"
	new_inhand_icon = "crusher_sword"

/datum/atom_skin/crusher_skin/harpoon
	new_name = "proto-kinetic harpoon"
	preview_name = "Harpoon"
	new_icon_state = "crusher_harpoon"
	new_inhand_icon = "crusher_harpoon"
	new_projectile_icon_state = "pulse_harpoon"

/datum/atom_skin/crusher_skin/harpoon/apply(atom/apply_to)
	. = ..()
	RegisterSignal(apply_to, COMSIG_ITEM_ATTACK_ANIMATION, PROC_REF(on_attack_animation))

/datum/atom_skin/crusher_skin/harpoon/clear_skin(atom/clear_from)
	. = ..()
	UnregisterSignal(clear_from, COMSIG_ITEM_ATTACK_ANIMATION)

/datum/atom_skin/crusher_skin/harpoon/proc/on_attack_animation(obj/item/source, atom/movable/attacker, atom/attacked_atom, animation_type, list/image_override, list/animation_override)
	SIGNAL_HANDLER

	// If nothing is forcing an animation type, attack with a piercing animation because we're a harpoon
	if (!animation_type)
		animation_override += ATTACK_ANIMATION_PIERCE

/datum/atom_skin/crusher_skin/dagger
	new_name = "proto-kinetic dual dagger and blaster"
	preview_name = "Dagger and Blaster"
	new_icon_state = "crusher_dagger"
	new_inhand_icon = "crusher_dagger"

/datum/atom_skin/crusher_skin/dagger/apply(atom/apply_to)
	. = ..()
	RegisterSignal(apply_to, COMSIG_ITEM_ATTACK_ANIMATION, PROC_REF(on_attack_animation))
	RegisterSignal(apply_to, COMSIG_CRUSHER_FIRED_BLAST, PROC_REF(on_fired_blast))

/datum/atom_skin/crusher_skin/dagger/clear_skin(atom/clear_from)
	. = ..()
	UnregisterSignal(clear_from, COMSIG_ITEM_ATTACK_ANIMATION)
	UnregisterSignal(clear_from, COMSIG_CRUSHER_FIRED_BLAST)

/datum/atom_skin/crusher_skin/dagger/proc/on_attack_animation(obj/item/kinetic_crusher/source, atom/movable/attacker, atom/attacked_atom, animation_type, list/image_override, list/animation_override, list/angle_override)
	SIGNAL_HANDLER

	// If we've been forcefully assigned an animation type already, we shouldn't do the custom attack animation logic
	if (animation_type)
		return

	if (isliving(attacked_atom))
		var/mob/living/target = attacked_atom
		if (source.last_projectile_pb)
			image_override += image(icon = 'icons/obj/mining.dmi', icon_state = "crusher_dagger_blaster")
			angle_override += 0
			animation_override += ATTACK_ANIMATION_PIERCE
			source.last_projectile_pb = FALSE
			return

		if (target.has_status_effect(/datum/status_effect/crusher_mark))
			animation_override += ATTACK_ANIMATION_PIERCE

	image_override += image(icon = 'icons/obj/mining.dmi', icon_state = "crusher_dagger_melee")

/datum/atom_skin/crusher_skin/dagger/proc/on_fired_blast(obj/item/kinetic_crusher/source, atom/target, mob/living/user, obj/projectile/destabilizer/destabilizer)
	SIGNAL_HANDLER

	if (isliving(target) && get_dist(target, user) <= 1)
		user.do_item_attack_animation(target, used_item = source)

/datum/atom_skin/crusher_skin/glaive
	new_name = "proto-kinetic glaive"
	preview_name = "Glaive"
	new_icon_state = "crusher_glaive"
	new_inhand_icon = "crusher_glaive"
	new_lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	new_righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	new_inhandx = 64
	new_inhandy = 64

// Locked skins that cannot be selected normally
/datum/atom_skin/crusher_skin/locked
	abstract_type = /datum/atom_skin/crusher_skin/locked

/datum/atom_skin/crusher_skin/locked/ashen_skull
	preview_name = "Skull"
	new_icon_state = "crusher_skull"
	new_inhand_icon = "crusher_skull"
	new_projectile_icon_state = "pulse_skull"

/// Unlockable (or forced) skins
/obj/item/crusher_trophy/retool_kit
	name = "crusher retool kit"
	desc = "A toolkit for changing the crusher's appearance without affecting the device's function."
	icon = 'icons/obj/mining.dmi'
	icon_state = "retool_kit"
	denied_type = /obj/item/crusher_trophy/retool_kit

	/// What skin do we apply when attached
	var/datum/atom_skin/crusher_skin/forced_skin

/obj/item/crusher_trophy/retool_kit/effect_desc()
	return "the crusher to have the appearance of \a [forced_skin::preview_name]"

/obj/item/crusher_trophy/retool_kit/add_to(obj/item/kinetic_crusher/pkc, mob/user)
	. = ..()
	if(!.)
		return

	pkc.update_reskin(forced_skin)

/obj/item/crusher_trophy/retool_kit/remove_from(obj/item/kinetic_crusher/pkc)
	pkc.update_reskin(null) // resets reskin component
	return ..()

/obj/item/crusher_trophy/retool_kit/ashenskull
	name = "ashen skull"
	desc = "It burns with the flame of the necropolis, whispering in your ear. It demands to be bound to a suitable weapon."
	icon_state = "retool_kit_skull"
	forced_skin = /datum/atom_skin/crusher_skin/locked/ashen_skull

/obj/item/crusher_trophy/retool_kit/ashenskull/effect_desc()
	return "the crusher to appear corrupted by infernal powers"
