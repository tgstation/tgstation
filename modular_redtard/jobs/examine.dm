/// Who a person is by the look of them (Ratwood human/examine.dm generate_main_examine_body(), human_topic.dm
/// social_strata and species_lore, mob_helpers.dm get_role_title()): on medieval maps the examine of a person whose face
/// shows opens with "This is X, the [race] [role]" - "the wandering [race]" for wanderers and the arrivals of migrant
/// waves, "the lowlife [race]" for the lowly - and the mark of their social rank, which outlanders do not read: a link
/// that tells how the person's standing compares with one's own. Under it come the title the ruler granted them and "A
/// noble!", "A fellow noble." or "A minor noble." for noble blood. Looking someone in the face makes them known
/// (jobs/known_people.dm). The holder of a role takes its social rank on arrival and the subclass's in its place once the
/// subclass is chosen. Modern maps keep TG's examine.
///
/// Places for the court of a later block: GLOB.rogue_lord_titles (the titles the ruler grants) and rogue_is_regent().

/// Ratwood GLOB.lord_titles: real name = the title the ruler granted; the court grants and strips them.
GLOBAL_LIST_EMPTY(rogue_lord_titles)

/// Who people are by the look of them, and whom one knows by face, on medieval maps.
/proc/rogue_people_enabled()
	return rogue_combat_enabled()

/mob/living/carbon/human
	/// Ratwood social_rank: the standing of the person (ROGUE_SOCIAL_RANK_*), the role's or its subclass's; null - none.
	var/rogue_social_rank
	/// Ratwood migrant_type: the role of the migrant wave the person arrived with; null - no arrival of a wave.
	var/datum/rogue_migrant_role/rogue_migrant_role

/datum/job/roguetown
	/// Ratwood f_title: the title of the role's holder who is a woman; null - the role's title (the porter writes it).
	var/rogue_f_title

/datum/rockhill_advclass
	/// Ratwood examine_name: what examine calls the holder of the subclass in place of its name (the porter writes it).
	var/rogue_examine_name

/// Ratwood's Migrant job (wanderer_examine, advjob_examine): the arrivals of the waves are wanderers known by their class.
/datum/job/roguetown/rockhill_migrant
	rogue_wanderer_examine = TRUE
	rogue_advjob_examine = TRUE

/// Ratwood _job.dm after_spawn() social_rank: the holder takes the role's rank before the role's subclass gives its own.
/datum/job/roguetown/after_spawn(mob/living/spawned, client/player_client)
	var/mob/living/carbon/human/human = spawned
	if(istype(human))
		human.rogue_social_rank = rogue_social_rank
	. = ..()

/// Ratwood advclass equipme() subclass_social_rank: a subclass that names a rank gives it in place of the role's.
/datum/rockhill_advclass/apply(mob/living/carbon/human/human)
	. = ..()
	if(!isnull(rogue_social_rank))
		human.rogue_social_rank = rogue_social_rank

/// Ratwood spawn_migrant(): the arrival remembers the role it came as (migrant_type).
/datum/controller/subsystem/rogue_migrants/spawn_migrant(datum/rogue_migrant_wave/wave, datum/rogue_migrant_assignment/assignment)
	. = ..()
	var/mob/living/carbon/human/arrival = assignment.client?.mob
	if(. && istype(arrival))
		arrival.rogue_migrant_role = GLOB.rogue_migrant_roles[assignment.role_type]

/// Ratwood SSticker.regentmob: whether the person rules as regent. Nobody does until the court of a later block.
/mob/living/carbon/human/proc/rogue_is_regent()
	return FALSE

/// Ratwood social_rank as examine reads it: noble blood makes anyone at least a minor noble.
/mob/living/carbon/human/proc/rogue_get_social_rank()
	if(HAS_TRAIT(src, TRAIT_NOBLE) && (isnull(rogue_social_rank) || rogue_social_rank < ROGUE_SOCIAL_RANK_MINOR_NOBLE))
		return ROGUE_SOCIAL_RANK_MINOR_NOBLE
	return rogue_social_rank

