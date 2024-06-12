// Knife Template, should not appear in game normaly //
/obj/item/knife
	name = "knife"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	inhand_icon_state = "knife"
	worn_icon_state = "knife"
	desc = "The original knife, it is said that all other knives are only copies of this one."
	obj_flags = CONDUCTS_ELECTRICITY
	force = 10
	demolition_mod = 0.75
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6)
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	armor_type = /datum/armor/item_knife
	var/bayonet = FALSE //Can this be attached to a gun?
	wound_bonus = 5
	bare_wound_bonus = 15
	tool_behaviour = TOOL_KNIFE

/datum/armor/item_knife
	fire = 50
	acid = 50

/obj/item/knife/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/eyestab)
	set_butchering()

///Adds the butchering component, used to override stats for special cases
/obj/item/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS - force, \
	effectiveness = 100, \
	bonus_modifier = force - 10, \
	)
	//bonus chance increases depending on force

/obj/item/knife/suicide_act(mob/living/user)
	user.visible_message(pick(span_suicide("[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
		span_suicide("[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
		span_suicide("[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return BRUTELOSS

/obj/item/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "bone_blade"
	inhand_icon_state = "bone_blade"
	worn_icon_state = "bone_blade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	item_flags = CRUEL_IMPLEMENT //maybe they want to use it in surgery
	force = 15
	throwforce = 15
	wound_bonus = 20
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/knife/bloodletter
	name = "bloodletter"
	desc = "An occult looking dagger that is cold to the touch. Somehow, the flawless orb on the pommel is made entirely of liquid blood."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "bloodletter"
	worn_icon_state = "render"
	w_class = WEIGHT_CLASS_NORMAL
	/// Bleed stacks applied when an organic mob target is hit
	var/bleed_stacks_per_hit = 3

/obj/item/knife/bloodletter/afterattack(atom/target, mob/user, click_parameters)
	if(!isliving(target))
		return
	var/mob/living/M = target
	if(!(M.mob_biotypes & MOB_ORGANIC))
		return
	var/datum/status_effect/stacking/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
	if(!B)
		M.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, bleed_stacks_per_hit)
	else
		B.add_stacks(bleed_stacks_per_hit)

/obj/item/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	inhand_icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	obj_flags = CONDUCTS_ELECTRICITY
	force = 15
	throwforce = 10
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 6)
	attack_verb_continuous = list("slices", "dices", "chops", "cubes", "minces", "juliennes", "chiffonades", "batonnets")
	attack_verb_simple = list("slice", "dice", "chop", "cube", "mince", "julienne", "chiffonade", "batonnet")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = PAYCHECK_CREW * 5
	wound_bonus = 15

/obj/item/knife/hunting
	name = "hunting knife"
	icon = 'icons/obj/weapons/stabby.dmi'
	desc = "Despite its name, it's mainly used for cutting meat from dead prey rather than actual hunting."
	inhand_icon_state = "huntingknife"
	icon_state = "huntingknife"
	wound_bonus = 10

/obj/item/knife/hunting/set_butchering()
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS - force, \
	effectiveness = 100, \
	bonus_modifier = force + 10, \
	)

/obj/item/knife/combat
	name = "combat knife"
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "buckknife"
	worn_icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE)
	force = 20
	throwforce = 20
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "cut")
	bayonet = TRUE
	slot_flags = ITEM_SLOT_MASK

/obj/item/knife/combat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/knockoff, 90, list(BODY_ZONE_PRECISE_MOUTH), slot_flags) //90% to knock off when wearing a mask

/obj/item/knife/combat/dropped(mob/living/user, slot)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_MASK) == src && !user.has_status_effect(/datum/status_effect/choke) && prob(20))
		user.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		playsound(user, 'sound/weapons/slice.ogg', 50, TRUE)
		user.visible_message(span_danger("[user] accidentally cuts [user.p_them()]self while pulling [src] out of [user.p_them()] teeth! What a doofus!"), span_userdanger("You accidentally cut your mouth with [src]!"))

