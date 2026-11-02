// The Right of Customs in Excess (Ratwood royal_custom_* of SStreasury, stockpile/stockpile.dm check_charter_unlock() and
// withdraw_tab.dm do_direct_import()): once the realm has traded enough through its stockpile, an ancient charter lets the
// Crown keep what the carriers took on a good imported straight from a region at the vomitorium. The Steward sets the margin.

/datum/controller/subsystem/rogue_treasury
	/// The charter has been invoked, and stands (Ratwood royal_custom_unlocked, royal_custom_active).
	var/royal_custom_unlocked = FALSE
	var/royal_custom_active = FALSE
	/// Percent laid on a direct import while the charter stands; the Steward sets it (Ratwood royal_custom_margin).
	var/royal_custom_margin = 0
	/// Mammons of trade the realm must tally before the charter is invoked, set by the population at round start (Ratwood
	/// royal_custom_threshold).
	var/royal_custom_threshold = 0
	var/total_royal_custom = 0

/datum/controller/subsystem/rogue_treasury/proc/setup_royal_custom()
	royal_custom_margin = round(rogue_value("trade_import_margin"))
	royal_custom_threshold = round(rogue_value("treasury_custom_volume") + length(GLOB.alive_player_list) * rogue_value("treasury_custom_volume_per_player"))

/// The charter stands: direct imports pay the Crown.
/datum/controller/subsystem/rogue_treasury/proc/royal_custom_in_force()
	return royal_custom_unlocked && royal_custom_active

/// Invokes the charter once the realm's trade passes its threshold (Ratwood check_charter_unlock()).
/datum/controller/subsystem/rogue_treasury/proc/check_royal_custom()
	if(royal_custom_unlocked || !royal_custom_threshold || economic_output < royal_custom_threshold)
		return FALSE
	royal_custom_unlocked = TRUE
	royal_custom_active = TRUE
	rogue_scom_announce("The Stewardry has tallied [royal_custom_threshold] mammons of trade. By ancient charter, the Crown's Right of Customs in Excess is invoked - duties that once paid for the middleman's cut now flow into the Crown's purse instead. The Steward may set the rate at the Stewardry.")
	for(var/mob/living/carbon/human/steward as anything in GLOB.human_list)
		if(steward.client && steward.stat != DEAD && steward.mind?.assigned_role?.title == JOB_ROCKHILL_STEWARD)
			to_chat(steward, span_boldnotice("Royal Custom unlocked. Import surcharges at every stockpile now flow to the Crown's purse. Adjust the margin at the nerve master."))
	log_game("TREASURY: the Right of Customs in Excess was invoked at [economic_output]m of trade")
	return TRUE

/// The Steward sets the margin laid on direct imports while the charter stands (Ratwood set_royal_custom_margin).
/datum/controller/subsystem/rogue_treasury/proc/set_royal_custom_margin(percent, mob/user)
	if(!royal_custom_unlocked)
		return FALSE
	royal_custom_margin = clamp(round(percent), 0, rogue_value("treasury_custom_margin_max"))
	log_game("TREASURY: [key_name(user)] set the Royal Custom margin to [royal_custom_margin]%")
	return TRUE

/// While the charter stands, a direct import costs its unit price with the Steward's margin instead of the carriers' (Ratwood
/// get_direct_import_quote()).
/datum/roguestock/import_quote()
	var/list/quote = ..()
	var/datum/controller/subsystem/rogue_treasury/treasury = SSrogue_treasury
	if(quote && treasury.royal_custom_in_force())
		quote["price"] = max(1, round(quote["unit_cost"] * (100 + treasury.royal_custom_margin) / 100))
	return quote

/// While the charter stands, what a buyer pays above the unit price of a direct import goes to the Crown's Purse instead of the
/// carriers (Ratwood do_direct_import(), "Royal Custom: direct import").
/obj/structure/roguemachine/buy_stock(datum/roguestock/stock, mob/user, import = FALSE)
	var/list/quote = (import && SSrogue_treasury.royal_custom_in_force()) ? stock.import_quote() : null
	. = ..()
	if(!. || !quote)
		return
	var/surcharge = quote["price"] - quote["unit_cost"]
	if(surcharge > 0 && SSrogue_treasury.mint(SSrogue_treasury.crown_purse, surcharge, "Royal Custom: direct import of [stock.name]"))
		SSrogue_treasury.total_royal_custom += surcharge
