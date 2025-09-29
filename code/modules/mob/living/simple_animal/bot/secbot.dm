/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot. He looks less than thrilled."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "secbot"
	light_color = "#f56275"
	light_power = 0.8
	gender = MALE
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB | PASSFLAPS
	combat_mode = TRUE
	can_buckle_to = FALSE

	req_one_access = list(ACCESS_SECURITY)
	radio_key = /obj/item/encryptionkey/secbot //AI Priv + Security
	radio_channel = RADIO_CHANNEL_SECURITY //Security channel
	bot_type = SEC_BOT
	bot_mode_flags = ~BOT_MODE_CAN_BE_SAPIENT
	data_hud_type = DATA_HUD_SECURITY_ADVANCED
	hackables = "target identification systems"
	path_image_color = COLOR_RED
	possessed_message = "You are a securitron! Guard the station to the best of your ability!"

	automated_announcements = list(
		BEEPSKY_VOICED_CRIMINAL_DETECTED = 'sound/mobs/non-humanoids/beepsky/criminal.ogg',
		BEEPSKY_VOICED_FREEZE = 'sound/mobs/non-humanoids/beepsky/freeze.ogg',
		BEEPSKY_VOICED_JUSTICE = 'sound/mobs/non-humanoids/beepsky/justice.ogg',
		BEEPSKY_VOICED_YOUR_MOVE = 'sound/mobs/non-humanoids/beepsky/creep.ogg',
		BEEPSKY_VOICED_I_AM_THE_LAW = 'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
		BEEPSKY_VOICED_SECURE_DAY = 'sound/mobs/non-humanoids/beepsky/secureday.ogg',
	)

	///Whether this secbot is considered 'commissioned' and given the trait on Initialize.
	var/commissioned = FALSE
	///The type of baton this Secbot will use
	var/baton_type = /obj/item/melee/baton/security
	///The type of cuffs we use on criminals after making arrests
	var/cuff_type = /obj/item/restraints/handcuffs/cable/zipties/used
	///The weapon (from baton_type) that will be used to make arrests.
	var/obj/item/weapon
	///Their current target
	var/mob/living/carbon/target
	///Name of their last target to prevent spamming
	var/oldtarget_name
	///The threat level of the BOT, will arrest anyone at threatlevel 4 or above
	var/threatlevel = 0
	///The last location their target was seen at
	var/target_lastloc
	///Time since last seeing their perpetrator
	var/last_found

	///Flags SecBOTs use on what to check on targets when arresting, and whether they should announce it to security/handcuff their target
	var/security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET
//	Selections: SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_WEAPONS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET

	///On arrest, charges the violator this much. If they don't have that much in their account, they will get beaten instead
	var/fair_market_price_arrest = 25
	///Charged each time the violator is stunned on detain
	var/fair_market_price_detain = 5
	///Force of the harmbaton used on them
	var/weapon_force = 20
	///The department the secbot will deposit collected money into
	var/payment_department = ACCOUNT_SEC

/mob/living/simple_animal/bot/secbot/beepsky
	name = "Commander Beep O'sky"
	desc = "It's Commander Beep O'sky! Officially the superior officer of all bots on station, Beepsky remains as humble and dedicated to the law as the day he was first fabricated."
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED
	commissioned = TRUE


/mob/living/simple_animal/bot/secbot/beepsky/officer
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey, and with a sturdier reinforced chassis, too."
	health = 45

/mob/living/simple_animal/bot/secbot/beepsky/officer/Initialize(mapload)
	. = ..()
	// Beepsky hates people scanning them
	RegisterSignal(src, COMSIG_MOVABLE_SPY_STEALING, PROC_REF(retaliate_async))

/mob/living/simple_animal/bot/secbot/beepsky/ofitser
	name = "Prison Ofitser"
	desc = "Powered by the tears and sweat of laborers."
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)

/mob/living/simple_animal/bot/secbot/beepsky/armsky
	name = "Sergeant-At-Armsky"
	desc = "It's Sergeant-At-Armsky! He's a disgruntled assistant to the warden that would probably shoot you if he had hands."
	health = 45
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS | SECBOT_CHECK_WEAPONS

/mob/living/simple_animal/bot/secbot/beepsky/jr
	name = "Officer Pipsqueak"
	desc = "It's Commander Beep O'sky's smaller, just-as aggressive cousin, Pipsqueak."
	commissioned = FALSE

