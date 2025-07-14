/**
 * # Religious Sects
 *
 * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
 *
 * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
 * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
 *
 */
/datum/religion_sect
	/// Name of the religious sect
	var/name = "Religious Sect Base Type"
	/// Flavorful quote given about the sect, used in tgui
	var/quote = "Hail Coderbus! Coderbus #1! Fuck the playerbase!"
	/// Opening message when someone gets converted
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
	/// Tgui icon used by this sect - https://fontawesome.com/icons/
	var/tgui_icon = "bug"
	/// holder for alignments.
	var/alignment = ALIGNMENT_GOOD
	/// Does this require something before being available as an option?
	var/starter = TRUE
	/// The Sect's 'Mana'
	var/favor = 0 //MANA!
	/// The max amount of favor the sect can have
	var/max_favor = 1000
	/// The default value for an item that can be sacrificed
	var/default_item_favor = 5
	/// Turns into 'desired_items_typecache', and is optionally assoc'd to sacrifice instructions if needed.
	var/list/desired_items
	/// Autopopulated by `desired_items`
	var/list/desired_items_typecache
	/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list = list()
	/// Changes the Altar of Gods icon
	var/altar_icon
	/// Changes the Altar of Gods icon_state
	var/altar_icon_state
	/// Currently Active (non-deleted) rites
	var/list/active_rites
	/// Chance that we fail a bible blessing.
	var/smack_chance = DEFAULT_SMACK_CHANCE
	/// Whether the structure has CANDLE OVERLAYS!
	var/candle_overlay = TRUE

/datum/religion_sect/New()
	. = ..()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	if(!locate(/datum/religion_rites/deaconize) in rites_list)
		rites_list += list(/datum/religion_rites/deaconize)
	on_select()

/// Activates once selected
/datum/religion_sect/proc/on_select()
	SHOULD_CALL_PARENT(TRUE)
	SSblackbox.record_feedback("text", "sect_chosen", 1, name)

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/chap)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(chap, span_boldnotice("\"[quote]\""))
	to_chat(chap, span_notice("[desc]"))
	chap.faction |= FACTION_HOLY

/// Activates if religious sect is reset by admins, should clean up anything you added on conversion.
/datum/religion_sect/proc/on_deconversion(mob/living/chap)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(chap, span_boldnotice("You have lost the approval of \the [name]."))
	if(chap.mind.holy_role == HOLY_ROLE_HIGHPRIEST)
		to_chat(chap, span_notice("Return to an altar to reform your sect."))
	chap.faction -= FACTION_HOLY

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering. Returning TRUE will stop the attackby sequence and proceed to on_sacrifice.
/datum/religion_sect/proc/can_sacrifice(obj/item/sacrifice, mob/living/chap)
	. = TRUE
	if(chap.mind.holy_role == HOLY_ROLE_DEACON)
		to_chat(chap, span_warning("You are merely a deacon of [GLOB.deity], and therefore cannot perform rites."))
		return
	if(!is_type_in_typecache(sacrifice, desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. This proc has NO bearing on the attackby sequence of other objects when used in conjunction with the religious_tool component.
/datum/religion_sect/proc/on_sacrifice(obj/item/sacrifice, mob/living/chap)
	return adjust_favor(default_item_favor, chap)

/// Returns a description for religious tools
/datum/religion_sect/proc/tool_examine(mob/living/holy_creature)
	return "You are currently at [round(favor)] favor with [GLOB.deity]."

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/chap)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if((favor + amount > max_favor))
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = clamp(0, max_favor, favor+amount)

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/chap)
	favor = clamp(0,max_favor,amount)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, atom/religious_tool)

