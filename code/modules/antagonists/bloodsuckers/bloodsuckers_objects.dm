//////////////////////
//       TRAP       //
//////////////////////

/obj/item/restraints/legcuffs/beartrap/bloodsucker
	name = "stake trap"
	desc = "Turn the stakes against the staker! Or something like that..."
	icon = 'icons/obj/vamp_obj.dmi'
	icon_state = "staketrap"
	slowdown = 10
	var/area/lair_area
	var/mob/lair_owner

/obj/item/restraints/legcuffs/beartrap/bloodsucker/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/restraints/legcuffs/beartrap/bloodsucker/attack_self(mob/user)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	lair_area = bloodsuckerdatum.lair
	lair_owner = user
	START_PROCESSING(SSobj, src)
	if(!bloodsuckerdatum)
		to_chat(user, span_notice("Although it seems simple you have no idea how to reactivate the stake trap."))
		return
	if(armed)
		STOP_PROCESSING(SSobj,src)
		return ..() //disarm it, otherwise continue to try and place
	if(!bloodsuckerdatum.lair)
		to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
		return
	if(lair_area != get_area(src))
		to_chat(user, span_danger("You may only activate this trap in your lair: [lair_area]."))
		return
	lair_area = bloodsuckerdatum.lair
	lair_owner = user
	START_PROCESSING(SSobj, src)
	..()

/obj/item/restraints/legcuffs/beartrap/bloodsucker/spring_trap(datum/source, AM as mob|obj)
	var/mob/living/carbon/human/user = AM
	if(armed && (IS_BLOODSUCKER(user) || IS_VASSAL(user)))
		to_chat(user, span_notice("You gracefully step over the blood puddle and avoid triggering the trap"))
		return
	..()

/obj/item/restraints/legcuffs/beartrap/bloodsucker/close_trap()
	STOP_PROCESSING(SSobj, src)
	lair_area = null
	lair_owner = null
	return ..()

/obj/item/restraints/legcuffs/beartrap/bloodsucker/process()
	if(!armed)
		STOP_PROCESSING(SSobj,src)
		return
	if(get_area(src) != lair_area)
		close_trap()

//////////////////////
//      HEART       //
//////////////////////

/datum/antagonist/bloodsucker/proc/RemoveVampOrgans()
	var/obj/item/organ/internal/heart/newheart = owner.current.getorganslot(ORGAN_SLOT_HEART)
	if(newheart)
		qdel(newheart)
	newheart = new()
	newheart.Insert(owner.current)

//////////////////////
//      STAKES      //
//////////////////////

/// Do I have a stake in my heart?
/mob/proc/AmStaked()
	return FALSE

/mob/living/AmStaked()
	var/obj/item/bodypart/chosen_bodypart = get_bodypart(BODY_ZONE_CHEST)
	if(!chosen_bodypart)
		return FALSE
	for(var/obj/item/embedded_stake in chosen_bodypart.embedded_objects)
		if(istype(embedded_stake, /obj/item/stake))
			return TRUE
	return FALSE

/// You can't go to sleep in a coffin with a stake in you.
/mob/living/proc/StakeCanKillMe()
	return IsSleeping() || stat >= UNCONSCIOUS || blood_volume <= 0 || HAS_TRAIT(src, TRAIT_NODEATH)

/// Can this target be staked? If someone stands up before this is complete, it fails. Best used on someone stationary.
/mob/living/carbon/proc/can_be_staked()
	return !(mobility_flags & MOBILITY_MOVE)

/obj/item/stake
	name = "wooden stake"
	desc = "A simple wooden stake carved to a sharp point."
	icon = 'icons/obj/stakes.dmi'
	icon_state = "wood"
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("stakes", "stabs", "tores into")
	attack_verb_simple = list("stake", "stab", "tore into")
	/// Embedding
	sharpness = SHARP_EDGED
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 20, "embedded_fall_chance" = 10)
	force = 6
	throwforce = 10
	max_integrity = 30
	/// Time it takes to embed the stake into someone's chest.
	var/staketime = 12 SECONDS

