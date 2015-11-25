/mob/proc/CheckSlip()
	return 0

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

/mob/living/Destroy()
	for(var/mob/living/silicon/robot/mommi/MoMMI in player_list)
		for(var/image/I in static_overlays)
			MoMMI.static_overlays.Remove(I) //no checks, since it's either there or its not
			MoMMI.client.images.Remove(I)
			del(I)
	if(static_overlays)
		static_overlays = null

	if(butchering_drops)
		for(var/datum/butchering_product/B in butchering_drops)
			butchering_drops -= B
			del(B)

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
	if(reagents && reagents.has_reagent("bustanut"))
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
	if ((src.health < 0 && src.health > -95.0))
		src.attack_log += "[src] has succumbed to death with [health] points of health!"
		src.apply_damage(maxHealth + 5 + src.health, OXY) // This will ensure people die when using the command, but don't go into overkill. 15 oxy points over the limit for safety since brute and burn regenerates
		src.health = 100 - src.getOxyLoss() - src.getToxLoss() - src.getFireLoss() - src.getBruteLoss()
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
//		to_chat(world, "[src] ~ [src.bodytemperature] ~ [temperature]")
	return temperature


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn
// I touched them without asking... I'm soooo edgy ~Erro (added nodamage checks)

/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	bruteloss = min(max(bruteloss + amount, 0),(maxHealth*2))

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = min(max(oxyloss + amount, 0),(maxHealth*2))

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = min(max(toxloss + amount, 0),(maxHealth*2))

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	fireloss = min(max(fireloss + amount, 0),(maxHealth*2))

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = min(max(cloneloss + amount, 0),(maxHealth*2))

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = min(max(brainloss + amount, 0),(maxHealth*2))

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	brainloss = amount

/mob/living/proc/getHalLoss()
	return halloss

/mob/living/proc/adjustHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = min(max(halloss + amount, 0),(maxHealth*2))

/mob/living/proc/setHalLoss(var/amount)
	if(status_flags & GODMODE)	return 0	//godmode
	halloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

// ++++ROCKDTBEN++++ MOB PROCS //END


/mob/proc/get_contents()



