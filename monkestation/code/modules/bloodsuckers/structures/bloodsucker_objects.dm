//////////////////////
//     BLOODBAG     //
//////////////////////

#define BLOODBAG_GULP_SIZE 5

/// Taken from drinks.dm
/obj/item/reagent_containers/blood/attack(mob/living/victim, mob/living/attacker, params)
	if(!can_drink(victim, attacker))
		return

	if(victim != attacker)
		if(!do_after(victim, 5 SECONDS, attacker))
			return
		attacker.visible_message(
			span_notice("[attacker] forces [victim] to drink from the [src]."),
			span_notice("You put the [src] up to [victim]'s mouth."))
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transfered_by = attacker, methods = INGEST)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
		return TRUE

	while(do_after(victim, 1 SECONDS, timed_action_flags = IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(can_drink), victim, attacker)))
		victim.visible_message(
			span_notice("[victim] puts the [src] up to their mouth."),
			span_notice("You take a sip from the [src]."),
		)
		reagents.trans_to(victim, BLOODBAG_GULP_SIZE, transfered_by = attacker, methods = INGEST)
		playsound(victim.loc, 'sound/items/drink.ogg', 30, 1)
	return TRUE

#undef BLOODBAG_GULP_SIZE

/obj/item/reagent_containers/blood/proc/can_drink(mob/living/victim, mob/living/attacker)
	if(!canconsume(victim, attacker))
		return FALSE
	if(!reagents || !reagents.total_volume)
		to_chat(victim, span_warning("[src] is empty!"))
		return FALSE
	return TRUE

///Bloodbag of Bloodsucker blood (used by Vassals only)
/obj/item/reagent_containers/blood/o_minus/bloodsucker
	name = "blood pack"
	unique_blood = /datum/reagent/blood/bloodsucker

/obj/item/reagent_containers/blood/o_minus/bloodsucker/examine(mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/ex_vassal) || user.mind.has_antag_datum(/datum/antagonist/vassal/revenge))
		. += span_notice("Seems to be just about the same color as your Master's...")

//////////////////////
//      STAKES      //
//////////////////////
/obj/item/stack/sheet/mineral/wood/attackby(obj/item/item, mob/user, params)
	if(!item.get_sharpness())
		return ..()
	user.visible_message(
		span_notice("[user] begins whittling [src] into a pointy object."),
		span_notice("You begin whittling [src] into a sharp point at one end."),
		span_hear("You hear wood carving."),
	)
	// 5 Second Timer
	if(!do_after(user, 5 SECONDS, src, NONE, TRUE))
		return
	// Make Stake
	var/obj/item/stake/new_item = new(user.loc)
	user.visible_message(
		span_notice("[user] finishes carving a stake out of [src]."),
		span_notice("You finish carving a stake out of [src]."),
	)
	// Prepare to Put in Hands (if holding wood)
	var/obj/item/stack/sheet/mineral/wood/wood_stack = src
	var/replace = (user.get_inactive_held_item() == wood_stack)
	// Use Wood
	wood_stack.use(1)
	// If stack depleted, put item in that hand (if it had one)
	if(!wood_stack && replace)
		user.put_in_hands(new_item)

/// Do I have a stake in my heart?
/mob/living/proc/am_staked()
	var/obj/item/bodypart/chosen_bodypart = get_bodypart(BODY_ZONE_CHEST)
	if(!chosen_bodypart)
		return FALSE
	for(var/obj/item/embedded_stake in chosen_bodypart.embedded_objects)
		if(istype(embedded_stake, /obj/item/stake))
			return TRUE
	return FALSE

/// You can't go to sleep in a coffin with a stake in you.
/mob/living/proc/StakeCanKillMe()
	if(IsSleeping())
		return TRUE
	if(stat >= UNCONSCIOUS)
		return TRUE
	if(HAS_TRAIT_FROM(src, TRAIT_NODEATH, TORPOR_TRAIT))
		return TRUE
	return FALSE

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'monkestation/icons/bloodsuckers/stakes.dmi'
	icon_state = "wood"
	inhand_icon_state = "wood"
	lefthand_file = 'monkestation/icons/bloodsuckers/bs_leftinhand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_POCKETS
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("staked", "stabbed", "tore into")
	attack_verb_simple = list("staked", "stabbed", "tore into")
	sharpness = SHARP_EDGED
	embedding = list("embed_chance" = 20)
	force = 6
	throwforce = 10
	max_integrity = 30

	///Time it takes to embed the stake into someone's chest.
	var/staketime = 12 SECONDS

