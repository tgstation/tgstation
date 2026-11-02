// Ratwood's herbs (roguejobs/alchemist/herb_flora.dm): the alchemist's plants of the map - atropa, salvia, rosa and the rest,
// and the herb/random that turns into one of them - are picked by hand for their ingredient (/obj/item/alch/*, the manabloom's
// flower) and bear again five minutes later. Not ported: Ratwood's herb events (herb growth, spreading and withering of
// events/minor/herb_growth.dm and moderate/herb_spreading.dm, herb_wither.dm) that keep lists of the herbs.

/// How long a hand rummages in a herb (Ratwood do_after rand(3, 5) deciseconds).
#define ROCKHILL_HERB_PICK_MIN 3
#define ROCKHILL_HERB_PICK_MAX 5
/// Ratwood CLICK_CD_INTENTCAP: the pause after reaching into a herb.
#define ROCKHILL_HERB_CLICK_CD 6

/obj/structure/flora/roguegrass/herb
	/// Ratwood herbtype: what a hand picks from the herb, an /obj/item/alch ingredient (the manabloom gives its flower); the
	/// porter writes it.
	var/herbtype
	/// Ratwood harvested: picked, and not yet grown back.
	var/rockhill_picked = FALSE

/// Ratwood herb Initialize(): the herb says what it is, and bears its ingredient.
/obj/structure/flora/roguegrass/herb/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	desc = "An herb. This one looks like [name]."
	rockhill_herb_regrow()

/// Ratwood loot_replenish() of a herb: it bears its ingredient again.
/obj/structure/flora/roguegrass/herb/proc/rockhill_herb_regrow()
	if(herbtype)
		LAZYADD(rockhill_loot, herbtype)
	rockhill_picked = FALSE

/obj/structure/flora/roguegrass/herb/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user) || DOING_INTERACTION_WITH_TARGET(user, src))
		return
	if(rockhill_picked)
		to_chat(user, span_warning("Picked clean; but looks healthy. I should try again later."))
	user.changeNext_move(ROCKHILL_HERB_CLICK_CD)
	INVOKE_ASYNC(src, PROC_REF(rockhill_pick_herb), user)
	return TRUE

/// Ratwood herb attack_hand(): a quick rummage takes the ingredient in hand - two for a woodwalker - and the herb grows it back
/// five minutes later.
/obj/structure/flora/roguegrass/herb/proc/rockhill_pick_herb(mob/living/user)
	playsound(loc, pick(GLOB.rockhill_plant_rustle), 80, FALSE, -1)
	if(!do_after(user, rand(ROCKHILL_HERB_PICK_MIN, ROCKHILL_HERB_PICK_MAX), src) || QDELETED(src))
		return
	if(!length(rockhill_loot))
		return
	var/found_type = pick_n_take(rockhill_loot)
	var/obj/item/found = new found_type(user.loc)
	user.put_in_hands(found)
	var/woodwalker = HAS_TRAIT(user, TRAIT_WOODWALKER)
	if(woodwalker)
		user.put_in_hands(new found_type(user.loc))
	user.visible_message(span_notice("[user] finds [woodwalker ? "two of " : ""][found] in [src]."))
	rockhill_picked = TRUE
	addtimer(CALLBACK(src, PROC_REF(rockhill_herb_regrow)), rogue_value("herb_regrow_time"), TIMER_DELETE_ME)

#undef ROCKHILL_HERB_PICK_MIN
#undef ROCKHILL_HERB_PICK_MAX
#undef ROCKHILL_HERB_CLICK_CD
