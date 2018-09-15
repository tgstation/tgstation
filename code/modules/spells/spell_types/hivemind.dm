/obj/effect/proc_holder/spell/target_hive
	panel = "Hivemind Abilities"
	still_recharging_msg = "<span class='notice'>Our psionic powers are still recharging.</span>"
	invocation_type = "none"
	selection_type = "range"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "spell_default"
	clothes_req = 0
	human_req = 1
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

	charge_max = 300
	range = 4
	target_external = 1

/obj/effect/proc_holder/spell/target_hive/hive_add/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE

	if(/*target.mind && target.mind.client &&*/ target.stat != DEAD) //uncomment later
		if(!target.has_trait(TRAIT_MINDSHIELD))
			to_chat(user, "<span class='notice'>We begin linking our mind with [target.name]!</span>")
			if(do_mob(user,user,70))
				to_chat(user, "<span class='notice'>Our mind is ready to connect [target.name] to the Hive!</span>")
				if((target in oview(range)) && do_mob(user,target,30))
					to_chat(user, "<span class='notice'>[target.name] was added to the Hive!</span>")
					success = TRUE
					hive.add_to_hive(target)
				else
					to_chat(user, "The connection between [target.name] has been disrupted!")
			else
				to_chat(user, "We fail to connect to [target.name].")
		else
			to_chat(user, "Powerful technology protects [target.name]'s mind.")
	else
		to_chat(user, "We detect no neural activity in this body.")
	if(!success)
		charge_counter = charge_max

/obj/effect/proc_holder/spell/target_hive/hive_remove
	name = "Release Vessel"
	desc = "We silently remove a nearby target from the hive."
	selection_type = "view"
	action_icon_state = "remove"

	charge_max = 100
	range = 4

/obj/effect/proc_holder/spell/target_hive/hive_remove/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]

	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	hive.hivemembers -= target
	hive.calc_size()
	to_chat(user, "We remove [target.name] from the hive")

/obj/effect/proc_holder/spell/target_hive/hive_see
	name = "Hive Vision"
	desc = "We use the eyes of one of our vessels. Use again to look through our own eyes once more."
	action_icon_state = "see"

	charge_max = 150

/obj/effect/proc_holder/spell/target_hive/on_lose(mob/user)
	if(active)
		user.reset_perspective(null)

/obj/effect/proc_holder/spell/target_hive/hive_see/cast(list/targets, mob/living/user = usr)
	if(!active)
		var/mob/target = targets[1]
		user.reset_perspective(target)
		active = TRUE
		charge_counter = charge_max
	else
		user.reset_perspective(null)
		active = FALSE

/obj/effect/proc_holder/spell/target_hive/hive_see/choose_targets(mob/user = usr)
	if(!active)
		..()
	else
		perform(,user)

/obj/effect/proc_holder/spell/target_hive/hive_shock
	name = "Neural Shock"
	desc = "After a short charging time, we overload the mind of one of our vessels with psionic energy, rendering them unconscious for a short period of time. This power is weaker over long distances."
	action_icon_state = "shock"

	charge_max = 600

/obj/effect/proc_holder/spell/target_hive/hive_shock/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	to_chat(user, "<span class='notice'>We begin increasing the psionic bandwidth between ourself and the vessel!</span>")
	if(do_mob(user,user,60))
		var/power = 120-get_dist(user, target)
		if(power > 5 && user.z == target.z)
			to_chat(target, "<span class='userdanger'>You feel a sharp pain, and foreign presence in your mind!!</span>")
			to_chat(user, "<span class='notice'>We have overloaded the vessel for a short time!</span>")
			target.Jitter(power)
			target.adjustStaminaLoss(round(power/2))
			target.Unconscious(power)
		else
			to_chat(user, "<span class='notice'>The vessel was too far away to be affected!</span>")
	else
		to_chat(user, "<span class='notice'>Our channeling has been interrupted!</span>")
		charge_counter = charge_max