/obj/item/stake/attack(mob/living/target, mob/living/user, params)
	. = ..()
	if(.)
		return
	// Invalid Target, or not targetting the chest?
	if(check_zone(user.zone_selected) != BODY_ZONE_CHEST)
		return
	if(target == user)
		return
	if(!target.can_be_staked()) // Oops! Can't.
		to_chat(user, span_danger("You can't stake [target] when they are moving about! They have to be laying down or grabbed by the neck!"))
		return
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_danger("[target]'s chest resists the stake. It won't go in."))
		return

	to_chat(user, span_notice("You put all your weight into embedding the stake into [target]'s chest..."))
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	if(!do_after(user, staketime, target, extra_checks = CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, can_be_staked)))) // user / target / time / uninterruptable / show progress bar / extra checks
		return
	// Drop & Embed Stake
	user.visible_message(
		span_danger("[user.name] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)
	playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)
	if(tryEmbed(target.get_bodypart(BODY_ZONE_CHEST), TRUE, TRUE)) //and if it embeds successfully in their chest, cause a lot of pain
		target.apply_damage(max(10, force * 1.2), BRUTE, BODY_ZONE_CHEST, wound_bonus = 0, sharpness = TRUE)
	if(QDELETED(src)) // in case trying to embed it caused its deletion (say, if it's DROPDEL)
		return
	if(!target.mind)
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum)
		// If DEAD or TORPID... Kill Bloodsucker!
		if(target.StakeCanKillMe())
			bloodsuckerdatum.FinalDeath()
		else
			to_chat(target, span_userdanger("You have been staked! Your powers are useless, your death forever, while it remains in place."))
			target.balloon_alert(target, "you have been staked!")

///Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/mob/living/proc/can_be_staked()
	return FALSE

/mob/living/carbon/can_be_staked()
	if(!(mobility_flags & MOBILITY_MOVE))
		return TRUE
	return FALSE

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A wooden stake carved to a sharp point and hardened by fire."
	icon_state = "hardened"
	force = 8
	throwforce = 12
	armour_penetration = 10
	embedding = list("embed_chance" = 35)
	staketime = 80

/obj/item/stake/hardened/silver
	name = "silver stake"
	desc = "Polished and sharp at the end. For when some mofo is always trying to iceskate uphill."
	icon_state = "silver"
	inhand_icon_state = "silver"
	siemens_coefficient = 1 //flags = CONDUCT // var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	force = 9
	armour_penetration = 25
	embedding = list("embed_chance" = 65)
	staketime = 60

//////////////////////
//     ARCHIVES     //
//////////////////////

/obj/item/book/codex_gigas/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	new /obj/item/book/kindred(current_turf)

/**
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators.
 *	When used on a player, after a short timer, will reveal if the player is a Bloodsucker, including their real name and Clan.
 *	This book should not work on Bloodsuckers using the Masquerade ability.
 *	If it reveals a Bloodsucker, the Curator will then be able to tell they are a Bloodsucker on examine (Like a Vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 *
 *	Regular Bloodsuckers won't have any negative effects from the book, while everyone else will get burns/eye damage.
 */
/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	starting_title = "the Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'monkestation/icons/bloodsuckers/vamp_obj.dmi'
	lefthand_file = 'monkestation/icons/bloodsuckers/bs_leftinhand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/bs_rightinhand.dmi'
	icon_state = "kindred_book"
	starting_author = "dozens of generations of Curators"
	unique = TRUE
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	///Boolean on whether the book is currently being used, so you can only use it on one person at a time.
	var/in_use = FALSE

/obj/item/book/kindred/Initialize()
	. = ..()
	AddComponent(/datum/component/stationloving, FALSE, TRUE)

/* NOT YET IMPLEMENTED
/obj/item/book/kindred/try_carve(obj/item/carving_item, mob/living/user, params)
	to_chat(user, span_notice("You feel the gentle whispers of a Librarian telling you not to cut [starting_title]."))
	return FALSE
*/

///Attacking someone with the book.
/obj/item/book/kindred/afterattack(mob/living/target, mob/living/user, flag, params)
	. = ..()
	if(!user.can_read(src) || in_use || (target == user) || !ismob(target))
		return
	if(!HAS_TRAIT(user.mind, TRAIT_OCCULTIST))
		if(IS_BLOODSUCKER(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
			return
		to_chat(user, span_warning("[src] burns your hands as you try to use it!"))
		user.apply_damage(3, BURN, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		return

	in_use = TRUE
	user.balloon_alert_to_viewers(user, "reading book...", "looks at [target] and [src]")
	if(!do_after(user, 3 SECONDS, target, timed_action_flags = NONE, progress = TRUE))
		to_chat(user, span_notice("You quickly close [src]."))
		in_use = FALSE
		return
	in_use = FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(target)
	// Are we a Bloodsucker | Are we on Masquerade. If one is true, they will fail.
	if(IS_BLOODSUCKER(target) && !HAS_TRAIT(target, TRAIT_MASQUERADE))
		if(bloodsuckerdatum.broke_masquerade)
			to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.return_full_name()]', is indeed a Bloodsucker, but you already knew this."))
			return
		to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.return_full_name()]', [bloodsuckerdatum.my_clan ? "is part of the [bloodsuckerdatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it."))
		bloodsuckerdatum.break_masquerade()
	else
		to_chat(user, span_notice("You fail to draw any conclusions to [target] being a Bloodsucker."))

/obj/item/book/kindred/attack_self(mob/living/user)
	if(user.mind && !HAS_TRAIT(user.mind, TRAIT_OCCULTIST))
		if(IS_BLOODSUCKER(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
		else
			to_chat(user, span_warning("You feel your eyes unable to read the boring texts..."))
			user.set_eye_blur_if_lower(10 SECONDS)
		return
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()

	for(var/datum/bloodsucker_clan/clans as anything in subtypesof(/datum/bloodsucker_clan))
		var/clan_data = list()
		clan_data["clan_name"] = initial(clans.name)
		clan_data["clan_desc"] = initial(clans.description)
		data["clans"] += list(clan_data)

	return data
