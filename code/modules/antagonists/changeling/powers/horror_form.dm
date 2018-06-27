/obj/effect/proc_holder/changeling/horror_form //Horror Form: turns the changeling into a terrifying abomination
	name = "Horror Form"
	desc = "We tear apart our human disguise, revealing our true form."
	helptext = "We will cocoon and metamorph into our horror form, allowing us to enslave others and take over. We need to absorb three other true changelings (xenobiology and other lesser changelings do not count) to do this."
	chemical_cost = 75
	dna_cost = 1
	req_changelingabsorbs = 3
	req_human = TRUE
	var/inprogress = FALSE

/obj/effect/proc_holder/changeling/horror_form/sting_action(mob/living/carbon/human/user)
	if(!user || user.notransform || !ishuman(user) || inprogress)
		return 0
	var/mob/living/carbon/human/H = user
	var/OwO = alert(H, "Are you sure you want to hatch? You cannot undo this!",,"Yes", "No")
	switch(OwO)
		if("No")
			return FALSE
		if("Yes")
			inprogress = TRUE
			H.visible_message("<span class='warning'>[H]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!</span>", \
							"<font color=#800080>You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you. <b>Moving will disrupt the transformation!</b></font>")
			for(var/obj/item/I in H)
				H.dropItemToGround(I)
			if(!do_mob(H, H, 50))
				to_chat(H, "<span class='userdanger'Transformation interrupted!</span>")
				inprogress = FALSE
				return FALSE
			var/turf/damonster = get_turf(H)
			for(var/turf/open/floor/F in orange(1, H))
				new /obj/structure/alien/resin/wall/cocoon(F)
			for(var/obj/structure/alien/resin/wall/cocoon/R in damonster) //extremely hacky
				qdel(R)
				new /obj/structure/alien/weeds/node(damonster) //Dim lighting in the chrysalis -- removes itself afterwards
			for(var/obj/structure/alien/weeds/node/shitcode in damonster) //i'm so sorry
				shitcode.color = "#FF0000"
			H.visible_message("<span class='warning'>A chrysalis forms around [H], sealing them inside.</span>", \
							"<font color=#800080>We create your chrysalis and begin to contort within.</font>")
			sleep(100) //NOW we do sleeps- we're going too deep into the transformation to cancel and we're cocooned in indestructable walls anyways.
			H.visible_message("<span class='warning'><b>The skin on [H]'s back begins to split apart. Sickly spines slowly emerge from the divide.</b></span>", \
							"<font color=#800080>Spines pierce our back. Claws break apart our melding fingers.</font>")
			playsound(H.loc, 'sound/effects/stretch.ogg', 50, 2)
			animate(H, color = "#FF0000", time = 850)
			H.Shake(3, 3, 850)
			sleep(7)
			playsound(H.loc, 'sound/effects/splat.ogg', 50, 2)
			sleep(83)
			H.visible_message("<span class='warning'><b>[H]'s skin shifts and morphs new faces, appendages slipping out and hanging at the floor.</b></span>", \
							"<font color=#800080>Our stable form finally gives way to something so much more beautiful.</font>")
			H.become_husk("changelingevolve")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slash.ogg', 25, 1)
			to_chat(H, "<i><b>We rip and we slice...</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
			to_chat(H, "<i><b>The chrysalis falls like water before us.</b></i>")
			sleep(10)
			playsound(H.loc, 'sound/weapons/slice.ogg', 25, 1)
			to_chat(H, "<i><b>The chrysalis begins to tear away, our metamorphosis nearing completion...</b></i>")
			sleep(10)
			for(var/obj/structure/alien/resin/wall/cocoon/W in orange(1, H))
				playsound(W, 'sound/effects/splat.ogg', 50, 1)
				qdel(W)
			for(var/obj/structure/alien/weeds/node/N in damonster)
				qdel(N)
			to_chat(H, "<font color=#800080><i><b>Flesh and sinew shift and flow into place, breaking bone and ripping muscle apart. We shall be prisoner of static inferior flesh no longer!</i></b></font>")
			playsound(user, 'sound/creatures/rawrXD.ogg', 100, 1)
			var/mob/living/simple_animal/hostile/true_changeling/new_mob = new(get_turf(H))
			var/datum/antagonist/changeling/ling_datum = H.mind.has_antag_datum(/datum/antagonist/changeling)
			for(var/datum/objective/horrorform/evolveobjective in ling_datum.objectives)
				evolveobjective.completed = 1

			priority_announce("Confirmed outbreak of level UNDEFINED biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert", 'sound/ai/outbreakerror.ogg')
			new_mob.real_name = ling_datum.changelingID
			new_mob.name = new_mob.real_name
			for(var/mob/M in view(7, H))
				flash_color(M, flash_color = list("#db0000", "#db0000", "#db0000", rgb(0,0,0)), flash_time = 50)
			new_mob.stored_changeling = H
			H.forceMove(new_mob)
			H.status_flags |= GODMODE
			H.mind.transfer_to(new_mob)
			new /obj/effect/gibspawner/human(get_turf(H))
			inprogress = FALSE
			return TRUE

/*/obj/effect/proc_holder/changeling/horror_form_lesser //Lesser Horror Form: instant horror form but a weaker one given to lesserlings
	name = "Evolved Form"
	desc = "Granted to the assimilated, our armblade has been replaced with a more deadly weapon."
	helptext = ""
	chemical_cost = 20
	dna_cost = 1
	lesserling = TRUE
	req_human = TRUE

/obj/effect/proc_holder/changeling/horror_form_lesser/sting_action(mob/living/carbon/human/user)
	to_chat(world, "you're winner!")*/