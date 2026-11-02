/// Known people (Ratwood code/datums/mind.dm known_people, i_know_person(), person_knows_me(), do_i_know(),
/// display_known_people(); jobs/job_types/_job.dm and roguetown/roguetown.dm peopleiknow, peopleknowme): a mind keeps the
/// people it knows by real name, with what it knows of each - the title they go by, gender, race, age, house, the colour
/// of their voice and the mark of a heresy shared or seen. On arrival a role that keeps an account (Ratwood
/// give_bank_account, economy/jobs.dm rogue_bank_account) knows the town - the holders of the roles of Ratwood's position
/// lists - and the town knows the newcomer; the dungeoneer is known only to the garrison, the nobility and the court; a
/// Towner and the wanderers who live in town know each other. Someone without a special role neither knows nor is known
/// by the holders of Ratwood's secret roles. Looking someone in the face on a medieval map makes them known
/// (jobs/examine.dm). The heart of the HUD lists the people one knows on right click (hud/rogue_hud_elements.dm).
///
/// What later systems build on: on /datum/mind rogue_i_know_person(), rogue_person_knows_me(), rogue_know_each_other(),
/// rogue_do_i_know(), rogue_become_unknown_to(), rogue_unknow_all_people(), rogue_known_names(),
/// rogue_display_known_people(); /proc/rogue_get_minds(); on /datum/job/roguetown rogue_introduce() and
/// rogue_reintroduce(); /proc/rogue_sync_resident_wanderer_knowledge(); GLOB.rogue_positions.

/// Ratwood's position lists (jobs/jobs.dm noble_positions and the rest) by the titles of Rockhill's roles: ROGUE_POSITIONS_*
/// = titles. A role that keeps an account knows all of them, and they know it. Left out are the titles no role of Rockhill
/// bears - Consort, Suitor, Confessor, Mortician, Scribe, Miner, Hunter, Fisher, Lumberjack, Villager, Nightmaster,
/// Beggar, Pilgrim, the desert town's roles and the old mercenary titles of mercenary_positions - and "Prisoner": the
/// prisoner of Rockhill is "Prisoner (Town)", whom Ratwood's lists miss, so those who arrive after the prisoners do not
/// know them.
GLOBAL_LIST_INIT(rogue_positions, list(
	ROGUE_POSITIONS_NOBLE = list(
		JOB_ROCKHILL_GRAND_DUKE,
		JOB_ROCKHILL_BARON,
		JOB_ROCKHILL_PRINCE,
		JOB_ROCKHILL_HAND,
		JOB_ROCKHILL_KNIGHT_CAPTAIN,
		JOB_ROCKHILL_MARSHAL,
		JOB_ROCKHILL_COUNCILLOR,
		JOB_ROCKHILL_STEWARD,
		JOB_ROCKHILL_CLERK,
		JOB_ROCKHILL_KNIGHT,
	),
	ROGUE_POSITIONS_COURTIER = list(
		JOB_ROCKHILL_COURT_MAGICIAN,
		JOB_ROCKHILL_MAGICIANS_ASSOCIATE,
		JOB_ROCKHILL_HEAD_PHYSICIAN,
		JOB_ROCKHILL_APOTHECARY,
		JOB_ROCKHILL_JESTER,
		JOB_ROCKHILL_SENESCHAL,
		JOB_ROCKHILL_SERVANT,
		JOB_ROCKHILL_COURT_CHAPLAIN,
	),
	ROGUE_POSITIONS_GARRISON = list(
		JOB_ROCKHILL_CITY_GUARD,
		JOB_ROCKHILL_ROOKIE,
		JOB_ROCKHILL_FOREST_WARDEN,
		JOB_ROCKHILL_SERGEANT,
		JOB_ROCKHILL_RETAINER,
		JOB_ROCKHILL_VETERAN,
		JOB_ROCKHILL_MAN_AT_ARMS,
		JOB_ROCKHILL_SQUIRE,
		JOB_ROCKHILL_VANGUARD,
		JOB_ROCKHILL_DUNGEONEER,
		JOB_ROCKHILL_MASTER_WARDEN,
		JOB_ROCKHILL_WATCH_CAPTAIN,
	),
	ROGUE_POSITIONS_CHURCH = list(
		JOB_ROCKHILL_BISHOP,
		JOB_ROCKHILL_ACOLYTE,
		JOB_ROCKHILL_KEEPER,
		JOB_ROCKHILL_TEMPLAR,
		JOB_ROCKHILL_DRUID,
		JOB_ROCKHILL_MARTYR,
	),
	ROGUE_POSITIONS_INQUISITION = list(
		JOB_ROCKHILL_INQUISITOR,
		JOB_ROCKHILL_ORTHODOXIST,
		JOB_ROCKHILL_ABSOLVER,
	),
	ROGUE_POSITIONS_YEOMAN = list(
		JOB_ROCKHILL_MERCHANT,
		JOB_ROCKHILL_INNKEEPER,
		JOB_ROCKHILL_ARCHIVIST,
		JOB_ROCKHILL_TOWN_CRIER,
		JOB_ROCKHILL_BATHMASTER,
		JOB_ROCKHILL_GUILDMASTER,
		JOB_ROCKHILL_GUILDSMAN,
		JOB_ROCKHILL_SLAVER,
		JOB_ROCKHILL_TAILOR,
	),
	ROGUE_POSITIONS_PEASANT = list(
		JOB_ROCKHILL_SOILSON,
		JOB_ROCKHILL_MANOR_COOK,
		JOB_ROCKHILL_LUNATIC,
		JOB_ROCKHILL_TOWNER,
		JOB_ROCKHILL_TAPSTER,
		JOB_ROCKHILL_BATHHOUSE_ATTENDANT,
		JOB_ROCKHILL_SLAVE,
		JOB_ROCKHILL_REFUGEE,
	),
	ROGUE_POSITIONS_YOUNGFOLK = list(
		JOB_ROCKHILL_CHURCHLING,
		JOB_ROCKHILL_SHOPHAND,
		JOB_ROCKHILL_VAGABOND,
		JOB_ROCKHILL_GUILD_APPRENTICE,
	),
))

