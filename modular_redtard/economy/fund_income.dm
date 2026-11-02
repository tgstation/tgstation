// Income of the realm's institutions beyond coins and loans (Ratwood code/modules/banking/fund_api.dm and atm_tgui.dm): the
// stalls of the tavern and the bathhouse pay their takings into their funds, and the Ordinance of the Baths sends the
// bathhouse's dues to the Church instead of the Crown. The bathhouse machines (BRASSFACE, TREASURE SEEKER) pay their dues
// through collect_bathhouse_tariff() and pay_bathhouse_hoard().

/// Lockid of a stall -> the institution whose fund keeps its takings (Ratwood: the TAVERN JAWBANK "hoards the tavern's takings",
/// the bathhouse fund keeps what the stews earn).
GLOBAL_LIST_INIT(rogue_stall_funds, list(
	"tavern" = ROGUE_FUND_TAVERN,
	"nightmaiden" = ROGUE_FUND_BATHHOUSE,
))

/obj/structure/roguemachine/vendor
	/// Institution whose fund takes the stall's takings; unset, the one its key belongs to (GLOB.rogue_stall_funds).
	var/takings_fund_id

/// The fund the stall's takings go to, if it belongs to an institution.
/obj/structure/roguemachine/vendor/proc/takings_fund()
	var/fund_id = takings_fund_id || GLOB.rogue_stall_funds[keycontrol]
	return fund_id ? SSrogue_treasury.get_fund(fund_id) : null

/// A sale at an institution's stall is banked in its fund instead of waiting in the stall for the keeper.
/obj/structure/roguemachine/vendor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	var/takings_before = profits
	. = ..()
	if(profits > takings_before)
		bank_takings(profits - takings_before)

/// Moves takings from the stall into its institution's fund. Returns TRUE when they were banked.
/obj/structure/roguemachine/vendor/proc/bank_takings(amount)
	var/datum/bank_account/rogue/fund = takings_fund()
	if(!fund || amount <= 0 || !SSrogue_treasury.mint(fund, amount, "[name]: sale"))
		return FALSE
	profits = max(0, profits - amount)
	var/obj/structure/roguemachine/vaultbank/jawbank = SSrogue_treasury.jawbanks[fund.fund_id]
	jawbank?.update_appearance()
	return TRUE

/obj/structure/roguemachine/vendor/examine(mob/user)
	. = ..()
	var/datum/bank_account/rogue/fund = takings_fund()
	if(fund)
		. += span_info("Its takings go to [fund.account_holder].")

/datum/controller/subsystem/rogue_treasury
	/// Ordinance of the Baths: the Church's sanction over the stews. While it holds, the bathhouse's dues go to the Church, not
	/// the Crown (Ratwood bathhouse_ordinance_active; in force at round start).
	var/bathhouse_ordinance = TRUE
	/// Before this world.time the Ordinance cannot be set anew (Ratwood bathhouse_ordinance_next_toggle_time).
	var/ordinance_next_toggle = 0
	/// Shares of a mammon the bathhouse owes the Church that did not yet make a whole coin (Ratwood bathhouse_tithe_debt).
	var/bathhouse_tithe_debt = 0
	var/total_bathhouse_tithe = 0

/// The Bishop and the Bathmaster set the terms of the Ordinance (Ratwood handle_toggle_bathhouse_ordinance()).
/datum/controller/subsystem/rogue_treasury/proc/can_set_ordinance(mob/user)
	return user?.mind?.assigned_role?.title in list(JOB_ROCKHILL_BISHOP, JOB_ROCKHILL_BATHMASTER)

