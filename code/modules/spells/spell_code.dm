var/list/spells = typesof(/spell) //needed for the badmin verb for now

/spell
	var/name = "Spell"
	var/desc = "A spell"
	parent_type = /datum
	var/panel = "Spells"//What panel the proc holder needs to go on.

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = Sp_RECHARGE //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = Sp_RECHARGE or starting charges if charge_type = Sp_CHARGES
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = Sp_RECHARGE or -- each cast if charge_type = Sp_CHARGES
	var/still_recharging_msg = "<span class='notice'>The spell is still recharging.</span>"

	var/silenced = 0 //not a binary (though it seems that it is at the moment) - the length of time we can't cast this for, set by the spell_master silence_spells()

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/spell_flags = NEEDSCLOTHES
	//Possible spell flags:
	//GHOSTCAST to make ghosts be able to cast this
	//NEEDSCLOTHES to forbit guys without wizard garb from casting this
	//NEEDSHUMAN to forbid non-humans to cast this
	//Z2NOCAST to forbit casting this on z-level 2 (centcomm, and wizard spawn)
	//STATALLOWED to allow dead/unconscious guys (and ghosts) to cast this
	//IGNOREPREV to make each new target not overlap with the previous one
	//CONSTRUCT_CHECK used by construct spells - checks for nullrods
	//NO_BUTTON to prevent spell from showing up in the HUD
	//WAIT_FOR_CLICK to make the spell cast on the next target you click

	//For targeted spells:
		//INCLUDEUSER to include user in the target selection
		//SELECTABLE to allow selecting a target for the spell
	//For AOE spells:
		//IGNOREDENSE to ignore dense turfs in selection
		//IGNORESPACE to ignore space turfs in selection
	var/invocation = "HURP DURP"	//what is uttered when the wizard casts the spell
	var/invocation_type = SpI_NONE	//can be none, whisper, shout, and emote
	var/range = 7					//the range of the spell; outer radius for aoe spells
	var/message = ""				//whatever it says to the guy affected by it
	var/selection_type = "view"		//can be "range" or "view"
	var/atom/movable/holder			//where the spell is. Normally the user, can be an item
	var/duration = 0 //how long the spell lasts

	var/list/spell_levels = list(Sp_SPEED = 0, Sp_POWER = 0) //the current spell levels - total spell levels can be obtained by just adding the two values
	var/list/level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4, Sp_POWER = 0) //maximum possible levels in each category. Total does cover both.
	var/cooldown_reduc = 0		//If set, defines how much charge_max drops by every speed upgrade
	var/delay_reduc = 0
	var/cooldown_min = 0 //minimum possible cooldown for a charging spell

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0

	var/cast_delay = 1
	var/cast_sound = ""

	var/hud_state = "" //name of the icon used in generating the spell hud object
	var/override_base = ""

	var/obj/screen/spell/connected_button
	var/currently_channeled = 0

///////////////////////
///SETUP AND PROCESS///
///////////////////////

/spell/New()
	..()

	//still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	charge_counter = charge_max

/spell/proc/process()
	spawn while(charge_counter < charge_max)
		if(holder && !holder.timestopped)
			charge_counter++
		sleep(1)
	return

/////////////////
/////CASTING/////
/////////////////

/spell/proc/choose_targets(mob/user = usr) //depends on subtype - see targeted.dm, aoe_turf.dm, dumbfire.dm, or code in general folder
	return

/spell/proc/is_valid_target(var/target)
	if(!(spell_flags & INCLUDEUSER) && target == usr)
		return 0
	if(get_dist(usr, target) > range) //Shouldn't be necessary but a good check in case of overrides
		return 0
	return istype(target, /mob/living)

/spell/proc/perform(mob/user = usr, skipcharge = 0) //if recharge is started is important for the trigger spells
	if(!holder)
		holder = user //just in case
	if(spell_flags & WAIT_FOR_CLICK)
		channel_spell(user, skipcharge)
		return
	if(!cast_check(skipcharge, user))
		return
	if(cast_delay && !spell_do_after(user, cast_delay))
		return
	var/list/targets = choose_targets(user)
	if(!cast_check(skipcharge, user))
		return //Prevent queueing of spells by opening several choose target windows.
	if(targets && targets.len)
		invocation(user, targets)
		take_charge(user, skipcharge)

		before_cast(targets) //applies any overlays and effects
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>[user.real_name] ([user.ckey]) cast the spell [name].</font>")
		if(prob(critfailchance))
			critfail(targets, user)
		else
			cast(targets, user)
		after_cast(targets) //generates the sparks, smoke, target messages etc.

