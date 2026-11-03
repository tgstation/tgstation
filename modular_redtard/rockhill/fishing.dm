// Ratwood's fishing on medieval maps (roguejobs/fisher/rod.dm, worms.dm, leeches.dm, items/rogueitems/fishing_cage.dm,
// __HELPERS/fishing_hunting.dm, Neu_Food/code/raw/raw_fish.dm and raw_shellfish.dm, churchloop/artefactsten.dm). A rod with
// the cast intent thrown at water within reach waits for a bite, quicker with the Fishing skill; baited, the bite comes by
// chance (bait and skill), and the angler strikes by pulling away - stepping, turning, or using the rod - before the fish
// gets away. What bites comes from the water's catch, weighed by the bait, Abyssor's favour, luck and caution. A crayfish cage
// set in water with bait in it catches shellfish by itself. Every fish is common, rare, ultra-rare or legendary, priced and
// named for it and, if its sprite shows rarity, drawn so; dropped or thrown back into water it swims off. Catch types the
// porter has not brought (most of Ratwood's fish, Eora's cerulean aril, the sea goblin) are named by text and join the
// catch once ported.

/// Ratwood fishingMods, in the order of a bait's row: the chance the bait costs (baitpenalty), then how it draws each kind
/// of catch. A catch's row has its plain weight in the first place instead.
#define BAIT_PENALTY 1
#define CATCH_FIXED 1
#define CATCH_COMMON 2
#define CATCH_RARE 3
#define CATCH_TREASURE 4
#define CATCH_TRASH 5
#define CATCH_DANGER 6
#define CATCH_CERULEAN 7
/// The waters of Ratwood's catch tables, and the cage's and Abyssor's rod's own.
#define FISH_WATER_FRESH "fresh"
#define FISH_WATER_COAST "coast"
#define FISH_WATER_DEEP "deep"
#define FISH_WATER_MUD "mud"
#define FISH_CAGE "cage"
#define FISH_ABYSSOR "abyssor"
/// Ratwood luck bonus to rare fish and treasure: per point of fortune over the middling, up to five points, then per point.
#define FISH_LUCK_FIRST_STEPS 5
#define FISH_LUCK_FIRST_STEP 0.05
#define FISH_LUCK_LATER_STEP 0.01
/// Ratwood TRAIT_CAUTIOUS_FISHER: more rare fish and treasure, and thrice as much less danger.
#define FISH_CAUTIOUS_BONUS 0.2
#define FISH_CAUTIOUS_DANGER 3
/// Ratwood Abyssor's anglers: danger, treasure and rare fish.
#define FISH_ABYSSOR_DANGER 1.1
#define FISH_ABYSSOR_TREASURE 0.9
#define FISH_ABYSSOR_RARE 1.25
#define FISH_CAST_SOUND 'modular_redtard/rockhill/sound/items/fishing_plouf.ogg'
#define FISH_OUT_SOUND 'modular_redtard/survival/sound/fish_out.ogg'
#define FISH_JUMPSCARES list('modular_redtard/rockhill/sound/misc/jumpscare (1).ogg', 'modular_redtard/rockhill/sound/misc/jumpscare (2).ogg', 'modular_redtard/rockhill/sound/misc/jumpscare (3).ogg', 'modular_redtard/rockhill/sound/misc/jumpscare (4).ogg')

/// What makes an item bait (Ratwood isbait, baitpenalty, fishingMods), the most particular type first.
GLOBAL_LIST_INIT(rogue_fishing_baits, rogue_fishing_bait_table())
/// The catch of each water (Ratwood create*FishWeightList()), types resolved: type = its row of weights.
GLOBAL_LIST_INIT(rogue_catch_tables, rogue_build_catch_tables())

/proc/rogue_fishing_bait_table()
	// penalty, common, rare, treasure, trash, danger, cerulean
	. = list(
		/obj/item/natural/worms/leech = list(0, 0.7, 1.3, 1, 1, 1.1, 0),
		/obj/item/natural/worms/grubs = list(5, 0.85, 1.15, 1, 1, 1, 0),
		/obj/item/natural/worms = list(10, 1, 1, 1, 1, 1, 0),
		/obj/item/reagent_containers/food/snacks/rogue/cheddarslice = list(10, 0.8, 0, 0, 1, 0.5, 0),
	)
	// Eora's cerulean aril is no map item, so the porter has not brought it yet.
	var/aril = text2path("/obj/item/reagent_containers/food/snacks/eoran_aril/cerulean")
	if(aril)
		.[aril] = list(5, 0.2, 1, 1, 0, 0, 1)

