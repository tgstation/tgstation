//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "brown cloak"
	desc = "It's a cape that can be worn around your neck."
	icon = 'icons/obj/clothing/cloaks.dmi'
	icon_state = "qmcloak"
	inhand_icon_state = "qmcloak"
	atom_size = ITEM_SIZE_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cloak/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/obj/item/clothing/neck/cloak/hos
	name = "head of security's cloak"
	desc = "Worn by Securistan, ruling the station with an iron fist."
	icon_state = "hoscloak"

/obj/item/clothing/neck/cloak/qm
	name = "quartermaster's cloak"
	desc = "Worn by Cargonia, supplying the station with the necessary tools for survival."

/obj/item/clothing/neck/cloak/cmo
	name = "chief medical officer's cloak"
	desc = "Worn by Meditopia, the valiant men and women keeping pestilence at bay."
	icon_state = "cmocloak"

/obj/item/clothing/neck/cloak/ce
	name = "chief engineer's cloak"
	desc = "Worn by Engitopia, wielders of an unlimited power."
	icon_state = "cecloak"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/neck/cloak/rd
	name = "research director's cloak"
	desc = "Worn by Sciencia, thaumaturges and researchers of the universe."
	icon_state = "rdcloak"

/obj/item/clothing/neck/cloak/cap
	name = "captain's cloak"
	desc = "Worn by the commander of Space Station 13."
	icon_state = "capcloak"

/obj/item/clothing/neck/cloak/hop
	name = "head of personnel's cloak"
	desc = "Worn by the Head of Personnel. It smells faintly of bureaucracy."
	icon_state = "hopcloak"

/obj/item/clothing/suit/hooded/cloak/goliath
	name = "goliath cloak"
	icon_state = "goliath_cloak"
	desc = "A staunch, practical cape made out of numerous monster materials, it is coveted amongst exiles & hermits."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/pickaxe, /obj/item/spear, /obj/item/organ/regenerative_core/legion, /obj/item/knife/combat/bone, /obj/item/knife/combat/survival)
	armor = list(MELEE = 35, BULLET = 10, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, FIRE = 60, ACID = 60) //a fair alternative to bone armor, requiring alternative materials and gaining a suit slot
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath
	body_parts_covered = CHEST|GROIN|ARMS

/obj/item/clothing/head/hooded/cloakhood/goliath
	name = "goliath cloak hood"
	icon_state = "golhood"
	desc = "A protective & concealing hood."
	armor = list(MELEE = 35, BULLET = 10, LASER = 25, ENERGY = 35, BOMB = 25, BIO = 0, FIRE = 60, ACID = 60)
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	transparent_protection = HIDEMASK

/obj/item/clothing/suit/hooded/cloak/drake
	name = "drake armour"
	icon_state = "dragon"
	desc = "A suit of armour fashioned from the remains of an ash drake."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list(MELEE = 65, BULLET = 15, LASER = 40, ENERGY = 40, BOMB = 70, BIO = 60, FIRE = 100, ACID = 100)
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/drake
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/head/hooded/cloakhood/drake
	name = "drake helm"
	icon_state = "dragon"
	desc = "The skull of a dragon."
	armor = list(MELEE = 65, BULLET = 15, LASER = 40, ENERGY = 40, BOMB = 70, BIO = 60, FIRE = 100, ACID = 100)
	clothing_flags = SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/hooded/cloak/godslayer
	name = "godslayer armour"
	icon_state = "godslayer"
	desc = "A suit of armour fashioned from the remnants of a knight's armor, and parts of a wendigo."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/spear)
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 50, FIRE = 100, ACID = 100)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/godslayer
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	transparent_protection = HIDEGLOVES|HIDESUITSTORAGE|HIDEJUMPSUIT|HIDESHOES
	/// Amount to heal when the effect is triggered
	var/heal_amount = 500
	/// Time until the effect can take place again
	var/effect_cooldown_time = 10 MINUTES
	/// Current cooldown for the effect
	COOLDOWN_DECLARE(effect_cooldown)
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/clothing/head/hooded/cloakhood/godslayer
	name = "godslayer helm"
	icon_state = "godslayer"
	desc = "The horns and skull of a wendigo, held together by the remaining icey energy of a demonic miner."
	armor = list(MELEE = 50, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 50, FIRE = 100, ACID = 100)
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL | SNUG_FIT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	flash_protect = FLASH_PROTECTION_WELDER
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	resistance_flags = FIRE_PROOF | ACID_PROOF | FREEZE_PROOF