//This is used with the wait_for_click spell flag to prepare spells to be cast on your next click
/spell/proc/channel_spell(mob/user = usr, skipcharge = 0, force_remove = 0)
	if(!holder)
		holder = user //just in case
	if(!user.spell_channeling && !force_remove)
		if(!cast_check(skipcharge, user))
			return 0
		user.remove_spell_channeling() //In case we're swapping from an older spell to this new one
		user.spell_channeling = user.on_uattack.Add(src, "channeled_spell")
		connected_button.name = "(Ready) [name]"
		currently_channeled = 1
		connected_button.add_channeling()
	else
		var/event/E = user.on_uattack
		E.handlers.Remove(user.spell_channeling)
		user.spell_channeling = null
		charge_counter = charge_max
		currently_channeled = 0
		connected_button.name = name
		connected_button.remove_channeling()
	return 1

/spell/proc/channeled_spell(var/list/args)
	var/event/E = args["event"]
	if(!currently_channeled)
		E.handlers.Remove("\ref[src]:channeled_spell")
		return 0

	var/atom/A = args["atom"]

	if(E.holder != holder)
		E.handlers.Remove("\ref[src]:channeled_spell")
		return 0
	var/list/target = list(A)
	var/mob/user = holder
	user.attack_delayer.delayNext(0)
	if(cast_check(1, holder) && is_valid_target(A))
		before_cast(target)
		if(prob(critfailchance))
			critfail(target, holder)
		else
			. = cast(target, holder)
		after_cast(target)
		if(!.) //Returning 1 will prevent us from removing the channeling and taking charge
			channel_spell(force_remove = 1)
			take_charge(holder, 0)
		return 1
	return 0

/spell/proc/cast(list/targets, mob/user) //the actual meat of the spell
	return

/spell/proc/critfail(list/targets, mob/user) //the wizman has fucked up somehow
	return

