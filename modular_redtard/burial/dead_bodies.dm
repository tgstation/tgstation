/// Ratwood's dead bodies of the map (structures/roguetown/deadbodies.dm): each lies in one of its kind's poses and can be
/// searched once, five seconds with a hand. The unlucky (fortune under 10) come up empty two times in five; the rest pull
/// out one thing, two from fortune 13, three from 16, and from fortune 14 a body with a lucky table gives from it. The
/// tables are Ratwood's; the porter does not carry them (rockhill_loot, rockhill_loot_lucky, rockhill_poses are written
/// here). Three of Ratwood's finds are not ported yet and count as found nothing until they are: the warden's goat and wolf
/// sallets and the antlered warden hood.

/// Ratwood CLICK_CD_INTENTCAP: the pause before a search begins.
#define ROGUE_SEARCH_CLICK_CD 6

/obj/structure/deadbody
	/// What a search may turn up, by weight (Ratwood loot_table).
	var/list/rockhill_loot
	/// What a lucky search turns up instead, by weight (Ratwood loot_table_lucky); none for some kinds.
	var/list/rockhill_loot_lucky
	/// The poses its kind lies in (Ratwood pose_states).
	var/list/rockhill_poses
	/// The one pose it always lies in, if set (Ratwood forced_pose).
	var/rockhill_forced_pose
	/// Searched already (Ratwood body_looted).
	var/rogue_looted = FALSE

/obj/structure/deadbody/Initialize(mapload)
	. = ..()
	if(rockhill_forced_pose)
		icon_state = rockhill_forced_pose
	else if(length(rockhill_poses))
		icon_state = pick(rockhill_poses)

/obj/structure/deadbody/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	if(rogue_looted)
		to_chat(user, span_warning("There's nothing left worth taking."))
		return TRUE
	if(DOING_INTERACTION_WITH_TARGET(user, src))
		return TRUE
	INVOKE_ASYNC(src, PROC_REF(rogue_search), user)
	return TRUE

/// Ratwood deadbody attack_hand(): five seconds of rummaging through the body.
/obj/structure/deadbody/proc/rogue_search(mob/living/user)
	user.changeNext_move(ROGUE_SEARCH_CLICK_CD)
	user.visible_message(span_notice("[user] begins searching the body."), span_notice("You begin searching the body."))
	if(!do_after(user, rogue_value("body_search_time"), target = src))
		return
	if(rogue_looted)
		to_chat(user, span_warning("There's nothing left worth taking."))
		return
	playsound(src, pick('modular_redtard/burial/sound/rummaging-01.ogg', 'modular_redtard/burial/sound/rummaging-02.ogg', 'modular_redtard/burial/sound/rummaging-03.ogg'), 50, FALSE)
	rogue_loot_body(user)
	user.visible_message(span_notice("[user] finishes searching [src]."), span_notice("You finish searching [src]."))

/// What the search turns up, into the searcher's hands (or at their feet); the body is looted after. Returns how many
/// things were found.
/obj/structure/deadbody/proc/rogue_loot_body(mob/living/user)
	rogue_looted = TRUE
	var/fortune = user.rogue_stat(ROGUE_STAT_FORTUNE)
	if(fortune < rogue_value("body_unlucky_fortune") && prob(rogue_value("body_unlucky_empty_chance")))
		to_chat(user, span_warning("You come up empty. Nothing but dust and bad luck."))
		return 0
	var/finds = 1
	if(fortune >= rogue_value("body_three_finds_fortune"))
		finds = 3
	else if(fortune >= rogue_value("body_two_finds_fortune"))
		finds = 2
	var/lucky = fortune >= rogue_value("body_lucky_fortune") && length(rockhill_loot_lucky)
	var/list/table = lucky ? rockhill_loot_lucky : rockhill_loot
	if(!length(table))
		return 0
	var/found_count = 0
	for(var/i in 1 to finds)
		var/item_type = pick_weight(table)
		// The finds the porter has not brought yet are written as text and turn up nothing until it does.
		if(istext(item_type))
			item_type = text2path(item_type)
		if(!ispath(item_type, /obj/item))
			continue
		var/obj/item/found = new item_type(user.loc)
		user.put_in_hands(found)
		found_count++
		if(lucky)
			to_chat(user, span_notice("A lucky find! You pull out [found]."))
		else
			to_chat(user, span_notice("You pull out [found]."))
	return found_count

// Ratwood's kinds of the dead: their poses and what they carried.

