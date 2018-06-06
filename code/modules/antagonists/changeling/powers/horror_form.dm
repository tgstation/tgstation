/obj/effect/proc_holder/changeling/horror_form //Horror Form: turns the changeling into a terrifying abomination
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will become an unstoppable force of destruction. We will turn back into a human after some time."
	chemical_cost = 75
	dna_cost = 1
	req_human = TRUE

/obj/effect/proc_holder/changeling/horror_form/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform || !ishuman(user))
		return 0
	var/mob/living/carbon/human/H = user
	var/OwO = alert(H, "Are you sure you want to hatch? You cannot undo this!",,"Yes", "No")
	switch(OwO)
		if("No")
			return FALSE
		if("Yes")
			H.visible_message("<span class='warning'>[H]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!</span>", \
							"<span class='shadowling'>You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you. Moving will disrupt the transformation!</span>")
			for(var/obj/item/I in H)
				H.dropItemToGround(I)
			if(!do_mob(H, H, 50))
				to_chat(H, "<span class='userdanger'Transformation interrupted!</span>")
				return TRUE //yeah, still steal all of their chems. If someone pushes you while you're cocooning you get FUCKED, should have just cancelled
			for(var/turf/open/floor/F in orange(1, H))
				new /obj/structure/alien/resin/wall/horrorform(F)
			H.visible_message("<span class='warning'>A chrysalis forms around [H], sealing them inside.</span>", \
							"<span class='shadowling'>We create your chrysalis and begin to contort within.</span>")
			sleep(100) //NOW we do sleeps- we're going too deep into the transformation to cancel and we're cocooned in indestructable walls anyways.
			H.visible_message("<span class='warning'><b>The skin on [H]'s back begins to split apart. Sickly spines slowly emerge from the divide.</b></span>", \
							"<span class='shadowling'>Spines pierce our back. Our claws break apart your fingers.</span>")
			sleep(90)
			H.visible_message("<span class='warning'><b>[H]'s skin shifts and morphing new faces, appendages slipping out and hang at the floor. A few of these appendages begin to scratch at the membrane.</b></span>", \
							"<span class='shadowling'>Our stable form finally gives way to something so much more beautiful. We begin tearing at the fragile membrane protecting us.</span>")
			sleep(80)
			playsound(H.loc, 'sound/weapons/slash.ogg', 25, 1)
			to_chat(H, "<i><b>You rip and slice.</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
			to_chat(H, "<i><b>The chrysalis falls like water before you.</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slice.ogg', 25, 1)
			to_chat(H, "<i><b>FREEDOM FROM OUR LESSER FORM!</b></i>")
			sleep(10)
			for(var/obj/structure/alien/resin/wall/horrorform/W in orange(1, H))
				playsound(W, 'sound/effects/splat.ogg', 50, 1)
				qdel(W)
			to_chat(H, "<i><b><font size=3>FREEDOM TO TAKE OVER THIS PITIFUL WORLD!!!</i></b></font>")
			playsound(user, 'sound/creatures/rawrXD.ogg', 100, 1)
			var/mob/living/simple_animal/hostile/true_changeling/new_mob = new(get_turf(H))
			var/datum/antagonist/changeling/ling_datum = H.mind.has_antag_datum(/datum/antagonist/changeling)
			new_mob.real_name = ling_datum.changelingID
			new_mob.name = new_mob.real_name
			for(var/mob/M in view(7, H))
				flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 50)
			new_mob.stored_changeling = H
			H.loc = new_mob
			H.status_flags |= GODMODE
			H.mind.transfer_to(new_mob)
			new /obj/effect/gibspawner/human(get_turf(H))
			return TRUE