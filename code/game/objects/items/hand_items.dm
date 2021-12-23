// For all of the items that are really just the user's hand used in different ways, mostly (all, really) from emotes

/obj/item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	attack_verb_continuous = list("bops")
	attack_verb_simple = list("bop")

/obj/item/circlegame/Initialize(mapload)
	. = ..()
	var/mob/living/owner = loc
	if(!istype(owner))
		return
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, .proc/ownerExamined)

/obj/item/circlegame/Destroy()
	var/mob/owner = loc
	if(istype(owner))
		UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)
	return ..()

/obj/item/circlegame/dropped(mob/user)
	UnregisterSignal(user, COMSIG_PARENT_EXAMINE) //loc will have changed by the time this is called, so Destroy() can't catch it
	// this is a dropdel item.
	return ..()

/// Stage 1: The mistake is made
/obj/item/circlegame/proc/ownerExamined(mob/living/owner, mob/living/sucker)
	SIGNAL_HANDLER

	if(!istype(sucker) || !in_range(owner, sucker))
		return
	addtimer(CALLBACK(src, .proc/waitASecond, owner, sucker), 4)

/// Stage 2: Fear sets in
/obj/item/circlegame/proc/waitASecond(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker) || QDELETED(src) || QDELETED(owner))
		return

	if(owner == sucker) // big mood
		to_chat(owner, span_danger("Wait a second... you just looked at your own [src.name]!"))
		addtimer(CALLBACK(src, .proc/selfGottem, owner), 10)
	else
		to_chat(sucker, span_danger("Wait a second... was that a-"))
		addtimer(CALLBACK(src, .proc/GOTTEM, owner, sucker), 6)

/// Stage 3A: We face our own failures
/obj/item/circlegame/proc/selfGottem(mob/living/owner)
	if(QDELETED(src) || QDELETED(owner))
		return

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.visible_message(span_danger("[owner] shamefully bops [owner.p_them()]self with [owner.p_their()] [src.name]."), span_userdanger("You shamefully bop yourself with your [src.name]."), \
		span_hear("You hear a dull thud!"))
	log_combat(owner, owner, "bopped", src.name, "(self)")
	owner.do_attack_animation(owner)
	owner.apply_damage(100, STAMINA)
	owner.Knockdown(10)
	qdel(src)

