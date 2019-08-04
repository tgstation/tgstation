/datum/action/innate/cult/cult_sac //Sacrifice a body to Nar'Sie
	name = "Sacrifice"
	desc = "Offer a body to Nar'Sie in exchange for a fragment of his power, husking the body. You must be holding a sharp object to conduct the sacrifice."	
	button_icon_state = "carve"

/datum/action/innate/cult/cult_sac/Activate()
	var/obj/item/inhand = owner.get_active_held_item()
	if(!inhand)
		to_chat(owner, "<span class='cultitalic'>You need a sharp item in your hand to make a sacrifice!</span>")
		return
	if(inhand.sharpness == IS_BLUNT)
		to_chat(owner, "<span class='cultitalic'>You need a sharp item in your hand to make a sacrifice!</span>")
		return
	var/list/targets = list()
	for(var/mob/living/carbon/human/H in view_or_range(distance = 1, center = owner, type = "range"))
		if(ishuman(H) && H != owner && H.stat == DEAD)
			targets |= H
	var/mob/target
	if(!targets.len)
		return
	else if(targets.len == 1)
		target = targets[1]
	else
		target = input(owner, "Choose a target...", "Sacrifice") as null|anything in targets
	if(iscultist(target))
		to_chat(owner, "<span class='cultitalic'>You cannot sacrifice another cultist!</span>")
		return
	if(!target.mind)
		to_chat(owner, "<span class='cultitalic'>This body has no soul, it is useless!</span>")
		return
	if(HAS_TRAIT_FROM(target, TRAIT_HUSK, CULT_TRAIT))
		to_chat(owner, "<span class='cultitalic'>This body was already desecrated, you cannot sacrifice it again!</span>")
		return
	to_chat(owner, "<span class='cultitalic'>You start sacrificing the body...</span>")
	var/sac_delay = max(5, (20-inhand.force/2))*10
	if(do_after(owner, sac_delay, target = target))
		sacrifice_person(owner, target)
	else
		to_chat(owner, "<span class='cultitalic'>Your sacrifice was interrupted!</span>")

/proc/sacrifice_person(mob/user, mob/living/target)
	user.add_mob_blood(target)
	target.become_husk(CULT_TRAIT)
	var/datum/antagonist/cult/cultistinfo = user.mind.has_antag_datum(/datum/antagonist/cult)
	cultistinfo.add_sac(user)
	for(var/datum/objective/sacrifice/sac_objective in cultistinfo.cult_team.objectives)
		if(sac_objective.target == target.mind)
			sac_objective.sacced = TRUE
			sound_to_playing_players('sound/hallucinations/i_see_you1.ogg')
			sac_objective.update_explanation_text()
			to_chat(user, "<span class='cultlarge'>Yes! This is the one I desire! You have done well.</span>")
			for(var/datum/mind/B in cultistinfo.cult_team.members)
				if(B.current)
					to_chat(B.current, "<span class='cultlarge'>The interloper has been sacrificed.</span>")
		else
			to_chat(user, "<span class='cultlarge'>I accept this sacrifice.</span>")