/mob/living/simple_animal/bot/secbot/beepsky/jr/Initialize(mapload)
	. = ..()
	update_transform(0.8)

/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	light_color = "#62baf5"
	radio_channel = RADIO_CHANNEL_AI_PRIVATE
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS

/mob/living/simple_animal/bot/secbot/genesky
	name = "Officer Genesky"
	desc = "A beefy variant of the standard securitron model."
	health = 50
	faction = list(FACTION_NANOTRASEN_PRIVATE)
	bot_mode_flags = BOT_MODE_ON
	bot_cover_flags = BOT_COVER_LOCKED | BOT_COVER_EMAGGED

/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/atom/Tsec = drop_location()
	new /obj/item/stock_parts/power_store/cell/potato(Tsec)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/drinking_oil = new(Tsec)
	drinking_oil.reagents.add_reagent(/datum/reagent/consumable/ethanol/whiskey, 15)
	return ..()

/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	weapon = new baton_type()
	update_appearance(UPDATE_ICON)
	if(commissioned)
		ADD_TRAIT(src, TRAIT_COMMISSIONED, INNATE_TRAIT)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/id_trim/job/det_trim = SSid_access.trim_singletons_by_path[/datum/id_trim/job/detective]
	access_card.add_access(det_trim.access + det_trim.wildcard_access)
	prev_access = access_card.access.Copy()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/security_vision, judgement_criteria = NONE, update_judgement_criteria = CALLBACK(src, PROC_REF(judgement_criteria)))

/mob/living/simple_animal/bot/secbot/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/simple_animal/bot/secbot/update_icon_state()
	if(mode == BOT_HUNT)
		icon_state = "[initial(icon_state)]-c"
		return
	return ..()

/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	mode = BOT_IDLE

/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	set_anchored(FALSE)
	GLOB.move_manager.stop_looping(src)
	last_found = world.time

/mob/living/simple_animal/bot/secbot/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!(security_mode_flags & SECBOT_SABOTEUR_AFFECTED))
		security_mode_flags |= SECBOT_SABOTEUR_AFFECTED
		addtimer(CALLBACK(src, PROC_REF(remove_saboteur_effect)), disrupt_duration)
		return TRUE

/mob/living/simple_animal/bot/secbot/proc/remove_saboteur_effect()
	security_mode_flags &= ~SECBOT_SABOTEUR_AFFECTED

/mob/living/simple_animal/bot/secbot/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)//shocks only make him angry
	if(base_speed < initial(base_speed) + 3)
		base_speed += 3
		addtimer(VARSET_CALLBACK(src, base_speed, base_speed - 3), 6 SECONDS)
		playsound(src, 'sound/machines/defib/defib_zap.ogg', 50)
		visible_message(span_warning("[src] shakes and speeds up!"))

/mob/living/simple_animal/bot/secbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == weapon)
		weapon = null
		update_appearance()

// Variables sent to TGUI
/mob/living/simple_animal/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || HAS_SILICON_ACCESS(user))
		data["custom_controls"]["check_id"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_weapons"] = security_mode_flags & SECBOT_CHECK_WEAPONS
		data["custom_controls"]["check_warrants"] = security_mode_flags & SECBOT_CHECK_RECORDS
		data["custom_controls"]["handcuff_targets"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["arrest_alert"] = security_mode_flags & SECBOT_DECLARE_ARRESTS
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/secbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !HAS_SILICON_ACCESS(user)))
		return

	switch(action)
		if("check_id")
			security_mode_flags ^= SECBOT_CHECK_IDS
		if("check_weapons")
			security_mode_flags ^= SECBOT_CHECK_WEAPONS
		if("check_warrants")
			security_mode_flags ^= SECBOT_CHECK_RECORDS
		if("handcuff_targets")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
		if("arrest_alert")
			security_mode_flags ^= SECBOT_DECLARE_ARRESTS

/mob/living/simple_animal/bot/secbot/proc/retaliate_async(datum/source, mob/user, ...)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(retaliate), user)

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/attacking_human)
	var/judgement_criteria = judgement_criteria()
	threatlevel = attacking_human.assess_threat(judgement_criteria)
	threatlevel += 6
	if(threatlevel >= THREAT_ASSESS_DANGEROUS)
		target = attacking_human
		mode = BOT_HUNT
	if(threatlevel < 0 && prob(5))
		manual_emote("salutes.")
		speak("Thank you sir.")

