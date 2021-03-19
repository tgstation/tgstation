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
/// Description of the religious sect, Presents itself in the selection menu (AKA be brief)
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
/// Opening message when someone gets converted
	var/convert_opener
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
/// Turns into 'desired_items_typecache', lists the types that can be sacrificed barring optional features in can_sacrifice()
	var/list/desired_items
/// Autopopulated by `desired_items`
	var/list/desired_items_typecache
/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list
/// Changes the Altar of Gods icon
	var/altar_icon
/// Changes the Altar of Gods icon_state
	var/altar_icon_state
/// Currently Active (non-deleted) rites
	var/list/active_rites

/datum/religion_sect/New()
	. = ..()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	if(rites_list)
		var/listylist = generate_rites_list()
		rites_list = listylist
	on_select()

///Generates a list of rites with 'name' = 'type'
/datum/religion_sect/proc/generate_rites_list()
	. = list()
	for(var/i in rites_list)
		if(!ispath(i))
			continue
		var/datum/religion_rites/RI = i
		var/name_entry = "[initial(RI.name)]"
		if(initial(RI.desc))
			name_entry += " - [initial(RI.desc)]"
		if(initial(RI.favor_cost))
			name_entry += " ([initial(RI.favor_cost)] favor)"

		. += list("[name_entry]" = i)

/// Activates once selected
/datum/religion_sect/proc/on_select()

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/L)
	to_chat(L, "<span class='notice'>[convert_opener]</span")

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering. Returning TRUE will stop the attackby sequence and proceed to on_sacrifice.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/L)
	. = TRUE
	if(!is_type_in_typecache(I,desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. This proc has NO bearing on the attackby sequence of other objects when used in conjunction with the religious_tool component.
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/L)
	return adjust_favor(default_item_favor,L)

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/L)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if((favor + amount > max_favor))
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = clamp(0,max_favor, favor+amount)

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/L)
	favor = clamp(0,max_favor,amount)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, atom/religious_tool)

/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/L, mob/living/user)
	if(!ishuman(L))
		return FALSE
	var/mob/living/carbon/human/H = L
	for(var/X in H.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.status == BODYPART_ROBOTIC)
			to_chat(user, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
			return TRUE

	var/heal_amt = 10
	var/list/hurt_limbs = H.get_damaged_bodyparts(1, 1, null, BODYPART_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYPART_ORGANIC))
				H.update_damage_overlays()
		H.visible_message("<span class='notice'>[user] heals [H] with the power of [GLOB.deity]!</span>")
		to_chat(H, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(user, "punch", 25, TRUE, -1)
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/puritanism
	name = "Puritanism (Default)"
	desc = "Nothing special."
	convert_opener = "Your run-of-the-mill sect, there are no benefits or boons associated. Praise normalcy!"

/datum/religion_sect/technophile
	name = "Technophile"
	desc = "A sect oriented around technology."
	convert_opener = "\"May you find peace in a metal shell, acolyte.\"<br>\
	Bibles now recharge cyborgs and heal robotic limbs if targeted, but they do not heal organic limbs. \
	You can now sacrifice cells, with favor depending on their charge."
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell)
	rites_list = list(/datum/religion_rites/synthconversion)
	altar_icon_state = "convertaltar-blue"

