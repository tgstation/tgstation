//The file that the threat datum will read the probabilities
#define ANTAG_PROBABILITIES_FILE	"config/antag_probabilities.txt"

#define ANTAG_DATUM_PATH			/datum/antagonist/

#define ANTAG_SCORE_INITIAL 100

//Contains priority defines for antagonist datums. Higher numbers are more important than lower ones.

#define ANTAGONIST_PRIORITY_NONE 		0 //No special allegiances. Essentially a normal crewman.
#define ANTAGONIST_PRIORITY_SYNDICATE 	1 //You're a member of the Syndicate coalition or some other faction. This is entirely voluntary, so it doesn't have much loyalty attached.
#define ANTAGONIST_PRIORITY_SECEDER 	2 //You've defected from the crew and joined a faction vying for control. This involves minor brainwashing, so it can be problematic but not impossible.
#define ANTAGONIST_PRIORITY_CULTIST 	3 //You serve a powerful deity with intense zeal. This involves intense brainwashing or conditioning and is difficult to remove fully.
#define ANTAGONIST_PRIORITY_NONHUMAN 	4 //You aren't human, so you aren't susceptible to human conditioning. You're immune to most conversion methods.
#define ANTAGONIST_PRIORITY_IMMUNE 		INFINITY //You physically can't be converted by anything. This has no canonical explanation and exists for gameplay purposes.

/* DATUM DEFINES */
#define ANTAG_DATUM_TRAITOR 				/datum/antagonist/traitor

#define ANTAG_DATUM_CHANGELING				/datum/antagonist/changeling

#define ANTAG_DATUM_WIZARD					/datum/antagonist/wizard

#define ANTAG_DATUM_WIZARD_APPRENTICE		/datum/antagonist/wizard/apprentice
#define ANTAG_DATUM_WIZARD_APPRENTICE_NAME	"Wizard Apprentice"

#define ANTAG_DATUM_HEAD_REVOLUTIONARY		/datum/antagonist/team/revolution

#define ANTAG_DATUM_GANG					/datum/antagonist/team/gang
#define ANTAG_DATUM_CULT					/datum/antagonist/team/cult
#define ANTAG_DATUM_CLOCKCULT				/datum/antagonist/team/clockcult


/* TRAITOR DATUM DEFINES */
#define TRAITOR_HIJACK_CHANCE 10
#define TRAITOR_MARTYR_CHANCE 20

/* CHANGELING DEFINES */
#define LING_FAKEDEATH_TIME					400 //40 seconds
#define LING_DEAD_GENETICDAMAGE_HEAL_CAP	50	//The lowest value of geneticdamage handle_changeling() can take it to while dead.
#define LING_ABSORB_RECENT_SPEECH			8	//The amount of recent spoken lines to gain on absorbing a mob