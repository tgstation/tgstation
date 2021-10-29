/obj/item/forging/reagent_weapon
	icon = 'modular_skyrat/modules/reagent_forging/icons/obj/forge_items.dmi'
	var/list/imbued_reagent = list()
	var/obj/item/reagent_containers/reagent_container
	var/has_imbued = FALSE

/obj/item/forging/reagent_weapon/Initialize()
	. = ..()
	create_reagents(500, INJECTABLE | REFILLABLE)
	reagent_container = new /obj/item/reagent_containers(src)

/obj/item/forging/reagent_weapon/Destroy()
	qdel(reagent_container)
	. = ..()

/obj/item/forging/reagent_weapon/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(isliving(target) && imbued_reagent)
		var/mob/living/living_mob = target
		if(!living_mob.can_inject(user, user.zone_selected))
			return
		for(var/reagent_list in imbued_reagent)
			reagent_container.reagents.add_reagent(reagent_list, 1)
			reagent_container.reagents.trans_to(target = living_mob, amount = 1, transfered_by = user, methods = INJECT)

/obj/item/forging/reagent_weapon/sword
	name = "reagent sword"
	desc = "A sword that can be imbued with a reagent."
	force = 20
	icon_state = "sword"
	inhand_icon_state = "sword"
	lefthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_r.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 10
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED

/obj/item/forging/reagent_weapon/staff
	name = "reagent staff"
	desc = "A staff that can be imbued with a reagent."
	force = 0
	icon_state = "staff"
	inhand_icon_state = "staff"
	lefthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_r.dmi'
	throwforce = 0
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("bonks", "bashes", "whacks", "pokes", "prods")
	attack_verb_simple = list("bonk", "bash", "whack", "poke", "prod")

/obj/item/forging/reagent_weapon/spear
	name = "reagent spear"
	desc = "A spear that can be imbued with a reagent."
	force = 8
	armour_penetration = 10
	icon_state = "spear"
	inhand_icon_state = "spear"
	lefthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'modular_skyrat/modules/reagent_forging/icons/mob/forge_weapon_r.dmi'
	throwforce = 0
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	wound_bonus = -15
	bare_wound_bonus = 15
	reach = 2

/obj/item/forging/reagent_weapon/spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=16)

