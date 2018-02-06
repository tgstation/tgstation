/obj/effect/proc_holder/spell/aimed/fireball
	desc = "This spell fires a fireball at a target and does not require wizard garb. Cannot be used while stunned or handcuffed."
	active_msg = "You prepare to cast your fireball spell! " //added a space to fix a text issue

/obj/effect/proc_holder/spell/aimed/fireball/perform(list/targets, recharge = 1, mob/user = usr)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.handcuffed)
			to_chat(C, "<span class='notice'>Your hands are restrained!</span>")
			revert_cast(user)
			return
	if(user.incapacitated())
		to_chat(user, "<span class='notice'>You can't move your hands into formation!</span>")
		revert_cast(user)
		return
	..()

/obj/effect/proc_holder/spell/aimed/lightningbolt
	active_msg = "You energize your staff with arcane lightning! " //added a space to fix a text issue, and replaced "hand" with "staff".