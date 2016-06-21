//Unlike revenants, abilities used by umbras generally don't cost any vitae.

/obj/effect/proc_holder/spell/targeted/night_vision/umbra //Toggle Nightvision: Self-explanatory
	panel = "Umbral Evocation"
	message = "<span class='umbra'>You toggle your night vision.</span>"
	charge_max = 0
	action_icon_state = "umbral_sight"
	action_background_icon_state = "bg_umbra"


/obj/effect/proc_holder/spell/targeted/discordant_whisper //Discordant Whisper: Sends a single, silent message to a creature that the umbra can see. Doesn't work on dead targets.
	name = "Discordant Whisper"
	desc = "Telepathically sends a single message to a target within range. Nobody else can perceive this message, and it works on unconscious and deafened targets."
	panel = "Umbral Evocation"
	range = 7
	charge_max = 50
	clothes_req = FALSE
	include_user = FALSE
	action_icon_state = "discordant_whisper"
	action_background_icon_state = "bg_umbra"

/obj/effect/proc_holder/spell/targeted/discordant_whisper/cast(list/targets, mob/living/simple_animal/umbra/user)
	if(!isumbra(user))
		revert_cast()
		return
	var/mob/living/target = targets[1]
	if(target.stat == DEAD)
		user << "<span class='warning'>You can't send thoughts to the dead!</span>"
		revert_cast()
		return
	var/message = stripped_input(user, "Enter a message to transmit to [target].", "Discordant Whisper")
	if(!message || !target)
		revert_cast()
		return
	log_say("UmbraWhisper: [key_name(user)] -> [key_name(target)]: [message]")
	user << "<span class='umbra_bold'>You whisper to [target]:</span> <span class='umbra'>\"[message]\"</span>"
	target << "<span class='umbra_emphasis'>You hear an otherworldly voice...</span> <span class='umbra'>\"[message]\"</span>"
	for(var/mob/dead/observer/O in dead_mob_list)
		var/f1 = FOLLOW_LINK(O, user)
		var/f2 = FOLLOW_LINK(O, target)
		O << "[f1] <span class='umbra_bold'>[user] (Umbra Whisper):</span> <span class='umbra'>\"[message]\"</span> to [f2] <span class='name'>[target]</span>"


/obj/effect/proc_holder/spell/targeted/possess //Possess: Occupies the body of a sapient and living human, slowly training vitae while they're conscious.
	name = "Possess/Unpossess"
	desc = "Enters and merges with the body of a nearby human. While inside of this human, you will very slowly generate vitae."
	panel = "Umbral Evocation"
	range = 1
	charge_max = 600
	clothes_req = FALSE
	include_user = FALSE
	action_icon_state = "possess"
	action_background_icon_state = "bg_umbra"

/obj/effect/proc_holder/spell/targeted/possess/cast(list/targets, mob/living/simple_animal/umbra/user)
	if(!isumbra(user))
		revert_cast()
		return
	if(!user.possessed)
		var/mob/living/carbon/human/target = targets[1]
		if(!ishuman(target))
			user << "<span class='warning'>Only humans can produce enough vitae to sustain you in this manner!</span>"
			revert_cast()
			return
		user.possessed = target
		user.loc = target
		user << "<span class='umbra_emphasis'>You silently enter [user.possessed]'s body and begin leeching vitae. You won't be able to do this for very long.</span>"
		user.notransform = TRUE
	else
		user.unpossess()


/obj/effect/proc_holder/spell/targeted/thoughtsteal //Thoughtsteal: Paralyzes and deals temporary brain damage to a target as the umbra drains it of vitae.
	name = "Thoughtsteal"
	desc = "Immobilizes a target as you copy their memories, gaining the knowledge of whatever they know."
	panel = "Umbral Evocation"
	range = 1
	charge_max = 450
	clothes_req = FALSE
	include_user = FALSE
	action_icon_state = "thoughtsteal"
	action_background_icon_state = "bg_umbra"

/obj/effect/proc_holder/spell/targeted/thoughtsteal/cast(list/targets, mob/living/simple_animal/umbra/user)
	if(!isumbra(user))
		revert_cast()
		return
	var/mob/living/target = targets[1]
	if(target in user.lobotomized)
		user << "<span class='warning'>You've already stolen [target]'s memories!</span>"
		revert_cast()
		return
	if(target.stat == DEAD)
		user << "<span class='warning'>You can't glean any knowledge from a dead brain!</span>"
		revert_cast()
		return
	if(!target.mind)
		user << "<span class='warning'>[target] is mindless and incapable of higher thought!</span>"
		revert_cast()
		return
	if(user.possessed)
		user << "<span class='warning'>Unpossess [user.possessed] first!</span>"
		revert_cast()
		return
	user.visible_message("<span class='warning'>[user] appears from nowhere, stretching out towards [target]!</span>", "<span class='umbra'>You try to copy [target]'s memories...</span>")
	target.visible_message("<span class='warning'>A blue beam arcs into [target]'s head, immobilizing them!</span>", "<span class='userdanger'>Your mind freezes. You can't move. \
	You can't think.</span>")
	user.Beam(target, icon = 'icons/effects/beam.dmi', icon_state = "b_beam", time = 50)
	user.immobilize(50)
	user.reveal(50)
	target.Stun(5)
	if(!do_after(user, 50, target = target))
		return
	user.visible_message("<span class='warning'>A chunk of biomatter travels along the beam and into [user]!</span>", \
	"<span class='umbra_bold'>Sweet, sweet thoughts. A lifetime of memories surges through you.</span>")
	target.visible_message("<span class='warning'>[target] silently collapses, motionless.</span>", "<span class='userdanger'>Your mind blanks. Your thoughts have fled. Slowly, they begin to \
	return... but you feel <i>wrong.</i></span>")
	target.mind.show_memory(user, 0)
	user.mind.memory += "<b><i>[target.real_name]'s Memories:</i></b><br>[target.mind.memory]<br><br>"
	target.Weaken(5)
	user.lobotomized |= target