/// Ratwood get_role_title(): what the person is called by their place - the migrant role they arrived as, the title of
/// their role (a woman's, if the role has one), or the subclass for the roles known by it; "unknown" for a role that is no
/// more, null for none.
/mob/living/carbon/human/proc/rogue_get_role_title()
	if(rogue_migrant_role)
		if(rogue_migrant_role.rogue_advjob_examine && rockhill_advclass)
			return rockhill_advclass.rogue_examine_name || rockhill_advclass.name
		return rogue_migrant_role.name
	if(!job)
		return null
	var/datum/job/role = SSjob.get_job(job)
	if(!role)
		return "unknown"
	. = role.title
	var/datum/job/roguetown/rogue_role = role
	if(!istype(rogue_role))
		return
	if(rogue_role.rogue_f_title && gender == FEMALE)
		. = rogue_role.rogue_f_title
	if(rogue_role.rogue_advjob_examine && rockhill_advclass)
		. = rockhill_advclass.rogue_examine_name || rockhill_advclass.name

/// The examine title on medieval maps: who the person is by their place (rogue_examine_title()).
/mob/living/carbon/human/examine_title(mob/user, thats = FALSE)
	if(!thats || !rogue_people_enabled())
		return ..()
	return rogue_examine_title(user) || ..()

/// Ratwood generate_main_examine_body(): looking someone in the face makes them known, and the title the ruler granted
/// them and their noble blood are told under the examine title.
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	if(!rogue_people_enabled() || (!isobserver(user) && get_face_name("") != real_name))
		return
	var/mob/living/carbon/human/viewer = user
	if(istype(viewer) && viewer != src)
		viewer.mind?.rogue_i_know_person(src)
	var/list/standing = rogue_examine_standing(user)
	if(length(standing))
		var/list/examine_list = .
		. = standing + examine_list

/// Ratwood generate_main_examine_body(): "This is X, the [race] [role]" and the mark of rank; "This is an unknown X" for a
/// hidden face that something names; null for a hidden face that nothing names, which TG's title tells ("This is
/// Unknown"). TG ends the title with a full stop.
/mob/living/carbon/human/proc/rogue_examine_title(mob/user)
	var/static/list/unknown_names = list("Unknown", "Unknown Man", "Unknown Woman")
	var/observer = isobserver(user)
	var/shown_name = get_examine_name(user)
	if(!observer && get_face_name("") != real_name)
		return (shown_name in unknown_names) ? null : "This is an unknown <em>[shown_name]</em>"
	var/used_name = observer ? real_name : shown_name
	var/datum/species/species = dna?.species
	var/race_name = species?.name
	if(species?.check_roundstart_eligible())
		race_name = "<a href='byond://?src=[REF(src)];rogue_species_lore=1'><u>[race_name]</u></a>"
	var/used_title = rogue_get_role_title()
	if(used_title && rogue_is_regent())
		used_title = "[used_title] Regent"
	var/datum/job/role = job ? SSjob.get_job(job) : null
	var/datum/job/roguetown/rogue_role = role
	var/line
	if(rogue_migrant_role)
		line = "This is <em>[used_name]</em>, the wandering [race_name] [rogue_migrant_role.name]"
	else if(job && (!role || (istype(rogue_role) && rogue_role.rogue_wanderer_examine)))
		line = "This is <em>[used_name]</em>, the wandering [race_name]"
	else if(istype(rogue_role) && rogue_role.rogue_lowlife_examine)
		line = "This is <em>[used_name]</em>, the lowlife [race_name]"
	else if(used_title)
		line = "This is <em>[used_name]</em>, the [race_name] [used_title]"
	else
		line = "This is the <em>[used_name]</em>, the [race_name]"
	var/mark = rogue_social_strata_mark(user)
	return mark ? "[line] [mark]" : line

/// Ratwood's mark of social rank on examine, coloured by the rank (a house's mark for one of a house): a link that compares
/// standings. Outlanders do not read it, and a person without a rank has none.
/mob/living/carbon/human/proc/rogue_social_strata_mark(mob/user)
	var/rank = rogue_get_social_rank()
	if(!rank || HAS_TRAIT(user, TRAIT_OUTLANDER))
		return null
	var/color = "#725D4C"
	switch(rank)
		if(ROGUE_SOCIAL_RANK_PEASANT)
			color = "#91733B"
		if(ROGUE_SOCIAL_RANK_YEOMAN)
			color = "#B1892A"
		if(ROGUE_SOCIAL_RANK_MINOR_NOBLE)
			color = "#D09F19"
		if(ROGUE_SOCIAL_RANK_NOBLE)
			color = "#ECB20A"
		if(ROGUE_SOCIAL_RANK_ROYAL)
			color = "#FFBF00"
	return "<a href='byond://?src=[REF(src)];rogue_social_strata=1'><font color='[color]'>[rogue_house_name() ? "&#9967;" : "&#9884;"]</font></a>"

