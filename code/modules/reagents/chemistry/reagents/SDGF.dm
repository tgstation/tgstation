/*SDGF
////////////////////////////////////////////////////
// 		synthetic-derived growth factor			 //
//////////////////////////////////////////////////
other files that are relivant:
modular_citadel/code/datums/status_effects/chems.dm - SDGF
WHAT IT DOES

Several outcomes are possible (in priority order):

Before the chem is even created, there is a risk of the reaction "exploding", which produces an angry teratoma that attacks the player.
0. Before the chem is activated, the purity is checked, if the purity of the reagent is less than 0.5, then sythetic-derived zombie factor is metabolised instead
	0.1 If SDZF is injected, the chem appears to act the same as normal, with nutrition gain, until the end, where it becomes toxic instead, giving a short window of warning to the player
		0.1.2 If the player can take pent in time, the player will spawn a hostile teratoma on them (less damaging), if they don't, then a zombie is spawned instead, with a small defence increase propotional to the volume
	0.2 If the purity is above 0.5, then the remaining impure volume created SDGFtox instead, which reduces blood volume and causes clone damage
1.Normal function creates a (another)player controlled clone of the player, which is spawned nude, with damage to the clone
	1.1 The remaining volume is transferred to the clone, which heals it over time, thus the player has to make a substantial ammount of the chem in order to produce a healthy clone
	1.2 If the player is infected with a zombie tumor, the tumor is transferred to the ghost controlled clone ONLY.
2. If no player can be found, a brainless clone is created over a long period of time, this body has no controller.
	2.1 If the player dies with a clone, then they play as the clone instead. However no memories are retained after splitting.
3. If there is already a clone, then SDGF heals clone, fire and brute damage slowly. This shouldn't normalise this chem as the de facto clone healing chem, as it will always try to make a ghost clone, and then a brainless clone first.
4. If there is insuffient volume to complete the cloning process, there are two outcomes
	4.1 At lower volumes, the players nutrition and blood is refunded, with light healing
	4.2 At higher volumes a stronger heal is applied to the user

IMPORTANT FACTORS TO CONSIDER WHILE BALANCING
1. The most important factor is the required volume, this is easily edited with the metabolism rate, this chem is HARD TO MAKE, You need to make a lot of it and it's a substantial effort on the players part. There is also a substantial risk; you could spawn a hotile teratoma during the reation, you could damage yourself with clone damage, you could accidentally spawn a zombie... Basically, you've a good chance of killing yourself.
	1.1 Additionally, if you're trying to make SDZF purposely, you've no idea if you have or not, and that reaction is even harder to do. Plus, the player has a huge time window to get to medical to deal with it. If you take pent while it's in you, it'll be removed before it can spawn, and only spawns a teratoma if it's late stage.
2. The rate in which the clone is made, This thing takes time to produce fruits, it slows you down and makes you useless in combat/working. Basically you can't do anything during it. It will only get you killed if you use it in combat, If you do use it and you spawn a player clone, they're gimped for a long time, as they have to heal off the clone damage.
3. The healing - it's pretty low and a cyropod is more Useful
4. If you're an antag, you've a 50% chance of making a clone that will help you with your efforts, and you've no idea if they will or not. While clones can't directly harm you and care for you, they can hinder your efforts.
5. If people are being arses when they're a clone, slap them for it, they are told to NOT bugger around with someone else character, if it gets bad I'll add a blacklist, or do a check to see if you've played X amount of hours.
	5.1 Another solution I'm okay with is to rename the clone to [M]'s clone, so it's obvious, this obviously ruins anyone trying to clone themselves to get an alibi however. I'd prefer this to not be the case.
	5.2 Additionally, this chem is a soft buff to changelings, which apparently need a buff!
	5.3 Other similar things exist already though in the codebase; impostors, split personalites, abductors, ect.
6. Giving this to someone without concent is against space law and gets you sent to gulag.
*/

