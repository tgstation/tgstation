<<<<<<< HEAD
/* I am informed this was added by Giacom to reduce mob-stacking in escape pods.
It's sorta problematic atm due to the shuttle changes I am trying to do
Sorry Giacom. Please don't be mad :(
/mob/living/Life()
	..()
	var/area/A = get_area(loc)
	if(A && A.push_dir)
		push_mob_back(src, A.push_dir)
*/

/mob/living/New()
	. = ..()
	generateStaticOverlay()
	if(staticOverlays.len)
		for(var/mob/living/simple_animal/drone/D in player_list)
			if(D && D.seeStatic)
				if(D.staticChoice in staticOverlays)
					D.staticOverlays |= staticOverlays[D.staticChoice]
					D.client.images |= staticOverlays[D.staticChoice]
				else //no choice? force static
					D.staticOverlays |= staticOverlays["static"]
					D.client.images |= staticOverlays["static"]
	if(unique_name)
		name = "[name] ([rand(1, 1000)])"
		real_name = name
	var/datum/atom_hud/data/human/medical/advanced/medhud = huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	faction |= "\ref[src]"


/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/Destroy()
	..()

	for(var/mob/living/simple_animal/drone/D in player_list)
		for(var/image/I in staticOverlays)
			D.staticOverlays.Remove(I)
			D.client.images.Remove(I)
			qdel(I)
	staticOverlays.len = 0
	remove_from_all_data_huds()
	return QDEL_HINT_HARDDEL


/mob/living/proc/OpenCraftingMenu()
	return

/mob/living/proc/generateStaticOverlay()
	staticOverlays.Add(list("static", "blank", "letter", "animal"))
	var/image/staticOverlay = image(getStaticIcon(new/icon(icon,icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["static"] = staticOverlay

	staticOverlay = image(getBlankIcon(new/icon(icon, icon_state)), loc = src)
	staticOverlay.override = 1
	staticOverlays["blank"] = staticOverlay

	staticOverlay = getLetterImage(src)
	staticOverlay.override = 1
	staticOverlays["letter"] = staticOverlay

	staticOverlay = getRandomAnimalImage(src)
	staticOverlay.override = 1
	staticOverlays["animal"] = staticOverlay


//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if(..()) //we are thrown onto something
		return
	if (buckled || !yes || now_pushing)
		return
	if(ismob(A))
		var/mob/M = A
		if(MobBump(M))
			return
	if(isobj(A))
		var/obj/O = A
		if(ObjBump(O))
			return
	if(istype(A, /atom/movable))
		var/atom/movable/AM = A
		if(PushAM(AM))
			return

/mob/living/Bumped(atom/movable/AM)
	..()
	last_bumped = world.time

//Called when we bump onto a mob
/mob/living/proc/MobBump(mob/M)
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	if(now_pushing)
		return 1

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				src << "<span class='warning'>[L] is restrained, you cannot push past.</span>"
			return 1

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						src << "<span class='warning'>[L] is restraining [P], you cannot push past.</span>"
					return 1

	if(moving_diagonally)//no mob swap during diagonal moves.
		return 1

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with its victim if on grab intent
		if(M.pulledby == src && a_intent == "grab")
			mob_swap = 1
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		else if((M.restrained() || M.a_intent == "help") && (restrained() || a_intent == "help"))
			mob_swap = 1
		if(mob_swap)
			//switch our position with M
			if(loc && !loc.Adjacent(M.loc))
				return 1
			now_pushing = 1
			var/oldloc = loc
			var/oldMloc = M.loc


			var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/src_passmob = (pass_flags & PASSMOB)
			M.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			M.Move(oldloc)
			Move(oldMloc)

			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!M_passmob)
				M.pass_flags &= ~PASSMOB

			now_pushing = 0
			return 1

	//okay, so we didn't switch. but should we push?
	//not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return 1
	//anti-riot equipment is also anti-push
	if(M.r_hand && (prob(M.r_hand.block_chance * 2)) && !istype(M.r_hand, /obj/item/clothing))
		return 1
	if(M.l_hand && (prob(M.l_hand.block_chance * 2)) && !istype(M.l_hand, /obj/item/clothing))
		return 1

//Called when we bump onto an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM)
	if(now_pushing)
		return 1
	if(moving_diagonally)// no pushing during diagonal moves.
		return 1
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	if(!AM.anchored)
		now_pushing = 1
		var/t = get_dir(src, AM)
		if (istype(AM, /obj/structure/window))
			var/obj/structure/window/W = AM
			if(W.fulltile)
				for(var/obj/structure/window/win in get_step(W,t))
					now_pushing = 0
					return
		if(pulling == AM)
			stop_pulling()
		step(AM, t)
		now_pushing = 0

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"

	if(istype(AM) && AM.Adjacent(src))
		start_pulling(AM)
	else
		stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return 0
	if(src.status_flags & FAKEDEATH)
		return 0
	if(!..())
		return 0
	visible_message("<b>[src]</b> points to [A]")
	return 1

/mob/living/verb/succumb(whispered as null)
	set hidden = 1
	if (InCritical())
		src.attack_log += "[src] has [whispered ? "whispered his final words" : "succumbed to death"] with [round(health, 0.1)] points of health!"
		src.adjustOxyLoss(src.health - config.health_threshold_dead)
		updatehealth()
		if(!whispered)
			src << "<span class='notice'>You have given up life and succumbed to death.</span>"
		death()

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95 && stat == UNCONSCIOUS)

/mob/living/ex_act(severity, origin)
	if(istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	flash_eyes()

/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()
	update_stat()
	med_hud_set_health()

//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return pressure


=======
/mob/living/New()
	. = ..()
	generate_static_overlay()
	if(istype(static_overlays,/list) && static_overlays.len)
		for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
			if(MoMMI.can_see_static())
				if(MoMMI.static_choice in static_overlays)
					MoMMI.static_overlays.Add(static_overlays[MoMMI.static_choice])
					MoMMI.client.images.Add(static_overlays[MoMMI.static_choice])
				else
					MoMMI.static_overlays.Add(static_overlays["static"])
					MoMMI.client.images.Add(static_overlays["static"])

	if(!species_type)
		species_type = src.type
	if(can_butcher && !meat_amount)
		meat_amount = size

/mob/living/Destroy()
	for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
		for(var/image/I in static_overlays)
			MoMMI.static_overlays.Remove(I) //no checks, since it's either there or its not
			MoMMI.client.images.Remove(I)
			qdel(I)
			I = null
	if(static_overlays)
		static_overlays = null

	if(butchering_drops)
		for(var/datum/butchering_product/B in butchering_drops)
			butchering_drops -= B
			qdel(B)
			B = null

	. = ..()

/mob/living/examine(mob/user) //Show the mob's size and whether it's been butchered
	var/size
	switch(src.size)
		if(SIZE_TINY)
			size = "tiny"
		if(SIZE_SMALL)
			size = "small"
		if(SIZE_NORMAL)
			size = "average in size"
		if(SIZE_BIG)
			size = "big"
		if(SIZE_HUGE)
			size = "huge"

	var/pronoun = "it is"
	if(src.gender == FEMALE)
		pronoun = "she is"
	else if(src.gender == MALE)
		pronoun = "he is"
	else if(src.gender == PLURAL)
		pronoun = "they are"

	..(user, " [capitalize(pronoun)] [size].")
	if(meat_taken > 0)
		to_chat(user, "<span class='info'>[capitalize(pronoun)] partially butchered.</span>")

	var/butchery = "" //More information about butchering status, check out "code/datums/helper_datums/butchering.dm"

	if(butchering_drops && butchering_drops.len)
		for(var/datum/butchering_product/B in butchering_drops)
			butchery = "[butchery][B.desc_modifier(src)]"
	if(butchery)
		to_chat(user, "<span class='info'>[butchery]</span>")

/mob/living/Life()
	if(timestopped) return 0 //under effects of time magick

	..()
	if (flags & INVULNERABLE)
		bodytemperature = initial(bodytemperature)
	if (monkeyizing)	return
	if(!loc)			return	// Fixing a null error that occurs when the mob isn't found in the world -- TLE
	if(reagents && reagents.has_reagent(BUSTANUT))
		if(!(M_HARDCORE in mutations))
			mutations.Add(M_HARDCORE)
			to_chat(src, "<span class='notice'>You feel like you're the best around.  Nothing's going to get you down.</span>")
	else
		if(M_HARDCORE in mutations)
			mutations.Remove(M_HARDCORE)
			to_chat(src, "<span class='notice'>You feel like a pleb.</span>")
	handle_beams()

	//handles "call on life", allowing external life-related things to be processed
	for(var/toCall in src.callOnLife)
		if(locate(toCall) && callOnLife[toCall])
			call(locate(toCall),callOnLife[toCall])()
		else callOnLife -= toCall

	if(mind)
		if(mind in ticker.mode.implanted)
			if(implanting) return
//			to_chat(world, "[src.name]")
			var/datum/mind/head = ticker.mode.implanted[mind]
			//var/list/removal
			if(!(locate(/obj/item/weapon/implant/traitor) in src.contents))
//				to_chat(world, "doesn't have an implant")
				ticker.mode.remove_traitor_mind(mind, head)
				/*
				if((head in ticker.mode.implanters))
					ticker.mode.implanter[head] -= src.mind
				ticker.mode.implanted -= src.mind
				if(src.mind in ticker.mode.traitors)
					ticker.mode.traitors -= src.mind
					special_role = null
					to_chat(current, "<span class='danger'><FONT size = 3>The fog clouding your mind clears. You remember nothing from the moment you were implanted until now..(You don't remember who enslaved you)</FONT></span>")
				*/

// Apply connect damage
/mob/living/beam_connect(var/obj/effect/beam/B)
	..()
	last_beamchecks["\ref[B]"]=world.time

/mob/living/beam_disconnect(var/obj/effect/beam/B)
	..()
	apply_beam_damage(B)
	last_beamchecks.Remove("\ref[B]") // RIP

/mob/living/handle_beams()
	if(flags & INVULNERABLE)
		return
	// New beam damage code (per-tick)
	for(var/obj/effect/beam/B in beams)
		apply_beam_damage(B)

/mob/living/cultify()
	if(iscultist(src) && client)
		var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester(get_turf(src))
		mind.transfer_to(C)
		to_chat(C, "<span class='sinister'>The Geometer of Blood is overjoyed to be reunited with its followers, and accepts your body in sacrifice. As reward, you have been gifted with the shell of an Harvester.<br>Your tendrils can use and draw runes without need for a tome, your eyes can see beings through walls, and your mind can open any door. Use these assets to serve Nar-Sie and bring him any remaining living human in the world.<br>You can teleport yourself back to Nar-Sie along with any being under yourself at any time using your \"Harvest\" spell.</span>")
		dust()
	else if(client)
		var/mob/dead/G = (ghostize())
		G.icon = 'icons/mob/mob.dmi'
		G.icon_state = "ghost-narsie"
		G.overlays = 0
		if(istype(G.mind.current, /mob/living/carbon/human/))
			var/mob/living/carbon/human/H = G.mind.current
			G.overlays += H.obj_overlays[ID_LAYER]
			G.overlays += H.obj_overlays[EARS_LAYER]
			G.overlays += H.obj_overlays[SUIT_LAYER]
			G.overlays += H.obj_overlays[GLASSES_LAYER]
			G.overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
			G.overlays += H.obj_overlays[BELT_LAYER]
			G.overlays += H.obj_overlays[BACK_LAYER]
			G.overlays += H.obj_overlays[HEAD_LAYER]
			G.overlays += H.obj_overlays[HANDCUFF_LAYER]
		G.invisibility = 0
		to_chat(G, "<span class='sinister'>You feel relieved as what's left of your soul finally escapes its prison of flesh.</span>")

		if(ticker.mode.name == "cult")
			var/datum/game_mode/cult/mode_ticker = ticker.mode
			mode_ticker.harvested++

	else
		dust()

/mob/living/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	// Figure out how much damage to deal.
	// Formula: (deciseconds_since_connect/10 deciseconds)*B.get_damage()
	var/damage = ((world.time - lastcheck)/10)  * B.get_damage()

	// Actually apply damage
	apply_damage(damage, B.damage_type, B.def_zone)

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/mob/living/verb/succumb()
	set hidden = 1
	if (src.health < 0 && stat != DEAD)
		src.attack_log += "[src] has succumbed to death with [health] points of health!"
		src.apply_damage(maxHealth + src.health, OXY)
		death(0)
		to_chat(src, "<span class='info'>You have given up life and succumbed to death.</span>")


/mob/living/proc/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else if(!(flags & INVULNERABLE))
		health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss() - halloss


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(var/pressure)
	return 0


//sort of a legacy burn method for /electrocute, /shock, and the e_chair
/mob/living/proc/burn_skin(burn_amount)
	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "DEBUG: burn_skin(), mutations=[mutations]")
		if(M_NO_SHOCK in src.mutations) //shockproof
			return 0
		if (M_RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/human/H = src	//make this damage method divide the damage to be done among all the body parts, then burn each body part for that much damage. will have better effect then just randomly picking a body part
		var/divided_damage = (burn_amount)/(H.organs.len)
		var/extradam = 0	//added to when organ is at max dam
		for(var/datum/organ/external/affecting in H.organs)
			if(!affecting)	continue
			if(affecting.take_damage(0, divided_damage+extradam))	//TODO: fix the extradam stuff. Or, ebtter yet...rewrite this entire proc ~Carn
				H.UpdateDamageIcon()
		H.updatehealth()
		return 1
	else if(istype(src, /mob/living/carbon/monkey))
		if (M_RESIST_HEAT in src.mutations) //fireproof
			return 0
		var/mob/living/carbon/monkey/M = src
		M.adjustFireLoss(burn_amount)
		M.updatehealth()
		return 1
	else if(istype(src, /mob/living/silicon/ai))
		return 0

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired
//	if(istype(src, /mob/living/carbon/human))
<<<<<<< HEAD
//		world << "[src] ~ [src.bodytemperature] ~ [temperature]"
	return temperature


// MOB PROCS
/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()
=======
//		to_chat(world, "[src] ~ [src.bodytemperature] ~ [temperature]")
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + (amount * brute_damage_modifier), 0),(maxHealth*2))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getOxyLoss()
	return oxyloss

