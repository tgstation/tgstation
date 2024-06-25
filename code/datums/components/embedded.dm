/*
	This component is responsible for handling individual instances of embedded objects. The embeddable element is what allows an item to be embeddable and stores its embedding stats,
	and when it impacts and meets the requirements to stick into something, it instantiates an embedded component. Once the item falls out, the component is destroyed, while the
	element survives to embed another day.

		- Carbon embedding has all the classical embedding behavior, and tracks more events and signals. The main behaviors and hooks to look for are:
			-- Every process tick, there is a chance to randomly proc pain, controlled by pain_chance. There may also be a chance for the object to fall out randomly, per fall_chance
			-- Every time the mob moves, there is a chance to proc jostling pain, controlled by jostle_chance (and only 50% as likely if the mob is walking or crawling)
			-- Various signals hooking into carbon topic() and the embed removal surgery in order to handle removals.


	In addition, there are 2 cases of embedding: embedding, and sticking

		- Embedding involves harmful and dangerous embeds, whether they cause brute damage, stamina damage, or a mix. This is the default behavior for embeddings, for when something is "pointy"

		- Sticking occurs when an item should not cause any harm while embedding (imagine throwing a sticky ball of tape at someone, rather than a shuriken). An item is considered "sticky"
			when it has 0 for both pain multiplier and jostle pain multiplier. It's a bit arbitrary, but fairly straightforward.

		Stickables differ from embeds in the following ways:
			-- Text descriptors use phrasing like "X is stuck to Y" rather than "X is embedded in Y"
			-- There is no slicing sound on impact
			-- All damage checks and bloodloss are skipped

*/

/datum/component/embedded
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/bodypart/limb
	var/obj/item/weapon

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance // not like we really need it once we're already stuck in but hey
	var/fall_chance
	var/pain_chance
	var/pain_mult
	var/impact_pain_mult
	var/remove_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct

	///if both our pain multiplier and jostle pain multiplier are 0, we're harmless and can omit most of the damage related stuff
	var/harmful

/datum/component/embedded/Initialize(obj/item/I,
			datum/thrownthing/throwingdatum,
			obj/item/bodypart/part,
			embed_chance = EMBED_CHANCE,
			fall_chance = EMBEDDED_ITEM_FALLOUT,
			pain_chance = EMBEDDED_PAIN_CHANCE,
			pain_mult = EMBEDDED_PAIN_MULTIPLIER,
			remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
			impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
			rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
			ignore_throwspeed_threshold = FALSE,
			jostle_chance = EMBEDDED_JOSTLE_CHANCE,
			jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
			pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)

	if(!iscarbon(parent) || !isitem(I))
		return COMPONENT_INCOMPATIBLE

	if(part)
		limb = part
	src.embed_chance = embed_chance
	src.fall_chance = fall_chance
	src.pain_chance = pain_chance
	src.pain_mult = pain_mult
	src.remove_pain_mult = remove_pain_mult
	src.rip_time = rip_time
	src.impact_pain_mult = impact_pain_mult
	src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	src.jostle_chance = jostle_chance
	src.jostle_pain_mult = jostle_pain_mult
	src.pain_stam_pct = pain_stam_pct
	src.weapon = I

	if(!weapon.isEmbedHarmless())
		harmful = TRUE

	weapon.embedded(parent, part)
	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/victim = parent

	limb._embed_object(weapon) // on the inside... on the inside...
	weapon.forceMove(victim)
	RegisterSignals(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(weaponDeleted))
	victim.visible_message(span_danger("[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] [victim]'s [limb.plaintext_zone]!"), span_userdanger("[weapon] [harmful ? "embeds" : "sticks"] itself [harmful ? "in" : "to"] your [limb.plaintext_zone]!"))

	var/damage = weapon.throwforce
	if(harmful)
		victim.throw_alert(ALERT_EMBEDDED_OBJECT, /atom/movable/screen/alert/embeddedobject)
		playsound(victim,'sound/weapons/bladeslice.ogg', 40)
		if (limb.can_bleed())
			weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!
		damage += weapon.w_class * impact_pain_mult
		victim.add_mood_event("embedded", /datum/mood_event/embedded)

	if(damage > 0)
		var/armor = victim.run_armor_check(limb.body_zone, MELEE, "Your armor has protected your [limb.plaintext_zone].", "Your armor has softened a hit to your [limb.plaintext_zone].",I.armour_penetration, weak_against_armour = I.weak_against_armour)
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, blocked=armor, wound_bonus = I.wound_bonus, bare_wound_bonus = I.bare_wound_bonus, sharpness = I.get_sharpness())
		victim.adjustStaminaLoss(pain_stam_pct * damage)