//Clone serum #chemClone
/datum/reagent/fermi/SDGF //vars, mostly only care about keeping track if there's a player in the clone or not.
	name = "synthetic-derived growth factor"
	id = "SDGF"
	description = "A rapidly diving mass of Embryonic stem cells. These cells are missing a nucleus and quickly replicate a host’s DNA before growing to form an almost perfect clone of the host. In some cases neural replication takes longer, though the underlying reason underneath has yet to be determined."
	color = "#a502e0" // rgb: 96, 0, 255
	var/playerClone = FALSE
	var/unitCheck = FALSE
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "a weird chemical fleshy flavour"
	//var/datum/status_effect/chem/SDGF/candidates/candies
	var/list/candies = list()
	//var/polling = FALSE
	var/list/result = list()
	var/list/group = null
	var/pollStarted = FALSE
	var/location_created
	var/startHunger
	ImpureChem 			= "SDGFtox"
	InverseChemVal 		= 0.5
	InverseChem 		= "SDZF"
	can_synth = TRUE


//Main SDGF chemical
/datum/reagent/fermi/SDGF/on_mob_life(mob/living/carbon/M) //Clones user, then puts a ghost in them! If that fails, makes a braindead clone.
	//Setup clone
	switch(current_cycle)
		if(1)
			startHunger = M.nutrition
			if(pollStarted == FALSE)
				pollStarted = TRUE
				candies = pollGhostCandidates("Do you want to play as a clone of [M], and do you agree to respect their character and act in a similar manner to them? Do not engage in ERP as them unless you have LOOC permission from them, and ensure it is permission from the original, not a clone.")
				log_game("FERMICHEM: [M] ckey: [M.key] has taken SDGF, and ghosts have been polled.")
		if(20 to INFINITY)
			if(LAZYLEN(candies) && playerClone == FALSE) //If there's candidates, clone the person and put them in there!
				log_game("FERMICHEM: [M] ckey: [M.key] is creating a clone, controlled by [candies]")
				to_chat(M, "<span class='warning'>The cells reach a critical micelle concentration, nucleating rapidly within your body!</span>")
				var/typepath = M.type
				var/mob/living/carbon/human/fermi_Gclone = new typepath(M.loc)
				var/mob/living/carbon/human/SM = fermi_Gclone
				if(istype(SM) && istype(M))
					SM.real_name = M.real_name
					M.dna.transfer_identity(SM)
					SM.updateappearance(mutcolor_update=1)
				var/mob/dead/observer/C = pick(candies)
				message_admins("Ghost candidate found! [C] key [C.key] is becoming a clone of [M] key: [M.key] (They agreed to respect the character they're becoming, and agreed to not ERP without express permission from the original.)")
				SM.key = C.key
				SM.mind.enslave_mind_to_creator(M)

				//If they're a zombie, they can try to negate it with this.
				//I seriously wonder if anyone will ever use this function.
				if(M.getorganslot(ORGAN_SLOT_ZOMBIE))//sure, it "treats" it, but "you've" still got it. Doesn't always work as well; needs a ghost.
					var/obj/item/organ/zombie_infection/ZI = M.getorganslot(ORGAN_SLOT_ZOMBIE)
					ZI.Remove(M)
					ZI.Insert(SM)
					log_game("FERMICHEM: [M] ckey: [M.key]'s zombie_infection has been transferred to their clone")

				to_chat(SM, "<span class='warning'>You feel a strange sensation building in your mind as you realise there's two of you, before you get a chance to think about it, you suddenly split from your old body, and find yourself face to face with your original, a perfect clone of your origin.</span>")

				if(prob(50))
					to_chat(SM, "<span class='userdanger'>While you find your newfound existence strange, you share the same memories as [M.real_name]. However, You find yourself indifferent to the goals you previously had, and take more interest in your newfound independence, but still have an indescribable care for the safety of your original.</span>")
					log_game("FERMICHEM: [SM] ckey: [SM.key]'s is not bound by [M] ckey [M.key]'s will, and is free to determine their own goals, while respecting and acting as their origin.")
				else
					to_chat(SM, "<span class='userdanger'>While you find your newfound existence strange, you share the same memories as [M.real_name]. Your mind has not deviated from the tasks you set out to do, and now that there's two of you the tasks should be much easier.</span>")
					log_game("FERMICHEM: [SM] ckey: [SM.key]'s is bound by [M] ckey [M.key]'s objectives, and is encouraged to help them complete them.")

				to_chat(M, "<span class='warning'>You feel a strange sensation building in your mind as you realise there's two of you, before you get a chance to think about it, you suddenly split from your old body, and find yourself face to face with yourself.</span>")
				M.visible_message("[M] suddenly shudders, and splits into two identical twins!")
				SM.copy_known_languages_from(M, FALSE)
				playerClone =  TRUE
				M.next_move_modifier = 1
				M.nutrition -= 500

				//Damage the clone
				SM.blood_volume = (BLOOD_VOLUME_NORMAL*SM.blood_ratio)/2
				SM.adjustCloneLoss(60, 0)
				SM.setBrainLoss(40)
				SM.nutrition = startHunger/2

				//Transfer remaining reagent to clone. I think around 30u will make a healthy clone, otherwise they'll have clone damage, blood loss, brain damage and hunger.
				SM.reagents.add_reagent("SDGFheal", volume)
				M.reagents.remove_reagent(id, volume)
				log_game("FERMICHEM: [volume]u of SDGFheal has been transferred to the clone")
				SSblackbox.record_feedback("tally", "fermi_chem", 1, "Sentient clones made")
				return

			else if(playerClone == FALSE) //No candidates leads to two outcomes; if there's already a braincless clone, it heals the user, as well as being a rare souce of clone healing (thematic!).
				unitCheck = TRUE
				if(M.has_status_effect(/datum/status_effect/chem/SGDF)) // Heal the user if they went to all this trouble to make it and can't get a clone, the poor fellow.
					switch(current_cycle)
						if(21)
							to_chat(M, "<span class='notice'>The cells fail to catalyse around a nucleation event, instead merging with your cells.</span>") //This stuff is hard enough to make to rob a user of some benefit. Shouldn't replace Rezadone as it requires the user to not only risk making a player controlled clone, but also requires them to have split in two (which also requires 30u of SGDF).
							REMOVE_TRAIT(M, TRAIT_DISFIGURED, TRAIT_GENERIC)
							log_game("FERMICHEM: [M] ckey: [M.key] is being healed by SDGF")
						if(22 to INFINITY)
							M.adjustCloneLoss(-1, 0)
							M.adjustBruteLoss(-1, 0)
							M.adjustFireLoss(-1, 0)
							M.heal_bodypart_damage(1,1)
							M.reagents.remove_reagent(id, 1)//faster rate of loss.
				else //If there's no ghosts, but they've made a large amount, then proceed to make flavourful clone, where you become fat and useless until you split.
					switch(current_cycle)
						if(21)
							to_chat(M, "<span class='notice'>You feel the synethic cells rest uncomfortably within your body as they start to pulse and grow rapidly.</span>")
						if(22 to 29)
							M.nutrition = M.nutrition + (M.nutrition/10)
						if(30)
							to_chat(M, "<span class='notice'>You feel the synethic cells grow and expand within yourself, bloating your body outwards.</span>")
						if(31 to 49)
							M.nutrition = M.nutrition + (M.nutrition/5)
						if(50)
							to_chat(M, "<span class='notice'>The synthetic cells begin to merge with your body, it feels like your body is made of a viscous water, making your movements difficult.</span>")
							M.next_move_modifier += 4//If this makes you fast then please fix it, it should make you slow!!
							//candidates = pollGhostCandidates("Do you want to play as a clone of [M.name] and do you agree to respect their character and act in a similar manner to them? I swear to god if you diddle them I will be very disapointed in you. ", "FermiClone", null, ROLE_SENTIENCE, 300) // see poll_ignore.dm, should allow admins to ban greifers or bullies
						if(51 to 79)
							M.nutrition = M.nutrition + (M.nutrition/2)
						if(80)
							to_chat(M, "<span class='notice'>The cells begin to precipitate outwards of your body, you feel like you'll split soon...</span>")
							if (M.nutrition < 20000)
								M.nutrition = 20000 //https://www.youtube.com/watch?v=Bj_YLenOlZI
						if(86)//Upon splitting, you get really hungry and are capable again. Deletes the chem after you're done.
							M.nutrition = 15//YOU BEST BE EATTING AFTER THIS YOU CUTIE
							M.next_move_modifier -= 4
							to_chat(M, "<span class='notice'>Your body splits away from the cell clone of yourself, leaving you with a drained and hollow feeling inside.</span>")

							//clone
							var/typepath = M.type
							var/mob/living/fermi_Clone = new typepath(M.loc)
							var/mob/living/carbon/C = fermi_Clone

							if(istype(C) && istype(M))
								C.real_name = M.real_name
								M.dna.transfer_identity(C, transfer_SE=1)
								C.updateappearance(mutcolor_update=1)
							C.apply_status_effect(/datum/status_effect/chem/SGDF)
							var/datum/status_effect/chem/SGDF/S = C.has_status_effect(/datum/status_effect/chem/SGDF)
							S.original = M
							S.originalmind = M.mind
							S.status_set = TRUE

							log_game("FERMICHEM: [M] ckey: [M.key] has created a mindless clone of themselves")
							SSblackbox.record_feedback("tally", "fermi_chem", 1, "Braindead clones made")
						if(87 to INFINITY)
							M.reagents.remove_reagent(id, volume)//removes SGDF on completion. Has to do it this way because of how i've coded it. If some madlab gets over 1k of SDGF, they can have the clone healing.


	..()

