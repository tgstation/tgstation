
/*
	Blunt/Bone wounds
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/datum/wound_pregen_data/bone
	abstract = TRUE
	required_limb_biostate = BIO_BONE

	required_wounding_types = list(WOUND_BLUNT)

	wound_series = WOUND_SERIES_BONE_BLUNT_BASIC

/datum/wound/blunt/bone
	name = "Blunt (Bone) Wound"
	wound_flags = (ACCEPTS_GAUZE)

	default_scar_file = BONE_SCAR_FILE

	/// Have we been bone gel'd?
	var/gelled
	/// Have we been taped?
	var/taped
	/// If we did the gel + surgical tape healing method for fractures, how many ticks does it take to heal by default
	var/regen_ticks_needed
	/// Our current counter for gel + surgical tape regeneration
	var/regen_ticks_current
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// If this is a chest wound and this is set, we have this chance to cough up blood when hit in the chest
	var/internal_bleeding_chance = 0

/*
	Overwriting of base procs
*/
/datum/wound/blunt/bone/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message(span_danger("[victim] drops [I] in shock!"), span_warning("<b>The force on your [limb.plaintext_zone] causes you to drop [I]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()
	return ..()

/datum/wound/blunt/bone/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, COMSIG_LIVING_UNARMED_ATTACK)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(attack_with_hurt_hand))

	return ..()

/datum/wound/blunt/bone/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	limp_chance = 0
	QDEL_NULL(active_trauma)
	return ..()