/obj/item/stake/afterattack(mob/living/carbon/target, mob/living/user, proximity, discover_after = TRUE)
	// Invalid Target, or not targetting the chest?
	if(check_zone(user.zone_selected) != BODY_ZONE_CHEST)
		return
	// Needs to be Down/Slipped in some way to Stake.
	if(!target.can_be_staked() || target == user) // Oops! Can't.
		to_chat(user, span_danger("You can't stake [target] when they are moving about! They have to be laying down or grabbed by the neck!"))
		return
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		to_chat(user, span_danger("[target]'s chest resists the stake. It won't go in."))
		return
	to_chat(user, span_notice("You put all your weight into embedding the stake into [target]'s chest..."))
	playsound(user, 'sound/magic/Demon_consume.ogg', 50, 1)
	if(!do_after(user, staketime, target, extra_checks = CALLBACK(target, /mob/living/carbon.proc/can_be_staked))) // user / target / time / uninterruptable / show progress bar / extra checks
		return
	// Drop & Embed Stake
	user.visible_message(
		span_danger("[user.name] drives the [src] into [target]'s chest!"),
		span_danger("You drive the [src] into [target]'s chest!"),
	)
	playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)
	user.dropItemToGround(src, TRUE) //user.drop_item() // "drop item" doesn't seem to exist anymore. New proc is user.dropItemToGround() but it doesn't seem like it's needed now?
	if(!target.mind)
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = target.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum)
		// If DEAD or TORPID... Kill Bloodsucker!
		if(target.StakeCanKillMe())
			bloodsuckerdatum.FinalDeath()
		else
			to_chat(target, span_userdanger("You have been staked! Your powers are useless, your death forever, while it remains in place."))
			to_chat(target, span_userdanger("You have been staked!"))

/// Created by welding and acid-treating a simple stake.
/obj/item/stake/hardened
	name = "hardened stake"
	desc = "A hardened wooden stake carved to a sharp point and scorched at the end."
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
	siemens_coefficient = 1 //flags = CONDUCT // var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	force = 9
	armour_penetration = 25
	embedding = list("embed_chance" = 65)
	staketime = 60

/obj/item/stake/ducky
	name = "wooden ducky"
	desc = "Remember to not drench your wooden ducky in bath water to prevent it from stinking."
	icon_state = "ducky"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP_POINTY //torture ducky

/obj/item/stake/ducky/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)

//////////////////////
//     ARCHIVES     //
//////////////////////

/*
 *	# Archives of the Kindred:
 *
 *	A book that can only be used by Curators.
 *	When used on a player, after a short timer, will reveal if the player is a Bloodsucker, including their real name and Clan.
 *	This book should not work on Bloodsuckers using the Masquerade ability.
 *	If it reveals a Bloodsucker, the Curator will then be able to tell they are a Bloodsucker on examine (Like a Vassal).
 *	Reading it normally will allow Curators to read what each Clan does, with some extra flavor text ones.
 *
 *	Regular Bloodsuckers won't have any negative effects from the book, while everyone else will get burns/eye damage.
 *	It is also Tremere's Clan objective to ensure a Tremere Bloodsucker has stolen this by the end of the round.
 */

/obj/item/book/codex_gigas/Initialize(mapload)
	. = ..()
	var/turf/current_turf = get_turf(src)
	new /obj/item/kindred(current_turf)

/obj/item/book/kindred
	name = "\improper Archive of the Kindred"
	starting_title = "the Archive of the Kindred"
	desc = "Cryptic documents explaining hidden truths behind Undead beings. It is said only Curators can decipher what they really mean."
	icon = 'icons/obj/vamp_obj.dmi'
	lefthand_file = 'icons/mob/inhands/antag/bs_leftinhand.dmi'
	righthand_file = 'icons/mob/inhands/antag/bs_rightinhand.dmi'
	starting_author = "dozens of generations of Curators"
	icon_state = "kindred_book"
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/in_use = FALSE

/obj/item/book/kindred/attackby(obj/item/item, mob/user, params)
	// Copied from '/obj/item/book/attackby(obj/item/item, mob/user, params)'
	if((istype(item, /obj/item/knife) || item.tool_behaviour == TOOL_WIRECUTTER) && !(flags_1 & HOLOGRAM_1))
		to_chat(user, span_notice("You feel the gentle whispers of a Librarian telling you not to cut [starting_title]."))
		return
	return ..()

///Attacking someone with the book.
/obj/item/book/kindred/afterattack(mob/living/target, mob/living/user, flag, params)
	. = ..()
	if(!user.can_read(src) || in_use || (target == user) || !ismob(target))
		return
	if(!HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER))
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

