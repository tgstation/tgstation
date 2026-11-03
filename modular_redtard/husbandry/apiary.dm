/// Beekeeping (Ratwood code/game/objects/structures/apiary.dm; the bees' way around what blocks them and the hive's examine after
/// Azure Peak). A hive keeps a colony under its queen. Its bees fly out in small groups to the crops (soil of farming/ with a crop in
/// it) and herbs around it, pollinate them - pollinated soil grows faster for a while (farming's soil.pollinate()) - and carry the
/// pollen home, where the bees at home work it into comb: a honeycomb for every hundred, five at most, and a new bee for every ten
/// while the colony has room. Rain or snow keeps the bees home. The honeycombs are taken by hand; without a beekeeper's protection (a
/// hood over the mouth and something over the chest) the queen's temper may send the bees out angrily instead, and angry bees sting
/// whoever stands next to them. A protected beekeeper's open hand takes the queen out, and a queen goes into a hive without one.
/// Without a queen a colony dwindles; a queen grows old and dies. Now and then a hive falls sick - of varroa mites (bees die),
/// foulbrood (the comb work spoils) or wax moths (honeycombs are eaten) - more often next to a sick hive and less under a hardy
/// queen, and a disease that runs its course kills the colony. A crowded hive swarms: a young queen leads part of the colony off to
/// settle a hive of its own. Honey of a colony that mostly visited poppies is Ratwood's medicinal honey, once the porter brings it.
/// It all runs on medieval maps only.
///
/// Not ported: Ratwood's smoker, magnifying glass and bee medicines (nothing makes them and no map holds them, so a hive disease is not
/// treated, as at Ratwood) and the wild hives with their bees (on no map either).

#define APIARY_ICON 'modular_redtard/rockhill/icons/obj/structures/apiary.dmi'
/// Ratwood's hives, bees, swarms and queens tick with SSobj, every 2 seconds; their chances and paces are per tick.
#define APIARY_TICK (2 SECONDS)
/// Ratwood disease_type.
#define BEE_DISEASE_MITES "varroa_mites"
#define BEE_DISEASE_FOULBROOD "foulbrood"
#define BEE_DISEASE_MOTHS "wax_moths"
/// Ratwood's bounds of a queen's and her bees' traits (the clamp() of create_swarm() and transfer_genetics()).
#define BEE_TRAIT_MIN 0.5
#define BEE_TRAIT_MAX 2
/// Ratwood's queens come in one of these golds (create_new_queen()).
#define BEE_QUEEN_COLORS list("#FFD700", "#FFA500", "#FFFF00", "#DAA520")
/// Disease progress that adds a step of severity, and the severity that kills the colony (Ratwood process_disease()).
#define BEE_DISEASE_PROGRESS 100
#define BEE_DISEASE_FATAL 100
/// Chance in percent a bee killed by mites is seen to fall (Ratwood prob(10)).
#define BEE_MITE_FALL_CHANCE 10
/// Swarm build-up out of 100 past which the bees grow restless, the chance they show it, and the build-up that releases the swarm.
#define BEE_SWARM_RESTLESS 80
#define BEE_SWARM_RESTLESS_CHANCE 10
#define BEE_SWARM_READY 100
/// Most bees drawn over a swarm (Ratwood min(bee_spawn, 10)), and how far apart the bees of a group are drawn (rand(12, -12)).
#define BEE_SWARM_DRAWN 10
#define BEE_SPREAD 12
/// Ratwood's medicinal honey of poppies (apiary.dm), not in the port yet.
#define BEE_POPPY_HONEY "/obj/item/reagent_containers/food/snacks/rogue/honey/healing"

