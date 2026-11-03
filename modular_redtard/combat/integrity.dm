// Ratwood's integrity of weapons and armor on top of TG's (code/game/atom/atom_defense.dm). The porter writes Ratwood's
// max_integrity, integrity_failure and equip_delay_self into TG's vars; this file gives them Ratwood's meaning
// (game/objects/obj_defense.dm, items.dm obj_break(), obj_fix() and obj_destruction(), rogueweapons/rogueweapon.dm,
// human/species.dm equip_delay_self_check()):
// - a weapon worn down to its integrity_failure share (a fifth for Ratwood's weapons) breaks: its force and armour
//   penetration fall to a fifth, its defense to a half and its wielded bonus to -3, it is blunt and cannot parry. It mends
//   as Ratwood mends it: repaired in full by a skilled hand, or field-repaired to 60% by an unskilled one (crafting/repair.dm);
// - worn out by blows, a weapon, a piece of clothing or anything held or worn is not destroyed (TG's deconstruct()): it stays
//   at no integrity, broken, to be repaired. Acid and fire still destroy it;
// - putting an item on oneself takes its equip_delay_self less the wearer's speed, and only the longer delays say so; most
//   things may be put on walking, clothes and armor standing (Ratwood edelay_type).
// Numbers in config/redtard/mechanics/values/combat.txt, section "Weapons and gear".

#define INTEGRITY_BROKEN_FORCE_DIVISOR rogue_value("broken_force_divisor")
#define INTEGRITY_BROKEN_PENETRATION_DIVISOR rogue_value("broken_penetration_divisor")
#define INTEGRITY_BROKEN_DEFENSE_DIVISOR rogue_value("broken_defense_divisor")
#define INTEGRITY_BROKEN_WIELDED_DEFENSE rogue_value("broken_wielded_defense")
/// Share of its integrity a field repair brings a broken item to (crafting/repair.dm, Ratwood 60%).
#define INTEGRITY_FIELD_REPAIR_SHARE rogue_value("field_repair_share")
#define INTEGRITY_EQUIP_MESSAGE_DELAY rogue_value("equip_message_delay")
#define INTEGRITY_BREAK_SOUND 'modular_redtard/rockhill/sound/foley/breaksound.ogg'

/obj/item/rogueweapon
	/// Broken in Ratwood's sense (obj_broken): worn down to integrity_failure, weak and blunt until mended.
	var/rogue_broken = FALSE
	/// What breaking took away, put back when the weapon is mended (Ratwood obj_fix() puts back the type's values).
	var/list/rogue_unbroken_stats

/obj/item/rogueweapon/atom_break(damage_flag)
	. = ..()
	rogue_break()

/// TG calls it on every repair above the breaking point; Ratwood mends only a full or a finished field repair.
/obj/item/rogueweapon/atom_fix()
	. = ..()
	if(rogue_mendable())
		rogue_mend()

/// The field repair of crafting/repair.dm marks the item shoddy after the integrity is back, so the mending is looked at here too.
/obj/item/rogueweapon/rogue_repair(mob/living/user, amount, unskilled)
	. = ..()
	if(rogue_mendable())
		rogue_mend()

/// A broken weapon counts as broken for the repairs (crafting/repair.dm): an unskilled hand brings it to 60% and no further.
/obj/item/rogueweapon/rogue_is_broken()
	return rogue_broken || ..()

/// Ratwood obj_break() of a weapon: sharpness = IS_BLUNT.
/obj/item/rogueweapon/get_sharpness()
	if(rogue_broken)
		return NONE
	return ..()

/obj/item/rogueweapon/examine(mob/user)
	. = ..()
	if(rogue_broken)
		. += span_warning("It's broken.")
	. += rogue_weapon_notes()

