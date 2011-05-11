/obj/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.

var/list/spells = typesof(/obj/proc_holder/spell) //needed for the badmin verb for now

/obj/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell"
	density = 0
	opacity = 0

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions
	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/clothes_req = 1 //see if it requires clothes
	var/stat_allowed = 0 //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"

	var/overlay = 0
	var/overlay_icon = 'wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

/obj/proc_holder/spell/proc/cast_check(skipcharge = 0,mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(!(src in usr.spell_list))
		usr << "\red You shouldn't have this spell! Something's wrong."
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
		if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
			usr << "I don't feel strong enough without my robe."
			return 0
		if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
			usr << "I don't feel strong enough without my sandals."
			return 0
		if(!istype(usr:head, /obj/item/clothing/head/wizard))
			usr << "I don't feel strong enough without my hat."
			return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails

	return 1

/obj/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount

	switch(invocation_type)
		if("shout")
			usr.say(invocation)
			if(usr.gender=="male")
				playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
			else
				playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)
		if("whisper")
			usr.whisper(invocation)

/obj/proc_holder/spell/New()
	..()

	charge_counter = charge_max

/obj/proc_holder/spell/Click()
	..()

	if(!cast_check())
		return

	choose_targets()

/obj/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/proc_holder/spell/proc/start_recharge()
	while(charge_counter < charge_max)
		sleep(1)
		charge_counter++

/obj/proc_holder/spell/proc/perform(list/targets, recharge = 1) //if recharge is started is important for the trigger spells
	before_cast(targets)
	invocation()
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	cast(targets)
	after_cast(targets)

/obj/proc_holder/spell/proc/before_cast(list/targets)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(istype(target,/mob))
				location = target.loc
			else if(istype(target,/turf))
				location = target
			var/obj/overlay/spell = new /obj/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = 1
			spell.density = 0
			spawn(overlay_lifespan)
				del(spell)

/obj/proc_holder/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location
		if(istype(target,/mob))
			location = target.loc
		else if(istype(target,/turf))
			location = target
		if(istype(target,/mob) && message)
			target << text("[message]")
		if(sparks_spread)
			var/datum/effects/system/spark_spread/sparks = new /datum/effects/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effects/system/bad_smoke_spread/smoke = new /datum/effects/system/bad_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()

/obj/proc_holder/spell/proc/cast(list/targets)
	return

/obj/proc_holder/spell/proc/revert_cast() //resets recharge or readds a charge
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++

	return


/obj/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = 0 //if it includes usr in the target list

/obj/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(selection_type)
		if("range")
			switch(max_targets)
				if(0)
					for(var/mob/target in range(user,range))
						targets += target
				if(1)
					if(range < 0)
						targets += user
					else
						var/possible_targets = range(user,range)
						if(!include_user && user in possible_targets)
							possible_targets -= user
						targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				else
					var/list/possible_targets = list()
					for(var/mob/target in range(user,range))
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
		if("view")
			switch(max_targets)
				if(0)
					for(var/mob/target in view(user,range))
						targets += target
				if(1)
					if(range < 0)
						targets += user
					else
						var/possible_targets = view(user,range)
						if(!include_user && user in possible_targets)
							possible_targets -= user
						targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				else
					var/list/possible_targets = list()
					for(var/mob/target in view(usr,range))
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
		revert_cast()
		return

	perform(targets)

	return

/obj/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(selection_type)
		if("range")
			for(var/turf/target in range(user,range))
				if(!(target in range(user,inner_radius)))
					targets += target
		if("view")
			for(var/turf/target in view(user,range))
				if(!(target in view(user,inner_radius)))
					targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast()
		return

	perform(targets)

	return