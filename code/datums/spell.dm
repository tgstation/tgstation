/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.

var/list/spells = typesof(/obj/effect/proc_holder/spell) //needed for the badmin verb for now

/obj/effect/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell"
	density = 0
	opacity = 0

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/clothes_req = 1 //see if it requires clothes
	var/stat_allowed = 0 //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0
	var/centcomm_cancast = 1 //Whether or not the spell should be allowed on z2

/obj/effect/proc_holder/spell/proc/cast_check(skipcharge = 0,mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(!(src in usr.spell_list))
		usr << "\red You shouldn't have this spell! Something's wrong."
		return 0

	if(usr.z == 2 && !centcomm_cancast) //Certain spells are not allowed on the centcomm zlevel
		return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				if(charge_counter < charge_max)
					usr << "[name] is still recharging."
					return 0
			if("charges")
				if(!charge_counter)
					usr << "[name] has no charges left."
					return 0

	if(usr.stat && !stat_allowed)
		usr << "Not when you're incapacitated."
		return 0

	if(clothes_req) //clothes check
		if(!istype(usr, /mob/living/carbon/human))
			usr << "You aren't a human, Why are you trying to cast a human spell, silly non-human? Casting human spells is for humans."
			return 0
		if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe) && !istype(user:wear_suit, /obj/item/clothing/suit/space/rig/wizard))
			usr << "I don't feel strong enough without my robe."
			return 0
		if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
			usr << "I don't feel strong enough without my sandals."
			return 0
		if(!istype(usr:head, /obj/item/clothing/head/wizard) && !istype(user:head, /obj/item/clothing/head/helmet/space/rig/wizard))
			usr << "I don't feel strong enough without my hat."
			return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails
			if("holdervar")
				adjust_var(user, holder_var_type, holder_var_amount)

	return 1

/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if("shout")
			if(prob(50))//Auto-mute? Fuck that noise
				usr.say(invocation)
			else
				usr.say(replacetext(invocation," ","`"))
			if(usr.gender==MALE)
				playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
			else
				playsound(usr.loc, pick('sound/misc/null.ogg','sound/misc/null.ogg'), 100, 1)
		if("whisper")
			if(prob(50))
				usr.whisper(invocation)
			else
				usr.whisper(replacetext(invocation," ","`"))

/obj/effect/proc_holder/spell/New()
	..()

	charge_counter = charge_max

/obj/effect/proc_holder/spell/Click()
	..()

	if(!cast_check())
		return

	choose_targets()

/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/effect/proc_holder/spell/proc/start_recharge()
	while(charge_counter < charge_max)
		sleep(1)
		charge_counter++

/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = 1) //if recharge is started is important for the trigger spells
	before_cast(targets)
	invocation()
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	if(prob(critfailchance))
		critfail(targets)
	else
		cast(targets)
	after_cast(targets)

/obj/effect/proc_holder/spell/proc/before_cast(list/targets)
	if(overlay)
		for(var/atom/target in targets)
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
				del(spell)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location
		if(istype(target,/mob/living))
			location = target.loc
		else if(istype(target,/turf))
			location = target
		if(istype(target,/mob/living) && message)
			target << text("[message]")
		if(sparks_spread)
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/effect/system/harmless_smoke_spread/smoke = new /datum/effect/effect/system/harmless_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/effect/system/bad_smoke_spread/smoke = new /datum/effect/effect/system/bad_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/obj/effect/proc_holder/spell/proc/cast(list/targets)
	return

/obj/effect/proc_holder/spell/proc/critfail(list/targets)
	return

/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //resets recharge or readds a charge
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++
		if("holdervar")
			adjust_var(user, holder_var_type, -holder_var_amount)

	return

/obj/effect/proc_holder/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
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

/obj/effect/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = 0 //if it includes usr in the target list

/obj/effect/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/effect/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				targets += target
		if(1) //single target can be picked
			if(range < 0)
				targets += user
			else
				var/possible_targets = list()

				for(var/mob/living/M in view_or_range(range, user, selection_type))
					if(!include_user && user == M)
						continue
					possible_targets += M

				targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
		else
			var/list/possible_targets = list()
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				possible_targets += target
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!include_user && (user in targets))
		targets -= user

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets)

	return

/obj/effect/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		if(!(target in view_or_range(inner_radius,user,selection_type)))
			targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast()
		return

	perform(targets)

	return