/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/target, mob/living/chap)
	if(!ishuman(target))
		return BLESSING_FAILED

	var/mob/living/carbon/human/blessed = target
	for(var/obj/item/bodypart/bodypart as anything in blessed.bodyparts)
		if(IS_ROBOTIC_LIMB(bodypart))
			to_chat(chap, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return BLESSING_IGNORED

	var/heal_amt = 10
	var/list/hurt_limbs = blessed.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC)

	if(!length(hurt_limbs))
		return BLESSING_IGNORED

	for(var/obj/item/bodypart/affecting as anything in hurt_limbs)
		if(affecting.heal_damage(heal_amt, heal_amt, required_bodytype = BODYTYPE_ORGANIC))
			blessed.update_damage_overlays()

	blessed.visible_message(span_notice("[chap] heals [blessed] with the power of [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("May the power of [GLOB.deity] compel you to be healed!"))
	playsound(chap, SFX_PUNCH, 25, TRUE, -1)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return BLESSING_SUCCESS

/// What happens if we bless a corpse? By default just do the default smack behavior
/datum/religion_sect/proc/sect_dead_bless(mob/living/target, mob/living/chap)
	return FALSE

/**** Nanotrasen Approved God ****/

/datum/religion_sect/puritanism
	name = "Nanotrasen Approved God"
	desc = "Your run-of-the-mill sect, there are no benefits or boons associated."
	quote = "Nanotrasen Recommends!"
	tgui_icon = "bible"

/**** Mechanical God ****/

/datum/religion_sect/mechanical
	name = "Mechanical God"
	quote = "May you find peace in a metal shell."
	desc = "Bibles now recharge cyborgs and heal robotic limbs if targeted, but they \
	do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	tgui_icon = "robot"
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/power_store = "with battery charge")
	rites_list = list(/datum/religion_rites/synthconversion, /datum/religion_rites/machine_blessing)
	altar_icon_state = "convertaltar-blue"
	max_favor = 2500

/datum/religion_sect/mechanical/sect_bless(mob/living/target, mob/living/chap)
	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		var/charge_amount = 0.05 * STANDARD_CELL_CHARGE
		if(target.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amount *= 2
		R.cell?.charge += charge_amount
		R.visible_message(span_notice("[chap] charges [R] with the power of [GLOB.deity]!"))
		to_chat(R, span_boldnotice("You are charged by the power of [GLOB.deity]!"))
		R.add_mood_event("blessing", /datum/mood_event/blessing)
		playsound(chap, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return BLESSING_SUCCESS

	if(!ishuman(target))
		return BLESSING_FAILED

	var/mob/living/carbon/human/blessed = target

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/ethereal/eth_stomach = blessed.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(0.06 * STANDARD_CELL_CHARGE)
		did_we_charge = TRUE

	//if we're not targeting a robot part we stop early
	var/obj/item/bodypart/bodypart = blessed.get_bodypart(chap.zone_selected)
	if(IS_ORGANIC_LIMB(bodypart))
		if(!did_we_charge)
			to_chat(chap, span_warning("[GLOB.deity] scoffs at the idea of healing such fleshy matter!"))
			return BLESSING_IGNORED

		blessed.visible_message(span_notice("[chap] charges [blessed] with the power of [GLOB.deity]!"))
		to_chat(blessed, span_boldnotice("You feel charged by the power of [GLOB.deity]!"))
		blessed.add_mood_event("blessing", /datum/mood_event/blessing)
		playsound(chap, 'sound/machines/synth/synth_yes.ogg', 25, TRUE, -1)
		return BLESSING_SUCCESS

	//charge(?) and go
	if(bodypart.heal_damage(5,5,BODYTYPE_ROBOTIC))
		blessed.update_damage_overlays()

	blessed.visible_message(span_notice("[chap] [did_we_charge ? "repairs and charges" : "repairs"] [blessed] with the power of [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("The inner machinations of [GLOB.deity] [did_we_charge ? "repairs and charges" : "repairs"] you!"))
	playsound(chap, 'sound/effects/bang.ogg', 25, TRUE, -1)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return BLESSING_SUCCESS

/datum/religion_sect/mechanical/on_sacrifice(obj/item/stock_parts/power_store/cell/power_cell, mob/living/chap)
	if(!istype(power_cell))
		return

	if(power_cell.charge() < 0.3 * STANDARD_CELL_CHARGE)
		to_chat(chap, span_notice("[GLOB.deity] does not accept pity amounts of power."))
		return

	adjust_favor(round(power_cell.charge() / (0.3 * STANDARD_CELL_CHARGE)), chap)
	to_chat(chap, span_notice("You offer [power_cell]'s power to [GLOB.deity], pleasing them."))
	qdel(power_cell)
	return TRUE

/**** Pyre God ****/

/datum/religion_sect/pyre
	name = "Pyre God"
	desc = "Sacrificing burning corpses with a lot of burn damage and candles grants you favor."
	quote = "It must burn! The primal energy must be respected."
	tgui_icon = "fire-alt"
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/flashlight/flare/candle = "already lit")
	rites_list = list(/datum/religion_rites/fireproof, /datum/religion_rites/burning_sacrifice, /datum/religion_rites/infinite_candle)
	altar_icon_state = "convertaltar-red"

/datum/religion_sect/pyre/on_select()
	. = ..()
	AddComponent(/datum/component/sect_nullrod_bonus, list(
		/obj/item/gun/ballistic/bow/divine/with_quiver = list(
			/datum/religion_rites/blazing_star,
		),
	))


/datum/religion_sect/pyre/on_sacrifice(obj/item/flashlight/flare/candle/offering, mob/living/user)
	if(!istype(offering))
		return
	if(!offering.light_on)
		to_chat(user, span_notice("The candle needs to be lit to be offered!"))
		return
	to_chat(user, span_notice("[GLOB.deity] is pleased with your sacrifice."))
	adjust_favor(40, user) //it's not a lot but hey there's a pacifist favor option at least
	qdel(offering)
	return TRUE

#define GREEDY_HEAL_COST 50

/datum/religion_sect/greed
	name = "Greedy God"
	quote = "Greed is good."
	desc = "In the eyes of your mercantile deity, your wealth is your favor. Earn enough wealth to purchase some more business opportunities."
	tgui_icon = "dollar-sign"
	altar_icon_state = "convertaltar-yellow"
	alignment = ALIGNMENT_EVIL //greed is not good wtf
	rites_list = list(/datum/religion_rites/greed/vendatray, /datum/religion_rites/greed/custom_vending)
	altar_icon_state = "convertaltar-yellow"

/datum/religion_sect/greed/tool_examine(mob/living/holy_creature) //display money policy
	return "In the eyes of [GLOB.deity], your wealth is your favor."

/datum/religion_sect/greed/sect_bless(mob/living/blessed_living, mob/living/chap)
	if(!ishuman(blessed_living))
		return BLESSING_FAILED

	var/datum/bank_account/account = chap.get_bank_account()
	if(!account)
		to_chat(chap, span_warning("You need a way to pay for the heal!"))
		return BLESSING_IGNORED

	if(account.account_balance < GREEDY_HEAL_COST)
		to_chat(chap, span_warning("Healing from [GLOB.deity] costs [GREEDY_HEAL_COST] credits for 30 health!"))
		return BLESSING_IGNORED

	var/mob/living/carbon/human/blessed = blessed_living
	for(var/obj/item/bodypart/robolimb as anything in blessed.bodyparts)
		if(IS_ROBOTIC_LIMB(robolimb))
			to_chat(chap, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return BLESSING_IGNORED

	account.adjust_money(-GREEDY_HEAL_COST, "Church Donation: Treatment")
	var/heal_amt = 30
	var/list/hurt_limbs = blessed.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC)
	if(!length(hurt_limbs))
		return BLESSING_IGNORED

	for(var/obj/item/bodypart/affecting as anything in hurt_limbs)
		if(affecting.heal_damage(heal_amt, heal_amt, required_bodytype = BODYTYPE_ORGANIC))
			blessed.update_damage_overlays()

	blessed.visible_message(span_notice("[chap] barters a heal for [blessed] from [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("May the power of [GLOB.deity] compel you to be healed! Thank you for choosing [GLOB.deity]!"))
	playsound(chap, 'sound/effects/cashregister.ogg', 60, TRUE)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return BLESSING_SUCCESS

#undef GREEDY_HEAL_COST

/datum/religion_sect/burden
	name = "Punished God"
	quote = "To feel the freedom, you must first understand captivity."
	desc = "Incapacitate yourself in any way possible. Bad mutations, lost limbs, traumas, \
		even addictions. You will learn the secrets of the universe from your defeated shell."
	tgui_icon = "user-injured"
	altar_icon_state = "convertaltar-burden"
	alignment = ALIGNMENT_NEUT
	candle_overlay = FALSE
	smack_chance = 0
	rites_list = list(/datum/religion_rites/nullrod_transformation)

/datum/religion_sect/burden/on_conversion(mob/living/carbon/human/new_convert)
	..()
	if(!ishuman(new_convert))
		to_chat(new_convert, span_warning("[GLOB.deity] needs higher level creatures to fully comprehend the suffering. You are not burdened."))
		return
	new_convert.gain_trauma(/datum/brain_trauma/special/burdened, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/religion_sect/burden/on_deconversion(mob/living/carbon/human/new_convert)
	if (ishuman(new_convert))
		new_convert.cure_trauma_type(/datum/brain_trauma/special/burdened, TRAUMA_RESILIENCE_ABSOLUTE)
	return ..()

/datum/religion_sect/burden/tool_examine(mob/living/carbon/human/burdened) //display burden level
	if(ishuman(burdened))
		var/datum/brain_trauma/special/burdened/burden = burdened.has_trauma_type(/datum/brain_trauma/special/burdened)
		if(burden)
			return "You are at burden level [burden.burden_level]/9."
	return "You are not burdened."

/datum/religion_sect/burden/sect_bless(mob/living/carbon/target, mob/living/carbon/chaplain)
	if(!istype(target) || !istype(chaplain))
		return BLESSING_FAILED

	var/datum/brain_trauma/special/burdened/burden = chaplain.has_trauma_type(/datum/brain_trauma/special/burdened)
	if(!burden)
		return BLESSING_FAILED

	var/burden_modifier = max(1 - 0.07 * burden.burden_level, 0.01)
	var/transferred = FALSE
	var/list/hurt_limbs = target.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC) + target.get_wounded_bodyparts(BODYTYPE_ORGANIC)
	var/list/chaplains_limbs = list()
	for(var/obj/item/bodypart/possible_limb in chaplain.bodyparts)
		if(IS_ORGANIC_LIMB(possible_limb))
			chaplains_limbs += possible_limb

	if(length(chaplains_limbs))
		for(var/obj/item/bodypart/affected_limb as anything in hurt_limbs)
			var/obj/item/bodypart/chaplains_limb = chaplain.get_bodypart(affected_limb.body_zone)
			if(!chaplains_limb || !IS_ORGANIC_LIMB(chaplains_limb))
				chaplains_limb = pick(chaplains_limbs)
			var/brute_damage = affected_limb.brute_dam
			var/burn_damage = affected_limb.burn_dam
			if((brute_damage || burn_damage))
				transferred = TRUE
				affected_limb.heal_damage(brute_damage, burn_damage, required_bodytype = BODYTYPE_ORGANIC)
				chaplains_limb.receive_damage(brute_damage * burden_modifier, burn_damage * burden_modifier, forced = TRUE, wound_bonus = CANT_WOUND)
			for(var/datum/wound/iter_wound as anything in affected_limb.wounds)
				transferred = TRUE
				iter_wound.remove_wound()
				iter_wound.apply_wound(chaplains_limb)

		if(HAS_TRAIT_FROM(target, TRAIT_HUSK, BURN))
			transferred = TRUE
			target.cure_husk(BURN)
			chaplain.become_husk(BURN)

	var/toxin_damage = target.getToxLoss()
	if(toxin_damage && !HAS_TRAIT(chaplain, TRAIT_TOXIMMUNE))
		transferred = TRUE
		target.adjustToxLoss(-toxin_damage)
		chaplain.adjustToxLoss(toxin_damage * burden_modifier, forced = TRUE)

	var/suffocation_damage = target.getOxyLoss()
	if(suffocation_damage && !HAS_TRAIT(chaplain, TRAIT_NOBREATH))
		transferred = TRUE
		target.adjustOxyLoss(-suffocation_damage)
		chaplain.adjustOxyLoss(suffocation_damage * burden_modifier, forced = TRUE)

	if(!HAS_TRAIT(chaplain, TRAIT_NOBLOOD))
		if(target.blood_volume < BLOOD_VOLUME_SAFE)
			var/transferred_blood_amount = min(chaplain.blood_volume, BLOOD_VOLUME_SAFE - target.blood_volume)
			if(transferred_blood_amount && target.get_blood_compatibility(chaplain))
				transferred = chaplain.transfer_blood_to(target, transferred_blood_amount, forced = TRUE)
		else if(target.blood_volume > BLOOD_VOLUME_EXCESS)
			transferred = target.transfer_blood_to(chaplain, target.blood_volume - BLOOD_VOLUME_EXCESS, forced = TRUE)

	target.update_damage_overlays()
	chaplain.update_damage_overlays()
	if(!transferred)
		to_chat(chaplain, span_warning("They hold no burden!"))
		return BLESSING_IGNORED

	target.visible_message(span_notice("[chaplain] takes on [target]'s burden!"))
	to_chat(target, span_boldnotice("May the power of [GLOB.deity] compel you to be healed!"))
	playsound(chaplain, SFX_PUNCH, 25, vary = TRUE, extrarange = -1)
	target.add_mood_event("blessing", /datum/mood_event/blessing)
	return BLESSING_SUCCESS

/datum/religion_sect/burden/sect_dead_bless(mob/living/target, mob/living/chaplain)
	return sect_bless(target, chaplain)

/datum/religion_sect/honorbound
	name = "Honorbound God"
	quote = "A good, honorable crusade against evil is required."
	desc = "Your deity requires fair fights from you. You may not attack the unready, the just, or the innocent. \
	You earn favor by getting others to join the crusade, and you may spend favor to announce a battle, bypassing some conditions to attack."
	tgui_icon = "scroll"
	altar_icon_state = "convertaltar-white"
	alignment = ALIGNMENT_GOOD
	rites_list = list(/datum/religion_rites/deaconize/crusader, /datum/religion_rites/forgive, /datum/religion_rites/summon_rules)

/datum/religion_sect/honorbound/on_conversion(mob/living/carbon/new_convert)
	..()
	if(!ishuman(new_convert))
		to_chat(new_convert, span_warning("[GLOB.deity] has no respect for lower creatures, and refuses to make you honorbound."))
		return FALSE
	new_convert.gain_trauma(/datum/brain_trauma/special/honorbound, TRAUMA_RESILIENCE_MAGIC)

/datum/religion_sect/honorbound/on_deconversion(mob/living/carbon/human/new_convert)
	if (ishuman(new_convert))
		new_convert.cure_trauma_type(/datum/brain_trauma/special/honorbound, TRAUMA_RESILIENCE_MAGIC)
	return ..()

#define MINIMUM_YUCK_REQUIRED 5

/datum/religion_sect/maintenance
	name = "Maintenance God"
	quote = "Your kingdom in the darkness."
	desc = "Sacrifice the organic slurry created from rats dipped in welding fuel to gain favor. Exchange favor to adapt to the maintenance shafts."
	tgui_icon = "eye"
	altar_icon_state = "convertaltar-maint"
	alignment = ALIGNMENT_EVIL //while maint is more neutral in my eyes, the flavor of it kinda pertains to rotting and becoming corrupted by the maints
	rites_list = list(/datum/religion_rites/maint_adaptation, /datum/religion_rites/adapted_eyes, /datum/religion_rites/adapted_food, /datum/religion_rites/ritual_totem)
	desired_items = list(/obj/item/reagent_containers = "holding organic slurry")

/datum/religion_sect/maintenance/sect_bless(mob/living/blessed_living, mob/living/chap)
	if(!ishuman(blessed_living))
		return BLESSING_FAILED

	var/mob/living/carbon/human/blessed = blessed_living
	if(blessed.reagents.has_reagent(/datum/reagent/drug/maint/sludge))
		to_chat(blessed, span_warning("[GLOB.deity] has already empowered them."))
		return BLESSING_IGNORED

	blessed.reagents.add_reagent(/datum/reagent/drug/maint/sludge, 5)
	blessed.visible_message(span_notice("[chap] empowers [blessed] with the power of [GLOB.deity]!"))
	to_chat(blessed, span_boldnotice("The power of [GLOB.deity] has made you harder to wound for a while!"))
	playsound(chap, SFX_PUNCH, 25, TRUE, -1)
	blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return BLESSING_SUCCESS //trust me, you'll be feeling the pain from the maint drugs all well enough

/datum/religion_sect/maintenance/on_sacrifice(obj/item/reagent_containers/offering, mob/living/user)
	if(!istype(offering))
		return
	var/datum/reagent/yuck/wanted_yuck = offering.reagents.has_reagent(/datum/reagent/yuck, MINIMUM_YUCK_REQUIRED)
	var/favor_earned = offering.reagents.get_reagent_amount(/datum/reagent/yuck)
	if(!wanted_yuck)
		to_chat(user, span_warning("[offering] does not have enough organic slurry for [GLOB.deity] to enjoy."))
		return
	to_chat(user, span_notice("[GLOB.deity] loves organic slurry."))
	adjust_favor(favor_earned, user)
	playsound(get_turf(offering), 'sound/items/drink.ogg', 50, TRUE)
	offering.reagents.clear_reagents()
	return TRUE

#undef MINIMUM_YUCK_REQUIRED

/datum/religion_sect/spar
	name = "Sparring God"
	quote = "Your next swing must be faster, neophyte. Steel your heart."
	desc = "Spar other crewmembers to gain favor or other rewards. Exchange favor to steel yourself against real battles."
	tgui_icon = "fist-raised"
	altar_icon_state = "convertaltar-orange"
	alignment = ALIGNMENT_NEUT
	rites_list = list(
		/datum/religion_rites/sparring_contract,
		/datum/religion_rites/ceremonial_weapon,
		/datum/religion_rites/declare_arena,
		/datum/religion_rites/tenacious,
		/datum/religion_rites/unbreakable,
	)
	///the one allowed contract. making a new contract dusts the old one
	var/obj/item/sparring_contract/existing_contract
	///places you can spar in. rites can be used to expand this list with new arenas!
	var/list/arenas = list(
		"Recreation Area" = /area/station/commons/fitness/recreation,
		"Chapel" = /area/station/service/chapel,
	)
	///how many matches you've lost with holy stakes. 3 = excommunication
	var/matches_lost = 0
	///past opponents who you've beaten in holy battles. You can't fight them again to prevent favor farming
	var/list/past_opponents = list()

/datum/religion_sect/spar/tool_examine(mob/living/holy_creature)
	return "You have [round(favor)] sparring matches won in [GLOB.deity]'s name to redeem. You have lost [matches_lost] holy matches. You will be excommunicated after losing three matches."

/datum/religion_sect/music
	name = "Festival God"
	quote = "Everything follows a rhythm- The heartbeat of the universe!"
	desc = "Make wonderful music! Sooth or serrate your friends and foes with the beat."
	tgui_icon = "music"
	altar_icon_state = "convertaltar-festival"
	alignment = ALIGNMENT_GOOD
	candle_overlay = FALSE
	rites_list = list(
		/datum/religion_rites/holy_violin,
		/datum/religion_rites/portable_song_tuning,
		/datum/religion_rites/song_tuner/evangelism,
		/datum/religion_rites/song_tuner/light,
		/datum/religion_rites/song_tuner/nullwave,
		/datum/religion_rites/song_tuner/pain,
		/datum/religion_rites/song_tuner/lullaby,
	)

/datum/religion_sect/music/on_conversion(mob/living/chap)
	. = ..()
	new /obj/item/choice_beacon/music(get_turf(chap))
