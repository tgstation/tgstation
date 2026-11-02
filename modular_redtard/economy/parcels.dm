/**
 * Parcels by the HERMES (Ratwood code/modules/roguetown/roguemachine/mail.dm, code/modules/_mini/carebox/,
 * modular_azurepeak mercmedals.dm): what the post brings besides letters.
 * - Care packages: a role with a benefactor (Ratwood's carebox tables: the Wretch) is sent a package every few changes of the
 *   time of day; its owner picks what it holds at any HERMES, and a random extra comes with it.
 * - The Guild's delivery: a holder of the Drug Supply trait finds a powder at the HERMES once a day, sometimes a rare one.
 * - Writs of commendation: anyone but a mercenary signs a mercenary's writ with a quill or a thorn; the mercenary posts it once
 *   a round and is rewarded with triumphs and the medal of their company (the medals wait for the porter).
 */

/// What a care package of a role holds (Ratwood /datum/carebox_table).
/datum/rogue_carebox_table
	/// Roles sent this package.
	var/list/jobs = list()
	/// Changes of the time of day between packages (Ratwood cycles).
	var/cycles = 4
	var/sender = "Benefactor"
	var/addendum = ""
	/// Picks the owner makes, random picks added from the rest, and what always comes.
	var/loot_choice = 1
	var/random_loot = 0
	var/list/extra_loot = list()
	/// Choice name -> list of item paths (text); a list("pick", n, paths...) gives n of the paths at random.
	var/list/loot = list()

/datum/rogue_carebox_table/wretch
	jobs = list(JOB_ROCKHILL_WRETCH)
	addendum = "\nAll packages contain 1 health potion.\nYou will also receive 1 random choice."
	random_loot = 1
	extra_loot = list("/obj/item/reagent_containers/glass/bottle/rogue/healthpot")
	loot = list(
		"Steel Mask" = list("pick", 1, "/obj/item/clothing/mask/rogue/facemask/steel", "/obj/item/clothing/mask/rogue/facemask/steel/hound"),
		"Steel Ingots (2)" = list("/obj/item/ingot/steel", "/obj/item/ingot/steel"),
		"Iron Ingots (3)" = list("/obj/item/ingot/iron", "/obj/item/ingot/iron", "/obj/item/ingot/iron"),
		"Gambeson" = list("/obj/item/clothing/suit/roguetown/armor/gambeson/heavy"),
		"Leather Clothes" = list("/obj/item/clothing/shoes/roguetown/boots/leather/reinforced", "/obj/item/clothing/gloves/roguetown/angle", "/obj/item/clothing/wrists/roguetown/bracers/leather/heavy", "/obj/item/clothing/under/roguetown/heavy_leather_pants"),
		"Leather Armor" = list("pick", 1, "/obj/item/clothing/suit/roguetown/armor/leather/studded", "/obj/item/clothing/suit/roguetown/armor/leather/heavy", "/obj/item/clothing/suit/roguetown/armor/leather/heavy/coat"),
		"Stamina Potion" = list("/obj/item/reagent_containers/glass/bottle/rogue/stampot"),
		"Mana Potion" = list("/obj/item/reagent_containers/glass/bottle/rogue/manapot"),
		"Raisin Loaf" = list("/obj/item/reagent_containers/food/snacks/rogue/raisinbread"),
		"Arrows and Bolts" = list("/obj/item/quiver/arrows", "/obj/item/quiver/bolts"),
		"Iron Throwing Knifes" = list("/obj/item/storage/belt/rogue/leather/knifebelt/black/iron"),
		"Pouch (Coins)" = list("/obj/item/storage/belt/rogue/pouch/coins/mid"),
		"Chains (2), Rope (1)" = list("/obj/item/rope/chain", "/obj/item/rope/chain", "/obj/item/rope"),
		"Lantern and Bedroll" = list("/obj/item/flashlight/flare/torch/lantern", "/obj/item/bedroll"),
		"Pouch (Medicine)" = list("/obj/item/storage/belt/rogue/pouch/medicine"),
		"Bottle Bomb (2)" = list("/obj/item/bomb", "/obj/item/bomb"),
		"Zizite Cross (2)" = list("/obj/item/clothing/neck/roguetown/psicross/inhumen/ancient", "/obj/item/clothing/neck/roguetown/psicross/inhumen/ancient"),
	)