/mob/living/simple_animal/bot/secbot/proc/judgement_criteria()
	var/final = FALSE
	if(bot_cover_flags & BOT_COVER_EMAGGED)
		final |= JUDGE_EMAGGED
	if(security_mode_flags & SECBOT_CHECK_IDS)
		final |= JUDGE_IDCHECK
	if(security_mode_flags & SECBOT_CHECK_RECORDS)
		final |= JUDGE_RECORDCHECK
	if(security_mode_flags & SECBOT_CHECK_WEAPONS)
		final |= JUDGE_WEAPONCHECK
	if(security_mode_flags & SECBOT_SABOTEUR_AFFECTED)
		final |= JUDGE_CHILLOUT
	return final

/mob/living/simple_animal/bot/secbot/proc/special_retaliate_after_attack(mob/user) //allows special actions to take place after being attacked.
	return

/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.combat_mode)
		retaliate(user)
		if(special_retaliate_after_attack(user))
			return

		// Turns an oversight into a feature. Beepsky will now announce when pacifists taunt him over sec comms.
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			user.visible_message(span_notice("[user] taunts [src], daring [p_them()] to give chase!"), \
				span_notice("You taunt [src], daring [p_them()] to chase you!"), span_hear("You hear someone shout a daring taunt!"), DEFAULT_MESSAGE_RANGE, user)
			speak("Taunted by pacifist scumbag [RUNECHAT_BOLD("[user]")] in [get_area(src)].", radio_channel)

			// Interrupt the attack chain. We've already handled this scenario for pacifists.
			return

	return ..()

/mob/living/simple_animal/bot/secbot/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	..()
	if(!(bot_mode_flags & BOT_MODE_ON)) // Bots won't remember if you hit them while they're off.
		return
	if(attacking_item.tool_behaviour == TOOL_WELDER && !user.combat_mode) // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(attacking_item.tool_behaviour != TOOL_SCREWDRIVER && (attacking_item.force) && (!target) && (attacking_item.damtype != STAMINA)) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		retaliate(user)
		special_retaliate_after_attack(user)

/mob/living/simple_animal/bot/secbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		balloon_alert(user, "target assessment circuits shorted")
		oldtarget_name = user.name

	if(bot_type == HONK_BOT)
		audible_message(span_danger("[src] gives out an evil laugh!"))
		playsound(src, 'sound/mobs/non-humanoids/honkbot/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter
	else
		audible_message(span_danger("[src] buzzes oddly!"))

	security_mode_flags &= ~SECBOT_DECLARE_ARRESTS
	update_appearance()
	return TRUE

/mob/living/simple_animal/bot/secbot/bullet_act(obj/projectile/proj)
	. = ..()
	if(. != BULLET_ACT_HIT)
		return

	if(istype(proj, /obj/projectile/beam) || istype(proj, /obj/projectile/bullet))
		if((proj.damage_type == BURN) || (proj.damage_type == BRUTE))
			if(proj.is_hostile_projectile() && proj.damage < src.health && ishuman(proj.firer))
				retaliate(proj.firer)

/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(!can_unarmed_attack())
		return
	if(!iscarbon(attack_target))
		return ..()
	var/mob/living/carbon/carbon_target = attack_target
	if(!carbon_target.IsParalyzed() || !(security_mode_flags & SECBOT_HANDCUFF_TARGET))
		if(!check_nap_violations())
			stun_attack(attack_target, TRUE)
		else
			stun_attack(attack_target)
	else if(carbon_target.canBeHandcuffed() && !carbon_target.handcuffed)
		start_handcuffing(attack_target)

/mob/living/simple_animal/bot/secbot/hitby(atom/movable/hitting_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(hitting_atom))
		var/obj/item/item_hitby = hitting_atom
		var/mob/thrown_by = throwingdatum?.get_thrower()
		if(item_hitby.throwforce < src.health && thrown_by && ishuman(thrown_by))
			var/mob/living/carbon/human/human_throwee = thrown_by
			retaliate(human_throwee)
	..()

/mob/living/simple_animal/bot/secbot/proc/start_handcuffing(mob/living/carbon/current_target)
	mode = BOT_ARREST
	playsound(src, 'sound/items/weapons/cablecuff.ogg', 30, TRUE, -2)
	current_target.visible_message(span_danger("[src] is trying to put zipties on [current_target]!"),\
						span_userdanger("[src] is trying to put zipties on you!"))
	addtimer(CALLBACK(src, PROC_REF(handcuff_target), current_target), 6 SECONDS)

/mob/living/simple_animal/bot/secbot/proc/handcuff_target(mob/living/carbon/current_target)
	if(!(bot_mode_flags & BOT_MODE_ON)) //if he's in a closet or not adjacent, we cancel cuffing.
		return FALSE
	if(!isturf(current_target.loc))
		return FALSE
	if(!Adjacent(current_target))
		return FALSE
	if(!current_target.handcuffed)
		current_target.set_handcuffed(new cuff_type(current_target))
		playsound(src, SFX_LAW, 50, FALSE)
		back_to_idle()

/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/current_target, harm = FALSE)
	var/judgement_criteria = judgement_criteria()
	playsound(src, 'sound/items/weapons/egloves.ogg', 50, TRUE, -1)
	icon_state = "[initial(icon_state)]-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_appearance)), 0.2 SECONDS)
	var/threat = 5

	if(harm)
		weapon.attack(current_target, src)
	if(ishuman(current_target))
		current_target.set_stutter(10 SECONDS)
		current_target.Paralyze(100)
		var/mob/living/carbon/human/human_target = current_target
		threat = human_target.assess_threat(judgement_criteria)
	else
		current_target.Paralyze(100)
		current_target.set_stutter(10 SECONDS)
		threat = current_target.assess_threat(judgement_criteria)

	log_combat(src, current_target, "stunned")
	if(security_mode_flags & SECBOT_DECLARE_ARRESTS)
		var/area/location = get_area(src)
		speak("[security_mode_flags & SECBOT_HANDCUFF_TARGET ? "Arresting" : "Detaining"] level [threat] scumbag [RUNECHAT_BOLD("[current_target]")] in [location].", radio_channel)
	current_target.visible_message(span_danger("[src] stuns [current_target]!"),\
							span_userdanger("[src] stuns you!"))

	target_lastloc = current_target.loc
	mode = BOT_PREP_ARREST

