/**
 * CASTIFICO (Ratwood code/modules/roguetown/roguemachine/bounty.dm, /obj/structure/chair/arrestchair): the EXCIDIUM's chair. A
 * wanted person is buckled into it and the one who brought them right clicks it: the machine reads the skull, crushes it twice
 * and pays every bounty posted on that name at the EXCIDIUM, in coin, to the one who turned them in; a corpse is worth half. A
 * living subject chooses: submit, and wake in a castifico collar that pacifies them and forbids their spells until the penance
 * is served (five minutes and a minute for every ten mammons on their head); or perish, and the chair crushes the skull to bone.
 * Outlaws are bitten for touching it. The collar is Ratwood's /obj/item/clothing/neck/roguetown/collar/prisoner once the porter
 * brings it, a plain collar dressed as one until then; its curse lives on the castifico_collar component either way. The
 * LIBERTAS, a tampered CASTIFICO, tears the collar off and blows itself apart.
 */

#define CASTIFICO_SUBMIT "Submit"
#define CASTIFICO_PERISH "Perish"
/// Trait source of the collar's curse on its wearer.
#define CASTIFICO_TRAIT "castifico_collar"
/// Ratwood's castifico collar; not ported yet (the porter's extra types).
#define CASTIFICO_COLLAR_PATH "/obj/item/clothing/neck/roguetown/collar/prisoner"
#define CASTIFICO_SOUND_SNAP 'modular_redtard/economy/sound/beartrap.ogg'
#define CASTIFICO_SOUND_CRUSH pick('modular_redtard/economy/sound/headcrush2.ogg', 'modular_redtard/economy/sound/headcrush3.ogg', 'modular_redtard/economy/sound/headcrush4.ogg')
#define CASTIFICO_SOUND_DONE 'modular_redtard/economy/sound/vite.ogg'
#define CASTIFICO_SOUND_BITE 'modular_redtard/rockhill/sound/combat/hits/bladed/genstab (1).ogg'
#define CASTIFICO_SOUND_OPEN 'modular_redtard/rockhill/sound/doors/pickgood1.ogg'

/obj/structure/chair/wood/rockhill/arrestchair
	/// A subject is being judged in it now.
	var/judging = FALSE
	/// The subject of the judgement chose to submit to the collar (Ratwood submission).
	var/submission = TRUE

/obj/structure/chair/wood/rockhill/arrestchair/examine(mob/user)
	. = ..()
	. += span_info("Buckle a person wanted at the EXCIDIUM into it, then right click it to collect the bounty on their head: in full for the living, who wake in a castifico collar, half for a corpse.")