/// Ratwood's special roles (ROLE_VAMPIRE, ROLE_NBEAST, ROLE_BANDIT, ROLE_LICH, ROLE_WRETCH, ROLE_UNBOUND_DEATHKNIGHT) whose
/// holders the town does not know on arrival, nor learns of when they arrive; the antagonists put them into their minds'
/// special_roles.
GLOBAL_LIST_INIT(rogue_secret_roles, list("Vampire", "Vampire Lord", "Bandit", "Lich", "Wretch", "Unbound Death Knight"))

/// The wanderers who may live in town (Ratwood sync_resident_wanderer_knowledge()): with TRAIT_RESIDENT they know the
/// Towners and each other.
GLOBAL_LIST_INIT(rogue_resident_wanderer_roles, list(JOB_ROCKHILL_ADVENTURER, JOB_ROCKHILL_MERCENARY, JOB_ROCKHILL_COURT_AGENT))

/// The titles of the named position lists (ROGUE_POSITIONS_*) as a set: title = TRUE.
/proc/rogue_position_titles(list/position_lists)
	. = list()
	for(var/positions in position_lists)
		for(var/title in GLOB.rogue_positions[positions])
			.[title] = TRUE

/// Ratwood get_minds(): the minds of the round whose role (the title) or special role is the one named; all of them when
/// none is named.
/proc/rogue_get_minds(role)
	. = list()
	for(var/datum/mind/mind in SSticker.minds)
		if(!role || mind.assigned_role?.title == role || LAZYFIND(mind.special_roles, role))
			. += mind

/datum/mind
	/// Ratwood known_people: real name = what this mind knows of the person, ROGUE_KNOWN_* = value (jobs/_defines.dm).
	var/list/rogue_known_people

