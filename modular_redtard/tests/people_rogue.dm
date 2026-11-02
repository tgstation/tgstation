#ifdef UNIT_TESTS
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]", __FILE__, __LINE__) }
#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]", __FILE__, __LINE__); \
	} \
} while (FALSE)

/// Ratwood's known people and the examine of rank (jobs/known_people.dm, jobs/examine.dm). The test map is not a medieval
/// one, so the procs behind the examine are called directly, and arrivals are introduced as their roles' after_spawn()
/// introduces them.
/datum/unit_test/rogue_people
	abstract_type = /datum/unit_test/rogue_people

/// A person with a mind and a name of their own, holding the medieval role given.
/datum/unit_test/rogue_people/proc/make_person(person_name, job_type)
	var/mob/living/carbon/human/consistent/person = allocate(__IMPLIED_TYPE__)
	person.fully_replace_character_name(person.real_name, person_name)
	person.mind_initialize()
	if(job_type)
		var/datum/job/job = SSjob.get_job_type(job_type)
		person.mind.set_assigned_role(job)
		person.job = job.title
	return person

/// A mind learns a person it meets, with their role, race and age; the other learns it only the other way; forgetting.
/datum/unit_test/rogue_people/knowing

/datum/unit_test/rogue_people/knowing/Run()
	var/mob/living/carbon/human/alice = make_person("Alice Knowingwood", /datum/job/roguetown/knight)
	var/mob/living/carbon/human/bob = make_person("Bob Knowingwood")
	TEST_ASSERT(!alice.mind.rogue_do_i_know(bob.mind), "Alice knows Bob before meeting him")
	alice.mind.rogue_i_know_person(bob)
	TEST_ASSERT(alice.mind.rogue_do_i_know(bob.mind), "Alice does not know Bob, whom she met")
	TEST_ASSERT(alice.mind.rogue_do_i_know(name = "Bob Knowingwood"), "Alice does not know Bob by his name")
	TEST_ASSERT(!bob.mind.rogue_do_i_know(alice.mind), "Alice meeting Bob made Bob know her")
	var/list/entry = alice.mind.rogue_known_people["Bob Knowingwood"]
	TEST_ASSERT_EQUAL(entry[ROGUE_KNOWN_TITLE], "unknown", "Bob holds no role")
	TEST_ASSERT_EQUAL(entry[ROGUE_KNOWN_RACE], bob.dna.species.name, "Alice knows Bob's race wrong")
	TEST_ASSERT_EQUAL(entry[ROGUE_KNOWN_AGE], bob.rogue_age_band(), "Alice knows Bob's age wrong")
	TEST_ASSERT(entry[ROGUE_KNOWN_COLOR], "Alice does not know the colour of Bob's voice")
	alice.mind.rogue_person_knows_me(bob)
	var/list/known_alice = LAZYACCESS(bob.mind.rogue_known_people, "Alice Knowingwood")
	TEST_ASSERT(known_alice, "Bob does not know Alice after she made herself known")
	TEST_ASSERT_EQUAL(known_alice[ROGUE_KNOWN_TITLE], JOB_ROCKHILL_KNIGHT, "Bob does not know Alice as the knight")
	alice.mind.rogue_i_know_person(alice)
	TEST_ASSERT(!alice.mind.rogue_do_i_know(alice.mind), "Alice knows herself")
	var/list/names = alice.mind.rogue_known_names()
	TEST_ASSERT_EQUAL(length(names), 1, "Alice knows someone besides Bob")
	TEST_ASSERT_EQUAL(names[1], "Bob Knowingwood", "Alice does not list Bob")
	alice.mind.rogue_become_unknown_to(bob.mind)
	TEST_ASSERT(!bob.mind.rogue_do_i_know(alice.mind), "Bob still knows Alice, who became unknown to him")
	alice.mind.rogue_unknow_all_people()
	TEST_ASSERT(!alice.mind.rogue_do_i_know(name = "Bob Knowingwood"), "Alice still knows Bob after forgetting everyone")

/// Ratwood's arrivals: a role that keeps an account knows the town and the town knows it, the dungeoneer is known only to
/// the garrison, the nobility and the court; wanderers, the holders of secret roles and a vagabond, who keeps no account,
/// stay strangers.
/datum/unit_test/rogue_people/arrival

