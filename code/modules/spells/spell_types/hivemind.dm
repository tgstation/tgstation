/obj/effect/proc_holder/spell/target_hive
	panel = "Hivemind Abilities"
	invocation_type = "none"
	selection_type = "range"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "spell_default"
	clothes_req = 0
	human_req = 1
	antimagic_allowed = TRUE
	range = 0 //SNOWFLAKE, 0 is unlimited for target_external=0 spells
	var/target_external = 0 //Whether or not we select targets inside or outside of the hive


/obj/effect/proc_holder/spell/target_hive/choose_targets(mob/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/list/possible_targets = list()
	var/list/targets = list()

	if(target_external)
		for(var/mob/living/carbon/H in view_or_range(range, user, selection_type))
			if(user == H)
				continue
			if(!can_target(H))
				continue
			if(!hive.is_carbon_member(H))
				possible_targets += H
	else
		possible_targets = hive.get_carbon_members()
		if(range)
			possible_targets &= view_or_range(range, user, selection_type)

	var/mob/living/carbon/human/H = input("Choose the target for the spell.", "Targeting") as null|mob in possible_targets
	if(!H)
		revert_cast()
		return
	targets += H
	perform(targets,user=user)

/obj/effect/proc_holder/spell/target_hive/hive_add
	name = "Assimilate Vessel"
	desc = "We silently add an unsuspecting target to the hive."
	selection_type = "view"
	action_icon_state = "add"

	charge_max = 50
	range = 7
	target_external = 1
	var/ignore_mindshield = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_add/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE

	if(target.mind && target.client && target.stat != DEAD)
		if(!target.has_trait(TRAIT_MINDSHIELD) || ignore_mindshield)
			if(target.has_trait(TRAIT_MINDSHIELD) && ignore_mindshield)
				to_chat(user, "<span class='notice'>We bruteforce our way past the mental barriers of [target.name] and begin linking our minds!</span>")
			else
				to_chat(user, "<span class='notice'>We begin linking our mind with [target.name]!</span>")
			if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && target in view(range))
				if(do_after(user,5*(1.5**get_dist(user, target)),0,user) && target in view(range))
					if((!target.has_trait(TRAIT_MINDSHIELD) || ignore_mindshield) && target in view(range))
						to_chat(user, "<span class='notice'>[target.name] was added to the Hive!</span>")
						success = TRUE
						hive.add_to_hive(target)
						if(ignore_mindshield)
							to_chat(user, "<span class='warning'>We are briefly exhausted by the effort required by our enhanced assimilation abilities.</span>")
							user.Immobilize(50)
							SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
							for(var/obj/item/implant/mindshield/M in target.implants)
								qdel(M)
					else
						to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
				else
					to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
			else
				to_chat(user, "<span class='notice'>We fail to connect to [target.name].</span>")
		else
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
	else
		to_chat(user, "<span class='notice'>We detect no neural activity in this body.</span>")
	if(!success)
		revert_cast()

/obj/effect/proc_holder/spell/target_hive/hive_remove
	name = "Release Vessel"
	desc = "We silently remove a nearby target from the hive. We must be close to their body to do so."
	selection_type = "view"
	action_icon_state = "remove"

	charge_max = 50
	range = 7

/obj/effect/proc_holder/spell/target_hive/hive_remove/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]

	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/datum/mind/M = target.mind
	if(!M)
		revert_cast()
		return
	hive.remove_from_hive(M)
	hive.calc_size()
	to_chat(user, "<span class='notice'>We remove [target.name] from the hive</span>")
	if(hive.active_one_mind)
		var/datum/antagonist/hivevessel/woke = target.is_wokevessel()
		if(woke)
			hive.active_one_mind.remove_member(M)
			M.remove_antag_datum(/datum/antagonist/hivevessel)

/obj/effect/proc_holder/spell/target_hive/hive_see
	name = "Hive Vision"
	desc = "We use the eyes of one of our vessels. Use again to look through our own eyes once more."
	action_icon_state = "see"
	var/mob/living/carbon/vessel
	var/mob/living/host //Didn't really have any other way to auto-reset the perspective if the other mob got qdeled

	charge_max = 20

/obj/effect/proc_holder/spell/target_hive/hive_see/on_lose(mob/living/user)
	user.reset_perspective()
	user.clear_fullscreen("hive_eyes")