//Recursive function to find everything a mob is holding.
/mob/living/get_contents(var/obj/item/weapon/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

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

	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/get_organ_target()
	var/t = src.zone_sel.selecting
	if ((t in list( "eyes", "mouth" )))
		t = "head"
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
	if(animation) T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg')

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
	jitteriness = 0
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
		H.vessel.add_reagent("blood",560)
		H.shock_stage = 0
		spawn(1)
			H.fixblood()
		for(var/organ_name in H.organs_by_name)
			var/datum/organ/external/O = H.organs_by_name[organ_name]
			for(var/obj/item/weapon/shard/shrapnel/s in O.implants)
				if(istype(s))
					O.implants -= s
					H.contents -= s
					del(s)
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


/mob/living/proc/Examine_OOC()
	set name = "Examine Meta-Info (OOC)"
	set category = "OOC"
	set src in view()

	if(config.allow_Metadata)
		if(client)
			to_chat(usr, "[src]'s Metainfo:<br>[client.prefs.metadata]")
		else
			to_chat(usr, "[src] does not have any stored infomation!")
	else
		to_chat(usr, "OOC Metadata is not supported by this server!")

	return

/mob/living/Move(atom/newloc, direct)
	if (locked_to && locked_to.loc != newloc)
		if (!locked_to.anchored)
			return locked_to.Move(newloc, direct)
		else
			return 0

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

	if ((s_active && !( s_active in contents ) ))
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

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	if(!isliving(usr) || usr.special_delayer.blocked())
		return
	delayNext(DELAY_ALL,20) // Attack, Move, and Special.

	var/mob/living/L = usr

	//Getting out of someone's inventory.
	if(istype(src.loc,/obj/item/weapon/holder))
		var/obj/item/weapon/holder/H = src.loc
		src.loc = get_turf(src.loc)
		if(istype(H.loc, /mob/living))
			var/mob/living/Location = H.loc
			Location.drop_from_inventory(H)
		del(H)
		return

	//Detaching yourself from a tether
	if(L.tether)
		var/mob/living/carbon/CM = L
		if(!istype(CM) || !CM.handcuffed)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum.extremity_B == src)
				L.visible_message("<span class='danger'>\the [L] quickly grabs and removes \the [L.tether] tethered to his body!</span>",
							  "<span class='warning'>You quickly grabs and remove \the [L.tether] tethered to your body.</span>")
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
			del(O)
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


	//unbuckling yourself
	if(L.locked_to && L.special_delayer.blocked() && istype(L.locked_to, /obj/structure/bed))
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

	//Breaking out of a locker?
	if(src.loc && (istype(src.loc, /obj/structure/closet)))
		var/breakout_time = 2 //2 minutes by default

		var/obj/structure/closet/C = L.loc
		if(C.opened)
			return //Door's open... wait, why are you in it's contents then?
		if(istype(L.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = L.loc
			if(!SC.locked && !SC.welded)
				return //It's a secure closet, but isn't locked. Easily escapable from, no need to 'resist'
		else
			if(!C.welded)
				return //closed but not welded...
		//	else Meh, lets just keep it at 2 minutes for now
		//		breakout_time++ //Harder to get out of welded lockers than locked lockers

		//okay, so the closet is either welded or locked... resist!!!
		L.delayNext(DELAY_ALL,100)
		L.visible_message("<span class='danger'>The [C] begins to shake violenty!</span>",
						  "<span class='warning'>You lean on the back of [C] and start pushing the door open (this will take about [breakout_time] minutes).</span>")
		spawn(0)
			if(do_after(usr,src,breakout_time * 60 * 10)) //minutes * 60seconds * 10deciseconds
				if(!C || !L || L.stat != CONSCIOUS || L.loc != C || C.opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
					return

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
									  "<span class='notice'>You successful break out!</span>")
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
			CM.weakened = 5
			CM.visible_message("<span class='danger'>[CM] rolls on the floor, trying to put themselves out!</span>",
							   "<span class='warning'>You stop, drop, and roll!</span>")
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
						del(CM.handcuffed)
						CM.handcuffed = null
						CM.update_inv_handcuffed()
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
						CM.handcuffed.loc = usr.loc
						CM.handcuffed = null
						CM.update_inv_handcuffed()
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
						del(CM.legcuffed)
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
										   "<span class='notice'>You successful remove [HC].</span>")
						CM.legcuffed.loc = usr.loc
						CM.legcuffed = null
						CM.update_inv_legcuffed()
					else
						to_chat(CM, "<span class='warning'>Your unlegcuffing attempt was interrupted.</span>")

/mob/living/verb/lay_down()
	set name = "Rest"
	set category = "IC"

	resting = !resting
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
	if(src.stat || !src.canmove || src.restrained())
		return 0
	if(src.status_flags & FAKEDEATH)
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

/mob/living/Bump(atom/movable/AM as mob|obj, yes)
	spawn(0)
		if ((!( yes ) || now_pushing) || !loc)
			return
		now_pushing = 1
		if (istype(AM, /mob/living))
			var/mob/living/tmob = AM

			for(var/mob/living/M in range(tmob, 1))
				if(tmob.pinned.len ||  ((M.pulling == tmob && ( tmob.restrained() && !( M.restrained() ) && M.stat == 0)) || locate(/obj/item/weapon/grab, tmob.grabbed_by.len)) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restrained, you cannot push past</span>")
					now_pushing = 0
					return
				if( tmob.pulling == M && ( M.restrained() && !( tmob.restrained() ) && tmob.stat == 0) )
					if ( !(world.time % 5) )
						to_chat(src, "<span class='warning'>[tmob] is restraining [M], you cannot push past</span>")
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
						dense = !A.CanPass(src, src.loc)
					else
						dense = 1
				if(dense) break
			if((tmob.a_intent == I_HELP || tmob.restrained()) && (a_intent == I_HELP || src.restrained()) && tmob.canmove && canmove && !dense && can_move_mob(tmob, 1, 0)) // mutual brohugs all around!
				var/turf/oldloc = loc
				loc = tmob.loc
				tmob.loc = oldloc
				now_pushing = 0
				for(var/mob/living/carbon/slime/slime in view(1,tmob))
					if(slime.Victim == tmob)
						slime.UpdateFeed()
				return

			if(!can_move_mob(tmob, 0, 0))
				now_pushing = 0
				return
			if(istype(tmob, /mob/living/carbon/human) && (M_FAT in tmob.mutations))
				if(prob(40) && !(M_FAT in src.mutations))
					to_chat(src, "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>")
					now_pushing = 0
					return
			if(tmob.r_hand && istype(tmob.r_hand, /obj/item/weapon/shield/riot))
				if(prob(99))
					now_pushing = 0
					return
			if(tmob.l_hand && istype(tmob.l_hand, /obj/item/weapon/shield/riot))
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

	if(user.stat || user.restrained() || (usr.status_flags & FAKEDEATH))
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

	if(src.meat_taken < src.size)
		to_chat(user, "<span class='info'>You cut a chunk of meat out of \the [src].</span>")
		return

	to_chat(user, "<span class='info'>You butcher \the [src].</span>")
	can_butcher = 0

	if(istype(src, /mob/living/simple_animal)) //Animals can be butchered completely, humans - not so
		gib(meat = 0) //"meat" argument only exists for mob/living/simple_animal/gib()

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