/obj/structure/deadbody/generic
	rockhill_poses = list(
		"generic_male", "gm10", "gm20", "gm30", "gm40",
		"generic_female", "gf10", "gf20", "gf30", "gf40",
	)
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 60,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 10,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 30,
		/obj/item/reagent_containers/food/snacks/rogue/raisinbread = 15,
		/obj/item/flashlight/flare/torch = 25,
		/obj/item/flint = 20,
		/obj/item/natural/bone = 5,
	)

/obj/structure/deadbody/adventurer_leather
	rockhill_poses = list("adventurer_leather", "adl10", "adl20", "adl30", "adl40")
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 30,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 25,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 5,
		/obj/item/rogueweapon/huntingknife/idagger = 20,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 15,
		/obj/item/clothing/suit/roguetown/armor/leather/cuirass = 10,
		/obj/item/clothing/suit/roguetown/armor/leather/studded = 8,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 20,
		/obj/item/flashlight/flare/torch = 15,
		/obj/item/flint = 10,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 30,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 15,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 25,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 10,
		/obj/item/clothing/suit/roguetown/armor/leather/studded = 15,
		/obj/item/clothing/suit/roguetown/armor/chainmail = 10,
		/obj/item/clothing/head/roguetown/helmet/kettle = 10,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 20,
	)

/obj/structure/deadbody/adventurer_steel
	rockhill_poses = list(
		"adventurer_steel", "ad10", "ad20", "ad30", "ad40",
		"adv_steel_skele", "advsk10", "advsk20", "advsk30", "advsk40",
	)
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 30,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 15,
		/obj/item/rogueweapon/sword = 10,
		/obj/item/rogueweapon/sword/long = 5,
		/obj/item/rogueweapon/mace = 10,
		/obj/item/rogueweapon/mace/steel = 4,
		/obj/item/clothing/suit/roguetown/armor/chainmail = 8,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 5,
		/obj/item/clothing/suit/roguetown/armor/plate/half = 3,
		/obj/item/clothing/head/roguetown/helmet/kettle = 10,
		/obj/item/clothing/head/roguetown/helmet/bascinet = 5,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 20,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 30,
		/obj/item/rogueweapon/sword/long = 20,
		/obj/item/rogueweapon/mace/steel = 15,
		/obj/item/rogueweapon/estoc = 8,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 15,
		/obj/item/clothing/suit/roguetown/armor/plate/half = 10,
		/obj/item/clothing/head/roguetown/helmet/bascinet = 15,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
	)

/obj/structure/deadbody/maa
	rockhill_poses = list("guard_tabbard", "g10", "g20", "g30", "g40")
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 35,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 10,
		/obj/item/rogueweapon/sword = 12,
		/obj/item/rogueweapon/sword/long = 5,
		/obj/item/rogueweapon/mace = 12,
		/obj/item/rogueweapon/mace/steel = 5,
		/obj/item/clothing/cloak/stabard/guard = 10,
		/obj/item/clothing/cloak/stabard/surcoat/guard = 6,
		/obj/item/clothing/cloak/stabard/guardhood = 6,
		/obj/item/clothing/suit/roguetown/armor/chainmail = 10,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 6,
		/obj/item/clothing/head/roguetown/helmet/kettle = 10,
		/obj/item/clothing/head/roguetown/helmet/sallet = 5,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
		/obj/item/flashlight/flare/torch = 10,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 30,
		/obj/item/rogueweapon/sword/long = 20,
		/obj/item/rogueweapon/mace/steel = 15,
		/obj/item/clothing/cloak/stabard/surcoat/guard = 20,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk = 20,
		/obj/item/clothing/head/roguetown/helmet/sallet = 20,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
	)

/obj/structure/deadbody/warden
	rockhill_poses = list(
		"warden", "wa10", "wa20", "wa30", "wa40",
		"warden_skele", "wsk10", "wsk20", "wsk30", "wsk40",
	)
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 25,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 8,
		/obj/item/rogueweapon/spear = 12,
		/obj/item/rogueweapon/halberd = 5,
		/obj/item/rogueweapon/stoneaxe/woodcut/wardenpick = 10,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 10,
		/obj/item/quiver/arrows = 12,
		/obj/item/clothing/cloak/wardencloak = 8,
		/obj/item/clothing/suit/roguetown/armor/leather/studded/warden = 6,
		/obj/item/clothing/suit/roguetown/armor/leather/heavy = 10,
		/obj/item/clothing/suit/roguetown/armor/chainmail = 6,
		/obj/item/clothing/head/roguetown/helmet/sallet/warden = 5,
		"/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf" = 3,
		"/obj/item/clothing/head/roguetown/helmet/sallet/warden/goat" = 3,
		/obj/item/clothing/head/roguetown/helmet/sallet/warden/bear = 3,
		/obj/item/clothing/head/roguetown/roguehood/warden = 5,
		"/obj/item/clothing/head/roguetown/roguehood/warden/antler" = 3,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
		/obj/item/flashlight/flare/torch = 15,
		/obj/item/flint = 10,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 20,
		/obj/item/rogueweapon/halberd = 20,
		/obj/item/rogueweapon/stoneaxe/woodcut/wardenpick = 15,
		/obj/item/clothing/cloak/wardencloak = 15,
		/obj/item/clothing/suit/roguetown/armor/leather/studded/warden = 15,
		"/obj/item/clothing/head/roguetown/helmet/sallet/warden/wolf" = 10,
		"/obj/item/clothing/head/roguetown/helmet/sallet/warden/goat" = 10,
		/obj/item/clothing/head/roguetown/helmet/sallet/warden/bear = 10,
		"/obj/item/clothing/head/roguetown/roguehood/warden/antler" = 8,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
	)

/obj/structure/deadbody/wizard
	rockhill_poses = list(
		"wizard", "wiz10", "wiz20", "wiz30", "wiz40",
		"wizard_old", "wiza10", "wiza20", "wiza30", "wiza40",
	)
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 20,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 15,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 10,
	)

/obj/structure/deadbody/necromancer
	rockhill_poses = list(
		"necromancer", "nec10", "nec20", "nec30", "nec40",
		"necromancer_old", "necro10", "necro20", "necro30", "necro40",
	)
	rockhill_loot = list(
		/obj/item/natural/bone = 20,
		/obj/item/skull = 10,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 15,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 10,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 15,
	)

/obj/structure/deadbody/skeleton
	rockhill_poses = list("skeletons", "ske10", "ske20", "ske30", "ske40")
	rockhill_loot = list(
		/obj/item/natural/bone = 40,
		/obj/item/skull = 15,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 25,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 8,
		/obj/item/rogueweapon/huntingknife/idagger = 10,
		/obj/item/flint = 10,
		/obj/item/clothing/head/roguetown/helmet/kettle = 5,
	)

/obj/structure/deadbody/greater_skeleton
	rockhill_poses = list(
		"gsk10", "gsk20", "gsk30", "gsk40", "gsk50",
		"gske10", "gske20", "gske30", "gske40", "gske50",
	)
	rockhill_loot = list(
		/obj/item/natural/bone = 25,
		/obj/item/skull = 15,
		/obj/item/rogueweapon/sword/short/ancient = 15,
		/obj/item/rogueweapon/sword/short/gladius/ancient = 10,
		/obj/item/rogueweapon/spear/ancient = 10,
		/obj/item/rogueweapon/halberd/bardiche/ancient = 6,
		/obj/item/rogueweapon/greatsword/ancient = 4,
		/obj/item/rogueweapon/flail/sflail/ancient = 6,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ancient/decrepit = 10,
		/obj/item/clothing/under/roguetown/platelegs/ancient/decrepit = 8,
		/obj/item/clothing/wrists/roguetown/bracers/ancient/decrepit = 8,
		/obj/item/clothing/neck/roguetown/chaincoif/ancient/decrepit = 8,
	)
	rockhill_loot_lucky = list(
		/obj/item/rogueweapon/greatsword/ancient = 20,
		/obj/item/rogueweapon/halberd/bardiche/ancient = 18,
		/obj/item/rogueweapon/spear/ancient = 15,
		/obj/item/rogueweapon/flail/sflail/ancient = 12,
		/obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ancient = 20,
		/obj/item/clothing/under/roguetown/platelegs/ancient = 15,
		/obj/item/clothing/wrists/roguetown/bracers/ancient = 15,
		/obj/item/clothing/neck/roguetown/chaincoif/ancient = 15,
	)

