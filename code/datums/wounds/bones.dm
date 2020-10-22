
/*
	Blunt/Bone wounds
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/datum/wound/blunt
	name = "Blunt (Bone) Wound"
	sound_effect = 'sound/effects/wounds/crack1.ogg'
	wound_type = WOUND_BLUNT
	wound_flags = (BONE_WOUND | ACCEPTS_GAUZE)

	/// Have we been taped?
	var/taped
	/// Have we been bone gel'd?
	var/gelled
	/// If we did the gel + surgical tape healing method for fractures, how many regen points we need
	var/regen_points_needed
	/// Our current counter for gel + surgical tape regeneration
	var/regen_points_current
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
/datum/wound/blunt/wound_injury(datum/wound/old_wound = null)
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	RegisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/attack_with_hurt_hand)
	if(limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'>[victim] drops [I] in shock!</span>", "<span class='warning'><b>The force on your [limb.name] causes you to drop [I]!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()

/datum/wound/blunt/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	QDEL_NULL(active_trauma)
	if(victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

/datum/wound/blunt/handle_process()
	. = ..()
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(!regen_points_needed)
		return

	regen_points_current++
	if(prob(severity * 2))
		victim.take_bodypart_damage(rand(1, severity * 2), stamina=rand(2, severity * 2.5), wound_bonus=CANT_WOUND)
		if(prob(33))
			to_chat(victim, "<span class='danger'>You feel a sharp pain in your body as your bones are reforming!</span>")

	if(regen_points_current > regen_points_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, "<span class='green'>Your [limb.name] has recovered from your fracture!</span>")
		remove_wound()

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	SIGNAL_HANDLER

	if(victim.get_active_hand() != limb || victim.a_intent == INTENT_HELP || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(prob((severity - 1) * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * (severity - 1)))
			to_chat(victim, "<span class='userdanger'>The fracture in your [limb.name] shoots with pain as you strike [target]!</span>")
			limb.receive_damage(brute=rand(1,5))
		else
			victim.visible_message("<span class='danger'>[victim] weakly strikes [target] with [victim.p_their()] broken [limb.name], recoiling from pain!</span>", \
			"<span class='userdanger'>You fail to strike [target] as the fracture in your [limb.name] lights up in unbearable pain!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			INVOKE_ASYNC(victim, /mob.proc/emote, "scream")
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7))
			return COMPONENT_CANCEL_ATTACK_CHAIN


/datum/wound/blunt/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return
	if(ishuman(victim))
		var/mob/living/carbon/human/human_victim = victim
		if(NOBLOOD in human_victim.dna?.species.species_traits)
			return

	if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume && prob(internal_bleeding_chance + wounding_dmg))
		var/blood_bled = rand(1, wounding_dmg * (severity == WOUND_SEVERITY_CRITICAL ? 2 : 1.5)) // 12 brute toolbox can cause up to 18/24 bleeding with a severe/critical chest wound
		switch(blood_bled)
			if(1 to 6)
				victim.bleed(blood_bled, TRUE)
			if(7 to 13)
				victim.visible_message("<span class='smalldanger'>[victim] coughs up a bit of blood from the blow to [victim.p_their()] chest.</span>", "<span class='danger'>You cough up a bit of blood from the blow to your chest.</span>", vision_distance=COMBAT_MESSAGE_RANGE)
				victim.bleed(blood_bled, TRUE)
			if(14 to 19)
				victim.visible_message("<span class='smalldanger'>[victim] spits out a string of blood from the blow to [victim.p_their()] chest!</span>", "<span class='danger'>You spit out a string of blood from the blow to your chest!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
				victim.bleed(blood_bled)
			if(20 to INFINITY)
				victim.visible_message("<span class='danger'>[victim] chokes up a spray of blood from the blow to [victim.p_their()] chest!</span>", "<span class='danger'><b>You choke up on a spray of blood from the blow to your chest!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)
				victim.bleed(blood_bled)
				new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
				victim.add_splatter_floor(get_step(victim.loc, victim.dir))


/datum/wound/blunt/get_examine_description(mob/user)
	if(!limb.current_gauze && !gelled && !taped)
		return ..()

	var/list/msg = list()
	if(!limb.current_gauze)
		msg += "[victim.p_their(TRUE)] [limb.name] [examine_desc]"
	else
		var/sling_condition = ""
		// how much life we have left in these bandages
		switch(limb.current_gauze.obj_integrity / limb.current_gauze.max_integrity * 100)
			if(0 to 25)
				sling_condition = "just barely "
			if(25 to 50)
				sling_condition = "loosely "
			if(50 to 75)
				sling_condition = "mostly "
			if(75 to INFINITY)
				sling_condition = "tightly "

		msg += "[victim.p_their(TRUE)] [limb.name] is [sling_condition] fastened in a sling of [limb.current_gauze.name]"

	if(taped)
		msg += ", <span class='notice'>and appears to be reforming itself under some surgical tape!</span>"
	else if(gelled)
		msg += ", <span class='notice'>with fizzing flecks of blue bone gel sparking off the bone!</span>"
	else
		msg +=  "!"
	return "<B>[msg.Join()]</B>"

/*
	New common procs for /datum/wound/blunt/
*/

