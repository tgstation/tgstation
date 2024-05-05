/obj/item/melee/trick_weapon
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	lefthand_file = 'monkestation/icons/bloodsuckers/weapons_lefthand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/weapons_righthand.dmi'
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///upgrade level of the weapon
	var/upgrade_level = 0
	///base force when transformed
	var/on_force
	///base force when in default state
	var/base_force
	///default name of the weapon
	var/base_name
	///is the weapon in its transformed state?
	var/enabled = FALSE
	///wounding chance while on
	var/on_wound_bonus

/obj/item/melee/trick_weapon/proc/upgrade_weapon()
	SIGNAL_HANDLER
	upgrade_level++
	force = upgraded_val(base_force,upgrade_level)
	var/datum/component/transforming/transform = GetComponent(/datum/component/transforming)
	transform.force_on = upgraded_val(on_force,upgrade_level)

/obj/item/melee/trick_weapon/attack(mob/target, mob/living/user, params) //our weapon does 25% less damage on non monsters
	var/old_force = force
	if(!is_monster_hunter_prey(target))
		force = round(force * 0.75)
	. = ..()
	force = old_force