/// Stage 3B: We face our reckoning (unless we moved away or they're incapacitated)
/obj/item/circlegame/proc/GOTTEM(mob/living/owner, mob/living/sucker)
	if(QDELETED(sucker))
		return

	if(QDELETED(src) || QDELETED(owner))
		to_chat(sucker, span_warning("Nevermind... must've been your imagination..."))
		return

	if(!in_range(owner, sucker) || !(owner.mobility_flags & MOBILITY_USE))
		to_chat(sucker, span_notice("Phew... you moved away before [owner] noticed you saw [owner.p_their()] [src.name]..."))
		return

	to_chat(owner, span_warning("[sucker] looks down at your [src.name] before trying to avert [sucker.p_their()] eyes, but it's too late!"))
	to_chat(sucker, span_danger("<b>[owner] sees the fear in your eyes as you try to look away from [owner.p_their()] [src.name]!</b>"))

	owner.face_atom(sucker)
	if(owner.client)
		owner.client.give_award(/datum/award/achievement/misc/gottem, owner) // then everybody clapped

	playsound(get_turf(owner), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	owner.do_attack_animation(sucker)

	if(HAS_TRAIT(owner, TRAIT_HULK))
		owner.visible_message(span_danger("[owner] bops [sucker] with [owner.p_their()] [src.name] much harder than intended, sending [sucker.p_them()] flying!"), \
			span_danger("You bop [sucker] with your [src.name] much harder than intended, sending [sucker.p_them()] flying!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), ignored_mobs=list(sucker))
		to_chat(sucker, span_userdanger("[owner] bops you incredibly hard with [owner.p_their()] [src.name], sending you flying!"))
		sucker.apply_damage(50, STAMINA)
		sucker.Knockdown(50)
		log_combat(owner, sucker, "bopped", src.name, "(setup- Hulk)")
		var/atom/throw_target = get_edge_target_turf(sucker, owner.dir)
		sucker.throw_at(throw_target, 6, 3, owner)
	else
		owner.visible_message(span_danger("[owner] bops [sucker] with [owner.p_their()] [src.name]!"), span_danger("You bop [sucker] with your [src.name]!"), \
			span_hear("You hear a dull thud!"), ignored_mobs=list(sucker))
		sucker.apply_damage(15, STAMINA)
		log_combat(owner, sucker, "bopped", src.name, "(setup)")
		to_chat(sucker, span_userdanger("[owner] bops you with [owner.p_their()] [src.name]!"))
	qdel(src)


/obj/item/noogie
	name = "noogie"
	desc = "Get someone in an aggressive grab then use this on them to ruin their day."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM

/obj/item/noogie/attack(mob/living/carbon/target, mob/living/carbon/human/user)
	if(!istype(target))
		to_chat(user, span_warning("You don't think you can give this a noogie!"))
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You can't bring yourself to noogie [target]! You don't want to risk harming anyone..."))
		return

	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target || user.grab_state < GRAB_AGGRESSIVE || user.getStaminaLoss() > 80)
		return FALSE

	var/obj/item/bodypart/head/the_head = target.get_bodypart(BODY_ZONE_HEAD)
	if((target.get_biological_state() != BIO_FLESH_BONE && target.get_biological_state() != BIO_JUST_FLESH) || !the_head.is_organic_limb())
		to_chat(user, span_warning("You can't noogie [target], [target.p_they()] [target.p_have()] no skin on [target.p_their()] head!"))
		return

	// [user] gives [target] a [prefix_desc] noogie[affix_desc]!
	var/brutal_noogie = FALSE // was it an extra hard noogie?
	var/prefix_desc = "rough"
	var/affix_desc = ""
	var/affix_desc_target = ""

	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		prefix_desc = "violent"
		affix_desc = "on [target.p_their()] sensitive antennae"
		affix_desc_target = "on your highly sensitive antennae"
		brutal_noogie = TRUE
	if(user.dna?.check_mutation(HULK))
		prefix_desc = "sickeningly brutal"
		brutal_noogie = TRUE

	var/message_others = "[prefix_desc] noogie[affix_desc]"
	var/message_target = "[prefix_desc] noogie[affix_desc_target]"

	user.visible_message(span_danger("[user] begins giving [target] a [message_others]!"), span_warning("You start giving [target] a [message_others]!"), vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
	to_chat(target, span_userdanger("[user] starts giving you a [message_target]!"))

	if(!do_after(user, 1.5 SECONDS, target))
		to_chat(user, span_warning("You fail to give [target] a noogie!"))
		to_chat(target, span_danger("[user] fails to give you a noogie!"))
		return

	if(brutal_noogie)
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie_harsh", /datum/mood_event/noogie_harsh)
	else
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "noogie", /datum/mood_event/noogie)

	noogie_loop(user, target, 0)

/// The actual meat and bones of the noogie'ing
/obj/item/noogie/proc/noogie_loop(mob/living/carbon/human/user, mob/living/carbon/target, iteration)
	if(!(target?.get_bodypart(BODY_ZONE_HEAD)) || user.pulling != target)
		return FALSE

	if(user.getStaminaLoss() > 80)
		to_chat(user, span_warning("You're too tired to continue giving [target] a noogie!"))
		to_chat(target, span_danger("[user] is too tired to continue giving you a noogie!"))
		return

	var/damage = rand(1, 5)
	if(HAS_TRAIT(target, TRAIT_ANTENNAE))
		damage += rand(3,7)
	if(user.dna?.check_mutation(HULK))
		damage += rand(3,7)

	if(damage >= 5)
		target.emote("scream")

	log_combat(user, target, "given a noogie to", addition = "([damage] brute before armor)")
	target.apply_damage(damage, BRUTE, BODY_ZONE_HEAD)
	user.adjustStaminaLoss(iteration + 5)
	playsound(get_turf(user), pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg'), 50)

	if(prob(33))
		user.visible_message(span_danger("[user] continues noogie'ing [target]!"), span_warning("You continue giving [target] a noogie!"), vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=target)
		to_chat(target, span_userdanger("[user] continues giving you a noogie!"))

	if(!do_after(user, 1 SECONDS + (iteration * 2), target))
		to_chat(user, span_warning("You fail to give [target] a noogie!"))
		to_chat(target, span_danger("[user] fails to give you a noogie!"))
		return

	iteration++
	noogie_loop(user, target, iteration)


/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")
	hitsound = 'sound/effects/snap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3

/obj/item/slapper/attack(mob/living/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)

	var/slap_volume = 50
	var/datum/status_effect/offering/kiss_check = M.has_status_effect(STATUS_EFFECT_OFFERING)
	if(kiss_check && istype(kiss_check.offered_item, /obj/item/kisser) && (user in kiss_check.possible_takers))
		user.visible_message(span_danger("[user] scoffs at [M]'s advance, winds up, and smacks [M.p_them()] hard to the ground!"),
			span_notice("The nerve! You wind back your hand and smack [M] hard enough to knock [M.p_them()] over!"),
			span_hear("You hear someone get the everloving shit smacked out of them!"), ignored_mobs = M)
		to_chat(M, span_userdanger("You see [user] scoff and pull back [user.p_their()] arm, then suddenly you're on the ground with an ungodly ringing in your ears!"))
		slap_volume = 120
		SEND_SOUND(M, sound('sound/weapons/flash_ring.ogg'))
		shake_camera(M, 2, 2)
		M.Paralyze(2.5 SECONDS)
		M.add_confusion(7)
		M.adjustStaminaLoss(40)
	else if(user.zone_selected == BODY_ZONE_HEAD || user.zone_selected == BODY_ZONE_PRECISE_MOUTH)
		user.visible_message(span_danger("[user] slaps [M] in the face!"),
			span_notice("You slap [M] in the face!"),
			span_hear("You hear a slap."))
	else
		user.visible_message(span_danger("[user] slaps [M]!"),
			span_notice("You slap [M]!"),
			span_hear("You hear a slap."))
	playsound(M, 'sound/weapons/slap.ogg', slap_volume, TRUE, -1)
	return

/obj/item/slapper/attack_atom(obj/O, mob/living/user, params)
	if(!istype(O, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = O
	var/is_right_clicking = LAZYACCESS(params2list(params), RIGHT_CLICK)

	if(is_right_clicking && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		transform = transform.Scale(5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
		SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 110, TRUE)
		user.visible_message("<b>[span_danger("[user] slams [user.p_their()] fist down on [the_table]!")]</b>", "<b>[span_danger("You slam your fist down on [the_table]!")]</b>")
		qdel(src)
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message(span_notice("[user] slaps [user.p_their()] hand on [the_table]."), span_notice("You slap your hand on [the_table]."), vision_distance=COMBAT_MESSAGE_RANGE)
		table_smacks_left--
		if(table_smacks_left <= 0)
			qdel(src)

/obj/item/slapper/on_offered(mob/living/carbon/offerer)
	. = TRUE

	if(!(locate(/mob/living/carbon) in orange(1, offerer)))
		visible_message(span_danger("[offerer] raises [offerer.p_their()] arm, looking around for a high-five, but there's no one around!"), \
			span_warning("You post up, looking for a high-five, but finding no one within range!"), null, 2)
		return

	offerer.visible_message(span_notice("[offerer] raises [offerer.p_their()] arm, looking for a high-five!"), \
		span_notice("You post up, looking for a high-five!"), null, 2)
	offerer.apply_status_effect(STATUS_EFFECT_OFFERING, src, /atom/movable/screen/alert/give/highfive)

/// Yeah broh! This is where we do the high-fiving (or high-tenning :o)
/obj/item/slapper/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)
	. = TRUE

	var/open_hands_taker
	var/slappers_giver
	for(var/i in taker.held_items) // see how many hands the taker has open for high'ing
		if(isnull(i))
			open_hands_taker++

	if(!open_hands_taker)
		to_chat(taker, span_warning("You can't high-five [offerer] with no open hands!"))
		SEND_SIGNAL(taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five_full_hand) // not so successful now!
		return

	for(var/i in offerer.held_items)
		var/obj/item/slapper/slap_check = i
		if(istype(slap_check))
			slappers_giver++

	if(slappers_giver >= 2) // we only check this if it's already established the taker has 2+ hands free
		offerer.visible_message(span_notice("[taker] enthusiastically high-tens [offerer]!"), span_nicegreen("Wow! You're high-tenned [taker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), ignored_mobs=taker)
		to_chat(taker, span_nicegreen("You give high-tenning [offerer] your all!"))
		playsound(offerer, 'sound/weapons/slap.ogg', 100, TRUE, 1)
		offerer.mind.add_memory(MEMORY_HIGH_FIVE, list(DETAIL_PROTAGONIST = taker, DETAIL_HIGHFIVE_TYPE = "high ten"), story_value = STORY_VALUE_OKAY)
		taker.mind.add_memory(MEMORY_HIGH_FIVE, list(DETAIL_PROTAGONIST = offerer, DETAIL_HIGHFIVE_TYPE = "high ten"), story_value = STORY_VALUE_OKAY)
		SEND_SIGNAL(offerer, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
		SEND_SIGNAL(taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_ten)
	else
		offerer.visible_message(span_notice("[taker] high-fives [offerer]!"), span_nicegreen("All right! You're high-fived by [taker]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), ignored_mobs=taker)
		to_chat(taker, span_nicegreen("You high-five [offerer]!"))
		playsound(offerer, 'sound/weapons/slap.ogg', 50, TRUE, -1)
		offerer.mind.add_memory(MEMORY_HIGH_FIVE, list(DETAIL_PROTAGONIST = taker, DETAIL_HIGHFIVE_TYPE = "high five"), story_value = STORY_VALUE_OKAY)
		taker.mind.add_memory(MEMORY_HIGH_FIVE, list(DETAIL_PROTAGONIST = offerer, DETAIL_HIGHFIVE_TYPE = "high five"), story_value = STORY_VALUE_OKAY)
		SEND_SIGNAL(offerer, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
		SEND_SIGNAL(taker, COMSIG_ADD_MOOD_EVENT, "high_five", /datum/mood_event/high_five)
	qdel(src)

/// Gangster secret handshakes.
/obj/item/slapper/secret_handshake
	name = "Secret Handshake"
	icon_state = "recruit"
	icon = 'icons/obj/gang/actions.dmi'
	/// References the active families gamemode handler (if one exists), for adding new family members to.
	var/datum/gang_handler/handler
	/// The typepath of the gang antagonist datum that the person who uses the package should have added to them -- remember that the distinction between e.g. Ballas and Grove Street is on the antag datum level, not the team datum level.
	var/gang_to_use
	/// The team datum that the person who uses this package should be added to.
	var/datum/team/gang/team_to_use


/// Adds the user to the family that this package corresponds to, dispenses the free_clothes of that family, and adds them to the handler if it exists.
/obj/item/slapper/secret_handshake/proc/add_to_gang(mob/living/user, original_name)
	var/datum/antagonist/gang/swappin_sides = new gang_to_use()
	swappin_sides.original_name = original_name
	swappin_sides.handler = handler
	user.mind.add_antag_datum(swappin_sides, team_to_use)
	var/policy = get_policy(ROLE_FAMILIES)
	if(policy)
		to_chat(user, policy)
	team_to_use.add_member(user.mind)
	swappin_sides.equip_gangster_in_inventory()
	if (!isnull(handler) && !handler.gangbangers.Find(user.mind)) // if we have a handler and they're not tracked by it
		handler.gangbangers += user.mind

/// Checks if the user is trying to use the package of the family they are in, and if not, adds them to the family, with some differing processing depending on whether the user is already a family member.
/obj/item/slapper/secret_handshake/proc/attempt_join_gang(mob/living/user)
	if(!user?.mind)
		return
	var/datum/antagonist/gang/is_gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
	var/real_name_backup = user.real_name
	if(is_gangster)
		if(is_gangster.my_gang == team_to_use)
			return
		real_name_backup = is_gangster.original_name
		is_gangster.my_gang.remove_member(user.mind)
		user.mind.remove_antag_datum(/datum/antagonist/gang)
	add_to_gang(user, real_name_backup)

/obj/item/slapper/secret_handshake/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)
	. = TRUE
	if (!(null in taker.held_items))
		to_chat(taker, span_warning("You can't get taught the secret handshake if [offerer] has no free hands!"))
		return

	if(HAS_TRAIT(taker, TRAIT_MINDSHIELD))
		to_chat(taker, "You attended a seminar on not signing up for a gang and are not interested.")
		return

	var/datum/antagonist/gang/is_gangster = taker.mind.has_antag_datum(/datum/antagonist/gang)
	if(is_gangster?.starter_gangster)
		if(is_gangster.my_gang == team_to_use)
			to_chat(taker, "You started your family. You don't need to join it.")
			return
		to_chat(taker, "You started your family. You can't turn your back on it now.")
		return

	offerer.visible_message(span_notice("[taker] is taught the secret handshake by [offerer]!"), span_nicegreen("All right! You've taught the secret handshake to [taker]!"), span_hear("You hear a bunch of weird shuffling and flesh slapping sounds!"), ignored_mobs=taker)
	to_chat(taker, span_nicegreen("You get taught the secret handshake by [offerer]!"))
	var/datum/antagonist/gang/owner_gang_datum = offerer.mind.has_antag_datum(/datum/antagonist/gang)
	handler = owner_gang_datum.handler
	gang_to_use = owner_gang_datum.type
	team_to_use = owner_gang_datum.my_gang
	attempt_join_gang(taker)
	qdel(src)



/obj/item/kisser
	name = "kiss"
	desc = "I want you all to know, everyone and anyone, to seal it with a kiss."
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	inhand_icon_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM
	/// The kind of projectile this version of the kiss blower fires
	var/kiss_type = /obj/projectile/kiss
	/// TRUE if the user was aiming anywhere but the mouth when they offer the kiss, if it's offered
	var/cheek_kiss

/obj/item/kisser/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_GARLIC_BREATH))
		kiss_type = /obj/projectile/kiss/french
	var/obj/projectile/blown_kiss = new kiss_type(get_turf(user))
	user.visible_message("<b>[user]</b> blows \a [blown_kiss] at [target]!", span_notice("You blow \a [blown_kiss] at [target]!"))

	//Shooting Code:
	blown_kiss.original = target
	blown_kiss.fired_from = user
	blown_kiss.firer = user // don't hit ourself that would be really annoying
	blown_kiss.impacted = list(user = TRUE) // just to make sure we don't hit the wearer
	blown_kiss.preparePixelProjectile(target, user)
	blown_kiss.fire()
	qdel(src)

/obj/item/kisser/on_offered(mob/living/carbon/offerer)
	if(!(locate(/mob/living/carbon) in orange(1, offerer)))
		return TRUE

	cheek_kiss = (offerer.zone_selected != BODY_ZONE_PRECISE_MOUTH)
	offerer.visible_message(span_notice("[offerer] leans in slightly, offering a kiss[cheek_kiss ? " on the cheek" : ""]!"),
		span_notice("You lean in slightly, indicating you'd like to offer a kiss[cheek_kiss ? " on the cheek" : ""]!"), null, 2)
	offerer.apply_status_effect(STATUS_EFFECT_OFFERING, src)
	return TRUE

/obj/item/kisser/on_offer_taken(mob/living/carbon/offerer, mob/living/carbon/taker)
	var/obj/projectile/blown_kiss = new kiss_type(get_turf(offerer))
	offerer.visible_message("<b>[offerer]</b> gives [taker] \a [blown_kiss][cheek_kiss ? " on the cheek" : ""]!!", span_notice("You give [taker] \a [blown_kiss][cheek_kiss ? " on the cheek" : ""]!"), ignored_mobs = taker)
	to_chat(taker, span_nicegreen("[offerer] gives you \a [blown_kiss][cheek_kiss ? " on the cheek" : ""]!"))
	offerer.face_atom(taker)
	taker.face_atom(offerer)
	offerer.do_item_attack_animation(taker, used_item=src)
	//We're still firing a shot here because I don't want to deal with some weird edgecase where direct impacting them with the projectile causes it to freak out because there's no angle or something
	blown_kiss.original = taker
	blown_kiss.fired_from = offerer
	blown_kiss.firer = offerer // don't hit ourself that would be really annoying
	blown_kiss.impacted = list(offerer = TRUE) // just to make sure we don't hit the wearer
	blown_kiss.preparePixelProjectile(taker, offerer)
	blown_kiss.suppressed = SUPPRESSED_VERY // this also means it's a direct offer
	blown_kiss.fire()
	qdel(src)
	return TRUE // so the core offering code knows to halt

/obj/item/kisser/death
	name = "kiss of death"
	desc = "If looks could kill, they'd be this."
	color = COLOR_BLACK
	kiss_type = /obj/projectile/kiss/death

/obj/projectile/kiss
	name = "kiss"
	icon = 'icons/mob/animal.dmi'
	icon_state = "heart"
	hitsound = 'sound/effects/kiss.ogg'
	hitsound_wall = 'sound/effects/kiss.ogg'
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	speed = 1.6
	damage_type = BRUTE
	damage = 0
	nodamage = TRUE // love can't actually hurt you
	armour_penetration = 100 // but if it could, it would cut through even the thickest plate

/obj/projectile/kiss/fire(angle, atom/direct_target)
	if(firer)
		name = "[name] blown by [firer]"
	return ..()

/obj/projectile/kiss/Impact(atom/A)
	if(!nodamage || !isliving(A)) // if we do damage or we hit a nonliving thing, we don't have to worry about a harmless hit because we can't wrongly do damage anyway
		return ..()

	harmless_on_hit(A)
	qdel(src)
	return FALSE

/**
 * To get around shielded hardsuits & such being set off by kisses when they shouldn't, we take a page from hallucination projectiles
 * and simply fake our on hit effects. This lets kisses remain incorporeal without having to make some new trait for this one niche situation.
 * This fake hit only happens if we can deal damage and if we hit a living thing. Otherwise, we just do normal on hit effects.
 */
/obj/projectile/kiss/proc/harmless_on_hit(mob/living/living_target)
	playsound(get_turf(living_target), hitsound, 100, TRUE)
	if(!suppressed)  // direct
		living_target.visible_message(span_danger("[living_target] is hit by \a [src]."), span_userdanger("You're hit by \a [src]!"), vision_distance=COMBAT_MESSAGE_RANGE)

	living_target.mind?.add_memory(MEMORY_KISS, list(DETAIL_PROTAGONIST = living_target, DETAIL_KISSER = firer), story_value = STORY_VALUE_OKAY)
	SEND_SIGNAL(living_target, COMSIG_ADD_MOOD_EVENT, "kiss", /datum/mood_event/kiss, firer, suppressed)
	if(isliving(firer))
		var/mob/living/kisser = firer
		kisser.mind?.add_memory(MEMORY_KISS, list(DETAIL_PROTAGONIST = living_target, DETAIL_KISSER = firer), story_value = STORY_VALUE_OKAY, memory_flags = MEMORY_CHECK_BLINDNESS)
	try_fluster(living_target)

/obj/projectile/kiss/proc/try_fluster(mob/living/living_target)
	// people with the social anxiety quirk can get flustered when hit by a kiss
	if(!HAS_TRAIT(living_target, TRAIT_ANXIOUS) || (living_target.stat > SOFT_CRIT) || living_target.is_blind())
		return
	if(HAS_TRAIT(living_target, TRAIT_FEARLESS) || prob(50)) // 50% chance for it to apply, also immune while on meds
		return

	var/other_msg
	var/self_msg
	var/roll = rand(1, 3)
	switch(roll)
		if(1)
			other_msg = "stumbles slightly, turning a bright red!"
			self_msg = "You lose control of your limbs for a moment as your blood rushes to your face, turning it bright red!"
			living_target.add_confusion(rand(5, 10))
		if(2)
			other_msg = "stammers softly for a moment before choking on something!"
			self_msg = "You feel your tongue disappear down your throat as you fight to remember how to make words!"
			addtimer(CALLBACK(living_target, /atom/movable.proc/say, pick("Uhhh...", "O-oh, uhm...", "I- uhhhhh??", "You too!!", "What?")), rand(0.5 SECONDS, 1.5 SECONDS))
			living_target.stuttering += rand(5, 15)
		if(3)
			other_msg = "locks up with a stunned look on [living_target.p_their()] face, staring at [firer ? firer : "the ceiling"]!"
			self_msg = "Your brain completely fails to process what just happened, leaving you rooted in place staring at [firer ? "[firer]" : "the ceiling"] for what feels like an eternity!"
			living_target.face_atom(firer)
			living_target.Stun(rand(3 SECONDS, 8 SECONDS))

	living_target.visible_message("<b>[living_target]</b> [other_msg]", span_userdanger("Whoa! [self_msg]"))

/obj/projectile/kiss/on_hit(atom/target, blocked, pierce_hit)
	def_zone = BODY_ZONE_HEAD // let's keep it PG, people
	. = ..()
	if(isliving(target))
		SEND_SIGNAL(target, COMSIG_ADD_MOOD_EVENT, "kiss", /datum/mood_event/kiss, firer, suppressed)
		try_fluster(target)

/obj/projectile/kiss/death
	name = "kiss of death"
	nodamage = FALSE // okay i kinda lied about love not being able to hurt you
	damage = 35
	wound_bonus = 0
	sharpness = SHARP_POINTY
	color = COLOR_BLACK

/obj/projectile/kiss/death/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/heartbreakee = target
	var/obj/item/organ/heart/dont_go_breakin_my_heart = heartbreakee.getorganslot(ORGAN_SLOT_HEART)
	dont_go_breakin_my_heart.applyOrganDamage(999)


/obj/projectile/kiss/french
	name = "french kiss (is that a hint of garlic?)"
	color = "#f2e9d2" //Scientifically proven to be the colour of garlic

/obj/projectile/kiss/french/harmless_on_hit(mob/living/living_target)
	. = ..()
	//Don't stack the garlic
	if(! living_target.has_reagent(/datum/reagent/consumable/garlic) )
		//Phwoar
		living_target.reagents.add_reagent(/datum/reagent/consumable/garlic, 1)
	living_target.visible_message("[living_target] has a funny look on [living_target.p_their()] face.", "Wow, that is a strong after taste of garlic!", vision_distance=COMBAT_MESSAGE_RANGE)
