// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list
// note: if you add more HUDs, even for non-human atoms, make sure to use unique numbers for the defines!
// /datum/atom_hud expects these to be unique
// these need to be strings in order to make them associative lists

/// dead, alive, sick, health status
#define HEALTH_HUD "1"
/// a simple line rounding the mob's number health
#define STATUS_HUD "2"
/// the job asigned to your ID
#define ID_HUD "3"
/// wanted, released, parroled, security status
#define WANTED_HUD "4"
/// loyality implant
#define IMPLOYAL_HUD "5"
/// chemical implant
#define IMPSEC_FIRST_HUD "6"
/// tracking implant
#define IMPSEC_SECOND_HUD "7"
/// Silicon/Mech/Circuit Status
#define DIAG_STAT_HUD "8"
/// Silicon health bar
#define DIAG_HUD "9"
/// Borg/Mech/Circutry power meter
#define DIAG_BATT_HUD "10"
/// Mech health bar
#define DIAG_MECH_HUD "11"
/// Bot HUDs
#define DIAG_BOT_HUD "12"
/// Mech/Silicon tracking beacon, Circutry long range icon
#define DIAG_TRACK_HUD "13"
/// Airlock shock overlay
#define DIAG_AIRLOCK_HUD "14"
/// Bot path indicators
#define DIAG_PATH_HUD "15"
/// Gland indicators for abductors
#define GLAND_HUD "16"
#define AI_DETECT_HUD "17"
/// Displays launchpads' targeting reticle
#define DIAG_LAUNCHPAD_HUD "18"
//for antag huds. these are used at the /mob level
#define ANTAG_HUD "19"
// for fans to identify pins
#define FAN_HUD "20"
/// Mech camera HUD
#define DIAG_CAMERA_HUD "21"
/// Steady Hacked APC effect, visible only to Malf AIs
#define MALF_APC_HUD "22"
/// Big Manipulator interaction point HUDs
#define BIG_MANIP_HUD "23"

//by default everything in the hud_list of an atom is an image
//a value in hud_list with one of these will change that behavior
#define HUD_LIST_LIST 1

//data HUD (medhud, sechud) defines
//Don't forget to update human/New() if you change these!
#define DATA_HUD_SECURITY_BASIC 1
#define DATA_HUD_SECURITY_ADVANCED 2
#define DATA_HUD_MEDICAL_BASIC 3
#define DATA_HUD_MEDICAL_ADVANCED 4
#define DATA_HUD_DIAGNOSTIC 5
#define DATA_HUD_BOT_PATH 6
#define DATA_HUD_ABDUCTOR 7
#define DATA_HUD_AI_DETECT 8
#define DATA_HUD_FAN 9
#define DATA_HUD_MALF_APC 10

/// cooldown for being shown the images for any particular data hud
#define ADD_HUD_TO_COOLDOWN 20

// Security HUD icon_state defines

#define SECHUD_NO_ID "hudno_id"
#define SECHUD_UNKNOWN "hudunknown"
#define SECHUD_CENTCOM "hudcentcom"
#define SECHUD_SYNDICATE "hudsyndicate"
#define SECHUD_SYNDICATE_INTERDYNE "hudsyndicateinterdyne"
#define SECHUD_SYNDICATE_INTERDYNE_HEAD "hudsyndicateinterdynehead"

#define SECHUD_ASSISTANT "hudassistant"
#define SECHUD_ATMOSPHERIC_TECHNICIAN "hudatmospherictechnician"
#define SECHUD_BARTENDER "hudbartender"
#define SECHUD_BUSSER "hudbusser"
#define SECHUD_BITAVATAR "hudbitavatar"
#define SECHUD_BITRUNNER "hudbitrunner"
#define SECHUD_BOTANIST "hudbotanist"
#define SECHUD_BRIDGE_ASSISTANT "hudbridgeassistant"
#define SECHUD_CAPTAIN "hudcaptain"
#define SECHUD_CARGO_TECHNICIAN "hudcargotechnician"
#define SECHUD_CHAPLAIN "hudchaplain"
#define SECHUD_CHEMIST "hudchemist"
#define SECHUD_CHIEF_ENGINEER "hudchiefengineer"
#define SECHUD_CHIEF_MEDICAL_OFFICER "hudchiefmedicalofficer"
#define SECHUD_CLOWN "hudclown"
#define SECHUD_COOK "hudcook"
#define SECHUD_CORONER "hudcoroner"
#define SECHUD_CURATOR "hudcurator"
#define SECHUD_DETECTIVE "huddetective"
#define SECHUD_GENETICIST "hudgeneticist"
#define SECHUD_HEAD_OF_PERSONNEL "hudheadofpersonnel"
#define SECHUD_HEAD_OF_SECURITY "hudheadofsecurity"
#define SECHUD_HUMAN_AI "hudhumanai"
#define SECHUD_JANITOR "hudjanitor"
#define SECHUD_LAWYER "hudlawyer"
#define SECHUD_MEDICAL_DOCTOR "hudmedicaldoctor"
#define SECHUD_MIME "hudmime"
#define SECHUD_PARAMEDIC "hudparamedic"
#define SECHUD_PRISONER "hudprisoner"
#define SECHUD_PSYCHOLOGIST "hudpsychologist"
#define SECHUD_QUARTERMASTER "hudquartermaster"
#define SECHUD_RESEARCH_DIRECTOR "hudresearchdirector"
#define SECHUD_ROBOTICIST "hudroboticist"
#define SECHUD_SECURITY_OFFICER "hudsecurityofficer"
#define SECHUD_SCIENTIST "hudscientist"
#define SECHUD_SHAFT_MINER "hudshaftminer"
#define SECHUD_STATION_ENGINEER "hudstationengineer"
#define SECHUD_VETERAN_ADVISOR "hudveteranadvisor"
#define SECHUD_WARDEN "hudwarden"

#define SECHUD_CHEF "hudchef"

#define SECHUD_DEATH_COMMANDO "huddeathcommando"

#define SECHUD_EMERGENCY_RESPONSE_TEAM_COMMANDER "hudemergencyresponseteamcommander"
#define SECHUD_SECURITY_RESPONSE_OFFICER "hudsecurityresponseofficer"
#define SECHUD_ENGINEERING_RESPONSE_OFFICER "hudengineeringresponseofficer"
#define SECHUD_MEDICAL_RESPONSE_OFFICER "hudmedicalresponseofficer"
#define SECHUD_RELIGIOUS_RESPONSE_OFFICER "hudreligiousresponseofficer"
#define SECHUD_JANITORIAL_RESPONSE_OFFICER "hudjanitorialresponseofficer"
#define SECHUD_ENTERTAINMENT_RESPONSE_OFFICER "hudentertainmentresponseofficer"
