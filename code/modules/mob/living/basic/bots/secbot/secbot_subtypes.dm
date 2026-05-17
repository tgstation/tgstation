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