/obj/effect/proc_holder/spell/target_hive/hive_see/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		if(vessel)
			vessel.apply_status_effect(STATUS_EFFECT_BUGGED, user)
			user.reset_perspective(vessel)
			active = TRUE
			host = user
			user.clear_fullscreen("hive_mc")
			user.overlay_fullscreen("hive_eyes", /obj/screen/fullscreen/hive_eyes)
		revert_cast()
	else
		vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
		user.reset_perspective()
		user.clear_fullscreen("hive_eyes")
		var/obj/effect/proc_holder/spell/target_hive/hive_control/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_control) in user.mind.spell_list
		if(the_spell && the_spell.active)
			user.overlay_fullscreen("hive_mc", /obj/screen/fullscreen/hive_mc)
		active = FALSE
		revert_cast()

/obj/effect/proc_holder/spell/target_hive/hive_see/process()
	if(active && (!vessel || !is_hivemember(vessel) || QDELETED(vessel)))
		to_chat(host, "<span class='warning'>Our vessel is one of us no more!</span>")
		host.reset_perspective()
		host.clear_fullscreen("hive_eyes")
		active = FALSE
		if(!QDELETED(vessel))
			vessel.remove_status_effect(STATUS_EFFECT_BUGGED)
	..()

/obj/effect/proc_holder/spell/target_hive/hive_see/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(,user)

/obj/effect/proc_holder/spell/target_hive/hive_shock
	name = "Neural Shock"
	desc = "After a short charging time, we overload the mind of one of our vessels with psionic energy, rendering them unconscious for a short period of time. This power weakens over distance, but strengthens with hive size."
	action_icon_state = "shock"

	charge_max = 600

/obj/effect/proc_holder/spell/target_hive/hive_shock/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	to_chat(user, "<span class='notice'>We begin increasing the psionic bandwidth between ourself and the vessel!</span>")
	if(do_after(user,30,0,user))
		var/power = 120-get_dist(user, target)
		if(!is_hivehost(target))
			switch(hive.hive_size)
				if(0 to 4)
				if(5 to 9)
					power *= 1.5
				if(10 to 14)
					power *= 2
				if(15 to 19)
					power *= 2.5
				else
					power *= 3
		if(power > 50 && user.z == target.z)
			to_chat(user, "<span class='notice'>We have overloaded the vessel for a short time!</span>")
			target.Jitter(round(power/10))
			target.Unconscious(power)
		else
			to_chat(user, "<span class='notice'>The vessel was too far away to be affected!</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()


/obj/effect/proc_holder/spell/self/hive_scan
	name = "Psychoreception"
	desc = "We release a pulse to receive information on any enemies we have previously located via Network Invasion, as well as those currently tracking us."
	panel = "Hivemind Abilities"
	charge_max = 1800
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "scan"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_scan/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/message
	var/distance

	for(var/datum/status_effect/hive_track/track in user.status_effects)
		var/mob/living/L = track.tracked_by
		if(!L)
			continue
		if(!do_after(user,5,0,user))
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
			break
		distance = get_dist(user, L)
		message = "[(L.is_real_hivehost()) ? "Someone": "A hivemind host"] tracking us"
		if(user.z != L.z || L.stat == DEAD)
			message += " could not be found."
		else
			switch(distance)
				if(0 to 2)
					message += " is right next to us!"
				if(2 to 14)
					message += " is nearby."
				if(14 to 28)
					message += " isn't too far away."
				if(28 to INFINITY)
					message += " is quite far away."
		to_chat(user, "<span class='assimilator'>[message]</span>")
	for(var/datum/antagonist/hivemind/enemy in hive.individual_track_bonus)
		if(!do_after(user,5,0,user))
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
			break
		var/mob/living/carbon/C = enemy.owner?.current
		if(!C)
			continue
		var/mob/living/real_enemy = C.get_real_hivehost()
		distance = get_dist(user, real_enemy)
		message = "A host that we can track for [(hive.individual_track_bonus[enemy])/10] extra seconds"
		if(user.z != real_enemy.z || real_enemy.stat == DEAD)
			message += " could not be found."
		else
			switch(distance)
				if(0 to 2)
					message += " is right next to us!"
				if(2 to 14)
					if(enemy.get_threat_multiplier() >= 0.85 && distance <= 7)
						message += " is in this very room!"
					else
						message += " is nearby."
				if(14 to 28)
					message += " isn't too far away."
				if(28 to INFINITY)
					message += " is quite far away."
		to_chat(user, "<span class='assimilator'>[message]</span>")

/obj/effect/proc_holder/spell/self/hive_drain
	name = "Repair Protocol"
	desc = "Our many vessels sacrifice a small portion of their mind's vitality to cure us of our physical and mental ailments."

	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "drain"
	human_req = 1
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_drain/cast(mob/living/carbon/human/user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		return
	var/iterations = 0
	var/list/carbon_members = hive.get_carbon_members()
	if(!carbon_members.len)
		return
	if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss() && !user.getBrainLoss())
		to_chat(user, "<span class='notice'>We cannot heal ourselves any more with this power!</span>")
		revert_cast()
	to_chat(user, "<span class='notice'>We begin siphoning power from our many vessels!</span>")
	while(iterations < 7)
		var/mob/living/carbon/target = pick(carbon_members)
		if(!do_after(user,15,0,user))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		if(!target)
			to_chat(user, "<span class='warning'>We have run out of vessels to drain.</span>")
			break
		target.adjustBrainLoss(5)
		if(user.getBruteLoss() > user.getFireLoss())
			user.heal_ordered_damage(5, list(CLONE, INTERNAL, BRUTE, BURN))
		else
			user.heal_ordered_damage(5, list(CLONE, INTERNAL, BURN, BRUTE))
		if(!user.getBruteLoss() && !user.getFireLoss() && !user.getInternalLoss() && !user.getCloneLoss()) //If we don't have any of these, stop looping
			to_chat(user, "<span class='warning'>We finish our healing.</span>")
			break
		iterations++
	user.setBrainLoss(0)


/mob/living/passenger
	name = "mind control victim"
	real_name = "unknown conscience"

/mob/living/passenger/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	to_chat(src, "<span class='warning'>You find yourself unable to speak, you aren't in control of your body!</span>")
	return FALSE

/mob/living/passenger/emote(act, m_type = null, message = null, intentional = FALSE)
	to_chat(src, "<span class='warning'>You find yourself unable to emote, you aren't in control of your body!</span>")
	return

/mob/living/passenger/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, message_mode)
	return