/// The bait row of an item, or null when it is no bait.
/proc/rogue_bait_data(obj/item/bait)
	if(!istype(bait))
		return null
	for(var/bait_type in GLOB.rogue_fishing_baits)
		if(istype(bait, bait_type))
			return GLOB.rogue_fishing_baits[bait_type]
	return null

/// Ratwood's catch tables by text path: fixed, common, rare, treasure, trash, danger, cerulean weight of each catch.
/proc/rogue_build_catch_tables()
	var/list/rows = list(
		FISH_WATER_FRESH = list(
			"/obj/item/reagent_containers/food/snacks/fish/carp" = list(0, 270, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/sunny" = list(0, 340, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/salmon" = list(0, 0, 180, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/eel" = list(0, 180, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/glass/bottle/rogue/wine" = list(0, 0, 0, 1, 0, 0, 15),
			"/obj/item/clothing/ring/gold" = list(0, 0, 0, 1, 0, 0, 15),
			"/obj/item/storage/belt/rogue/pouch/coins/poor" = list(0, 0, 0, 1, 0, 0, 50),
			"/obj/item/storage/belt/rogue/pouch/coins/mid" = list(0, 0, 0, 0, 0, 0, 10),
			"/obj/item/grown/log/tree/stick" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/natural/cloth" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/ammo_casing/caseless/rogue/arrow" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/reagent_containers/glass/bottle/rogue" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/reagent_containers/food/snacks/smallrat" = list(1, 0, 0, 0, 0, 0, 0),
			"/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab" = list(30, 0, 0, 0, 0, 0, 0),
		),
		FISH_WATER_COAST = list(
			"/obj/item/reagent_containers/food/snacks/fish/cod" = list(0, 210, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/plaice" = list(0, 0, 70, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/sole" = list(0, 300, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/angler" = list(0, 0, 60, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/lobster" = list(0, 0, 70, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/bass" = list(0, 210, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clam" = list(0, 0, 40, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clownfish" = list(0, 0, 10, 0, 0, 0, 100),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_eel" = list(0, 0, 1, 0, 0, 0, 10),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_squid" = list(0, 0, 5, 0, 0, 0, 10),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_shark" = list(0, 0, 1, 0, 0, 0, 10),
			"/obj/item/reagent_containers/glass/bottle/rogue/wine" = list(0, 0, 0, 1, 0, 0, 15),
			"/obj/item/clothing/ring/gold" = list(0, 0, 0, 1, 0, 0, 15),
			"/obj/item/storage/belt/rogue/pouch/coins/poor" = list(0, 0, 0, 1, 0, 0, 50),
			"/obj/item/storage/belt/rogue/pouch/coins/mid" = list(0, 0, 0, 0, 0, 0, 10),
			"/obj/item/grown/log/tree/stick" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/natural/cloth" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/ammo_casing/caseless/rogue/arrow" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/reagent_containers/glass/bottle/rogue" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/reagent_containers/food/snacks/smallrat" = list(1, 0, 0, 0, 0, 0, 0),
			"/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab" = list(30, 0, 0, 0, 0, 0, 0),
		),
		FISH_WATER_DEEP = list(
			"/obj/item/reagent_containers/food/snacks/fish/cod" = list(0, 100, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/plaice" = list(0, 0, 150, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/sole" = list(0, 50, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/angler" = list(0, 0, 150, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/lobster" = list(0, 0, 100, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/bass" = list(0, 100, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clam" = list(0, 0, 150, 0, 0, 0, 0),
			"/obj/item/roguegem/oyster" = list(0, 0, 40, 10, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clownfish" = list(0, 0, 50, 0, 0, 0, 200),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_eel" = list(0, 0, 2, 0, 0, 0, 10),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_squid" = list(0, 0, 7, 0, 0, 0, 10),
			"/obj/item/reagent_containers/food/snacks/fish/creepy_shark" = list(0, 0, 2, 0, 0, 0, 10),
			"/obj/item/reagent_containers/glass/bottle/rogue/wine" = list(0, 0, 0, 1, 0, 0, 30),
			"/obj/item/clothing/ring/gold" = list(0, 0, 0, 1, 0, 0, 30),
			"/obj/item/storage/belt/rogue/pouch/coins/poor" = list(0, 0, 0, 1, 0, 0, 75),
			"/obj/item/storage/belt/rogue/pouch/coins/mid" = list(0, 0, 0, 0, 0, 0, 40),
			"/obj/item/storage/belt/rogue/pouch/coins/rich" = list(0, 0, 0, 0, 0, 0, 15),
			"/obj/item/reagent_containers/glass/bottle/rogue" = list(0, 0, 0, 0, 1, 0, 0),
			"/obj/item/reagent_containers/food/snacks/smallrat" = list(1, 0, 0, 0, 0, 0, 0),
			"/mob/living/carbon/human/species/goblin/npc/sea" = list(0, 0, 0, 0, 0, 50, 0),
			"/mob/living/simple_animal/hostile/rogue/deepone" = list(0, 0, 0, 0, 0, 50, 0),
			"/mob/living/simple_animal/hostile/rogue/deepone/spit" = list(0, 0, 0, 0, 0, 50, 0),
		),
		FISH_WATER_MUD = list(
			"/obj/item/reagent_containers/food/snacks/fish/mudskipper" = list(0, 790, 0, 0, 0, 0, 0),
			"/obj/item/natural/worms/leech" = list(0, 0, 180, 0, 0, 0, 0),
			"/obj/item/clothing/ring/gold" = list(0, 0, 0, 1, 0, 0, 30),
			"/obj/item/reagent_containers/food/snacks/smallrat" = list(1, 0, 0, 0, 0, 0, 0),
			"/mob/living/simple_animal/hostile/retaliate/rogue/mudcrab" = list(30, 0, 0, 0, 0, 0, 0),
		),
		FISH_CAGE = list(
			"/obj/item/reagent_containers/food/snacks/fish/oyster" = list(0, 250, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/shrimp" = list(0, 250, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/crab" = list(0, 0, 250, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/lobster" = list(0, 250, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/smallrat" = list(1, 0, 0, 0, 0, 0, 0),
		),
		// Abyssor's rod (artefactsten.dm _abyssor_loot): no bait, plain weights.
		FISH_ABYSSOR = list(
			"/obj/item/reagent_containers/food/snacks/fish/cod" = list(230, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/plaice" = list(180, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/sole" = list(250, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/angler" = list(170, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/lobster" = list(180, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/bass" = list(230, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clam" = list(50, 0, 0, 0, 0, 0, 0),
			"/obj/item/reagent_containers/food/snacks/fish/clownfish" = list(40, 0, 0, 0, 0, 0, 0),
		),
	)
	. = list()
	for(var/waters in rows)
		var/list/table = list()
		var/list/source = rows[waters]
		for(var/path_text in source)
			var/catch_type = text2path(path_text)
			if(catch_type)
				table[catch_type] = source[path_text]
		.[waters] = table

/// Ratwood pickweightAllowZero() of a water's catch: each catch weighs its plain weight and its kinds by the bait's (or the
/// angler's) draw of them, rounded up; no draw (Abyssor's rod) counts the plain weights only. Null when nothing can bite.
/proc/rogue_pick_catch(waters, list/mods)
	var/list/table = GLOB.rogue_catch_tables[waters]
	if(!length(table))
		return null
	var/list/weights = list()
	for(var/catch_type in table)
		var/list/row = table[catch_type]
		var/weight = row[CATCH_FIXED]
		if(mods)
			for(var/kind in CATCH_COMMON to CATCH_CERULEAN)
				weight += row[kind] * mods[kind]
		weight = ceil(weight)
		if(weight > 0)
			weights[catch_type] = weight
	if(!length(weights))
		return null
	return pick_weight(weights)

/// Ratwood get_skill_delay(): a wait from the slowest without the skill down to the fastest at legendary.
/proc/rogue_fishing_delay(rank, fastest, slowest)
	if(rank <= 0)
		return slowest
	return LERP(slowest, fastest, min(rank, ROGUE_SKILL_RANK_MAX) / ROGUE_SKILL_RANK_MAX)

// --- Which waters hold which catch (Ratwood rod.dm: these exact types; VALID_FISHING_SPOTS for the cage, with their kinds)

/turf/open/water/rockhill
	/// The catch table a rod draws from here (Ratwood: only these exact water types bite), or null.
	var/rogue_fish_waters
	/// A crayfish cage set here catches (Ratwood is_valid_fishing_spot()).
	var/rogue_fish_cage = FALSE

/turf/open/water/river
	rogue_fish_waters = FISH_WATER_FRESH
	rogue_fish_cage = TRUE

/turf/open/water/river/flow
	rogue_fish_waters = null

/turf/open/water/river/muddy
	rogue_fish_waters = null

/turf/open/water/cleanshallow
	rogue_fish_waters = FISH_WATER_FRESH
	rogue_fish_cage = TRUE

/turf/open/water/pond
	rogue_fish_waters = FISH_WATER_FRESH

/turf/open/water/ocean
	rogue_fish_waters = FISH_WATER_COAST
	rogue_fish_cage = TRUE

/turf/open/water/ocean/deep
	rogue_fish_waters = FISH_WATER_DEEP

/turf/open/water/ocean/deep/thermalwater
	rogue_fish_waters = null

/turf/open/water/swamp
	rogue_fish_waters = FISH_WATER_MUD
	rogue_fish_cage = TRUE

// --- The rod

/obj/item/fishingrod
	/// Ratwood baited: what is hooked to the line.
	var/obj/item/rogue_bait
	/// A line is out (Ratwood user.doing): one cast at a time.
	var/rogue_casting = FALSE
	/// The angler used the rod in hand while the line was out (Ratwood user.doing = 0): the wait ends - to strike at a bite.
	var/rogue_pulled = FALSE
	/// Ratwood Abyssor's rod: it needs no bait and its line never comes up empty.
	var/rogue_needs_bait = TRUE

/obj/item/fishingrod/abyssoid
	rogue_needs_bait = FALSE

/obj/item/fishingrod/Destroy()
	QDEL_NULL(rogue_bait)
	return ..()

/obj/item/fishingrod/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rogue_bait)
		rogue_bait = null
		update_appearance()

/obj/item/fishingrod/examine(mob/user)
	. = ..()
	if(!rogue_survival_enabled())
		return
	if(rogue_bait)
		. += span_notice("[rogue_bait] is hooked to the line.")
	else if(rogue_needs_bait)
		. += span_notice("Hook a worm, a grub or a leech to the line, then cast it at water with the cast intent. When something tugs the line, pull away.")

/// Ratwood update_icon(): the bait hangs from the rod.
/obj/item/fishingrod/update_overlays()
	. = ..()
	if(!rogue_bait)
		return
	var/mutable_appearance/bait_look = mutable_appearance(rogue_bait.icon, rogue_bait.icon_state)
	bait_look.color = rogue_bait.color
	bait_look.pixel_x = 6
	bait_look.pixel_y = -6
	. += bait_look

/// Ratwood attackby(): bait goes on the hook; Abyssor's rod takes none.
/obj/item/fishingrod/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_survival_enabled() || !rogue_bait_data(tool))
		return ..()
	if(!rogue_needs_bait)
		to_chat(user, span_notice("This rod needs no bait."))
		return ITEM_INTERACT_BLOCKING
	if(rogue_bait)
		to_chat(user, span_warning("The rod already has bait on it!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING
	rogue_bait = tool
	user.visible_message(span_notice("[user] hooks something to the line."), span_notice("I hook [tool] to my line."))
	playsound(src, 'modular_redtard/rockhill/sound/foley/pierce.ogg', 50, FALSE)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/// Ratwood attack_self(): using the rod while the line is out pulls it - the strike when a fish bites.
/obj/item/fishingrod/attack_self(mob/user, modifiers)
	if(rogue_casting)
		rogue_pulled = TRUE
		return TRUE
	return ..()

/obj/item/fishingrod/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_try_cast(interacting_with, user, TRUE) || ..()

/obj/item/fishingrod/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return rogue_try_cast(interacting_with, user, FALSE) || ..()

/// Ratwood afterattack() with the cast intent: a line into water within reach (Abyssor's rod only from the shore).
/obj/item/fishingrod/proc/rogue_try_cast(atom/target, mob/living/user, adjacent)
	if(!istype(target, /turf/open/water/rockhill) || !rogue_survival_enabled() || !istype(user.rogue_active_intent(), /datum/intent/cast))
		return NONE
	if(get_dist(user, target) > rogue_value("fishing_cast_range") || (!adjacent && !rogue_needs_bait))
		return NONE
	if(rogue_casting)
		to_chat(user, span_warning("I must stand still to fish."))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_fish), target, user)
	return ITEM_INTERACT_SUCCESS

/// The line stays in the water while the rod is not pulled.
/obj/item/fishingrod/proc/rogue_line_still()
	return !rogue_pulled

/// The bite waits while the angler neither pulls the rod nor turns away (Ratwood same_direction).
/obj/item/fishingrod/proc/rogue_line_steady(mob/living/user, facing)
	return !rogue_pulled && user.dir == facing

/// Ratwood rod afterattack(): the wait for a bite, the bite, the strike.
/obj/item/fishingrod/proc/rogue_fish(turf/open/water/rockhill/spot, mob/living/user)
	rogue_casting = TRUE
	rogue_pulled = FALSE
	user.visible_message(span_warning("[user] casts a line!"), span_notice("I cast a line."))
	playsound(src, FISH_CAST_SOUND, 100, TRUE)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/labor/fishing)
	var/wait = max(rogue_value("fishing_cast_time") - rank * rogue_value("fishing_cast_time_per_rank"), rogue_value("fishing_cast_time_min"))
	if(!do_after(user, wait, spot, extra_checks = CALLBACK(src, PROC_REF(rogue_line_still))))
		if(!QDELETED(user))
			to_chat(user, span_warning("I must stand still to fish."))
		rogue_casting = FALSE
		return
	if(rogue_needs_bait && !rogue_bait)
		to_chat(user, span_warning("This seems pointless without bait."))
		rogue_casting = FALSE
		return
	var/catch_type
	if(!rogue_needs_bait)
		catch_type = rogue_pick_catch(FISH_ABYSSOR, null)
	else if(prob(rogue_catch_chance(user, rank)))
		catch_type = rogue_pick_catch(spot.rogue_fish_waters, rogue_angler_mods(user))
	else
		to_chat(user, span_warning("Not even a nibble..."))
		user.rogue_craft_experience(/datum/attribute/skill/labor/fishing, user.rogue_stat(ROGUE_STAT_INTELLIGENCE) * rogue_value("fishing_xp_pity"))
		rogue_casting = FALSE
		return
	if(!catch_type)
		rogue_casting = FALSE
		return
	to_chat(user, span_notice("Something tugs the line!"))
	spot.balloon_alert_to_viewers("Tug!")
	playsound(src, FISH_CAST_SOUND, 100, TRUE)
	rogue_pulled = FALSE
	var/window = rogue_value("fishing_bite_window") + rank * rogue_value("fishing_bite_window_per_rank")
	var/waited_out = do_after(user, window, spot, extra_checks = CALLBACK(src, PROC_REF(rogue_line_steady), user, user.dir))
	rogue_casting = FALSE
	if(QDELETED(user) || !user.is_holding(src))
		return
	if(waited_out && rogue_needs_bait)
		to_chat(user, span_warning("Damn, it got away... I should <b>pull away</b> next time."))
		if(prob(rogue_value("fishing_bait_loss_escaped") - rank * rogue_value("fishing_bait_loss_per_rank")))
			to_chat(user, span_warning("...And took my bait, too."))
			QDEL_NULL(rogue_bait)
		return
	rogue_reel_in(catch_type, spot, user, rank)

/// Ratwood: the catch comes up - a creature out of the water at the line, anything else at the angler's feet - with Fishing
/// learnt by it; a baited hook may come back bare.
/obj/item/fishingrod/proc/rogue_reel_in(catch_type, turf/spot, mob/living/user, rank)
	var/intelligence = user.rogue_stat(ROGUE_STAT_INTELLIGENCE)
	if(ispath(catch_type, /mob/living))
		new catch_type(spot)
		if(!ispath(catch_type, /mob/living/simple_animal/hostile/retaliate/rogue/mudcrab))
			user.playsound_local(spot, pick(FISH_JUMPSCARES), 100)
		user.rogue_craft_experience(/datum/attribute/skill/labor/fishing, intelligence * rogue_value("fishing_xp_creature"))
	else
		new catch_type(user.drop_location())
		to_chat(user, span_warning("Reel 'em in!"))
		user.rogue_craft_experience(/datum/attribute/skill/labor/fishing, round(intelligence * rogue_value("fishing_xp_catch"), 2))
		playsound(src, FISH_OUT_SOUND, 100, TRUE)
	if(rogue_bait && prob(rogue_value("fishing_bait_loss_caught") - rank * rogue_value("fishing_bait_loss_per_rank")))
		to_chat(user, span_warning("Damn, it ate my bait."))
		QDEL_NULL(rogue_bait)

/// Ratwood fishchance: a sure bite, less half without the Fishing skill; with it, less the bait's penalty and the angler's
/// shortfall from legendary skill. A body without a mind always bites.
/obj/item/fishingrod/proc/rogue_catch_chance(mob/living/user, rank)
	. = 100
	if(!user.mind)
		return
	if(rank <= 0)
		return . - rogue_value("fishing_unskilled_penalty")
	var/list/bait = rogue_bait_data(rogue_bait)
	return . - (bait ? bait[BAIT_PENALTY] : 0) - max(rogue_value("fishing_skill_penalty") - rank * rogue_value("fishing_skill_penalty_per_rank"), 0)

/// Ratwood modlist: the bait's draw, and Abyssor's follower draws danger and rare fish, a lucky one treasure and rare fish,
/// a cautious one less danger.
/obj/item/fishingrod/proc/rogue_angler_mods(mob/living/user)
	var/list/bait = rogue_bait_data(rogue_bait)
	var/list/mods = bait ? bait.Copy() : list(0, 1, 1, 1, 1, 1, 0)
	var/mob/living/carbon/human/angler = user
	if(!istype(angler))
		return mods
	if(istype(angler.rogue_patron, /datum/patron/divine/abyssor))
		mods[CATCH_DANGER] *= FISH_ABYSSOR_DANGER
		mods[CATCH_TREASURE] *= FISH_ABYSSOR_TREASURE
		mods[CATCH_RARE] *= FISH_ABYSSOR_RARE
	var/luck = angler.rogue_stat(ROGUE_STAT_FORTUNE) - ROGUE_ATTRIBUTE_MIDDLING
	if(luck > 0)
		var/cautious = HAS_TRAIT(angler, TRAIT_CAUTIOUS_FISHER) ? FISH_CAUTIOUS_BONUS : 0
		var/bonus = min(luck, FISH_LUCK_FIRST_STEPS) * FISH_LUCK_FIRST_STEP + max(luck - FISH_LUCK_FIRST_STEPS, 0) * FISH_LUCK_LATER_STEP + cautious
		mods[CATCH_RARE] *= 1 + bonus
		mods[CATCH_TREASURE] *= 1 + bonus
		mods[CATCH_DANGER] *= 1 - cautious * FISH_CAUTIOUS_DANGER
	return mods

// --- The crayfish cage

/obj/item/fishingcage
	/// Set in water (Ratwood deployed).
	var/rogue_deployed = FALSE
	/// What lures the catch in (Ratwood bait).
	var/obj/item/rogue_cage_bait
	/// What is in the cage, waiting to be taken out (Ratwood caught).
	var/rogue_caught
	/// When the baited cage catches (Ratwood check_counter + time2catch).
	var/rogue_catch_at = 0

/obj/item/fishingcage/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(rogue_cage_bait)
	return ..()

/obj/item/fishingcage/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rogue_cage_bait)
		rogue_cage_bait = null
		update_appearance()

/obj/item/fishingcage/update_icon_state()
	if(rogue_caught)
		icon_state = "fishingcage_caught"
	else if(rogue_cage_bait)
		icon_state = "fishingcage_ready"
	else
		icon_state = rogue_deployed ? "fishingcage_deployed" : initial(icon_state)
	return ..()

/obj/item/fishingcage/examine(mob/user)
	. = ..()
	if(rogue_caught)
		. += span_warning("Something seems to be inside...")
	else if(rogue_survival_enabled() && !rogue_deployed)
		. += span_notice("Put a worm or a leech in it and set it in the water in front of you.")

/// Ratwood attack_self(): the cage is set in the water ahead, if anything lives there.
/obj/item/fishingcage/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !rogue_survival_enabled() || !isliving(user))
		return
	var/turf/open/water/rockhill/water = get_step(user, user.dir)
	if(!istype(water))
		to_chat(user, span_warning("This goes into water!"))
		return TRUE
	if(!water.rogue_fish_cage)
		to_chat(user, span_warning("This body of water seems devoid of aquatic life..."))
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(rogue_deploy), water, user)
	return TRUE

/obj/item/fishingcage/proc/rogue_deploy(turf/open/water/rockhill/water, mob/living/user)
	user.visible_message(span_notice("[user] begins deploying the fishing cage..."), span_notice("I begin deploying the fishing cage..."))
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/labor/fishing)
	if(!do_after(user, rogue_fishing_delay(rank, rogue_value("fishing_cage_deploy_fast"), rogue_value("fishing_cage_deploy_slow")), src))
		return
	if(!user.transferItemToLoc(src, water))
		return
	rogue_set_deployed(TRUE)

/obj/item/fishingcage/proc/rogue_set_deployed(deployed)
	rogue_deployed = deployed
	set_anchored(deployed)
	if(deployed && rogue_cage_bait)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)
	update_appearance()

/// Ratwood attack_hand() of a set cage: take the catch out, or, with nothing caught, take the cage up (the bait is lost).
/obj/item/fishingcage/attack_hand(mob/user, list/modifiers)
	if(!rogue_deployed || !isliving(user))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_tend), user)
	return TRUE

/obj/item/fishingcage/proc/rogue_tend(mob/living/user)
	var/rank = user.rogue_skill_rank(/datum/attribute/skill/labor/fishing)
	var/wait = rogue_fishing_delay(rank, rogue_value("fishing_cage_deploy_fast"), rogue_value("fishing_cage_deploy_slow"))
	if(rogue_caught)
		user.visible_message(span_notice("[user] begins to harvest from the cage..."), span_notice("I begin harvesting from the cage..."))
		if(!do_after(user, wait, src) || !rogue_caught)
			return
		rogue_harvest(user)
		return
	user.visible_message(span_notice("[user] begins disarming the fishing cage..."), span_notice("I begin disarming the fishing cage..."))
	if(!do_after(user, wait, src) || !rogue_deployed || rogue_caught)
		return
	QDEL_NULL(rogue_cage_bait)
	rogue_set_deployed(FALSE)
	user.put_in_hands(src)

/// The catch comes out at the fisher's feet, with Fishing learnt; the cage stays set, empty.
/obj/item/fishingcage/proc/rogue_harvest(mob/living/user)
	new rogue_caught(user.drop_location())
	rogue_caught = null
	user.rogue_craft_experience(/datum/attribute/skill/labor/fishing, rogue_value("fishing_cage_xp"))
	update_appearance()

/// Ratwood attackby(): bait goes into the cage, and it starts to lure (faster with the Fishing skill).
/obj/item/fishingcage/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!rogue_survival_enabled() || !rogue_bait_data(tool))
		return ..()
	if(rogue_cage_bait)
		to_chat(user, span_warning("There's bait already on the cage."))
		return ITEM_INTERACT_BLOCKING
	INVOKE_ASYNC(src, PROC_REF(rogue_add_bait), tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/fishingcage/proc/rogue_add_bait(obj/item/bait, mob/living/user)
	user.visible_message(span_notice("[user] starts adding the bait to the fishing cage..."), span_notice("I start to add [bait] to the fishing cage..."))
	if(!do_after(user, rogue_value("fishing_cage_bait_time"), src) || rogue_cage_bait || !user.transferItemToLoc(bait, src))
		return
	playsound(src, 'modular_redtard/rockhill/sound/foley/pierce.ogg', 50, FALSE)
	rogue_bait_cage(bait, user.rogue_skill_rank(/datum/attribute/skill/labor/fishing))

/obj/item/fishingcage/proc/rogue_bait_cage(obj/item/bait, rank)
	rogue_cage_bait = bait
	rogue_catch_at = world.time + rogue_fishing_delay(rank, rogue_value("fishing_cage_catch_fast"), rogue_value("fishing_cage_catch_slow"))
	if(rogue_deployed)
		START_PROCESSING(SSobj, src)
	update_appearance()

/// Ratwood process(): once its time has come, a set and baited cage has something in it, and the bait is gone.
/obj/item/fishingcage/process(seconds_per_tick)
	if(!rogue_deployed || !rogue_cage_bait)
		return PROCESS_KILL
	if(world.time < rogue_catch_at)
		return
	rogue_caught = rogue_pick_catch(FISH_CAGE, rogue_bait_data(rogue_cage_bait))
	QDEL_NULL(rogue_cage_bait)
	update_appearance()
	return PROCESS_KILL

// --- Fish

/obj/item/reagent_containers/food/snacks/fish
	/// The sprite stem of a fish whose sprite shows its rarity (Ratwood initial(icon_state): carp + com, rare, ultra, gold). A fish
	/// type named like its stem (crab, oyster, eel...) uses its own name. Fish with a sprite of their own keep it.
	var/rogue_fish_sprite = "carp"
	/// Ratwood rarity_rank: 0 common, 1 rare, 2 ultra-rare, 3 legendary.
	var/rogue_rarity = 0

/obj/item/reagent_containers/food/snacks/fish/Initialize(mapload)
	. = ..()
	rogue_roll_rarity()

/// Ratwood raw_fish.dm Initialize(): how rare this fish is, its name and price by it and, where the sprite shows it, its look.
/obj/item/reagent_containers/food/snacks/fish/proc/rogue_roll_rarity()
	var/list/rarities = list(
		"gold" = rogue_value("fishing_rarity_legendary"),
		"ultra" = rogue_value("fishing_rarity_ultra"),
		"rare" = rogue_value("fishing_rarity_rare"),
		"com" = rogue_value("fishing_rarity_common"),
	)
	var/rarity = pick_weight(rarities)
	switch(rarity)
		if("gold")
			rogue_rarity = 3
			sellprice *= rogue_value("fishing_price_legendary")
			name = "legendary [initial(name)]"
		if("ultra")
			rogue_rarity = 2
			sellprice *= rogue_value("fishing_price_ultra")
			name = "ultra-rare [initial(name)]"
		if("rare")
			rogue_rarity = 1
			sellprice *= rogue_value("fishing_price_rare")
			name = "rare [initial(name)]"
		else
			rogue_rarity = 0
			name = "common [initial(name)]"
	// The porter leaves a fish without a sprite of its own state-less (only its rarity sprites exist).
	if(icon_state)
		return
	var/type_text = "[type]"
	var/stem = copytext(type_text, findlasttext(type_text, "/") + 1)
	if(!icon_exists(icon, "[stem][rarity]"))
		stem = rogue_fish_sprite
	if(icon_exists(icon, "[stem][rarity]"))
		icon_state = "[stem][rarity]"

/// Ratwood turf/open/water Entered(): a fish dropped or thrown into water swims off - unless a boat floats there.
/obj/item/reagent_containers/food/snacks/fish/rogue_entered_water(turf/open/water/rockhill/water, atom/old_loc)
	if(locate(/obj/vehicle) in water)
		return
	visible_message(span_warning("[src] dives into \the [water] and disappears!"))
	qdel(src)

#undef BAIT_PENALTY
#undef CATCH_FIXED
#undef CATCH_COMMON
#undef CATCH_RARE
#undef CATCH_TREASURE
#undef CATCH_TRASH
#undef CATCH_DANGER
#undef CATCH_CERULEAN
#undef FISH_WATER_FRESH
#undef FISH_WATER_COAST
#undef FISH_WATER_DEEP
#undef FISH_WATER_MUD
#undef FISH_CAGE
#undef FISH_ABYSSOR
#undef FISH_LUCK_FIRST_STEPS
#undef FISH_LUCK_FIRST_STEP
#undef FISH_LUCK_LATER_STEP
#undef FISH_CAUTIOUS_BONUS
#undef FISH_CAUTIOUS_DANGER
#undef FISH_ABYSSOR_DANGER
#undef FISH_ABYSSOR_TREASURE
#undef FISH_ABYSSOR_RARE
#undef FISH_CAST_SOUND
#undef FISH_OUT_SOUND
#undef FISH_JUMPSCARES
