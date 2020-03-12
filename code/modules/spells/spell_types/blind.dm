/*
/obj/effect/proc_holder/spell/targeted/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."

	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 50 //12 deciseconds reduction per rank

	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/blind","/obj/effect/proc_holder/spell/targeted/genetic/blind")

	action_icon_state = "blind"

/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20
	sound = 'sound/magic/blind.ogg'

/obj/effect/proc_holder/spell/targeted/genetic/blind
	mutations = list(BLINDMUT)
	duration = 300
	charge_max = 400 // needs to be higher than the duration or it'll be permanent
	sound = 'sound/magic/blind.ogg'
*/

/////////

/obj/effect/proc_holder/spell/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single target."

	school = "transmutation"
	charge_max = 300
	clothes_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 50 //12 deciseconds reduction per rank

	action_icon_state = "blind"

	active = FALSE
	ranged_mousepointer = 'icons/effects/cult_target.dmi'

/obj/effect/proc_holder/spell/blind/Destroy()
	. = ..()
	if(action && !QDELETED(action))
		QDEL_NULL(action)

/obj/effect/proc_holder/horror/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='cult'>You dispel the magic...</span>")
	else
		add_ranged_ability(user, "<span class='cult'>You prepare to horrify a target...</span>")

/obj/effect/proc_holder/horror/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated() || !iscultist(caller))
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return FALSE
	if(target in view(7, get_turf(ranged_ability_user)))
		if(!ishuman(target) || iscultist(target))
			return
		var/mob/living/carbon/human/H = target
		H.hallucination = max(H.hallucination, 120)
		SEND_SOUND(ranged_ability_user, sound('sound/effects/ghost.ogg',0,1,50))
		var/image/C = image('icons/effects/cult_effects.dmi',H,"bloodsparkles", ABOVE_MOB_LAYER)
		add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/cult, "cult_apoc", C, NONE)
		addtimer(CALLBACK(H,/atom/.proc/remove_alt_appearance,"cult_apoc",TRUE), 2400, TIMER_OVERRIDE|TIMER_UNIQUE)
		to_chat(ranged_ability_user,"<span class='cult'><b>[H] has been cursed with living nightmares!</b></span>")
		attached_action.charges--
		attached_action.desc = attached_action.base_desc
		attached_action.desc += "<br><b><u>Has [attached_action.charges] use\s remaining</u></b>."
		attached_action.UpdateButtonIcon()
		if(attached_action.charges <= 0)
			remove_ranged_ability("<span class='cult'>You have exhausted the spell's power!</span>")
			qdel(src)