/// Numbers of the mechanics registry (config/redtard/mechanics/values/husbandry.txt).
#define APIARY_MAX_BEES rogue_value("apiary_max_bees")
#define APIARY_MAX_BEES_PER_EFFICIENCY rogue_value("apiary_max_bees_per_efficiency")
#define APIARY_STARTER_BEES rogue_value("apiary_starter_bees")
#define APIARY_MAX_COMBS rogue_value("apiary_max_combs")
#define APIARY_COMB_WORK rogue_value("apiary_comb_work")
#define APIARY_WORK_PER_BEE rogue_value("apiary_work_per_bee")
#define APIARY_BEE_COST rogue_value("apiary_bee_cost")
#define APIARY_QUEEN_BROOD_CHANCE rogue_value("apiary_queen_brood_chance")
#define APIARY_QUEENLESS_LOSS rogue_value("apiary_queenless_loss")
#define APIARY_HONEY_TIME rogue_value("apiary_honey_time")
#define APIARY_QUEEN_TIME rogue_value("apiary_queen_time")
#define APIARY_AGITATE_CHANCE rogue_value("apiary_agitate_chance")
#define APIARY_AGITATE_MAX rogue_value("apiary_agitate_max")
#define APIARY_AGITATE_TICKS rogue_value("apiary_agitate_ticks")
#define APIARY_QUEENLESS_AGGRESSION rogue_value("apiary_queenless_aggression")
#define APIARY_DISEASE_ROLL rogue_value("apiary_disease_roll")
#define APIARY_DISEASE_CHANCE rogue_value("apiary_disease_chance")
#define APIARY_DISEASE_NEARBY_CHANCE rogue_value("apiary_disease_nearby_chance")
#define APIARY_DISEASE_RANGE rogue_value("apiary_disease_range")
#define APIARY_DISEASE_RESISTANCE rogue_value("apiary_disease_resistance")
#define APIARY_DISEASE_START rogue_value("apiary_disease_start")
#define APIARY_DISEASE_STEP rogue_value("apiary_disease_step")
#define APIARY_MITE_SHARE rogue_value("apiary_mite_share")
#define APIARY_FOULBROOD_SHARE rogue_value("apiary_foulbrood_share")
#define APIARY_MOTH_SHARE rogue_value("apiary_moth_share")
#define APIARY_SWARM_SHARE rogue_value("apiary_swarm_share")
#define APIARY_SWARM_COOLDOWN rogue_value("apiary_swarm_cooldown")
#define APIARY_SWARM_RATE rogue_value("apiary_swarm_rate")
#define BEE_GROUP_JOIN_MAX rogue_value("bee_group_join_max")
#define BEE_TARGET_RANGE rogue_value("bee_target_range")
#define BEE_POLLINATE_TIME rogue_value("bee_pollinate_time")
#define BEE_POLLEN_MIN rogue_value("bee_pollen_min")
#define BEE_POLLEN_MAX rogue_value("bee_pollen_max")
#define BEE_POLLEN_LOAD rogue_value("bee_pollen_load")
#define BEE_REST_TIME rogue_value("bee_rest_time")
#define BEE_BLOCKED_MOVES rogue_value("bee_blocked_moves")
#define BEE_GIVE_UP_TIME rogue_value("bee_give_up_time")
#define BEE_STING_SHARE rogue_value("bee_sting_share")
#define BEE_STING_TOXIN rogue_value("bee_sting_toxin")
#define BEE_STING_VENOM rogue_value("bee_sting_venom")
#define BEE_STING_SPREAD_RANGE rogue_value("bee_sting_spread_range")
#define BEE_STING_SPREAD_CHANCE rogue_value("bee_sting_spread_chance")
#define BEE_STING_SPREAD_TICKS rogue_value("bee_sting_spread_ticks")
#define BEE_TRAIT_DRIFT rogue_value("bee_trait_drift")
#define BEE_AGGRESSION_DRIFT rogue_value("bee_aggression_drift")
#define SWARM_SIZE_MIN rogue_value("swarm_size_min")
#define SWARM_SIZE_MAX rogue_value("swarm_size_max")
#define SWARM_LIFETIME rogue_value("swarm_lifetime")
#define SWARM_SEARCH_TICKS rogue_value("swarm_search_ticks")
#define SWARM_SETTLE_CHANCE rogue_value("swarm_settle_chance")
#define SWARM_WANDER_CHANCE rogue_value("swarm_wander_chance")
#define SWARM_TRAIT_DRIFT rogue_value("swarm_trait_drift")
#define SWARM_AGGRESSION_DRIFT rogue_value("swarm_aggression_drift")
#define QUEEN_TRAIT_SPREAD rogue_value("queen_trait_spread")
#define QUEEN_AGGRESSION_MAX rogue_value("queen_aggression_max")
#define QUEEN_AGE_RATE rogue_value("queen_age_rate")
#define QUEEN_OLD_AGE rogue_value("queen_old_age")
#define QUEEN_DECLINE rogue_value("queen_decline")

/obj/structure/apiary
	/// Ratwood bee_count: bees at home and awake.
	var/rogue_bees = 0
	/// Ratwood outside_bees: bees out on the wing.
	var/rogue_bees_out = 0
	/// Ratwood sleeping_bees: bees back home, resting before they go out again.
	var/rogue_bees_asleep = 0
	/// Ratwood max_bees: how big the colony may grow, more under a better queen.
	var/rogue_max_bees = 0
	/// Ratwood stored_combs: honeycombs ready to be taken.
	var/rogue_combs = 0
	/// Ratwood comb_progress: pollen worked towards the next honeycomb, which also raises new bees.
	var/rogue_comb_progress = 0
	/// Ratwood pollen: pollen brought home and not yet worked.
	var/rogue_pollen = 0
	/// Ratwood queen_bee: the queen, inside the hive.
	var/obj/item/queen_bee/rogue_queen
	/// Ratwood bee_objects: the groups of bees on the wing.
	var/list/rogue_bee_groups
	/// Ratwood disease_type (BEE_DISEASE_*; null - healthy), disease_severity (out of 100) and disease_progression.
	var/rogue_disease
	var/rogue_disease_severity = 0
	var/rogue_disease_progress = 0
	/// Ratwood swarm_progress (out of 100) and last_swarm_time.
	var/rogue_swarm_progress = 0
	var/rogue_last_swarm = 0
	/// Ratwood pollen_sources: what the bees pollinated since the honey was last taken, crop or herb type = visits.
	var/list/rogue_pollen_sources
	/// Ratwood's starter hive: it comes with a queen of its own and a few bees.
	var/rogue_stocked = FALSE
	/// Deciseconds towards the next tick of the hive.
	var/rogue_tick_time = 0

/obj/structure/apiary/starter
	rogue_stocked = TRUE

/obj/structure/apiary/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	rogue_max_bees = APIARY_MAX_BEES
	if(!rogue_husbandry_enabled())
		return
	if(rogue_stocked)
		rogue_bees = max(rogue_bees, APIARY_STARTER_BEES)
		var/obj/item/queen_bee/queen = new(src)
		queen.rogue_randomize()
		rogue_insert_queen(queen, quiet = TRUE)
	START_PROCESSING(SSobj, src)
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/apiary/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/effect/rogue_bees/group as anything in rogue_bee_groups)
		qdel(group)
	rogue_bee_groups = null
	QDEL_NULL(rogue_queen)
	rogue_pollen_sources = null
	return ..()

/// The queen is taken out or dies of old age: the hive is without her.
/obj/structure/apiary/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rogue_queen)
		rogue_queen = null

/// Ratwood update_icon_state(): the box shows its honeycombs.
/obj/structure/apiary/update_icon_state()
	icon_state = rogue_combs > 0 ? "beebox-full" : "beebox-empty"
	return ..()

/// Azure Peak's apiary examine(): whether there is a queen, sleeping bees, honeycombs and pollen.
/obj/structure/apiary/examine(mob/user)
	. = ..()
	if(!rogue_husbandry_enabled())
		return
	if(rogue_queen)
		. += span_green("A queen is present within the hive, her quiet presence seeming to keep the colony in order.")
	else
		. += span_warning("There is no queen within the hive. The colony seems strangely unsettled.")
	if(rogue_bees_asleep > 0)
		. += span_notice("I can hear the soft, muffled hum of sleeping bees within.")
	if(rogue_combs <= 0)
		. += span_notice("There are no honeycombs ready to harvest.")
	else if(rogue_combs >= APIARY_MAX_COMBS)
		. += span_green("The hive is full to brimming with honey, swollen with the fruits of the colony's labor.")
	else if(rogue_combs > 2)
		. += span_green("Several heavy honeycombs fill the hive, rich with the promise of sweet honey.")
	else
		. += span_notice("A little honeycomb can be seen within the hive, though there is still room for more.")
	if(rogue_pollen > 0)
		. += span_notice("A warm, sweet scent of pollen and wax clings to the hive.")

