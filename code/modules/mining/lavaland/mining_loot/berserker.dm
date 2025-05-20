#define MAX_BERSERK_CHARGE 100
#define PROJECTILE_HIT_MULTIPLIER 1.5
#define DAMAGE_TO_CHARGE_SCALE 0.75
#define CHARGE_DRAINED_PER_SECOND 5
#define BERSERK_ATTACK_SPEED_MODIFIER 0.25

/obj/item/clothing/suit/hooded/berserker
	name = "berserker armor"
	desc = "This hulking armor seems to possess some kind of dark force within; howling in rage, hungry for carnage. \
		The self-sealing stem bolts that allowed this suit to be spaceworthy have long since corroded. However, the entity \
		sealed within the suit seems to hunger for the fleeting lifeforce found in the remains left in the remains of drakes. \
		Feeding it drake remains seems to empower a suit piece, though turns the remains back to lifeless ash."
	icon_state = "berserker"
	icon = 'icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'icons/mob/clothing/suits/armor.dmi'
	hoodtype = /obj/item/clothing/head/hooded/berserker
	armor_type = /datum/armor/hooded_berserker
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = THICKMATERIAL|HEADINTERNALS

/datum/armor/hooded_berserker
	melee = 30
	bullet = 30
	laser = 10
	energy = 20
	bomb = 50
	bio = 60
	fire = 100
	acid = 100
	wound = 10

/datum/armor/drake_empowerment
	melee = 35
	laser = 30
	energy = 20
	bomb = 20

/obj/item/clothing/suit/hooded/berserker/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, ALL, inventory_flags = ITEM_SLOT_OCLOTHING)
	AddComponent(/datum/component/armor_plate, maxamount = 1, upgrade_item = /obj/item/drake_remains, armor_mod = /datum/armor/drake_empowerment, upgrade_prefix = "empowered")
	allowed = GLOB.mining_suit_allowed

/obj/item/clothing/head/hooded/berserker
	name = "berserker helmet"
	desc = "This burdensome helmet seems to possess some kind of dark force within; howling in rage, hungry for carnage. \
		The self-sealing stem bolts that allowed this helmet to be spaceworthy have long since corroded. However, the entity \
		sealed within the suit seems to hunger for the fleeting lifeforce found in the remains left in the remains of drakes. \
		Feeding it drake remains seems to empower a suit piece, though turns the remains back to lifeless ash."
	icon_state = "berserker"
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	armor_type = /datum/armor/hooded_berserker
	actions_types = list(/datum/action/item_action/berserk_mode)
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_flags = SNUG_FIT|THICKMATERIAL
	/// Current charge of berserk, goes from 0 to 100
	var/berserk_charge = 0
	/// Status of berserk
	var/berserk_active = FALSE

/obj/item/clothing/head/hooded/berserker/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)
	AddComponent(/datum/component/armor_plate, maxamount = 1, upgrade_item = /obj/item/drake_remains, armor_mod = /datum/armor/drake_empowerment, upgrade_prefix = "empowered")
	AddComponent(/datum/component/item_equipped_movement_rustle, SFX_PLATE_ARMOR_RUSTLE, 8)

/obj/item/clothing/head/hooded/berserker/examine()
	. = ..()
	. += span_notice("Berserk mode is [berserk_charge]% charged.")

/obj/item/clothing/head/hooded/berserker/process(seconds_per_tick)
	if(berserk_active)
		berserk_charge = clamp(berserk_charge - CHARGE_DRAINED_PER_SECOND * seconds_per_tick, 0, MAX_BERSERK_CHARGE)

	if(!berserk_charge)
		if(ishuman(loc))
			end_berserk(loc)

/obj/item/clothing/head/hooded/berserker/dropped(mob/user)
	. = ..()
	end_berserk(user)

/obj/item/clothing/head/hooded/berserker/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, damage_type = BRUTE)
	if(berserk_active)
		return
	var/berserk_value = damage * DAMAGE_TO_CHARGE_SCALE
	if(attack_type == PROJECTILE_ATTACK)
		berserk_value *= PROJECTILE_HIT_MULTIPLIER
	berserk_charge = clamp(round(berserk_charge + berserk_value), 0, MAX_BERSERK_CHARGE)
	if(berserk_charge >= MAX_BERSERK_CHARGE)
		var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
		to_chat(owner, span_cult_large("Berserk mode is fully charged."))
		balloon_alert(owner, "berserk charged")
		ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)

/obj/item/clothing/head/hooded/berserker/IsReflect()
	return berserk_active

/// Starts berserk, reducing incoming brute by 50%, doubled attacking speed, NOGUNS trait, adding a color and giving them the berserk movespeed modifier
/obj/item/clothing/head/hooded/berserker/proc/berserk_mode(mob/living/carbon/human/user)
	var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
	to_chat(user, span_cult("You enter berserk mode."))
	playsound(user, 'sound/effects/magic/staff_healing.ogg', 50)
	user.add_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.brute_mod *= 0.5
	user.next_move_modifier *= BERSERK_ATTACK_SPEED_MODIFIER
	user.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
	user.add_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), BERSERK_TRAIT)
	ADD_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	berserk_active = TRUE
	START_PROCESSING(SSobj, src)
	ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)

/// Ends berserk, reverting the changes from the proc [berserk_mode]
/obj/item/clothing/head/hooded/berserker/proc/end_berserk(mob/living/carbon/human/user)
	if(!berserk_active)
		return
	berserk_active = FALSE
	if(QDELETED(user))
		return
	var/datum/action/item_action/berserk_mode/ragemode = locate() in actions
	ragemode?.build_all_button_icons(UPDATE_BUTTON_STATUS)
	to_chat(user, span_cult("You exit berserk mode."))
	playsound(user, 'sound/effects/magic/summonitems_generic.ogg', 50)
	user.remove_movespeed_modifier(/datum/movespeed_modifier/berserk)
	user.physiology.brute_mod *= 2
	user.next_move_modifier /= BERSERK_ATTACK_SPEED_MODIFIER
	user.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED)
	user.remove_traits(list(TRAIT_NOGUNS, TRAIT_TOSS_GUN_HARD), BERSERK_TRAIT)
	REMOVE_TRAIT(src, TRAIT_NODROP, BERSERK_TRAIT)
	STOP_PROCESSING(SSobj, src)

#undef MAX_BERSERK_CHARGE
#undef PROJECTILE_HIT_MULTIPLIER
#undef DAMAGE_TO_CHARGE_SCALE
#undef CHARGE_DRAINED_PER_SECOND
#undef BERSERK_ATTACK_SPEED_MODIFIER