/datum/reagent/fermi/SDGF/on_mob_delete(mob/living/M) //When the chem is removed, a few things can happen, mostly consolation prizes.
	pollStarted = FALSE
	if (playerClone == TRUE)//If the player made a clone with it, then thats all they get.
		playerClone = FALSE
		return
	if (M.next_move_modifier == 4 && !M.has_status_effect(/datum/status_effect/chem/SGDF))//checks if they're ingested over 20u of the stuff, but fell short of the required 30u to make a clone.
		to_chat(M, "<span class='notice'>You feel the cells begin to merge with your body, unable to reach nucleation, they instead merge with your body, healing any wounds.</span>")
		M.adjustCloneLoss(-10, 0) //I don't want to make Rezadone obsolete.
		M.adjustBruteLoss(-25, 0)// Note that this takes a long time to apply and makes you fat and useless when it's in you, I don't think this small burst of healing will be useful considering how long it takes to get there.
		M.adjustFireLoss(-25, 0)
		M.blood_volume += 250
		M.heal_bodypart_damage(1,1)
		M.next_move_modifier = 1
		if (M.nutrition < 1500)
			M.nutrition += 250
	else if (unitCheck == TRUE && !M.has_status_effect(/datum/status_effect/chem/SGDF))// If they're ingested a little bit (10u minimum), then give them a little healing.
		unitCheck = FALSE
		to_chat(M, "<span class='notice'>the cells fail to hold enough mass to generate a clone, instead diffusing into your system.</span>")
		M.adjustBruteLoss(-10, 0)
		M.adjustFireLoss(-10, 0)
		M.blood_volume += 100
		M.next_move_modifier = 1
		if (M.nutrition < 1500)
			M.nutrition += 500