/obj/item/book/kindred/on_read(mob/living/user)
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	if(user.mind && !HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER))
		if(IS_BLOODSUCKER(user))
			to_chat(user, span_notice("[src] seems to be too complicated for you. It would be best to leave this for someone else to take."))
			return
		to_chat(user, span_warning("You feel your eyes burn as you begin to read through [src]!"))
		var/obj/item/organ/internal/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
		user.set_eye_blur_if_lower(10 SECONDS)
		eyes.applyOrganDamage(5)
		return

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "KindredBook", name)
		ui.open()

/obj/item/book/kindred/ui_static_data(mob/user)
	var/data = list()

	var/clan_data = list()
	clan_data["clan_name"] = initial(CLAN_BRUJAH)
	clan_data["clan_desc"] = initial("This Clan has proven to be the strongest in melee combat, boasting a <b>powerful punch</b>.<br> \
		They also appear to be more calm than the others, entering their 'frenzies' whenever they want, but <i>dont seem affected</i>.<br> \
		Be wary, as they are fearsome warriors, rebels and anarchists, with an inclination towards Frenzy.<br> \
		<b>Favorite Vassal</b>: Their favorite Vassal gains the Brawn ability. \
		<b>Strength</b>: Frenzy will not kill them, punches deal a lot of damage.<br> \
		<b>Weakness</b>: They have to spend Blood on powers while in Frenzy too.")
	data["clans"] += list(clan_data)

	clan_data["clan_name"] = initial(CLAN_TREMERE)
	clan_data["clan_desc"] = initial("This Clan seems to hate entering the <i>Chapel</i>.<br> \
		They are a secluded Clan, they are Vampires who've mastered the power of blood, and seek knowledge.<br> \
		They appear to be focused more on their Blood Magic than their other Powers, getting stronger faster the more Vassals they have.<br> \
		They have 3 different paths they can take, from reviving people as Vassals, to stealing blood with beams made of the same essence.<br> \
		<b>Favorite Vassal</b>: Their Favorite Vassal gains the ability to shift into a Bat at will. \
		<b>Strength</b>: 3 different Powers that get stupidly strong overtime.<br> \
		<b>Weakness</b>: Cannot get regular Powers, with no way to get stun resistance outside of Frenzy.")
	data["clans"] += list(clan_data)

	clan_data["clan_name"] = initial(CLAN_NOSFERATU)
	clan_data["clan_desc"] = initial("This Clan has been the most obvious to find information about.<br> \
		They are <i>disfigured, ghoul-like</i> vampires upon embrace by their Sire, scouts that travel through desolate paths to avoid violating the Masquerade.<br> \
		They make <i>no attempts</i> at hiding themselves within the crew, and have a terrible taste for <i>heavy items</i>.<br> \
		They also seem to manage to fit themsleves into small spaces such as <i>vents</i>.<br> \
		<b>Favorite Vassal</b>: Their Favorite Vassal gains the ability to ventcrawl while naked and becomes disfigured. \
		<b>Strength</b>: Ventcrawl.<br> \
		<b>Weakness</b>: Can't disguise themselves, permanently pale, can easily be discovered by their DNA or Blood Level.")
	data["clans"] += list(clan_data)

	clan_data["clan_name"] = initial(CLAN_VENTRUE)
	clan_data["clan_desc"] = initial("This Clan seems to <i>despise</i> drinking from non sentient organics.<br> \
		They are Masters of manipulation, Greedy and entitled. Authority figures between the kindred society.<br> \
		They seem to take their Vassal's lives <i>very seriously</i>, going as far as to give Vassals some of their own Blood.<br> \
		Compared to other types, this one <i>relies</i> on their Vassals, rather than fighting for themselves.<br> \
		<b>Favorite Vassal</b>: Their Favorite Vassal will slowly be turned into a Bloodsucker overtime. \
		<b>Strength</b>: Slowly turns a Vassal into a Bloodsucker.<br> \
		<b>Weakness</b>: Does not gain more abilities overtime, it is best to target the Bloodsucker over the Vassal.")
	data["clans"] += list(clan_data)

	clan_data["clan_name"] = initial(CLAN_MALKAVIAN)
	clan_data["clan_desc"] = initial("There is barely any information known about this Clan.<br> \
		Members of this Clan seems to <i>mumble things to themselves</i>, unaware of their surroundings.<br> \
		They also seem to enter and dissapear into areas randomly, <i>as if not even they know where they are</i>.<br> \
		<b>Favorite Vassal</b>: Unknown. \
		<b>Strength</b>: Unknown.<br> \
		<b>Weakness</b>: Unknown.")
	data["clans"] += list(clan_data)

	return data
