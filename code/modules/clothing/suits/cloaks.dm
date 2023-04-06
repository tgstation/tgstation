//Cloaks. No, not THAT kind of cloak.

/obj/item/clothing/neck/cloak
	name = "brown cloak"
	desc = "It's a cape that can be worn around your neck."
	icon = 'icons/obj/clothing/cloaks.dmi'
	icon_state = "qmcloak"
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESUITSTORAGE

/obj/item/clothing/neck/cloak/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/surgery_initiator)

/obj/item/clothing/neck/cloak/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

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

/obj/item/clothing/neck/cloak/skill_reward
	var/associated_skill_path = /datum/skill
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE

/obj/item/clothing/neck/cloak/skill_reward/examine(mob/user)
	. = ..()
	. += span_notice("You notice a powerful aura about this cloak, suggesting that only the truly experienced may wield it.")

/obj/item/clothing/neck/cloak/skill_reward/proc/check_wearable(mob/user)
	return user.mind?.get_skill_level(associated_skill_path) >= SKILL_LEVEL_LEGENDARY

/obj/item/clothing/neck/cloak/skill_reward/proc/unworthy_unequip(mob/user)
	to_chat(user, span_warning("You feel completely and utterly unworthy to even touch \the [src]."))
	var/hand_index = user.get_held_index_of_item(src)
	if (hand_index)
		user.dropItemToGround(src, TRUE)
	return FALSE

/obj/item/clothing/neck/cloak/skill_reward/equipped(mob/user, slot)
	if (!check_wearable(user))
		unworthy_unequip(user)
	return ..()

/obj/item/clothing/neck/cloak/skill_reward/attack_hand(mob/user, list/modifiers)
	if (!check_wearable(user))
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