/// The items one choice of a package yields; unported items are left out.
/datum/rogue_carebox_table/proc/items_of(list/choice)
	. = list()
	var/list/paths = choice
	if(length(choice) && choice[1] == "pick")
		paths = choice.Copy(3)
		for(var/i in 1 to choice[2])
			if(!length(paths))
				break
			var/path = text2path(pick_n_take(paths))
			if(path)
				. += path
		return
	for(var/path_text in paths)
		var/path = text2path(path_text)
		if(path)
			. += path

/datum/mind
	/// A care package waits for the subject at the HERMES (Ratwood TRAIT_CAREBOX).
	var/rogue_carebox_ready = FALSE
	/// Changes of the time of day the subject has lived through (Ratwood survived_cycles).
	var/rogue_survived_cycles = 0
	/// The dawn of the last delivery of the Guild; one a day (Ratwood has_drug_delivery).
	var/rogue_drug_dawn = -1
	/// The mercenary has posted their writ of commendation this round (Ratwood tokenclaimed).
	var/rogue_writ_posted = FALSE

/**
 * The post (Ratwood SSnightshift progress_cycles() and the drug supply of settod()): every change of the time of day counts
 * toward the care packages, and every dawn tells the Guild's clients that their delivery has come.
 */
SUBSYSTEM_DEF(rogue_post)
	name = "Post"
	flags = SS_NO_FIRE
	dependencies = list(
		/datum/controller/subsystem/mapping,
	)
	/// Every care package table.
	var/list/datum/rogue_carebox_table/carebox_tables = list()

/datum/controller/subsystem/rogue_post/Initialize()
	if(!rogue_economy_enabled())
		return SS_INIT_NO_NEED
	for(var/table_type in subtypesof(/datum/rogue_carebox_table))
		carebox_tables += new table_type
	RegisterSignal(SSdcs, COMSIG_GLOB_ROCKHILL_TIME_OF_DAY, PROC_REF(on_time_of_day))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/rogue_post/proc/table_for(mob/living/subject)
	var/title = subject?.mind?.assigned_role?.title
	if(!title)
		return null
	for(var/datum/rogue_carebox_table/table as anything in carebox_tables)
		if(title in table.jobs)
			return table
	return null

/datum/controller/subsystem/rogue_post/proc/on_time_of_day(datum/source, datum/rockhill_clock_step/phase/old_phase, datum/rockhill_clock_step/phase/new_phase)
	SIGNAL_HANDLER
	for(var/mob/living/carbon/human/subject as anything in GLOB.human_list)
		if(subject.stat == DEAD || !subject.mind || !subject.client)
			continue
		progress_carebox(subject)
		if(new_phase?.name == ROCKHILL_DAWN && HAS_TRAIT(subject, TRAIT_DRUG_SUPPLY))
			to_chat(subject, span_smallnotice("The Guild left something for me. I should check HERMES for my delivery."))

/// Ratwood human_cycle_progress(): every few changes of the time of day a package is sent.
/datum/controller/subsystem/rogue_post/proc/progress_carebox(mob/living/carbon/human/subject)
	var/datum/mind/mind = subject.mind
	mind.rogue_survived_cycles++
	var/datum/rogue_carebox_table/table = table_for(subject)
	if(!table || mind.rogue_carebox_ready || mind.rogue_survived_cycles % table.cycles)
		return
	mind.rogue_carebox_ready = TRUE
	to_chat(subject, span_notice("New letter from <b>[table.sender]</b>."))
	subject.playsound_local(subject, ROGUE_SOUND_MAIL, 100, FALSE)