/datum/reagent/fermi/SDGF/reaction_mob(mob/living/carbon/human/M, method=TOUCH, reac_volume)
	if(volume<5)
		M.visible_message("<span class='warning'>The growth factor froths upon [M]'s body, failing to do anything of note.</span>")
		return
	if(M.stat == DEAD)
		if(M.suiciding || (HAS_TRAIT(M, TRAIT_NOCLONE)) || M.hellbound)
			M.visible_message("<span class='warning'>The growth factor inertly sticks to [M]'s body, failing to do anything of note.</span>")
			return
		if(!M.mind)
			M.visible_message("<span class='warning'>The growth factor shudders, merging with [M]'s body, but is unable to replicate properly.</span>")

		var/bodydamage = (M.getBruteLoss() + M.getFireLoss())
		var/typepath = M.type
		volume =- 5

		var/mob/living/carbon/human/fermi_Gclone = new typepath(M.loc)
		var/mob/living/carbon/human/SM = fermi_Gclone
		if(istype(SM) && istype(M))
			SM.real_name = M.real_name
			M.dna.transfer_identity(SM)
			SM.updateappearance(mutcolor_update=1)
		M.mind.transfer_to(SM)
		M.visible_message("<span class='warning'>[M]'s body shudders, the growth factor rapidly splitting into a new clone of [M].</span>")

		if(bodydamage>50)
			SM.adjustOxyLoss(-(bodydamage/10), 0)
			SM.adjustToxLoss(-(bodydamage/10), 0)
			SM.blood_volume = (BLOOD_VOLUME_NORMAL*SM.blood_ratio)/1.5
			SM.adjustCloneLoss((bodydamage/10), 0)
			SM.setBrainLoss((bodydamage/10))
			SM.nutrition = 400
		if(bodydamage>200)
			SM.gain_trauma_type(BRAIN_TRAUMA_MILD)
		if(bodydamage>300)
			var/obj/item/bodypart/l_arm = SM.get_bodypart(BODY_ZONE_L_ARM) //We get the body parts we want this way.
			var/obj/item/bodypart/r_arm = SM.get_bodypart(BODY_ZONE_R_ARM)
			l_arm.drop_limb()
			r_arm.drop_limb()
		if(bodydamage>400)
			var/obj/item/bodypart/l_leg = SM.get_bodypart(BODY_ZONE_L_LEG) //We get the body parts we want this way.
			var/obj/item/bodypart/r_leg = SM.get_bodypart(BODY_ZONE_R_LEG)
			l_leg.drop_limb()
			r_leg.drop_limb()
		if(bodydamage>500)
			SM.gain_trauma_type(BRAIN_TRAUMA_SEVERE)
		if(bodydamage>600)
			var/datum/species/mutation = pick(subtypesof(/datum/species))
			SM.set_species(mutation)

		//Transfer remaining reagent to clone. I think around 30u will make a healthy clone, otherwise they'll have clone damage, blood loss, brain damage and hunger.
		SM.reagents.add_reagent("SDGFheal", volume)
		M.reagents.remove_reagent(id, volume)

		SM.updatehealth()
		SM.emote("gasp")
		log_combat(M, M, "SDGF clone-vived", src)
	..()