/datum/wound/blunt/bone/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	var/is_bone_limb = ((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
	if(!gelled || (!taped && !is_bone_limb))
		return

	regen_ticks_current++
	if(victim.body_position == LYING_DOWN)
		if(SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1
		if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
			regen_ticks_current += 1

	if(!is_bone_limb && SPT_PROB(severity * 1.5, seconds_per_tick))
		victim.take_bodypart_damage(rand(1, severity * 2), wound_bonus=CANT_WOUND)
		victim.adjustStaminaLoss(rand(2, severity * 2.5))
		if(prob(33))
			to_chat(victim, span_danger("You feel a sharp pain in your body as your bones are reforming!"))

	if(regen_ticks_current > regen_ticks_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, span_green("Your [limb.plaintext_zone] has recovered from its [name]!"))
		remove_wound()

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/bone/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	SIGNAL_HANDLER

	if(victim.get_active_hand() != limb || !proximity || !victim.combat_mode || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return NONE

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(prob((severity - 1) * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * (severity - 1)))
			to_chat(victim, span_userdanger("The fracture in your [limb.plaintext_zone] shoots with pain as you strike [target]!"))
			limb.receive_damage(brute=rand(1,5))
		else
			victim.visible_message(span_danger("[victim] weakly strikes [target] with [victim.p_their()] broken [limb.plaintext_zone], recoiling from pain!"), \
			span_userdanger("You fail to strike [target] as the fracture in your [limb.plaintext_zone] lights up in unbearable pain!"), vision_distance=COMBAT_MESSAGE_RANGE)
			INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7))
			return COMPONENT_CANCEL_ATTACK_CHAIN

	return NONE

/datum/wound/blunt/bone/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(HAS_TRAIT(human_victim, TRAIT_NOBLOOD))
			return

	if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume && prob(internal_bleeding_chance + wounding_dmg))
		var/blood_bled = rand(1, wounding_dmg * (severity == WOUND_SEVERITY_CRITICAL ? 2 : 1.5)) // 12 brute toolbox can cause up to 18/24 bleeding with a severe/critical chest wound
		switch(blood_bled)
			if(1 to 6)
				victim.bleed(blood_bled, TRUE)
			if(7 to 13)
				victim.visible_message("<span class='smalldanger'>A thin stream of blood drips from [victim]'s mouth from the blow to [victim.p_their()] chest.</span>", span_danger("You cough up a bit of blood from the blow to your chest."), vision_distance=COMBAT_MESSAGE_RANGE)
				victim.bleed(blood_bled, TRUE)
			if(14 to 19)
				victim.visible_message("<span class='smalldanger'>Blood spews out of [victim]'s mouth from the blow to [victim.p_their()] chest!</span>", span_danger("You spit out a string of blood from the blow to your chest!"), vision_distance=COMBAT_MESSAGE_RANGE)
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
				victim.bleed(blood_bled)
			if(20 to INFINITY)
				victim.visible_message(span_danger("Blood spurts out of [victim]'s mouth from the blow to [victim.p_their()] chest!"), span_danger("<b>You choke up on a spray of blood from the blow to your chest!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)
				victim.bleed(blood_bled)
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
				victim.add_splatter_floor(get_step(victim.loc, victim.dir))

/datum/wound/blunt/bone/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze)
		if(taped)
			. += ", [span_notice("and appears to be reforming itself under some surgical tape!")]"
		else if(gelled)
			. += ", [span_notice("with fizzing flecks of blue bone gel sparking off the bone!")]"

/datum/wound/blunt/get_limb_examine_description()
	return span_warning("The bones in this limb appear badly cracked.")

/*
	New common procs for /datum/wound/blunt/bone/
*/

/datum/wound/blunt/bone/get_scar_file(obj/item/bodypart/scarred_limb, add_to_scars)
	if (scarred_limb.biological_state & BIO_BONE && (!(scarred_limb.biological_state & BIO_FLESH))) // only bone
		return BONE_SCAR_FILE
	else if (scarred_limb.biological_state & BIO_FLESH && (!(scarred_limb.biological_state & BIO_BONE)))
		return FLESH_SCAR_FILE

	return ..()

/// Joint Dislocation (Moderate Blunt)
/datum/wound/blunt/bone/moderate
	name = "Joint Dislocation"
	desc = "Patient's limb has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation by applying an aggressive grab to the patient and helpfully interacting with afflicted limb may suffice."
	examine_desc = "is awkwardly janked out of place"
	occur_text = "janks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.3
	limp_slowdown = 3
	limp_chance = 50
	threshold_penalty = 15
	treatable_tools = list(TOOL_BONESET)
	status_effect_type = /datum/status_effect/wound/blunt/bone/moderate
	scar_keyword = "dislocate"

	simple_desc = "Patient's bone has been dislocated, causing limping or reduced dexterity."
	simple_treat_text = "<b>Bandaging</b> the wound will reduce its impact until treated with a bonesetter. Most commonly, it is treated by aggressively grabbing someone and helpfully wrenching the limb in place, though there's room for malfeasance when doing this."
	homemade_treat_text = "Besides bandaging and wrenching, <b>bone setters</b> can be printed in lathes and utilized on oneself at the cost of great pain. As a last resort, <b>crushing</b> the patient with a <b>firelock</b> has sometimes been noted to fix their dislocated limb."

/datum/wound_pregen_data/bone/dislocate
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/moderate

	required_limb_biostate = BIO_JOINTED

	threshold_minimum = 35

/datum/wound/blunt/bone/moderate/Destroy()
	if(victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	return ..()

/datum/wound/blunt/bone/moderate/set_victim(new_victim)

	if (victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_DOORCRUSHED, PROC_REF(door_crush))

	return ..()

/// Getting smushed in an airlock/firelock is a last-ditch attempt to try relocating your limb
/datum/wound/blunt/bone/moderate/proc/door_crush()
	SIGNAL_HANDLER
	if(prob(40))
		victim.visible_message(span_danger("[victim]'s dislocated [limb.plaintext_zone] pops back into place!"), span_userdanger("Your dislocated [limb.plaintext_zone] pops back into place! Ow!"))
		remove_wound()

/datum/wound/blunt/bone/moderate/try_handling(mob/living/user)
	if(user.usable_hands <= 0 || user.pulling != victim)
		return FALSE
	if(!isnull(user.hud_used?.zone_select) && user.zone_selected != limb.body_zone)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, span_warning("You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [LOWER_TEXT(name)]!"))
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message(span_danger("[user] begins twisting and straining [victim]'s dislocated [limb.plaintext_zone]!"), span_notice("You begin twisting and straining [victim]'s dislocated [limb.plaintext_zone]..."), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] begins twisting and straining your dislocated [limb.plaintext_zone]!"))
		if(!user.combat_mode)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our dislocated joint back into place by hand with an aggro grab and help intent
/datum/wound/blunt/bone/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] snaps [victim]'s dislocated [limb.plaintext_zone] back into place!"), span_notice("You snap [victim]'s dislocated [limb.plaintext_zone] back into place!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] snaps your dislocated [limb.plaintext_zone] back into place!"))
		victim.emote("scream")
		limb.receive_damage(brute=20, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message(span_danger("[user] wrenches [victim]'s dislocated [limb.plaintext_zone] around painfully!"), span_danger("You wrench [victim]'s dislocated [limb.plaintext_zone] around painfully!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] wrenches your dislocated [limb.plaintext_zone] around painfully!"))
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/blunt/bone/moderate/proc/malpractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	if(prob(65))
		user.visible_message(span_danger("[user] snaps [victim]'s dislocated [limb.plaintext_zone] with a sickening crack!"), span_danger("You snap [victim]'s dislocated [limb.plaintext_zone] with a sickening crack!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] snaps your dislocated [limb.plaintext_zone] with a sickening crack!"))
		victim.emote("scream")
		limb.receive_damage(brute=25, wound_bonus=30)
	else
		user.visible_message(span_danger("[user] wrenches [victim]'s dislocated [limb.plaintext_zone] around painfully!"), span_danger("You wrench [victim]'s dislocated [limb.plaintext_zone] around painfully!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] wrenches your dislocated [limb.plaintext_zone] around painfully!"))
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		malpractice(user)


/datum/wound/blunt/bone/moderate/treat(obj/item/I, mob/user)
	var/scanned = HAS_TRAIT(src, TRAIT_WOUND_SCANNED)
	var/self_penalty_mult = user == victim ? 1.5 : 1
	var/scanned_mult = scanned ? 0.5 : 1
	var/treatment_delay = base_treat_time * self_penalty_mult * scanned_mult

	if(victim == user)
		victim.visible_message(span_danger("[user] begins [scanned ? "expertly" : ""] resetting [victim.p_their()] [limb.plaintext_zone] with [I]."), span_warning("You begin resetting your [limb.plaintext_zone] with [I][scanned ? ", keeping the holo-image's indications in mind" : ""]..."))
	else
		user.visible_message(span_danger("[user] begins [scanned ? "expertly" : ""] resetting [victim]'s [limb.plaintext_zone] with [I]."), span_notice("You begin resetting [victim]'s [limb.plaintext_zone] with [I][scanned ? ", keeping the holo-image's indications in mind" : ""]..."))

	if(!do_after(user, treatment_delay, target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return

	if(victim == user)
		limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message(span_danger("[user] finishes resetting [victim.p_their()] [limb.plaintext_zone]!"), span_userdanger("You reset your [limb.plaintext_zone]!"))
	else
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message(span_danger("[user] finishes resetting [victim]'s [limb.plaintext_zone]!"), span_nicegreen("You finish resetting [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] resets your [limb.plaintext_zone]!"))

	victim.emote("scream")
	qdel(src)

/*
	Severe (Hairline Fracture)
*/

/datum/wound/blunt/bone/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though a sling of medical gauze will prevent worsening situation."
	examine_desc = "appears grotesquely swollen, jagged bumps hinting at chips in the bone"
	occur_text = "sprays chips of bone and develops a nasty looking bruise"

	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/severe
	scar_keyword = "bluntsevere"
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	internal_bleeding_chance = 40
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR)
	regen_ticks_needed = 120 // ticks every 2 seconds, 240 seconds, so roughly 4 minutes default

	simple_desc = "Patient's bone has cracked in the middle, drastically reducing limb functionality."
	simple_treat_text = "<b>Bandaging</b> the wound will reduce its impact until <b>surgically treated</b> with bone gel and surgical tape."
	homemade_treat_text = "<b>Bone gel and surgical tape</b> may be applied directly to the wound, though this is quite difficult for most people to do so individually unless they've dosed themselves with one or more <b>painkillers</b> (Morphine and Miner's Salve have been known to help)"


/datum/wound_pregen_data/bone/hairline
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/severe

	threshold_minimum = 60

/// Compound Fracture (Critical Blunt)
/datum/wound/blunt/bone/critical
	name = "Compound Fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "is thoroughly pulped and cracked, exposing shards of bone to open air"
	occur_text = "cracks apart, exposing broken bones to open air"

	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 2.5
	limp_slowdown = 7
	limp_chance = 70
	sound_effect = 'sound/effects/wounds/crack2.ogg'
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/bone/critical
	scar_keyword = "bluntcritical"
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	internal_bleeding_chance = 60
	wound_flags = (ACCEPTS_GAUZE | MANGLES_INTERIOR)
	regen_ticks_needed = 240 // ticks every 2 seconds, 480 seconds, so roughly 8 minutes default

	simple_desc = "Patient's bones have effectively shattered completely, causing total immobilization of the limb."
	simple_treat_text = "<b>Bandaging</b> the wound will slightly reduce its impact until <b>surgically treated</b> with bone gel and surgical tape."
	homemade_treat_text = "Although this is extremely difficult and slow to function, <b>Bone gel and surgical tape</b> may be applied directly to the wound, though this is nigh-impossible for most people to do so individually unless they've dosed themselves with one or more <b>painkillers</b> (Morphine and Miner's Salve have been known to help)"

/datum/wound_pregen_data/bone/compound
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/bone/critical

	threshold_minimum = 115

// doesn't make much sense for "a" bone to stick out of your head
/datum/wound/blunt/bone/critical/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = null, smited = FALSE, attack_direction = null, wound_source = "Unknown", replacing = FALSE)
	if(L.body_zone == BODY_ZONE_HEAD)
		occur_text = "splits open, exposing a bare, cracked skull through the flesh and blood"
		examine_desc = "has an unsettling indent, with bits of skull poking out"
	. = ..()

/// if someone is using bone gel on our wound
/datum/wound/blunt/bone/proc/gel(obj/item/stack/medical/bone_gel/I, mob/user)
	// skellies get treated nicer with bone gel since their "reattach dismembered limbs by hand" ability sucks when it's still critically wounded
	if((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
		return skelly_gel(I, user)

	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already coated with bone gel!"))
		return TRUE

	user.visible_message(span_danger("[user] begins hastily applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin hastily applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the warning label..."))

	if(!do_after(user, base_treat_time * 1.5 * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	I.use(1)
	victim.emote("scream")
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you can feel the bones exploding with pain as they begin melting and reforming!"))
	else
		if(!HAS_TRAIT(victim, TRAIT_ANALGESIA))
			if(prob(25 + (20 * (severity - 2)) - min(victim.get_drunk_amount(), 10))) // 25%/45% chance to fail self-applying with severe and critical wounds, modded by drunkenness
				victim.visible_message(span_danger("[victim] fails to finish applying [I] to [victim.p_their()] [limb.plaintext_zone], passing out from the pain!"), span_notice("You pass out from the pain of applying [I] to your [limb.plaintext_zone] before you can finish!"))
				victim.AdjustUnconscious(5 SECONDS)
				return TRUE
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], grimacing from the pain!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and your bones explode in pain!"))

	limb.receive_damage(25, wound_bonus=CANT_WOUND)
	victim.adjustStaminaLoss(100)
	gelled = TRUE
	return TRUE

/// skellies are less averse to bone gel, since they're literally all bone
/datum/wound/blunt/bone/proc/skelly_gel(obj/item/stack/medical/bone_gel/I, mob/user)
	if(gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already coated with bone gel!"))
		return

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [I] to your [limb.plaintext_zone], and you feel a funny fizzy tickling as they begin to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [I] to your [limb.plaintext_zone], and feel a funny fizzy tickling as the bone begins to reform!"))

	gelled = TRUE
	processes = TRUE
	return TRUE

/// if someone is using surgical tape on our wound
/datum/wound/blunt/bone/proc/tape(obj/item/stack/sticky_tape/surgical/I, mob/user)
	if(!gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] must be coated with bone gel to perform this emergency operation!"))
		return TRUE
	if(taped)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already wrapped in [I.name] and reforming!"))
		return TRUE

	user.visible_message(span_danger("[user] begins applying [I] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]..."))

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if(victim == user)
		regen_ticks_needed *= 1.5

	I.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [I] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [I] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_green("[user] finishes applying [I] to your [limb.plaintext_zone], you immediately begin to feel your bones start to reform!"))
	else
		victim.visible_message(span_notice("[victim] finishes applying [I] to [victim.p_their()] [limb.plaintext_zone], !"), span_green("You finish applying [I] to your [limb.plaintext_zone], and you immediately begin to feel your bones start to reform!"))

	taped = TRUE
	processes = TRUE
	return TRUE

/datum/wound/blunt/bone/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/bone_gel))
		return gel(I, user)
	else if(istype(I, /obj/item/stack/sticky_tape/surgical))
		return tape(I, user)

/datum/wound/blunt/bone/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(severity > WOUND_SEVERITY_MODERATE)
		if((limb.biological_state & BIO_BONE) && !(limb.biological_state & BIO_FLESH))
			if(!gelled)
				. += "Recommended Treatment: Apply bone gel directly to injured limb. Creatures of pure bone don't seem to mind bone gel application nearly as much as fleshed individuals. Surgical tape will also be unnecessary.\n"
			else
				. += "[span_notice("Note: Bone regeneration in effect. Bone is [round(regen_ticks_current*100/regen_ticks_needed)]% regenerated.")]\n"
		else
			if(!gelled)
				. += "Alternative Treatment: Apply bone gel directly to injured limb, then apply surgical tape to begin bone regeneration. This is both excruciatingly painful and slow, and only recommended in dire circumstances.\n"
			else if(!taped)
				. += "[span_notice("Continue Alternative Treatment: Apply surgical tape directly to injured limb to begin bone regeneration. Note, this is both excruciatingly painful and slow, though sleep or laying down will speed recovery.")]\n"
			else
				. += "[span_notice("Note: Bone regeneration in effect. Bone is [round(regen_ticks_current*100/regen_ticks_needed)]% regenerated.")]\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Cranial Trauma Detected: Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] brain traumas until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume)
		. += "Ribcage Trauma Detected: Further trauma to chest is likely to worsen internal bleeding until bone is repaired."
	. += "</div>"
