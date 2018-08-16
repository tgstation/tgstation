//Mob vars
/mob/living
	var/arousalloss = 0			//How aroused the mob is.
	var/min_arousal = 0			//The lowest this mobs arousal will get. default = 0
	var/max_arousal = 100		//The highest this mobs arousal will get. default = 100
	var/arousal_rate = 1		//The base rate that arousal will increase in this mob.
	var/arousal_loss_rate = 1	//How easily arousal can be relieved for this mob.
	var/canbearoused = FALSE	//Mob-level disabler for arousal. Starts off and can be enabled as features are added for different mob types.
	var/mb_cd_length = 100		//5 second cooldown for masturbating because fuck spam.
	var/mb_cd_timer = 0			//The timer itself

/mob/living/carbon/human
	canbearoused = TRUE

	var/saved_underwear = ""//saves their underwear so it can be toggled later
	var/saved_undershirt = ""

/mob/living/carbon/human/New()
	..()
	saved_underwear = underwear
	saved_undershirt = undershirt

//Species vars
/datum/species
	var/arousal_gain_rate = 1 //Rate at which this species becomes aroused
	var/arousal_lose_rate = 1 //Multiplier for how easily arousal can be relieved
	var/list/cum_fluids = list("semen")
	var/list/milk_fluids = list("milk")
	var/list/femcum_fluids = list("femcum")

//Mob procs
/mob/living/proc/handle_arousal()


/mob/living/carbon/handle_arousal()
	if(canbearoused && dna)
		var/datum/species/S
		S = dna.species
		if(S && !(SSmobs.times_fired % 36) && getArousalLoss() < max_arousal)//Totally stolen from breathing code. Do this every 36 ticks.
			adjustArousalLoss(arousal_rate * S.arousal_gain_rate)
			if(dna.features["exhibitionist"] && client)
				var/amt_nude = 0
				if(is_chest_exposed() && (gender == FEMALE || getorganslot("breasts")))
					amt_nude++
				if(is_groin_exposed())
					if(getorganslot("penis"))
						amt_nude++
					if(getorganslot("vagina"))
						amt_nude++
				if(amt_nude)
					var/watchers = 0
					for(var/mob/_M in view(world.view, src))
						var/mob/living/M = _M
						if(!istype(M))
							continue
						if(M.client && !M.stat && !M.eye_blind && (locate(src) in viewers(world.view,M)))
							watchers++
					if(watchers)
						adjustArousalLoss((amt_nude * watchers) + S.arousal_gain_rate)


/mob/living/proc/getArousalLoss()
	return arousalloss

/mob/living/proc/adjustArousalLoss(amount, updating_arousal=1)
	if(status_flags & GODMODE || !canbearoused)
		return 0
	arousalloss = CLAMP(arousalloss + amount, min_arousal, max_arousal)
	if(updating_arousal)
		updatearousal()

/mob/living/proc/setArousalLoss(amount, updating_arousal=1)
	if(status_flags & GODMODE || !canbearoused)
		return 0
	arousalloss = CLAMP(amount, min_arousal, max_arousal)
	if(updating_arousal)
		updatearousal()

/mob/living/proc/getPercentAroused()
	return ((100 / max_arousal) * arousalloss)

/mob/living/proc/isPercentAroused(percentage)//returns true if the mob's arousal (measured in a percent of 100) is greater than the arg percentage.
	if(!isnum(percentage) || percentage > 100 || percentage < 0)
		CRASH("Provided percentage is invalid")
	if(getPercentAroused() >= percentage)
		return TRUE
	return FALSE

//H U D//
/mob/living/proc/updatearousal()
	update_arousal_hud()

/mob/living/proc/update_arousal_hud()
	return 0

/datum/species/proc/update_arousal_hud(mob/living/carbon/human/H)
	return 0

