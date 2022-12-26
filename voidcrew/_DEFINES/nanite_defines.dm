///Trait given by Nanites
#define TRAIT_NANITES "Nanites"

#define NANITE_SYNC_DELAY (30 SECONDS)
#define NANITE_PROGRAM_LIMIT 20

///The chance at a Nanite program randomly failing when it cannot sync
#define NANITE_FAILURE_CHANCE 8

#define NANITE_SHOCK_IMMUNE 1
#define NANITE_EMP_IMMUNE 2

#define NANITE_CLOUD_TOGGLE 1
#define NANITE_CLOUD_DISABLE 2
#define NANITE_CLOUD_ENABLE 3

///Nanite Protocol types
#define NANITE_PROTOCOL_REPLICATION "nanite_replication"
#define NANITE_PROTOCOL_STORAGE "nanite_storage"

///Nanite extra settings types: used to help uis know what type an extra setting is
#define NESTYPE_TEXT "text"
#define NESTYPE_NUMBER "number"
#define NESTYPE_TYPE "type"
#define NESTYPE_BOOLEAN "boolean"

///Nanite Extra Settings - Note that these will also be the names displayed in the UI
#define NES_SENT_CODE "Sent Code"
#define NES_DELAY "Delay"
#define NES_MODE "Mode"
#define NES_COMM_CODE "Comm Code"
#define NES_RELAY_CHANNEL "Relay Channel"
#define NES_HEALTH_PERCENT "Health Percent"
#define NES_DIRECTION "Direction"
#define NES_NANITE_PERCENT "Nanite Percent"
#define NES_DAMAGE_TYPE "Damage Type"
#define NES_DAMAGE "Damage"
#define NES_SENTENCE "Sentence"
#define NES_MESSAGE "Message"
#define NES_DIRECTIVE "Directive"
#define NES_INCLUSIVE_MODE "Inclusive Mode"
#define NES_RACE "Race"
#define NES_HALLUCINATION_TYPE "Hallucination Type"
#define NES_HALLUCINATION_DETAIL "Hallucination Detail"
#define NES_MOOD_MESSAGE "Mood Message"
#define NES_PROGRAM_OVERWRITE "Program Overwrite"
#define NES_CLOUD_OVERWRITE "Cloud Overwrite"
#define NES_SCAN_TYPE "Scan Type"
#define NES_BUTTON_NAME "Button Name"
#define NES_ICON "Icon"
#define NES_COLOR "Color"

///The nanite build_type.
#define NANITE_PROGRAM (1<<11)

#define RND_CATEGORY_NANITE_PROGRAMS "/Nanites"
#define RND_SUBCATEGORY_NANITE_UTILITY "/Utility Nanites"
#define RND_SUBCATEGORY_NANITE_MEDICAL "/Medical Nanites"
#define RND_SUBCATEGORY_NANITE_AUGMENTATION "/Augmentation Nanites"
#define RND_SUBCATEGORY_NANITE_DEFECTIVE "/Defective Nanites"
#define RND_SUBCATEGORY_NANITE_WEAPONIZED "/Weaponized Nanites"
#define RND_SUBCATEGORY_NANITE_SUPRESSION "/Suppression Nanites"
#define RND_SUBCATEGORY_NANITE_SENSOR "/Sensor Nanites"
#define RND_SUBCATEGORY_NANITE_PROTOCOL "/Protocol Nanites"