/obj/effect/proc_holder/spell/target_hive/hive_control
	name = "Mind Control"
	desc = "We assume direct control of one of our vessels, leaving our current body for up to a minute. It can be cancelled at any time by casting it again. Powers can be used via our vessel, although if it dies, the entire hivemind will come down with it. Our ability to sense psionic energy is completely nullified while using this power, and it will end immediately should we attempt to move too far from our starting point."
	charge_max = 1500
	action_icon_state = "force"
	active  = FALSE
	var/mob/living/carbon/human/original_body //The original hivemind host
	var/mob/living/carbon/human/vessel
	var/mob/living/passenger/backseat //Storage for the mind controlled vessel
	var/turf/starting_spot
	var/power = 600
	var/time_initialized = 0
	var/out_of_range = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_control/proc/release_control() //If the spell is active, force everybody into their original bodies if they exist, ghost them otherwise, delete the backseat
	if(!active)
		return
	active = FALSE
	charge_counter = max((0.5-(world.time-time_initialized)/power)*charge_max, 0) //Partially refund the power based on how long it was used, up to a max of half the charge time

	if(!QDELETED(vessel))
		vessel.clear_fullscreen("hive_mc")
		if(vessel.mind)
			if(QDELETED(original_body))
				vessel.ghostize(0)
			else
				vessel.mind.transfer_to(original_body, 1)
				original_body.Sleeping(vessel.AmountSleeping()) // Mirrors any sleep or unconsciousness from the vessel
				original_body.Unconscious(vessel.AmountUnconscious())

	if(!QDELETED(backseat) && backseat.mind)
		if(QDELETED(vessel))
			backseat.ghostize(0)
		else
			backseat.mind.transfer_to(vessel,1)

	message_admins("[ADMIN_LOOKUPFLW(vessel)] is no longer being controlled by [ADMIN_LOOKUPFLW(original_body)] (Hivemind Host).")
	log_game("[key_name(vessel)] was released from Mind Control by [key_name(original_body)].")

	QDEL_NULL(backseat)

	if(original_body?.mind)
		var/datum/antagonist/hivemind/hive = original_body.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(hive)
			hive.threat_level += 0.5