/mob/living/carbon/human/update_arousal_hud()
	if(!client || !hud_used)
		return 0
	if(dna.species.update_arousal_hud())
		return 0
	if(!canbearoused)
		hud_used.arousal.icon_state = ""
		return 0
	else
		if(hud_used.arousal)
			if(stat == DEAD)
				hud_used.arousal.icon_state = "arousal0"
				return 1
			if(getArousalLoss() == max_arousal)
				hud_used.arousal.icon_state = "arousal100"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 90)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal90"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 80)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal80"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 70)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal70"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 60)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal60"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 50)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal50"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 40)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal40"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 30)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal30"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 20)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal10"
				return 1
			if(getArousalLoss() >= (max_arousal / 100) * 10)//M O D U L A R ,   W O W
				hud_used.arousal.icon_state = "arousal10"
				return 1
			else
				hud_used.arousal.icon_state = "arousal0"

/obj/screen/arousal
	name = "arousal"
	icon_state = "arousal0"
	icon = 'modular_citadel/icons/obj/genitals/hud.dmi'
	screen_loc = ui_arousal

/obj/screen/arousal/Click()
	if(!isliving(usr))
		return 0
	var/mob/living/M = usr
	if(M.canbearoused)
		M.mob_climax()
		return 1
	else
		to_chat(M, "<span class='warning'>Arousal is disabled. Feature is unavailable.</span>")



/mob/living/proc/mob_climax()//This is just so I can test this shit without being forced to add actual content to get rid of arousal. Will be a very basic proc for a while.
	set name = "Masturbate"
	set category = "IC"
	if(canbearoused && !restrained() && !stat)
		if(mb_cd_timer <= world.time)
			//start the cooldown even if it fails
			mb_cd_timer = world.time + mb_cd_length
			if(getArousalLoss() >= ((max_arousal / 100) * 33))//33% arousal or greater required
				src.visible_message("<span class='danger'>[src] starts masturbating!</span>", \
								"<span class='userdanger'>You start masturbating.</span>")
				if(do_after(src, 30, target = src))
					src.visible_message("<span class='danger'>[src] relieves [p_them()]self!</span>", \
								"<span class='userdanger'>You have relieved yourself.</span>")
					setArousalLoss(min_arousal)
					/*
					switch(gender)
						if(MALE)
							PoolOrNew(/obj/effect/decal/cleanable/semen, loc)
						if(FEMALE)
							PoolOrNew(/obj/effect/decal/cleanable/femcum, loc)
					*/
			else
				to_chat(src, "<span class='notice'>You aren't aroused enough for that.</span>")


//These are various procs that we'll use later, split up for readability instead of having one, huge proc.
//For all of these, we assume the arguments given are proper and have been checked beforehand.
/mob/living/carbon/human/proc/mob_masturbate(obj/item/organ/genital/G, mb_time = 30) //Masturbation, keep it gender-neutral
	var/total_fluids = 0
	var/datum/reagents/fluid_source = null

	if(G.producing) //Can it produce its own fluids, such as breasts?
		fluid_source = G.reagents
	else
		if(!G.linked_organ)
			to_chat(src, "<span class='warning'>Your [G.name] is unable to produce it's own fluids, it's missing the organs for it.</span>")
			return
		fluid_source = G.linked_organ.reagents
	total_fluids = fluid_source.total_volume
	if(mb_time)
		src.visible_message("<span class='danger'>[src] starts to [G.masturbation_verb] [p_their()] [G.name].</span>", \
							"<span class='green'>You start to [G.masturbation_verb] your [G.name].</span>", \
							"<span class='green'>You start to [G.masturbation_verb] your [G.name].</span>")

	if(do_after(src, mb_time, target = src))
		if(total_fluids > 5)
			fluid_source.reaction(src.loc, TOUCH, 1, 0)
			fluid_source.clear_reagents()
		src.visible_message("<span class='danger'>[src] orgasms, cumming[istype(src.loc, /turf/open/floor) ? " onto [src.loc]" : ""]!</span>", \
							"<span class='green'>You cum[istype(src.loc, /turf/open/floor) ? " onto [src.loc]" : ""].</span>", \
							"<span class='green'>You have relieved yourself.</span>")
		if(G.can_climax)
			setArousalLoss(min_arousal)


