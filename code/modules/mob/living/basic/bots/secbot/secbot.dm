/mob/living/basic/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot. He looks less than thrilled."
	icon = 'icons/mob/silicon/aibots.dmi'
	icon_state = "secbot"
	base_icon_state = "secbot"
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
	data_hud_type = TRAIT_SECURITY_HUD
	hackables = "target identification systems"
	path_image_color = COLOR_RED
	possessed_message = "You are a securitron! Guard the station to the best of your ability!"
	additional_access = /datum/id_trim/job/detective

	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.2, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 3.2)
	ai_controller = /datum/ai_controller/basic_controller/bot/secbot
	///Whether this secbot is considered 'commissioned' and given the trait on Initialize.
	var/commissioned = FALSE
	///The type of baton this Secbot will use
	var/baton_type = /obj/item/melee/baton/security
	///The weapon (from baton_type) that will be used to make arrests.
	var/obj/item/weapon
	///The threat level of the BOT, will arrest anyone at threatlevel 4 or above
	var/threatlevel = 0

	///Flags SecBOTs use on what to check on targets when arresting, and whether they should announce it to security/handcuff their target
	/// Look at the security_mode_flags bitfield for more information on what's togglable here.
	var/security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_RECORDS | SECBOT_HANDCUFF_TARGET

	/// On arrest, charges the violator this much.
	/// If they don't have that much in their account, they will get beaten instead
	var/price_arrest = 0
	/// Charged each time the violator is stunned on detain
	var/price_detain = 0
	///The department the secbot will deposit collected money into
	var/payment_department = ACCOUNT_SEC
	///what sound we play when stunning
	var/stun_sound = 'sound/items/weapons/egloves.ogg'
	///The type of cuffs we use on criminals after making arrests
	var/cuff_type = /obj/item/restraints/handcuffs/cable/zipties/used


/mob/living/basic/bot/secbot/beepsky
	name = "Commander Beep O'sky"
	desc = "It's Commander Beep O'sky! Officially the superior officer of all bots on station, Beepsky remains as humble and dedicated to the law as the day he was first fabricated."
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_AUTOPATROL | BOT_MODE_REMOTE_ENABLED
	commissioned = TRUE


/mob/living/basic/bot/secbot/beepsky/officer
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey, and with a sturdier reinforced chassis, too."
	health = 45

/mob/living/basic/bot/secbot/beepsky/officer/Initialize(mapload)
	. = ..()
	// Beepsky hates people scanning them
	RegisterSignal(src, COMSIG_MOVABLE_SPY_STEALING, PROC_REF(on_spy_scan))

/mob/living/basic/bot/secbot/beepsky/officer/proc/on_spy_scan(datum/source, mob/user)
	SIGNAL_HANDLER

	ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, user)

/mob/living/basic/bot/secbot/beepsky/ofitser
	name = "Prison Ofitser"
	desc = "Powered by the tears and sweat of laborers."
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)

/mob/living/basic/bot/secbot/beepsky/armsky
	name = "Sergeant-At-Armsky"
	desc = "It's Sergeant-At-Armsky! He's a disgruntled assistant to the warden that would probably shoot you if he had hands."
	health = 45
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS | SECBOT_CHECK_WEAPONS

/mob/living/basic/bot/secbot/beepsky/jr
	name = "Officer Pipsqueak"
	desc = "It's Commander Beep O'sky's smaller, just-as aggressive cousin, Pipsqueak."
	commissioned = FALSE

/mob/living/basic/bot/secbot/beepsky/jr/Initialize(mapload)
	. = ..()
	update_transform(0.8)

/mob/living/basic/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	light_color = "#62baf5"
	radio_channel = RADIO_CHANNEL_AI_PRIVATE
	bot_mode_flags = ~(BOT_MODE_CAN_BE_SAPIENT|BOT_MODE_AUTOPATROL)
	security_mode_flags = SECBOT_DECLARE_ARRESTS | SECBOT_CHECK_IDS | SECBOT_CHECK_RECORDS

/mob/living/basic/bot/secbot/genesky
	name = "Officer Genesky"
	desc = "A beefy variant of the standard securitron model."
	health = 50
	faction = list(FACTION_NANOTRASEN_PRIVATE)
	bot_mode_flags = BOT_MODE_ON
	bot_access_flags = BOT_COVER_LOCKED | BOT_COVER_EMAGGED

/mob/living/basic/bot/secbot/beepsky/explode()
	var/atom/current_location = drop_location()
	new /obj/item/stock_parts/power_store/cell/potato(current_location)
	var/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/drinking_oil = new(current_location)
	drinking_oil.reagents.add_reagent(/datum/reagent/consumable/ethanol/whiskey, 15)
	return ..()

