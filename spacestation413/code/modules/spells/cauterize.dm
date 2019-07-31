/obj/effect/proc_holder/spell/targeted/cauterize
	name = "Cauterize"
	desc = "Replace all brute/burn damage with burn damage, taken over time. Higher levels increases time taken to return back to original damage level."
	clothes_req = TRUE
	human_req = FALSE
	charge_max = 800
	cooldown_min = 600 //50 deciseconds reduction per level
	range = -1
	var/cauterize_duration = 20 //in seconds
	include_user = TRUE
	invocation = "AMOS INO!"
	invocation_type = "shout"
	action_icon = 'spacestation413/icons/mob/actions.dmi'
	action_icon_state = "cauterize"

/obj/effect/proc_holder/spell/targeted/cauterize/cast(list/targets,mob/user = usr)
	for(var/mob/living/target in targets)
		INVOKE_ASYNC(src, .proc/do_cauterize, target)

/obj/effect/proc_holder/spell/targeted/cauterize/proc/do_cauterize(mob/living/target)
	var/total_dam = target.getBruteLoss() + target.getFireLoss()
	var/real_duration = cauterize_duration+((spell_level-1)*10) //60 at highest, same as cooldown
	target.adjustBruteLoss(-500)
	target.adjustFireLoss(-500)
	var/damage_per_tick=total_dam/real_duration
	if(total_dam>=100)
		to_chat(target, "<span class='warning'>You really feel like you should heal your burns!</span>")
	for(var/i in 1 to real_duration)
		sleep(10)
		target.adjustFireLoss(damage_per_tick)

/datum/spellbook_entry/cauterize
	name = "Cauterize"
	spell_type = /obj/effect/proc_holder/spell/targeted/cauterize
	category = "Defensive"
