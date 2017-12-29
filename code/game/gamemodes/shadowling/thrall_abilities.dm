
/obj/effect/proc_holder/spell/targeted/sling/lesser_glare //a defensive ability, nothing else. can't be used to stun people, steal tasers, etc. Just good for escaping
	name = "Lesser Glare"
	desc = "Makes a single target dizzy for a bit."
	panel = "Thrall Abilities"
	charge_max = 450
	human_req = TRUE
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "glare"
	thrall_ability = TRUE

/obj/effect/proc_holder/spell/targeted/sling/lesser_glare/InterceptClickOn(mob/living/caller, params, atom/t)
	. = ..()
	if(iscarbon(t))
		var/mob/living/carbon/target = t
		if(target.stat)
			to_chat(user, "<span class='warning'>[target] must be conscious!</span>")
			revert_cast()
			return
		if(is_shadow_or_thrall(target))
			to_chat(user, "<span class='warning'>You cannot glare at allies!</span>")
			revert_cast()
			return
		user.visible_message("<span class='warning'><b>[user]'s eyes flash a bright red!</b></span>")
		target.visible_message("<span class='danger'>[target] suddendly looks dizzy and nauseous...</span>")
		if(in_range(target, user))
			to_chat(target, "<span class='userdanger'>Your gaze is forcibly drawn into [user]'s eyes, and you suddendly feel dizzy and nauseous...</span>")
		else //Only alludes to the thrall if the target is close by
			to_chat(target, "<span class='userdanger'>Red lights suddenly dance in your vision, and you suddendly feel dizzy and nauseous...</span>")
		target.confused += 25
		target.Jitter(50)
		if(prob(25))
			target.vomit(10)
	else
		revert_cast()

////////////////////
////THRALL GUISE////
////////////////////

/obj/effect/proc_holder/spell/self/lesser_shadow_walk //Thrall version of Shadow Walk, only works in darkness, doesn't grant phasing, but gives near-invisibility
	name = "Guise"
	desc = "Wraps your form in shadows, making you harder to see."
	panel = "Thrall Abilities"
	charge_max = 1200
	human_req = TRUE
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	clothes_req = FALSE
	action_icon_state = "shadow_walk"

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/proc/reappear(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] appears from nowhere!</span>", "<span class='shadowling'>Your shadowy guise slips away.</span>")
	user.alpha = initial(user.alpha)

/obj/effect/proc_holder/spell/self/lesser_shadow_walk/cast(mob/living/carbon/human/user)
	user.visible_message("<span class='warning'>[user] suddenly fades away!</span>", "<span class='shadowling'>You veil yourself in darkness, making you harder to see.</span>")
	user.alpha = 10
	addtimer(CALLBACK(src, .proc/reappear, user), 40)


////////////////////////
////THRALL DARKSIGHT////
////////////////////////
/obj/effect/proc_holder/spell/self/thrall_night_vision //Toggleable night vision for thralls
	name = "Thrall Darksight"
	desc = "Allows you to see in the dark!"
	action_icon_state = "darksight"
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	clothes_req = FALSE
	charge_max = FALSE

/obj/effect/proc_holder/spell/self/thrall_night_vision/cast(mob/living/carbon/human/user)
	if(!is_shadow_or_thrall(user))
		revert_cast()
		return
	var/obj/item/organ/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return
	eyes.sight_flags = initial(eyes.sight_flags)
	switch(eyes.lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			eyes.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			eyes.sight_flags &= ~SEE_BLACKNESS
	user.update_sight()


//////////////////////
////THRALL COMMUNE////
//////////////////////
/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind //Lets a thrall talk with their allies
	name = "Lesser Commune"
	desc = "Allows you to silently communicate with all other shadowlings and thralls."
	panel = "Thrall Abilities"
	charge_max = 50
	human_req = 1
	clothes_req = 0
	action_icon = 'icons/mob/actions/actions_shadowling.dmi'
	action_icon_state = "commune"

/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind/cast(mob/living/carbon/human/user)
	if(!is_shadow_or_thrall(user))
		to_chat(user, "<span class='warning'><b>As you attempt to commune with the others, an agonizing spike of pain drives itself into your head!</b></span>")
		user.apply_damage(10, BRUTE, "head")
		return
	var/text = stripped_input(user, "What do you want to say your masters and fellow thralls?.", "Lesser Commune", "")
	if(!text)
		return
	text = "<span class='shadowling'><b>\[Thrall\]</b><i> [user.real_name]</i>: [text]</span>"
	for(var/mob/M in GLOB.mob_list)
		if(is_shadow_or_thrall(M))
			to_chat(M, text)
		if(isobserver(M))
			to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [text]")
	log_say("[user.real_name]/[user.key] : [text]")