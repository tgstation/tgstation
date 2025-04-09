/obj/item/forging/reagent_weapon
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_items.dmi'
	lefthand_file = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_r.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_worn.dmi'
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	obj_flags = UNIQUE_RENAME
	obj_flags_doppler = ANVIL_REPAIR
	toolspeed = 0.9 //Slightly better than avg. - A forged hammer or knife is probably better than a standard one

/obj/item/forging/reagent_weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_weapon)

/obj/item/forging/reagent_weapon/examine(mob/user)
	. = ..()
	. += span_notice("Using a hammer on [src] will repair its damage!")

//vanilla sword with no quirks, at least it's good versus other melees :)
/obj/item/forging/reagent_weapon/sword
	name = "forged sword"
	desc = "A sharp, one-handed sword most adept at blocking opposing melee strikes."
	force = 20
	armour_penetration = 10
	icon_state = "sword"
	inhand_icon_state = "sword"
	worn_icon_state = "sword_back"
	inside_belt_icon_state = "sword_belt"
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	throwforce = 10
	block_chance = 25
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	max_integrity = 150

//katana, one which shall cut through your puny armour
/obj/item/forging/reagent_weapon/katana
	name = "forged katana"
	desc = "A katana sharp enough to penetrate body armor, but not quite million-times-folded sharp."
	force = 20
	armour_penetration = 25
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana_back"
	inside_belt_icon_state = "katana_belt"
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	throwforce = 10
	block_chance = 20
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED

//quirky knife that lets you click fast
/obj/item/forging/reagent_weapon/dagger
	name = "forged dagger"
	desc = "A lightweight dagger with an extremely quick swing!"
	force = 13
	icon_state = "dagger"
	inhand_icon_state = "dagger"
	worn_icon_state = "dagger_back"
	inside_belt_icon_state = "dagger_belt"
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	throw_speed = 4
	embed_type = /datum/embedding/forged_dagger
	throwforce = 15
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_KNIFE

/datum/embedding/forged_dagger
	embed_chance = 50
	fall_chance = 1
	pain_mult = 2

//what a cute gimmick
/obj/item/forging/reagent_weapon/dagger/attack(mob/living/M, mob/living/user, params)
	. = ..()
	user.changeNext_move(CLICK_CD_RANGE)

//this isnt a weapon...
/obj/item/forging/reagent_weapon/staff
	name = "forged staff"
	desc = "A staff most notably capable of being imbued with reagents, especially useful alongside its otherwise harmless nature."
	force = 0
	icon_state = "staff"
	inhand_icon_state = "staff"
	worn_icon_state = "staff_back"
	throwforce = 0
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("bonks", "bashes", "whacks", "pokes", "prods")
	attack_verb_simple = list("bonk", "bash", "whack", "poke", "prod")

//omg, two tile range! surely i wont lose a fight now...
/obj/item/forging/reagent_weapon/spear
	name = "forged spear"
	desc = "A long spear that can be wielded in two hands to boost damage at the cost of single-handed versatility."
	force = 13
	armour_penetration = 15
	icon_state = "spear"
	inhand_icon_state = "spear"
	worn_icon_state = "spear_back"
	throwforce = 22
	throw_speed = 4
	embed_data = /datum/embedding/forged_spear
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF
	hitsound = 'sound/items/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	wound_bonus = -15
	bare_wound_bonus = 15
	block_chance = 10
	sharpness = SHARP_EDGED

/datum/embedding/forged_spear
	embed_chance = 75
	fall_chance = 0
	pain_mult = 6

//this is 1:1 with the bonespear, lets use this as a 'balance anchor'. weapons that blatantly outclass this are powercrept.
/obj/item/forging/reagent_weapon/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 13, force_wielded = 23)

