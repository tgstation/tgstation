/obj/item/melee/rapier
	name = "officer's rapier"
	desc = "An elegant weapon, not dissimilar from the captain's own. its monomolecular edge is capable of cutting through flesh and bone with even more ease."
	icon = 'modular_frontier/modules/blueshield/icons/obj/items_and_weapons.dmi'
	icon_state = "rapier"
	inhand_icon_state = "rapier"
	lefthand_file = 'modular_frontier/modules/blueshield/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'modular_frontier/modules/blueshield/icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	force = 25 // as a representative of central command, you don't fuck around.
	throwforce = 10
	w_class = WEIGHT_CLASS_BULKY
	block_chance = 50
	armour_penetration = 75
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("slashes", "cuts")
	attack_verb_simple = list("slash", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	custom_materials = list(/datum/material/iron = 1000)
	wound_bonus = 10
	bare_wound_bonus = 25

/obj/item/melee/rapier/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 95, 5) //fast and effective, but as a sword, it might damage the results.

/obj/item/melee/rapier/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0 //Don't bring a sword to a gunfight
	return ..()

/obj/item/melee/rapier/on_exit_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/rapier/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/unsheath.ogg', 25, TRUE)

/obj/item/melee/rapier/on_enter_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/rapier/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/sheath.ogg', 25, TRUE)