/// Ratwood generate_main_examine_body() under the opening: the title the ruler granted, and noble blood.
/mob/living/carbon/human/proc/rogue_examine_standing(mob/user)
	. = list()
	var/granted = real_name && GLOB.rogue_lord_titles[real_name]
	if(granted)
		. += span_notice("[user == src ? "I have" : "[p_They()] [p_have()]"] been granted the title of \"[granted]\".")
	if(!HAS_TRAIT(src, TRAIT_NOBLE) && !HAS_TRAIT(src, TRAIT_DEFILED_NOBLE))
		return
	if(rogue_get_social_rank() < ROGUE_SOCIAL_RANK_NOBLE)
		. += span_notice("A minor noble.")
		return
	var/mob/living/carbon/human/viewer = user
	if(istype(viewer) && (HAS_TRAIT(viewer, TRAIT_NOBLE) || HAS_TRAIT(viewer, TRAIT_DEFILED_NOBLE)) && viewer.rogue_get_social_rank() >= ROGUE_SOCIAL_RANK_NOBLE)
		. += span_notice("A fellow noble.")
	else
		. += span_notice("A noble!")

/// The links of the examine title: the mark of rank and the race.
/mob/living/carbon/human/Topic(href, href_list)
	if(href_list["rogue_social_strata"])
		rogue_tell_social_standing(usr)
		return
	if(href_list["rogue_species_lore"])
		rogue_show_species_lore(usr)
		return
	return ..()

/// Ratwood human_topic.dm social_strata: the person's standing against the viewer's own, and their house.
/mob/living/carbon/human/proc/rogue_tell_social_standing(mob/viewer)
	var/rank = rogue_get_social_rank()
	if(!ismob(viewer) || !rank || HAS_TRAIT(src, TRAIT_OUTLANDER))
		return
	var/datum/job/role = job ? SSjob.get_job(job) : null
	var/clergy = role && LAZYFIND(role.departments_list, /datum/job_department/rockhill_church)
	var/rank_name
	switch(rank)
		if(ROGUE_SOCIAL_RANK_DIRT)
			rank_name = "dirt"
		if(ROGUE_SOCIAL_RANK_PEASANT)
			rank_name = "a peasant"
		if(ROGUE_SOCIAL_RANK_YEOMAN)
			rank_name = "a yeoman"
		if(ROGUE_SOCIAL_RANK_MINOR_NOBLE)
			rank_name = clergy ? "low clergy" : "a minor noble"
		if(ROGUE_SOCIAL_RANK_NOBLE)
			rank_name = clergy ? "clergy" : "a noble"
		if(ROGUE_SOCIAL_RANK_ROYAL)
			rank_name = clergy ? "head of the clergy" : "royalty"
	if(HAS_TRAIT(src, TRAIT_DISGRACED_NOBLE))
		rank_name = "a disgraced noble"
		rank = ROGUE_SOCIAL_RANK_YEOMAN
	if(role?.title == JOB_ROCKHILL_JESTER)
		rank_name = "the jester"
	if(role?.title == JOB_ROCKHILL_DRUID)
		rank_name = "a druid"
	var/mob/living/carbon/human/human_viewer = viewer
	var/viewer_rank = istype(human_viewer) ? human_viewer.rogue_get_social_rank() : null
	var/standing = "my lesser"
	if(rank > viewer_rank)
		standing = "my better"
	else if(rank == viewer_rank)
		standing = "my equal"
	to_chat(viewer, span_notice("This person's social standing is equivalent to <em>[rank_name]</em>, they are [standing]."))
	var/house = rogue_house_name()
	if(house)
		to_chat(viewer, span_notice("They are a member of house [house]."))

/// Ratwood human_topic.dm species_lore: the lore of the person's race.
/mob/living/carbon/human/proc/rogue_show_species_lore(mob/viewer)
	var/datum/species/species = dna?.species
	if(!ismob(viewer) || !species?.check_roundstart_eligible())
		return
	var/list/lore = list(species.get_species_description())
	lore += species.get_species_lore()
	var/datum/browser/popup = new(viewer, "rogue_species_lore", "<center>Lore</center>", 460, 550)
	popup.set_content(jointext(lore, "<br><br>"))
	popup.open()
