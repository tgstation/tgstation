/// Ratwood's leeches on medieval maps (roguetown/roguejobs/fisher/leeches.dm, the item is the porter's): set on a bare limb, a
/// leech draws toxins out of the body and drinks its blood each Life tick (on_embed_life(), run by the blood element on the
/// body's Life, combat/blood.dm) until it is full or the body is dry, then drops off; ripped off early it tears the skin. Each wild
/// leech has a nature (leech_lore()): an evil one drinks more and cleanses less, and is named and coloured for it. A cheele,
/// Pestra's, squeezed in the hand, gives back the blood it holds instead. Off a body a leech slowly digests what it drank
/// (process(), counted when it is looked at or set on someone).

/// Ratwood leech_lore(): the scale of a leech's evil, and how far its nature moves its drinking and its cleansing (up to twice
/// its base each), never below one.
#define LEECH_EVILNESS_MAX 10
#define LEECH_NATURE_SPREAD 2
#define LEECH_LEAST_EFFECT 1

/obj/item/natural/worms/leech
	/// Gives blood instead of drinking it (Ratwood giving): a squeezed cheele.
	var/rogue_giving = FALSE
	/// Blood it drinks, or gives, each Life tick (Ratwood blood_sucking).
	var/rogue_suck = 0
	/// Toxins it draws out each Life tick (Ratwood toxin_healing).
	var/rogue_cleanse = 0
	/// Blood it holds (Ratwood blood_storage), and the most it holds (blood_maximum).
	var/rogue_blood = 0
	var/rogue_blood_max = 0
	/// What it keeps of the blood it drinks (Ratwood blood_multiplier).
	var/rogue_blood_factor = 1
	/// It digests what it holds (Ratwood drainage), counted from this time.
	var/rogue_digests = TRUE
	var/rogue_fed_at = 0
	/// It takes to a body without a mind (Ratwood mindless_attach).
	var/rogue_mindless_attach = TRUE
	/// Damage to the limb when it is ripped off (Ratwood embedded_unsafe_removal_pain_multiplier * w_class).
	var/rogue_rip_damage = 0
	/// The limb it is latched onto.
	var/obj/item/bodypart/rogue_limb

/obj/item/bodypart
	/// The leeches latched onto this limb (Ratwood embedded_objects).
	var/list/rogue_leeches

/obj/item/natural/worms/leech/Initialize(mapload)
	. = ..()
	rogue_set_nature()
	rogue_fed_at = world.time

/obj/item/natural/worms/leech/Destroy()
	if(rogue_limb)
		LAZYREMOVE(rogue_limb.rogue_leeches, src)
		rogue_limb = null
	return ..()

/// Ratwood's leech: its base drinking and cleansing, then its nature.
/obj/item/natural/worms/leech/proc/rogue_set_nature()
	rogue_suck = rogue_value("leech_suck")
	rogue_cleanse = rogue_value("leech_cleanse")
	rogue_blood_max = rogue_value("leech_blood_max")
	rogue_rip_damage = rogue_value("leech_rip_damage")
	rogue_leech_lore()

/// Ratwood's cheele: Pestra's work, always the same; it holds much blood from the start, keeps thrice what it drinks, digests
/// nothing, takes only to a body with a mind and comes off gently.
/obj/item/natural/worms/leech/cheele/rogue_set_nature()
	rogue_suck = rogue_value("cheele_suck")
	rogue_cleanse = rogue_value("leech_cleanse")
	rogue_blood_factor = rogue_value("cheele_blood_factor")
	rogue_blood = rogue_value("cheele_blood")
	rogue_blood_max = rogue_value("cheele_blood_max")
	rogue_digests = FALSE
	rogue_mindless_attach = FALSE
	rogue_rip_damage = 0

