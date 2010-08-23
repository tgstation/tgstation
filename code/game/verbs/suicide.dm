/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1

	if (src.stat == 2)
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
		suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(src) << "\red <b>[src] is holding \his breath. It looks like \he's trying to commit suicide.</b>"
		src.oxyloss = max(175 - src.toxloss - src.fireloss - src.bruteloss, src.oxyloss)
		src.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			src.suiciding = 0

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1

	if (src.stat == 2)
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
		suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		viewers(src) << "\red <b>[src] is holding \his breath. It looks like \he's trying to commit suicide.</b>"
		src.oxyloss = max(175 - src.toxloss - src.fireloss - src.bruteloss, src.oxyloss)
		src.updatehealth()
		spawn(200) //in case they get revived by cryo chamber or something stupid like that, let them suicide again in 20 seconds
			src.suiciding = 0

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1

	if (src.stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		viewers(src) << "\red <b>[src] is powering down. It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		src.oxyloss = max(175 - src.toxloss - src.fireloss - src.bruteloss, src.oxyloss)
		src.updatehealth()
/mob/living/silicon/robot/verb/suicide()
	set hidden = 1

	if (src.stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		viewers(src) << "\red <b>[src] is powering down. It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		src.oxyloss = max(475 - src.toxloss - src.fireloss - src.bruteloss, src.oxyloss)
		src.updatehealth()

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1

	if (src.stat == 2)
		src << "You're already dead!"
		return

	if (suiciding)
		src << "You're already committing suicide! Be patient!"
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		viewers(src) << "\red <b>[src] is holding his breath. It looks like \he's trying to commit suicide.</b>"
		//put em at -175
		src.oxyloss = max(100 - src.fireloss - src.bruteloss, src.oxyloss)
		src.updatehealth()