/mob/living/carbon/human/proc/mob_climax_outside(obj/item/organ/genital/G, mb_time = 30) //This is used for forced orgasms and other hands-free climaxes
	var/total_fluids = 0
	var/datum/reagents/fluid_source = null
	var/unable_to_come = FALSE

	if(G.producing) //Can it produce its own fluids, such as breasts?
		fluid_source = G.reagents
		total_fluids = fluid_source.total_volume
	else
		if(!G.linked_organ)
			unable_to_come = TRUE
		else
			fluid_source = G.linked_organ.reagents
			total_fluids = fluid_source.total_volume

	if(unable_to_come)
		src.visible_message("<span class='danger'>[src] shudders, their [G.name] unable to cum.</span>", \
							"<span class='userdanger'>Your [G.name] cannot cum, giving no relief.</span>", \
							"<span class='userdanger'>Your [G.name] cannot cum, giving no relief.</span>")
	else
		total_fluids = fluid_source.total_volume
		if(mb_time) //as long as it's not instant, give a warning
			src.visible_message("<span class='danger'>[src] looks like they're about to cum.</span>", \
								"<span class='green'>You feel yourself about to orgasm.</span>", \
								"<span class='green'>You feel yourself about to orgasm.</span>")
		if(do_after(src, mb_time, target = src))
			if(total_fluids > 5)
				fluid_source.reaction(src.loc, TOUCH, 1, 0)
			fluid_source.clear_reagents()
			src.visible_message("<span class='danger'>[src] orgasms[istype(src.loc, /turf/open/floor) ? ", spilling onto [src.loc]" : ""], using [p_their()] [G.name]!</span>", \
								"<span class='green'>You climax[istype(src.loc, /turf/open/floor) ? ", spilling onto [src.loc]" : ""] with your [G.name].</span>", \
								"<span class='green'>You climax using your [G.name].</span>")
			if(G.can_climax)
				setArousalLoss(min_arousal)


/mob/living/carbon/human/proc/mob_climax_partner(obj/item/organ/genital/G, mob/living/L, spillage = TRUE, mb_time = 30) //Used for climaxing with any living thing
	var/total_fluids = 0
	var/datum/reagents/fluid_source = null

	if(G.producing) //Can it produce its own fluids, such as breasts?
		fluid_source = G.reagents
	else
		if(!G.linked_organ)
			to_chat(src, "<span class='warning'>Your [G.name] is unable to produce it's own fluids, it's missing the organs for it.</span>")
			return
		fluid_source = G.linked_organ.reagents
	total_fluids = fluid_source.total_volume
	if(mb_time) //Skip warning if this is an instant climax.
		src.visible_message("[src] is about to climax with [L]!", \
							"You're about to climax with [L]!", \
							"<span class='danger'>You're preparing to climax with someone!</span>")
	if(spillage)
		if(do_after(src, mb_time, target = src) && in_range(src, L))
			fluid_source.trans_to(L, total_fluids*G.fluid_transfer_factor)
			total_fluids -= total_fluids*G.fluid_transfer_factor
			if(total_fluids > 5)
				fluid_source.reaction(L.loc, TOUCH, 1, 0)
			fluid_source.clear_reagents()
			src.visible_message("<span class='danger'>[src] climaxes with [L][spillage ? ", overflowing and spilling":""], using [p_their()] [G.name]!</span>", \
								"<span class='green'>You orgasm with [L][spillage ? ", spilling out of them":""], using your [G.name].</span>", \
								"<span class='green'>You have climaxed with someone[spillage ? ", spilling out of them":""], using your [G.name].</span>")
			if(G.can_climax)
				setArousalLoss(min_arousal)
	else //knots and other non-spilling orgasms
		if(do_after(src, mb_time, target = src) && in_range(src, L))
			fluid_source.trans_to(L, total_fluids)
			total_fluids = 0
			src.visible_message("<span class='danger'>[src] climaxes with [L], [p_their()] [G.name] spilling nothing!</span>", \
								"<span class='green'>You ejaculate with [L], your [G.name] spilling nothing.</span>", \
								"<span class='green'>You have climaxed inside someone, your [G.name] spilling nothing.</span>")
			if(G.can_climax)
				setArousalLoss(min_arousal)