/obj/structure/apiary/process(seconds_per_tick)
	rogue_tick_time += seconds_per_tick SECONDS
	while(rogue_tick_time >= APIARY_TICK)
		rogue_tick_time -= APIARY_TICK
		rogue_hive_tick()

/// Ratwood apiary process(): one tick of the colony - work the pollen, raise and send out bees, tend the bees on the wing, sicken,
/// dwindle without a queen, swarm when crowded.
/obj/structure/apiary/proc/rogue_hive_tick()
	var/stay_home = rogue_bee_weather()
	rogue_work_pollen()
	if(rogue_bees_out + rogue_bees < rogue_max_bees)
		rogue_raise_bee()
	if(rogue_bees > 0 && !stay_home)
		rogue_send_bee()
	rogue_tend_groups(stay_home)
	if(rogue_disease)
		rogue_run_disease()
	rogue_catch_disease()
	if(!rogue_queen)
		if(rogue_bees > 0 && prob(APIARY_QUEENLESS_LOSS))
			rogue_bees--
	else if(rogue_bees_out + rogue_bees < rogue_max_bees && prob(APIARY_QUEEN_BROOD_CHANCE))
		rogue_raise_bee()
	if(rogue_queen && rogue_bees > rogue_max_bees * APIARY_SWARM_SHARE)
		rogue_build_swarm()

/// Ratwood process_comb_gain(): the bees at home work the pollen into comb - half a point each, rounded up for the colony, more under an
/// efficient queen - a honeycomb for every apiary_comb_work of it. Once the combs are full the rest of the pollen is lost.
/obj/structure/apiary/proc/rogue_work_pollen()
	if(rogue_pollen <= 0)
		return
	var/rate = CEILING(rogue_bees * APIARY_WORK_PER_BEE, 1)
	if(rogue_queen)
		rate *= rogue_queen.rogue_efficiency
	var/worked = min(rate, rogue_pollen)
	rogue_pollen -= worked
	rogue_comb_progress += worked
	var/comb_work = APIARY_COMB_WORK
	if(rogue_comb_progress > comb_work)
		rogue_combs = min(rogue_combs + 1, APIARY_MAX_COMBS)
		rogue_comb_progress -= comb_work
		update_appearance(UPDATE_ICON_STATE)
	rogue_comb_progress = min(rogue_comb_progress, comb_work)
	if(rogue_combs >= APIARY_MAX_COMBS)
		rogue_pollen = 0

/// Ratwood try_create_bees(): the comb work raises a new bee while the colony has room.
/obj/structure/apiary/proc/rogue_raise_bee()
	if(rogue_comb_progress < APIARY_BEE_COST || rogue_bees_out + rogue_bees + rogue_bees_asleep > rogue_max_bees)
		return
	rogue_comb_progress -= APIARY_BEE_COST
	rogue_bees++

/// Ratwood try_send_bees_out(): while there is no pollen to work, or the combs are full, a bee goes out - into a small group on the
/// wing, or as a group of its own.
/obj/structure/apiary/proc/rogue_send_bee()
	if(rogue_pollen > 0 && rogue_combs < APIARY_MAX_COMBS)
		return
	rogue_bees--
	rogue_bees_out++
	for(var/obj/effect/rogue_bees/group as anything in rogue_bee_groups)
		if(group.count <= BEE_GROUP_JOIN_MAX)
			group.join(1)
			return
	new /obj/effect/rogue_bees(get_turf(src), src, 1)

/// Ratwood process_bee_objects(): rain or snow calls the bees home; idle bees pollinate where they are or are sent to a crop or a herb.
/obj/structure/apiary/proc/rogue_tend_groups(stay_home)
	if(!length(rogue_bee_groups))
		return
	var/list/flowers
	for(var/obj/effect/rogue_bees/group as anything in rogue_bee_groups)
		if(stay_home)
			group.go_home()
			continue
		if(group.pollinating || group.target || group.try_pollinate())
			continue
		if(isnull(flowers))
			flowers = rogue_flowers()
		group.pick_target(flowers)

/// Ratwood give_bee_target(): what the bees may pollinate in sight of the hive - soil with a crop in it, and herbs.
/obj/structure/apiary/proc/rogue_flowers()
	. = list()
	for(var/obj/structure/flower in view(BEE_TARGET_RANGE, src))
		if(istype(flower, /obj/structure/flora/roguegrass/herb))
			. += flower
		else if(istype(flower, /obj/structure/soil))
			var/obj/structure/soil/soil = flower
			if(soil.plant)
				. += soil

/// Ratwood record_pollen_source(): the hive remembers what its bees visited.
/obj/structure/apiary/proc/rogue_record_pollen(plant_type)
	LAZYINITLIST(rogue_pollen_sources)
	rogue_pollen_sources[plant_type] += 1

/// Ratwood on_bee_enter() and finish_sleep(): bees back home rest a while before they count among the bees at home again.
/obj/structure/apiary/proc/rogue_wake(count)
	var/woken = min(count, rogue_bees_asleep)
	rogue_bees_asleep -= woken
	rogue_bees += woken

/// Ratwood transfer_genetics(): bees take after their queen, give or take a little.
/obj/structure/apiary/proc/rogue_bee_genes(obj/effect/rogue_bees/group)
	if(!rogue_queen)
		return
	group.efficiency = clamp(rogue_queen.rogue_efficiency + BEE_TRAIT_DRIFT * rand(-100, 100) / 100, BEE_TRAIT_MIN, BEE_TRAIT_MAX)
	group.aggression = clamp(rogue_queen.rogue_aggression + rand(-BEE_AGGRESSION_DRIFT, BEE_AGGRESSION_DRIFT), 0, 100)
	group.bee_color = rogue_queen.rogue_bee_color