/obj/item/knife/combat/equipped(mob/living/user, slot, initial = FALSE)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(20))
		if(user.get_item_by_slot(ITEM_SLOT_MASK) == src)
			user.apply_status_effect(/datum/status_effect/choke, src)
			user.visible_message(span_danger("[user] accidentally swallows [src]!"))
			playsound(user, 'sound/items/eatfood.ogg', 100, TRUE)

/obj/item/knife/combat/survival
	name = "survival knife"
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "survivalknife"
	worn_icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/knife/combat/bone
	name = "bone dagger"
	inhand_icon_state = "bone_dagger"
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "bone_dagger"
	worn_icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10)
	obj_flags = parent_type::obj_flags & ~CONDUCTS_ELECTRICITY
	slot_flags = NONE
	force = 15
	throwforce = 15
	custom_materials = null

/obj/item/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife_cyborg"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."

/obj/item/knife/shiv
	name = "glass shiv"
	icon = 'icons/obj/weapons/stabby.dmi'
	icon_state = "shiv"
	inhand_icon_state = "shiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A makeshift glass shiv."
	obj_flags = parent_type::obj_flags & ~CONDUCTS_ELECTRICITY
	force = 8
	throwforce = 12
	attack_verb_continuous = list("shanks", "shivs")
	attack_verb_simple = list("shank", "shiv")
	armor_type = /datum/armor/none
	custom_materials = list(/datum/material/glass = SMALL_MATERIAL_AMOUNT * 4)

/obj/item/knife/shiv/plasma
	name = "plasma shiv"
	icon_state = "plasmashiv"
	inhand_icon_state = "plasmashiv"
	desc = "A makeshift plasma glass shiv."
	force = 9
	throwforce = 13
	armor_type = /datum/armor/shiv_plasma
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT *4, /datum/material/plasma=SMALL_MATERIAL_AMOUNT * 2)

/datum/armor/shiv_plasma
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 25
	fire = 50
	acid = 50

/obj/item/knife/shiv/titanium
	name = "titanium shiv"
	icon_state = "titaniumshiv"
	inhand_icon_state = "titaniumshiv"
	desc = "A makeshift titanium-infused glass shiv."
	throwforce = 14
	throw_range = 7
	wound_bonus = 10
	armor_type = /datum/armor/shiv_titanium
	custom_materials = list(/datum/material/glass=SMALL_MATERIAL_AMOUNT * 4, /datum/material/titanium=SMALL_MATERIAL_AMOUNT * 2)

/datum/armor/shiv_titanium
	melee = 25
	bullet = 25
	laser = 25
	energy = 25
	bomb = 25
	fire = 50
	acid = 50

/obj/item/knife/shiv/plastitanium
	name = "plastitanium shiv"
	icon_state = "plastitaniumshiv"
	inhand_icon_state = "plastitaniumshiv"
	desc = "A makeshift titanium-infused plasma glass shiv."
	force = 10
	throwforce = 15
	throw_speed = 4
	throw_range = 8
	wound_bonus = 10
	bare_wound_bonus = 20
	armor_type = /datum/armor/shiv_plastitanium
	custom_materials = list(/datum/material/glass= SMALL_MATERIAL_AMOUNT * 4, /datum/material/alloy/plastitanium= SMALL_MATERIAL_AMOUNT * 2)

/datum/armor/shiv_plastitanium
	melee = 50
	bullet = 50
	laser = 50
	energy = 50
	bomb = 50
	fire = 75
	acid = 75

/obj/item/knife/shiv/carrot
	name = "carrot shiv"
	icon_state = "carrotshiv"
	inhand_icon_state = "carrotshiv"
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	custom_materials = null

/obj/item/knife/shiv/carrot/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] forcefully drives \the [src] into [user.p_their()] eye! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS
