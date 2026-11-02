// Ratwood's wild plants on the medieval maps' own types (rogueflora.dm, datums/components/hiding_spot.dm): grass rustles under
// whoever walks through it, bushes are searched for berries, pipeweed, thorns and fibres and catch and prick those who run or
// ride through them, a thorn bush entangles, fire flowers, swampweed and wild pumpkins are searched too, giant mushrooms close
// their facing side, trees and grass catch fire from a spark, an axe keeps chopping a tree, and one can hide in a bush, an old
// log or behind a bookcase (the module's hiding spot component, rockhill/hiding.dm). Not ported: the ambushes of the wilds
// (Ratwood consider_ambush(), threat regions) and the special items hidden in trees and mushrooms (attack_right()).

/// Ratwood CLICK_CD_INTENTCAP: the pause after reaching into a plant.
#define ROCKHILL_FLORA_CLICK_CD 6
/// How far a bush, fire flowers or swampweed sit off their tile's centre (Ratwood pixel_x += rand(-3, 3)).
#define ROCKHILL_PLANT_SHIFT_X 3
/// How far up wild pumpkins sit (Ratwood pixel_y += rand(0, 6)).
#define ROCKHILL_PUMPKIN_SHIFT_Y 6
/// The do_after key of a tree being chopped on and on.
#define ROCKHILL_CHOP_KEY "rockhill_chop"

/// Ratwood's sound key "plantcross": a plant rustles.
GLOBAL_LIST_INIT(rockhill_plant_rustle, list(
	'modular_redtard/rockhill/sound/foley/plantcross1.ogg',
	'modular_redtard/rockhill/sound/foley/plantcross2.ogg',
	'modular_redtard/rockhill/sound/foley/plantcross3.ogg',
	'modular_redtard/rockhill/sound/foley/plantcross4.ogg',
))

/area/rogue
	/// Ratwood town_area: years of harvest have left the bushes of a town fruitless (the porter writes it).
	var/town_area = FALSE

/obj/structure/flora/roguegrass
	/// Ratwood bushtype: the fruit the plant bears, if any.
	var/rockhill_crop
	/// Ratwood looty: what a searching hand still finds in the plant, one path per find.
	var/list/rockhill_loot
	/// Ratwood res_replenish: the time a plant picked clean bears again.
	var/rockhill_bears_again = 0

/// Ratwood's sparks set grass alight (roguegrass spark_act()).
/obj/structure/flora/roguegrass/spark_act()
	fire_act()

/// Ratwood's sparks set a tree alight (roguetree spark_act()).
/obj/structure/flora/roguetree/spark_act()
	fire_act()

// --- Walking through plants

/turf/open/floor/rockhill/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		rockhill_brush_plants(arrived)

/turf/open/water/rockhill/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived))
		rockhill_brush_plants(arrived)

/// The plants on this tile feel whoever just came onto it (Ratwood Crossed() of grass, bushes and thorn bushes); one check of
/// the tile instead of a signal on each of the plants the woods are full of.
/turf/open/proc/rockhill_brush_plants(mob/living/walker)
	if(walker.loc != src)
		return
	for(var/obj/structure/flora/roguegrass/plant in src)
		plant.rockhill_brushed(walker)

/// Ratwood /datum/component/roguegrass Crossed(): a living thing that does not sneak pushes through the plant, which rustles -
/// unless a native of the vale walks through it - and sways.
/obj/structure/flora/roguegrass/proc/rockhill_brushed(mob/living/walker)
	var/mob/living/carbon/human/sneaker = walker
	if(istype(sneaker) && sneaker.rogue_sneaking)
		return
	if(!HAS_TRAIT(walker, TRAIT_AZURENATIVE) || walker.move_intent == MOVE_INTENT_RUN)
		playsound(loc, pick(GLOB.rockhill_plant_rustle), 80, FALSE, -1)
	var/rest_x = pixel_x
	animate(src, pixel_x = rest_x + 1, time = 0.5)
	animate(pixel_x = rest_x - 1, time = 0.5)
	animate(pixel_x = rest_x, time = 0.5)