//Unobtainable, used in clone spawn.
/datum/reagent/fermi/SDGFheal
	name = "synthetic-derived growth factor"
	id = "SDGFheal"
	metabolization_rate = 1
	can_synth = FALSE

/datum/reagent/fermi/SDGFheal/on_mob_life(mob/living/carbon/M)//Used to heal the clone after splitting, the clone spawns damaged. (i.e. insentivies players to make more than required, so their clone doesn't have to be treated)
	if(M.blood_volume < (BLOOD_VOLUME_NORMAL*M.blood_ratio))
		M.blood_volume += 10
	M.adjustCloneLoss(-2, 0)
	M.setBrainLoss(-1)
	M.nutrition += 10
	..()

//Unobtainable, used if SDGF is impure but not too impure
/datum/reagent/fermi/SDGFtox
	name = "synthetic-derived growth factor"
	id = "SDGFtox"
	description = "A chem that makes a certain chemcat angry at you if you're reading this, how did you get this???"//i.e. tell me please, figure it's a good way to get pinged for bugfixes.
	metabolization_rate = 1
	can_synth = FALSE

/datum/reagent/fermi/SDGFtox/on_mob_life(mob/living/carbon/M)//Damages the taker if their purity is low. Extended use of impure chemicals will make the original die. (thus can't be spammed unless you've very good)
	M.blood_volume -= 10
	M.adjustCloneLoss(2, 0)
	..()

//Fail state of SDGF
/datum/reagent/fermi/SDZF
	name = "synthetic-derived growth factor"
	id = "SDZF"
	description = "A horribly peverse mass of Embryonic stem cells made real by the hands of a failed chemist. This message should never appear, how did you manage to get a hold of this?"
	color = "#a502e0" // rgb: 96, 0, 255
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/startHunger
	can_synth = TRUE