/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("stunned")
			target.AdjustStunned(amount)
		if("weakened")
			target.AdjustWeakened(amount)
		if("paralysis")
			target.AdjustParalysis(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars
	return

///////////////////////////
/////CASTING WRAPPERS//////
///////////////////////////

/spell/proc/before_cast(list/targets)
	var/valid_targets[0]
	for(var/atom/target in targets)
		// Check range again (fixes long-range EI NATH)
		if(!(target in view_or_range(range,usr,selection_type)))
			continue

		valid_targets += target

		if(overlay)
			var/location
			if(istype(target,/mob/living))
				location = target.loc
			else if(istype(target,/turf))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = 1
			spell.density = 0
			spawn(overlay_lifespan)
				qdel(spell)
				spell = null
	return valid_targets

/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location = get_turf(target)
		if(istype(target,/mob/living) && message)
			to_chat(target, text("[message]"))
		if(sparks_spread)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/effect/system/smoke_spread/bad/smoke = new /datum/effect/effect/system/smoke_spread/bad()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/////////////////////
////CASTING TOOLS////
/////////////////////
/*Checkers, cost takers, message makers, etc*/

/spell/proc/cast_check(skipcharge = 0,mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell


	if(!(src in user.spell_list) && holder == user)
		to_chat(user, "<span class='warning'>You shouldn't have this spell! Something's wrong.</span>")
		return 0

	if(silenced > 0)
		return
	if(user.reagents && user.reagents.has_reagent("zombiepowder"))
		to_chat(user, "<span class='warning'>You just can't seem to focus enough to do this.</span>")
		return 0

	var/ourz = user.z
	if(!ourz)
		var/turf/T = get_turf(user)
		if(!T) return 0
		ourz = T.z
	if(map.zLevels.len < ourz || !ourz)
		WARNING("[user] is somehow on a zlevel [(ourz > map.zLevels.len) ? "higher" : "lower"] than our zlevels list! [map.zLevels.len] level\s, [map.nameLong] - [formatJumpTo(get_turf(user))]")
		return 0
	if(istype(map.zLevels[ourz], /datum/zLevel/centcomm) && spell_flags & Z2NOCAST) //Certain spells are not allowed on the centcomm zlevel
		return 0

	if(spell_flags & CONSTRUCT_CHECK)
		for(var/turf/T in range(holder, 1))
			if(findNullRod(T))
				return 0

	if(istype(user, /mob/living/simple_animal) && holder == user)
		var/mob/living/simple_animal/SA = user
		if(SA.purge)
			to_chat(SA, "<span class='warning'>The nullrod's power interferes with your own!</span>")
			return 0

	if(!src.check_charge(skipcharge, user)) //sees if we can cast based on charges alone
		return 0

	if(!(spell_flags & GHOSTCAST) && holder == user)
		if(user.stat && !(spell_flags & STATALLOWED))
			to_chat(usr, "Not when you're incapacitated.")
			return 0

		if(ishuman(user) || ismonkey(user) && !(invocation_type in list(SpI_EMOTE, SpI_NONE)))
			if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
				to_chat(user, "Mmmf mrrfff!")
				return 0

	var/spell/noclothes/spell = locate() in user.spell_list
	if((spell_flags & NEEDSCLOTHES) && !(spell && istype(spell)) && holder == user)//clothes check
		if(!user.wearing_wiz_garb())
			return 0

	return 1

/spell/proc/check_charge(var/skipcharge, mob/user)
	if(!skipcharge)
		switch(charge_type)
			if(Sp_RECHARGE)
				if(charge_counter < charge_max)
					to_chat(user, still_recharging_msg)
					return 0
			if(Sp_CHARGES)
				if(!charge_counter)
					to_chat(user, "<span class='notice'>[name] has no charges left.</span>")
					return 0
	return 1

/spell/proc/take_charge(mob/user = user, var/skipcharge)
	if(!skipcharge)
		switch(charge_type)
			if(Sp_RECHARGE)
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
				src.process()
				return 1
			if(Sp_CHARGES)
				charge_counter-- //returns the charge if the targets selecting fails
				return 1
			if(Sp_HOLDVAR)
				adjust_var(user, holder_var_type, holder_var_amount)
				return 1
		return 0
	return 1

/spell/proc/invocation(mob/user = usr, var/list/targets) //spelling the spell out and setting it on recharge/reducing charges amount


	switch(invocation_type)
		if(SpI_SHOUT)
			if(prob(50))//Auto-mute? Fuck that noise
				user.say(invocation)
			else
				user.say(replacetext(invocation," ","`"))
		if(SpI_WHISPER)
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ","`"))
		if(SpI_EMOTE)
			user.emote("me", 1, invocation) //the 1 means it's for everyone in view, the me makes it an emote, and the invocation is written accordingly.

/////////////////////
///UPGRADING PROCS///
/////////////////////

/spell/proc/can_improve(var/upgrade_type)
	if(level_max[Sp_TOTAL] <= ( spell_levels[Sp_SPEED] + spell_levels[Sp_POWER] )) //too many levels, can't do it
		return 0

	if(upgrade_type && (upgrade_type in spell_levels) && (upgrade_type in level_max))
		if(spell_levels[upgrade_type] >= level_max[upgrade_type])
			return 0

	return 1

/spell/proc/empower_spell()
	return

/spell/proc/quicken_spell()
	if(!can_improve(Sp_SPEED))
		return 0

	spell_levels[Sp_SPEED]++

	if(delay_reduc && cast_delay)
		cast_delay = max(0, cast_delay - delay_reduc)
	else if(cast_delay)
		cast_delay = round( max(0, initial(cast_delay) * ((level_max[Sp_SPEED] - spell_levels[Sp_SPEED]) / level_max[Sp_SPEED] ) ) )

	if(charge_type == Sp_RECHARGE)
		if(cooldown_reduc)
			charge_max = max(cooldown_min, charge_max - cooldown_reduc)
		else
			charge_max = round( max(cooldown_min, initial(charge_max) * ((level_max[Sp_SPEED] - spell_levels[Sp_SPEED]) / level_max[Sp_SPEED] ) ) ) //the fraction of the way you are to max speed levels is the fraction you lose
	if(charge_max < charge_counter)
		charge_counter = charge_max

	var/temp = ""
	name = initial(name)
	switch(level_max[Sp_SPEED] - spell_levels[Sp_SPEED])
		if(3)
			temp = "You have improved [name] into Efficient [name]."
			name = "Efficient [name]"
		if(2)
			temp = "You have improved [name] into Quickened [name]."
			name = "Quickened [name]"
		if(1)
			temp = "You have improved [name] into Free [name]."
			name = "Free [name]"
		if(0)
			temp = "You have improved [name] into Instant [name]."
			name = "Instant [name]"

	return temp

/spell/proc/spell_do_after(var/mob/user as mob, delay as num, var/numticks = 5)
	if(!user || isnull(user))
		return 0
	if(numticks == 0)
		return 1

	var/delayfraction = round(delay/numticks)
	var/Location = user.loc
	var/originalstat = user.stat

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)


		if(!user || (!(spell_flags & (STATALLOWED|GHOSTCAST)) && user.stat != originalstat)  || !(user.loc == Location))
			return 0
	return 1