/datum/religion_sect/technophile/sect_bless(mob/living/L, mob/living/user)
	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		var/charge_amt = 50
		if(L.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amt *= 2
		R.cell?.charge += charge_amt
		R.visible_message("<span class='notice'>[user] charges [R] with the power of [GLOB.deity]!</span>")
		to_chat(R, "<span class='boldnotice'>You are charged by the power of [GLOB.deity]!</span>")
		SEND_SIGNAL(R, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(L))
		return
	var/mob/living/carbon/human/H = L

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/ethereal/eth_stomach = H.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(60)
		did_we_charge = TRUE

	//if we're not targetting a robot part we stop early
	var/obj/item/bodypart/BP = H.get_bodypart(user.zone_selected)
	if(BP.status != BODYPART_ROBOTIC)
		if(!did_we_charge)
			to_chat(user, "<span class='warning'>[GLOB.deity] scoffs at the idea of healing such fleshy matter!</span>")
		else
			H.visible_message("<span class='notice'>[user] charges [H] with the power of [GLOB.deity]!</span>")
			to_chat(H, "<span class='boldnotice'>You feel charged by the power of [GLOB.deity]!</span>")
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
			playsound(user, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(BP.heal_damage(5,5,null,BODYPART_ROBOTIC))
		H.update_damage_overlays()

	H.visible_message("<span class='notice'>[user] [did_we_charge ? "repairs" : "repairs and charges"] [H] with the power of [GLOB.deity]!</span>")
	to_chat(H, "<span class='boldnotice'>The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!</span>")
	playsound(user, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/technophile/on_sacrifice(obj/item/I, mob/living/L)
	var/obj/item/stock_parts/cell/the_cell = I
	if(!istype(the_cell)) //how...
		return
	if(the_cell.charge < 300)
		to_chat(L,"<span class='notice'>[GLOB.deity] does not accept pity amounts of power.</span>")
		return
	adjust_favor(round(the_cell.charge/300), L)
	to_chat(L, "<span class='notice'>You offer [the_cell]'s power to [GLOB.deity], pleasing them.</span>")
	qdel(I)
	return TRUE

/**** Ever-Burning Candle sect ****/

/datum/religion_sect/candle_sect
	name = "Ever-Burning Candle"
	desc = "A sect dedicated to candles."
	convert_opener = "\"May you be the wax to keep the Ever-Burning Candle burning, acolyte.\"<br>\
	Sacrificing burning corpses with a lot of burn damage and candles grants you favor."
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/candle)
	rites_list = list(/datum/religion_rites/fireproof, /datum/religion_rites/burning_sacrifice, /datum/religion_rites/infinite_candle)
	altar_icon_state = "convertaltar-red"

//candle sect bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/candle_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/candle_sect/on_sacrifice(obj/item/candle/offering, mob/living/user)
	if(!istype(offering))
		return
	if(!offering.lit)
		to_chat(user, "<span class='notice'>The candle needs to be lit to be offered!</span>")
		return
	to_chat(user, "<span class='notice'>Another candle for [GLOB.deity]'s collection.</span>")
	adjust_favor(20, user) //it's not a lot but hey there's a pacifist favor option at least
	qdel(offering)
	return TRUE

/datum/religion_sect/greed
	name = "Greedy God"
	desc = "A very mercantile sect."
	altar_icon_state = "convertaltar-yellow"
	alignment = ALIGNMENT_EVIL //greed is not good wtf
	rites_list = list(/datum/religion_rites/greed/vendatray, /datum/religion_rites/greed/custom_vending)
	convert_opener = "\"Greed is good.\"<br>\
	In the eyes of your mercantile diety, your wealth is your favor. Earn enough wealth to purchase some more business opportunities."
	altar_icon_state = "convertaltar-red"

/datum/religion_sect/honorbound
	name = "Honorbound God"
	desc = "A sect that does not engage in harm."
	altar_icon_state = "convertaltar-white"
	alignment = ALIGNMENT_GOOD
	convert_opener = "\"A good, honourable crusade against evil is required.\"<br>\
	Your diety requires fair fights from you. You may not attack the unready, the just, or the innocent.<br>\
	You earn favor by getting others to join the crusade, and you may spend favor to announce a battle, bypassing some conditions to attack."
	var/list/guilty = list() //list of guilty people

/datum/religion_sect/honorbound/on_conversion(mob/living/new_convert)
	RegisterSignal(new_convert, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/unarmed_honor_check)
	RegisterSignal(new_convert, COMSIG_ATOM_HULK_ATTACK, .proc/hulk_honor_check)
	RegisterSignal(new_convert, COMSIG_MOB_ITEM_ATTACK, .proc/itemattack_honor_check)

/datum/religion_sect/honorbound/proc/unarmed_honor_check(mob/living/carbon/human/honorbound_human, atom/target, proximity)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	var/mob/living/target_creature = target
	if(!is_honorable(honorbound_human, target_creature))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/religion_sect/honorbound/proc/hulk_honor_check(atom/target, mob/living/carbon/human/honorbound_human)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	var/mob/living/target_creature = target
	if(!is_honorable(honorbound_human, target_creature))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/religion_sect/honorbound/proc/itemattack_honor_check(atom/item, atom/target, mob/living/carbon/human/honorbound_human)
	SIGNAL_HANDLER
	if(!isliving(target))
		return
	var/mob/living/target_creature = target
	if(!is_honorable(honorbound_human, target_creature))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/religion_sect/honorbound/proc/is_honorable(mob/living/carbon/human/honorbound_human, mob/living/target_creature)
	var/is_guilty = (target_creature in guilty)
	//THE UNREADY (Applies over ANYTHING else!)
	if(target_creature.IsSleeping() || HAS_TRAIT(target_creature, TRAIT_RESTRAINED))
		to_chat(honorbound_human, "<span class='warning'>There is no honor in attacking the <b>unready</b>.</span>")
		return FALSE
	//THE JUST (Applies over guilt except for med, so you best be careful!)
	if(ishuman(target_creature))
		var/mob/living/carbon/human/target_human
		var/job = target_human.mind?.assigned_role
		if(job in GLOB.security_positions || job == "Chaplain")
			to_chat(honorbound_human, "<span class='warning'>There is nothing rightous in attacking the <b>just</b>.</span>")
			return FALSE
		if(job in GLOB.medical_positions)
			to_chat(honorbound_human, "<span class='warning'>If you truly think this healer is not <b>innocent</b>, declare them guilty.</span>")
			return FALSE
	//THE INNOCENT
	if(!is_guilty)
		to_chat(honorbound_human, "<span class='warning'>There is nothing rightous in attacking the <b>innocent</b>.</span>")
		return FALSE

#define MINIMUM_YUCK_REQUIRED 5

/datum/religion_sect/maintenance
	name = "Maintenance God"
	desc = "A sect based around the maintenance shafts of the station."
	altar_icon_state = "convertaltar-maint"
	alignment = ALIGNMENT_EVIL //while maint is more neutral in my eyes, the flavor of it kinda pertains to rotting and becoming corrupted by the maints
	convert_opener = "\"Your kingdom in the darkness.\"<br>\
	Sacrifice the organic slurry created from rats dipped in welding fuel to gain favor. Exchange favor to adapt to the maintenance shafts."
	rites_list = list(/datum/religion_rites/maint_adaptation, /datum/religion_rites/adapted_food)
	desired_items = list(/obj/item/reagent_containers)

/datum/religion_sect/maintenance/on_sacrifice(obj/item/reagent_containers/offering, mob/living/user)
	if(!istype(offering))
		return
	var/datum/reagent/yuck/wanted_yuck = offering.reagents.has_reagent(/datum/reagent/yuck, MINIMUM_YUCK_REQUIRED)
	var/favor_earned = offering.reagents.get_reagent_amount(/datum/reagent/yuck)
	if(!wanted_yuck)
		to_chat(user, "<span class='warning'>[offering] does not have enough Organic Slurry for [GLOB.deity] to enjoy.</span>")
		return
	to_chat(user, "<span class='notice'>[GLOB.deity] loves Organic Slurry.</span>")
	adjust_favor(favor_earned, user)
	playsound(get_turf(offering), 'sound/items/drink.ogg', 50, TRUE)
	offering.reagents.clear_reagents()
	return TRUE

#undef MINIMUM_YUCK_REQUIRED