/mob/living/carbon/human/proc/mob_fill_container(obj/item/organ/genital/G, obj/item/reagent_containers/container, mb_time = 30) //For beaker-filling, beware the bartender
	var/total_fluids = 0
	var/datum/reagents/fluid_source = null

	if(G.producing) //Can it produce its own fluids, such as breasts?
		fluid_source = G.reagents
	else
		if(!G.linked_organ)
			to_chat(src, "<span class='warning'>Your [G.name] is unable to produce it's own fluids, it's missing the organs for it.</span>")
			return
		fluid_source = G.linked_organ.reagents
	total_fluids = fluid_source.total_volume

	//if(!container) //Something weird happened
	//	to_chat(src, "<span class='warning'>You need a container to do this!</span>")
	//	return

	src.visible_message("<span class='danger'>[src] starts to [G.masturbation_verb] their [G.name] over [container].</span>", \
						"<span class='userdanger'>You start to [G.masturbation_verb] your [G.name] over [container].</span>", \
						"<span class='userdanger'>You start to [G.masturbation_verb] your [G.name] over something.</span>")
	if(do_after(src, mb_time, target = src) && in_range(src, container))
		fluid_source.trans_to(container, total_fluids)
		src.visible_message("<span class='danger'>[src] uses [p_their()] [G.name] to fill [container]!</span>", \
							"<span class='green'>You used your [G.name] to fill [container].</span>", \
							"<span class='green'>You have relieved some pressure.</span>")
		if(G.can_climax)
			setArousalLoss(min_arousal)

/mob/living/carbon/human/proc/pick_masturbate_genitals()
	var/obj/item/organ/genital/ret_organ
	var/list/genitals_list = list()
	var/list/worn_stuff = get_equipped_items()

	for(var/obj/item/organ/genital/G in internal_organs)
		if(G.can_masturbate_with) //filter out what you can't masturbate with
			if(G.is_exposed(worn_stuff)) //Nude or through_clothing
				genitals_list += G
	if(genitals_list.len)
		ret_organ = input(src, "with what?", "Masturbate", null)  as null|obj in genitals_list
		return ret_organ
	return null //error stuff


/mob/living/carbon/human/proc/pick_climax_genitals()
	var/obj/item/organ/genital/ret_organ
	var/list/genitals_list = list()
	var/list/worn_stuff = get_equipped_items()

	for(var/obj/item/organ/genital/G in internal_organs)
		if(G.can_climax) //filter out what you can't masturbate with
			if(G.is_exposed(worn_stuff)) //Nude or through_clothing
				genitals_list += G
	if(genitals_list.len)
		ret_organ = input(src, "with what?", "Climax", null)  as null|obj in genitals_list
		return ret_organ
	return null //error stuff


/mob/living/carbon/human/proc/pick_partner()
	var/list/partners = list()
	if(src.pulling)
		partners += src.pulling //Yes, even objects for now
	if(src.pulledby)
		partners += src.pulledby
	//Now we got both of them, let's check if they're proper
	for(var/I in partners)
		if(isliving(I))
			if(iscarbon(I))
				var/mob/living/carbon/C = I
				if(!C.exposed_genitals.len) //Nothing through_clothing
					if(!C.is_groin_exposed()) //No pants undone
						if(!C.is_chest_exposed()) //No chest exposed
							partners -= I //Then not proper, remove them
		else
			partners -= I //No fucking objects
	//NOW the list should only contain correct partners
	if(!partners.len)
		return null //No one left.
	return input(src, "With whom?", "Sexual partner", null) in partners //pick one, default to null

