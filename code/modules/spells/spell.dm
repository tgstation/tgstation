#define TARGET_CLOSEST 1
#define TARGET_RANDOM 2


/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.
	var/active = FALSE //Used by toggle based abilities.
	var/ranged_mousepointer
	var/mob/living/ranged_ability_user
	var/ranged_clickcd_override = -1

GLOBAL_LIST_INIT(spells, typesof(/obj/effect/proc_holder/spell)) //needed for the badmin verb for now

/obj/effect/proc_holder/Destroy()
	if(ranged_ability_user)
		remove_ranged_ability()
	return ..()

/obj/effect/proc_holder/proc/InterceptClickOn(mob/living/caller, params, atom/A)
	if(caller.ranged_ability != src || ranged_ability_user != caller) //I'm not actually sure how these would trigger, but, uh, safety, I guess?
		to_chat(caller, "<span class='warning'><b>[caller.ranged_ability.name]</b> has been disabled.")
		caller.ranged_ability.remove_ranged_ability()
		return TRUE //TRUE for failed, FALSE for passed.
	if(ranged_clickcd_override >= 0)
		ranged_ability_user.next_click = world.time + ranged_clickcd_override
	else
		ranged_ability_user.next_click = world.time + CLICK_CD_CLICK_ABILITY
	ranged_ability_user.face_atom(A)
	return FALSE

/obj/effect/proc_holder/proc/add_ranged_ability(mob/living/user, msg, forced)
	if(!user || !user.client)
		return
	if(user.ranged_ability && user.ranged_ability != src)
		if(forced)
			to_chat(user, "<span class='warning'><b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>.")
			user.ranged_ability.remove_ranged_ability()
		else
			return
	user.ranged_ability = src
	user.client.click_intercept = user.ranged_ability
	add_mousepointer(user.client)
	ranged_ability_user = user
	if(msg)
		to_chat(ranged_ability_user, msg)
	active = TRUE
	update_icon()

/obj/effect/proc_holder/proc/add_mousepointer(client/C)
	if(C && ranged_mousepointer && C.mouse_pointer_icon == initial(C.mouse_pointer_icon))
		C.mouse_pointer_icon = ranged_mousepointer

/obj/effect/proc_holder/proc/remove_mousepointer(client/C)
	if(C && ranged_mousepointer && C.mouse_pointer_icon == ranged_mousepointer)
		C.mouse_pointer_icon = initial(C.mouse_pointer_icon)

/obj/effect/proc_holder/proc/remove_ranged_ability(msg)
	if(!ranged_ability_user || !ranged_ability_user.client || (ranged_ability_user.ranged_ability && ranged_ability_user.ranged_ability != src)) //To avoid removing the wrong ability
		return
	ranged_ability_user.ranged_ability = null
	ranged_ability_user.client.click_intercept = null
	remove_mousepointer(ranged_ability_user.client)
	if(msg)
		to_chat(ranged_ability_user, msg)
	ranged_ability_user = null
	active = FALSE
	update_icon()

/obj/effect/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell"
	panel = "Spells"
	var/sound = null //The sound the spell makes when it is cast
	anchored = TRUE // Crap like fireball projectiles are proc_holders, this is needed so fireballs don't get blown back into your face via atmos etc.
	pass_flags = PASSTABLE
	density = FALSE
	opacity = 0

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/still_recharging_msg = "<span class='notice'>The spell is still recharging.</span>"
	var/recharging = TRUE

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/clothes_req = 1 //see if it requires clothes
	var/cult_req = 0 //SPECIAL SNOWFLAKE clothes required for cult only spells
	var/human_req = 0 //spell can only be cast by humans
	var/nonabstract_req = 0 //spell can only be cast by mobs that are physical entities
	var/stat_allowed = 0 //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/phase_allowed = 0 // If true, the spell can be cast while phased, eg. blood crawling, ethereal jaunting
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_emote_self = null
	var/invocation_type = "none" //can be none, whisper, emote and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"
	var/spell_level = 0 //if a spell can be taken multiple times, this raises
	var/level_max = 4 //The max possible level_max is 4
	var/cooldown_min = 0 //This defines what spell quickened four times has as a cooldown. Make sure to set this for every spell
	var/player_lock = 1 //If it can be used by simple mobs

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0
	var/centcom_cancast = 1 //Whether or not the spell should be allowed on z2

	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_spell"
	var/datum/action/spell_action/action