/obj/structure/chair/wood/rockhill/arrestchair/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !ishuman(user))
		return
	INVOKE_ASYNC(src, PROC_REF(judge), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// The person buckled into the chair, if any.
/obj/structure/chair/wood/rockhill/arrestchair/proc/buckled_subject()
	for(var/mob/living/buckled as anything in buckled_mobs)
		return buckled
	return null

/// Ratwood attack_right(): reads the subject's skull, pays the bounties on their name and collars them, or kills the defiant.
/obj/structure/chair/wood/rockhill/arrestchair/proc/judge(mob/living/carbon/human/turner)
	if(judging)
		say("Analysis already in progress.")
		return
	var/mob/living/subject = buckled_subject()
	if(subject && HAS_TRAIT(turner, TRAIT_OUTLAW))
		bite(turner)
		return
	if(!subject)
		refuse("Cannot begin skull structure analysis without a subject buckled to the Castifico.")
		return
	if(!ishuman(subject))
		refuse("Subject is non-human entity. Aborting...")
		return
	var/mob/living/carbon/human/wanted = subject
	if(!wanted.get_bodypart(BODY_ZONE_HEAD))
		refuse("Subject is missing cranium. Aborting...")
		return
	if(!do_after(turner, rogue_value("machines_castifico_analysis_time"), wanted))
		return
	if(!still_judging(wanted) || judging)
		return
	judging = TRUE
	submission = TRUE
	playsound(src, CASTIFICO_SOUND_SNAP, 100, TRUE, -1)
	wanted.Paralyze(3 SECONDS)
	var/list/datum/rogue_bounty/bounties = bounties_on(wanted)
	say(pick("Performing intra-cranial inspection...", "Analyzing skull structure...", "Commencing cephalic dissection..."))
	sleep(1 SECONDS)
	var/dead = wanted.stat == DEAD
	if(dead && length(bounties))
		refuse("Subject is deceased. Rewarding half of posted bounty amount.")
		sleep(1 SECONDS)
	else if(!dead && wanted.client)
		INVOKE_ASYNC(src, PROC_REF(offer_choice), wanted)
	say("Assessing value of lyfe...")
	sleep(rogue_value("machines_castifico_assessment_time"))
	if(!still_judging(wanted))
		judging = FALSE
		return
	playsound(src, CASTIFICO_SOUND_CRUSH, 100, FALSE, -1)
	wanted.emote("scream")
	wanted.apply_damage(rogue_value("machines_castifico_crush_damage"), BRUTE, BODY_ZONE_HEAD)
	sleep(1 SECONDS)
	playsound(src, CASTIFICO_SOUND_CRUSH, 100, FALSE, -1)
	wanted.emote("agony")
	wanted.apply_damage(rogue_value("machines_castifico_crush_damage"), BRUTE, BODY_ZONE_HEAD)
	sleep(2 SECONDS)
	if(QDELETED(src) || QDELETED(wanted))
		judging = FALSE
		return
	var/reward = collect_bounties(bounties, dead)
	if(length(bounties))
		say("A bounty has been sated.")
		if(reward > 0)
			rogue_coins_out(reward, turner.Adjacent(src) ? turner : null, null, src)
		message_admins("[ADMIN_LOOKUPFLW(turner)] turned in [ADMIN_LOOKUPFLW(wanted)] at the CASTIFICO for [reward] mammons.")
		log_game("BOUNTY: [key_name(turner)] turned in [key_name(wanted)] at the CASTIFICO for [reward]m")
		if(wanted.stat != DEAD)
			put_collar(wanted, reward)
		playsound(src, CASTIFICO_SOUND_SNAP, 100, TRUE, -1)
	else
		refuse("This skull carries no reward, you fool.")
	if(!submission && wanted.stat != DEAD && wanted.Adjacent(src))
		say("Resistance detected...")
		Shake()
		crush_skull(wanted)
	else if(wanted.stat != DEAD)
		wanted.Unconscious(rogue_value("machines_castifico_sleep_time"))
		sleep(2 SECONDS)
		playsound(src, CASTIFICO_SOUND_DONE, 100, FALSE, -1)
	judging = FALSE
	submission = TRUE
	if(!QDELETED(src))
		unbuckle_all_mobs()

/// The subject is still here and still buckled in the chair after the machine slept.
/obj/structure/chair/wood/rockhill/arrestchair/proc/still_judging(mob/living/carbon/human/wanted)
	return !QDELETED(src) && !QDELETED(wanted) && wanted.buckled == src

/// Every bounty posted on the subject's name at the EXCIDIUM (Ratwood: target or hidden target equals the real name).
/obj/structure/chair/wood/rockhill/arrestchair/proc/bounties_on(mob/living/carbon/human/wanted)
	. = list()
	for(var/datum/rogue_bounty/bounty as anything in GLOB.rogue_head_bounties)
		if(bounty.target == wanted.real_name)
			. += bounty

/// Strikes the bounties from the board and returns what they pay: their sum, a share of it for a corpse.
/obj/structure/chair/wood/rockhill/arrestchair/proc/collect_bounties(list/datum/rogue_bounty/bounties, dead)
	var/reward = 0
	for(var/datum/rogue_bounty/bounty as anything in bounties)
		if(!(bounty in GLOB.rogue_head_bounties))
			continue
		GLOB.rogue_head_bounties -= bounty
		reward += bounty.amount
	if(dead)
		reward = floor(reward * rogue_value("machines_castifico_corpse_share"))
	return reward

/// Ratwood giveup(): the subject has a few seconds to submit to the collar or to die.
/obj/structure/chair/wood/rockhill/arrestchair/proc/offer_choice(mob/living/carbon/human/wanted)
	var/choice = tgui_alert(wanted, "Do you submit to the Mask, or do you die? You have 10 seconds to decide.", "CHOICE OF LYFE", list(CASTIFICO_SUBMIT, CASTIFICO_PERISH), rogue_value("machines_castifico_choice_time"))
	if(choice != CASTIFICO_PERISH || QDELETED(src) || QDELETED(wanted) || !judging)
		return
	message_admins("[ADMIN_LOOKUPFLW(wanted)] chose to die to the Excidium.")
	log_admin("[key_name(wanted)] opted to die to the Excidium.")
	if(wanted.Adjacent(src))
		submission = FALSE

/// Ratwood: the defiant's skull is crushed to bone.
/obj/structure/chair/wood/rockhill/arrestchair/proc/crush_skull(mob/living/carbon/human/wanted)
	message_admins("[ADMIN_LOOKUPFLW(wanted)] was killed by the Excidium.")
	log_admin("[key_name(wanted)] was killed by the Excidium.")
	playsound(src, CASTIFICO_SOUND_DONE, 100, FALSE, -1)
	var/obj/item/bodypart/head/skull = wanted.get_bodypart(BODY_ZONE_HEAD)
	if(skull?.rogue_skeletonize())
		wanted.update_body_parts()
	wanted.death()

/// The castifico collar goes on the subject's neck, with the bounty that bought it (Ratwood prisonmask.bounty_amount).
/obj/structure/chair/wood/rockhill/arrestchair/proc/put_collar(mob/living/carbon/human/wanted, bounty)
	var/obj/item/old_collar = wanted.get_item_by_slot(ITEM_SLOT_NECK)
	if(old_collar)
		wanted.dropItemToGround(old_collar, TRUE)
	var/obj/item/collar = rogue_castifico_collar(get_turf(wanted))
	collar.AddComponent(/datum/component/rogue_castifico_collar, bounty)
	if(!wanted.equip_to_slot_or_del(collar, ITEM_SLOT_NECK))
		say("ERROR: COLLAR COULD NOT BE FITTED.")

/// Ratwood: an outlaw who touches the chair is bitten.
/obj/structure/chair/wood/rockhill/arrestchair/proc/bite(mob/living/carbon/human/outlaw)
	playsound(outlaw, CASTIFICO_SOUND_BITE, 100, FALSE, -1)
	visible_message(span_warning("The castifico snaps at [outlaw]'s hand!"))
	to_chat(outlaw, span_danger("The machine wants YOU!"))
	flash_color(outlaw, flash_color = "#C80000", flash_time = 1 SECONDS)
	outlaw.Stun(rogue_value("machines_castifico_bite_stun"))
	outlaw.apply_damage(rogue_value("machines_castifico_bite_damage"), BRUTE, IS_RIGHT_INDEX(outlaw.active_hand_index) ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM)
	outlaw.emote("whimper")

/obj/structure/chair/wood/rockhill/arrestchair/proc/refuse(message)
	say(message)
	playsound(src, ROGUE_SOUND_MACHINE_NO, 100, FALSE, -1)

/// A new castifico collar: Ratwood's own once ported, else a plain collar dressed as one.
/proc/rogue_castifico_collar(atom/spot)
	var/collar_type = text2path(CASTIFICO_COLLAR_PATH)
	if(collar_type)
		return new collar_type(spot)
	var/obj/item/clothing/neck/roguetown/collar/collar = new(spot)
	collar.name = "castifico collar"
	collar.desc = "A metal collar that seals around the neck, making it impossible to remove. It seems to be enchanted with some kind of vile magic..."
	collar.icon = 'modular_redtard/rockhill/icons/roguetown/clothing/neck.dmi'
	collar.icon_state = "castifico_collar"
	collar.resistance_flags |= FIRE_PROOF
	collar.body_parts_covered = NONE
	return collar

/**
 * LIBERTAS (Ratwood /obj/structure/chair/freedomchair): a CASTIFICO tampered with to take the collar off. This one was
 * tampered with badly: it tears the collar off the buckled subject and blows itself apart doing it.
 */
/obj/structure/chair/wood/rockhill/freedomchair/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !ishuman(user))
		return
	INVOKE_ASYNC(src, PROC_REF(free_subject), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/chair/wood/rockhill/freedomchair/proc/free_subject(mob/living/carbon/human/user)
	var/mob/living/carbon/human/subject = locate() in buckled_mobs
	if(!subject)
		say("CANNOT BEGIN WITHOUT SUBJECT BUCKLED.")
		return
	if(!do_after(user, 3 SECONDS, subject) || QDELETED(src) || subject.buckled != src)
		return
	playsound(src, CASTIFICO_SOUND_OPEN, 100, TRUE, -1)
	subject.Paralyze(3 SECONDS)
	var/obj/item/collar = subject.get_item_by_slot(ITEM_SLOT_NECK)
	if(!collar?.GetComponent(/datum/component/rogue_castifico_collar))
		say("ANALYSIS COMPLETE. NO CURSED COLLAR FOUND. ABORT.")
		return
	say("ERROR: UNLAWFUL SYSTEM TAMPERING DETECTED... ENGAGING SELF DESTRUCT...")
	sleep(1 SECONDS)
	if(QDELETED(src))
		return
	explosion(src, light_impact_range = 1, flame_range = 1, explosion_cause = src)
	if(!QDELETED(subject) && !QDELETED(collar))
		subject.dropItemToGround(collar, TRUE)
	qdel(src)

/**
 * The curse of a castifico collar (Ratwood /obj/item/clothing/neck/roguetown/collar/prisoner): it cannot be taken off, it
 * pacifies its wearer and forbids their spells, and it falls apart once the penance is served. Torn off by force, it breaks.
 */
/datum/component/rogue_castifico_collar
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// Mammons of bounty the wearer was turned in for; the penance grows with it.
	var/bounty = 0
	/// Who wears it now.
	var/mob/living/wearer
	var/penance_timer

/datum/component/rogue_castifico_collar/Initialize(bounty = 0)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.bounty = bounty
	var/obj/item/collar = parent
	ADD_TRAIT(collar, TRAIT_NODROP, CURSED_ITEM_TRAIT(collar.type))
	collar.item_flags |= DROPDEL

/datum/component/rogue_castifico_collar/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))