<<<<<<< HEAD
/mob/living/proc/adjustOxyLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	oxyloss = Clamp(oxyloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/setOxyLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	oxyloss = amount
	if(updating_health)
		updatehealth()
=======
/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + (amount * oxy_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getToxLoss()
	return toxloss

<<<<<<< HEAD
/mob/living/proc/adjustToxLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	toxloss = Clamp(toxloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setToxLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	toxloss = amount
	if(updating_health)
		updatehealth()
=======
/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + (amount * tox_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getFireLoss()
	return fireloss

<<<<<<< HEAD
/mob/living/proc/adjustFireLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	fireloss = Clamp(fireloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()
=======
/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + (amount * burn_damage_modifier), 0),(maxHealth*2))
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getCloneLoss()
	return cloneloss

<<<<<<< HEAD
/mob/living/proc/adjustCloneLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	cloneloss = Clamp(cloneloss + amount, 0, maxHealth*2)
	if(updating_health)
		updatehealth()

/mob/living/proc/setCloneLoss(amount, updating_health=1)
	if(status_flags & GODMODE)
		return 0
	cloneloss = amount
	if(updating_health)
		updatehealth()
=======
/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + (amount * clone_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getBrainLoss()
	return brainloss

<<<<<<< HEAD
/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	brainloss = Clamp(brainloss + amount, 0, maxHealth*2)

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	brainloss = amount

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/adjustStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = Clamp(staminaloss + amount, 0, maxHealth*2)
	if(updating_stamina)
		update_stamina()

/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/proc/setStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/setStaminaLoss(amount, updating_stamina = 1)
	if(status_flags & GODMODE)
		return 0
	staminaloss = amount
	if(updating_stamina)
		update_stamina()

/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return
=======
/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + (amount * brain_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + (amount * hal_damage_modifier), 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/mob/living/proc/getMaxHealth()
	return maxHealth

<<<<<<< HEAD
/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

// MOB PROCS //END

/mob/living/proc/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(sleeping)
		src << "<span class='notice'>You are already sleeping.</span>"
		return
	else
		if(alert(src, "You sure you want to sleep for a while?", "Sleep", "Yes", "No") == "Yes")
			SetSleeping(20) //Short nap
	update_canmove()

/mob/proc/get_contents()

/mob/living/proc/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	src << "<span class='notice'>You are now [resting ? "resting" : "getting up"].</span>"
	update_canmove()

//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/weapon/storage/Storage = null)
=======
/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()



//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()
<<<<<<< HEAD
		return L
	else
		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/under/U in src.contents)	//Check for jumpsuit accessories
			L += U.contents
		for(var/obj/item/weapon/folder/F in src.contents)	//Check for folders
			L += F.contents
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = src.get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0


/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = 0, tesla_shock = 0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
=======

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/weapon/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/weapon/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/delivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += src.contents
		for(var/obj/item/weapon/storage/S in src.contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in src.contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in src.contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/weapon/gift/G in src.contents) //Check for gift-wrapped items
			L += G.gift
			if(istype(G.gift, /obj/item/weapon/storage))
				L += get_contents(G.gift)

		for(var/obj/item/delivery/D in src.contents) //Check for package wrapped items
			L += D.wrapped
			if(istype(D.wrapped, /obj/item/weapon/storage)) //this should never happen
				L += get_contents(D.wrapped)
		return L

/mob/living/proc/can_inject()
	return 1

/mob/living/proc/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	  return 0 // only carbon liveforms have this proc
				// now with silicons

/mob/living/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

<<<<<<< HEAD
/mob/living/proc/can_inject()
	return 1

/mob/living/proc/get_organ_target()
	var/mob/shooter = src
	var/t = shooter.zone_selected
	if ((t in list( "eyes", "mouth" )))
		t = "head"
	var/def_zone = ran_zone(t)
	return def_zone

// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(brute, burn, updating_health=1)
	adjustBruteLoss(-brute, updating_health)
	adjustFireLoss(-burn, updating_health)
	if(updating_health)
		updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(brute, burn, updating_health=1)
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	if(updating_health)
		updatehealth()

// heal MANY bodyparts, in random order
/mob/living/proc/heal_overall_damage(brute, burn, updating_health=1)
	adjustBruteLoss(-brute, updating_health)
	adjustFireLoss(-burn, updating_health)
	if(updating_health)
		updatehealth()

// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute, burn, updating_health=1)
	adjustBruteLoss(brute, updating_health)
	adjustFireLoss(burn, updating_health)
	if(updating_health)
		updatehealth()

//proc used to ressuscitate a mob
/mob/living/proc/revive(full_heal = 0, admin_revive = 0)
	if(full_heal)
		fully_heal(admin_revive)
	if(stat == DEAD && can_be_revived()) //in some cases you can't revive (e.g. no brain)
		dead_mob_list -= src
		living_mob_list += src
		suiciding = 0
		stat = UNCONSCIOUS //the mob starts unconscious,
		blind_eyes(1)
		updatehealth() //then we check if the mob should wake up.
		update_canmove()
		update_sight()
		reload_fullscreen()
		. = 1

//proc used to completely heal a mob.
/mob/living/proc/fully_heal(admin_revive = 0)
	restore_blood()
	setToxLoss(0, 0)
	setOxyLoss(0, 0)
	setCloneLoss(0, 0)
	setBrainLoss(0)
	setStaminaLoss(0, 0)
	SetParalysis(0, 0)
	SetStunned(0, 0)
	SetWeakened(0, 0)
	SetSleeping(0, 0)
	radiation = 0
	nutrition = NUTRITION_LEVEL_FED + 50
	bodytemperature = 310
	set_blindness(0)
	set_blurriness(0)
	set_eye_damage(0)
	cure_nearsighted()
	cure_blind()
	disabilities = 0
	ear_deaf = 0
	ear_damage = 0
	hallucination = 0
	heal_overall_damage(100000, 100000)
	ExtinguishMob()
	fire_stacks = 0
	updatehealth()
	update_canmove()


//proc called by revive(), to check if we can actually ressuscitate the mob (we don't want to revive him and have him instantly die again)
/mob/living/proc/can_be_revived()
	. = 1
	if(health <= config.health_threshold_dead)
		return 0

/mob/living/proc/update_damage_overlays()
	return

=======
/mob/living/proc/get_organ_target()
	var/t = src.zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = LIMB_HEAD
	var/datum/organ/external/def_zone = ran_zone(t)
	return def_zone


// heal ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_organ_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_organ_damage(var/brute, var/burn)
	if(status_flags & GODMODE)	return 0	//godmode
	if(flags & INVULNERABLE)	return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY external organs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY external organs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null)
	if(status_flags & GODMODE)	return 0	//godmode
	if(flags & INVULNERABLE)	return 0
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return

/*
NOTE TO ANYONE MAKING A PROC THAT USES REVIVE/REJUVENATE:
If the proc calling either of these is:
	-meant to be an admin/overpowered revival proc, make sure you set suiciding = 0
	-meant to be something that a player uses to heal/revive themself or others, check if suiciding = 1 and prevent them from reviving if true.
Thanks.
*/

/mob/living/proc/revive(animation = 0)
	rejuvenate(animation)
	/*
	locked_to = initial(src.locked_to)
	*/
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if (C.handcuffed && !initial(C.handcuffed))
			C.drop_from_inventory(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)

		if (C.legcuffed && !initial(C.legcuffed))
			C.drop_from_inventory(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD

/mob/living/proc/rejuvenate(animation = 0)
	var/turf/T = get_turf(src)
	if(animation) T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = PLANE_EFFECTS)

	// shut down various types of badness
	toxloss = 0
	oxyloss = 0
	cloneloss = 0
	bruteloss = 0
	fireloss = 0
	brainloss = 0
	halloss = 0
	paralysis = 0
	stunned = 0
	weakened = 0
	remove_jitter()
	germ_level = 0
	next_pain_time = 0
	traumatic_shock = 0
	radiation = 0
	nutrition = 400
	bodytemperature = 310
	sdisabilities = 0
	disabilities = 0
	blinded = 0
	eye_blind = 0
	eye_blurry = 0
	ear_deaf = 0
	ear_damage = 0
	if(!reagents)
		create_reagents(1000)
	else
		reagents.clear_reagents()
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	fire_stacks = 0
	/*
	if(locked_to)
		locked_to.unbuckle()
	locked_to = initial(src.locked_to)
	*/
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		H.timeofdeath = 0
		H.vessel.reagent_list = list()
		H.vessel.add_reagent(BLOOD,560)
		H.shock_stage = 0
		spawn(1)
			H.fixblood()
		for(var/organ_name in H.organs_by_name)
			var/datum/organ/external/O = H.organs_by_name[organ_name]
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					qdel(s)
					s = null
			O.amputated = 0
			O.brute_dam = 0
			O.burn_dam = 0
			O.damage_state = "00"
			O.germ_level = 0
			O.hidden = null
			O.number_wounds = 0
			O.open = 0
			O.perma_injury = 0
			O.stage = 0
			O.status = 0
			O.trace_chemicals = list()
			O.wounds = list()
			O.wound_update_accuracy = 1
		for(var/organ_name in H.internal_organs_by_name)
			var/datum/organ/internal/IO = H.internal_organs_by_name[organ_name]
			IO.damage = 0
			IO.trace_chemicals.len = 0
			IO.germ_level = 0
			IO.status = 0
			IO.robotic = 0
		H.updatehealth()
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)
	for(var/datum/disease/D in viruses)
		D.cure(0)
	if(stat == DEAD)
		resurrect()
		tod = null

	// restore us to conciousness
	stat = CONSCIOUS

	//Snowflake fix for zombiepowder
	status_flags &= ~FAKEDEATH

	// make the icons look correct
	regenerate_icons()
	update_canmove()
	..()

	hud_updateflag |= 1 << HEALTH_HUD
	hud_updateflag |= 1 << STATUS_HUD
	return

/mob/living/proc/UpdateDamageIcon()
	return


>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
<<<<<<< HEAD
			src << "[src]'s Metainfo:<br>[client.prefs.metadata]"
		else
			src << "[src] does not have any stored infomation!"
	else
		src << "OOC Metadata is not supported by this server!"
=======
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

	return

/mob/living/Move(atom/newloc, direct)
<<<<<<< HEAD
	if (buckled && buckled.loc != newloc) //not updating position
		if (!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
		log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
		stop_pulling()
	var/turf/T = loc
	. = ..()
	if(. && pulling && pulling == pullee) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return

		var/pull_dir = get_dir(src, pulling)
		if(get_dist(src, pulling) > 1 || ((pull_dir - 1) & pull_dir)) //puller and pullee more than one tile away or in diagonal position
			if(isliving(pulling))
				var/mob/living/M = pulling
				if(M.lying && !M.buckled && (prob(M.getBruteLoss()*200/M.maxHealth)))
					M.makeTrail(T)
			pulling.Move(T, get_dir(pulling, T)) //the pullee tries to reach our previous position
			if(pulling && get_dist(src, pulling) > 1) //the pullee couldn't keep up
				stop_pulling()

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

	if (s_active && !(s_active.ClickAccessible(src, depth=STORAGE_VIEW_DEPTH) || s_active.Adjacent(src)))
		s_active.close(src)

/mob/living/movement_delay()
	. = ..()
	if(istype(loc, /turf/open))
		var/turf/open/T = loc
		. += T.slowdown
	switch(m_intent)
		if("run")
			if(drowsyness > 0)
				. += 6
			. += config.run_speed
		if("walk")
			. += config.walk_speed

/mob/living/proc/makeTrail(turf/T)
	if(!has_gravity(src))
		return
	var/blood_exists = 0

	for(var/obj/effect/decal/cleanable/trail_holder/C in src.loc) //checks for blood splatter already on the floor
		blood_exists = 1
	if (isturf(src.loc))
		var/trail_type = getTrail()
		if(trail_type)
			var/brute_ratio = round(getBruteLoss()/maxHealth, 0.1)
			if(blood_volume && blood_volume > max(BLOOD_VOLUME_NORMAL*(1 - brute_ratio * 0.25), 0))//don't leave trail if blood volume below a threshold
				blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0) 					//that depends on our brute damage.
				var/newdir = get_dir(T, src.loc)
				if(newdir != src.dir)
					newdir = newdir | src.dir
					if(newdir == 3) //N + S
						newdir = NORTH
					else if(newdir == 12) //E + W
						newdir = EAST
				if((newdir in cardinal) && (prob(50)))
					newdir = turn(get_dir(T, src.loc), 180)
				if(!blood_exists)
					new /obj/effect/decal/cleanable/trail_holder(src.loc)
				for(var/obj/effect/decal/cleanable/trail_holder/TH in src.loc)
					if((!(newdir in TH.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && TH.existing_dirs.len <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
						TH.existing_dirs += newdir
						TH.overlays.Add(image('icons/effects/blood.dmi',trail_type,dir = newdir))
						TH.transfer_mob_blood_dna(src)

/mob/living/carbon/human/makeTrail(turf/T)
	if((NOBLOOD in dna.species.specflags) || !bleed_rate || bleedsuppress)
		return
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	if (client && client.move_delay >= world.time + world.tick_lag*2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if (has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction)+90))
		if (T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction)-90))
		if (T)
			turfs_to_check += T

		for (var/t in turfs_to_check)
			T = t
			if (T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for (var/atom/movable/AM in T)
				if (AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break

	..(pressure_difference, direction, pressure_resistance_prob_delta)

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(src) || next_move > world.time || incapacitated(ignore_restraints = 1))
		return
	changeNext_move(CLICK_CD_RESIST)

	//resisting grabs (as if it helps anyone...)
	if(!restrained(ignore_grab = 1) && pulledby)
		visible_message("<span class='danger'>[src] resists against [pulledby]'s grip!</span>")
		resist_grab()
		return

	//unbuckling yourself
	if(buckled && last_special <= world.time)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(canmove)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else if(last_special <= world.time)
			resist_restraints() //trying to remove cuffs.


/mob/proc/resist_grab(moving_resist)
	return 1 //returning 0 means we successfully broke free

/mob/living/resist_grab(moving_resist)
	. = 1
	if(pulledby.grab_state)
		if(prob(30/pulledby.grab_state))
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
			pulledby.stop_pulling()
			return 0
		if(moving_resist && client) //we resisted by trying to move
			client.move_delay = world.time + 20
	else
		pulledby.stop_pulling()
		return 0

/mob/living/proc/resist_buckle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	return

/mob/living/proc/get_visible_name()
	return name

/mob/living/update_gravity(has_gravity,override = 0)
	if(!ticker || !ticker.mode)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /obj/screen/alert/weightless)
	if(!override)
		float(!has_gravity)

/mob/living/proc/float(on)
	if(throwing)
		return
	var/fixed = 0
	if(anchored || (buckled && buckled.anchored))
		fixed = 1
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		floating = 1
	else if(((!on || fixed) && floating))
		animate(src, pixel_y = get_standard_pixel_y_offset(lying), time = 10)
		floating = 0

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(check_eye_prot() < intensity && (override_blindness_check || !(disabilities & BLIND)))
		overlay_fullscreen("flash", type)
		addtimer(src, "clear_fullscreen", 25, FALSE, "flash", 25)
		return 1

//this returns the mob's protection against eye damage (number between -1 and 2)
/mob/living/proc/check_eye_prot()
	return 0

//this returns the mob's protection against ear damage (0 or 1)
/mob/living/proc/check_ear_prot()
	return 0

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where)
	if(what.flags & NODROP)
		src << "<span class='warning'>You can't remove \the [what.name], it appears to be stuck!</span>"
		return
	who.visible_message("<span class='danger'>[src] tries to remove [who]'s [what.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [who]'s [what.name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && what == who.get_item_by_slot(where) && Adjacent(who))
			who.unEquip(what)
			add_logs(src, who, "stripped", addition="of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where)
	what = src.get_active_hand()
	if(what && (what.flags & NODROP))
		src << "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>"
		return
	if(what)
		if(!what.mob_can_equip(who, where, 1))
			src << "<span class='warning'>\The [what.name] doesn't fit in that place!</span>"
			return
		visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who))
				unEquip(what)
				who.equip_to_slot_if_possible(what, where, 0, 1)
				add_logs(src, who, "equipped", what)

/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/singularity_pull(S, current_size)
	if(current_size >= STAGE_SIX)
		throw_at_fast(S,14,3, spin=1)
	else
		step_towards(src,S)

/mob/living/narsie_act()
	if(is_servant_of_ratvar(src) && !stat)
		src << "<span class='userdanger'>You resist Nar-Sie's influence... but not all of it. <i>Run!</i></span>"
		adjustBruteLoss(35)
		if(src && reagents)
			reagents.add_reagent("heparin", 5)
		return 0
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, null, 0)
	else
		new /mob/living/simple_animal/hostile/construct/harvester/hostile(get_turf(src))
	spawn_dust()
	gib()
	return

