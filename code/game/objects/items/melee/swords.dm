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
	/// Name used after the item breaks.
	var/broken_name = "broken rusty broadsword"
	/// Description used after the item breaks.
	var/broken_desc = "A sharp steel forged sword. It's edge is rusty, corroded and broken."
	/// Icon thats used for object, inhands and worn sprites when it breaks.
	var/broken_icon = "broadsword_broken"
	/// How many hits an item can deal and block before it breaks, with one additional final usage.
	var/durability = 15
	/// If the item is broken or not.
	var/broken = FALSE
	/// The message displayed when the item breaks.
	var/break_message_others = "'s sword snaps in half!"
	/// The message displayed when the item breaks.
	var/break_message_self = "'s blade breaks leaving you with half a sword!"
	/// Sound used when the item breaks.
	var/break_sound = 'sound/effects/structure_stress/pop3.ogg'
	/// How much damage the item loses after it breaks.
	var/damage_decrease = 5
	/// The new wound bonus after the item breaks.
	var/broken_wound = 1
	/// The throw range of the item after it breaks.
	var/broken_throw = 2
	/// The embedding of the item after it breaks.
	var/broken_embed_chance = 10
	/// The embedding of the item after it breaks.
	var/broken_embed_pain = 15
	/// The block chance of the item after it breaks.
	var/broken_block = 20
	/// The weight class of the item after it breaks
	var/broken_weight = WEIGHT_CLASS_SMALL

/obj/item/melee/sword/rust/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(broken)
		return
	if(ismovable(target))
		decrease_uses(user)

/obj/item/melee/sword/rust/hit_reaction(mob/user)
	. = ..()
	if(!.)
		return
	if(broken)
		return
	decrease_uses(user)

/obj/item/melee/sword/rust/proc/decrease_uses(mob/user)
	if(durability == 0)
		no_uses(user)
		return
	durability--

/obj/item/melee/sword/rust/proc/no_uses(mob/user)
	if(broken == TRUE)
		return
	user.visible_message(span_notice("[user][break_message_others]"), span_notice("[src][break_message_self]"))
	broken = TRUE
	name = broken_name
	desc = broken_desc
	icon_state = broken_icon
	inhand_icon_state = broken_icon
	worn_icon_state = broken_icon
	update_appearance()
	playsound(user, break_sound, 100, TRUE)
	force -= damage_decrease
	wound_bonus = broken_wound
	throw_range = broken_throw
	embedding = list("embed_chance" = broken_embed_chance, "impact_pain_mult" = broken_embed_pain)
	block_chance = broken_block
	w_class = broken_weight

/obj/item/melee/sword/rust/gold
	name = "rusty gilded broadsword"
	desc = "A sharp steel forged sword. It's got a rich guard and pommel. It's edge is rusty and corroded."
	icon_state = "broadsword_gold_rust"
	inhand_icon_state = "broadsword_gold"
	worn_icon_state = "broadsword_gold"
	broken_icon = "broadsword_gold_broken"
	broken_name = "broken rusty gilded broadsword"
	broken_desc = "A sharp steel forged sword. It's got a rich guard and pommel. It's edge is rusty, corroded and broken."

/obj/item/melee/sword/rust/claymore
	name = "rusty claymore"
	desc = "A rusted claymore, it smells damp and it has seen better days."
	icon_state = "claymore_rust"
	inhand_icon_state = "claymore"
	worn_icon_state = "claymore"
	broken_icon = "claymore_broken"
	broken_name = "broken rusty claymore"
	broken_desc = "A rusted claymore, it smells damp, its edge broke and it has seen better days."

/obj/item/melee/sword/rust/claymoregold
	name = "rusty holy claymore"
	desc = "A weapon fit for a crusade... or it used to be..."
	icon_state = "claymore_gold_rust"
	inhand_icon_state = "claymore_gold"
	worn_icon_state = "claymore_gold"
	broken_icon = "claymore_gold_broken"
	broken_name = "broken rusty holy claymore"
	broken_desc = "A weapon fit for a crusade... or it used to be... and its broken."

/obj/item/melee/sword/rust/cultblade
	name = "rusty dark blade"
	desc = "Once used by worshipers of forbidden gods, now its covered in old rust."
	icon_state = "cultblade_rust"
	inhand_icon_state = "cultblade_rust"
	broken_icon = "cultblade_broken"
	broken_name = "broken rusty dark blade"
	broken_desc = "Once used by worshipers of forbidden gods, now its covered in old rust and broken."

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
	var/broken = FALSE
	var/rustiness = 0 //This isn't a mistake, this causes it to break instantly upon use.
	var/broken_icon = "reforged_broken"

/obj/item/melee/sword/reforged/shitty/afterattack(target, mob/user, proximity_flag)
	. = ..()
	if(broken)
		return ..()
	if(ismovable(target))
		decrease_uses(user)

/obj/item/melee/sword/reforged/shitty/hit_reaction(mob/user)
	. = ..()
	if(broken)
		return ..()
	if(!.)
		return
	decrease_uses(user)

/obj/item/melee/sword/reforged/shitty/proc/decrease_uses(mob/user)
	if(rustiness == 0)
		no_uses(user)
		return
	rustiness--

/obj/item/melee/sword/reforged/shitty/proc/no_uses(mob/user)
	if(broken == TRUE)
		return
	user.visible_message(span_notice("[user]'s sword breaks. WHAT AN IDIOT!"), span_notice("The [src]'s blade shatters! It was a cheap felinid imitation! WHAT A PIECE OF SHIT!"))
	broken = TRUE
	name = "broken fake longsword"
	desc = "A cheap piece of felinid forged trash."
	icon_state = broken_icon
	inhand_icon_state = broken_icon
	worn_icon_state = broken_icon
	update_appearance()
	playsound(user, 'sound/effects/glassbr1.ogg', 100, TRUE)
	force -= 20
	throwforce = 5
	throw_range = 1
	block_chance = 5
	wound_bonus = -10
	armour_penetration = 0
	embedding = list("embed_chance" = 5, "impact_pain_mult" = 5)
	w_class = WEIGHT_CLASS_SMALL
