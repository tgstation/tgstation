/**
 * # Energy Katana
 *
 * The space ninja's katana.
 *
 * The katana that only space ninja spawns with.  Comes with 30 force and throwforce, along with a signature special jaunting system.
 * Upon clicking on a tile when right clicking, the user will teleport to that tile, assuming their target was not dense.
 * The katana has 3 dashes stored at maximum, and upon using the dash, it will return 20 seconds after it was used.
 * It also has a special feature where if it is tossed at a space ninja who owns it (determined by the ninja suit), the ninja will catch the katana instead of being hit by it.
 *
 */
/obj/item/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	desc_controls = "Right-click to dash."
	icon_state = "energy_katana"
	inhand_icon_state = "energy_katana"
	worn_icon_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 30
	throwforce = 30
	block_chance = 50
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	pickup_sound = 'sound/items/unsheath.ogg'
	drop_sound = 'sound/items/sheath.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = SHARP_EDGED
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/ninja/jaunt

/obj/item/energy_katana/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_katana/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!target.density)
		jaunt?.teleport(user, target)

/obj/item/energy_katana/equipped(mob/user, slot, initial)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Grant(user, src)

/obj/item/energy_katana/dropped(mob/user)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Remove(user)

/obj/item/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/datum/action/innate/dash/ninja
	current_charges = 3
	max_charges = 3
	charge_rate = 200
	beam_length = 1 SECONDS
	recharge_sound = null

/datum/action/innate/dash/ninja/GiveAction(mob/viewer) //this action should be invisible, as its handled by right-click
	return

/datum/action/innate/dash/ninja/HideFrom(mob/viewer)
	return
