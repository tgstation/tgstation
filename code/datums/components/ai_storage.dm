/datum/component/ai_storage
	var/mob/living/silicon/ai/AI
	var/wiping = FALSE

/datum/component/ai_storage/Initialize(_wiping=FALSE)
	wiping = _wiping
	RegisterSignal(COMSIG_ITEM_ATTACK_OBJ, .proc/attack_obj)

/datum/component/ai_storage/proc/wipe()
	INVOKE_ASYNC(src, .proc/wipe_loop)

/datum/component/ai_storage/proc/wipe_loop()
	if(AI && AI.loc == src)
		to_chat(AI, "<span class='userdanger'>Your core files are being wiped!</span>")
		while(AI.stat != DEAD && wiping)
			AI.adjustOxyLoss(1)
			AI.updatehealth()
			sleep(5)
		wiping = FALSE

/datum/component/ai_storage/proc/attack_obj(obj/target, mob/living/user)
	if(!user.Adjacent(target) || !target )
		return
	if(AI) //AI is on the card, implies user wants to upload it.
		target.transfer_ai(AI_TRANS_FROM_CARD, user, AI, src)
		add_logs(user, AI, "carded", src)
	else //No AI on the card, therefore the user wants to download one.
		target.transfer_ai(AI_TRANS_TO_CARD, user, null, src)