/mob/living/simple_animal/bot/secbot/handle_automated_action()
	. = ..()
	if(!.)
		return

	switch(mode)

		if(BOT_IDLE) // idle
			GLOB.move_manager.stop_looping(src)
			look_for_perp() // see if any criminals are in range
			if((mode == BOT_IDLE) && bot_mode_flags & BOT_MODE_AUTOPATROL) // didn't start hunting during look_for_perp, and set to patrol
				mode = BOT_START_PATROL // switch to patrol mode

		if(BOT_HUNT) // hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				GLOB.move_manager.stop_looping(src)
				back_to_idle()
				return

			if(!target) // make sure target exists
				back_to_idle()
				return
			if(Adjacent(target) && isturf(target.loc)) // if right next to perp
				if(!check_nap_violations())
					stun_attack(target, TRUE)
				else
					stun_attack(target)

				set_anchored(TRUE)
				return

			// not next to perp
			var/turf/olddist = get_dist(src, target)
			GLOB.move_manager.move_to(src, target, 1, 4)
			if((get_dist(src, target)) >= (olddist))
				frustration++
			else
				frustration = 0

		if(BOT_PREP_ARREST) // preparing to arrest target
			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if(!Adjacent(target) || !isturf(target.loc) || !HAS_TRAIT(target, TRAIT_FLOORED))
				back_to_hunt()
				return

			if(!iscarbon(target) || !target.canBeHandcuffed())
				back_to_idle()
				return

			if(security_mode_flags & SECBOT_HANDCUFF_TARGET)
				if(!target.handcuffed) //he's not cuffed? Try to cuff him!
					start_handcuffing(target)
				else
					back_to_idle()
					return

		if(BOT_ARREST)
			if(!target)
				set_anchored(FALSE)
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				if(!check_nap_violations())
					stun_attack(target, TRUE)
					return
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && !HAS_TRAIT(target, TRAIT_FLOORED))) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				set_anchored(FALSE)

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()

/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	set_anchored(FALSE)
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))

/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	set_anchored(FALSE)
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
// look for a criminal in view of the bot

