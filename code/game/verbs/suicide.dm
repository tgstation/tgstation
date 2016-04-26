/mob/var/suiciding = 0

/mob/living/carbon/human/verb/suicide()
	set hidden = 1
	if(!ticker)
		to_chat(src, "<span class='warning'>You can't commit suicide before the game starts!</span>")
		return

	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(istype(wear_mask, /obj/item/clothing/mask/happy))
		to_chat(src, "<span class='sinister'>BUT WHY? I'M SO HAPPY!</span>")
		return

	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B && B.controlling) //Borer
		to_chat(src, "<span class='warning'>You cannot commit suicide, your host is clinging to life enough to resist it.</span>")
		return

	var/permitted = 1
	var/list/allowed = list("Syndicate", "traitor", "Wizard", "Head Revolutionary", "Cultist", "Changeling")
	for(var/T in allowed)
		if(mind.special_role == T)
			permitted = 1
			break

	if(!permitted)
		message_admins("<span class='danger'>[ckey] has tried to suicide, but they were not permitted to due to being an antagonist.</span>", 1) //Fairly urgent
		to_chat(src, "<span class='warning'>Your masters and the gods won't let you do that without a proper reason.</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		if(!canmove || restrained()) //Just while I finish up the new 'fun' suiciding verb. This is to prevent metagaming via suicide
			to_chat(src, "<span class='warning'>You can't commit suicide whilst restrained!</span>")
			return
		suiciding = 1
		var/obj/item/held_item = get_active_hand()
		if(held_item)
			var/damagetype = held_item.suicide_act(src)
			if(damagetype)
				var/damage_mod = 1
				switch(damagetype) //Sorry about the magic numbers.
								   //brute = 1, burn = 2, tox = 4, oxy = 8
					if(15) //4 damage types
						damage_mod = 4

					if(6, 11, 13, 14) //3 damage types
						damage_mod = 3

					if(3, 5, 7, 9, 10, 12) //2 damage types
						damage_mod = 2

					if(1, 2, 4, 8) //1 damage type
						damage_mod = 1

					else //This should not happen, but if it does, everything should still work
						damage_mod = 1

				//Do 175 damage divided by the number of damage types applied.
				if(damagetype & BRUTELOSS)
					adjustBruteLoss(175/damage_mod)

				if(damagetype & FIRELOSS)
					adjustFireLoss(175/damage_mod)

				if(damagetype & TOXLOSS)
					adjustToxLoss(175/damage_mod)

				if(damagetype & OXYLOSS)
					adjustOxyLoss(175/damage_mod)

				//If something went wrong, just do normal oxyloss
				if(!(damagetype | BRUTELOSS) && !(damagetype | FIRELOSS) && !(damagetype | TOXLOSS) && !(damagetype | OXYLOSS))
					adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))

				updatehealth()
				return


		visible_message(pick("<span class='danger'>[src] is attempting to bite \his tongue off! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[src] is jamming \his thumbs into \his eye sockets! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[src] is twisting \his own neck! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[src] is holding \his breath! It looks like \he's trying to commit suicide.</span>"))
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

/mob/living/carbon/brain/verb/suicide()
	set hidden = 1
	if(!ticker)
		to_chat(src, "<span class='warning'>You can't commit suicide before the game starts!</span>")
		return

	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		if(!container)
			visible_message("<span class='danger'>[src]'s brain is growing dull and lifeless. It looks like it has lost the will to live.</span>")
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")
		spawn(50)
			death(0)
			suiciding = 0

/mob/living/carbon/monkey/verb/suicide()
	set hidden = 1
	if(!ticker)
		to_chat(src, "<span class='warning'>You can't commit suicide before the game starts!</span>")
		return

	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/mob/living/simple_animal/borer/B=has_brain_worms()
	if (B && B.controlling) // Borer
		to_chat(src, "Your can't suicide while controlling your host, you dick.")
		return


	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		if(!canmove || restrained())
			to_chat(src, "You can't commit suicide whilst restrained! ((You can type Ghost instead however.))")
			return
		suiciding = 1
		//instead of killing them instantly, just put them at -175 health and let 'em gasp for a while
		visible_message("<span class='danger'>\The [src] is attempting to bite \his tongue off. It looks like \he's trying to commit suicide.</span>")
		adjustOxyLoss(max(175 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

/mob/living/silicon/ai/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is powering down. It looks like \he's trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is powering down. It looks like \he's trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(maxHealth * 2 - getToxLoss() - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		stat = DEAD //new robot shit doesnt care about oxyloss
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

/mob/living/silicon/pai/verb/suicide()
	set category = "pAI Commands"
	set desc = "Kill yourself and become a ghost (You will receive a confirmation prompt)"
	set name = "pAI Suicide"
	var/answer = input("REALLY kill yourself? This action can't be undone.", "Suicide", "No") in list ("Yes", "No")
	if(answer == "Yes")
		var/obj/item/device/paicard/card = loc
		card.removePersonality()
		var/turf/T = get_turf(card.loc)
		for (var/mob/M in viewers(T))
			visible_message("<span class='notice'>[src] flashes a message across its screen, \"Wiping core files. Please acquire a new personality to continue using pAI device functions.\"</span>")
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")
		death(0)

/mob/living/carbon/alien/humanoid/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] is thrashing around wildly! It looks like \he's trying to commit suicide.</span>")
		//put em at -175
		adjustOxyLoss(max(175 - getFireLoss() - getBruteLoss() - getOxyLoss(), 0))
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

/mob/living/carbon/slime/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] starts vibrating uncontrollably! It looks like \he's trying to commit suicide.</span>")
		setOxyLoss(100)
		adjustBruteLoss(100 - getBruteLoss())
		setToxLoss(100)
		setCloneLoss(100)
		updatehealth()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")

//Default for all simple animals, using the Die() proc. Custom cases below
/mob/living/simple_animal/verb/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] suddenly starts thrashing around! It looks like \he's trying to commit suicide.</span>")
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")
		Die()

/mob/living/simple_animal/spiderbot/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] suddenly topples over and starts thrashing around! It looks like \he's trying to commit suicide.</span>")
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")
		Die() //Handles death properly enough

/mob/living/simple_animal/borer/suicide()
	set hidden = 1
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return

	if(suiciding)
		to_chat(src, "<span class='warning'>You're already committing suicide! Be patient!</span>")
		return

	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")

	if(confirm == "Yes")
		suiciding = 1
		visible_message("<span class='danger'>[src] suddenly starts trashing around [host ? "[host]'s head":""]! It looks like \he's trying to commit suicide.</span>")
		detach()
		log_attack("<font color='red'>[key_name(src)] used the suicide verb.</font>")
		Die()