/obj/effect/proc_holder/spell/proc/cast_check(skipcharge = 0,mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell

	if(player_lock)
		if(!user.mind || !(src in user.mind.spell_list) && !(src in user.mob_spell_list))
			to_chat(user, "<span class='warning'>You shouldn't have this spell! Something's wrong.</span>")
			return 0
	else
		if(!(src in user.mob_spell_list))
			return 0

	var/turf/T = get_turf(user)
	if(T.z == ZLEVEL_CENTCOM && !centcom_cancast) //Certain spells are not allowed on the centcom zlevel
		to_chat(user, "<span class='notice'>You can't cast this spell here.</span>")
		return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				if(charge_counter < charge_max)
					to_chat(user, still_recharging_msg)
					return 0
			if("charges")
				if(!charge_counter)
					to_chat(user, "<span class='notice'>[name] has no charges left.</span>")
					return 0

	if(user.stat && !stat_allowed)
		to_chat(user, "<span class='notice'>Not when you're incapacitated.</span>")
		return 0

	if(!phase_allowed && istype(user.loc, /obj/effect/dummy))
		to_chat(user, "<span class='notice'>[name] cannot be cast unless you are completely manifested in the material plane.</span>")
		return 0

	if(ishuman(user))

		var/mob/living/carbon/human/H = user

		if((invocation_type == "whisper" || invocation_type == "shout") && H.is_muzzled())
			to_chat(user, "<span class='notice'>You can't get the words out!</span>")
			return 0

		var/list/casting_clothes = typecacheof(list(/obj/item/clothing/suit/wizrobe,
		/obj/item/clothing/suit/space/hardsuit/wizard,
		/obj/item/clothing/head/wizard,
		/obj/item/clothing/head/helmet/space/hardsuit/wizard,
		/obj/item/clothing/suit/space/hardsuit/shielded/wizard,
		/obj/item/clothing/head/helmet/space/hardsuit/shielded/wizard))

		if(clothes_req) //clothes check
			if(!is_type_in_typecache(H.wear_suit, casting_clothes))
				to_chat(H, "<span class='notice'>I don't feel strong enough without my robe.</span>")
				return 0
			if(!is_type_in_typecache(H.head, casting_clothes))
				to_chat(H, "<span class='notice'>I don't feel strong enough without my hat.</span>")
				return 0
		if(cult_req) //CULT_REQ CLOTHES CHECK
			if(!istype(H.wear_suit, /obj/item/clothing/suit/magusred) && !istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/cult))
				to_chat(H, "<span class='notice'>I don't feel strong enough without my armor.</span>")
				return 0
			if(!istype(H.head, /obj/item/clothing/head/magus) && !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/cult))
				to_chat(H, "<span class='notice'>I don't feel strong enough without my helmet.</span>")
				return 0
	else
		if(clothes_req || human_req)
			to_chat(user, "<span class='notice'>This spell can only be cast by humans!</span>")
			return 0
		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			to_chat(user, "<span class='notice'>This spell can only be cast by physical beings!</span>")
			return 0


	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails
			if("holdervar")
				adjust_var(user, holder_var_type, holder_var_amount)
	if(action)
		action.UpdateButtonIcon()
	return 1