/datum/unit_test/rogue_people/arrival/Run()
	var/mob/living/carbon/human/knight = make_person("Knight Arrivalwood", /datum/job/roguetown/knight)
	var/mob/living/carbon/human/farmer = make_person("Soilson Arrivalwood", /datum/job/roguetown/farmer)
	var/mob/living/carbon/human/vagabond = make_person("Vagabond Arrivalwood", /datum/job/roguetown/orphan)
	var/mob/living/carbon/human/adventurer = make_person("Adventurer Arrivalwood", /datum/job/roguetown/adventurer)
	var/mob/living/carbon/human/bandit = make_person("Bandit Arrivalwood", /datum/job/roguetown/farmer)
	LAZYADD(bandit.mind.special_roles, "Bandit")
	var/mob/living/carbon/human/dungeoneer = make_person("Dungeoneer Arrivalwood", /datum/job/roguetown/dungeoneer)
	var/datum/job/roguetown/dungeoneer_job = SSjob.get_job_type(/datum/job/roguetown/dungeoneer)
	dungeoneer_job.rogue_introduce(dungeoneer)
	TEST_ASSERT(dungeoneer.mind.rogue_do_i_know(farmer.mind), "The dungeoneer does not know the soilson")
	TEST_ASSERT(!farmer.mind.rogue_do_i_know(dungeoneer.mind), "The soilson knows the dungeoneer, whom only the garrison, the nobility and the court know")
	TEST_ASSERT(knight.mind.rogue_do_i_know(dungeoneer.mind), "The knight does not know the dungeoneer")
	var/datum/job/roguetown/knight_job = SSjob.get_job_type(/datum/job/roguetown/knight)
	knight_job.rogue_introduce(knight)
	TEST_ASSERT(knight.mind.rogue_do_i_know(farmer.mind) && farmer.mind.rogue_do_i_know(knight.mind), "The knight and the soilson do not know each other")
	TEST_ASSERT(knight.mind.rogue_do_i_know(vagabond.mind) && vagabond.mind.rogue_do_i_know(knight.mind), "The knight and the vagabond do not know each other")
	TEST_ASSERT(!knight.mind.rogue_do_i_know(adventurer.mind) && !adventurer.mind.rogue_do_i_know(knight.mind), "The knight and the adventurer, a wanderer, know each other")
	TEST_ASSERT(!knight.mind.rogue_do_i_know(bandit.mind) && !bandit.mind.rogue_do_i_know(knight.mind), "The knight and a bandit know each other")
	var/mob/living/carbon/human/latecomer = make_person("Latecomer Arrivalwood", /datum/job/roguetown/orphan)
	var/datum/job/roguetown/orphan_job = SSjob.get_job_type(/datum/job/roguetown/orphan)
	orphan_job.rogue_introduce(latecomer)
	TEST_ASSERT(!length(latecomer.mind.rogue_known_people) && !knight.mind.rogue_do_i_know(latecomer.mind), "A vagabond arriving late knows the town, or the town knows them")

/// A renamed newcomer ("Ser ...") is known by the new name instead of the old one.
/datum/unit_test/rogue_people/rename

/datum/unit_test/rogue_people/rename/Run()
	var/mob/living/carbon/human/knight = make_person("Knight Renamewood", /datum/job/roguetown/knight)
	var/mob/living/carbon/human/guard = make_person("Guard Renamewood", /datum/job/roguetown/guardsman)
	var/datum/job/roguetown/knight_job = SSjob.get_job_type(/datum/job/roguetown/knight)
	knight_job.rogue_introduce(knight)
	knight.fully_replace_character_name("Knight Renamewood", "Ser Knight Renamewood")
	knight_job.rogue_reintroduce(knight, "Knight Renamewood")
	TEST_ASSERT(guard.mind.rogue_do_i_know(name = "Ser Knight Renamewood"), "The guard does not know the knight by the new name")
	TEST_ASSERT(!guard.mind.rogue_do_i_know(name = "Knight Renamewood"), "The guard still knows the knight by the old name")

/// A Towner and the wanderers who live in town know each other; a wanderer passing through stays a stranger.
/datum/unit_test/rogue_people/residents

/datum/unit_test/rogue_people/residents/Run()
	var/mob/living/carbon/human/towner = make_person("Towner Residentwood", /datum/job/roguetown/villager)
	var/mob/living/carbon/human/resident = make_person("Resident Residentwood", /datum/job/roguetown/adventurer)
	var/mob/living/carbon/human/passer = make_person("Passer Residentwood", /datum/job/roguetown/adventurer)
	ADD_TRAIT(resident, TRAIT_RESIDENT, TRAIT_SOURCE_UNIT_TESTS)
	rogue_sync_resident_wanderer_knowledge(towner)
	TEST_ASSERT(towner.mind.rogue_do_i_know(resident.mind) && resident.mind.rogue_do_i_know(towner.mind), "A Towner and a resident adventurer do not know each other")
	TEST_ASSERT(!towner.mind.rogue_do_i_know(passer.mind), "A Towner knows an adventurer who does not live in town")