/datum/component/rogue_castifico_collar/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/rogue_castifico_collar/Destroy(force)
	deltimer(penance_timer)
	release()
	return ..()

/// How long the penance lasts (Ratwood: five minutes, and a minute for every ten mammons of a bounty of ten or more).
/datum/component/rogue_castifico_collar/proc/penance_time()
	. = rogue_value("machines_castifico_penance_base")
	if(bounty >= rogue_value("machines_castifico_penance_threshold"))
		. += round(bounty * rogue_value("machines_castifico_penance_per_mammon")) MINUTES

/datum/component/rogue_castifico_collar/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(wearer || !(slot & ITEM_SLOT_NECK) || !isliving(equipper))
		return
	wearer = equipper
	ADD_TRAIT(wearer, TRAIT_PACIFISM, CASTIFICO_TRAIT)
	RegisterSignal(wearer, COMSIG_MOB_RESTRICT_MAGIC, PROC_REF(block_magic))
	RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(on_wearer_deleted))
	to_chat(wearer, span_warning("This accursed collar pacifies me!"))
	var/duration = penance_time()
	penance_timer = addtimer(CALLBACK(src, PROC_REF(penance_served)), duration, TIMER_STOPPABLE)
	INVOKE_ASYNC(source, TYPE_PROC_REF(/atom/movable, say), "YOUR PENANCE WILL BE COMPLETE IN [round(duration / (1 MINUTES))] MINUTES.")

