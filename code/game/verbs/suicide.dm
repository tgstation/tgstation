/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (!ticker)
		src << "You can't commit suicide before the game starts!"
		return

	var/permitted = 0
	var/list/allowed = list("Syndicate","traitor","Wizard","Head Revolutionary","Cultist","Changeling")
	for(var/T in allowed)
		if(mind.special_role == T)
			permitted = 1
			break

	if(!permitted)
		message_admins("[ckey] has tried to suicide, but they were not permitted due to not being antagonist as human.", 1)
		src << "No. Adminhelp if there is a legitimate reason."
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(alien_egg_flag)
		src << "The alien inside you forces you to breathe, preventing you from suiciding."
		return

	if(mutantrace == "trappedsoul")
		src << "You are already dead, your soul trapped and contained!"
		return

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1

		if(mind.special_role == "Syndicate" || mind.special_role == "traitor" || mind.special_role == "Head Revolutionary")
			viewers(src) << "\red <b>[src] appears to be shifting \his tongue about in \his mouth frantically!</b>"
			src << "\red <b>You hear a muffled pop and poison starts burning your mouth. Everything fades to black.</b>"
			toxloss = max(175 - getOxyLoss() - getFireLoss() - getBruteLoss(), getToxLoss())

		else if (mind.special_role == "Wizard")
			viewers(src) << "\red <b>[src] mutters a chant under \his breath hurriedly and bursts into flames immediately after!</b>"
			src << "\red <b>An intense heat builds up as you chant under your breath, releasing the energy in a white-hot blaze as you finish.</b>"
			fireloss = max(175 - getOxyLoss() - getToxLoss() - getBruteLoss(), getFireLoss())

		else if (mind.special_role == "Cultist")
			viewers(src) << "\red <b>[src] mutters a prayer hastly and falls to the ground!</b>"
			src << "\red <b>You mutter a prayer hastly and feel your body become heavier.</b>"
			oxyloss = max(175 - getToxLoss() - getFireLoss() - getBruteLoss(), getOxyLoss())

		else if (mind.special_role == "Changeling")
			viewers(src) << "\red <b>[src] extends its proboscis and stabs itself in the chest!</b>"
			src << "\red <b>You extend your proboscis and stab yourself in the chest.</b>"
			bruteloss = max(175 - getToxLoss() - getFireLoss() - getOxyLoss(), getBruteLoss())

		updatehealth()

/mob/living/carbon/brain/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (!ticker)
		src << "You can't commit suicide before the game starts!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		viewers(loc) << "\red <b>[src]'s brain is growing dull and lifeless. It looks like it's lost the will to live.</b>"
		spawn(50)
			death(0)
			suiciding = 0

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (!ticker)
		src << "You can't commit suicide before the game starts!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(src) << "\red <b>[src] is attempting to bite \his tongue. It looks like \he's trying to commit suicide.</b>"
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		viewers(src) << "\red <b>[src] is powering down. It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		viewers(src) << "\red <b>[src] is powering down. It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		adjustOxyLoss(max(475 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()

/mob/living/silicon/pai/verb/suicide()
	set category = "pAI Commands"
	set desc = "Kill yourself and become a ghost (You will receive a confirmation prompt)"
	set name = "pAI Suicide"
	var/answer = input("REALLY kill yourself? This action can't be undone.", "Suicide", "No") in list ("Yes", "No")
	if(answer == "Yes")
		message_admins("[ckey] has suicided.", 1)
		var/obj/item/device/paicard/card = loc
		card.pai = null
		var/turf/T = get_turf_or_move(card.loc)
		for (var/mob/M in viewers(T))
			M.show_message("\blue [src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"", 3, "\blue [src] bleeps electronically.", 2)
		death(0)
	else
		src << "Aborting suicide attempt."

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1

	if (stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		viewers(src) << "\red <b>[src] is thrashing wildly! It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		adjustOxyLoss(max(100 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()


/mob/living/carbon/metroid/verb/suicide()
	set hidden = 1
	if (stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		message_admins("[ckey] has suicided.", 1)
		suiciding = 1
		setOxyLoss(100)
		adjustBruteLoss(100 - getBruteLoss())
		setToxLoss(100)
		setCloneLoss(100)

		updatehealth()
