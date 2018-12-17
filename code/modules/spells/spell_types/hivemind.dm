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
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/list/possible_targets = list()
	var/list/targets = list()

	if(target_external)
		for(var/mob/living/carbon/human/H in view_or_range(range, user, selection_type))
			if(user == H)
				continue
			if(!can_target(H))
				continue
			if(!hive.hivemembers.Find(H))
				possible_targets += H
	else
		possible_targets = hive.hivemembers.Copy()
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

	charge_max = 200
	range = 7
	target_external = 1
	var/ignore_mindshield = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_add/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
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
					to_chat(user, "<span class='notice'>[target.name] was added to the Hive!</span>")
					success = TRUE
					hive.add_to_hive(target)
					if(ignore_mindshield)
						SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
						for(var/obj/item/implant/mindshield/M in target.implants)
							qdel(M)
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

	charge_max = 100
	range = 7

/obj/effect/proc_holder/spell/target_hive/hive_remove/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	hive.hivemembers -= target
	hive.calc_size()
	to_chat(user, "<span class='notice'>We remove [target.name] from the hive</span>")

/obj/effect/proc_holder/spell/target_hive/hive_see
	name = "Hive Vision"
	desc = "We use the eyes of one of our vessels. Use again to look through our own eyes once more."
	action_icon_state = "see"
	var/mob/vessel
	var/mob/living/host //Didn't really have any other way to auto-reset the perspective if the other mob got qdeled

	charge_max = 50

/obj/effect/proc_holder/spell/target_hive/hive_see/on_lose(mob/living/user)
	user.reset_perspective()

/obj/effect/proc_holder/spell/target_hive/hive_see/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		if(vessel)
			user.reset_perspective(vessel)
			active = TRUE
			host = user
		revert_cast()
	else
		user.reset_perspective()
		active = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_see/process()
	if(active && (!vessel || !is_hivemember(vessel) || QDELETED(vessel)))
		to_chat(host, "<span class='warning'>Our vessel is one of us no more!</span>")
		host.reset_perspective()
		active = FALSE
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
	if(do_after(user,60,0,user))
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

/obj/effect/proc_holder/spell/self/hive_drain/cast(mob/living/carbon/human/user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		return
	var/iterations = 0

	if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss() && !user.getBrainLoss())
		to_chat(user, "<span class='notice'>We cannot heal ourselves any more with this power!</span>")
		revert_cast()
	to_chat(user, "<span class='notice'>We begin siphoning power from our many vessels!</span>")
	while(iterations < 7)
		var/mob/living/carbon/human/target = pick(hive.hivemembers)
		if(!do_after(user,15,0,user))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		if(!target)
			to_chat(user, "<span class='warning'>We have run out of vessels to drain.</span>")
			break
		target.adjustBrainLoss(5)
		if(user.getBruteLoss() > user.getFireLoss())
			user.heal_ordered_damage(5, list(CLONE, BRUTE, BURN))
		else
			user.heal_ordered_damage(5, list(CLONE, BURN, BRUTE))
		if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss()) //If we don't have any of these, stop looping
			to_chat(user, "<span class='warning'>We finish our healing</span>")
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
	desc = "We assume direct control of one of our vessels, leaving our current body for up to ten seconds, although a larger hive may be able to sustain it for up to two minutes. It can be cancelled at any time by casting it again. Powers can be used via our vessel, although if it dies, the entire hivemind will come down with it."
	charge_max = 600
	action_icon_state = "force"
	active  = FALSE
	var/mob/living/carbon/human/original_body //The original hivemind host
	var/mob/living/carbon/human/vessel
	var/mob/living/passenger/backseat //Storage for the mind controlled vessel
	var/power = 100
	var/time_initialized = 0

/obj/effect/proc_holder/spell/target_hive/hive_control/proc/release_control() //If the spell is active, force everybody into their original bodies if they exist, ghost them otherwise, delete the backseat
	if(!active)
		return
	active = FALSE
	charge_counter = max((0.5-(world.time-time_initialized)/power)*charge_max, 0) //Partially refund the power based on how long it was used, up to a max of half the charge time

	if(!QDELETED(vessel))
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

/obj/effect/proc_holder/spell/target_hive/hive_control/on_lose(mob/user)
	release_control()