/// Ratwood i_know_person(): the person (a mind or a mob) is added to the people this mind knows, or what it knows of them
/// is brought up to date.
/datum/mind/proc/rogue_i_know_person(person)
	if(!person || person == src || person == current)
		return
	if(istype(person, /datum/mind))
		var/datum/mind/person_mind = person
		person = person_mind.current
	var/mob/living/carbon/human/known = person
	if(istype(known))
		rogue_note_person(known, current)

/// Ratwood person_knows_me(): this mind's person is added to the people the other (a mind or a mob) knows; unlike looking
/// at them, it tells no mark of heresy.
/datum/mind/proc/rogue_person_knows_me(person)
	if(!person || person == src || person == current)
		return
	if(ismob(person))
		var/mob/person_mob = person
		person = person_mob.mind
	var/datum/mind/knower = person
	var/mob/living/carbon/human/me = current
	if(istype(knower) && knower != src && istype(me))
		knower.rogue_note_person(me)

/// Both know each other (Ratwood's i_know_person() and person_knows_me() in a row: bandits, vampires, death knights).
/datum/mind/proc/rogue_know_each_other(person)
	rogue_i_know_person(person)
	rogue_person_knows_me(person)

/// What this mind knows of a person, under the person's real name. The viewer, when it is the one who looks, also reads
/// the mark of a heresy it shares or sees.
/datum/mind/proc/rogue_note_person(mob/living/carbon/human/known, mob/living/carbon/human/viewer)
	if(!known.real_name)
		return
	var/list/entry = LAZYACCESS(rogue_known_people, known.real_name)
	if(!entry)
		entry = list()
		LAZYSET(rogue_known_people, known.real_name, entry)
	entry[ROGUE_KNOWN_COLOR] = colorize_string(known.real_name)
	entry[ROGUE_KNOWN_TITLE] = known.rogue_get_role_title() || "unknown"
	switch(known.gender)
		if(MALE)
			entry[ROGUE_KNOWN_GENDER] = "Male"
		if(FEMALE)
			entry[ROGUE_KNOWN_GENDER] = "Female"
		else
			entry[ROGUE_KNOWN_GENDER] = "Androgynous"
	if(known.dna?.species)
		entry[ROGUE_KNOWN_RACE] = known.dna.species.name
	entry[ROGUE_KNOWN_AGE] = known.rogue_age_band()
	var/house = known.rogue_house_name()
	if(house)
		entry[ROGUE_KNOWN_HOUSE] = house
	if(istype(viewer))
		var/heresy = known.rogue_get_heretic_symbol(viewer)
		if(heresy)
			entry[ROGUE_KNOWN_HERESY] = heresy

/// Ratwood do_i_know(): whether this mind knows the person of the mind, or the one of the name.
/datum/mind/proc/rogue_do_i_know(datum/mind/person, name)
	if(person)
		var/mob/living/carbon/human/known = person.current
		if(!istype(known))
			return FALSE
		if(LAZYACCESS(rogue_known_people, known.real_name))
			return TRUE
	return !!(name && LAZYACCESS(rogue_known_people, name))

/// Ratwood become_unknown_to(): the other mind forgets this mind's person.
/datum/mind/proc/rogue_become_unknown_to(datum/mind/person)
	var/mob/living/carbon/human/me = current
	if(!istype(person) || person == src || !istype(me))
		return
	LAZYREMOVE(person.rogue_known_people, me.real_name)

/// Ratwood unknow_all_people(): this mind forgets everyone.
/datum/mind/proc/rogue_unknow_all_people()
	rogue_known_people = null

/// Ratwood admin_send_back_to_lobby(): one who leaves the round forgets everyone, and everyone forgets them.
/datum/mind/proc/rogue_leave_acquaintances()
	rogue_unknow_all_people()
	for(var/datum/mind/other as anything in rogue_get_minds())
		rogue_become_unknown_to(other)

/// The real names of the people this mind knows, in order: what the bishop's verbs, the bounty board and the like offer.
/datum/mind/proc/rogue_known_names()
	return sort_list(assoc_to_keys(rogue_known_people))