/mob/living/basic/bot/secbot/Initialize(mapload)
	. = ..()
	weapon = new baton_type(src)
	update_appearance(UPDATE_ICON)
	if(commissioned)
		ADD_TRAIT(src, TRAIT_COMMISSIONED, INNATE_TRAIT)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	AddComponent(/datum/component/security_vision, judgement_criteria = NONE, update_judgement_criteria = CALLBACK(src, PROC_REF(judgement_criteria)))
	add_arrest_component()

/mob/living/basic/bot/secbot/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/basic/bot/secbot/update_icon_state()
	if(mode == BOT_HUNT)
		icon_state = "[base_icon_state]-c"
	return ..()

/mob/living/basic/bot/secbot/turn_off()
	..()
	update_bot_mode(new_mode = BOT_IDLE)

/mob/living/basic/bot/secbot/on_saboteur(datum/source, disrupt_duration)
	. = ..()
	if(!(security_mode_flags & SECBOT_SABOTEUR_AFFECTED))
		security_mode_flags |= SECBOT_SABOTEUR_AFFECTED
		addtimer(CALLBACK(src, PROC_REF(remove_saboteur_effect)), disrupt_duration)
		return TRUE

/mob/living/basic/bot/secbot/proc/remove_saboteur_effect()
	security_mode_flags &= ~SECBOT_SABOTEUR_AFFECTED

/mob/living/basic/bot/secbot/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)//shocks only make him angry
	if(speed >= initial(speed) + 3)
		return
	speed += 3
	addtimer(VARSET_CALLBACK(src, speed, speed - 3), 6 SECONDS)
	playsound(src, 'sound/machines/defib/defib_zap.ogg', 50)
	visible_message(span_warning("[src] shakes and speeds up!"))

/mob/living/basic/bot/secbot/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == weapon)
		weapon = null
		update_appearance()

// Variables sent to TGUI
/mob/living/basic/bot/secbot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_access_flags & BOT_COVER_LOCKED) || HAS_SILICON_ACCESS(user))
		data["custom_controls"]["check_id"] = security_mode_flags & SECBOT_CHECK_IDS
		data["custom_controls"]["check_weapons"] = security_mode_flags & SECBOT_CHECK_WEAPONS
		data["custom_controls"]["check_warrants"] = security_mode_flags & SECBOT_CHECK_RECORDS
		data["custom_controls"]["handcuff_targets"] = security_mode_flags & SECBOT_HANDCUFF_TARGET
		data["custom_controls"]["arrest_alert"] = security_mode_flags & SECBOT_DECLARE_ARRESTS
	return data

// Actions received from TGUI
/mob/living/basic/bot/secbot/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/mob/user = ui.user
	if(. || (bot_access_flags & BOT_COVER_LOCKED && !HAS_SILICON_ACCESS(user)))
		return

	switch(action)
		if("check_id")
			security_mode_flags ^= SECBOT_CHECK_IDS
			return TRUE
		if("check_weapons")
			security_mode_flags ^= SECBOT_CHECK_WEAPONS
			return TRUE
		if("check_warrants")
			security_mode_flags ^= SECBOT_CHECK_RECORDS
			return TRUE
		if("handcuff_targets")
			security_mode_flags ^= SECBOT_HANDCUFF_TARGET
			return TRUE
		if("arrest_alert")
			security_mode_flags ^= SECBOT_DECLARE_ARRESTS
			return TRUE


/mob/living/basic/bot/secbot/attack_hand(mob/living/carbon/human/user, list/modifiers)

	// Turns an oversight into a feature. Beepsky will now announce when pacifists taunt him over sec comms.
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		user.visible_message(span_notice("[user] taunts [src], daring [p_them()] to give chase!"), \
			span_notice("You taunt [src], daring [p_them()] to chase you!"), span_hear("You hear someone shout a daring taunt!"), DEFAULT_MESSAGE_RANGE, user)
		speak("Taunted by pacifist scumbag [RUNECHAT_BOLD("[user]")] in [get_area(src)].", radio_channel)

		// Interrupt the attack chain. We've already handled this scenario for pacifists.
		return

	return ..()

/mob/living/basic/bot/secbot/proc/retrieve_emag_message()
	audible_message(span_danger("[src] buzzes oddly!"))