/obj/effect/proc_holder/spell/target_hive/hive_control/cast(list/targets, mob/living/user = usr)
	if(!active)
		vessel = targets[1]
		var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(!hive)
			to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
			return
		switch(hive.hive_size)
			if(10 to 14)
				power = 100
				charge_max = 600
			if(15 to 19)
				power = 300
				charge_max = 900
			if(20 to 24)
				power = 600
				charge_max = 1200
			else
				power = 1200
				charge_max = 1200
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

			original_body = user
			backseat.loc = vessel
			backseat.name = vessel.real_name
			backseat.real_name = vessel.real_name
			vessel.mind.transfer_to(backseat, 1)
			user.mind.transfer_to(vessel, 1)
			backseat.blind_eyes(power)
			active = TRUE
			time_initialized = world.time
			revert_cast()
			to_chat(vessel, "<span class='assimilator'>We can sustain our control for a maximum of [round(power/10)] seconds.</span>")
			if(do_after(user,power,0,user))
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
		else if(!is_hivemember(vessel)) //If the vessel is no longer a hive member, return to original bodies
			to_chat(vessel, "<span class='warning'>Our vessel is one of us no more!</span>")
			release_control()
		else if(!QDELETED(original_body) && (!vessel.ckey || vessel.stat == DEAD)) //If the original body exists and the vessel is dead/ghosted, return both to body but not before killing the original
			original_body.adjustBrainLoss(200)
			to_chat(vessel.mind, "<span class='warning'>Our vessel is one of us no more!</span>")
			release_control()
		else if(!QDELETED(original_body) && original_body.z != vessel.z) //Return to original bodies
			release_control()
			to_chat(original_body, "<span class='warning'>Our vessel is too far away to control!</span>")
		if(QDELETED(original_body) || original_body.stat == DEAD) //Return vessel to its body, either return or ghost the original
			to_chat(vessel, "<span class='userdanger'>Our body has been destroyed, the hive cannot survive without its host!</span>")
			release_control()
	..()

/obj/effect/proc_holder/spell/target_hive/hive_control/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(,user)

/obj/effect/proc_holder/spell/targeted/induce_panic
	name = "Induce Panic"
	desc = "We unleash a burst of psionic energy, inducing a debilitating fear in those around us and reducing their combat readiness. Mindshielded foes have a chance to resist this power."
	panel = "Hivemind Abilities"
	charge_max = 900
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "panic"

