/obj/item/melee/sword
	name = "broadsword"
	desc = "A sharp steel forged sword. It's fine edge shines in the light."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "broadsword"
	inhand_icon_state = "broadsword"
	worn_icon_state = "broadsword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 20
	throwforce = 10
	wound_bonus = 5
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	block_chance = 30
	block_sound = 'sound/weapons/parry.ogg'
	sharpness = SHARP_EDGED
	max_integrity = 200
	armor_type = /datum/armor/item_claymore
	resistance_flags = FIRE_PROOF
	embedding = list("embed_chance" = 20, "impact_pain_mult" = 10) //It's a sword, thrown swords can stick into people.

/obj/item/melee/sword/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/butchering, \
		speed = 8 SECONDS, \
		effectiveness = 105, \
	)
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/melee/sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/melee/sword/gold
	name = "gilded broadsword"
	desc = "A sharp steel forged sword. It's got a rich guard and pommel. It's fine edge shines in the light."
	icon_state = "broadsword_gold"
	inhand_icon_state = "broadsword_gold"
	worn_icon_state = "broadsword_gold"

/obj/item/melee/sword/rust
	name = "rusty broadsword"
	desc = "A sharp steel forged sword. It's edge is rusty and corroded."
	icon_state = "broadsword_rust"
	worn_icon_state = "broadsword"
	force = 15
	wound_bonus = 0
	///Determines Icon State used by the item when it breaks.
	var/broken_icon_state = "broadsword_broken"
	///Determines Description used by the item when it breaks.
	var/broken_desc = "A sharp steel forged sword. Its edge is rusty, corroded and broken."

/obj/item/melee/sword/rust/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/durability, \
		broken_icon_state = broken_icon_state, \
		broken_desc = broken_desc, \
		max_durability = 20, \
		break_sound = 'sound/effects/structure_stress/pop3.ogg', \
		broken_force_decrease = 5, \
		broken_throw_force_decrease = 5, \
		broken_throw_range = 2, \
		broken_embedding = list("embed_chance" = 10, "impact_pain_mult" = 15), \
		broken_block_chance = 15, \
		broken_message = span_warning("The sword breaks."), \
		broken_w_class = WEIGHT_CLASS_SMALL \
	)

/obj/item/melee/sword/rust/gold
	name = "rusty gilded broadsword"
	desc = "A sharp steel forged sword. Its got a rich guard and pommel. Its edge is rusty and corroded."
	icon_state = "broadsword_gold_rust"
	inhand_icon_state = "broadsword_gold"
	worn_icon_state = "broadsword_gold"
	broken_icon_state = "broadsword_gold_broken"
	broken_desc = "A sharp steel forged sword. Its got a rich guard and pommel. Its edge is rusty, corroded and broken."

/obj/item/melee/sword/rust/claymore
	name = "rusty claymore"
	desc = "A rusted claymore, it smells damp and it has seen better days."
	icon_state = "claymore_rust"
	inhand_icon_state = "claymore"
	worn_icon_state = "claymore"
	broken_icon_state = "claymore_broken"
	broken_desc = "A rusted claymore, it smells damp, its edge broke and it has seen better days."

/obj/item/melee/sword/rust/claymoregold
	name = "rusty holy claymore"
	desc = "A weapon fit for a crusade... or it used to be..."
	icon_state = "claymore_gold_rust"
	inhand_icon_state = "claymore_gold"
	worn_icon_state = "claymore_gold"
	broken_icon_state = "claymore_gold_broken"
	broken_desc = "A weapon fit for a crusade... or it used to be... and its broken."

/obj/item/melee/sword/rust/cultblade
	name = "rusty dark blade"
	desc = "Once used by worshipers of forbidden gods, now its covered in old rust."
	icon_state = "cultblade_rust"
	inhand_icon_state = "cultblade_rust"
	broken_icon_state = "cultblade_broken"
	broken_desc = "Once used by worshipers of forbidden gods, now its broken and covered in old rust."

/obj/item/melee/sword/claymore
	name = "holy claymore"
	desc = "A weapon fit for a crusade! It lacks a holy shine however."
	force = 18
	icon_state = "claymore_gold"
	inhand_icon_state = "claymore_gold"
	worn_icon_state = "claymore_gold"

/obj/item/melee/sword/claymore/darkblade
	name = "dark blade"
	desc = "Spread the glory of the dark gods! Even if they don't bless this blade."
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64

/obj/item/melee/sword/reforged
	name = "Reforged longsword"
	desc = "A hard steel blade, it's edge has been forged to be incredibly strong. It feels light."
	icon_state = "reforged"
	inhand_icon_state = "reforged"
	worn_icon_state = "reforged"
	force = 25
	throwforce = 15
	throw_range = 6
	block_chance = 40
	wound_bonus = 5
	armour_penetration = 15
	embedding = list("embed_chance" = 30, "impact_pain_mult" = 10)

/obj/item/melee/sword/reforged/shitty

/obj/item/melee/sword/reforged/shitty/Initialize(mapload)
	. = ..()

	AddComponent( \
		/datum/component/durability, \
		broken_name = "broken fake longsword", \
		broken_icon_state = "reforged_broken", \
		broken_desc = "A cheap piece of felinid-forged trash.", \
		max_durability = 1, \
		break_sound = 'sound/effects/glassbr1.ogg', \
		broken_force_decrease = 20, \
		broken_throw_force_decrease = 10, \
		broken_throw_range = 1, \
		broken_embedding = list("embed_chance" = 5, "impact_pain_mult" = 5), \
		broken_block_chance = 5, \
		broken_message = span_warning("The sword breaks in a single motion. WHAT A PIECE OF SHIT!"), \
		broken_w_class = WEIGHT_CLASS_SMALL \
	)