/// Ratwood bush Crossed(): whoever pushes through a bush on their feet is held in it for a moment, the stronger the shorter;
/// running or riding, they sidestep the hold and its thorns cut them.
/obj/structure/flora/roguegrass/bush/rockhill_brushed(mob/living/walker)
	. = ..()
	if(walker.body_position != STANDING_UP)
		return
	walker.Immobilize(max(rogue_value("bush_hold_min"), rogue_value("bush_hold_time") - round(walker.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("bush_hold_per_strength"))))
	if(walker.move_intent != MOVE_INTENT_RUN && !walker.buckled)
		return
	if(!iscarbon(walker))
		to_chat(walker, span_warning("I'm cut on a thorn!"))
		walker.apply_damage(rogue_value("thorn_beast_damage"), BRUTE)
		return
	var/mob/living/carbon/victim = walker
	var/obj/item/bodypart/limb = pick(victim.bodyparts)
	if(prob(rogue_value("bush_impale_chance")))
		if(!HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
			rockhill_thorn_impale(victim, limb, loc)
		return
	rockhill_thorn_cut(victim, limb)

/// Ratwood thorn bush Crossed(): it entangles anything bigger than a small critter for a moment, the stronger the shorter,
/// and cuts a beast. A thorn always sinks into one cursed by Dendor and never touches one he blessed; a rider snags and, less
/// often the better they ride, their mount goes mad with pain; a person is impaled less often the luckier, else cut.
/obj/structure/flora/roguegrass/thorn_bush/rockhill_brushed(mob/living/walker)
	. = ..()
	if(walker.mob_size <= MOB_SIZE_SMALL)
		return
	walker.Immobilize(max(0, rogue_value("thorn_bush_hold_time") - walker.rogue_stat(ROGUE_STAT_STRENGTH) * rogue_value("thorn_bush_hold_per_strength")))
	if(!iscarbon(walker))
		to_chat(walker, span_warning("I'm cut on a thorn!"))
		walker.apply_damage(rogue_value("thorn_beast_damage"), BRUTE)
		return
	var/mob/living/carbon/victim = walker
	if(HAS_TRAIT(victim, TRAIT_CURSE_DENDOR))
		rockhill_thorn_impale(victim, pick(victim.bodyparts), loc)
		return
	if(HAS_TRAIT(victim, TRAIT_KNEESTINGER_IMMUNITY))
		return
	if(victim.buckled)
		var/obj/item/bodypart/snagged = pick(victim.bodyparts)
		to_chat(victim, span_warning("My [snagged.name] snags on a thorn."))
		snagged.receive_damage(rogue_value("thorn_damage"), wound_bonus = CANT_WOUND)
		var/riding = victim.rogue_skill_rank(/datum/attribute/skill/misc/riding)
		if(HAS_TRAIT(victim, TRAIT_STEPPE_RIDER))
			riding += rogue_value("thorn_steppe_rider_ranks")
		if(prob(100 - riding * rogue_value("thorn_riding_rank_chance")))
			to_chat(victim, span_danger("My mount goes mad with pain!"))
			victim.Paralyze(rogue_value("thorn_mount_paralyze"))
	if(prob(rogue_value("thorn_impale_chance") - victim.rogue_stat(ROGUE_STAT_FORTUNE)))
		if(!HAS_TRAIT(victim, TRAIT_PIERCEIMMUNE))
			rockhill_thorn_impale(victim, pick(victim.bodyparts), loc)
		return
	rockhill_thorn_cut(victim, pick(victim.bodyparts))

/// A thorn's cut on a body part (Ratwood receive_damage(10) with no blow class: no wound).
/proc/rockhill_thorn_cut(mob/living/carbon/victim, obj/item/bodypart/limb)
	to_chat(victim, span_warning("A thorn [pick("slices", "cuts", "nicks")] my [limb.name]."))
	limb.receive_damage(rogue_value("thorn_damage"), wound_bonus = CANT_WOUND)

/// Ratwood add_embedded_object() of a thorn: a thorn of the bush sinks into the body part, which takes the cut.
/proc/rockhill_thorn_impale(mob/living/carbon/victim, obj/item/bodypart/limb, turf/spot)
	var/obj/item/natural/thorn/thorn = new(spot)
	thorn.set_embed(/datum/embedding/rogue_thorn)
	thorn.force_embed(victim, limb)
	limb.receive_damage(rogue_value("thorn_damage"), wound_bonus = CANT_WOUND)

/// A thorn stuck in a body part (Ratwood thorn embedding): it hurts now and then, never falls out by itself, and is pulled out
/// in two seconds.
/datum/embedding/rogue_thorn
	embed_chance = 35
	fall_chance = 0
	pain_chance = 10
	pain_mult = 1
	impact_pain_mult = 0
	rip_time = 2 SECONDS

// --- Searching plants

/// Whether a hand searches the plant at all.
/obj/structure/flora/roguegrass/proc/rockhill_searchable()
	return FALSE

/// Ratwood loot_replenish(): what the plant bears again once it is picked clean.
/obj/structure/flora/roguegrass/proc/rockhill_replenish()
	return

/// The rustle of a search (Ratwood: a bush 50, the rest 80).
/obj/structure/flora/roguegrass/proc/rockhill_search_volume()
	return 80

/// Whether a fruitless search goes on by itself while something is left (Ratwood bush attack_hand()).
/obj/structure/flora/roguegrass/proc/rockhill_search_again()
	return FALSE

/// Chance in percent that one search turns something up.
/obj/structure/flora/roguegrass/proc/rockhill_find_chance()
	return rogue_value("flora_search_find_chance")

/// The searcher takes a find in hand.
/obj/structure/flora/roguegrass/proc/rockhill_give(mob/living/user, found_type)
	var/obj/item/found = new found_type(user.loc)
	user.put_in_hands(found)
	user.visible_message(span_notice("[user] finds [found] in [src]."))

/obj/structure/flora/roguegrass/attack_hand(mob/living/user, list/modifiers)
	var/hidden_here = user.loc == src
	. = ..()
	if(. || hidden_here || !isliving(user) || !rockhill_searchable() || DOING_INTERACTION_WITH_TARGET(user, src))
		return
	user.changeNext_move(ROCKHILL_FLORA_CLICK_CD)
	INVOKE_ASYNC(src, PROC_REF(rockhill_search), user)
	return TRUE

/// Ratwood attack_hand() of a searchable plant: a rustling search that turns up one of the plant's finds by its chance; a plant
/// picked clean bears again a while after its last find.
/obj/structure/flora/roguegrass/proc/rockhill_search(mob/living/user)
	do
		playsound(loc, pick(GLOB.rockhill_plant_rustle), rockhill_search_volume(), FALSE, -1)
		if(!do_after(user, rogue_value("flora_search_time"), src) || QDELETED(src))
			return
		if(!length(rockhill_loot) && world.time > rockhill_bears_again)
			rockhill_replenish()
		if(length(rockhill_loot) && prob(rockhill_find_chance()))
			if(length(rockhill_loot) == 1)
				rockhill_bears_again = world.time + rogue_value("flora_regrow_time")
			rockhill_give(user, pick_n_take(rockhill_loot))
			return
		user.visible_message(span_warning("[user] searches through [src]."))
		if(!length(rockhill_loot))
			to_chat(user, span_warning("Picked clean... I should try later."))
			return
	while(rockhill_search_again())

// --- Bushes

/// Ratwood bush Initialize(): a bush bears its fruit, a thorn now and then and always fibres, and one can hide in it. Away
/// from towns most bushes bear berries, poisonous berries or pipeweed; in a town years of harvest have left them fruitless.
/obj/structure/flora/roguegrass/bush/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	AddComponent(/datum/component/rockhill_hiding_spot)
	if(isnull(rockhill_crop))
		var/area/rogue/here = get_area(src)
		if(istype(here) && here.town_area)
			desc += "Sadly, years of harvest inside this town have left it fruitless."
		else if(prob(rogue_value("flora_crop_chance")))
			rockhill_crop = pick_weight(list(
				/obj/item/reagent_containers/food/snacks/grown/berries/rogue = 5,
				/obj/item/reagent_containers/food/snacks/grown/berries/rogue/poison = 3,
				/obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed = 1,
			))
	rockhill_replenish()
	pixel_x += rand(-ROCKHILL_PLANT_SHIFT_X, ROCKHILL_PLANT_SHIFT_X)

/obj/structure/flora/roguegrass/bush/rockhill_searchable()
	return TRUE

/obj/structure/flora/roguegrass/bush/rockhill_search_volume()
	return 50

/obj/structure/flora/roguegrass/bush/rockhill_search_again()
	return TRUE

/obj/structure/flora/roguegrass/bush/rockhill_replenish()
	LAZYINITLIST(rockhill_loot)
	if(rockhill_crop)
		rockhill_loot += rockhill_crop
	if(prob(rogue_value("bush_thorn_chance")))
		rockhill_loot += /obj/item/natural/thorn
	rockhill_loot += /obj/item/natural/fibers

/// Ratwood westleach: a bush of pipeweed, now and then with a second leaf.
/obj/structure/flora/roguegrass/bush/westleach
	rockhill_crop = /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed

/obj/structure/flora/roguegrass/bush/westleach/rockhill_replenish()
	. = ..()
	if(prob(rogue_value("westleach_pipeweed_chance")))
		rockhill_loot += /obj/item/reagent_containers/food/snacks/grown/rogue/pipeweed

// --- Fire flowers, swampweed, wild pumpkins

/// Ratwood pyroclasticflowers: mostly a fire flower (fyritius), now and then a second.
/obj/structure/flora/roguegrass/pyroclasticflowers/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if(prob(rogue_value("flora_crop_chance")))
		rockhill_crop = /obj/item/reagent_containers/food/snacks/grown/rogue/fyritius
	rockhill_replenish()
	pixel_x += rand(-ROCKHILL_PLANT_SHIFT_X, ROCKHILL_PLANT_SHIFT_X)

/obj/structure/flora/roguegrass/pyroclasticflowers/rockhill_searchable()
	return TRUE

/obj/structure/flora/roguegrass/pyroclasticflowers/rockhill_replenish()
	LAZYINITLIST(rockhill_loot)
	if(rockhill_crop)
		rockhill_loot += rockhill_crop
	if(prob(rogue_value("flora_second_crop_chance")))
		rockhill_loot += /obj/item/reagent_containers/food/snacks/grown/rogue/fyritius

/// Ratwood swampweed: mostly a root, now and then a second; a woodwalker finds two at once.
/obj/structure/flora/roguegrass/swampweed/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	if(prob(rogue_value("flora_crop_chance")))
		rockhill_crop = /obj/item/reagent_containers/food/snacks/grown/rogue/swampweed
	rockhill_replenish()
	pixel_x += rand(-ROCKHILL_PLANT_SHIFT_X, ROCKHILL_PLANT_SHIFT_X)

/obj/structure/flora/roguegrass/swampweed/rockhill_searchable()
	return TRUE

/obj/structure/flora/roguegrass/swampweed/rockhill_replenish()
	LAZYINITLIST(rockhill_loot)
	if(rockhill_crop)
		rockhill_loot += rockhill_crop
	if(prob(rogue_value("flora_second_crop_chance")))
		rockhill_loot += /obj/item/reagent_containers/food/snacks/grown/rogue/swampweed

/obj/structure/flora/roguegrass/swampweed/rockhill_give(mob/living/user, found_type)
	var/obj/item/found = new found_type(user.loc)
	user.put_in_hands(found)
	var/woodwalker = HAS_TRAIT(user, TRAIT_WOODWALKER)
	if(woodwalker)
		user.put_in_hands(new found_type(user.loc))
	user.visible_message(span_notice("[user] finds [woodwalker ? "two of " : ""][found] in [src]."))

/// Ratwood pumpkin: a few wild pumpkins and fibres, found three times in four; picked bare, the vines are gone for good.
/obj/structure/flora/roguegrass/pumpkin/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	rockhill_loot = list(/obj/item/natural/shellplant/pumpkin, /obj/item/natural/fibers)
	for(var/chance_id in list("wild_pumpkin_second", "wild_pumpkin_third"))
		if(prob(rogue_value(chance_id)))
			rockhill_loot += /obj/item/natural/shellplant/pumpkin
	if(prob(rogue_value("wild_pumpkin_fibers")))
		rockhill_loot += /obj/item/natural/fibers
	if(prob(rogue_value("wild_pumpkin_fourth")))
		rockhill_loot += /obj/item/natural/shellplant/pumpkin
	pixel_x += rand(-ROCKHILL_PLANT_SHIFT_X, ROCKHILL_PLANT_SHIFT_X)
	pixel_y += rand(0, ROCKHILL_PUMPKIN_SHIFT_Y)

/obj/structure/flora/roguegrass/pumpkin/rockhill_searchable()
	return TRUE

/obj/structure/flora/roguegrass/pumpkin/rockhill_find_chance()
	return rogue_value("wild_pumpkin_find_chance")

/obj/structure/flora/roguegrass/pumpkin/rockhill_give(mob/living/user, found_type)
	. = ..()
	if(length(rockhill_loot))
		return
	to_chat(user, span_warning("There is nothing else to find."))
	qdel(src)

// --- Giant mushrooms

/// Ratwood rogueshroom CanPass() and on_exit(): a giant mushroom closes its facing side - nothing comes in from there or goes
/// out that way, except what slips through bars.
/obj/structure/flora/rogueshroom/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(rockhill_on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/flora/rogueshroom/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir == dir && !(mover.pass_flags & PASSGRILLE))
		return FALSE

/obj/structure/flora/rogueshroom/proc/rockhill_on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving == src || direction != dir || (leaving.pass_flags & PASSGRILLE))
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

