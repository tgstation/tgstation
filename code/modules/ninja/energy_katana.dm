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
	desc = "A katana infused with strong energy. Right-click to dash."
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

/obj/item/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	var/list/modifiers = params2list(click_parameters)

	if(LAZYACCESS(modifiers, RIGHT_CLICK) && !target.density)
		jaunt.teleport(user, target)

/obj/item/energy_katana/pickup(mob/living/user)
	. = ..()
	jaunt.Grant(user, src)
	user.update_icons()
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/item/energy_katana/dropped(mob/user)
	. = ..()
	jaunt?.Remove(user)
	user.update_icons()

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/hit_human = hit_atom
		if(istype(hit_human.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/ninja_suit = hit_human.wear_suit
			if(ninja_suit.energyKatana == src)
				returnToOwner(hit_human, 0, 1)
				return

	..()

/obj/item/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(jaunt)
	return ..()

/**
 * Proc called when the katana is recalled to its space ninja.
 *
 * Proc called when space ninja is hit with its suit's katana or the recall ability is used.
 * Arguments:
 * * user - To whom the katana is returning to.
 * * doSpark - whether or not the katana will spark when it returns.
 * * caught - boolean for whether or not the katana was caught or was teleported back.
 */
/obj/item/energy_katana/proc/returnToOwner(mob/living/carbon/human/user, doSpark = TRUE, caught = FALSE)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, ITEM_SLOT_BELT, 0, 1, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, span_notice("[msg]"))

/datum/action/innate/dash/ninja
	current_charges = 3
	max_charges = 3
	charge_rate = 200
	recharge_sound = null