/// Breaks or restores the Ordinance of the Baths and proclaims it (Ratwood handle_toggle_bathhouse_ordinance()).
/datum/controller/subsystem/rogue_treasury/proc/toggle_ordinance(mob/living/user)
	if(!can_set_ordinance(user))
		to_chat(user, span_warning("Only the Bishop or the Bathmaster may set the terms of the Ordinance of the Baths."))
		return FALSE
	if(world.time < ordinance_next_toggle)
		to_chat(user, span_warning("The seal is still warm upon the wax. The Ordinance may be reconsidered in [DisplayTimeText(ordinance_next_toggle - world.time)]."))
		return FALSE
	bathhouse_ordinance = !bathhouse_ordinance
	ordinance_next_toggle = world.time + rogue_value("treasury_ordinance_cooldown")
	var/bishop = user.mind.assigned_role.title == JOB_ROCKHILL_BISHOP
	var/text
	if(bathhouse_ordinance)
		if(bishop)
			text = "By Eora's grace, the Bishop, [user.real_name], hath set anew the seal upon the Ordinance of the Baths. The See extends its sanction over the stews once more, and the tithe shall render unto the Church."
		else
			text = "By Eora's grace, the Bathmaster, [user.real_name], hath knelt beneath the Ordinance of the Baths. The stews accept the Church's sanction anew, and the tithe shall render unto the Church."
	else if(bishop)
		text = "The Bishop, [user.real_name], hath broken the seal upon the Ordinance of the Baths. The See renounces its sanction; the stews fall again beneath the Crown's tariff."
	else
		text = "The Bathmaster, [user.real_name], hath broken the seal upon the Ordinance of the Baths. The stews cast off the Church's sanction; their farm returns unto the Crown."
	priority_announce(text, bathhouse_ordinance ? "Ordinance of the Baths Restored" : "Ordinance of the Baths Broken", ROGUE_SOUND_DECREE)
	log_game("ORDINANCE OF THE BATHS: [key_name(user)] set it [bathhouse_ordinance ? "IN FORCE" : "BROKEN"].")
	message_admins("[key_name_admin(user)] set the Ordinance of the Baths [bathhouse_ordinance ? "IN FORCE" : "BROKEN"].")
	return TRUE

/**
 * Ratwood compute_bathhouse_tithe(): while the Ordinance holds, a share of a bathhouse sale or hoard is the Church's. The shares
 * add up until they make whole mammons. Returns the whole mammons the Church is owed now; 0 while the Ordinance is broken.
 */
/datum/controller/subsystem/rogue_treasury/proc/bathhouse_tithe(base_amount, rate)
	if(base_amount <= 0 || rate <= 0 || !bathhouse_ordinance || !funds[ROGUE_FUND_CHURCH])
		return 0
	bathhouse_tithe_debt += base_amount * rate
	var/tithe = floor(bathhouse_tithe_debt)
	if(tithe <= 0)
		return 0
	bathhouse_tithe_debt -= tithe
	total_bathhouse_tithe += tithe
	return tithe

/**
 * The dues of a sale at a bathhouse machine (Ratwood bathvend "buy", for the BRASSFACE): under the Ordinance the tariff charged
 * on the sale goes to the Church, with the Ordinance's tithe on the sale on top; broken, the tariff is the Crown's import duty.
 * Returns the account that took the tariff.
 */
/datum/controller/subsystem/rogue_treasury/proc/collect_bathhouse_tariff(tariff, base_amount, source)
	var/datum/bank_account/rogue/church = funds[ROGUE_FUND_CHURCH]
	if(bathhouse_ordinance && church)
		var/tithe = bathhouse_tithe(base_amount, rogue_value("treasury_bath_sale_tithe"))
		if(tithe > 0)
			mint(church, tithe, "Ordinance of the Baths tithe ([source])")
		if(tariff > 0)
			mint(church, tariff, "[ROGUE_TAX_IMPORT] diverted to the Church ([source])")
		return church
	if(tariff > 0 && mint(crown_purse, tariff, "[ROGUE_TAX_IMPORT] ([source])"))
		total_tariff += tariff
	return crown_purse

/**
 * The hoard of the bathhouse vault pays the bathhouse fund, less the Ordinance's vault tithe to the Church (Ratwood BMtreasury
 * fire(), for the TREASURE SEEKER). Returns the mammons the bathhouse fund got.
 */
/datum/controller/subsystem/rogue_treasury/proc/pay_bathhouse_hoard(amount, source)
	var/datum/bank_account/rogue/bathhouse = funds[ROGUE_FUND_BATHHOUSE]
	amount = round(amount)
	if(!bathhouse || amount <= 0)
		return 0
	var/tithe = bathhouse_tithe(amount, rogue_value("treasury_bath_vault_tithe"))
	if(tithe > 0 && mint(funds[ROGUE_FUND_CHURCH], tithe, "Ordinance of the Baths tithe ([source])"))
		amount -= tithe
	if(!mint(bathhouse, amount, source))
		return 0
	update_jawbanks()
	return amount