/// Every title of Ratwood's position lists names a role of Rockhill; a role that keeps an account knows the town, one that
/// keeps none does not; the dungeoneer is known to the nobility and not to the peasants.
/datum/unit_test/rogue_people/positions

/datum/unit_test/rogue_people/positions/Run()
	for(var/positions in GLOB.rogue_positions)
		for(var/title in GLOB.rogue_positions[positions])
			var/datum/job/job = SSjob.get_job(title)
			if(!istype(job, /datum/job/roguetown) || job.title != title)
				TEST_FAIL("[title] of Ratwood's [positions] positions is no role of Rockhill")
	var/datum/job/roguetown/knight_job = SSjob.get_job_type(/datum/job/roguetown/knight)
	TEST_ASSERT(LAZYACCESS(knight_job.rogue_people_i_know, JOB_ROCKHILL_SOILSON) && LAZYACCESS(knight_job.rogue_people_know_me, JOB_ROCKHILL_SOILSON), "The knight, who keeps an account, does not know the town")
	var/datum/job/roguetown/adventurer_job = SSjob.get_job_type(/datum/job/roguetown/adventurer)
	TEST_ASSERT(!length(adventurer_job.rogue_people_i_know) && !length(adventurer_job.rogue_people_know_me), "The adventurer, who keeps no account, knows the town")
	var/datum/job/roguetown/dungeoneer_job = SSjob.get_job_type(/datum/job/roguetown/dungeoneer)
	TEST_ASSERT(LAZYACCESS(dungeoneer_job.rogue_people_know_me, JOB_ROCKHILL_KNIGHT), "The nobility does not know the dungeoneer")
	TEST_ASSERT(!LAZYACCESS(dungeoneer_job.rogue_people_know_me, JOB_ROCKHILL_SOILSON), "The peasants know the dungeoneer")

/// The examine of rank: "This is X, the [race] [role]" with the mark that outlanders do not read, the wanderer, the lowlife
/// and the one without a role, noble blood, a granted title and a hidden face.
/datum/unit_test/rogue_people/examine