/datum/reagent/fermi/SDZF/on_mob_life(mob/living/carbon/M) //If you're bad at fermichem, turns your clone into a zombie instead.
	switch(current_cycle)//Pretends to be normal
		if(20)
			to_chat(M, "<span class='notice'>You feel the synethic cells rest uncomfortably within your body as they start to pulse and grow rapidly.</span>")
			startHunger = M.nutrition
		if(21 to 29)
			M.nutrition = M.nutrition + (M.nutrition/10)
		if(30)
			to_chat(M, "<span class='notice'>You feel the synethic cells grow and expand within yourself, bloating your body outwards.</span>")
		if(31 to 49)
			M.nutrition = M.nutrition + (M.nutrition/5)
		if(50)
			to_chat(M, "<span class='notice'>The synethic cells begin to merge with your body, it feels like your body is made of a viscous water, making your movements difficult.</span>")
			M.next_move_modifier = 4//If this makes you fast then please fix it, it should make you slow!!
		if(51 to 73)
			M.nutrition = M.nutrition + (M.nutrition/2)
		if(74)
			to_chat(M, "<span class='notice'>The cells begin to precipitate outwards of your body, but... something is wrong, the sythetic cells are beginnning to rot...</span>")
			if (M.nutrition < 20000) //whoever knows the maxcap, please let me know, this seems a bit low.
				M.nutrition = 20000 //https://www.youtube.com/watch?v=Bj_YLenOlZI
		if(75 to 85)
			M.adjustToxLoss(1, 0)// the warning!

		if(86)//mean clone time!
			if (!M.reagents.has_reagent("pen_acid"))//Counterplay is pent.)
				message_admins("(non-infectious) SDZF: Zombie spawned at [M] [COORD(M)]!")
				M.nutrition = startHunger - 500//YOU BEST BE RUNNING AWAY AFTER THIS YOU BADDIE
				M.next_move_modifier = 1
				to_chat(M, "<span class='warning'>Your body splits away from the cell clone of yourself, your attempted clone birthing itself violently from you as it begins to shamble around, a terrifying abomination of science.</span>")
				M.visible_message("[M] suddenly shudders, and splits into a funky smelling copy of themselves!")
				M.emote("scream")
				M.adjustToxLoss(30, 0)
				var/mob/living/simple_animal/hostile/unemployedclone/ZI = new(get_turf(M.loc))
				ZI.damage_coeff = list(BRUTE = ((1 / volume)**0.25) , BURN = ((1 / volume)**0.1), TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
				ZI.real_name = M.real_name//Give your offspring a big old kiss.
				ZI.name = M.real_name
				ZI.desc = "[M]'s clone, gone horribly wrong."
				log_game("FERMICHEM: [M] ckey: [M.key]'s clone has become a horrifying zombie instead")
				M.reagents.remove_reagent(id, 20)

			else//easier to deal with
				to_chat(M, "<span class='notice'>The pentetic acid seems to have stopped the decay for now, clumping up the cells into a horrifying tumour!</span>")
				M.nutrition = startHunger - 500
				var/mob/living/simple_animal/slime/S = new(get_turf(M.loc),"grey") //TODO: replace slime as own simplemob/add tumour slime cores for science/chemistry interplay
				S.damage_coeff = list(BRUTE = ((1 / volume)**0.1) , BURN = 2, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
				S.name = "Living teratoma"
				S.real_name = "Living teratoma"//horrifying!!
				S.rabid = 1//Make them an angery boi
				M.reagents.remove_reagent(id, volume)
				to_chat(M, "<span class='warning'>A large glob of the tumour suddenly splits itself from your body. You feel grossed out and slimey...</span>")
				log_game("FERMICHEM: [M] ckey: [M.key]'s clone has become a horrifying teratoma instead")
				SSblackbox.record_feedback("tally", "fermi_chem", 1, "Zombie clones made!")

		if(87 to INFINITY)
			M.adjustToxLoss(1, 0)
	..()