/obj/effect/proc_holder/spell/targeted/induce_panic/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.has_trait(TRAIT_MINDSHIELD) && prob(50-hive.hive_size)) //Mindshielded targets resist panic pretty well
			continue
		if(target.stat == DEAD)
			continue
		target.Jitter(14)
		target.apply_damage(min(35,hive.hive_size), STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
		if(prob(50))
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
				target.Dizzy(2)
			if(3)
				to_chat(target, "<span class='userdanger'>You freeze up in fear!</span>")
				target.Stun(70)
			if(4)
				to_chat(target, "<span class='userdanger'>You feel nauseous as dread washes over you!</span>")
				target.Dizzy(15)
				target.apply_damage(45, STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
				target.hallucination += 45

/obj/effect/proc_holder/spell/target_hive/hive_attack
	name = "Medullary Failure"
	desc = "We overload the target's medulla, inducing an immediate heart attack."

	charge_max = 3000
	action_icon_state = "attack"

/obj/effect/proc_holder/spell/target_hive/hive_attack/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	if(!target.undergoing_cardiac_arrest() && target.can_heartattack())
		target.set_heartattack(TRUE)
		to_chat(target, "<span class='userdanger'>You feel a sharp pain, and foreign presence in your mind!!</span>")
		to_chat(user, "<span class='notice'>We have overloaded the vessel's medulla! Without medical attention, they will shortly die.</span>")
		if(target.stat == CONSCIOUS)
			target.visible_message("<span class='userdanger'>[target] clutches at [target.p_their()] chest as if [target.p_their()] heart stopped!</span>")
	else
		to_chat(user, "<span class='warning'>We are unable to induce a heart attack!</span>")

/obj/effect/proc_holder/spell/target_hive/hive_warp
	name = "Distortion Field"
	desc = "We warp reality surrounding a vessel, causing hallucinations in everybody around them over a short period of time, eventually weakening those caught within the field. This power's effectiveness scales with hive size."

	charge_max = 900
	action_icon_state = "warp"

/obj/effect/proc_holder/spell/target_hive/hive_warp/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(target.z != user.z)
		to_chat(user, "<span class='notice'>We are too far away from [target.name] to affect them!</span>")
		return
	to_chat(user, "<span class='notice'>We successfully distort reality surrounding [target.name]!</span>")
	var/pulse_cap = min(12,max(6, round(3+hive.hive_size/3)))
	distort(user, target, pulse_cap)

/obj/effect/proc_holder/spell/target_hive/hive_warp/proc/distort(user, target, pulse_cap, pulses = 0)
	for(var/mob/living/carbon/human/victim in view(7,target))
		if(user == victim)
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

/obj/effect/proc_holder/spell/targeted/hive_hack/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/human/target = targets[1]
	var/in_hive = hive.hivemembers.Find(target)
	var/list/enemies = list()
	var/enemy_names = ""

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
			if(!M || M.current == user)
				continue
			if(enemy.hivemembers.Find(target))
				var/hive_name = enemy.get_real_name()
				if(hive_name)
					enemies += hive_name
				enemy.remove_from_hive(target)
				to_chat(M.current, "<span class='userdanger'>We detect a surge of psionic energy from [target.real_name] before they disappear from the hive. An enemy host, or simply a stolen vessel?</span>")
			if(enemy.owner == target)
				user.Stun(70)
				user.Jitter(14)
				to_chat(user, "<span class='userdanger'>A sudden surge of psionic energy rushes into your mind, only a Hive host could have such power!!</span>")
				return
		if(enemies.len)
			enemy_names = enemies.Join(". ")
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. [enemy_names]. They are watching us. They know we are coming.</span>")
		else
			to_chat(user, "<span class='notice'>We peer into the inner depths of their mind and see nothing, no enemies lurk inside this mind.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/targeted/hive_assim
	name = "Mass Assimilation"
	desc = "Should we capture an enemy Hive host, we can assimilate their entire hive into ours. It is unlikely their mind will surive the ordeal."
	panel = "Hivemind Abilities"
	charge_max = 3000
	range = 1
	invocation_type = "none"
	clothes_req = 0
	max_targets = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "assim"

/obj/effect/proc_holder/spell/targeted/hive_assim/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/human/target = targets[1]

	to_chat(user, "<span class='notice'>We tear into [target.name]'s mind with all our power!</span>")
	to_chat(target, "<span class='userdanger'>You feel an excruciating pain in your head!</span>")
	if(do_after(user,150,1,target))
		if(!target.mind)
			to_chat(user, "<span class='notice'>This being has no mind!</span>")
			revert_cast()
			return
		var/datum/antagonist/hivemind/enemy_hive = target.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(enemy_hive)
			to_chat(user, "<span class='danger'>We begin assimilating every psionic link we can find!.</span>")
			to_chat(target, "<span class='userdanger'>Our grip on our mind is slipping!</span>")
			target.Jitter(14)
			target.setBrainLoss(125)
			if(do_after(user,300,1,target))
				enemy_hive = target.mind.has_antag_datum(/datum/antagonist/hivemind) //Check again incase they lost it somehow
				if(enemy_hive)
					to_chat(user, "<span class='userdanger'>Ours. It is ours. Our mind has never been stronger, never been larger, never been mightier. And theirs is no more.</span>")
					to_chat(target, "<span class='userdanger'>Our vessels, they're! That's impossible! We can't... we can't... </span><span class ='notice'>I can't...</span>")
					hive.hivemembers |= enemy_hive.hivemembers
					enemy_hive.hivemembers = list()
					hive.calc_size()
					enemy_hive.calc_size()
					target.setBrainLoss(200)

					message_admins("[ADMIN_LOOKUPFLW(target)] was killed and had their hive stolen by [ADMIN_LOOKUPFLW(user)].")
					log_game("[key_name(target)] was killed via Mass Assimilation by [key_name(user)].")
				else
					to_chat(user, "<span class='notice'>It seems we have been mistaken, this mind is not the host of a hive.</span>")
			else
				to_chat(user, "<span class='userdanger'>Our concentration has been broken, leaving our mind wide open for a counterattack!</span>")
				to_chat(target, "<span class='userdanger'>Their concentration has been broken... leaving them wide open for a counterattack!</span>")
				user.Unconscious(120)
				user.adjustStaminaLoss(70)
				user.Jitter(60)
		else
			to_chat(user, "<span class='notice'>We appear to have made a mistake... this mind is too weak to be the one we're looking for.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		revert_cast()

/obj/effect/proc_holder/spell/self/hive_loyal
	name = "Bruteforce"
	desc = "Our ability to assimilate is temporarily boosted, allowing us to crush the technology shielding the minds of Security and Command personnel and assimilate them."
	panel = "Hivemind Abilities"
	charge_max = 1200
	invocation_type = "none"
	clothes_req = 0
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "loyal"

/obj/effect/proc_holder/spell/self/hive_loyal/cast(mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/obj/effect/proc_holder/spell/target_hive/hive_add/the_spell = locate(/obj/effect/proc_holder/spell/target_hive/hive_add) in user.mind.spell_list
	if(the_spell)
		the_spell.ignore_mindshield = TRUE
		to_chat(user, "<span class='notice'>We prepare to crush mindshielding technology!</span>")
		addtimer(VARSET_CALLBACK(the_spell, ignore_mindshield, FALSE), 300)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, user, "<span class='warning'>Our heightened power wears off, we are once again unable to assimilate mindshielded crew.</span>"), 300)
	else
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE5</span>")

/obj/effect/proc_holder/spell/targeted/forcewall/hive
	name = "Telekinetic Field"
	desc = "Our psionic powers form a barrier around us in the phsyical world that only we can pass through."
	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "forcewall"
	range = -1
	include_user = 1
	wall_type = /obj/effect/forcefield/wizard/hive

/obj/effect/proc_holder/spell/targeted/forcewall/hive/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user),user)
	for(var/dir in GLOB.alldirs)
		new wall_type(get_step(user, dir),user)

/obj/effect/forcefield/wizard/hive
	name = "Telekinetic Field"
	desc = "A psychic barrier, usable by only the strongest of minds."
	timeleft = 150

/obj/effect/forcefield/wizard/hive/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	return  FALSE