/datum/wound/blunt/proc/update_inefficiencies()
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(limb.current_gauze)
			limp_slowdown = initial(limp_slowdown) * limb.current_gauze.splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
		victim.apply_status_effect(STATUS_EFFECT_LIMP)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(limb.current_gauze)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * limb.current_gauze.splint_factor)
		else
			interaction_efficiency_penalty = interaction_efficiency_penalty

	if(initial(disabling))
		set_disabling(!limb.current_gauze)

	limb.update_wounds()

/// Joint Dislocation (Moderate Blunt)
/datum/wound/blunt/moderate
	name = "Joint Dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation by applying an aggressive grab to the patient and helpfully interacting with afflicted limb may suffice."
	examine_desc = "is awkwardly jammed out of place"
	occur_text = "jerks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 3
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	wound_flags = (BONE_WOUND)
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	scar_keyword = "bluntmoderate"

/datum/wound/blunt/moderate/Destroy()
	if(victim)
		UnregisterSignal(victim, COMSIG_LIVING_DOORCRUSHED)
	return ..()

/datum/wound/blunt/moderate/wound_injury(datum/wound/old_wound)
	. = ..()
	RegisterSignal(victim, COMSIG_LIVING_DOORCRUSHED, .proc/door_crush)

/// Getting smushed in an airlock/firelock is a last-ditch attempt to try relocating your limb
/datum/wound/blunt/moderate/proc/door_crush()
	if(prob(33))
		victim.visible_message("<span class='danger'>[victim]'s dislocated [limb.name] pops back into place!</span>", "<span class='userdanger'>Your dislocated [limb.name] pops back into place! Ow!</span>")
		remove_wound()

/datum/wound/blunt/moderate/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message("<span class='danger'>[user] begins twisting and straining [victim]'s dislocated [limb.name]!</span>", "<span class='notice'>You begin twisting and straining [victim]'s dislocated [limb.name]...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] begins twisting and straining your dislocated [limb.name]!</span>")
		if(user.a_intent == INTENT_HELP)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our dislocated joint back into place by hand with an aggro grab and help intent
/datum/wound/blunt/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(prob(65))
		user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] back into place!</span>", "<span class='notice'>You snap [victim]'s dislocated [limb.name] back into place!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] back into place!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=20, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] wrenches [victim]'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>You wrench [victim]'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches your dislocated [limb.name] around painfully!</span>")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/blunt/moderate/proc/malpractice(mob/living/carbon/human/user)
	var/time = base_treat_time

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(prob(65))
		user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] with a sickening crack!</span>", "<span class='danger'>You snap [victim]'s dislocated [limb.name] with a sickening crack!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] with a sickening crack!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=25, wound_bonus=30)
	else
		user.visible_message("<span class='danger'>[user] wrenches [victim]'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>You wrench [victim]'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches your dislocated [limb.name] around painfully!</span>")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		malpractice(user)