/obj/effect/proc_holder/spell/target_hive/hive_control/on_lose(mob/user)
	release_control()

/obj/effect/proc_holder/spell/target_hive/hive_control/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(!hive)
			to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
			return
		original_body = user
		vessel = targets[1]
		to_chat(user, "<span class='notice'>We begin merging our mind with [vessel.name].</span>")
		if(!do_after(user,50,0,user))
			to_chat(user, "<span class='notice'>We fail to assume control of the target.</span>")
			revert_cast()
			return
		if(user.z != vessel.z)
			to_chat(user, "<span class='notice'>Our vessel is too far away to control.</span>")
			revert_cast()
			return
		for(var/datum/antagonist/hivemind/H in GLOB.antagonists)
			if(H.owner == user.mind)
				continue
			if(H.owner == vessel.mind)
				to_chat(user, "<span class='danger'>We have detected a foreign presence within this mind, it would be unwise to merge so intimately with it.</span>")
				revert_cast()
				return
		backseat = new /mob/living/passenger()
		if(vessel && vessel.mind && backseat)
			var/obj/effect/proc_holder/spell/target_hive/hive_see/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_see) in user.mind.spell_list
			if(the_spell && the_spell.active) //Uncast Hive Sight just to make things easier when casting during mind control
				the_spell.perform(,user)

			message_admins("[ADMIN_LOOKUPFLW(vessel)] has been temporarily taken over by [ADMIN_LOOKUPFLW(user)] (Hivemind Host).")
			log_game("[key_name(vessel)] was Mind Controlled by [key_name(user)].")

			deadchat_broadcast("<span class='deadsay'><span class='name'>[vessel]</span> has just been mind controlled!</span>", vessel)

			original_body = user
			backseat.loc = vessel
			backseat.name = vessel.real_name
			backseat.real_name = vessel.real_name
			vessel.mind.transfer_to(backseat, 1)
			user.mind.transfer_to(vessel, 1)
			backseat.blind_eyes(power)
			vessel.overlay_fullscreen("hive_mc", /obj/screen/fullscreen/hive_mc)
			active = TRUE
			out_of_range = FALSE
			starting_spot = get_turf(vessel)
			time_initialized = world.time
			revert_cast()
			to_chat(vessel, "<span class='assimilator'>We can sustain our control for a maximum of [round(power/10)] seconds.</span>")
			if(do_after(user,power,0,user,0))
				to_chat(vessel, "<span class='warning'>We cannot sustain the mind control any longer and release control!</span>")
			else
				to_chat(vessel, "<span class='warning'>Our body has been disturbed, interrupting the mind control!</span>")
			release_control()
		else
			to_chat(usr, "<span class='warning'>We detect no neural activity in our vessel!</span>")
			revert_cast()
	else
		release_control()

/obj/effect/proc_holder/spell/target_hive/hive_control/process()
	if(active)
		if(QDELETED(vessel)) //If we've been gibbed or otherwise deleted, ghost both of them and kill the original
			original_body.adjustBrainLoss(200)
			release_control()
		else if(!is_hivemember(backseat)) //If the vessel is no longer a hive member, return to original bodies
			to_chat(vessel, "<span class='warning'>Our vessel is one of us no more!</span>")
			release_control()
		else if(!QDELETED(original_body) && (!backseat.ckey || vessel.stat == DEAD)) //If the original body exists and the vessel is dead/ghosted, return both to body but not before killing the original
			original_body.adjustBrainLoss(200)
			to_chat(vessel.mind, "<span class='warning'>Our vessel is one of us no more!</span>")
			release_control()
		else if(!QDELETED(original_body) && original_body.z != vessel.z) //Return to original bodies
			release_control()
			to_chat(original_body, "<span class='warning'>Our vessel is too far away to control!</span>")
		else if(QDELETED(original_body) || original_body.stat == DEAD) //Return vessel to its body, either return or ghost the original
			to_chat(vessel, "<span class='userdanger'>Our body has been destroyed, the hive cannot survive without its host!</span>")
			release_control()
		else if(!out_of_range && get_dist(starting_spot, vessel) > 14)
			out_of_range = TRUE
			flash_color(vessel, flash_color="#800080", flash_time=10)
			to_chat(vessel, "<span class='warning'>Our vessel has been moved too far away from the initial point of control, we will be disconnected if we go much further!</span>")
			addtimer(CALLBACK(src, "range_check"), 30)
		else if(get_dist(starting_spot, vessel) > 21)
			release_control()

	..()