/// Ratwood insert_queen(): the queen settles in the hive, and the colony may grow bigger the more efficient she is.
/obj/structure/apiary/proc/rogue_insert_queen(obj/item/queen_bee/queen, quiet = FALSE)
	rogue_queen = queen
	rogue_max_bees = APIARY_MAX_BEES + queen.rogue_efficiency * APIARY_MAX_BEES_PER_EFFICIENCY
	if(queen.loc != src)
		queen.forceMove(src)
	if(!quiet)
		visible_message(span_notice("The bees in [src] welcome their new queen!"))

/// Ratwood attack_hand(): a protected beekeeper's open hand takes the queen out; anyone takes the honeycombs, unless the bees of an
/// unprotected one take offence at it, as their queen's temper wills.
/obj/structure/apiary/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !isliving(user) || !rogue_husbandry_enabled())
		return
	var/mob/living/keeper = user
	var/protected = rogue_bee_protected(keeper)
	if(rogue_queen && protected && istype(keeper.rogue_active_intent(), /datum/intent/unarmed/help))
		INVOKE_ASYNC(src, PROC_REF(rogue_take_queen), keeper)
		return TRUE
	if(rogue_combs <= 0)
		return
	if(!protected && rogue_queen && prob(rogue_queen.rogue_aggression))
		rogue_agitate(APIARY_AGITATE_CHANCE, keeper)
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(rogue_take_honey), keeper)
	return TRUE