/datum/wound/blunt/moderate/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin resetting your [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin resetting [victim]'s [limb.name] with [I]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>You reset your [limb.name]!</span>")
	else
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting [victim]'s [limb.name]!</span>", "<span class='nicegreen'>You finish resetting [victim]'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets your [limb.name]!</span>")

	victim.emote("scream")
	qdel(src)

/*
	Severe (Hairline Fracture)
*/

/datum/wound/blunt/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though a sling of medical gauze will prevent worsening situation."
	examine_desc = "appears grotesquely swollen, its attachment weakened"
	occur_text = "sprays chips of bone and develops a nasty looking bruise"

	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	threshold_minimum = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/severe
	scar_keyword = "bluntsevere"
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	internal_bleeding_chance = 40
	wound_flags = (BONE_WOUND | ACCEPTS_GAUZE | MANGLES_BONE)

/// Compound Fracture (Critical Blunt)
/datum/wound/blunt/critical
	name = "Compound Fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "is mangled and pulped, seemingly held together by tissue alone"
	occur_text = "cracks apart, exposing broken bones to open air"

	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 4
	limp_slowdown = 9
	sound_effect = 'sound/effects/wounds/crack2.ogg'
	threshold_minimum = 115
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/critical
	scar_keyword = "bluntcritical"
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	internal_bleeding_chance = 60
	wound_flags = (BONE_WOUND | ACCEPTS_GAUZE | MANGLES_BONE)

// doesn't make much sense for "a" bone to stick out of your head
/datum/wound/blunt/critical/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	if(L.body_zone == BODY_ZONE_HEAD)
		occur_text = "splits open, exposing a bare, cracked skull through the flesh and blood"
		examine_desc = "has an unsettling indent, with bits of skull poking out"
	. = ..()

/// if someone is using bone gel on our wound
/datum/wound/blunt/proc/gel(obj/item/stack/medical/bone_gel/I, mob/user)
	if(gelled)
		to_chat(user, "<span class='warning'>[user == victim ? "Your" : "[victim]'s"] [limb.name] is already coated with bone gel!</span>")
		return

	user.visible_message("<span class='danger'>[user] begins hastily applying [I] to [victim]'s' [limb.name]...</span>", "<span class='warning'>You begin hastily applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.name], disregarding the warning label...</span>")

	if(!do_after(user, base_treat_time * 1.5 * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	I.use(1)
	victim.emote("scream")
	if(user != victim)
		user.visible_message("<span class='notice'>[user] finishes applying [I] to [victim]'s [limb.name], emitting a fizzing noise!</span>", "<span class='notice'>You finish applying [I] to [victim]'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] finishes applying [I] to your [limb.name], and you can feel the bones exploding with pain as they begin melting and reforming!</span>")
	else
		var/painkiller_bonus = 0
		if(victim.drunkenness > 10)
			painkiller_bonus += 10
		if(victim.has_reagent(/datum/reagent/medicine/morphine))
			painkiller_bonus += 20
		if(victim.has_reagent(/datum/reagent/determination))
			painkiller_bonus += 10
		if(victim.has_reagent(/datum/reagent/consumable/ethanol/painkiller))
			painkiller_bonus += 5
		if(victim.has_reagent(/datum/reagent/medicine/mine_salve))
			painkiller_bonus += 20

		if(prob(25 + (20 * (severity - 2)) - painkiller_bonus)) // 25%/45% chance to fail self-applying with severe and critical wounds, modded by painkillers
			victim.visible_message("<span class='danger'>[victim] fails to finish applying [I] to [victim.p_their()] [limb.name], passing out from the pain!</span>", "<span class='notice'>You pass out from the pain of applying [I] to your [limb.name] before you can finish!</span>")
			victim.AdjustUnconscious(5 SECONDS)
			return
		victim.visible_message("<span class='notice'>[victim] finishes applying [I] to [victim.p_their()] [limb.name], grimacing from the pain!</span>", "<span class='notice'>You finish applying [I] to your [limb.name], and your bones explode in pain!</span>")

	limb.receive_damage(25, stamina=100, wound_bonus=CANT_WOUND)
	if(!gelled)
		gelled = TRUE

/// if someone is using surgical tape on our wound
/datum/wound/blunt/proc/tape(obj/item/stack/sticky_tape/surgical/I, mob/user)
	if(!gelled)
		to_chat(user, "<span class='warning'>[user == victim ? "Your" : "[victim]'s"] [limb.name] must be coated with bone gel to perform this emergency operation!</span>")
		return
	if(taped)
		to_chat(user, "<span class='warning'>[user == victim ? "Your" : "[victim]'s"] [limb.name] is already wrapped in [I.name] and reforming!</span>")
		return

	user.visible_message("<span class='danger'>[user] begins applying [I] to [victim]'s' [limb.name]...</span>", "<span class='warning'>You begin applying [I] to [user == victim ? "your" : "[victim]'s"] [limb.name]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	regen_points_current = 0
	regen_points_needed = 30 SECONDS * (user == victim ? 1.5 : 1) * (severity - 1)
	I.use(1)
	if(user != victim)
		user.visible_message("<span class='notice'>[user] finishes applying [I] to [victim]'s [limb.name], emitting a fizzing noise!</span>", "<span class='notice'>You finish applying [I] to [victim]'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='green'>[user] finishes applying [I] to your [limb.name], you immediately begin to feel your bones start to reform!</span>")
	else
		victim.visible_message("<span class='notice'>[victim] finishes applying [I] to [victim.p_their()] [limb.name], !</span>", "<span class='green'>You finish applying [I] to your [limb.name], and you immediately begin to feel your bones start to reform!</span>")

	taped = TRUE
	processes = TRUE

/datum/wound/blunt/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/bone_gel))
		gel(I, user)
	else if(istype(I, /obj/item/stack/sticky_tape/surgical))
		tape(I, user)

/datum/wound/blunt/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(!gelled)
		. += "Alternative Treatment: Apply bone gel directly to injured limb, then apply surgical tape to begin bone regeneration. This is both excruciatingly painful and slow, and only recommended in dire circumstances.\n"
	else if(!taped)
		. += "<span class='notice'>Continue Alternative Treatment: Apply surgical tape directly to injured limb to begin bone regeneration. Note, this is both excruciatingly painful and slow.</span>\n"
	else
		. += "<span class='notice'>Note: Bone regeneration in effect. Bone is [round(regen_points_current*100/regen_points_needed)]% regenerated.</span>\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Cranial Trauma Detected: Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] brain traumas until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume)
		. += "Ribcage Trauma Detected: Further trauma to chest is likely to worsen internal bleeding until bone is repaired."
	. += "</div>"