// --- Chopping trees

/obj/structure/flora/roguetree
	/// Ratwood AutoWoodcut: a chopping blow on the tree goes on by itself (a preference in Ratwood, on by default; always here).
	var/rockhill_autochop = TRUE

/obj/structure/flora/roguetree/stump
	rockhill_autochop = FALSE

/// Ratwood roguetree attackby(): a chop keeps chopping the tree, a swing every 1.5 seconds, while the lumberjack stands by it
/// with the axe in hand and the energy to swing it.
/obj/structure/flora/roguetree/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!rockhill_autochop || !isliving(user) || DOING_INTERACTION(user, ROCKHILL_CHOP_KEY))
		return ..()
	var/mob/living/lumberjack = user
	var/datum/intent/intent = lumberjack.rogue_hand_intent(lumberjack.get_held_index_of_item(attacking_item))
	if(intent?.blade_class != BCLASS_CHOP)
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rockhill_keep_chopping), attacking_item, lumberjack)
	return TRUE

/obj/structure/flora/roguetree/proc/rockhill_keep_chopping(obj/item/axe, mob/living/lumberjack)
	while(!QDELETED(src) && !QDELETED(axe) && lumberjack.Adjacent(src) && lumberjack.get_active_held_item() == axe)
		var/mob/living/carbon/human/tired = lumberjack
		if(istype(tired) && tired.rogue_energy <= 0)
			to_chat(lumberjack, span_warning("I'm too tired to keep chopping."))
			return
		if(!do_after(lumberjack, rogue_value("tree_chop_interval"), src, interaction_key = ROCKHILL_CHOP_KEY))
			return
		if(QDELETED(src) || QDELETED(axe) || lumberjack.get_active_held_item() != axe)
			return
		lumberjack.do_attack_animation(src)
		axe.attack_atom(src, lumberjack)

// --- Hiding

/// Ratwood stump/log: one can hide inside an old log.
/obj/structure/flora/roguetree/stump/log/Initialize(mapload)
	. = ..()
	if(. != INITIALIZE_HINT_QDEL)
		AddComponent(/datum/component/rockhill_hiding_spot)

/// Ratwood bookcase: one can hide behind a bookcase of the map. The shelf has no window of its own, so it drops TG's
/// interaction on a hand's click: a click the hiding spot takes then stays taken, and the list of books stays shut.
/obj/structure/bookcase/Initialize(mapload)
	. = ..()
	if(!mapload || . == INITIALIZE_HINT_QDEL || !rogue_combat_enabled())
		return
	AddComponent(/datum/component/rockhill_hiding_spot)
	interaction_flags_atom &= ~INTERACT_ATOM_ATTACK_HAND

#undef ROCKHILL_FLORA_CLICK_CD
#undef ROCKHILL_PLANT_SHIFT_X
#undef ROCKHILL_PUMPKIN_SHIFT_Y
#undef ROCKHILL_CHOP_KEY