/// Ratwood attackby() with a queen: she goes into a hive that has none, and the hive is stocked with a few bees if it has fewer
/// (Ratwood put a new stocked hive with a queen of its own in its place).
/obj/structure/apiary/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/queen_bee) || !rogue_husbandry_enabled())
		return ..()
	if(rogue_queen)
		to_chat(user, span_warning("There's already a queen!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	rogue_bees = max(rogue_bees, APIARY_STARTER_BEES)
	rogue_insert_queen(tool)
	return ITEM_INTERACT_SUCCESS

/// Ratwood attack_hand(): the honeycombs are taken out a few seconds later.
/obj/structure/apiary/proc/rogue_take_honey(mob/living/user)
	user.visible_message(span_notice("[user] starts to collect combs from [src]."), span_notice("I start to collect combs from [src]."))
	if(!do_after(user, APIARY_HONEY_TIME, target = src) || rogue_combs <= 0)
		return
	rogue_spill_honey()

/// The honeycombs come out by the hive, of the honey the bees made; returns them.
/obj/structure/apiary/proc/rogue_spill_honey()
	. = list()
	var/honey_type = rogue_honey_type()
	var/turf/here = get_turf(src)
	for(var/comb in 1 to rogue_combs)
		. += new honey_type(here)
	rogue_combs = 0
	update_appearance(UPDATE_ICON_STATE)

/// Ratwood determine_honey_type(): the honey of what the bees visited most since the honey was last taken - Ratwood's medicinal honey
/// from poppies, plain honey from anything else (and from poppies too until the porter brings the medicinal one).
/obj/structure/apiary/proc/rogue_honey_type()
	var/static/poppy_honey = text2path(BEE_POPPY_HONEY)
	var/favourite
	var/visits = 0
	for(var/plant_type in rogue_pollen_sources)
		if(rogue_pollen_sources[plant_type] > visits)
			visits = rogue_pollen_sources[plant_type]
			favourite = plant_type
	rogue_pollen_sources = null
	if(favourite == /datum/plant_def/poppy && poppy_honey)
		return poppy_honey
	return /obj/item/reagent_containers/food/snacks/rogue/honey

/// Ratwood attack_hand(): the queen is taken out after a careful while, and the bees take offence at it.
/obj/structure/apiary/proc/rogue_take_queen(mob/living/user)
	user.visible_message(span_notice("[user] carefully reaches into [src]."), span_notice("I carefully reach into [src] for the queen."))
	if(!do_after(user, APIARY_QUEEN_TIME, target = src) || QDELETED(rogue_queen))
		return
	var/obj/item/queen_bee/queen = rogue_queen
	if(!user.put_in_hands(queen))
		queen.forceMove(drop_location())
	to_chat(user, span_notice("I extract the queen bee from [src]."))
	rogue_agitate(APIARY_AGITATE_CHANCE, user)

/// Ratwood agitate_bees(): a few bees swarm out of the hive angrily and sting whoever they find next to them for a while. Ratwood
/// marked the one who angered them as stung already, so they never stung that one; here they do.
/obj/structure/apiary/proc/rogue_agitate(chance, mob/living/user)
	if(rogue_bees <= 0 || !prob(chance))
		return
	var/angry = rand(1, min(APIARY_AGITATE_MAX, rogue_bees))
	rogue_bees -= angry
	rogue_bees_out += angry
	visible_message(span_warning("Bees swarm out of [src] angrily!"))
	var/aggression = rogue_queen ? rogue_queen.rogue_aggression : APIARY_QUEENLESS_AGGRESSION
	for(var/bee in 1 to angry)
		var/obj/effect/rogue_bees/group = new(get_turf(src), src, 1)
		group.aggression = aggression
		group.agitate(APIARY_AGITATE_TICKS)

/// Ratwood process_disease(): the disease worsens a step every hundred ticks and does its harm; at its worst the colony dies of it.
/obj/structure/apiary/proc/rogue_run_disease()
	if(++rogue_disease_progress >= BEE_DISEASE_PROGRESS)
		rogue_disease_progress = 0
		rogue_disease_severity += APIARY_DISEASE_STEP
	switch(rogue_disease)
		if(BEE_DISEASE_MITES)
			if(rogue_bees > 0 && prob(rogue_disease_severity * APIARY_MITE_SHARE))
				rogue_bees--
				if(prob(BEE_MITE_FALL_CHANCE))
					visible_message(span_warning("A bee falls from [src], twitching."))
		if(BEE_DISEASE_FOULBROOD)
			if(prob(rogue_disease_severity * APIARY_FOULBROOD_SHARE))
				rogue_comb_progress = max(rogue_comb_progress - 1, 0)
		if(BEE_DISEASE_MOTHS)
			if(rogue_combs > 0 && prob(rogue_disease_severity * APIARY_MOTH_SHARE))
				rogue_combs--
				update_appearance(UPDATE_ICON_STATE)
	if(rogue_disease_severity >= BEE_DISEASE_FATAL)
		rogue_collapse()

/// Ratwood process_disease() at its worst: the colony and its queen die, and the hive is healthy and empty again.
/obj/structure/apiary/proc/rogue_collapse()
	visible_message(span_warning("The colony in [src] collapses from disease!"))
	for(var/obj/effect/rogue_bees/group as anything in rogue_bee_groups)
		qdel(group)
	rogue_bees = 0
	rogue_bees_out = 0
	rogue_bees_asleep = 0
	rogue_disease = null
	rogue_disease_severity = 0
	rogue_disease_progress = 0
	QDEL_NULL(rogue_queen)

/// Ratwood check_for_disease(): now and then a hive may fall sick - more likely with a sick hive in sight, less under a hardy queen.
/obj/structure/apiary/proc/rogue_catch_disease()
	if(rogue_disease || !prob(APIARY_DISEASE_ROLL))
		return
	var/chance = APIARY_DISEASE_CHANCE
	for(var/obj/structure/apiary/other in view(APIARY_DISEASE_RANGE, src))
		if(other.rogue_disease)
			chance = APIARY_DISEASE_NEARBY_CHANCE
			break
	if(rogue_queen)
		chance = max(chance - rogue_queen.rogue_disease_resistance * APIARY_DISEASE_RESISTANCE, 0)
	if(prob(chance))
		rogue_infect()

/// The hive falls sick of one of Ratwood's bee diseases.
/obj/structure/apiary/proc/rogue_infect(disease = pick(BEE_DISEASE_MITES, BEE_DISEASE_FOULBROOD, BEE_DISEASE_MOTHS))
	rogue_disease = disease
	rogue_disease_severity = APIARY_DISEASE_START
	rogue_disease_progress = 0
	visible_message(span_warning("The bees in [src] seem agitated."))

/// Ratwood process_swarm(): a crowded hive grows restless, a while after the last swarm, until a swarm leaves it.
/obj/structure/apiary/proc/rogue_build_swarm()
	if(world.time < rogue_last_swarm + APIARY_SWARM_COOLDOWN)
		return
	rogue_swarm_progress += APIARY_SWARM_RATE
	if(rogue_swarm_progress > BEE_SWARM_RESTLESS && prob(BEE_SWARM_RESTLESS_CHANCE))
		visible_message(span_warning("The bees in [src] are extremely active!"))
	if(rogue_swarm_progress >= BEE_SWARM_READY)
		rogue_release_swarm()

/// Ratwood create_swarm(): a young queen taking after the old one leads part of the colony out to find a home of its own.
/obj/structure/apiary/proc/rogue_release_swarm()
	rogue_swarm_progress = 0
	rogue_last_swarm = world.time
	var/size = min(rand(SWARM_SIZE_MIN, SWARM_SIZE_MAX), rogue_bees)
	rogue_bees -= size
	var/obj/item/queen_bee/young_queen = new(get_turf(src))
	young_queen.rogue_inherit(rogue_queen)
	visible_message(span_warning("A swarm of bees emerges from [src]!"))
	var/obj/effect/rogue_bee_swarm/swarm = new(get_turf(src), size, young_queen)
	swarm.find_new_home()

/// Ratwood's bees stay at home while it rains or snows (try_send_bees_out(), process_bee_objects()).
/proc/rogue_bee_weather()
	var/datum/weather/particle/rockhill/weather = SSrockhill_weather.active_weather()
	return istype(weather, /datum/weather/particle/rockhill/rain_gentle) || istype(weather, /datum/weather/particle/rockhill/rain_storm) \
		|| istype(weather, /datum/weather/particle/rockhill/snow_gentle) || istype(weather, /datum/weather/particle/rockhill/snow_storm)

/// Ratwood is_wearing_bee_protection(): headgear over the mouth and armour over the chest keep the bees off a beekeeper.
/proc/rogue_bee_protected(mob/living/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/keeper = user
	return keeper.is_mouth_covered(ITEM_SLOT_HEAD) && keeper.wear_suit && (keeper.wear_suit.rogue_coverage_flags() & CHEST)

/// A group of bees on the wing (Ratwood /obj/effect/bees): it flies a tile every 2 seconds towards what it is after - a crop or a herb,
/// or its hive - pollinates where it lands, carries the pollen home, and while angry stings whoever stands next to it.
/obj/effect/rogue_bees
	name = "bees"
	desc = "A buzzing cloud of bees."
	icon = APIARY_ICON
	icon_state = "bee"
	layer = ABOVE_MOB_LAYER
	pass_flags = PASSTABLE | PASSMOB
	movement_type = FLYING
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The hive the bees come from and fly home to.
	var/obj/structure/apiary/hive
	/// Ratwood bee_count: bees in the group.
	var/count = 1
	/// What the bees fly to: a crop, a herb, or their hive.
	var/atom/target
	/// Ratwood stored_pollen: pollen the bees carry.
	var/pollen = 0
	/// Ratwood pollinating, and the deciseconds of it left.
	var/pollinating = FALSE
	var/pollinate_left = 0
	/// Ratwood last_pollinated: the tile last pollinated, which is not pollinated twice running.
	var/turf/last_pollinated
	/// Ratwood bee_efficiency, bee_aggression (percent) and bee_color, from the queen.
	var/efficiency = 1
	var/aggression = 0
	var/bee_color = "#FFD700"
	/// Ratwood agitation_countdown: ticks the bees stay angry.
	var/angry_ticks = 0
	/// Ratwood attacked_mobs: weakrefs of those these bees have stung while angry, each stung once.
	var/list/stung
	/// Moves that failed towards the target, and the targets given up on for a while, weakref = world.time it may be tried again
	/// (Azure Peak target_move_failures, bad_targets).
	var/blocked_moves = 0
	var/list/given_up
	/// Deciseconds towards the next tick of the group.
	var/tick_time = 0

/obj/effect/rogue_bees/Initialize(mapload, obj/structure/apiary/home, bees = 1)
	. = ..()
	count = bees
	if(home)
		hive = home
		LAZYADD(home.rogue_bee_groups, src)
		home.rogue_bee_genes(src)
	set_glide_size(DELAY_TO_GLIDE_SIZE(APIARY_TICK))
	update_appearance(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/effect/rogue_bees/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(hive)
		LAZYREMOVE(hive.rogue_bee_groups, src)
		hive = null
	target = null
	stung = null
	given_up = null
	return ..()

/// Ratwood update_overlays(): the other bees of the group buzz around the first.
/obj/effect/rogue_bees/update_overlays()
	. = ..()
	for(var/bee in 1 to count - 1)
		var/mutable_appearance/other = mutable_appearance(icon, icon_state)
		other.pixel_x = rand(-BEE_SPREAD, BEE_SPREAD)
		other.pixel_y = rand(-BEE_SPREAD, BEE_SPREAD)
		other.color = bee_color
		. += other

/// Another bee of the hive joins the group on the wing (Ratwood merge_target).
/obj/effect/rogue_bees/proc/join(bees)
	count += bees
	update_appearance(UPDATE_OVERLAYS)

/obj/effect/rogue_bees/process(seconds_per_tick)
	tick_time += seconds_per_tick SECONDS
	while(tick_time >= APIARY_TICK)
		tick_time -= APIARY_TICK
		bee_tick()
		if(QDELETED(src))
			return PROCESS_KILL

/// Ratwood bees process(): the pollinating goes on, or a tile towards the target - into the hive, or onto the crop or herb to
/// pollinate it - and angry bees sting. Bees at work on a flower stay on it until they are done (Ratwood's flew off and finished
/// the flower from afar).
/obj/effect/rogue_bees/proc/bee_tick()
	if(pollinating)
		pollinate_left -= APIARY_TICK
		if(pollinate_left <= 0)
			finish_pollinating()
	else if(target)
		var/turf/target_turf = get_turf(target)
		if(QDELETED(target) || target_turf?.z != z)
			target = null
		else
			if(get_dist(src, target) > 0)
				fly_towards()
				if(QDELETED(src))
					return
			if(target && get_dist(src, target) == 0)
				if(target == hive)
					enter_hive()
					return
				target = null
				try_pollinate()
	if(angry_ticks > 0)
		angry_ticks--
		sting_nearby()
	else if(stung)
		stung = null

/// A tile towards the target, or around what is in the way. After a few blocked moves the bees give up on a crop or a herb for a
/// while (Azure Peak), or, bound home, slip into the hive anyway.
/obj/effect/rogue_bees/proc/fly_towards()
	var/heading = get_dir(src, target)
	for(var/direction in list(heading, turn(heading, 45), turn(heading, -45)))
		var/turf/next = get_step(src, direction)
		if(next && Move(next, direction))
			blocked_moves = 0
			return
	if(++blocked_moves < BEE_BLOCKED_MOVES)
		return
	blocked_moves = 0
	if(target == hive)
		enter_hive()
		return
	LAZYSET(given_up, WEAKREF(target), world.time + BEE_GIVE_UP_TIME)
	target = null

/// Ratwood give_bee_target(): idle bees pick something to pollinate, not one they gave up on lately.
/obj/effect/rogue_bees/proc/pick_target(list/flowers)
	var/list/choices = flowers
	if(length(given_up))
		choices = list()
		for(var/atom/flower as anything in flowers)
			var/datum/weakref/flower_ref = WEAKREF(flower)
			if(given_up[flower_ref] > world.time)
				continue
			given_up -= flower_ref
			choices += flower
	if(length(choices))
		target = pick(choices)

/// Ratwood try_pollinate(): bees on a crop or a herb, not the one they pollinated last, start pollinating it.
/obj/effect/rogue_bees/proc/try_pollinate()
	if(pollinating)
		return TRUE
	var/turf/here = get_turf(src)
	if(!here || here == last_pollinated)
		return FALSE
	if(!(locate(/obj/structure/soil) in here) && !(locate(/obj/structure/flora/roguegrass/herb) in here))
		return FALSE
	pollinating = TRUE
	pollinate_left = BEE_POLLINATE_TIME / efficiency
	return TRUE

/// Ratwood finish_pollinating(): the soil is pollinated and grows faster for a while, the bees gather pollen and tell the hive what they
/// visited, and fly home once they carry enough.
/obj/effect/rogue_bees/proc/finish_pollinating()
	pollinating = FALSE
	var/turf/here = get_turf(src)
	last_pollinated = here
	pollen += rand(BEE_POLLEN_MIN, BEE_POLLEN_MAX) * count * efficiency
	var/obj/structure/soil/soil = locate() in here
	if(soil)
		soil.pollinate()
		if(soil.plant)
			hive?.rogue_record_pollen(soil.plant.type)
	var/obj/structure/flora/roguegrass/herb/herb = locate() in here
	if(herb)
		hive?.rogue_record_pollen(herb.type)
	if(pollen > BEE_POLLEN_LOAD * count)
		go_home()

/// Ratwood return_to_hive().
/obj/effect/rogue_bees/proc/go_home()
	if(hive)
		target = hive

/// Ratwood enter_hive(): the bees go in with their pollen and rest a while before they go out again.
/obj/effect/rogue_bees/proc/enter_hive()
	if(hive)
		hive.rogue_bees_out = max(hive.rogue_bees_out - count, 0)
		hive.rogue_bees_asleep += count
		hive.rogue_pollen += pollen
		addtimer(CALLBACK(hive, TYPE_PROC_REF(/obj/structure/apiary, rogue_wake), count), BEE_REST_TIME)
	qdel(src)

/// Ratwood agitate(): the bees are angry for a while.
/obj/effect/rogue_bees/proc/agitate(ticks)
	angry_ticks = ticks

/// Ratwood attack_nearby_targets(): now and then, as their aggression wills, angry bees sting someone unprotected next to them whom they
/// have not stung yet. Ratwood takes the aggression for the chance in hundredths of a percent (bee_sting_share).
/obj/effect/rogue_bees/proc/sting_nearby()
	if(pollinating || !prob(aggression * BEE_STING_SHARE))
		return
	for(var/mob/living/carbon/human/victim in view(1, src))
		if(victim.stat == DEAD || LAZYFIND(stung, WEAKREF(victim)) || rogue_bee_protected(victim))
			continue
		sting(victim)
		return

/// Ratwood attack_mob(): a sting does a little toxin harm and leaves venom, and angers the bees around.
/obj/effect/rogue_bees/proc/sting(mob/living/carbon/human/victim)
	var/obj/item/bodypart/part = victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD))
	var/where = part ? part.plaintext_zone : "body"
	victim.visible_message(span_danger("\The [src] sting [victim] in the [where]!"), span_userdanger("I feel a sharp stinging pain in my [where]!"))
	victim.adjust_tox_loss(BEE_STING_TOXIN)
	victim.reagents?.add_reagent(/datum/reagent/toxin/venom, BEE_STING_VENOM)
	LAZYADD(stung, WEAKREF(victim))
	for(var/obj/effect/rogue_bees/others in view(BEE_STING_SPREAD_RANGE, src))
		if(others != src && prob(BEE_STING_SPREAD_CHANCE))
			others.agitate(BEE_STING_SPREAD_TICKS)

/// A swarm with a young queen looking for a home (Ratwood /obj/effect/bee_swarm): it drifts about and now and then, on a free tile,
/// settles into a new hive of its own; one that finds no home in time disperses, and its queen dies.
/obj/effect/rogue_bee_swarm
	name = "bee swarm"
	desc = "A buzzing swarm of bees looking for a place to build a new hive."
	icon = APIARY_ICON
	icon_state = "bee"
	layer = ABOVE_MOB_LAYER
	pass_flags = PASSTABLE | PASSMOB
	movement_type = FLYING
	/// Ratwood bee_count: bees in the swarm.
	var/count = 1
	/// Ratwood queen_bee: the young queen, carried inside.
	var/obj/item/queen_bee/queen
	/// Ratwood search_time: ticks since the swarm last looked for a home.
	var/search_ticks = 0
	/// Deciseconds towards the next tick of the swarm.
	var/tick_time = 0

/obj/effect/rogue_bee_swarm/Initialize(mapload, size = 1, obj/item/queen_bee/young_queen)
	. = ..()
	count = size
	if(young_queen)
		queen = young_queen
		young_queen.forceMove(src)
	set_glide_size(DELAY_TO_GLIDE_SIZE(APIARY_TICK))
	update_appearance(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)
	addtimer(CALLBACK(src, PROC_REF(disperse)), SWARM_LIFETIME)

/obj/effect/rogue_bee_swarm/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(queen)
	return ..()

/obj/effect/rogue_bee_swarm/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == queen)
		queen = null

/obj/effect/rogue_bee_swarm/update_overlays()
	. = ..()
	for(var/bee in 1 to min(count - 1, BEE_SWARM_DRAWN))
		var/mutable_appearance/other = mutable_appearance(icon, icon_state)
		other.pixel_x = rand(-BEE_SPREAD, BEE_SPREAD)
		other.pixel_y = rand(-BEE_SPREAD, BEE_SPREAD)
		. += other

/obj/effect/rogue_bee_swarm/process(seconds_per_tick)
	tick_time += seconds_per_tick SECONDS
	while(tick_time >= APIARY_TICK)
		tick_time -= APIARY_TICK
		if(prob(SWARM_WANDER_CHANCE))
			var/direction = pick(GLOB.alldirs)
			var/turf/next = get_step(src, direction)
			if(next)
				Move(next, direction)
		if(++search_ticks >= SWARM_SEARCH_TICKS)
			search_ticks = 0
			find_new_home()
			if(QDELETED(src))
				return PROCESS_KILL

/// Ratwood find_new_home(): on a free tile with no hive the swarm may settle.
/obj/effect/rogue_bee_swarm/proc/find_new_home()
	var/turf/here = loc
	if(!isturf(here) || here.density || (locate(/obj/structure/apiary) in here))
		return
	for(var/atom/movable/thing as anything in here)
		if(thing != src && thing.density)
			return
	if(prob(SWARM_SETTLE_CHANCE))
		settle()

/// Ratwood establish_hive(): the swarm becomes a hive with its queen.
/obj/effect/rogue_bee_swarm/proc/settle()
	var/obj/structure/apiary/hive = new(loc)
	hive.rogue_bees = count
	if(queen)
		hive.rogue_insert_queen(queen, quiet = TRUE)
	visible_message(span_notice("The swarm has established a new hive!"))
	qdel(src)

/// Ratwood swarm_timeout().
/obj/effect/rogue_bee_swarm/proc/disperse()
	visible_message(span_notice("The bee swarm disperses without finding a suitable home."))
	qdel(src)

/// Ratwood's queen (apiary.dm /obj/item/queen_bee) is TG's queen bee item, the one the merchant sells: on medieval maps she looks as
/// Ratwood's, carries her colony's traits and grows old.
/obj/item/queen_bee
	/// Ratwood bee_efficiency: how much her bees gather and work, and how big her colony may grow.
	var/rogue_efficiency = 1
	/// Ratwood bee_aggression: the chance in percent her bees take offence at an unprotected beekeeper.
	var/rogue_aggression = 0
	/// Ratwood bee_color: the colour of her bees.
	var/rogue_bee_color = "#FFD700"
	/// Ratwood bee_disease_resistance: how well her colony withstands disease.
	var/rogue_disease_resistance = 1
	/// Ratwood queen_age (days) and queen_health (out of 100): an old queen weakens and dies.
	var/rogue_age = 0
	var/rogue_health = 100
	/// Deciseconds towards the next tick of her age.
	var/rogue_tick_time = 0

/obj/item/queen_bee/Initialize(mapload)
	. = ..()
	if(!rogue_husbandry_enabled())
		return
	icon = APIARY_ICON
	icon_state = "queen_bee"
	START_PROCESSING(SSobj, src)

/obj/item/queen_bee/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/// Ratwood queen_bee process(): she ages, weakens once old, and dies of old age.
/obj/item/queen_bee/process(seconds_per_tick)
	rogue_tick_time += seconds_per_tick SECONDS
	while(rogue_tick_time >= APIARY_TICK)
		rogue_tick_time -= APIARY_TICK
		rogue_age += QUEEN_AGE_RATE
		if(rogue_age > QUEEN_OLD_AGE)
			rogue_health -= QUEEN_DECLINE
		if(rogue_health <= 0)
			visible_message(span_warning("[src] dies of old age!"))
			qdel(src)
			return PROCESS_KILL

/// Ratwood create_new_queen(): a queen raised in a hive is born with traits of her own.
/obj/item/queen_bee/proc/rogue_randomize()
	rogue_efficiency = 1 + QUEEN_TRAIT_SPREAD * rand(-100, 100) / 100
	rogue_aggression = rand(0, QUEEN_AGGRESSION_MAX)
	rogue_disease_resistance = 1 + QUEEN_TRAIT_SPREAD * rand(-100, 100) / 100
	rogue_bee_color = pick(BEE_QUEEN_COLORS)

/// Ratwood create_swarm(): a swarm's queen takes after the old one, give or take more than a bee does.
/obj/item/queen_bee/proc/rogue_inherit(obj/item/queen_bee/mother)
	if(!mother)
		rogue_randomize()
		return
	rogue_efficiency = clamp(mother.rogue_efficiency + SWARM_TRAIT_DRIFT * rand(-100, 100) / 100, BEE_TRAIT_MIN, BEE_TRAIT_MAX)
	rogue_aggression = clamp(mother.rogue_aggression + rand(-SWARM_AGGRESSION_DRIFT, SWARM_AGGRESSION_DRIFT), 0, 100)
	rogue_disease_resistance = clamp(mother.rogue_disease_resistance + SWARM_TRAIT_DRIFT * rand(-100, 100) / 100, BEE_TRAIT_MIN, BEE_TRAIT_MAX)
	rogue_bee_color = mother.rogue_bee_color

#undef APIARY_ICON
#undef APIARY_TICK
#undef BEE_DISEASE_MITES
#undef BEE_DISEASE_FOULBROOD
#undef BEE_DISEASE_MOTHS
#undef BEE_TRAIT_MIN
#undef BEE_TRAIT_MAX
#undef BEE_QUEEN_COLORS
#undef BEE_DISEASE_PROGRESS
#undef BEE_DISEASE_FATAL
#undef BEE_MITE_FALL_CHANCE
#undef BEE_SWARM_RESTLESS
#undef BEE_SWARM_RESTLESS_CHANCE
#undef BEE_SWARM_READY
#undef BEE_SWARM_DRAWN
#undef BEE_SPREAD
#undef BEE_POPPY_HONEY
#undef APIARY_MAX_BEES
#undef APIARY_MAX_BEES_PER_EFFICIENCY
#undef APIARY_STARTER_BEES
#undef APIARY_MAX_COMBS
#undef APIARY_COMB_WORK
#undef APIARY_WORK_PER_BEE
#undef APIARY_BEE_COST
#undef APIARY_QUEEN_BROOD_CHANCE
#undef APIARY_QUEENLESS_LOSS
#undef APIARY_HONEY_TIME
#undef APIARY_QUEEN_TIME
#undef APIARY_AGITATE_CHANCE
#undef APIARY_AGITATE_MAX
#undef APIARY_AGITATE_TICKS
#undef APIARY_QUEENLESS_AGGRESSION
#undef APIARY_DISEASE_ROLL
#undef APIARY_DISEASE_CHANCE
#undef APIARY_DISEASE_NEARBY_CHANCE
#undef APIARY_DISEASE_RANGE
#undef APIARY_DISEASE_RESISTANCE
#undef APIARY_DISEASE_START
#undef APIARY_DISEASE_STEP
#undef APIARY_MITE_SHARE
#undef APIARY_FOULBROOD_SHARE
#undef APIARY_MOTH_SHARE
#undef APIARY_SWARM_SHARE
#undef APIARY_SWARM_COOLDOWN
#undef APIARY_SWARM_RATE
#undef BEE_GROUP_JOIN_MAX
#undef BEE_TARGET_RANGE
#undef BEE_POLLINATE_TIME
#undef BEE_POLLEN_MIN
#undef BEE_POLLEN_MAX
#undef BEE_POLLEN_LOAD
#undef BEE_REST_TIME
#undef BEE_BLOCKED_MOVES
#undef BEE_GIVE_UP_TIME
#undef BEE_STING_SHARE
#undef BEE_STING_TOXIN
#undef BEE_STING_VENOM
#undef BEE_STING_SPREAD_RANGE
#undef BEE_STING_SPREAD_CHANCE
#undef BEE_STING_SPREAD_TICKS
#undef BEE_TRAIT_DRIFT
#undef BEE_AGGRESSION_DRIFT
#undef SWARM_SIZE_MIN
#undef SWARM_SIZE_MAX
#undef SWARM_LIFETIME
#undef SWARM_SEARCH_TICKS
#undef SWARM_SETTLE_CHANCE
#undef SWARM_WANDER_CHANCE
#undef SWARM_TRAIT_DRIFT
#undef SWARM_AGGRESSION_DRIFT
#undef QUEEN_TRAIT_SPREAD
#undef QUEEN_AGGRESSION_MAX
#undef QUEEN_AGE_RATE
#undef QUEEN_OLD_AGE
#undef QUEEN_DECLINE
