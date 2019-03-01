/obj/item/melee/rubyfist
	name = "\improper Ruby Gauntlet"
	desc = "A powerful looking gauntlet used for punching things."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "disintegrate"
	item_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	attack_verb = list("punches", "boxes", "mashed")

/obj/item/melee/rubyfist/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/rubyfist
	name = "Summon Ruby Gauntlet"
	desc = "Link your mind with the energy of all existing matter, and Channel the collective power of the universe through your Gem."
	isclockcult = FALSE
	weapon_type = /obj/item/melee/rubyfist
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "summons"
	background_icon_state = "bg_spell"