/// Ratwood display_known_people(): the window of the people this mind knows, with what it knows of each.
/datum/mind/proc/rogue_display_known_people(mob/user)
	if(!user || !length(rogue_known_people))
		return
	var/list/contents = list("<center>People that [html_encode(name)] knows:</center><br>")
	for(var/person in rogue_known_names())
		var/list/entry = rogue_known_people[person]
		var/color = entry[ROGUE_KNOWN_COLOR]
		var/title = entry[ROGUE_KNOWN_TITLE]
		if(!color || !title)
			continue
		var/heresy = entry[ROGUE_KNOWN_HERESY]
		if(heresy)
			contents += "<b><font color='#f1d669'>[heresy]</font></b> "
		var/house = entry[ROGUE_KNOWN_HOUSE]
		contents += "<b><font color='[color]'>[html_encode(person)]</font></b><br>[title], [entry[ROGUE_KNOWN_RACE]], [entry[ROGUE_KNOWN_GENDER]], [entry[ROGUE_KNOWN_AGE]][house ? "<br><b>House [html_encode(house)]</b>" : ""]<br>"
	var/datum/browser/popup = new(user, "rogue_known_people", "", 260, 400)
	popup.set_content(jointext(contents, ""))
	popup.open()

/// Whether the mind holds one of Ratwood's secret roles (GLOB.rogue_secret_roles).
/datum/mind/proc/rogue_holds_secret_role()
	for(var/role in special_roles)
		if(role in GLOB.rogue_secret_roles)
			return TRUE
	return FALSE

/datum/job/roguetown
	/// Ratwood peopleiknow: the titles of the roles whose holders the holder of this one knows on arrival (title = TRUE).
	var/list/rogue_people_i_know
	/// Ratwood peopleknowme: the titles of the roles whose holders know the holder of this one on arrival (title = TRUE).
	var/list/rogue_people_know_me

/// Ratwood roguetown.dm New(): a role that keeps an account knows the town and is known to it.
/datum/job/roguetown/New()
	. = ..()
	if(isnull(rogue_bank_account))
		return
	rogue_people_i_know = rogue_position_titles(GLOB.rogue_positions)
	rogue_people_know_me = rogue_people_i_know.Copy()

/// Ratwood dungeoneer.dm New(): only the garrison, the nobility and the court know the dungeoneer.
/datum/job/roguetown/dungeoneer/New()
	. = ..()
	rogue_people_know_me = rogue_position_titles(list(ROGUE_POSITIONS_GARRISON, ROGUE_POSITIONS_NOBLE, ROGUE_POSITIONS_COURTIER))

/// Ratwood _job.dm after_spawn(): the newcomer gets to know the town, and the town the newcomer.
/datum/job/roguetown/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(ishuman(spawned) && !QDELETED(spawned))
		rogue_introduce(spawned)

/// Ratwood after_spawn() peopleknowme, peopleiknow: the holders of the roles of rogue_people_know_me come to know the
/// newcomer, and the newcomer those of rogue_people_i_know; someone without a special role skips the holders of secret
/// roles. Also how a circle of another role is joined later (Ratwood's Resident virtue joins the Towner's).
/datum/job/roguetown/proc/rogue_introduce(mob/living/carbon/human/newcomer)
	var/datum/mind/newcomer_mind = newcomer?.mind
	if(!newcomer_mind || (!length(rogue_people_i_know) && !length(rogue_people_know_me)))
		return
	var/skips_secrets = !length(newcomer_mind.special_roles)
	for(var/datum/mind/other in SSticker.minds)
		var/title = other.assigned_role?.title
		if(other == newcomer_mind || !title || (skips_secrets && other.rogue_holds_secret_role()))
			continue
		if(LAZYACCESS(rogue_people_know_me, title))
			newcomer_mind.rogue_person_knows_me(other)
		if(LAZYACCESS(rogue_people_i_know, title))
			newcomer_mind.rogue_i_know_person(other)