/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
	set_anchored(FALSE)
	var/judgement_criteria = judgement_criteria()
	for(var/mob/living/carbon/nearby_carbons in view(7, src)) //Let's find us a criminal
		if((nearby_carbons.stat) || (nearby_carbons.handcuffed))
			continue

		if((nearby_carbons.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = nearby_carbons.assess_threat(judgement_criteria)

		if(threatlevel < THREAT_ASSESS_DANGEROUS)
			continue

		target = nearby_carbons
		oldtarget_name = nearby_carbons.name
		threat_react(threatlevel)
		visible_message("<b>[src]</b> points at [nearby_carbons.name]!")
		mode = BOT_HUNT
		INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
		break

/// React to detecting criminal scum by making some kind of noise
/mob/living/simple_animal/bot/secbot/proc/threat_react(threatlevel)
	speak("Level [threatlevel] infraction alert!")
	playsound(src, pick(
		'sound/mobs/non-humanoids/beepsky/criminal.ogg',
		'sound/mobs/non-humanoids/beepsky/justice.ogg',
		'sound/mobs/non-humanoids/beepsky/freeze.ogg',
		), 50, FALSE)

/mob/living/simple_animal/bot/secbot/explode()
	var/atom/Tsec = drop_location()
	switch(bot_type)
		if(ADVANCED_SEC_BOT)
			var/obj/item/bot_assembly/ed209/ed_assembly = new(Tsec)
			ed_assembly.build_step = ASSEMBLY_FIRST_STEP
			ed_assembly.add_overlay("hs_hole")
			ed_assembly.created_name = name
			new /obj/item/assembly/prox_sensor(Tsec)
			var/obj/item/gun/energy/disabler/disabler_gun = new(Tsec)
			disabler_gun.cell.charge = 0
			disabler_gun.update_appearance()
			if(prob(50))
				new /obj/item/bodypart/leg/left/robot(Tsec)
				if(prob(25))
					new /obj/item/bodypart/leg/right/robot(Tsec)
			if(prob(25))//50% chance for a helmet OR vest
				if(prob(50))
					new /obj/item/clothing/head/helmet(Tsec)
				else
					new /obj/item/clothing/suit/armor/vest(Tsec)
		if(HONK_BOT)
			var/obj/item/bot_assembly/honkbot/honkbot_assembly = new(Tsec)
			honkbot_assembly.build_step = ASSEMBLY_FIRST_STEP
			honkbot_assembly.created_name = name
			new /obj/item/assembly/prox_sensor(Tsec)
			drop_part(baton_type, Tsec)
		else
			var/obj/item/bot_assembly/secbot/secbot_assembly = new(Tsec)
			secbot_assembly.build_step = ASSEMBLY_FIRST_STEP
			secbot_assembly.add_overlay("hs_hole")
			secbot_assembly.created_name = name
			new /obj/item/assembly/prox_sensor(Tsec)
			drop_part(baton_type, Tsec)

	new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/simple_animal/bot/secbot/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	. = ..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT

/mob/living/simple_animal/bot/secbot/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(has_gravity() && ismob(AM) && target)
		var/mob/living/carbon/C = AM
		if(!istype(C) || !C || in_range(src, target))
			return
		knockOver(C)

/// Returns false if the current target is unable to pay the fair_market_price for being arrested/detained
/mob/living/simple_animal/bot/secbot/proc/check_nap_violations()
	if(!SSeconomy.full_ancap)
		return TRUE
	if(!target)
		return TRUE
	if(!ishuman(target))
		return TRUE
	var/mob/living/carbon/human/human_target = target
	var/obj/item/card/id/target_id = human_target.get_idcard()
	if(!target_id)
		say("Suspect NAP Violation: No ID card found.")
		nap_violation(target)
		return FALSE
	var/datum/bank_account/insurance = target_id.registered_account
	if(!insurance)
		say("Suspect NAP Violation: No bank account found.")
		nap_violation(target)
		return FALSE
	var/fair_market_price = (security_mode_flags & SECBOT_HANDCUFF_TARGET ? fair_market_price_detain : fair_market_price_arrest)
	if(!insurance.adjust_money(-fair_market_price))
		say("Suspect NAP Violation: Unable to pay.")
		nap_violation(target)
		return FALSE
	var/datum/bank_account/beepsky_department_account = SSeconomy.get_dep_account(payment_department)
	say("Thank you for your compliance. Your account been charged [fair_market_price] credits.")
	if(beepsky_department_account)
		beepsky_department_account.adjust_money(fair_market_price)
		return TRUE

/// Does nothing
/mob/living/simple_animal/bot/secbot/proc/nap_violation(mob/violator)
	return