/datum/unit_test/rogue_people/examine/Run()
	var/mob/living/carbon/human/noble = make_person("Noble Examinewood", /datum/job/roguetown/knight)
	var/mob/living/carbon/human/viewer = make_person("Viewer Examinewood", /datum/job/roguetown/farmer)
	noble.rogue_social_rank = ROGUE_SOCIAL_RANK_NOBLE
	ADD_TRAIT(noble, TRAIT_NOBLE, TRAIT_SOURCE_UNIT_TESTS)
	var/title = noble.rogue_examine_title(viewer)
	TEST_ASSERT(findtext(title, "This is <em>Noble Examinewood</em>, the "), "The examine does not open with the name: [title]")
	TEST_ASSERT(findtext(title, " [JOB_ROCKHILL_KNIGHT] <a href="), "The examine does not name the role and then the mark of rank: [title]")
	TEST_ASSERT(findtext(title, "rogue_social_strata"), "The examine has no mark of rank: [title]")
	ADD_TRAIT(viewer, TRAIT_OUTLANDER, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(!findtext(noble.rogue_examine_title(viewer), "rogue_social_strata"), "An outlander reads the mark of rank")
	REMOVE_TRAIT(viewer, TRAIT_OUTLANDER, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT(span_notice("A noble!") in noble.rogue_examine_standing(viewer), "A commoner does not see the noble")
	ADD_TRAIT(viewer, TRAIT_NOBLE, TRAIT_SOURCE_UNIT_TESTS)
	viewer.rogue_social_rank = ROGUE_SOCIAL_RANK_NOBLE
	TEST_ASSERT(span_notice("A fellow noble.") in noble.rogue_examine_standing(viewer), "A noble does not see a fellow noble")
	noble.rogue_social_rank = ROGUE_SOCIAL_RANK_PEASANT
	TEST_ASSERT_EQUAL(noble.rogue_get_social_rank(), ROGUE_SOCIAL_RANK_MINOR_NOBLE, "Noble blood does not make a peasant a minor noble")
	TEST_ASSERT(span_notice("A minor noble.") in noble.rogue_examine_standing(viewer), "The minor noble is not told")
	GLOB.rogue_lord_titles[noble.real_name] = "Warden of the Vale"
	var/list/standing = noble.rogue_examine_standing(viewer)
	GLOB.rogue_lord_titles -= noble.real_name
	TEST_ASSERT(length(standing) && findtext(standing[1], "granted the title of \"Warden of the Vale\""), "The granted title is not told")
	var/mob/living/carbon/human/wanderer = make_person("Wanderer Examinewood", /datum/job/roguetown/adventurer)
	TEST_ASSERT(findtext(wanderer.rogue_examine_title(viewer), "</em>, the wandering "), "An adventurer is not a wanderer")
	var/mob/living/carbon/human/lowlife = make_person("Lowlife Examinewood", /datum/job/roguetown/orphan)
	TEST_ASSERT(findtext(lowlife.rogue_examine_title(viewer), "</em>, the lowlife "), "A vagabond is not a lowlife")
	var/mob/living/carbon/human/stranger = make_person("Stranger Examinewood")
	TEST_ASSERT(findtext(stranger.rogue_examine_title(viewer), "This is the <em>Stranger Examinewood</em>, the "), "Someone without a role is not named by the race alone")
	ADD_TRAIT(noble, TRAIT_UNKNOWN_APPEARANCE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_NULL(noble.rogue_examine_title(viewer), "A hidden face was named")

/// What a person is called by their place: the role, the subclass of a role known by it, the migrant role; and the rank of
/// noble blood.
/datum/unit_test/rogue_people/role_title

/datum/unit_test/rogue_people/role_title/Run()
	var/mob/living/carbon/human/towner = make_person("Towner Titlewood", /datum/job/roguetown/villager)
	TEST_ASSERT_EQUAL(towner.rogue_get_role_title(), JOB_ROCKHILL_TOWNER, "A Towner without a subclass is not called by the role")
	towner.rockhill_advclass = rockhill_advclass(/datum/rockhill_advclass/blacksmith)
	TEST_ASSERT_EQUAL(towner.rogue_get_role_title(), "Blacksmith", "A Towner is not known by the subclass")
	var/mob/living/carbon/human/arrival = make_person("Arrival Titlewood", /datum/job/roguetown/rockhill_migrant)
	arrival.rogue_migrant_role = GLOB.rogue_migrant_roles[/datum/rogue_migrant_role/adventurer]
	TEST_ASSERT_EQUAL(arrival.rogue_get_role_title(), "Adventurer", "An arrival is not called by the migrant role")
	TEST_ASSERT(findtext(arrival.rogue_examine_title(towner), "</em>, the wandering "), "An arrival is not a wanderer")
	var/mob/living/carbon/human/commoner = make_person("Commoner Titlewood")
	TEST_ASSERT_NULL(commoner.rogue_get_social_rank(), "Someone without a role has a rank")
	ADD_TRAIT(commoner, TRAIT_NOBLE, TRAIT_SOURCE_UNIT_TESTS)
	TEST_ASSERT_EQUAL(commoner.rogue_get_social_rank(), ROGUE_SOCIAL_RANK_MINOR_NOBLE, "Noble blood does not make a minor noble")
	commoner.rogue_social_rank = ROGUE_SOCIAL_RANK_ROYAL
	TEST_ASSERT_EQUAL(commoner.rogue_get_social_rank(), ROGUE_SOCIAL_RANK_ROYAL, "Noble blood lowered the royal")

/// The heart of the HUD opens the list of the people one knows on right click.
/datum/unit_test/rogue_people/heart

/datum/unit_test/rogue_people/heart/Run()
	var/mob/living/carbon/human/viewer = make_person("Viewer Heartwood", /datum/job/roguetown/knight)
	var/mob/living/carbon/human/known = make_person("Known Heartwood", /datum/job/roguetown/farmer)
	viewer.set_hud_used(new viewer.hud_type(viewer))
	SEND_SIGNAL(viewer, COMSIG_MOB_HUD_CREATED)
	var/atom/movable/screen/healths/rogue/heart = viewer.hud_used.screen_objects[HUD_MOB_HEALTH]
	TEST_ASSERT(istype(heart), "The HUD has no heart")
	viewer.mind.rogue_i_know_person(known)
	var/old_usr = usr
	usr = viewer
	heart.Click(null, null, "right=1;icon-x=16;icon-y=16")
	usr = old_usr
	TEST_ASSERT(viewer.mind.rogue_do_i_know(known.mind), "The list of known people forgot whom it lists")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
#endif