/// Ratwood leech_lore(): the leech's nature, from pitiful to bursting with hatred, gives it its colour, its words, and moves
/// its drinking up and its cleansing down the more evil it is.
/obj/item/natural/worms/leech/proc/rogue_leech_lore()
	var/static/list/all_colors = list(
		"#9860ff" = 8,
		"#bcff49" = 4,
		"#ffce49" = 2,
		"#79ddff" = 2,
		"#ff7878" = 1,
		"#ff31e4" = 1,
	)
	var/static/list/all_adjectives = list(
		"blood-sucking" = 20,
		"disgusting" = 10,
		"vile" = 8,
		"repugnant" = 4,
		"revolting" = 4,
		"grotesque" = 4,
		"hideous" = 4,
		"stupid" = 2,
		"dumb" = 2,
		"demonic" = 1,
		"graggoid" = 1,
		"zizoid" = 1,
	)
	var/static/list/all_descs = list(
		"What a disgusting creature." = 10,
		"Fucking gross." = 5,
		"Slippery..." = 3,
		"So yummy and full of blood." = 3,
		"I love this leech!" = 2,
		"It is so beautiful." = 2,
		"I wish I was a leech." = 1,
	)
	var/list/possible_adjectives = all_adjectives.Copy()
	var/list/possible_descs = all_descs.Copy()
	var/list/adjectives = list()
	var/list/descs = list()
	var/evilness = rand(0, LEECH_EVILNESS_MAX)
	switch(evilness)
		if(LEECH_EVILNESS_MAX to INFINITY)
			color = "#ff0000"
			adjectives += pick("evil", "malevolent", "misanthropic")
			descs += span_danger("This one is bursting with hatred!")
		if(5)
			if(prob(3))
				adjectives += pick("average", "ordinary", "boring")
				descs += "This one is extremely boring to look at."
		if(-INFINITY to 1)
			adjectives += pick("pitiful", "pathetic", "depressing")
			descs += "<span class='dead'>This one yearns for nothing but death.</span>"
		else
			var/adjective_amount = 1
			if(prob(5))
				adjective_amount = 3
			else if(prob(30))
				adjective_amount = 2
			for(var/count in 1 to adjective_amount)
				var/adjective = pick_weight(possible_adjectives)
				possible_adjectives -= adjective
				adjectives += adjective
				var/line = pick_weight(possible_descs)
				possible_descs -= line
				descs += line
	rogue_cleanse = max(round((LEECH_EVILNESS_MAX - evilness) / LEECH_EVILNESS_MAX * LEECH_NATURE_SPREAD * rogue_cleanse, 0.1), LEECH_LEAST_EFFECT)
	rogue_suck = max(round(evilness / LEECH_EVILNESS_MAX * LEECH_NATURE_SPREAD * rogue_suck, 0.1), LEECH_LEAST_EFFECT)
	if(evilness < LEECH_EVILNESS_MAX)
		color = pick_weight(all_colors)
	if(length(adjectives))
		name = "[english_list(adjectives)] [name]"
	if(length(descs))
		desc = "[desc] [jointext(descs, " ")]"

/// The cheele is Pestra's work, always the same (Ratwood consistent): no nature.
/obj/item/natural/worms/leech/cheele/rogue_leech_lore()
	return

/// Ratwood's leech examine: how full it is, and whether it drinks or gives.
/obj/item/natural/worms/leech/examine(mob/user)
	. = ..()
	rogue_digest()
	var/fill = rogue_blood_max ? rogue_blood / rogue_blood_max : 0
	switch(fill)
		if(0.8 to INFINITY)
			. += "<span class='bloody'><b>[p_Theyre()] fat and engorged with blood.</b></span>"
		if(0.5 to 0.8)
			. += "<span class='bloody'>[p_Theyre()] well fed.</span>"
		if(0.1 to 0.5)
			. += span_warning("[p_They()] want[p_s()] a meal.")
		else
			. += "<span class='dead'>[p_Theyre()] starved.</span>"
	if(rogue_giving)
		. += span_notice("[p_Theyre()] [pick("vomiting", "gorfing", "exhaling")].")
	else
		. += span_warning("[p_Theyre()] [pick("slurping", "sucking", "inhaling")].")