/mob/living/ratvar_act()
	if(!add_servant_of_ratvar(src) && !is_servant_of_ratvar(src))
		src << "<span class='userdanger'>A blinding light boils you alive! <i>Run!</i></span>"
		adjustFireLoss(35)
		if(src)
			adjust_fire_stacks(1)
			IgniteMob()

/atom/movable/proc/do_attack_animation(atom/A, end_pixel_y)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)


/mob/living/do_attack_animation(atom/A)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	..(A, final_pixel_y)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

	// What icon do we use for the attack?
	var/image/I
	if(hand && l_hand) // Attacked with item in left hand.
		I = image(l_hand.icon, A, l_hand.icon_state, A.layer + 0.1)
	else if(!hand && r_hand) // Attacked with item in right hand.
		I = image(r_hand.icon, A, r_hand.icon_state, A.layer + 0.1)
	else // Attacked with a fist?
		return

	// Who can see the attack?
	var/list/viewing = list()
	for(var/mob/M in viewers(A))
		if(M.client)
			viewing |= M.client
	flick_overlay(I, viewing, 5) // 5 ticks/half a second

	// Scale the icon.
	I.transform *= 0.75
	// The icon should not rotate.
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

	// Set the direction of the icon animation.
	var/direction = get_dir(src, A)
	if(direction & NORTH)
		I.pixel_y = -16
	else if(direction & SOUTH)
		I.pixel_y = 16

	if(direction & EAST)
		I.pixel_x = -16
	else if(direction & WEST)
		I.pixel_x = 16

	if(!direction) // Attacked self?!
		I.pixel_z = 16

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/mob/living/proc/do_jitter_animation(jitteriness)
	var/amplitude = min(4, (jitteriness/100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude/3, amplitude/3)
	var/final_pixel_x = get_standard_pixel_x_offset(lying)
	var/final_pixel_y = get_standard_pixel_y_offset(lying)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff , time = 2, loop = 6)
	animate(pixel_x = final_pixel_x , pixel_y = final_pixel_y , time = 2)
	floating = 0 // If we were without gravity, the bouncing animation got stopped, so we make sure to restart it in next life().

