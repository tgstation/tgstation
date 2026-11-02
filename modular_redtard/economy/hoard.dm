/**
 * The Nightmaster's hoard (Ratwood merchant/bathmaster.dm, SSBMtreasury): whatever treasure lies in the bathhouse vault, on its
 * floor or in its chests, earns the Bathhouse Fund interest every five to eight minutes - the hoard "remembers its worth", and
 * each further piece of a kind already counted is worth less. Every payout and every consignment of the TREASURE SEEKER goes
 * into the hoard ledger the bathhouse reads at the BRASSFACE. The treasury pays it into the Bathhouse Fund, less the Church's tithe
 * while the Ordinance of the Baths holds (pay_bathhouse_hoard(), fund_income.dm).
 */
SUBSYSTEM_DEF(rogue_hoard)
	name = "Bathhouse Hoard"
	wait = 1 MINUTES
	runlevels = RUNLEVEL_GAME
	dependencies = list(
		/datum/controller/subsystem/rogue_treasury,
	)
	/// When the hoard next pays its interest.
	var/next_payout = 0
	/// Newest first: list("kind" = "payout"|"deposit", "time", "text", "amount", "who") (Ratwood hoard_log).
	var/list/hoard_log = list()
	/// Mammons the hoard paid the Bathhouse Fund this round.
	var/total_paid = 0

/datum/controller/subsystem/rogue_hoard/Initialize()
	if(!rogue_economy_enabled())
		can_fire = FALSE
		return SS_INIT_NO_NEED
	schedule_payout()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rogue_hoard/stat_entry(msg)
	msg = "Paid: [total_paid]m, next in [max(0, round((next_payout - world.time) / 10))]s"
	return ..()

/datum/controller/subsystem/rogue_hoard/fire(resumed)
	if(world.time < next_payout)
		return
	schedule_payout()
	pay_interest()

/datum/controller/subsystem/rogue_hoard/proc/schedule_payout()
	next_payout = world.time + rand(rogue_value("machines_hoard_period_min"), rogue_value("machines_hoard_period_max"))

/// Ratwood add_hoard_log(): a line of the hoard ledger, newest first, the last fifty kept.
/datum/controller/subsystem/rogue_hoard/proc/add_log(kind, text, amount, who)
	hoard_log.Insert(1, list(list(
		"kind" = kind,
		"time" = round_timestamp("hh:mm"),
		"text" = text,
		"amount" = amount,
		"who" = who,
	)))
	var/most = rogue_value("machines_hoard_log_size")
	if(length(hoard_log) > most)
		hoard_log.Cut(most + 1)

/// Ratwood generates_profit(): the hoard counts things of worth, not coins or containers.
/datum/controller/subsystem/rogue_hoard/proc/profitable(obj/item/thing)
	return thing.get_real_price() > 0 && !istype(thing, /obj/item/roguecoin) && !istype(thing, /obj/item/storage)

/**
 * The interest the vault earns now (Ratwood fire() and add_to_vault()): each treasure pays a share of its worth, and every
 * further piece of the same kind is worth that much less again.
 */
/datum/controller/subsystem/rogue_hoard/proc/vault_interest()
	var/list/accounted = list()
	var/rate = rogue_value("machines_hoard_interest")
	var/repeat = rogue_value("machines_hoard_repeat_penalty")
	var/interest = 0
	for(var/turf/vault_turf as anything in rogue_bath_vault_turfs(FALSE))
		for(var/obj/item/thing in vault_turf)
			interest += count_treasure(thing, accounted, rate, repeat)
		for(var/obj/structure/closet/chest in vault_turf)
			for(var/obj/item/thing in chest)
				interest += count_treasure(thing, accounted, rate, repeat)
	return round(interest)

/datum/controller/subsystem/rogue_hoard/proc/count_treasure(obj/item/thing, list/accounted, rate, repeat)
	if(!profitable(thing))
		return 0
	if(accounted[thing.type])
		accounted[thing.type] *= repeat
	else
		accounted[thing.type] = thing.get_real_price()
	return accounted[thing.type] * rate

/// The hoard pays its interest into the Bathhouse Fund, less the Ordinance's tithe, and the Bathmaster hears of it.
/datum/controller/subsystem/rogue_hoard/proc/pay_interest()
	var/interest = vault_interest()
	if(interest <= 0)
		return 0
	interest = SSrogue_treasury.pay_bathhouse_hoard(interest, "Income from the smuggling hoard")
	if(interest <= 0)
		return 0
	total_paid += interest
	add_log("payout", "Income from smuggling hoard", interest)
	for(var/datum/bank_account/rogue/account as anything in SSrogue_treasury.accounts)
		if(account.job_title() == JOB_ROCKHILL_BATHMASTER)
			account.bank_card_talk("Income from smuggling hoard (deposited to Bathhouse Fund): +[interest]m")
	return interest

/// The bathhouse's own: the Bathmaster, her attendants and, unless left out, the agents her writ swore in (Ratwood bathhouse_positions).
/proc/rogue_bathhouse_staff(mob/user, agents = TRUE)
	if(!user)
		return FALSE
	if(user.mind?.assigned_role?.title in list(JOB_ROCKHILL_BATHMASTER, JOB_ROCKHILL_BATHHOUSE_ATTENDANT))
		return TRUE
	return agents && HAS_TRAIT(user, TRAIT_AGENT_BATHHOUSE)