/obj/item/clothing/suit/hooded/cloak/godslayer/examine(mob/user)
	. = ..()
	if(loc == user && !COOLDOWN_FINISHED(src, effect_cooldown))
		. += "You feel like the revival effect will be able to occur again in [COOLDOWN_TIMELEFT(src, effect_cooldown) / 10] seconds."

/obj/item/clothing/suit/hooded/cloak/godslayer/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOB_STATCHANGE, .proc/resurrect)
		return
	UnregisterSignal(user, COMSIG_MOB_STATCHANGE)

/obj/item/clothing/suit/hooded/cloak/godslayer/dropped(mob/user)
	..()
	UnregisterSignal(user, COMSIG_MOB_STATCHANGE)

/obj/item/clothing/suit/hooded/cloak/godslayer/proc/resurrect(mob/living/carbon/user, new_stat)
	SIGNAL_HANDLER
	if(new_stat > CONSCIOUS && new_stat < DEAD && COOLDOWN_FINISHED(src, effect_cooldown))
		COOLDOWN_START(src, effect_cooldown, effect_cooldown_time) //This needs to happen first, otherwise there's an infinite loop
		user.heal_ordered_damage(heal_amount, damage_heal_order)
		user.visible_message(span_notice("[user] suddenly revives, as their armor swirls with demonic energy!"), span_notice("You suddenly feel invigorated!"))
		playsound(user.loc, 'sound/magic/clockwork/ratvar_attack.ogg', 50)

/obj/item/clothing/neck/cloak/skill_reward
	var/associated_skill_path = /datum/skill
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE

/obj/item/clothing/neck/cloak/skill_reward/examine(mob/user)
	. = ..()
	. += span_notice("You notice a powerful aura about this cloak, suggesting that only the truly experienced may wield it.")

/obj/item/clothing/neck/cloak/skill_reward/proc/check_wearable(mob/user)
	return user.mind?.get_skill_level(associated_skill_path) < SKILL_LEVEL_LEGENDARY

/obj/item/clothing/neck/cloak/skill_reward/proc/unworthy_unequip(mob/user)
	to_chat(user, span_warning("You feel completely and utterly unworthy to even touch \the [src]."))
	var/hand_index = user.get_held_index_of_item(src)
	if (hand_index)
		user.dropItemToGround(src, TRUE)
	return FALSE

/obj/item/clothing/neck/cloak/skill_reward/equipped(mob/user, slot)
	if (check_wearable(user))
		unworthy_unequip(user)
	return ..()

/obj/item/clothing/neck/cloak/skill_reward/attack_hand(mob/user, list/modifiers)
	if (check_wearable(user))
		unworthy_unequip(user)
	return ..()

/obj/item/clothing/neck/cloak/skill_reward/gaming
	name = "legendary gamer's cloak"
	desc = "Worn by the most skilled professional gamers on the station, this legendary cloak is only attainable by achieving true gaming enlightenment. This status symbol represents the awesome might of a being of focus, commitment, and sheer fucking will. Something casual gamers will never begin to understand."
	icon_state = "gamercloak"
	associated_skill_path = /datum/skill/gaming

/obj/item/clothing/neck/cloak/skill_reward/cleaning
	name = "legendary cleaner's cloak"
	desc = "Worn by the most skilled custodians, this legendary cloak is only attainable by achieving janitorial enlightenment. This status symbol represents a being not only extensively trained in grime combat, but one who is willing to use an entire aresenal of cleaning supplies to its full extent to wipe grime's miserable ass off the face of the station."
	icon_state = "cleanercloak"
	associated_skill_path = /datum/skill/cleaning

/obj/item/clothing/neck/cloak/skill_reward/mining
	name = "legendary miner's cloak"
	desc = "Worn by the most skilled miners, this legendary cloak is only attainable by achieving true mineral enlightenment. This status symbol represents a being who has forgotten more about rocks than most miners will ever know, a being who has moved mountains and filled valleys."
	icon_state = "minercloak"
	associated_skill_path = /datum/skill/mining

/obj/item/clothing/neck/cloak/skill_reward/playing
	name = "legendary veteran's cloak"
	desc = "Worn by the wisest of veteran employees, this legendary cloak is only attainable by maintaining a living employment agreement with Nanotrasen for over <b>five thousand hours</b>. This status symbol represents a being is better than you in nearly every quantifiable way, simple as that."
	icon_state = "playercloak"

/obj/item/clothing/neck/cloak/skill_reward/playing/check_wearable(mob/user)
	return user.client?.is_veteran()