/obj/structure/deadbody/rogue
	rockhill_poses = list("rog10", "rog20", "rog30", "rog40", "rog50")
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/mid = 25,
		/obj/item/storage/belt/rogue/pouch/coins/poor = 15,
		/obj/item/storage/belt/rogue/pouch/coins/rich = 10,
		/obj/item/rogueweapon/huntingknife/idagger = 20,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 15,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 8,
		/obj/item/rogueweapon/huntingknife/throwingknife/steel = 10,
		/obj/item/lockpick = 12,
		/obj/item/clothing/suit/roguetown/armor/leather/cuirass = 8,
		/obj/item/clothing/suit/roguetown/armor/leather/studded = 6,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
		/obj/item/roguestatue/glass = 8,
		/obj/item/roguestatue/gold = 4,
		/obj/item/roguestatue/silver = 6,
		/obj/item/candle/candlestick/gold = 6,
		/obj/item/candle/candlestick/silver = 8,
		/obj/item/candle/candlestick/gold/single = 5,
		/obj/item/candle/candlestick/silver/single = 6,
		/obj/item/clothing/ring/gold = 8,
		/obj/item/clothing/ring/silver = 8,
		/obj/item/clothing/ring/opal = 3,
		/obj/item/clothing/ring/turq = 3,
		/obj/item/clothing/ring/jade = 4,
		/obj/item/clothing/ring/coral = 4,
		/obj/item/roguegem/green = 8,
		/obj/item/roguegem/diamond = 3,
		/obj/item/roguegem/opal = 4,
		/obj/item/roguegem/turq = 5,
		/obj/item/roguegem/jade = 5,
		/obj/item/roguegem/amber = 5,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 20,
		/obj/item/rogueweapon/huntingknife/idagger/navaja = 15,
		/obj/item/rogueweapon/huntingknife/throwingknife/steel = 12,
		/obj/item/roguestatue/gold = 15,
		/obj/item/candle/candlestick/gold = 12,
		/obj/item/clothing/ring/opal = 10,
		/obj/item/clothing/ring/turq = 10,
		/obj/item/roguegem/diamond = 12,
		/obj/item/roguegem/opal = 12,
		/obj/item/roguegem/turq = 10,
	)

/obj/structure/deadbody/peasant
	rockhill_poses = list(
		"mpes10", "mpes20", "mpes30", "mpes40", "mpes50",
		"fpes10", "fpes20", "fpes30", "fpes40", "fpes50",
	)
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 60,
		/obj/item/reagent_containers/food/snacks/rogue/bread = 25,
		/obj/item/reagent_containers/food/snacks/rogue/raisinbread = 10,
		/obj/item/flashlight/flare/torch = 20,
		/obj/item/flint = 20,
		/obj/item/natural/bone = 15,
		/obj/item/needle = 10,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 5,
	)

/obj/structure/deadbody/bogman
	rockhill_poses = list("bogman", "bog10", "bog20", "bog30", "bog40")
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/poor = 30,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 20,
		/obj/item/rogueweapon/mace = 10,
		/obj/item/impact_grenade/explosion = 10,
		/obj/item/impact_grenade/smoke = 8,
		/obj/item/clothing/suit/roguetown/armor/leather/heavy = 8,
		/obj/item/clothing/suit/roguetown/armor/leather/hide = 8,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
		/obj/item/flashlight/flare/torch = 10,
		/obj/item/flashlight/flare/torch/lantern = 20,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 20,
		/obj/item/rogueweapon/huntingknife/idagger/steel = 20,
		/obj/item/rogueweapon/mace/steel = 15,
		/obj/item/impact_grenade/explosion = 25,
		/obj/item/impact_grenade/smoke = 15,
		/obj/item/clothing/suit/roguetown/armor/leather/heavy = 20,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 15,
	)

/obj/structure/deadbody/old_knight
	rockhill_poses = list("old_knight", "kn10", "kn20", "kn30", "kn40")
	rockhill_loot = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 25,
		/obj/item/storage/belt/rogue/pouch/coins/mid = 20,
		/obj/item/rogueweapon/sword/long = 15,
		/obj/item/rogueweapon/estoc = 6,
		/obj/item/rogueweapon/greatsword/zwei = 3,
		/obj/item/clothing/suit/roguetown/armor/plate/half = 10,
		/obj/item/clothing/suit/roguetown/armor/plate/full = 4,
		/obj/item/clothing/head/roguetown/helmet/heavy/knight = 8,
		/obj/item/clothing/head/roguetown/helmet/bascinet/pigface = 5,
		/obj/item/clothing/gloves/roguetown/plate = 10,
		/obj/item/clothing/under/roguetown/platelegs = 10,
		/obj/item/reagent_containers/glass/bottle/rogue/healthpot = 10,
	)
	rockhill_loot_lucky = list(
		/obj/item/storage/belt/rogue/pouch/coins/rich = 25,
		/obj/item/rogueweapon/sword/long = 20,
		/obj/item/rogueweapon/estoc = 15,
		/obj/item/rogueweapon/greatsword/zwei = 8,
		/obj/item/clothing/suit/roguetown/armor/plate/full = 15,
		/obj/item/clothing/head/roguetown/helmet/heavy/knight = 15,
		/obj/item/clothing/head/roguetown/helmet/bascinet/pigface = 12,
		/obj/item/clothing/gloves/roguetown/plate = 15,
		/obj/item/clothing/under/roguetown/platelegs = 15,
	)

#undef ROGUE_SEARCH_CLICK_CD