//throwing weapons, what a fun gimmick. lets make them actually worth using
/obj/item/forging/reagent_weapon/axe
	name = "forged axe"
	desc = "An axe especially balanced for throwing and embedding into fleshy targets. Nonetheless useful as a traditional melee tool."
	force = 13
	armour_penetration = 10
	icon_state = "axe"
	inhand_icon_state = "axe"
	worn_icon_state = "axe_back"
	throwforce = 18
	throw_speed = 4
	embed_type = /datum/embedding/forged_axe
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("slashes", "bashes")
	attack_verb_simple = list("slash", "bash")
	sharpness = SHARP_EDGED

/datum/embedding/forged_axe
	embed_chance = 65
	fall_chance = 10
	pain_mult = 4

//Boring option for doing the most raw damage
/obj/item/forging/reagent_weapon/hammer
	name = "forged hammer"
	desc = "A heavy, weighted hammer that packs an incredible punch but can prove to be unwieldy. Useful for forging!"
	force = 24 //Requires wielding
	armour_penetration = 10
	icon_state = "crush_hammer"
	inhand_icon_state = "crush_hammer"
	worn_icon_state = "hammer_back"
	throwforce = 10
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("bashes", "whacks")
	attack_verb_simple = list("bash", "whack")
	tool_behaviour = TOOL_HAMMER
	///the list of things that, if attacked, will set the attack speed to rapid
	var/static/list/fast_attacks = list(
		/obj/structure/reagent_anvil,
		/obj/structure/reagent_crafting_bench
	)

/obj/item/forging/reagent_weapon/hammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 24, force_wielded = 24, require_twohands = TRUE)
	AddElement(/datum/element/kneejerk)

/obj/item/forging/reagent_weapon/hammer/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()
	if(!is_type_in_list(attacked_atom, fast_attacks))
		return
	user.changeNext_move(CLICK_CD_RAPID)

/obj/item/shield/buckler/reagent_weapon
	name = "forged buckler shield"
	desc = "A small, round shield best used in tandem with a melee weapon in close-quarters combat."
	icon = 'modular_doppler/reagent_forging/icons/obj/forge_items.dmi'
	worn_icon = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_worn.dmi'
	icon_state = "buckler"
	inhand_icon_state = "buckler"
	worn_icon_state = "buckler_back"
	lefthand_file = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_l.dmi'
	righthand_file = 'modular_doppler/reagent_forging/icons/mob/forge_weapon_r.dmi'
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT)
	resistance_flags = FIRE_PROOF
	block_chance = 30
	transparent = FALSE
	max_integrity = 150 //over double that of a wooden one
	w_class = WEIGHT_CLASS_NORMAL
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_AFFECT_STATISTICS
	obj_flags_doppler = ANVIL_REPAIR
	shield_break_sound = 'sound/effects/bang.ogg'
	shield_break_leftover = /obj/item/forging/complete/plate

/obj/item/shield/buckler/reagent_weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_weapon)

/obj/item/shield/buckler/reagent_weapon/examine(mob/user)
	. = ..()
	. += span_notice("Using a hammer on [src] will repair its damage!")

/obj/item/shield/buckler/reagent_weapon/attackby(obj/item/attacking_item, mob/user, params)
	if(atom_integrity >= max_integrity)
		return ..()
	if(istype(attacking_item, /obj/item/forging/hammer))
		var/obj/item/forging/hammer/attacking_hammer = attacking_item
		var/skill_modifier = user.mind.get_skill_modifier(/datum/skill/smithing, SKILL_SPEED_MODIFIER) * attacking_hammer.toolspeed
		while(atom_integrity < max_integrity)
			if(!do_after(user, skill_modifier SECONDS, src))
				return
			var/fixing_amount = min(max_integrity - atom_integrity, 5)
			atom_integrity += fixing_amount
			user.mind.adjust_experience(/datum/skill/smithing, 5) //useful heating means you get some experience
			balloon_alert(user, "partially repaired!")
		return
	return ..()