/mob/living/basic/bot/secbot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(!(bot_access_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		balloon_alert(user, "target assessment circuits shorted")

	retrieve_emag_message()
	security_mode_flags &= ~SECBOT_DECLARE_ARRESTS
	update_appearance()
	return TRUE

/mob/living/basic/bot/secbot/proc/post_arrest(mob/living/carbon/current_target)
	playsound(src, SFX_LAW, 50, FALSE)

/mob/living/basic/bot/secbot/proc/post_stun(mob/living/carbon/current_target, harm = FALSE)
	flick("[base_icon_state]-c", src)
	var/threat = 5 || ai_controller.blackboard[BB_CURRENT_CRIMINAL_ASSESSMENT]
	if(security_mode_flags & SECBOT_DECLARE_ARRESTS)
		var/area/location = get_area(src)
		speak("[security_mode_flags & SECBOT_HANDCUFF_TARGET ? "Arresting" : "Detaining"] level [threat] scumbag [RUNECHAT_BOLD("[current_target]")] in [location].", radio_channel)
	payment_check(current_target)
	update_bot_mode(new_mode = BOT_PREP_ARREST)

/mob/living/basic/bot/secbot/explode()
	var/atom/drop_location = drop_location()
	retrieve_secbot_drops(drop_location)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	return ..()

/mob/living/basic/bot/secbot/proc/retrieve_secbot_drops(atom/drop_location)
	var/obj/item/bot_assembly/secbot/secbot_assembly = new(drop_location)
	secbot_assembly.build_step = ASSEMBLY_FIRST_STEP
	secbot_assembly.add_overlay("hs_hole")
	secbot_assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_location)
	drop_part(weapon, drop_location)

/mob/living/basic/bot/secbot/proc/on_entered(datum/source, atom/movable/to_be_tripped)
	SIGNAL_HANDLER
	var/mob/living/possible_target = ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!has_gravity() || !ismob(to_be_tripped) || !possible_target)
		return
	var/mob/living/carbon/tripped_mob = to_be_tripped
	if(istype(tripped_mob) && !in_range(src, possible_target))
		knockOver(tripped_mob)

/// Returns true if the current target is unable to pay to be detained/arrested
/mob/living/basic/bot/secbot/proc/payment_check(mob/living/carbon/human/human_target)
	var/fair_market_price = (security_mode_flags & SECBOT_HANDCUFF_TARGET) ? price_arrest : price_detain
	if(fair_market_price <= 0)
		return FALSE
	if(!ishuman(human_target))
		return FALSE
	var/obj/item/card/id/target_id = human_target.get_idcard()
	if(!target_id)
		say("Unable to pay fine: No ID card found.")
		return TRUE
	var/datum/bank_account/insurance = target_id.registered_account
	if(!insurance)
		say("Unable to pay fine: No bank account found.")
		return TRUE
	if(!insurance.adjust_money(-fair_market_price, "Securitron fine"))
		say("Unable to pay fine: Not enough funds in account.")
		return TRUE

	SSeconomy.get_dep_account(payment_department)?.adjust_money(fair_market_price)
	say("Fine paid: Thank you for your compliance. Your account been charged [fair_market_price] [MONEY_NAME].")
	return FALSE

/mob/living/basic/bot/secbot/generate_speak_list()
	var/static/list/secbot_lines = list(
		BEEPSKY_VOICED_CRIMINAL_DETECTED = 'sound/mobs/non-humanoids/beepsky/criminal.ogg',
		BEEPSKY_VOICED_FREEZE = 'sound/mobs/non-humanoids/beepsky/freeze.ogg',
		BEEPSKY_VOICED_JUSTICE = 'sound/mobs/non-humanoids/beepsky/justice.ogg',
		BEEPSKY_VOICED_YOUR_MOVE = 'sound/mobs/non-humanoids/beepsky/creep.ogg',
		BEEPSKY_VOICED_I_AM_THE_LAW = 'sound/mobs/non-humanoids/beepsky/iamthelaw.ogg',
		BEEPSKY_VOICED_SECURE_DAY = 'sound/mobs/non-humanoids/beepsky/secureday.ogg',
	)
	return secbot_lines


/mob/living/basic/bot/secbot/proc/judgement_criteria()
	var/final = FALSE
	if(bot_access_flags & BOT_COVER_EMAGGED)
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

/mob/living/basic/bot/secbot/proc/add_arrest_component()
	AddComponent(/datum/component/stun_n_cuff,\
		stun_sound = stun_sound,\
		post_stun_callback = CALLBACK(src, PROC_REF(post_stun)),\
		post_arrest_callback = CALLBACK(src, PROC_REF(post_arrest)),\
		handcuff_type = cuff_type,\
	)