/// Ratwood obj_break() of a weapon, with lose_polish() and ungrip() of /obj/item/obj_break().
/obj/item/rogueweapon/proc/rogue_break()
	if(rogue_broken)
		return FALSE
	var/mob/living/holder = isliving(loc) ? loc : null
	var/datum/component/rogue_polish/polish = GetComponent(/datum/component/rogue_polish)
	// The polish goes with the breaking, its force bonus first (crafting/polishing.dm).
	polish?.on_integrity_changed(src, max_integrity, 0)
	rogue_release_grips(holder)
	var/datum/component/two_handed/grip = GetComponent(/datum/component/two_handed)
	rogue_unbroken_stats = list(
		"force" = grip ? grip.force_unwielded : force,
		"force_wielded" = grip?.force_wielded,
		"rogue_force_wielded" = rogue_force_wielded,
		"armour_penetration" = armour_penetration,
		"wdefense" = wdefense,
		"wdefense_wbonus" = wdefense_wbonus,
		"can_parry" = can_parry,
	)
	rogue_broken = TRUE
	var/divisor = INTEGRITY_BROKEN_FORCE_DIVISOR
	rogue_set_force(rogue_unbroken_stats["force"] / divisor, grip ? grip.force_wielded / divisor : null)
	rogue_force_wielded /= divisor
	armour_penetration /= INTEGRITY_BROKEN_PENETRATION_DIVISOR
	wdefense /= INTEGRITY_BROKEN_DEFENSE_DIVISOR
	if(wdefense_wbonus)
		wdefense_wbonus = INTEGRITY_BROKEN_WIELDED_DEFENSE
	can_parry = FALSE
	playsound(get_turf(src), INTEGRITY_BREAK_SOUND, 80, TRUE)
	balloon_alert_to_viewers("breaks!")
	if(holder)
		to_chat(holder, span_warning("\The [src] BREAKS...!"))
		holder.rogue_refresh_intents()
	update_appearance()
	return TRUE

/// Ratwood obj_fix() of a weapon: what breaking took is given back.
/obj/item/rogueweapon/proc/rogue_mend()
	if(!rogue_broken)
		return FALSE
	var/mob/living/holder = isliving(loc) ? loc : null
	rogue_release_grips(holder)
	var/list/stats = rogue_unbroken_stats
	rogue_broken = FALSE
	rogue_unbroken_stats = null
	if(length(stats))
		rogue_set_force(stats["force"], stats["force_wielded"])
		rogue_force_wielded = stats["rogue_force_wielded"]
		armour_penetration = stats["armour_penetration"]
		wdefense = stats["wdefense"]
		wdefense_wbonus = stats["wdefense_wbonus"]
		can_parry = stats["can_parry"]
	holder?.rogue_refresh_intents()
	update_appearance()
	return TRUE

/// Ratwood mends a broken weapon repaired in full, or field-repaired to its share by an unskilled hand (shoddy_repair).
/obj/item/rogueweapon/proc/rogue_mendable()
	if(!rogue_broken)
		return FALSE
	var/integrity = get_integrity()
	return integrity >= max_integrity || (shoddy_repair && integrity >= max_integrity * INTEGRITY_FIELD_REPAIR_SHARE)

/// Lets go of the alternate grip and of the second hand (Ratwood ungrip()), so breaking and mending start from one hand.
/obj/item/proc/rogue_release_grips(mob/living/holder)
	if(rogue_alt_grip)
		rogue_set_alt_grip(null, holder)
	var/datum/component/two_handed/grip = GetComponent(/datum/component/two_handed)
	var/mob/living/carbon/wielder = holder
	if(grip?.wielded && istype(wielder))
		grip.unwield(wielder, FALSE, FALSE)

/// Sets the item's force in one hand and wielded, on its two-handed grip too, keeping the force it is held with in step
/// (Ratwood update_force_dynamic()). A null wielded force leaves the grip's own.
/obj/item/proc/rogue_set_force(unwielded, wielded)
	var/datum/component/two_handed/grip = GetComponent(/datum/component/two_handed)
	if(!grip)
		force = max(unwielded, 0)
		return
	grip.force_unwielded = max(unwielded, 0)
	if(!isnull(wielded))
		grip.force_wielded = max(wielded, 0)
	force = grip.wielded ? grip.force_wielded : grip.force_unwielded

/// Adds to the item's force in one hand and wielded (Ratwood force += amount, force_wielded += amount).
/obj/item/proc/rogue_add_force(amount)
	var/datum/component/two_handed/grip = GetComponent(/datum/component/two_handed)
	if(rogue_force_wielded)
		rogue_force_wielded = max(rogue_force_wielded + amount, 0)
	if(grip)
		rogue_set_force(grip.force_unwielded + amount, grip.force_wielded + amount)
	else
		rogue_set_force(force + amount)