/obj/effect/proc_holder/spell/target_hive/hive_control/proc/range_check()
	if(!active)
		return
	if(get_dist(starting_spot, vessel) > 14)
		release_control()
	out_of_range = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_control/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(,user)

/obj/effect/proc_holder/spell/targeted/induce_panic
	name = "Induce Panic"
	desc = "We unleash a burst of psionic energy, inducing a debilitating fear in those around us and reducing their combat readiness. We can also briefly affect silicon-based life with this burst."
	panel = "Hivemind Abilities"
	charge_max = 900
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "panic"

/obj/effect/proc_holder/spell/targeted/induce_panic/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat == DEAD)
			continue
		target.Jitter(14)
		target.apply_damage(35 + rand(0,15), STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
		if(target.is_real_hivehost())
			continue
		if(prob(20))
			var/text = pick(";HELP!","I'm losing control of the situation!!","Get me outta here!")
			target.say(text, forced = "panic")
		var/effect = rand(1,4)
		switch(effect)
			if(1)
				to_chat(target, "<span class='userdanger'>You panic and drop everything to the ground!</span>")
				target.drop_all_held_items()
			if(2)
				to_chat(target, "<span class='userdanger'>You panic and flail around!</span>")
				target.click_random_mob()
				addtimer(CALLBACK(target, "click_random_mob"), 5)
				addtimer(CALLBACK(target, "click_random_mob"), 10)
				addtimer(CALLBACK(target, "click_random_mob"), 15)
				addtimer(CALLBACK(target, "click_random_mob"), 20)
				addtimer(CALLBACK(target, "Stun", 30), 25)
				target.confused += 10
			if(3)
				to_chat(target, "<span class='userdanger'>You freeze up in fear!</span>")
				target.Stun(70)
			if(4)
				to_chat(target, "<span class='userdanger'>You feel nauseous as dread washes over you!</span>")
				target.Dizzy(15)
				target.apply_damage(30, STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
				target.hallucination += 45

	for(var/mob/living/silicon/target in targets)
		target.Unconscious(50)

/obj/effect/proc_holder/spell/targeted/induce_sleep
	name = "Circadian Shift"
	desc = "We send out a controlled pulse of psionic energy, temporarily causing a deep sleep to anybody in sight, even in silicon-based lifeforms. The fewer people in sight, the more effective this power is. The weak mind of a vessels cannot handle this ability, using Mind Control and this at the same time would be most unwise."
	panel = "Hivemind Abilities"
	charge_max = 1200
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	include_user = 1 //Checks for real hivemind hosts during the cast, won't smack you unless using mind control
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "sleep"

/obj/effect/proc_holder/spell/targeted/induce_sleep/cast(list/targets, mob/living/user = usr)
	if(!targets)
		to_chat(user, "<span class='notice'>Nobody is in sight, it'd be a waste to do that now.</span>")
		revert_cast()
		return
	var/list/victims = list()
	for(var/mob/living/target in targets)
		if(target.stat == DEAD)
			continue
		if(target.is_real_hivehost() || (!iscarbon(target) && !issilicon(target)))
			continue
		victims += target
	for(var/mob/living/carbon/victim in victims)
		victim.Sleeping(max(80,240/(1+round(victims.len/3))))
	for(var/mob/living/silicon/victim in victims)
		victim.Unconscious(240)

/obj/effect/proc_holder/spell/target_hive/hive_attack
	name = "Medullary Failure"
	desc = "We overload the target's medulla, inducing an immediate heart attack."

	charge_max = 3000
	action_icon_state = "attack"

/obj/effect/proc_holder/spell/target_hive/hive_attack/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]
	if(!target.undergoing_cardiac_arrest() && target.can_heartattack())
		target.set_heartattack(TRUE)
		to_chat(target, "<span class='userdanger'>You feel a sharp pain, and foreign presence in your mind!!</span>")
		to_chat(user, "<span class='notice'>We have overloaded the vessel's medulla! Without medical attention, they will shortly die.</span>")
		if(target.stat == CONSCIOUS)
			target.visible_message("<span class='userdanger'>[target] clutches at [target.p_their()] chest as if [target.p_their()] heart stopped!</span>")
			deadchat_broadcast("<span class='deadsay'><span class='name'>[target]</span> has suffered a mysterious heart attack!</span>", target)
	else
		to_chat(user, "<span class='warning'>We are unable to induce a heart attack!</span>")
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(hive)
		hive.threat_level += 2

/obj/effect/proc_holder/spell/target_hive/hive_warp
	name = "Distortion Field"
	desc = "We warp reality surrounding a vessel, causing hallucinations in everybody around them over a short period of time, eventually weakening those caught within the field. This power's effectiveness scales with hive size."

	charge_max = 900
	action_icon_state = "warp"

/obj/effect/proc_holder/spell/target_hive/hive_warp/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(target.z != user.z)
		to_chat(user, "<span class='notice'>We are too far away from [target.name] to affect them!</span>")
		return
	to_chat(user, "<span class='notice'>We successfully distort reality surrounding [target.name]!</span>")
	var/pulse_cap = min(12, 8+(round(hive.hive_size/20)))
	distort(user, target, pulse_cap)

/obj/effect/proc_holder/spell/target_hive/hive_warp/proc/distort(user, target, pulse_cap, pulses = 0)
	for(var/mob/living/carbon/human/victim in view(7,target))
		if(user == victim || victim.is_real_hivehost())
			continue
		if(pulses < 4)
			victim.apply_damage(10, STAMINA, victim.get_bodypart(BODY_ZONE_HEAD)) // 25 over 10 seconds when taking stamina regen (3 per tick(2 seconds)) into account
			victim.hallucination += 5
		else if(pulses < 8)
			victim.apply_damage(15, STAMINA, victim.get_bodypart(BODY_ZONE_HEAD)) // 45 over 10 seconds when taking stamina regen into account
			victim.hallucination += 10
		else
			victim.apply_damage(20, STAMINA, victim.get_bodypart(BODY_ZONE_HEAD)) // 65 over 10 seconds when taking stamina regen into account
			victim.hallucination += 15

	if(pulses < pulse_cap && user && target)
		addtimer(CALLBACK(src, "distort", user, target, pulse_cap, pulses+1), 25)

/obj/effect/proc_holder/spell/targeted/hive_hack
	name = "Network Invasion"
	desc = "We probe the mind of an adjacent target and extract valuable information on any enemy hives they may belong to. Takes longer if the target is not in our hive."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	invocation_type = "none"
	clothes_req = 0
	max_targets = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "hack"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_hack/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/target = targets[1]
	var/in_hive = hive.is_carbon_member(target)
	var/list/enemies = list()

	to_chat(user, "<span class='notice'>We begin probing [target.name]'s mind!</span>")
	if(do_after(user,100,0,target))
		if(!in_hive)
			to_chat(user, "<span class='notice'>Their mind slowly opens up to us.</span>")
			if(!do_after(user,200,0,target))
				to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
				revert_cast()
				return
		for(var/datum/antagonist/hivemind/enemy in GLOB.antagonists)
			var/datum/mind/M = enemy.owner
			if(!M?.current)
				continue
			if(M.current == user)
				continue
			if(enemy.is_carbon_member(target))
				hive.add_track_bonus(enemy, TRACKER_BONUS_LARGE)
				var/mob/living/real_enemy = (M.current.get_real_hivehost())
				enemies += real_enemy
				enemy.remove_from_hive(target)
				real_enemy.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, user, hive.get_track_bonus(enemy))
				if(M.current.is_real_hivehost()) //If they were using mind control, too bad
					real_enemy.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
					target.apply_status_effect(STATUS_EFFECT_HIVE_TRACKER, real_enemy, enemy.get_track_bonus(hive))
					to_chat(real_enemy, "<span class='assimilator'>We detect a surge of psionic energy from a far away vessel before they disappear from the hive. Whatever happened, there's a good chance they're after us now.</span>")

			if(enemy.owner == M && target.is_real_hivehost())
				var/atom/throwtarget
				throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(user, src)))
				SEND_SOUND(user, sound(pick('sound/hallucinations/turn_around1.ogg','sound/hallucinations/turn_around2.ogg'),0,1,50))
				flash_color(user, flash_color="#800080", flash_time=10)
				user.Paralyze(10)
				user.throw_at(throwtarget, 5, 1,src)
				to_chat(user, "<span class='userdanger'>A sudden surge of psionic energy rushes into your mind, only a Hive host could have such power!!</span>")
				return
		if(enemies.len)
			hive.track_bonus += TRACKER_BONUS_SMALL
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. They have heard our call. They know we are coming.</span>")
			to_chat(user, "<span class='assimilator'>This vision has provided us insight on our very nature, improving our sensory abilities, particularly against the hives this vessel belonged to.</span>")
			user.apply_status_effect(STATUS_EFFECT_HIVE_RADAR)
		else
			to_chat(user, "<span class='notice'>We peer into the inner depths of their mind and see nothing, no enemies lurk inside this mind.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/targeted/hive_reclaim
	name = "Reclaim"
	desc = "Allows us to instantly syphon the psionic energy from an adjacent critically injured host, killing them immediately. If it succeeds, we will be able to advance our own powers a great deal."
	panel = "Hivemind Abilities"
	charge_max = 600
	range = 1
	max_targets = 0
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "reclaim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/targeted/hive_reclaim/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/found_target = FALSE
	var/gibbed = FALSE

	for(var/mob/living/carbon/C in targets)
		if(!is_hivehost(C))
			continue
		if(C.InCritical())
			C.gib()
			hive.track_bonus += TRACKER_BONUS_LARGE
			hive.size_mod += 5
			gibbed = TRUE
			found_target = TRUE
		else if(C.IsUnconscious())
			C.adjustOxyLoss(100)
			found_target = TRUE

	if(!found_target)
		revert_cast()
		return

	flash_color(user, flash_color="#800080", flash_time=10)
	if(gibbed)
		to_chat(user,"<span class='assimilator'>We have reclaimed what gifts weaker minds were squandering and gain ever more insight on our psionic abilities.</span>")
		to_chat(user,"<span class='assimilator'>Thanks to this new knowledge, our sensory powers last a great deal longer.</span>")
		hive.check_powers()

/obj/effect/proc_holder/spell/self/hive_wake
	name = "Chaos Induction"
	desc = "A one-use power, we awaken four random vessels within our hive and force them to do our bidding."
	panel = "Hivemind Abilities"
	charge_type = "charges"
	charge_max = 1
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "chaos"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_wake/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	var/list/valid_targets = list()
	for(var/datum/mind/M in hive.hivemembers)
		var/mob/living/carbon/C = M.current
		if(!C)
			continue
		if(is_hivehost(C) || C.is_wokevessel())
			continue
		if(C.stat == DEAD || C.InCritical())
			continue
		valid_targets += C

	if(!valid_targets || valid_targets.len < 4)
		to_chat(user, "<span class='assimilator'>We lack the vessels to use this power.</span>")
		revert_cast()
		return

	var/objective = stripped_input(user, "What objective do you want to give to your vessels?", "Objective")

	for(var/i = 0, i < 4, i++)
		var/mob/living/carbon/C = pick_n_take(valid_targets)
		C.hive_awaken(objective)

/obj/effect/proc_holder/spell/self/hive_loyal
	name = "Bruteforce"
	desc = "Our ability to assimilate is boosted at the cost of, allowing us to crush the technology shielding the minds of Security and Command personnel and assimilate them. This power comes at a small price, and we will be immobilized for a few seconds after assimilation."
	panel = "Hivemind Abilities"
	charge_max = 600
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "loyal"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_loyal/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/obj/effect/proc_holder/spell/target_hive/hive_add/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_add) in user.mind.spell_list
	if(!the_spell)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE5</span>")
		return
	the_spell.ignore_mindshield = !active
	to_chat(user, "<span class='notice'>We [active?"let our minds rest and cancel our crushing power.":"prepare to crush mindshielding technology!"]</span>")
	active = !active
	if(active)
		revert_cast()

