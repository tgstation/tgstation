/spell/targeted/wrapping_paper
	name = ""
	desc = "This spell turns a single person into an inert statue for a long period of time."

	school = "transmutation"
	charge_max = 300
	spell_flags = NEEDSCLOTHES | SELECTABLE
	range = 7
	max_targets = 1
	invocation = "You'll make a wonderful gift!"
	invocation_type = SpI_SHOUT
	amt_stunned = 5//just exists to make sure the giftwrap "catches" them
	cooldown_min = 30 //100 deciseconds reduction per rank

	hud_state = "wrap"

/spell/targeted/wrapping_paper/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/target in targets)
		var/obj/present = new /obj/structure/strange_present(target.loc,target)
		if (target.client)
			target.client.perspective = EYE_PERSPECTIVE
			target.client.eye = present
		target.forceMove(present)
	return