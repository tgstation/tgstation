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

	ranged_mousepointer = 'icons/effects/cult_target.dmi'
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

/obj/effect/proc_holder/spell/targeted/trigger/blind/Click()
	if(cast_check(TRUE))
		toggle(usr)
	return TRUE

/obj/effect/proc_holder/spell/targeted/trigger/blind/proc/toggle(mob/user)
	if(active)
		remove_ranged_ability("<span class='notice'>You dispel the magic...</span>")
	else
		add_ranged_ability(user, "<span class='notice'>You prepare to blind a target...</span>")

/obj/effect/proc_holder/spell/targeted/trigger/blind/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(ranged_ability_user.incapacitated())
		remove_ranged_ability()
		return
	var/turf/T = get_turf(ranged_ability_user)
	if(!isturf(T))
		return
	if(!isliving(target))
		to_chat(ranged_ability_user, "<span class='warning'>You can only blind living beings!</span>")
		return
	perform(list(target), TRUE, ranged_ability_user)
	remove_ranged_ability("<span class='notice'>You have exhausted the spell's power!</span>")