/// Ratwood's integrity rules hold: on medieval maps, and for Ratwood's weapons wherever they are.
/obj/item/proc/rogue_integrity_rules()
	return istype(src, /obj/item/rogueweapon) || rogue_combat_enabled()

/// Ratwood obj_destruction() of an item: worn out by blows, a weapon, a piece of clothing or anything held or worn stays,
/// broken; acid and fire destroy it, and TG's consuming moths eat it.
/obj/item/proc/rogue_kept_at_zero(damage_flag)
	if(!rogue_integrity_rules() || damage_flag == ACID || damage_flag == FIRE || damage_flag == CONSUME)
		return FALSE
	return istype(src, /obj/item/rogueweapon) || isclothing(src) || ismob(loc)

/obj/item/atom_destruction(damage_flag)
	if(!rogue_kept_at_zero(damage_flag))
		return ..()

/// TG shreds worn-out clothing and drops it off the wearer; Ratwood keeps it on, broken (its armor gone, combat/armor.dm).
/obj/item/clothing/atom_destruction(damage_flag)
	if(!rogue_kept_at_zero(damage_flag))
		return ..()

/// An item kept at no integrity takes no more harm from blows, where TG would stack_trace; acid and fire finish it
/// (Ratwood take_damage() at zero integrity).
/obj/item/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(!uses_integrity || QDELETED(src) || get_integrity() > 0 || !rogue_integrity_rules())
		return ..()
	if((damage_flag == ACID || damage_flag == FIRE) && !(resistance_flags & INDESTRUCTIBLE) && run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration) >= DAMAGE_PRECISION)
		atom_destruction(damage_flag)
	return 0

/obj/item
	/// Ratwood edelay_type: the item may be put on walking (most things); clothes and armor are put on standing still.
	var/edelay_type = TRUE

/obj/item/clothing
	edelay_type = FALSE

/obj/item/clothing/cloak
	edelay_type = TRUE

/obj/item/clothing/suit/roguetown/shirt
	edelay_type = TRUE

/obj/item/clothing/head/roguetown/roguehood
	edelay_type = TRUE

/obj/item/clothing/head/roguetown/scarf
	edelay_type = TRUE

/obj/item/clothing/head/roguetown/beekeeper
	edelay_type = TRUE

/obj/item/clothing/neck/roguetown/psicross/malum/secret
	edelay_type = TRUE

/obj/item/clothing/neck/roguetown/psicross/weeping
	edelay_type = TRUE

/// Deciseconds putting the item on oneself takes (Ratwood minone(equip_delay_self - STASPD)): the speed shortens it, and
/// when it reaches nothing the item goes on at once; a faster wearer than that still takes a decisecond.
/obj/item/proc/rogue_self_equip_delay(mob/living/wearer)
	var/delay = equip_delay_self - wearer.rogue_stat(ROGUE_STAT_SPEED)
	return delay ? max(delay, 1) : 0

/// Ratwood equip_delay_self_check(): the delay less the wearer's speed, "I start putting on..." only for a delay over a
/// second, walking allowed by edelay_type. TG waits the whole delay and always says so.
/datum/species/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self || !rogue_combat_enabled())
		return ..()
	if(I.equip_delay_self > INTEGRITY_EQUIP_MESSAGE_DELAY)
		H.visible_message(span_smallnotice("[H] starts putting on [I]..."), span_smallnotice("I start putting on [I]..."))
	return do_after(H, I.rogue_self_equip_delay(H), target = H, timed_action_flags = I.edelay_type ? (IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE) : NONE)

#undef INTEGRITY_BROKEN_FORCE_DIVISOR
#undef INTEGRITY_BROKEN_PENETRATION_DIVISOR
#undef INTEGRITY_BROKEN_DEFENSE_DIVISOR
#undef INTEGRITY_BROKEN_WIELDED_DEFENSE
#undef INTEGRITY_FIELD_REPAIR_SHARE
#undef INTEGRITY_EQUIP_MESSAGE_DELAY
#undef INTEGRITY_BREAK_SOUND