/obj/effect/proc_holder/spell/targeted/forcewall/hive
	name = "Telekinetic Field"
	desc = "Our psionic powers form a barrier around us in the phsyical world that only we can pass through."
	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	human_req = 1
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "forcewall"
	range = -1
	include_user = 1
	antimagic_allowed = TRUE
	wall_type = /obj/effect/forcefield/wizard/hive
	var/wall_type_b = /obj/effect/forcefield/wizard/hive/invis

/obj/effect/proc_holder/spell/targeted/forcewall/hive/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user),user)
	for(var/dir in GLOB.alldirs)
		new wall_type_b(get_step(user, dir),user)

/obj/effect/forcefield/wizard/hive
	name = "Telekinetic Field"
	desc = "You think, therefore it is."
	timeleft = 150
	pixel_x = -32 //Centres the 96x96 sprite
	pixel_y = -32
	icon = 'icons/effects/96x96.dmi'
	icon_state = "hive_shield"
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/forcefield/wizard/hive/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	return  FALSE

/obj/effect/forcefield/wizard/hive/invis
	icon = null
	icon_state = null
	pixel_x = 0
	pixel_y = 0
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/proc_holder/spell/self/one_mind
	name = "One Mind"
	desc = "Our true power... finally within reach."
	panel = "Hivemind Abilities"
	charge_type = "charges"
	charge_max = 1
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "assim"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/one_mind/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/boss = user.get_real_hivehost()
	var/datum/objective/objective = new("Ensure the One Mind survives under the leadership of [boss.real_name]!")
	var/datum/team/hivemind/one_mind_team = new /datum/team/hivemind(user.mind)
	hive.active_one_mind = one_mind_team
	one_mind_team.objectives += objective
	for(var/datum/antagonist/hivevessel/vessel in GLOB.antagonists)
		var/mob/living/carbon/C = vessel.owner?.current
		if(C && hive.is_carbon_member(C))
			vessel.one_mind = one_mind_team
	for(var/datum/antagonist/hivemind/enemy in GLOB.antagonists)
		if(enemy.owner)
			enemy.owner.RemoveSpell(new/obj/effect/proc_holder/spell/self/one_mind)
	sound_to_playing_players('sound/effects/one_mind.ogg')
	hive.glow = mutable_appearance('icons/effects/hivemind.dmi', "awoken", -BODY_BEHIND_LAYER)
	addtimer(CALLBACK(user, /atom/proc/add_overlay, hive.glow), 150)
	addtimer(CALLBACK(hive, /datum/antagonist/hivemind/proc/awaken), 150)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/send_to_playing_players, "<span class='bigassimilator'>THE ONE MIND RISES</span>"), 150)
	addtimer(CALLBACK(GLOBAL_PROC, /proc/sound_to_playing_players, 'sound/effects/magic.ogg'), 150)
	for(var/datum/mind/M in hive.hivemembers)
		var/mob/living/carbon/C = M.current
		if(!C)
			continue
		if(is_hivehost(C))
			continue
		if(C.stat == DEAD)
			continue
		C.Jitter(15)
		C.Unconscious(150)
		to_chat(C, "<span class='boldwarning'>Something's wrong...</span>")
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>...your memories are becoming fuzzy.</span>"), 45)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='boldwarning'>You try to remember who you are...</span>"), 90)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='assimilator'>There is no you...</span>"), 110)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, C, "<span class='bigassimilator'>...there is only us.</span>"), 130)
		addtimer(CALLBACK(C, /mob/living/proc/hive_awaken, objective, one_mind_team), 150)

/obj/effect/proc_holder/spell/self/hive_comms
	name = "Hive Communication"
	desc = "Now that we are free we may finally share our thoughts with our many bretheren."
	panel = "Hivemind Abilities"
	charge_max = 100
	invocation_type = "none"
	clothes_req = 0
	human_req = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "comms"
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_comms/cast(mob/living/user = usr)
	var/message = stripped_input(user, "What do you want to say?", "Hive Communication")
	if(!message)
		return
	var/title = "One Mind"
	var/span = "changeling"
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/hivemind))
		span = "assimilator"
	var/my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(is_hivehost(M) || is_hivemember(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="hive")