/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount
	switch(invocation_type)
		if("shout")
			if(prob(50))//Auto-mute? Fuck that noise
				user.say(invocation)
			else
				user.say(replacetext(invocation," ","`"))
		if("whisper")
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ","`"))
		if("emote")
			user.visible_message(invocation, invocation_emote_self) //same style as in mob/living/emote.dm

/obj/effect/proc_holder/spell/proc/playMagSound()
	playsound(get_turf(usr), sound,50,1)

/obj/effect/proc_holder/spell/Initialize()
	. = ..()
	action = new(src)
	START_PROCESSING(SSfastprocess, src)

	still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	charge_counter = charge_max

/obj/effect/proc_holder/spell/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	qdel(action)
	return ..()

/obj/effect/proc_holder/spell/Click()
	if(cast_check())
		choose_targets()
	return 1

/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/effect/proc_holder/spell/proc/can_target(mob/living/target)
	return TRUE

/obj/effect/proc_holder/spell/proc/start_recharge()
	recharging = TRUE

/obj/effect/proc_holder/spell/process()
	if(recharging && charge_type == "recharge" && (charge_counter < charge_max))
		charge_counter += 2	//processes 5 times per second instead of 10.
		if(charge_counter >= charge_max)
			action.UpdateButtonIcon()
			charge_counter = charge_max
			recharging = FALSE

/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = TRUE, mob/user = usr) //if recharge is started is important for the trigger spells
	before_cast(targets)
	invocation(user)
	if(user && user.ckey)
		user.log_message("<span class='danger'>cast the spell [name].</span>", INDIVIDUAL_ATTACK_LOG)
	if(recharge)
		recharging = TRUE
	if(sound)
		playMagSound()
	if(prob(critfailchance))
		critfail(targets)
	else
		cast(targets,user=user)
	after_cast(targets)
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/before_cast(list/targets)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(isliving(target))
				location = target.loc
			else if(isturf(target))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = TRUE
			spell.density = FALSE
			QDEL_IN(spell, overlay_lifespan)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location
		if(isliving(target))
			location = target.loc
		else if(isturf(target))
			location = target
		if(isliving(target) && message)
			to_chat(target, text("[message]"))
		if(sparks_spread)
			do_sparks(sparks_amt, FALSE, location)
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect_system/smoke_spread/smoke = new
				smoke.set_up(smoke_amt, location)
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect_system/smoke_spread/bad/smoke = new
				smoke.set_up(smoke_amt, location)
				smoke.start()
			else if(smoke_spread == 3)
				var/datum/effect_system/smoke_spread/sleeping/smoke = new
				smoke.set_up(smoke_amt, location)
				smoke.start()


/obj/effect/proc_holder/spell/proc/cast(list/targets,mob/user = usr)
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
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	if (!istype(target))
		return
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("stun")
			target.AdjustStun(amount)
		if("knockdown")
			target.AdjustKnockdown(amount)
		if("unconscious")
			target.AdjustUnconscious(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars

/obj/effect/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = 0 //if it includes usr in the target list
	var/random_target = 0 // chooses random viable target instead of asking the caster
	var/random_target_priority = TARGET_CLOSEST // if random_target is enabled how it will pick the target


/obj/effect/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/effect/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				if(!can_target(target))
					continue
				targets += target
		if(1) //single target can be picked
			if(range < 0)
				targets += user
			else
				var/possible_targets = list()

				for(var/mob/living/M in view_or_range(range, user, selection_type))
					if(!include_user && user == M)
						continue
					if(!can_target(M))
						continue
					possible_targets += M

				//targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				//Adds a safety check post-input to make sure those targets are actually in range.
				var/mob/M
				if(!random_target)
					M = input("Choose the target for the spell.", "Targeting") as null|mob in possible_targets
				else
					switch(random_target_priority)
						if(TARGET_RANDOM)
							M = pick(possible_targets)
						if(TARGET_CLOSEST)
							for(var/mob/living/L in possible_targets)
								if(M)
									if(get_dist(user,L) < get_dist(user,M))
										if(los_check(user,L))
											M = L
								else
									if(los_check(user,L))
										M = L
				if(M in view_or_range(range, user, selection_type)) targets += M

		else
			var/list/possible_targets = list()
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				if(!can_target(target))
					continue
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

	perform(targets,user=user)

/obj/effect/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		if(!can_target(target))
			continue
		if(!(target in view_or_range(inner_radius,user,selection_type)))
			targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast()
		return

	perform(targets,user=user)

/obj/effect/proc_holder/spell/proc/updateButtonIcon()
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/can_be_cast_by(mob/caster)
	if((human_req || clothes_req) && !ishuman(caster))
		return 0
	return 1

/obj/effect/proc_holder/spell/targeted/proc/los_check(mob/A,mob/B)
	//Checks for obstacles from A to B
	var/obj/dummy = new(A.loc)
	dummy.pass_flags |= PASSTABLE
	for(var/turf/turf in getline(A,B))
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/effect/proc_holder/spell/proc/can_cast(mob/user = usr)
	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.mob_spell_list))
		return 0

	switch(charge_type)
		if("recharge")
			if(charge_counter < charge_max)
				return 0
		if("charges")
			if(!charge_counter)
				return 0

	if(user.stat && !stat_allowed)
		return 0

	if(!ishuman(user))
		if(clothes_req || human_req)
			return 0
		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			return 0
	return 1

/obj/effect/proc_holder/spell/self //Targets only the caster. Good for buffs and heals, but probably not wise for fireballs (although they usually fireball themselves anyway, honke)
	range = -1 //Duh

/obj/effect/proc_holder/spell/self/choose_targets(mob/user = usr)
	if(!user)
		revert_cast()
		return
	perform(null,user=user)

/obj/effect/proc_holder/spell/self/basic_heal //This spell exists mainly for debugging purposes, and also to show how casting works
	name = "Lesser Heal"
	desc = "Heals a small amount of brute and burn damage."
	human_req = 1
	clothes_req = 0
	charge_max = 100
	cooldown_min = 50
	invocation = "Victus sano!"
	invocation_type = "whisper"
	school = "restoration"
	sound = 'sound/magic/staff_healing.ogg'

/obj/effect/proc_holder/spell/self/basic_heal/cast(mob/living/carbon/human/user) //Note the lack of "list/targets" here. Instead, use a "user" var depending on mob requirements.
	//Also, notice the lack of a "for()" statement that looks through the targets. This is, again, because the spell can only have a single target.
	user.visible_message("<span class='warning'>A wreath of gentle light passes over [user]!</span>", "<span class='notice'>You wreath yourself in healing light!</span>")
	user.adjustBruteLoss(-10)
	user.adjustFireLoss(-10)
