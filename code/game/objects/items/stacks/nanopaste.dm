/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite paste" //You apply nanopaste (or nanite paste, if you want to be fancy), not 'nanite swarm'
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = "materials=4;engineering=3"
	amount = 10

/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M) || !istype(user))
		return 0
	if(istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss())
			R.adjustBruteLoss(rand(-15, -20))
			R.adjustFireLoss(rand(-15, -20))
			R.updatehealth()
			use(1)
			user.visible_message("<span class='notice'>[user] applies some [src] to [R]'s damaged areas.</span>", \
				"<span class='notice'>You apply some [src] to [R]'s damaged areas.</span>")
		else
			user << "<span class='notice'>All [R]'s systems are nominal.</span>"

	if(istype(M,/mob/living/carbon/human))	//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/datum/organ/external/affecting = H.get_organ(user.zone_sel.selecting)

		if(affecting.open == 1)
			if(affecting && (affecting.status & ORGAN_ROBOT))
				if(affecting.get_damage())
					affecting.heal_damage(rand(15, 20), rand(15, 20), robo_repair = 1)
					H.updatehealth()
					use(1)
					user.visible_message("<span class='notice'>[user] applies some [src] to [user != M ? "[M]'s":"their"] [affecting.display_name].</span>", \
					"<span class='notice'>You apply some [src] to [user != M ? "[M]'s":"your"] [affecting.display_name].</span>")
				else
					user << "<span class='notice'>Nothing to fix here.</span>"
		else
			if(can_operate(H))
				if(do_surgery(H,user,src))
					return
			else
				user << "<span class='notice'>Nothing to fix in here.</span>"