/obj/item/shield/buckler/reagent_weapon/pavise //similar to the adamantine shield. Huge, slow, lets you soak damage and packs a wallop.
	name = "forged pavise shield"
	desc = "An oblong shield used by ancient crossbowmen as cover while reloading. Probably just as useful with an actual gun."
	icon_state = "pavise"
	inhand_icon_state = "pavise"
	worn_icon_state = "pavise_back"
	block_chance = 75
	item_flags = SLOWS_WHILE_IN_HAND
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	max_integrity = 300 //tanky

/obj/item/shield/buckler/reagent_weapon/pavise/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_wielded = 15)

/obj/item/pickaxe/reagent_weapon
	name = "forged pickaxe"

/obj/item/pickaxe/reagent_weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_weapon)

/obj/item/shovel/reagent_weapon
	name = "forged shovel"

/obj/item/shovel/reagent_weapon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reagent_weapon)

/obj/item/ammo_casing/arrow/attackby(obj/item/attacking_item, mob/user, params)
	var/spawned_item
	if(istype(attacking_item, /obj/item/stack/sheet/sinew))
		spawned_item = /obj/item/ammo_casing/arrow/ash

	if(istype(attacking_item, /obj/item/stack/sheet/bone))
		spawned_item = /obj/item/ammo_casing/arrow/bone

	if(istype(attacking_item, /obj/item/stack/tile/bronze))
		spawned_item = /obj/item/ammo_casing/arrow/bronze

	if(!spawned_item)
		return ..()

	var/obj/item/stack/stack_item = attacking_item
	if(!stack_item.use(1))
		return

	var/obj/item/ammo_casing/arrow/converted_arrow = new spawned_item(get_turf(src))
	transfer_fingerprints_to(converted_arrow)
	remove_item_from_storage(user)
	user.put_in_hands(converted_arrow)
	qdel(src)

#define INCREASE_BLOCK_CHANCE 2

/obj/item/forging/reagent_weapon/bokken
	name = "bokken"
	desc = "A bokken that is capable of blocking attacks when wielding in two hands, possibly including bullets should the user be brave enough."
	force = 20
	icon_state = "bokken"
	inhand_icon_state = "bokken"
	worn_icon_state = "bokken_back"
	throwforce = 10
	block_chance = 20
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FIRE_PROOF
	attack_verb_continuous = list("bonks", "bashes", "whacks", "pokes", "prods")
	attack_verb_simple = list("bonk", "bash", "whack", "poke", "prod")
	///whether the bokken is being wielded or not
	var/wielded = FALSE

/obj/item/forging/reagent_weapon/bokken/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(wielded)
		final_block_chance *= INCREASE_BLOCK_CHANCE
	if(prob(final_block_chance))
		if(attack_type == PROJECTILE_ATTACK)
			owner.visible_message(span_danger("[owner] deflects [attack_text] with [src]!"))
			playsound(src, pick('sound/items/weapons/effects/ric1.ogg', 'sound/items/weapons/effects/ric2.ogg', 'sound/items/weapons/effects/ric3.ogg', 'sound/items/weapons/effects/ric4.ogg', 'sound/items/weapons/effects/ric5.ogg'), 100, TRUE)
		else
			playsound(src, 'sound/items/weapons/parry.ogg', 75, TRUE)
			owner.visible_message(span_danger("[owner] parries [attack_text] with [src]!"))
		var/owner_turf = get_turf(owner)
		new block_effect(owner_turf, COLOR_YELLOW)
		return TRUE
	return FALSE

#undef INCREASE_BLOCK_CHANCE

/obj/item/forging/reagent_weapon/bokken/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))
	AddComponent(/datum/component/two_handed, force_unwielded = 20, force_wielded = 10)

/obj/item/forging/reagent_weapon/bokken/proc/on_wield()
	SIGNAL_HANDLER
	wielded = TRUE

/obj/item/forging/reagent_weapon/bokken/proc/on_unwield()
	SIGNAL_HANDLER
	wielded = FALSE