/datum/component/rogue_castifico_collar/proc/on_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	release()

/datum/component/rogue_castifico_collar/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	release()

/// A collared wearer casts no spells (Ratwood TRAIT_SPELLCOCKBLOCK).
/datum/component/rogue_castifico_collar/proc/block_magic(mob/source, magic_flags)
	SIGNAL_HANDLER
	return COMPONENT_MAGIC_BLOCKED

/// Ratwood timerup(): the collar opens and falls apart.
/datum/component/rogue_castifico_collar/proc/penance_served()
	var/obj/item/collar = parent
	if(wearer)
		collar.visible_message(span_warning("The castifico collar opens with a click, falling off of [wearer]'s neck and clambering apart on the ground, their penance complete."))
	collar.say("YOUR PENANCE IS COMPLETE.")
	playsound(collar, CASTIFICO_SOUND_OPEN, 5, TRUE)
	release()
	qdel(collar)

/datum/component/rogue_castifico_collar/proc/release()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_PACIFISM, CASTIFICO_TRAIT)
	UnregisterSignal(wearer, list(COMSIG_MOB_RESTRICT_MAGIC, COMSIG_QDELETING))
	wearer = null

#undef CASTIFICO_SUBMIT
#undef CASTIFICO_PERISH
#undef CASTIFICO_TRAIT
#undef CASTIFICO_COLLAR_PATH
#undef CASTIFICO_SOUND_SNAP
#undef CASTIFICO_SOUND_CRUSH
#undef CASTIFICO_SOUND_DONE
#undef CASTIFICO_SOUND_BITE
#undef CASTIFICO_SOUND_OPEN