/datum/component/embedded/Destroy()
	var/mob/living/carbon/victim = parent
	if(victim && !victim.has_embedded_objects())
		victim.clear_alert(ALERT_EMBEDDED_OBJECT)
		victim.clear_mood_event("embedded")
	if(weapon)
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	weapon = null
	limb = null
	return ..()

/datum/component/embedded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(jostleCheck))
	RegisterSignal(parent, COMSIG_CARBON_EMBED_RIP, PROC_REF(ripOut))
	RegisterSignal(parent, COMSIG_CARBON_EMBED_REMOVAL, PROC_REF(safeRemove))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(checkTweeze))
	RegisterSignal(parent, COMSIG_MAGIC_RECALL, PROC_REF(magic_pull))

/datum/component/embedded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_EMBED_RIP, COMSIG_CARBON_EMBED_REMOVAL, COMSIG_ATOM_ATTACKBY, COMSIG_MAGIC_RECALL))

/datum/component/embedded/process(seconds_per_tick)
	var/mob/living/carbon/victim = parent

	if(!victim || !limb) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
		weapon.forceMove(get_turf(weapon))
		qdel(src)
		return

	if(victim.stat == DEAD)
		return

	var/damage = weapon.w_class * pain_mult
	var/pain_chance_current = SPT_PROB_RATE(pain_chance / 100, seconds_per_tick) * 100
	if(pain_stam_pct && HAS_TRAIT_FROM(victim, TRAIT_INCAPACITATED, STAMINA)) //if it's a less-lethal embed, give them a break if they're already stamcritted
		pain_chance_current *= 0.2
		damage *= 0.5
	else if(victim.body_position == LYING_DOWN)
		pain_chance_current *= 0.2

	if(harmful && prob(pain_chance_current))
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, wound_bonus = CANT_WOUND)
		victim.adjustStaminaLoss(pain_stam_pct * damage)
		to_chat(victim, span_userdanger("[weapon] embedded in your [limb.plaintext_zone] hurts!"))

	var/fall_chance_current = SPT_PROB_RATE(fall_chance / 100, seconds_per_tick) * 100
	if(victim.body_position == LYING_DOWN)
		fall_chance_current *= 0.2

	if(prob(fall_chance_current))
		fallOut()

////////////////////////////////////////
////////////BEHAVIOR PROCS//////////////
////////////////////////////////////////


/// Called every time a carbon with a harmful embed moves, rolling a chance for the item to cause pain. The chance is halved if the carbon is crawling or walking.
/datum/component/embedded/proc/jostleCheck()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	var/chance = jostle_chance
	if(victim.move_intent == MOVE_INTENT_WALK || victim.body_position == LYING_DOWN)
		chance *= 0.5

	if(harmful && prob(chance))
		var/damage = weapon.w_class * jostle_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, wound_bonus = CANT_WOUND)
		victim.adjustStaminaLoss(pain_stam_pct * damage)
		to_chat(victim, span_userdanger("[weapon] embedded in your [limb.plaintext_zone] jostles and stings!"))


/// Called when then item randomly falls out of a carbon. This handles the damage and descriptors, then calls safe_remove()
/datum/component/embedded/proc/fallOut()
	var/mob/living/carbon/victim = parent

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, wound_bonus = CANT_WOUND)
		victim.adjustStaminaLoss(pain_stam_pct * damage)
	victim.visible_message(span_danger("[weapon] falls [harmful ? "out" : "off"] of [victim.name]'s [limb.plaintext_zone]!"), span_userdanger("[weapon] falls [harmful ? "out" : "off"] of your [limb.plaintext_zone]!"))
	safeRemove()


