/// Ratwood's stalks (code/modules/farming/chaff.dm): a harvest of grain comes as bundles of stalks. A thresher beats the grain out
/// of every bundle on a tile at once (farming/tools.dm), a club out of some, bare hands shuck one bundle slowly; each bundle gives
/// its grain and a fiber. A wielded pitchfork carries the bundles about (farming/tools.dm).
/obj/item/natural/chaff
	/// The grain beaten or shucked out of the stalks (Ratwood foodextracted).
	var/foodextracted = null
	/// Whether a thresher or a club beats the grain out (Ratwood canthresh).
	var/canthresh = TRUE

/obj/item/natural/chaff/wheat
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/wheat

/obj/item/natural/chaff/oat
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/oat

/// Rice stalks are Ratwood's but not yet in the port: declared here only for their grain, so rice is not sown before the porter
/// brings their sprite (/datum/plant_def/can_grow()).
/obj/item/natural/chaff/rice
	foodextracted = /obj/item/reagent_containers/food/snacks/grown/rice

/// Ratwood thresh(): the grain and a fiber fall out where the bundle lay.
/obj/item/natural/chaff/proc/thresh()
	if(!foodextracted || !canthresh)
		return
	var/atom/spot = drop_location()
	new foodextracted(spot)
	new /obj/item/natural/fibers(spot)
	qdel(src)

/// Ratwood attack_right() with an empty hand: shuck the bundle, the grain into the hand.
/obj/item/natural/chaff/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !foodextracted || !isliving(user) || user.get_active_held_item())
		return
	INVOKE_ASYNC(src, PROC_REF(rogue_shuck), user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/natural/chaff/proc/rogue_shuck(mob/living/user)
	to_chat(user, span_warning("I start to shuck [src]..."))
	if(!do_after(user, rogue_value("farm_shuck_time"), target = src, timed_action_flags = IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE))
		return
	user.visible_message(span_notice("[user] shucks [src]."), span_notice("I shuck [src]."))
	var/turf/spot = get_turf(src)
	var/obj/item/grain = new foodextracted(spot)
	user.put_in_active_hand(grain)
	new /obj/item/natural/fibers(spot)
	qdel(src)

/// Ratwood attackby(): a wielded pitchfork with the scoop intent picks up the stalks on the tile; a club beats the grain out of this
/// bundle and, by its wielder's strength and farming, out of the others on the tile.
/obj/item/natural/chaff/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!isliving(user))
		return ..()
	if(istype(tool, /obj/item/rogueweapon/pitchfork) && istype(user.rogue_active_intent(), /datum/intent/pforkdump))
		var/obj/item/rogueweapon/pitchfork/fork = tool
		if(fork.rogue_wielded && isturf(loc))
			fork.rogue_scoop(loc, user)
			return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/rogueweapon/mace/woodclub))
		rogue_club_thresh(user)
		return ITEM_INTERACT_SUCCESS
	return ..()

/obj/item/natural/chaff/proc/rogue_club_thresh(mob/living/user)
	var/chance = clamp(user.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("farm_club_strength_chance") + user.rogue_learned_rank(ROGUE_FARMING_SKILL) * rogue_value("farm_club_rank_chance"), rogue_value("farm_club_least_chance"), 100)
	for(var/obj/item/natural/chaff/stalks in get_turf(src))
		if(stalks != src && prob(chance))
			stalks.thresh()
	user.visible_message(span_notice("[user] threshes the stalks!"), span_notice("I thresh the stalks."))
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(src, pick(ROGUE_PLANTCROSS_SOUNDS), 100, FALSE)
	playsound(src, pick('modular_redtard/rockhill/sound/combat/hits/smashlimb (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (3).ogg'), 50, FALSE)
	thresh()