/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(istype(get_turf(src), /turf/open/space))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		var/obj/machinery/atmospherics/components/unary/cryo_cell/C = loc
		var/datum/gas_mixture/G = C.AIR1

		if(G.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = G.temperature

	else
		loc_temp = environment.temperature

	return loc_temp

/mob/living/proc/get_standard_pixel_x_offset(lying = 0)
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset(lying = 0)
	return initial(pixel_y)

/mob/living/Stat()
	..()
	if(statpanel("Status"))
		if(ticker)
			if(ticker.mode)
				for(var/datum/gang/G in ticker.mode.gangs)
					if(G.is_dominating)
						stat(null, "[G.name] Gang Takeover: [max(G.domination_time_remaining(), 0)]")

/mob/living/cancel_camera()
	..()
	cameraFollow = null

/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return 0
	if(T.z == ZLEVEL_CENTCOM) //dont detect mobs on centcomm
		return 0
	if(T.z >= ZLEVEL_SPACEMAX)
		return 0
	if(user != null && src == user)
		return 0
	if(invisibility || alpha == 0)//cloaked
		return 0
	if(digitalcamo || digitalinvis)
		return 0

	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return 0

	return 1

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/harvest(mob/living/user)
	if(qdeleted(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1; i <= butcher_results[path];i++)
				new path(src.loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
	visible_message("<span class='notice'>[user] butchers [src].</span>")
	gib()

/mob/living/canUseTopic(atom/movable/M, be_close = 0, no_dextery = 0)
	if(incapacitated())
		return
	if(no_dextery)
		if(be_close && in_range(M, src))
			return 1
	else
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return
/mob/living/proc/can_use_guns(var/obj/item/weapon/gun/G)
	if (G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser())
		src << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 0
	return 1

/mob/living/carbon/proc/update_stamina()
	return

/mob/living/carbon/human/update_stamina()
	if(staminaloss)
		var/total_health = (health - staminaloss)
		if(total_health <= config.health_threshold_crit && !stat)
			src << "<span class='notice'>You're too exhausted to keep going...</span>"
			Weaken(5)
			setStaminaLoss(health - 2)
	update_health_hud()

/mob/proc/update_sight()
	return

/mob/living/proc/owns_soul()
	if(mind)
		return mind.soulOwner == mind
	return 1

/mob/living/proc/return_soul()
	if(mind)
		mind.soulOwner = mind

/mob/living/proc/has_bane(banetype)
	if(mind)
		if(mind.devilinfo)
			return mind.devilinfo.bane == banetype
	return 0

/mob/living/proc/check_weakness(obj/item/weapon, mob/living/attacker)
	if(mind && mind.devilinfo)
		return check_devil_bane_multiplier(weapon, attacker)
	return 1

/mob/living/proc/check_acedia()
	if(src.mind && src.mind.objectives)
		for(var/datum/objective/sintouched/acedia/A in src.mind.objectives)
			return 1
	return 0

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0)
	stop_pulling()
	. = ..()

// Called when we are hit by a bolt of polymorph and changed
// Generally the mob we are currently in, is about to be deleted
/mob/living/proc/wabbajack_act(mob/living/new_mob)
	new_mob.name = name
	new_mob.real_name = real_name

	if(mind)
		mind.transfer_to(new_mob)
	else
		new_mob.key = key

	for(var/para in hasparasites())
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.summoner = new_mob
		G.Recall()
		G << "<span class='holoparasite'>Your summoner has changed \
			form!</span>"

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return
=======
	if (locked_to && locked_to.loc != newloc)
		var/datum/locking_category/category = locked_to.locked_atoms[src]
		if (locked_to.anchored || category.flags & CANT_BE_MOVED_BY_LOCKED_MOBS)
			return 0
		else
			return locked_to.Move(newloc, direct)

	if (restrained())
		stop_pulling()

	var/turf/T = loc

	var/t7 = 1
	if (restrained())
		for(var/mob/living/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if (t7 && pulling && (Adjacent(pulling) || pulling.loc == loc))
		. = ..()

		if (pulling && pulling.loc)
			if(!isturf(pulling.loc))
				stop_pulling()
				return
			else
				if(Debug)
					diary <<"pulling disappeared? at [__LINE__] in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			stop_pulling()
			return

		var/mob/living/M = pulling
		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if(!istype(pulling) || !pulling)
					WARNING("Pulling disappeared! pulling = [pulling] old pulling = [M]")
				else if(isturf(pulling.loc))
					if (isliving(pulling))
						M = pulling
						var/ok = 1
						if (locate(/obj/item/weapon/grab, M.grabbed_by))
							if (prob(75))
								var/obj/item/weapon/grab/G = pick(M.grabbed_by)
								if (istype(G, /obj/item/weapon/grab))
									visible_message("<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s grip.</span>",
										drugged_message="<span class='danger'>[src] has pulled [G.affecting] from [G.assailant]'s hug.</span>")
									qdel(G)
							else
								ok = 0
							if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
								ok = 0
						if (ok)
							var/atom/movable/t = M.pulling
							M.stop_pulling()
							pulling.Move(T, get_dir(pulling, T))
							if(M)
								M.start_pulling(t)
					else
						if (pulling)
							pulling.Move(T, get_dir(pulling, T))
				else
					stop_pulling()
	else
		stop_pulling()
		. = ..()

	if ((s_active && !is_holder_of(src, s_active)))
		s_active.close(src)

	if(update_slimes)
		for(var/mob/living/carbon/slime/M in view(1,src))
			M.UpdateFeed(src)

	if(T != loc)
		handle_hookchain(direct)

	if(.)
		for(var/obj/item/weapon/gun/G in targeted_by) //Handle moving out of the gunner's view.
			var/mob/living/M = G.loc
			if(!(M in view(src)))
				NotTargeted(G)
		for(var/obj/item/weapon/gun/G in src) //Handle the gunner loosing sight of their target/s
			if(G.target)
				for(var/mob/living/M in G.target)
					if(M && !(M in view(src)))
						M.NotTargeted(G)
	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=loc))

/mob/living/proc/handle_hookchain(var/direct)
	for(var/obj/item/weapon/gun/hookshot/hookshot in src)
		if(hookshot.clockwerk)
			continue

		for(var/i = 1;i<hookshot.maxlength;i++)
			var/obj/effect/overlay/hookchain/HC = hookshot.links["[i]"]
			if(HC.loc != hookshot)
				HC.Move(get_step(HC,direct),direct)

		if(hookshot.hook)
			var/obj/item/projectile/hookshot/hook = hookshot.hook
			hook.Move(get_step(hook,direct),direct)
			if(direct & NORTH)
				hook.override_starting_Y++
				hook.override_target_Y++
			if(direct & SOUTH)
				hook.override_starting_Y--
				hook.override_target_Y--
			if(direct & EAST)
				hook.override_starting_X++
				hook.override_target_X++
			if(direct & WEST)
				hook.override_starting_X--
				hook.override_target_X--

/mob/living
    var/event/on_resist

/mob/living/New()
    . = ..()
    on_resist = new(owner = src)

/mob/living/Destroy()
    . = ..()
    qdel(on_resist)
    on_resist = null

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.special_delayer.blocked())
		return

	INVOKE_EVENT(on_resist, list())

	delayNext(DELAY_ALL,20) // Attack, Move, and Special.

	var/mob/living/L = usr

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc
		forceMove(get_turf(src))
		if(istype(H.loc, /mob/living))
			var/mob/living/Location = H.loc
			Location.drop_from_inventory(H)
		qdel(H)
		H = null
		return
	else if(istype(src.loc, /obj/structure/strange_present))
		var/obj/structure/strange_present/present = src.loc
		forceMove(get_turf(src))
		qdel(present)
		playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return
	else if(istype(src.loc, /obj/item/delivery/large)) //Syndie item
		var/obj/item/delivery/large/package = src.loc
		to_chat(L, "<span class='warning'>You attempt to unwrap yourself, this package is tight and will take some time.</span>")
		if(do_after(src, src, 100))
			L.visible_message("<span class='danger'>[L] successfully breaks out of [package]!</span>",\
							  "<span class='notice'>You successfully break out!</span>")
			forceMove(get_turf(src))
			qdel(package)
			playsound(src.loc, 'sound/items/poster_ripped.ogg', 100, 1)
		return

	//Detaching yourself from a tether
	if(L.tether)
		var/mob/living/carbon/CM = L
		if(!istype(CM) || !CM.handcuffed)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum.extremity_B == src)
				L.visible_message("<span class='danger'>\the [L] quickly grabs and removes \the [L.tether] tethered to his body!</span>",
							  "<span class='warning'>You quickly grab and remove \the [L.tether] tethered to your body.</span>")
				L.tether = null
				tether_datum.extremity_B = null
				tether_datum.rewind_chain()

	//Trying to unstick a stickybomb
	for(var/obj/item/stickybomb/B in L)
		if(B.stuck_to)
			L.visible_message("<span class='danger'>\the [L] is trying to reach and pull off \the [B] stuck on his body!</span>",
						  "<span class='warning'>You reach for \the [B] stuck on your body and start pulling.</span>")
			if(do_after(L, src, 30, 10, FALSE))
				L.visible_message("<span class='danger'>After struggling for an instant, \the [L] manages unstick \the [B] from his body!</span>",
						  "<span class='warning'>It came off!</span>")
				L.put_in_hands(B)
				B.unstick(0)
			else
				to_chat(L, "<span class='warning'>You need to stop moving around while you try to get a hold of \the [B]!</span>")
			return
		else
			continue

	//Resisting control by an alien mind.
	if(istype(src.loc,/mob/living/simple_animal/borer))
		var/mob/living/simple_animal/borer/B = src.loc
		var/mob/living/captive_brain/H = src

		H.simple_message("<span class='danger'>You begin doggedly resisting the parasite's control (this will take approximately sixty seconds).</span>",\
			"<span class='danger'>You attempt to remember who you are and how the heck did you get here (this will probably take a while).</span>")
		to_chat(B.host, "<span class='danger'>You feel the captive mind of [src] begin to resist your control.</span>")

		spawn(rand(350,450)+B.host.brainloss)

			if(!B || !B.controlling)
				return

			B.host.adjustBrainLoss(rand(5,10))
			H.simple_message("<span class='danger'>With an immense exertion of will, you regain control of your body!</span>")
			to_chat(B.host, "<span class='danger'>You feel control of the host brain ripped from your grasp, and retract your probosci before the wild neural impulses can damage you.</span>")

			var/mob/living/carbon/C=B.host
			C.do_release_control(0) // Was detach().

			return

	//resisting grabs (as if it helps anyone...)
	if ((!(L.stat) && L.canmove && !(L.restrained())))
		var/resisting = 0
		for(var/obj/O in L.requests)
			L.requests.Remove(O)
			qdel(O)
			O = null
			resisting++
		for(var/obj/item/weapon/grab/G in usr.grabbed_by)
			resisting++
			if (G.state == GRAB_PASSIVE)
				returnToPool(G)
			else
				if (G.state == GRAB_AGGRESSIVE)
					if (prob(25))
						L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s grip!</span>", \
							drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s hug!</span>")
						returnToPool(G)
				else
					if (G.state == GRAB_NECK)
						if (prob(5))
							L.visible_message("<span class='danger'>[L] has broken free of [G.assailant]'s headlock!</span>", \
								drugged_message="<span class='danger'>[L] has broken free of [G.assailant]'s passionate hug!</span>")
							returnToPool(G)
		if(resisting)
			L.visible_message("<span class='danger'>[L] resists!</span>")


	if(L.locked_to && L.special_delayer.blocked())
		//unbuckling yourself
		if(istype(L.locked_to, /obj/structure/bed))
			var/obj/structure/bed/B = L.locked_to
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				if(C.handcuffed)
					C.delayNextAttack(100)
					C.delayNextSpecial(100)
					C.visible_message("<span class='warning'>[C] attempts to unbuckle themself!</span>",
									  "<span class='warning'>You attempt to unbuckle yourself (this will take around two minutes, and you need to stay still).</span>",
									  self_drugged_message="<span class='warning'>You attempt to regain control of your legs (this will take a while).</span>")
					spawn(0)
						if(do_after(usr, usr, 1200))
							if(!C.locked_to)
								return
							C.visible_message("<span class='danger'>[C] manages to unbuckle themself!</span>",\
								"<span class='notice'>You successfully unbuckle yourself.</span>",\
								self_drugged_message="<span class='notice'>You successfully regain control of your legs and stand up.</span>")
							B.manual_unbuckle(C)
						else
							C.simple_message("<span class='warning'>Your unbuckling attempt was interrupted.</span>", \
								"<span class='warning'>Your attempt to regain control of your legs was interrupted. Damn it!</span>")
			else
				B.manual_unbuckle(L)
		//release from kudzu
		/*else if(istype(L.locked_to, /obj/effect/plantsegment))
			var/obj/effect/plantsegment/K = L.locked_to
			K.manual_unbuckle(L)*/

	//Breaking out of a locker?
	if(src.loc && (istype(src.loc, /obj/structure/closet)))
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(!istype(C.loc, /obj/item/delivery/large)) //Wouldn't want to interrupt escaping being wrapped over the next few trivial checks
			if(istype(C, /obj/structure/closet/secure_closet))
				var/obj/structure/closet/secure_closet/SC = L.loc
				if(!SC.locked && !SC.welded)
					return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
			else
				if(!C.welded)
					return //closed but not welded...

		//okay, so the closet is either welded or locked... resist!!!
		L.delayNext(DELAY_ALL,100)
		L.visible_message("<span class='danger'>The [C] begins to shake violenty!</span>",
						  "<span class='warning'>You lean on the back of [C] and start pushing the door open (this will take about [breakout_time] minutes).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time * 60 * 10)) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

				if(!istype(C.loc, /obj/item/delivery/large)) //Wouldn't want to interrupt escaping being wrapped over the next few trivial checks
					//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
					if(istype(L.loc, /obj/structure/closet/secure_closet))
						var/obj/structure/closet/secure_closet/SC = L.loc
						if(!SC.locked && !SC.welded)
							return
					else
						if(!C.welded)
							return

				//Well then break it!
				if(istype(usr.loc, /obj/structure/closet/secure_closet))
					var/obj/structure/closet/secure_closet/SC = L.loc
					SC.desc = "It appears to be broken."
					SC.icon_state = SC.icon_off
					flick(SC.icon_broken, SC)
					sleep(10)
					flick(SC.icon_broken, SC)
					sleep(10)
					SC.broken = SC.locked // If it's only welded just break the welding, dont break the lock.
					SC.locked = 0
					SC.welded = 0
					L.visible_message("<span class='danger'>[L] successfully breaks out of [SC]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(SC.loc, /obj/item/delivery/large)) //Do this to prevent contents from being opened into nullspace (read: bluespace)
						var/obj/item/delivery/large/BD = SC.loc
						BD.attack_hand(usr)
					SC.open()
				else
					C.welded = 0
					L.visible_message("<span class='danger'>[L] successful breaks out of [C]!</span>",
									  "<span class='notice'>You successfully break out!</span>")
					if(istype(C.loc, /obj/item/delivery/large)) //nullspace ect.. read the comment above
						var/obj/item/delivery/large/BD = C.loc
						BD.attack_hand(usr)
					C.open()


	else if(iscarbon(L))
		var/mob/living/carbon/CM = L
	//putting out a fire
		if(CM.on_fire && CM.canmove)
			CM.fire_stacks -= 5
			CM.SetWeakened(3)
			playsound(CM.loc, 'sound/effects/bodyfall.ogg', 50, 1)
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>",
							   "<span class='warning'>You stop, drop, and roll!</span>")

			for(var/i = 1 to rand(8,12))
				CM.dir = turn(CM.dir, pick(-90, 90))
				sleep(2)

			if(fire_stacks <= 0)
				CM.visible_message("<span class='danger'>[CM] has successfully extinguished themselves!</span>",
								   "<span class='notice'>You extinguish yourself.</span>")
				ExtinguishMob()
			return

	//breaking out of handcuffs
		if(CM.handcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the handcuffs!</span>",
								   "<span class='warning'>You attempt to break your handcuffs. (This will take around five seconds and you will need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.handcuffed || CM.locked_to)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the handcuffs!</span>",
										   "<span class='notice'>You successfuly break your handcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						var/obj/item/weapon/handcuffs/cuffs = CM.handcuffed
						CM.drop_from_inventory(cuffs)
						if(!cuffs.gcDestroyed) //If these were not qdel'd already (exploding cuffs, anyone?)
							qdel(cuffs)
					else
						to_chat(CM, "<span class='warning'>Your cuff breaking attempt was interrupted.</span>")


			else
				var/obj/item/weapon/handcuffs/HC = CM.handcuffed
				var/breakouttime = HC.breakouttime
				if(!(breakouttime))
					breakouttime = 1200 //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove [HC]!</span>",
								   "<span class='warning'>You attempt to remove [HC] (this will take around [(breakouttime)/600] minutes and you need to stand still).</span>",
								   self_drugged_message="<span class='warning'>You attempt to regain control of your hands (this will take a while).</span>")
				spawn(0)
					if(do_after(CM,CM, breakouttime))
						if(!CM.handcuffed || CM.locked_to)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove [HC]!</span>",
										   "<span class='notice'>You successfuly remove [HC].</span>",
										   self_drugged_message="<span class='notice'>You successfully regain control of your hands.</span>")
						CM.drop_from_inventory(HC)
					else
						CM.simple_message("<span class='warning'>Your uncuffing attempt was interrupted.</span>",
							"<span class='warning'>Your attempt to regain control of your hands was interrupted. Damn it!</span>")

		else if(CM.legcuffed && CM.canmove && CM.special_delayer.blocked())
			CM.delayNext(DELAY_ALL,100)
			if(isalienadult(CM) || (M_HULK in usr.mutations))//Don't want to do a lot of logic gating here.
				CM.visible_message("<span class='danger'>[CM] is trying to break the legcuffs!</span>",
								   "<span class='warning'>You attempt to break your legcuffs. (This will take around five seconds and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, 50))
						if(!CM.legcuffed || CM.locked_to)
							return
						CM.visible_message("<span class='danger'>[CM] manages to break the legcuffs!</span>",
										   "<span class='notice'>You successfully break your legcuffs.</span>")
						CM.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
						qdel(CM.legcuffed)
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						to_chat(CM, "<span class='warning'>Your legcuffing breaking attempt was interrupted.</span>")
			else
				var/obj/item/weapon/legcuffs/HC = CM.legcuffed
				var/breakouttime = HC.breakouttime
				if(!(breakouttime))
					breakouttime = 1200 //Default
				CM.visible_message("<span class='danger'>[CM] attempts to remove [HC]!</span>",
								   "<span class='warning'>You attempt to remove [HC]. (This will take around [(breakouttime)/600] minutes and you need to stand still).</span>")
				spawn(0)
					if(do_after(CM, CM, breakouttime))
						if(!CM.legcuffed || CM.locked_to)
							return // time leniency for lag which also might make this whole thing pointless but the server
						CM.visible_message("<span class='danger'>[CM] manages to remove [HC]!</span>",
										   "<span class='notice'>You successfully remove [HC].</span>")
						CM.legcuffed.loc = usr.loc
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						to_chat(CM, "<span class='warning'>Your unlegcuffing attempt was interrupted.</span>")

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
	update_canmove()
	to_chat(src, "<span class='notice'>You are now [resting ? "resting" : "getting up"]</span>")

/mob/living/proc/has_brain()
	return 1

/mob/living/proc/has_eyes()
	return 1

/mob/living/singularity_act()
	if(!(src.flags & INVULNERABLE))
		var/gain = 20
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return(gain)

/mob/living/singularity_pull(S)
	if(!(src.flags & INVULNERABLE))
		step_towards(src, S)

//shuttle_act is called when a shuttle collides with the mob
/mob/living/shuttle_act(datum/shuttle/S)
	if(!(src.flags & INVULNERABLE))
		src.attack_log += "\[[time_stamp()]\] was gibbed by a shuttle ([S.name], [S.type])!"
		gib()
	return

/mob/living/proc/InCritical()
	return (src.health < 0 && src.health > -95.0 && stat == UNCONSCIOUS)

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = "Object"
	if(AM.Adjacent(src))
		src.start_pulling(AM)
	return

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(src.incapacitated())
		return 0
	if(!..())
		return 0
	usr.visible_message("<b>[src]</b> points to [A]")
	return 1


/mob/living/proc/generate_static_overlay()
	if(!istype(static_overlays,/list))
		static_overlays = list()
	static_overlays.Add(list("static", "blank", "letter"))
	var/image/static_overlay = image(getStaticIcon(new/icon(src.icon, src.icon_state)), loc = src)
	static_overlay.override = 1
	static_overlays["static"] = static_overlay

	static_overlay = image(getBlankIcon(new/icon(src.icon, src.icon_state)), loc = src)
	static_overlay.override = 1
	static_overlays["blank"] = static_overlay

	static_overlay = getLetterImage(src)
	static_overlay.override = 1
	static_overlays["letter"] = static_overlay

/*one proc, four uses
swapping: if it's 1, the mobs are trying to switch, if 0, non-passive is pushing passive
default behaviour is:
 - non-passive mob passes the passive version
 - passive mob checks to see if its mob_bump_flag is in the non-passive's mob_bump_flags
 - if si, the proc returns
*/
/mob/living/proc/can_move_mob(var/mob/living/swapped, swapping = 0, passive = 0)
	if(!swapped)
		return 1
	if(!passive)
		return swapped.can_move_mob(src, swapping, 1)
	else
		var/context_flags = 0
		if(swapping)
			context_flags = swapped.mob_swap_flags
		else
			context_flags = swapped.mob_push_flags
		if(!mob_bump_flag) //nothing defined, go wild
			return 1
		if(mob_bump_flag & context_flags)
			return 1
		return 0

/mob/living/Bump(atom/movable/AM as mob|obj)
	spawn(0)
		if (now_pushing || !loc)
			return
		now_pushing = 1
		if (istype(AM, /obj/structure/bed/roller)) //no pushing rollerbeds that have people on them
			var/obj/structure/bed/roller/R = AM
			for(var/mob/living/tmob in range(R, 1))
				if(tmob.pulling == R && !(tmob.restrained()) && tmob.stat == 0 && R.density == 1)
					to_chat(src, "<span class='warning'>[tmob] is pulling [R], you can't push past.</span>")
					now_pushing = 0
					return
		if (istype(AM, /mob/living)) //no pushing people pushing rollerbeds that have people on them
			var/mob/living/tmob = AM
			for(var/obj/structure/bed/roller/R in range(tmob, 1))
				if(tmob.pulling == R && !(tmob.restrained()) && tmob.stat == 0 && R.density == 1)
					to_chat(src, "<span class='warning'>[tmob] is pulling [R], you can't push past.</span>")
					now_pushing = 0
					return
			for(var/mob/living/M in range(tmob, 1)) //no pushing prisoners or people pulling prisoners
				if(tmob.pinned.len ||  ((M.pulling == tmob && (tmob.restrained() && !(M.restrained()) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)))
					to_chat(src, "<span class='warning'>[tmob] is restrained, you can't push past.</span>")
					now_pushing = 0
					return
				if(tmob.pulling == M && (M.restrained() && !(tmob.restrained()) && tmob.stat == 0))
					to_chat(src, "<span class='warning'>[tmob] is restraining [M], you can't push past.</span>")
					now_pushing = 0
					return

			//BubbleWrap: people in handcuffs are always switched around as if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
			var/dense = 0
			if(loc.density)
				dense = 1
			for(var/atom/movable/A in loc)
				if(A == src)
					continue
				if(A.density)
					if(A.flags&ON_BORDER)
						dense = !A.Cross(src, src.loc)
					else
						dense = 1
				if(dense) break
			if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained()) && tmob.canmove && canmove && !dense && can_move_mob(tmob, 1, 0)) // mutual brohugs all around!
				var/turf/oldloc = loc
				forceMove(tmob.loc)
				tmob.forceMove(oldloc)
				now_pushing = 0
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = 0
				return
			var/mob/living/carbon/human/H = null
			if(ishuman(tmob))
				H = tmob
			if(H && ((M_FAT in H.mutations) || (H && H.species && H.species.flags & IS_BULKY)))
				var/mob/living/carbon/human/U = null
				if(ishuman(src))
					U = src
				if(prob(40) && !(U && ((M_FAT in U.mutations) || (U && U.species && U.species.flags & IS_BULKY))))
					to_chat(src, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
					now_pushing = 0
					return

			for(var/obj/item/weapon/shield/riot/R in tmob.held_items)
				if(prob(99))
					now_pushing = 0
					return

			if(!(tmob.status_flags & CANPUSH))
				now_pushing = 0
				return

			tmob.LAssailant = src

		now_pushing = 0
		spawn(0)
			..()
			if (!istype(AM, /atom/movable))
				return
			if (!now_pushing)
				now_pushing = 1

				if (!AM.anchored)
					var/t = get_dir(src, AM)
					if(AM.flags & ON_BORDER && !t)
						t = AM.dir
					if (istype(AM, /obj/structure/window/full))
						for(var/obj/structure/window/win in get_step(AM,t))
							now_pushing = 0
							return
					step(AM, t)
				now_pushing = 0
			return
	return

/mob/living/is_open_container()
	return 1

/mob/living/proc/drop_meat(location)
	if(!meat_type) return 0

	var/obj/item/weapon/reagent_containers/food/snacks/meat/M = new meat_type(location)
	var/obj/item/weapon/reagent_containers/food/snacks/meat/animal/A = M

	if(istype(A))
		var/mob/living/simple_animal/source_animal = src
		if(istype(source_animal) && source_animal.species_type)
			var/mob/living/specimen = source_animal.species_type
			A.name = "[initial(specimen.name)] meat"
			A.animal_name = initial(specimen.name)
		else
			A.name = "[initial(src.name)] meat"
			A.animal_name = initial(src.name)
	return M

/mob/living/proc/butcher()
	set category = "Object"
	set name = "Butcher"
	set src in oview(1)

	var/mob/living/user = usr
	if(!istype(user))
		return

	if(user.isUnconscious() || user.restrained())
		return

	if(being_butchered)
		to_chat(user, "<span class='notice'>[src] is already being butchered.</span>")
		return

	if(!can_butcher)
		if(meat_taken)
			to_chat(user, "<span class='notice'>[src] has already been butchered.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You can't butcher [src]!")
			return
		return

	var/obj/item/tool = null	//The tool that is used for butchering
	var/speed_mod = 1.0			//The higher it is, the faster you butcher
	var/butchering_time = 20 * size //2 seconds for tiny animals, 4 for small ones, 6 for normal sized ones (+ humans), 8 for big guys and 10 for biggest guys

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		tool = H.get_active_hand()
		if(tool)
			speed_mod = tool.is_sharp()
			if(!speed_mod)
				to_chat(user, "<span class='notice'>You can't butcher \the [src] with this!</span>")
				return
		else
			speed_mod = 0.0

		if(M_CLAWS in H.mutations)
			if(!istype(H.gloves))
				speed_mod += 0.25
		if(M_BEAK in H.mutations)
			if(istype(H.wear_mask))
				var/obj/item/clothing/mask/M = H.wear_mask
				if(!(M.body_parts_covered & MOUTH)) //If our mask doesn't cover mouth, we can use our beak to help us while butchering
					speed_mod += 0.25
			else
				speed_mod += 0.25
	else
		speed_mod = 0.5

	if(!speed_mod)
		return

	if(src.butchering_drops && src.butchering_drops.len)
		var/list/actions = list()
		actions += "Butcher"
		for(var/datum/butchering_product/B in src.butchering_drops)
			if(B.amount <= 0) continue

			actions |= capitalize(B.verb_name)
			actions[capitalize(B.verb_name)] = B
		actions += "Cancel"

		var/choice = input(user,"What would you like to do with \the [src]?","Butchering") in actions
		if(!Adjacent(user) || !(usr.get_active_hand() == tool)) return

		if(choice == "Cancel")
			return 0
		else if(choice != "Butcher")
			var/datum/butchering_product/our_product = actions[choice]
			if(!istype(our_product)) return

			user.visible_message("<span class='notice'>[user] starts [our_product.verb_gerund] \the [src][tool ? "with \the [tool]" : ""].</span>",\
				"<span class='info'>You start [our_product.verb_gerund] \the [src].</span>")
			src.being_butchered = 1
			if(!do_after(user,src,butchering_time / speed_mod))
				to_chat(user, "<span class='warning'>Your attempt to [our_product.verb_name] \the [src] has been interrupted.</span>")
				src.being_butchered = 0
			else
				to_chat(user, "<span class='info'>You finish [our_product.verb_gerund] \the [src].</span>")
				src.being_butchered = 0
				src.update_icons()
				our_product.spawn_result(get_turf(src), src)
			return

	user.visible_message("<span class='notice'>[user] starts butchering \the [src][tool ? " with \the [tool]" : ""].</span>",\
		"<span class='info'>You start butchering \the [src].</span>")
	src.being_butchered = 1

	if(!do_after(user,src,butchering_time / speed_mod))
		to_chat(user, "<span class='warning'>Your attempt to butcher \the [src] was interrupted.</span>")
		src.being_butchered = 0
		return

	src.drop_meat(get_turf(src))
	src.meat_taken++
	src.being_butchered = 0

	if(src.meat_taken < src.meat_amount)
		to_chat(user, "<span class='info'>You cut a chunk of meat out of \the [src].</span>")
		return

	to_chat(user, "<span class='info'>You butcher \the [src].</span>")
	can_butcher = 0

	if(istype(src, /mob/living/simple_animal)) //Animals can be butchered completely, humans - not so
		if(src.size > SIZE_TINY) //Tiny animals don't produce gibs
			gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()
		else
			qdel(src)

/mob/living/proc/get_strength() //Returns a mob's strength. Isn't used in damage calculations, but rather in things like cutting down trees etc.
	var/strength = 1.0

	strength += (M_HULK in src.mutations)
	strength += (M_STRONG in src.mutations)

	. = strength

/mob/living/proc/scoop_up(mob/M) //M = mob who scoops us up!
	if(!holder_type) return

	var/obj/item/weapon/holder/D = getFromPool(holder_type, loc, src)

	if(M.put_in_active_hand(D))
		to_chat(M, "You scoop up [src].")
		to_chat(src, "[M] scoops you up.")
		src.loc = D //Only move the mob into the holder after we're sure he has been picked up!
	else
		returnToPool(D)

	return

/mob/living/nuke_act() //Called when caught in a nuclear blast
	health = 0
	stat = DEAD

/mob/proc/CheckSlip()
	return 0



/*
	How this proc that I took from /tg/ works:
	intensity determines the damage done to humans with eyes
	visual determines whether the proc damages eyes (in the living/carbon/human proc). 1 for no damage
	override_blindness_check = 1 means that it'll display a flash even if the mob is blind
	affect_silicon = 0 means that the flash won't affect silicons at all.

*/
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(override_blindness_check || !(disabilities & BLIND))
		// flick("e_flash", flash)
		overlay_fullscreen("flash", type)
		// addtimer(src, "clear_fullscreen", 25, FALSE, "flash", 25)
		spawn(25)
			clear_fullscreen("flash", 25)
		return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