/// Ratwood knight.dm, captain.dm, heartfeltknight.dm after_spawn(): a newcomer who takes a new name ("Ser ...") is known
/// by it instead of the old one to those this role makes know them.
/datum/job/roguetown/proc/rogue_reintroduce(mob/living/carbon/human/renamed, old_name)
	var/datum/mind/renamed_mind = renamed?.mind
	if(!renamed_mind || !length(rogue_people_know_me))
		return
	for(var/datum/mind/other in SSticker.minds)
		var/title = other.assigned_role?.title
		if(other == renamed_mind || !title || !LAZYACCESS(rogue_people_know_me, title))
			continue
		LAZYREMOVE(other.rogue_known_people, old_name)
		renamed_mind.rogue_person_knows_me(other)

/// Ratwood villager.dm after_spawn(): a Towner knows the wanderers who live in town.
/datum/job/roguetown/villager/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(ishuman(spawned) && !QDELETED(spawned))
		rogue_sync_resident_wanderer_knowledge(spawned)

/// Ratwood sync_resident_wanderer_knowledge(): a wanderer who lives in town (TRAIT_RESIDENT) and the Towners know each
/// other, and so do such wanderers; a Towner knows them all.
/proc/rogue_sync_resident_wanderer_knowledge(mob/living/carbon/human/human)
	var/datum/mind/human_mind = human?.mind
	if(!human_mind)
		return
	var/role = human_mind.assigned_role?.title || human.job
	var/resident_wanderer = (role in GLOB.rogue_resident_wanderer_roles) && HAS_TRAIT(human, TRAIT_RESIDENT)
	if(!resident_wanderer && role != JOB_ROCKHILL_TOWNER)
		return
	for(var/mob/living/carbon/human/other as anything in GLOB.human_list)
		if(other == human || !other.mind)
			continue
		var/other_role = other.mind.assigned_role?.title || other.job
		var/other_resident = (other_role in GLOB.rogue_resident_wanderer_roles) && HAS_TRAIT(other, TRAIT_RESIDENT)
		if(other_resident || (resident_wanderer && other_role == JOB_ROCKHILL_TOWNER))
			human_mind.rogue_know_each_other(other.mind)

/// Ratwood's age of a person, by the years attributes/mob.dm counts.
/mob/living/carbon/human/proc/rogue_age_band()
	if(dna?.species?.rogue_ageless)
		return ROGUE_AGE_BAND_IMMORTAL
	if(age >= ROGUE_AGE_OLD)
		return ROGUE_AGE_BAND_OLD
	if(age >= ROGUE_AGE_MIDDLE)
		return ROGUE_AGE_BAND_MIDDLE
	return ROGUE_AGE_BAND_ADULT

/// Ratwood family_datum.housename: the house the person belongs to. None until the family tree of a later block names it;
/// it shows in the list of the people one knows, and examine marks one of a house with the house's mark.
/mob/living/carbon/human/proc/rogue_house_name()
	return null

/// Ratwood get_heretic_symbol(): the mark of an inhumen faith the examiner shares with the person, or sees as a heretic
/// seer; none behind Deceiving Meekness.
/mob/living/carbon/human/proc/rogue_get_heretic_symbol(mob/examiner)
	if(HAS_TRAIT(src, TRAIT_DECEIVING_MEEKNESS))
		return null
	var/seer = HAS_TRAIT(examiner, TRAIT_HERETIC_SEER)
	if(HAS_TRAIT(src, TRAIT_COMMIE) && (seer || HAS_TRAIT(examiner, TRAIT_COMMIE)))
		return "&spades;"
	if(HAS_TRAIT(src, TRAIT_CABAL) && (seer || HAS_TRAIT(examiner, TRAIT_CABAL)))
		return "&diams;"
	if(HAS_TRAIT(src, TRAIT_HORDE) && (seer || HAS_TRAIT(examiner, TRAIT_HORDE)))
		return "&spades;"
	if(HAS_TRAIT(src, TRAIT_DEPRAVED) && (seer || HAS_TRAIT(examiner, TRAIT_DEPRAVED)))
		return "&hearts;"
	return null