/// Called when a carbon with an object embedded/stuck to them inspects themselves and clicks the appropriate link to begin ripping the item out. This handles the ripping attempt, descriptors, and dealing damage, then calls safe_remove()
/datum/component/embedded/proc/ripOut(datum/source, obj/item/I, obj/item/bodypart/limb)
	SIGNAL_HANDLER

	if(I != weapon || src.limb != limb)
		return
	var/mob/living/carbon/victim = parent
	var/time_taken = rip_time * weapon.w_class
	INVOKE_ASYNC(src, PROC_REF(complete_rip_out), victim, I, limb, time_taken)

/// everything async that ripOut used to do
/datum/component/embedded/proc/complete_rip_out(mob/living/carbon/victim, obj/item/I, obj/item/bodypart/limb, time_taken)
	victim.visible_message(span_warning("[victim] attempts to remove [weapon] from [victim.p_their()] [limb.plaintext_zone]."),span_notice("You attempt to remove [weapon] from your [limb.plaintext_zone]... (It will take [DisplayTimeText(time_taken)])"))
	if(!do_after(victim, time_taken, target = victim))
		return
	if(!weapon || !limb || weapon.loc != victim || !(weapon in limb.embedded_objects))
		qdel(src)
		return
	if(harmful)
		damaging_removal(victim, I, limb)

	victim.visible_message(span_notice("[victim] successfully rips [weapon] [harmful ? "out" : "off"] of [victim.p_their()] [limb.plaintext_zone]!"), span_notice("You successfully remove [weapon] from your [limb.plaintext_zone]."))
	safeRemove(victim)

/// Proc that actually does the damage associated with ripping something out of yourself. Call this before safeRemove.
/datum/component/embedded/proc/damaging_removal(mob/living/carbon/victim, obj/item/removed, obj/item/bodypart/limb, ouch_multiplier = 1)
	var/damage = weapon.w_class * remove_pain_mult * ouch_multiplier
	limb.receive_damage(brute=(1-pain_stam_pct) * damage, sharpness=SHARP_EDGED) //It hurts to rip it out, get surgery you dingus. unlike the others, this CAN wound + increase slash bloodflow
	victim.adjustStaminaLoss(pain_stam_pct * damage)
	victim.emote("scream")

/// This proc handles the final step and actual removal of an embedded/stuck item from a carbon, whether or not it was actually removed safely.
/// If you want the thing to go into someone's hands rather than the floor, pass them in to_hands
/datum/component/embedded/proc/safeRemove(mob/to_hands)
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb._unembed_object(weapon)
	UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING)) // have to do it here otherwise we trigger weaponDeleted()

	SEND_SIGNAL(weapon, COMSIG_ITEM_UNEMBEDDED, victim)
	if(!weapon.unembedded()) // if it hasn't deleted itself due to drop del
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
		if(to_hands)
			INVOKE_ASYNC(to_hands, TYPE_PROC_REF(/mob, put_in_hands), weapon)
		else
			weapon.forceMove(get_turf(victim))

	qdel(src)

/// Something deleted or moved our weapon while it was embedded, how rude!
/datum/component/embedded/proc/weaponDeleted()
	SIGNAL_HANDLER

	var/mob/living/carbon/victim = parent
	limb._unembed_object(weapon)

	if(victim)
		to_chat(victim, span_userdanger("\The [weapon] that was embedded in your [limb.plaintext_zone] disappears!"))

	qdel(src)

/// The signal for listening to see if someone is using a hemostat on us to pluck out this object
/datum/component/embedded/proc/checkTweeze(mob/living/carbon/victim, obj/item/possible_tweezers, mob/user)
	SIGNAL_HANDLER

	if(!istype(victim) || (possible_tweezers.tool_behaviour != TOOL_HEMOSTAT && possible_tweezers.tool_behaviour != TOOL_WIRECUTTER) || user.zone_selected != limb.body_zone)
		return

	if(weapon != limb.embedded_objects[1]) // just pluck the first one, since we can't easily coordinate with other embedded components affecting this limb who is highest priority
		return

	if(ishuman(victim)) // check to see if the limb is actually exposed
		var/mob/living/carbon/human/victim_human = victim
		if(!victim_human.try_inject(user, limb.body_zone, INJECT_CHECK_IGNORE_SPECIES | INJECT_TRY_SHOW_ERROR_MESSAGE))
			return TRUE

	INVOKE_ASYNC(src, PROC_REF(tweezePluck), possible_tweezers, user)
	return COMPONENT_NO_AFTERATTACK