/// Ratwood try_retrieve_carebox(): the owner picks what the package holds and takes it. Returns TRUE if a package was taken.
/obj/structure/roguemachine/mail/proc/retrieve_carebox(mob/living/carbon/human/user)
	if(!user.mind?.rogue_carebox_ready)
		return FALSE
	var/datum/rogue_carebox_table/table = SSrogue_post.table_for(user)
	if(!table || tgui_alert(user, "Do you wish to retrieve your special care package?", name, list("Yes", "No")) != "Yes")
		return FALSE
	var/list/choices = table.loot.Copy()
	var/list/picked = list()
	for(var/i in 1 to table.loot_choice)
		if(!length(choices))
			break
		var/choice = tgui_input_list(user, "What did I receive? (Choices: [table.loot_choice - i + 1])[table.addendum]", "MAIL", choices)
		if(!choice)
			return FALSE
		picked += list(choices[choice])
		choices -= choice
	for(var/i in 1 to table.random_loot)
		if(!length(choices))
			break
		var/choice = pick(choices)
		picked += list(choices[choice])
		choices -= choice
	if(QDELETED(src) || !user.Adjacent(src) || !user.mind?.rogue_carebox_ready)
		return FALSE
	user.mind.rogue_carebox_ready = FALSE
	to_chat(user, span_notice("I collect my package."))
	playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
	var/list/items = table.items_of(table.extra_loot)
	for(var/list/choice as anything in picked)
		items += table.items_of(choice)
	for(var/item_type in items)
		user.put_in_hands(new item_type(drop_location()))
	return TRUE

/// Ratwood TRAIT_DRUG_SUPPLY at the HERMES: once a day a powder, now and then a rare one. Returns TRUE if one was delivered.
/obj/structure/roguemachine/mail/proc/deliver_drugs(mob/living/carbon/human/user)
	if(!HAS_TRAIT(user, TRAIT_DRUG_SUPPLY) || !user.mind || user.mind.rogue_drug_dawn == GLOB.rockhill_dawns)
		return FALSE
	user.mind.rogue_drug_dawn = GLOB.rockhill_dawns
	var/drug_type
	if(prob(rogue_value("machines_mail_rare_drug_chance")))
		drug_type = pick(/obj/item/reagent_containers/powder/moondust_purest, /obj/item/reagent_containers/powder/herozium)
	else
		drug_type = pick(/obj/item/reagent_containers/powder/spice, /obj/item/reagent_containers/powder/moondust, /obj/item/reagent_containers/powder/starsugar)
	user.put_in_hands(new drug_type(drop_location()))
	playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
	return TRUE

/obj/item/merctoken
	/// Who vouched for the mercenary, and their role (Ratwood signee, signeejob).
	var/signee
	var/signee_job
	var/signed = FALSE

/// Ratwood merctoken attackby(): anyone but a mercenary who can read signs the writ with a quill or a thorn.
/obj/item/merctoken/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/natural/feather) && !istype(tool, /obj/item/natural/thorn))
		return NONE
	if(!user.can_read(src))
		to_chat(user, span_warning("Even a reader would find these verba incomprehensible."))
		return ITEM_INTERACT_BLOCKING
	if(signed)
		to_chat(user, span_warning("This writ has already been signed."))
		return ITEM_INTERACT_BLOCKING
	if(user.mind?.assigned_role?.title == JOB_ROCKHILL_MERCENARY)
		to_chat(user, span_warning("...have I really stooped so low as to sign my own commendation?"))
		return ITEM_INTERACT_BLOCKING
	signee = user.real_name
	signee_job = user.mind?.assigned_role?.title || "Subject"
	signed = TRUE
	desc = "A small, palm-fitting bound scroll that can be sent by mail to the Guild. Most of the fine print is unintelligible, save for one bold SIGNEE: [signee], [signee_job] of The Realm."
	user.visible_message(span_warning("[user] writes their name down on the token."))
	playsound(src, 'modular_redtard/economy/sound/write.ogg', 100, FALSE)
	return ITEM_INTERACT_SUCCESS

/obj/item/merctoken/examine(mob/user)
	. = ..()
	if(!signed)
		. += span_info("This could be signed with a quill... or a thorn, if one was desperate.")