/// Turfs of the Nightmaster's vault (Ratwood /area/rogue/outdoors/exposed/bath/vault); only the free floor when asked.
/proc/rogue_bath_vault_turfs(free_floor = TRUE)
	. = list()
	for(var/turf/vault_turf as anything in get_area_turfs(/area/rogue/outdoors/exposed/bath/vault, subtypes = TRUE))
		if(free_floor && (!isopenturf(vault_turf) || vault_turf.is_blocked_turf()))
			continue
		. += vault_turf

/**
 * TREASURE SEEKER (Ratwood treasureseeker.dm): the HEADEATER's bathhouse kin. The bathhouse's own feed it trinkets, or right
 * click it to feed it everything at its foot, and it drops them on the floor of the Nightmaster's vault, where they earn the
 * hoard interest; each consignment goes into the hoard ledger. Worthless things, coins and containers it refuses.
 */
/obj/structure/roguemachine/headeater/treasureseeker/examine(mob/user)
	. = ..()
	. += span_info("Use an item on it to consign it to the Nightmistress's vault. Right click to consign every item beneath its maw.")
	. += span_smallnotice("Its jaws open only for the Bathhouse - the Nightmistress, her workers and her sworn agents.")
	. += span_smallnotice("Each consignment is entered into the BRASSFACE's Hoard ledger, and the hoard pays interest on the vault's treasures.")
	. += span_smallnotice("Dross is refused - it swallows only what the hoard can turn a profit on, leaving worthless trinkets, loose coin and containers behind.")

/obj/structure/roguemachine/headeater/treasureseeker/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(!rogue_bathhouse_staff(user))
		to_chat(user, span_warning("[src] stays shut, its brass jaws sealed - the hoard answers only to the Bathhouse."))
		return ITEM_INTERACT_BLOCKING
	if(!SSrogue_hoard.profitable(tool))
		to_chat(user, span_warning("[src] sniffs at [tool] and turns its brass nose up - the hoard has no taste for such dross."))
		return ITEM_INTERACT_BLOCKING
	var/list/vault = rogue_bath_vault_turfs()
	if(!length(vault))
		to_chat(user, span_warning("[src] rattles hollowly - the Nightmistress's vault cannot be reached."))
		return ITEM_INTERACT_BLOCKING
	var/turf/destination = pick(vault)
	if(!user.transferItemToLoc(tool, destination))
		to_chat(user, span_warning("[tool] is stuck to your hand!"))
		return ITEM_INTERACT_BLOCKING
	SSrogue_hoard.add_log("deposit", tool.name, tool.get_real_price(), user.real_name)
	announce_treasure("[tool] suddenly appears in a golden flash upon the ground of the vault.", destination)
	playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
	to_chat(user, span_danger("[src] gulps down [tool], whisking it away to the Nightmistress's vault."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/roguemachine/headeater/treasureseeker/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !ishuman(user))
		return
	consign_all(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood attack_right(): everything worth keeping at its foot goes to the vault, logged one line per kind.
/obj/structure/roguemachine/headeater/treasureseeker/proc/consign_all(mob/living/user)
	if(!rogue_bathhouse_staff(user))
		to_chat(user, span_warning("[src] stays shut, its brass jaws sealed - the hoard answers only to the Bathhouse."))
		return
	var/list/to_ship = list()
	var/rejected = 0
	for(var/obj/item/thing in get_turf(src))
		if(thing.anchored)
			continue
		if(SSrogue_hoard.profitable(thing))
			to_ship += thing
		else
			rejected++
	if(!length(to_ship))
		if(rejected)
			to_chat(user, span_warning("[src] turns its brass nose up at the dross before it - nothing there would fatten the hoard."))
		else
			to_chat(user, span_info("Nothing glitters upon the tile before [src]."))
		return
	var/list/vault = rogue_bath_vault_turfs()
	if(!length(vault))
		to_chat(user, span_warning("[src] rattles hollowly - the Nightmistress's vault cannot be reached."))
		return
	var/list/counts = list()
	var/list/values = list()
	var/turf/destination
	for(var/obj/item/thing as anything in to_ship)
		destination = pick(vault)
		thing.forceMove(destination)
		counts[thing.name] += 1
		values[thing.name] += thing.get_real_price()
	var/shipped = length(to_ship)
	for(var/item_name in counts)
		SSrogue_hoard.add_log("deposit", counts[item_name] > 1 ? "[item_name] x[counts[item_name]]" : item_name, values[item_name], user.real_name)
	var/obj/item/first = to_ship[1]
	announce_treasure(shipped == 1 ? "[first] suddenly appears in a golden flash upon the ground of the vault." : "[shipped] items of treasure suddenly appear in a golden flash upon the ground of the vault.", destination)
	playsound(src, ROGUE_SOUND_MACHINE_VOMIT, 100, TRUE, -1)
	to_chat(user, span_danger("[src] gulps down [shipped] treasure\s, whisking [shipped == 1 ? "it" : "them"] away to the Nightmistress's vault."))
	if(rejected)
		to_chat(user, span_warning("[src] leaves [rejected] trifle\s untouched - the hoard has no taste for such dross."))

/// Those in the vault see the treasure arrive (Ratwood announce_arrival()).
/obj/structure/roguemachine/headeater/treasureseeker/proc/announce_treasure(message, turf/destination)
	if(!destination)
		return
	for(var/mob/hearer in hearers(7, destination))
		to_chat(hearer, span_notice(message))