/// Ratwood's leech attack(): set on someone, on the limb aimed at.
/obj/item/natural/worms/leech/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!ishuman(interacting_with) || !rogue_combat_enabled())
		return ..()
	INVOKE_ASYNC(src, PROC_REF(rogue_place), interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/// Ratwood's leech attack(): not on the dead (only running blood is drawn) unless it gives, a cheele not on the mindless, and
/// only on a limb nothing covers; the Medicine skill makes it quicker.
/obj/item/natural/worms/leech/proc/rogue_place(mob/living/carbon/human/patient, mob/living/user)
	if(!rogue_giving && patient.stat == DEAD)
		to_chat(user, span_warning("They are deceased. Only running blood may be extracted."))
		return
	if(!rogue_giving && !patient.mind && !rogue_mindless_attach)
		to_chat(user, span_warning("They are mindless. \The [src] won't attach."))
		return
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	if(!limb)
		return
	if(!patient.try_inject(user, limb.body_zone, INJECT_TRY_SHOW_ERROR_MESSAGE))
		return
	var/time = max(rogue_value("leech_place_time") - user.rogue_skill_rank(/datum/attribute/skill/misc/medicine) * rogue_value("leech_place_per_rank"), 0)
	if(!do_after(user, time, target = patient))
		return
	if(QDELETED(limb) || limb.owner != patient || !user.is_holding(src) || !user.transferItemToLoc(src, limb))
		return
	rogue_latch(limb)
	if(patient == user)
		user.visible_message(span_notice("[user] places [src] on [user.p_their()] [limb.plaintext_zone]."), span_notice("I place a leech on my [limb.plaintext_zone]."))
	else
		user.visible_message(span_notice("[user] places [src] on [patient]'s [limb.plaintext_zone]."), span_notice("I place a leech on [patient]'s [limb.plaintext_zone]."))

/// Takes hold of the limb it lies in (Ratwood add_embedded_object()).
/obj/item/natural/worms/leech/proc/rogue_latch(obj/item/bodypart/limb)
	rogue_digest()
	rogue_limb = limb
	LAZYADD(limb.rogue_leeches, src)

/// Ratwood on_embed_life(), each Life tick of the body it is on, living or dead: it draws toxins out, then drinks blood, or a
/// squeezed cheele gives the blood it holds; full, empty, or with the body dry, it drops off. One past Journey's End is not
/// drunk from.
/obj/item/natural/worms/leech/proc/rogue_leech_tick(mob/living/carbon/human/host, ticks)
	rogue_digest()
	host.adjust_tox_loss(-rogue_cleanse * ticks)
	var/volume = host.get_blood_volume()
	if(rogue_giving)
		var/cap = rogue_value("cheele_blood_cap")
		var/given = min(cap - volume, rogue_blood, rogue_suck * ticks)
		if(given > 0)
			host.adjust_blood_volume(given, maximum = cap)
			rogue_blood -= given
		if(rogue_blood <= 0 || host.get_blood_volume() >= cap)
			rogue_drop_off()
		return
	if(HAS_TRAIT(host, TRAIT_JOURNEYS_END))
		return
	var/drunk = min(rogue_blood_max - rogue_blood, volume, rogue_suck * ticks)
	if(drunk > 0)
		host.adjust_blood_volume(-drunk)
		rogue_blood += drunk * rogue_blood_factor
	if(rogue_blood >= rogue_blood_max || host.get_blood_volume() <= 0)
		rogue_drop_off()

/// Ratwood remove_embedded_object(): it lets go, onto the ground under the body.
/obj/item/natural/worms/leech/proc/rogue_drop_off()
	var/obj/item/bodypart/limb = rogue_limb
	var/atom/ground = limb?.owner ? limb.owner.drop_location() : drop_location()
	forceMove(ground)

/// Ratwood's removal of an embedded object (human/human_topic.dm): at once, into the hand; a leech tears the skin as it comes
/// off (a cheele does not).
/obj/item/natural/worms/leech/proc/rogue_rip_off(mob/living/user)
	var/obj/item/bodypart/limb = rogue_limb
	var/mob/living/carbon/host = limb?.owner
	if(!host || !host.IsReachableBy(user) || user.incapacitated)
		return
	forceMove(host.drop_location())
	if(rogue_rip_damage > 0)
		if(limb.receive_damage(rogue_rip_damage, wound_bonus = CANT_WOUND))
			host.update_damage_overlays()
		host.emote("pain")
	playsound(host, 'modular_redtard/combat/sound/misc/flesh_rem.ogg', 100, TRUE, -2)
	if(user == host)
		user.visible_message(span_notice("[user] rips [src] out of [user.p_their()] [limb.plaintext_zone]!"), span_notice("I successfully remove [src] from my [limb.plaintext_zone]."))
	else
		user.visible_message(span_notice("[user] rips [src] out of [host]'s [limb.plaintext_zone]!"), span_notice("I successfully remove [src] from [host]'s [limb.plaintext_zone]."))
	user.put_in_hands(src)

/// Ratwood process(): a leech digests what it holds, a little each Life tick, on a body or off it.
/obj/item/natural/worms/leech/proc/rogue_digest()
	if(rogue_digests && rogue_blood > 0)
		rogue_blood = max(rogue_blood - rogue_value("leech_digest") * (world.time - rogue_fed_at) / (ROGUE_LIFE_TICK SECONDS), 0)
	rogue_fed_at = world.time

/// Ratwood's cheele attack_self(): squeezed, it turns from drawing blood to giving it, and back.
/obj/item/natural/worms/leech/cheele/attack_self(mob/user, modifiers)
	. = ..()
	if(. || !rogue_combat_enabled())
		return
	rogue_giving = !rogue_giving
	user.visible_message(span_notice("[user] squeezes [src]."), span_notice("I squeeze [src]. It will now [rogue_giving ? "infuse" : "extract"] blood."))
	return TRUE

#undef LEECH_EVILNESS_MAX
#undef LEECH_NATURE_SPREAD
#undef LEECH_LEAST_EFFECT