/// The medal each mercenary company sends for a commendation (Ratwood merctype); the medals are not ported yet.
GLOBAL_LIST_INIT(rogue_merc_medals, list(
	"/datum/rockhill_advclass/mercenary/atgervi" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/atgervi",
	"/datum/rockhill_advclass/mercenary/gronnheavy" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/atgervi",
	"/datum/rockhill_advclass/mercenary/blackoak" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/blackoak",
	"/datum/rockhill_advclass/mercenary/condottiero" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/condottiero",
	"/datum/rockhill_advclass/mercenary/desert_rider" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/desertrider",
	"/datum/rockhill_advclass/mercenary/forlorn" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/forlorn",
	"/datum/rockhill_advclass/mercenary/freelancer" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/freifechter",
	"/datum/rockhill_advclass/mercenary/freelancer_lancer" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/freifechter",
	"/datum/rockhill_advclass/mercenary/freelancer_sabrist" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/freifechter",
	"/datum/rockhill_advclass/mercenary/grenzelhoft" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/grenzelhoft",
	"/datum/rockhill_advclass/mercenary/grudgebearer" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/grudgebearer",
	"/datum/rockhill_advclass/mercenary/rumaclan" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal",
	"/datum/rockhill_advclass/mercenary/routier" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/routier",
	"/datum/rockhill_advclass/mercenary/steppesman" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/steppesman",
	"/datum/rockhill_advclass/mercenary/vaquero" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/vaquero",
	"/datum/rockhill_advclass/mercenary/warscholar" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/warscholar",
	"/datum/rockhill_advclass/mercenary/crocs" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/anthrax",
	"/datum/rockhill_advclass/mercenary/crocsass" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/anthrax",
	"/datum/rockhill_advclass/mercenary/oathmarked" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal/oathmarked",
	"/datum/rockhill_advclass/mercenary/newmoon" = "/obj/item/clothing/neck/roguetown/luckcharm/mercmedal",
))

/// The medal of a mercenary's company, by their class or the class it derives from; null when not ported.
/proc/rogue_merc_medal(mob/living/carbon/human/mercenary)
	var/datum/rockhill_advclass/advclass = mercenary.rockhill_advclass
	if(!advclass)
		return text2path("/obj/item/clothing/neck/roguetown/luckcharm/mercmedal")
	for(var/class_text in GLOB.rogue_merc_medals)
		var/class_type = text2path(class_text)
		if(class_type && istype(advclass, class_type))
			return text2path(GLOB.rogue_merc_medals[class_text])
	return null

/// Ratwood: a mercenary posts a signed writ once a round; the Guild sends triumphs and the company's medal.
/obj/structure/roguemachine/mail/proc/post_writ(obj/item/merctoken/writ, mob/living/carbon/human/user)
	if(user.mind?.assigned_role?.title != JOB_ROCKHILL_MERCENARY)
		to_chat(user, span_warning("This is of no use to me - I may give this to a mercenary so they may send it themselves."))
		return
	if(user.mind.rogue_writ_posted)
		to_chat(user, span_warning("I have already received my commendation. There's always next week to look forward to!"))
		return
	if(!writ.signed)
		to_chat(user, span_warning("I cannot send an unsigned token."))
		return
	user.mind.rogue_writ_posted = TRUE
	qdel(writ)
	visible_message(span_warning("[user] sends something."))
	playsound(src, ROGUE_SOUND_FLUSH, 100, FALSE, -1)
	addtimer(CALLBACK(src, PROC_REF(reward_writ), user), 2 SECONDS)

/obj/structure/roguemachine/mail/proc/reward_writ(mob/living/carbon/human/user)
	if(QDELETED(user))
		return
	playsound(src, 'modular_redtard/economy/sound/triumph.ogg', 100, FALSE, -1)
	playsound(src, ROGUE_SOUND_HISS, 100, FALSE, -1)
	user.visible_message(span_warning("A trinket comes tumbling down from the machine. Proof of your distinction."))
	rogue_adjust_triumphs(user.ckey, rogue_value("machines_mail_writ_triumphs"))
	var/medal_type = rogue_merc_medal(user)
	if(medal_type)
		new medal_type(drop_location())
