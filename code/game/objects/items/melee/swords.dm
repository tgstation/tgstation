/obj/item/melee/sword
	name = "broadsword"
	desc = "A sharp steel forged sword. It's fine edge shines in the light."
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "broadsword"
	inhand_icon_state = "broadsword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/bladeslice.ogg'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 20
	throwforce = 10
	wound_bonus = 10
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
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
	AddComponent(/datum/component/butchering, \
	speed = 4 SECONDS, \
	effectiveness = 105, \
	)

/obj/item/melee/sword/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is falling on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/melee/sword/gold
	name = "gilded broadsword"
	desc = "A sharp steel forged sword. It's got a rich guard and pommel. It's fine edge shines in the light."
	icon_state = "broadsword_gold"
	inhand_icon_state = "broadsword_gold"

/obj/item/melee/sword/rust
	name = "rusty broadsword"
	desc = "A sharp steel forged sword. It's edge is rusty and corroded."
	icon_state = "broadsword_rust"
	force = 15
	wound_bonus = 5
	var/broken_icon = "broadsword_broken"

	/// How many hits a sword can deal and block before it breaks.
	var/rustiness = 15
	/// If the sword is broken or not.
	var/broken = 0

/obj/item/melee/sword/rust/afterattack()
	. = ..()
	if(rustiness <= 0)
		return
	decrease_uses()

/obj/item/melee/sword/rust/proc/on_hit_reaction()
	. = ..()
	if(!.)
		return
	if(rustiness <= 0)
		return
	decrease_uses()

/obj/item/melee/sword/rust/proc/decrease_uses(mob/user)
	if(rustiness == 0)
		no_uses(user)
		return
	rustiness--

/obj/item/melee/sword/rust/proc/no_uses(mob/user)
	if(broken == TRUE)
		return
	to_chat(user, span_warning("[src]'s blade breaks leaving you with half a sword!"))
	broken = 1
	name = broken + name
	icon_state = broken_icon
	inhand_icon_state = broken_icon
	update_icon()
	force -= 5
	wound_bonus = 5
	throw_range = 2
	embedding = list("embed_chance" = 10, "impact_pain_mult" = 15)//jagged metal in wound heh
	block_chance = 20
	w_class = WEIGHT_CLASS_SMALL

/obj/item/melee/sword/rust/gold
	name = "rusty gilded broadsword"
	desc = "A sharp steel forged sword. It's got a rich guard and pommel. It's edge is rusty and corroded."
	icon_state = "broadsword_gold_rust"
	inhand_icon_state = "broadsword_gold"
	broken_icon = "broadswordgold_broken"

/obj/item/melee/sword/rust/claymore
	name = "rusty claymore"
	desc = "A rusted claymore, it smells damp and it has seen better days."
	icon_state = "claymore_rust"
	inhand_icon_state = "claymore"
	broken_icon = "claymore_broken"

/obj/item/melee/sword/rust/claymoregold
	name = "rusty holy claymore"
	desc = "A weapon fit for a crusade... or it used to be..."
	icon_state = "claymore_gold_rust"
	inhand_icon_state = "claymore_gold"
	broken_icon = "claymore_gold_broken"

/obj/item/melee/sword/rust/claymoregold
	name = "rusty dark blade"
	desc = "Once used by worshipers of forbidden gods, now its covered in old rust."
	icon_state = "cultblade_rust"
	inhand_icon_state = "cultblade_rust"
	broken_icon = "cultblade_broken"

/obj/item/melee/sword/reforged
	name = "Reforged longsword"
	desc = "A hard steel blade, it's edge has been forged to be incredibly strong. It feels light."
	icon_state = "reforged"
	inhand_icon_state = "reforged"
	force = 25
	throwforce = 15
	throw_range = 6
	block_chance = 40
	wound_bonus = 15
	armour_penetration = 15
	embedding = list("embed_chance" = 30, "impact_pain_mult" = 10)

/obj/item/melee/sword/reforged/shitty
	var/broken = 0
	var/rustiness = 1
	var/broken_icon = "reforged_broken"

/obj/item/melee/sword/reforged/shitty/afterattack()
	. = ..()
	if(rustiness <= 0)
		return
	decrease_uses()

/obj/item/melee/sword/reforged/shitty/proc/on_hit_reaction()
	. = ..()
	if(!.)
		return
	if(rustiness <= 0)
		return
	decrease_uses()

/obj/item/melee/sword/reforged/shitty/proc/decrease_uses(mob/user)
	if(rustiness == 0)
		no_uses(user)
		return
	rustiness--

/obj/item/melee/sword/reforged/shitty/proc/no_uses(mob/user)
	if(broken == TRUE)
		return
	to_chat(user, span_warning("[src]'s blade shatters! It was a cheap felinid imitation! WHAT A PIECE OF SHIT!"))
	broken = 1
	name = "broken fake longsword"
	desc = "A cheap piece of felinid forged trash."
	icon_state = broken_icon
	inhand_icon_state = broken_icon
	update_icon()
	force -= 20
	throwforce = 5
	throw_range = 1
	block_chance = 5
	wound_bonus = -10
	armour_penetration = 0
	embedding = list("embed_chance" = 5, "impact_pain_mult" = 5)
	w_class = WEIGHT_CLASS_SMALL
