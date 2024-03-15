// fear the øx
// øx means axe for the uncultured



/obj/item/melee/viking
	icon = 'monkestation/icons/viking/viking_items.dmi'
	lefthand_file = 'monkestation/icons/viking/axes_lefthand.dmi'
	righthand_file = 'monkestation/icons/viking/axes_righthand.dmi'
	worn_icon = 'monkestation/icons/viking/viking_armor.dmi'

/obj/item/melee/viking/tenja
	name = "boarding axe"
	icon_state = "hand_axe"
	worn_icon_state = "hand_axe_worn"
	desc = "A one handed axe used by vikings."
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 20
	throwforce = 45
	embedding = 50
	wound_bonus = 25
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/melee/viking/godly_tenja
	name = "Leviathan Axe"
	icon_state = "hand_axe_frost"
	worn_icon_state = "hand_axe_frost_worn"
	desc = "An axe with no equal to its power."
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 25
	throwforce = 65
	embedding = 75
	sharpness = SHARP_EDGED
	wound_bonus = 30
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/melee/viking/godly_tenja/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/consumable/frostoil, 4)
		carbon_target.reagents.add_reagent(/datum/reagent/consumable/ice, 4)
		carbon_target.reagents.add_reagent(/datum/reagent/medicine/c2/hercuri, 4)
/obj/item/melee/viking/genja
	name = "battle axe"
	icon_state = "battleaxe0"
	base_icon_state = "battleaxe"
	worn_icon_state = "battle_axe_worn"
	desc = "A large 2 handed axe used for raiding."
	force = 15
	throwforce = 60
	embedding = 50
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = 30
	block_chance = 30
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
/// How much damage to do unwielded
	var/force_unwielded = 15
	/// How much damage to do wielded
	var/force_wielded = 30

/obj/item/melee/viking/genja/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")

/obj/item/melee/viking/genja/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()
/obj/item/melee/viking/skeggox
	name = "grappling axe"
	icon_state = "hooking_axe_item"
	lefthand_file = "hooking_axe_inhand_L"
	righthand_file = "hooking_axe_inhand_R"
	worn_icon_state = "hooking_axe_worn"
	desc = "An axe meant to disarm the users opponent."
	hitsound = 'sound/weapons/bladeslice.ogg'
	force = 18
	throwforce = 40
	embedding = 50
	sharpness = SHARP_EDGED
	wound_bonus = 20
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL


/obj/item/melee/viking/skeggox/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(ishuman(target) && proximity_flag)
		var/mob/living/carbon/human/human_target = target
		human_target.drop_all_held_items()
		human_target.visible_message(span_danger("[user] disarms [human_target]!"), span_userdanger("[user] disarmed you!"))
