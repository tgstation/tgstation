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
	new /obj/item/book/kindred(current_turf)

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
	if(!(HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER) || HAS_TRAIT(user, TRAIT_BLOODSUCKER_HUNTER)))
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
			to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.ReturnFullName()]', is indeed a Bloodsucker, but you already knew this."))
			return
		to_chat(user, span_warning("[target], also known as '[bloodsuckerdatum.ReturnFullName()]', [bloodsuckerdatum.my_clan ? "is part of the [bloodsuckerdatum.my_clan]!" : "is not part of a clan."] You quickly note this information down, memorizing it."))
		bloodsuckerdatum.break_masquerade()
	else
		to_chat(user, span_notice("You fail to draw any conclusions to [target] being a Bloodsucker."))

/obj/item/book/kindred/on_read(mob/living/user)
	ui_interact(user)

/obj/item/book/kindred/ui_interact(mob/living/user, datum/tgui/ui)
	if(user.mind && !(HAS_TRAIT(user.mind, TRAIT_BLOODSUCKER_HUNTER) || HAS_TRAIT(user, TRAIT_BLOODSUCKER_HUNTER)))
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
	clan_data["clan_name"] = CLAN_BRUJAH
	clan_data["clan_desc"] = "The Brujah Clan has proven to be the strongest in melee combat, boasting a powerful punch. \n\
		They also appear to be more calm than the others, entering their 'frenzies' whenever they want, but dont seem affected much by them. \n\
		Be wary, as they are fearsome warriors, rebels and anarchists, with an inclination towards Frenzy. \n\
		The Favorite Vassal gains brawn and a massive increase in brute damage from punching."
	data["clans"] += list(clan_data)

	var/clan_data1 = list()
	clan_data1["clan_name"] = CLAN_TREMERE
	clan_data1["clan_desc"] = "The Tremere Clan is extremely weak to True Faith, and will burn when entering areas considered such, like the Chapel. \n\
		Additionally, a whole new moveset is learned, built on Blood magic rather than Blood abilities, which are upgraded overtime. \n\
		More ranks can be gained by Vassalizing crewmembers. \n\
		The Favorite Vassal gains the Batform spell, being able to morph themselves at will."
	data["clans"] += list(clan_data1)

	var/clan_data2 = list()
	clan_data2["clan_name"] = CLAN_NOSFERATU
	clan_data2["clan_desc"] = "The Nosferatu Clan is unable to blend in with the crew, with no abilities such as Masquerade and Veil. \n\
		Additionally, has a permanent bad back and looks like a Bloodsucker upon a simple examine, and is entirely unidentifiable, \n\
		they can fit in the vents regardless of their form and equipment. \n\
		The Favorite Vassal is permanetly disfigured, and can also ventcrawl, but only while entirely nude."
	data["clans"] += list(clan_data2)

	var/clan_data3 = list()
	clan_data3["clan_name"] = CLAN_VENTRUE
	clan_data3["clan_desc"] = "The Ventrue Clan is extremely snobby with their meals, and refuse to drink blood from people without a mind. \n\
		There is additionally no way to rank themselves up, instead will have to rank their Favorite vassal through a Persuasion Rack. \n\
		The Favorite Vassal will slowly turn into a Bloodsucker this way, until they finally lose their last bits of Humanity."
	data["clans"] += list(clan_data3)

	var/clan_data4 = list()
	clan_data4["clan_name"] = CLAN_MALKAVIAN
	clan_data4["clan_desc"] = "Little is documented about Malkavians. Complete insanity is the most common theme. \n\
		The Favorite Vassal will suffer the same fate as the Master."
	data["clans"] += list(clan_data4)

	return data