/obj/effect/proc_holder/spell/self/hive_drain
	name = "Repair Protocol"
	desc = "Our many vessels sacrifice a small portion of their mind's vitality to cure us of our physical and mental ailments."

	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	still_recharging_msg = "<span class='notice'>Our psionic powers are still recharging.</span>"
	invocation_type = "none"
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "drain"
	human_req = 1

/obj/effect/proc_holder/spell/self/hive_drain/cast(mob/living/carbon/human/user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		return
	var/iterations = 0
	var/power = 5

	if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss() && !user.getBrainLoss())
		to_chat(user, "<span class='notice'>We cannot heal ourselves anymore with this power!</span>")
	to_chat(user, "<span class='notice'>We begin siphoning power from our many vessels!</span>")
	while(iterations < 7)
		var/mob/living/carbon/human/target = pick(hive.hivemembers)
		if(!target)
			break
		if(!do_mob(user,user,15))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		target.adjustBrainLoss(5)
		power = max(5-(round(get_dist(user, target)/40)),2)
		if(user.getCloneLoss()) //If we have genetic damage, prioritize this
			user.adjustCloneLoss(-power)
		else if(user.getBruteLoss() || user.getFireLoss()) //Otherwise heal the type we have more of
			if(user.getBruteLoss() > user.getFireLoss())
				user.adjustBruteLoss(-power)
			else
				user.adjustFireLoss(-power)
		else //If we don't have any of these, stop looping
			to_chat(user, "<span class='warning'>We finish our healing</span>")
			break
		iterations++
	user.setBrainLoss(0)


/obj/effect/proc_holder/spell/target_hive/hive_force
	name = "Cerebellic Pulse"
	desc = "We pulse the cerebellum of the target, forcing them to move in whatever direction we look at."
	charge_max = 50 //change to 600
	action_icon_state = "force"

/obj/effect/proc_holder/spell/target_hive/hive_force/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/power = 20-(round(get_dist(user, target)/5))

	if(power < 5  || user.z != target.z)
		to_chat(user, "<span class='notice'>[target.name] is too far away to use this power on!</span>")
		return
	to_chat(user, "<span class='notice'>We prepare to pulse [target.name]'s cerebellum!</span>")
	if(!do_mob(user,user,15))
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		charge_counter = charge_max
		return
	to_chat(user, "<span class='notice'>We pulse [target.name]'s cerebellum, forcing him to move!</span>")
	while(power > 0)
		if(!target || !target.canmove)
			break
		if(!do_mob(user,user,3,0,0))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		var/turf/T = get_step(target,user.dir)
		target.Move(T)
		power--
	if(power == 0)
		to_chat(user, "<span class='warning'>We reach our limit and stop moving [target.name]!</span>")

/obj/effect/proc_holder/spell/targeted/induce_panic
	name = "Induce Panic"
	desc = "We unleash a burst of psionic energy, inducing fear in those around us."
	panel = "Hivemind Abilities"
	charge_max = 1500
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
				target.Jitter(14)
			if(4)
				to_chat(target, "<span class='userdanger'>You feel nauseous as dread washes over you!</span>")
				target.Dizzy(15)
				target.adjustStaminaLoss(45)
				target.hallucination += 45

/obj/effect/proc_holder/spell/target_hive/hive_attack
	name = "Medullary Failure"
	desc = "We overload the target's medulla, inducing an immediate heart attack."

	charge_max = 50 //Change to 3000
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

