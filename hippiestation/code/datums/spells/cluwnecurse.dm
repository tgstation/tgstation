/obj/effect/proc_holder/spell/targeted/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	charge_type = "recharge"
	charge_max	= 600
	charge_counter = 0
	clothes_req = 1
	stat_allowed = 0
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = "shout"
	range = 3
	cooldown_min = 75
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human)
	action_icon = 'hippiestation/icons/mob/actions.dmi'
	action_icon_state = "cluwne"

/obj/effect/proc_holder/spell/targeted/cluwnecurse/cast(list/targets, mob/user = usr)
	if(!targets.len)
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return
	var/mob/living/carbon/target = targets[1]
	if(!(target.type in compatible_mobs))
		to_chat(user, "<span class='notice'>You are unable to curse [target]!</span>")
		return
	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>They are too far away!</span>")
		return
	var/mob/living/carbon/human/H = target
	H.cluwneify()
