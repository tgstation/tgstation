/obj/item/clothing/suit/space/hardsuit/berserker
	name = "berserker hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane."
	icon_state = "hardsuit-berserker"
	inhand_icon_state = "hardsuit-berserker"
	slowdown = 0
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/berserker
	armor = list(MELEE = 30, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 10, FIRE = 100, ACID = 100)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/organ/regenerative_core/legion, /obj/item/kitchen/knife, /obj/item/kinetic_crusher, /obj/item/resonator, /obj/item/melee/transforming/cleaving_saw)


/obj/item/clothing/suit/space/hardsuit/berserker/Initialize()
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, TRUE, ITEM_SLOT_OCLOTHING)

/obj/item/clothing/suit/space/hardsuit/berserker/RemoveHelmet()
	var/obj/item/clothing/head/helmet/space/hardsuit/berserker/helm = helmet
	if(helm?.berserk_active)
		return
	return ..()

#define MAX_BERSERK_CHARGE 100
#define PROJECTILE_HIT_MULTIPLIER 1.5
#define DAMAGE_TO_CHARGE_SCALE 0.25
#define CHARGE_DRAINED_PER_SECOND 5
#define BERSERK_MELEE_ARMOR_ADDED 50
#define BERSERK_ATTACK_SPEED_MODIFIER 0.25

/obj/item/clothing/head/helmet/space/hardsuit/berserker
	name = "berserker helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-berserker"
	inhand_icon_state = "hardsuit0-berserker"
	hardsuit_type = "berserker"
	armor = list(MELEE = 30, BULLET = 10, LASER = 10, ENERGY = 20, BOMB = 50, BIO = 100, RAD = 10, FIRE = 100, ACID = 100)
	actions_types = list(/datum/action/item_action/berserk_mode)
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	/// Current charge of berserk, goes from 0 to 100
	var/berserk_charge = 0
	/// Status of berserk
	var/berserk_active = FALSE

/obj/item/clothing/head/helmet/space/hardsuit/berserker/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/head/helmet/space/hardsuit/berserker/examine()
	. = ..()
	. += span_notice("Berserk mode is [berserk_charge]% charged.")

/obj/item/clothing/head/helmet/space/hardsuit/berserker/process(delta_time)
	. = ..()
	if(berserk_active)
		berserk_charge = clamp(berserk_charge - CHARGE_DRAINED_PER_SECOND * delta_time, 0, MAX_BERSERK_CHARGE)
	if(!berserk_charge)
		if(ishuman(loc))
			end_berserk(loc)

/obj/item/clothing/head/helmet/space/hardsuit/berserker/dropped(mob/user)
	. = ..()
	end_berserk(user)

/obj/item/clothing/head/helmet/space/hardsuit/berserker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(berserk_active)
		return
	var/berserk_value = damage * DAMAGE_TO_CHARGE_SCALE
	if(attack_type == PROJECTILE_ATTACK)
		berserk_value *= PROJECTILE_HIT_MULTIPLIER
	berserk_charge = clamp(round(berserk_charge + berserk_value), 0, MAX_BERSERK_CHARGE)
	if(berserk_charge >= MAX_BERSERK_CHARGE)
		to_chat(owner, span_notice("Berserk mode is fully charged."))

/// Starts berserk, giving the wearer 50 melee armor, doubled attacking speed, NOGUNS trait, adding a color and giving them the berserk movespeed modifier
/obj/item/clothing/head/helmet/space/hardsuit/berserker/proc/berserk_mode(mob/living/carbon/human/user)
	to_chat(user, span_warning("You enter berserk mode."))
	playsound(user, 'sound/magic/staff_healing.ogg', 50)
	user.add_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.armor.melee += BERSERK_MELEE_ARMOR_ADDED
	user.next_move_modifier *= BERSERK_ATTACK_SPEED_MODIFIER
	user.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
	ADD_TRAIT(user, TRAIT_NOGUNS, BERSERK_TRAIT)
	ADD_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	berserk_active = TRUE

/// Ends berserk, reverting the changes from the proc [berserk_mode]
/obj/item/clothing/head/helmet/space/hardsuit/berserker/proc/end_berserk(mob/living/carbon/human/user)
	if(!berserk_active)
		return
	to_chat(user, span_warning("You exit berserk mode."))
	playsound(user, 'sound/magic/summonitems_generic.ogg', 50)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.armor.melee -= BERSERK_MELEE_ARMOR_ADDED
	user.next_move_modifier /= BERSERK_ATTACK_SPEED_MODIFIER
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED)
	REMOVE_TRAIT(user, TRAIT_NOGUNS, BERSERK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	berserk_active = FALSE

#undef MAX_BERSERK_CHARGE
#undef PROJECTILE_HIT_MULTIPLIER
#undef DAMAGE_TO_CHARGE_SCALE
#undef CHARGE_DRAINED_PER_SECOND
#undef BERSERK_MELEE_ARMOR_ADDED
#undef BERSERK_ATTACK_SPEED_MODIFIER