/obj/effect/proc_holder/spell/targeted/hive_hack
	name = "Network Invasion"
	desc = "We probe the mind of an adjacent target and extract valuable information on any enemy hives they may belong to. Takes longer if the target is not in our hive."
	panel = "Hivemind Abilities"
	charge_max = 1500
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
	if(do_mob(user,target,15))
		if(!in_hive)
			to_chat(user, "<span class='notice'>Their mind slowly opens up to us.</span>")
			if(!do_mob(user,target,30))
				to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
				charge_counter = charge_max
		for(var/datum/antagonist/hivemind/enemy in GLOB.antagonists)
			if(enemy.hivemembers.Find(target))
				enemies += enemy.owner.name
				enemy.remove_from_hive(target)
			if(enemy.owner == target)
				user.Stun(70)
				user.Jitter(14)
				to_chat(user, "<span class='userdanger'>A sudden surge of psionic energy rushes into your mind, only a Hive host could have such power!!</span>")
				return
		if(enemies.len)
			enemy_names = enemies.Join(". ")
			to_chat(user, "<span class='userdanger'>In a moment of clarity, we see all. Another hive. Faces. Our nemesis. [enemy_names]. They are watching us. They know we are coming.</span>")
		else
			to_chat(user, "<span class='notice'>We peer into the inner depths of their mind and see nothing. </span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		charge_counter = charge_max

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
	if(do_mob(user,target,150))
		if(!target.mind)
			to_chat(user, "<span class='notice'>This being has no mind!</span>")
			charge_counter = charge_max
			return
		var/datum/antagonist/hivemind/enemy_hive = target.mind.has_antag_datum(/datum/antagonist/hivemind)
		if(enemy_hive)
			to_chat(user, "<span class='danger'>We begin assimilating every psionic link we can find!.</span>")
			to_chat(target, "<span class='userdanger'>Our grip on our mind is slipping!</span>")
			target.Jitter(14)
			target.setBrainLoss(125)
			if(do_mob(user,target,300))
				enemy_hive = target.mind.has_antag_datum(/datum/antagonist/hivemind) //Check again incase they lost it somehow
				if(enemy_hive)
					to_chat(user, "<span class='userdanger'>Ours. It is ours. Our mind has never been stronger, never been larger, never been mightier. And theirs is no more.</span>")
					to_chat(target, "<span class='userdanger'>Our vessels, they're! That's impossible! We can't... we can't... </span><span class ='notice'>I can't...</span>")
					hive.hivemembers |= enemy_hive.hivemembers
					enemy_hive.hivemembers = list()
					hive.calc_size()
					enemy_hive.calc_size()
					target.setBrainLoss(200)
				else
					to_chat(user, "<span class='notice'>It seems we have been mistaken, this mind is not the host of a hive.</span>")
			else
				to_chat(user, "<span class='userdanger'>Our concentration has been broken, leaving our mind wide open for a counterattack!</span>")
				to_chat(target, "<span class='userdanger'>Their concentration has been broken... and are wide open for a counterattack!</span>")
				user.Unconscious(120)
				user.adjustStaminaLoss(70)
				user.Jitter(60)
		else
			to_chat(user, "<span class='notice'>We appear to have made a mistake... this mind is too weak to be the one we're looking for.</span>")
	else
		to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")

/obj/effect/proc_holder/spell/targeted/hive_loyal
	name = "Bruteforce"
	desc = "We crush the technology shielding the minds of Security and Command personell, allowing us to assimilate them into the hive."
	panel = "Hivemind Abilities"
	charge_max = 3000
	range = 1
	invocation_type = "none"
	clothes_req = 0
	max_targets = 1
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "loyal"

/obj/effect/proc_holder/spell/targeted/hive_loyal/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	var/mob/living/carbon/human/target = targets[1]


	if(target.has_trait(TRAIT_MINDSHIELD))
		to_chat(user, "<span class='notice'>We begin scanning [target.name]'s body with our mind!</span>")
		if(do_mob(user,target,150))
			to_chat(user, "<span class='notice'>We find the shield generator and attempt to surround it with our psionic powers!</span>")
			if(do_mob(user,target,150))
				if(SEND_SIGNAL(target, COMSIG_HAS_NANITES))
					to_chat(user, "<span class='notice'>Synthetic microorganisms delay our task...</span>")
					if(!do_mob(user,target,150))
						to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
						return
					else
						SEND_SIGNAL(target, COMSIG_NANITE_SET_VOLUME, 0)
				to_chat(user, "<span class='notice'>The mechanisms shielding [target.name]'s mind were crushed! Their mind is ready for assimilation.</span>")
				for(var/obj/item/implant/mindshield/M in target.implants)
					qdel(M)
			else
				to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
		else
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
	else
		to_chat(user, "<span class='notice'>This mind is not shielded!</span>")

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

/obj/effect/forcefield/wizard/hive/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	return  FALSE