/// The actual action for pulling out an embedded object with a hemostat
/datum/component/embedded/proc/tweezePluck(obj/item/possible_tweezers, mob/user)
	var/mob/living/carbon/victim = parent
	var/self_pluck = (user == victim)
	// quality of the tool we're using
	var/tweezer_speed = possible_tweezers.toolspeed
	// is this an actual piece of medical equipment
	var/tweezer_safe = (possible_tweezers.tool_behaviour == TOOL_HEMOSTAT)
	var/pluck_time = rip_time * (weapon.w_class * 0.3) * (self_pluck ? 1.5 : 1) * tweezer_speed * (tweezer_safe ? 1 : 1.5)

	if(self_pluck)
		user.visible_message(span_danger("[user] begins plucking [weapon] from [user.p_their()] [limb.plaintext_zone] with [possible_tweezers]..."), span_notice("You start plucking [weapon] from your [limb.plaintext_zone] with [possible_tweezers]... (It will take [DisplayTimeText(pluck_time)])"),\
			vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=victim)
	else
		user.visible_message(span_danger("[user] begins plucking [weapon] from [victim]'s [limb.plaintext_zone] with [possible_tweezers]..."),span_notice("You start plucking [weapon] from [victim]'s [limb.plaintext_zone] with [possible_tweezers]... (It will take [DisplayTimeText(pluck_time)])"), \
			vision_distance=COMBAT_MESSAGE_RANGE, ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] begins plucking [weapon] from your [limb.plaintext_zone] with [possible_tweezers]... (It will take [DisplayTimeText(pluck_time)])"))

	if(!do_after(user, pluck_time, victim))
		if(self_pluck)
			to_chat(user, span_danger("You fail to pluck [weapon] from your [limb.plaintext_zone]."))
		else
			to_chat(user, span_danger("You fail to pluck [weapon] from [victim]'s [limb.plaintext_zone]."))
			to_chat(victim, span_danger("[user] fails to pluck [weapon] from your [limb.plaintext_zone]."))
		return

	to_chat(user, span_notice("You successfully pluck [weapon] from [victim]'s [limb.plaintext_zone][tweezer_safe ? "." : ", but hurt [victim.p_them()] in the process."]"))
	to_chat(victim, span_notice("[user] plucks [weapon] from your [limb.plaintext_zone][tweezer_safe ? "." : ", but it's not perfect."]"))
	if(!tweezer_safe)
		// sure it still hurts but it sucks less
		damaging_removal(victim, weapon, limb, (0.4 * possible_tweezers.w_class))
	safeRemove(user)

/// Called when an object is ripped out of someone's body by magic or other abnormal means
/datum/component/embedded/proc/magic_pull(datum/source, mob/living/caster, obj/marked_item)
	SIGNAL_HANDLER

	if(marked_item != weapon)
		return

	var/mob/living/carbon/victim = parent

	if(!harmful)
		victim.visible_message(span_danger("[marked_item] vanishes from [victim.name]'s [limb.plaintext_zone]!"), span_userdanger("[weapon] vanishes from [limb.plaintext_zone]!"))
		return
	var/damage = weapon.w_class * remove_pain_mult
	limb.receive_damage(brute=(1-pain_stam_pct) * damage * 1.5, sharpness=SHARP_EDGED) // Performs exit wounds and flings the user to the caster if nearby
	victim.cause_wound_of_type_and_severity(WOUND_PIERCE, limb, WOUND_SEVERITY_MODERATE)
	victim.adjustStaminaLoss(pain_stam_pct * damage)
	playsound(get_turf(victim), 'sound/effects/wounds/blood2.ogg', 50, TRUE)

	var/dist = get_dist(caster, victim) //Check if the caster is close enough to yank them in
	if(dist < 7)
		victim.throw_at(caster, get_dist(victim, caster) - 1, 1, caster)
		victim.Paralyze(1 SECONDS)
		victim.visible_message(span_alert("[victim] is sent flying towards [caster] as the [marked_item] tears out of them!"), span_alert("You are launched at [caster] as the [marked_item] tears from your body and towards their hand!"))
	victim.visible_message(span_danger("[marked_item] is violently torn from [victim.name]'s [limb.plaintext_zone]!"), span_userdanger("[weapon] is violently torn from your [limb.plaintext_zone]!"))