/mob/living/carbon/human/proc/pick_climax_container()
	var/obj/item/reagent_containers/SC = null
	var/list/containers_list = list()

	for(var/obj/item/reagent_containers/container in held_items)
		if(container.is_open_container() || istype(container, /obj/item/reagent_containers/food/snacks))
			containers_list += container

	if(containers_list.len)
		SC = input(src, "Into or onto what?(Cancel for nowhere)", null)  as null|obj in containers_list
		if(SC)
			if(in_range(src, SC))
				return SC
	return null //If nothing correct, give null.


//Here's the main proc itself
/mob/living/carbon/human/mob_climax(forced_climax=FALSE) //Forced is instead of the other proc, makes you cum if you have the tools for it, ignoring restraints
	if(mb_cd_timer > world.time)
		if(!forced_climax) //Don't spam the message to the victim if forced to come too fast
			to_chat(src, "<span class='warning'>You need to wait [DisplayTimeText((mb_cd_timer - world.time), TRUE)] before you can do that again!</span>")
		return
	mb_cd_timer = (world.time + mb_cd_length)


	if(canbearoused && has_dna())
		if(stat==2)
			to_chat(src, "<span class='warning'>You can't do that while dead!</span>")
			return
		if(forced_climax) //Something forced us to cum, this is not a masturbation thing and does not progress to the other checks
			for(var/obj/item/organ/O in internal_organs)
				if(istype(O, /obj/item/organ/genital))
					var/obj/item/organ/genital/G = O
					if(!G.can_climax) //Skip things like wombs and testicles
						continue
					var/mob/living/partner
					var/check_target
					var/list/worn_stuff = get_equipped_items()

					if(G.is_exposed(worn_stuff))
						if(src.pulling) //Are we pulling someone? Priority target, we can't be making option menus for this, has to be quick
							if(isliving(src.pulling)) //Don't fuck objects
								check_target = src.pulling
						if(src.pulledby && !check_target) //prioritise pulled over pulledby
							if(isliving(src.pulledby))
								check_target = src.pulledby
						//Now we should have a partner, or else we have to come alone
						if(check_target)
							if(iscarbon(check_target)) //carbons can have clothes
								var/mob/living/carbon/C = check_target
								if(C.exposed_genitals.len || C.is_groin_exposed() || C.is_chest_exposed()) //Are they naked enough?
									partner = C
							else //A cat is fine too
								partner = check_target
						if(partner) //Did they pass the clothing checks?
							mob_climax_partner(G, partner, mb_time = 0) //Instant climax due to forced
							continue //You've climaxed once with this organ, continue on
					//not exposed OR if no partner was found while exposed, climax alone
					mob_climax_outside(G, mb_time = 0) //removed climax timer for sudden, forced orgasms
			//Now all genitals that could climax, have.
			//Since this was a forced climax, we do not need to continue with the other stuff
			return
		//If we get here, then this is not a forced climax and we gotta check a few things.

		if(stat==1) //No sleep-masturbation, you're unconscious.
			to_chat(src, "<span class='warning'>You must be conscious to do that!</span>")
			return
		if(getArousalLoss() < 33) //flat number instead of percentage
			to_chat(src, "<span class='warning'>You aren't aroused enough for that!</span>")
			return

		//Ok, now we check what they want to do.
		var/choice = input(src, "Select sexual activity", "Sexual activity:") in list("Masturbate", "Climax alone", "Climax with partner", "Fill container")

		switch(choice)
			if("Masturbate")
				if(restrained(TRUE)) //TRUE ignores grabs
					to_chat(src, "<span class='warning'>You can't do that while restrained!</span>")
					return
				var/free_hands = get_num_arms()
				if(!free_hands)
					to_chat(src, "<span class='warning'>You need at least one free arm.</span>")
					return
				for(var/helditem in held_items)//how many hands are free
					if(isobj(helditem))
						free_hands--
				if(free_hands <= 0)
					to_chat(src, "<span class='warning'>You're holding too many things.</span>")
					return
				//We got hands, let's pick an organ
				var/obj/item/organ/genital/picked_organ
				picked_organ = pick_masturbate_genitals()
				if(picked_organ)
					mob_masturbate(picked_organ)
					return
				else //They either lack organs that can masturbate, or they didn't pick one.
					to_chat(src, "<span class='warning'>You cannot masturbate without choosing genitals.</span>")
					return

			if("Climax alone")
				if(restrained(TRUE)) //TRUE ignores grabs
					to_chat(src, "<span class='warning'>You can't do that while restrained!</span>")
					return
				var/free_hands = get_num_arms()
				if(!free_hands)
					to_chat(src, "<span class='warning'>You need at least one free arm.</span>")
					return
				for(var/helditem in held_items)//how many hands are free
					if(isobj(helditem))
						free_hands--
				if(free_hands <= 0)
					to_chat(src, "<span class='warning'>You're holding too many things.</span>")
					return
				//We got hands, let's pick an organ
				var/obj/item/organ/genital/picked_organ
				picked_organ = pick_climax_genitals()
				if(picked_organ)
					mob_climax_outside(picked_organ)
					return
				else //They either lack organs that can masturbate, or they didn't pick one.
					to_chat(src, "<span class='warning'>You cannot climax without choosing genitals.</span>")
					return

			if("Climax with partner")
				//We need no hands, we can be restrained and so on, so let's pick an organ
				var/obj/item/organ/genital/picked_organ
				picked_organ = pick_climax_genitals()
				if(picked_organ)
					var/mob/living/partner = pick_partner() //Get someone
					if(partner)
						var/spillage = input(src, "Would your fluids spill outside?", "Choose overflowing option", "Yes") as anything in list("Yes", "No")
						if(spillage == "Yes")
							mob_climax_partner(picked_organ, partner, TRUE)
						else
							mob_climax_partner(picked_organ, partner, FALSE)
						return
					else
						to_chat(src, "<span class='warning'>You cannot do this alone.</span>")
						return
				else //They either lack organs that can masturbate, or they didn't pick one.
					to_chat(src, "<span class='warning'>You cannot climax without choosing genitals.</span>")
					return

			if("Fill container")
				//We'll need hands and no restraints.
				if(restrained(TRUE)) //TRUE ignores grabs
					to_chat(src, "<span class='warning'>You can't do that while restrained!</span>")
					return
				var/free_hands = get_num_arms()
				if(!free_hands)
					to_chat(src, "<span class='warning'>You need at least one free arm.</span>")
					return
				for(var/helditem in held_items)//how many hands are free
					if(isobj(helditem))
						free_hands--
				if(free_hands <= 0)
					to_chat(src, "<span class='warning'>You're holding too many things.</span>")
					return
				//We got hands, let's pick an organ
				var/obj/item/organ/genital/picked_organ
				picked_organ = pick_climax_genitals() //Gotta be climaxable, not just masturbation, to fill with fluids.
				if(picked_organ)
					//Good, got an organ, time to pick a container
					var/obj/item/reagent_containers/fluid_container = pick_climax_container()
					if(fluid_container)
						mob_fill_container(picked_organ, fluid_container)
						return
					else
						to_chat(src, "<span class='warning'>You cannot do this without anything to fill.</span>")
						return
				else //They either lack organs that can climax, or they didn't pick one.
					to_chat(src, "<span class='warning'>You cannot fill anything without choosing genitals.</span>")
					return
			else //Somehow another option was taken, maybe something interrupted the selection or it was cancelled
				return //Just end it in that case.
