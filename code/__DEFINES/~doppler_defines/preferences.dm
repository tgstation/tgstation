#define MAX_FLAVOR_SHORT_DESC_LEN 250
#define MAX_FLAVOR_EXTENDED_DESC_LEN 4096

#define PREFERENCE_CATEGORY_DOPPLER_LORE "doppler_lore"

#define PREVIEW_PREF_JOB "Job"
#define PREVIEW_PREF_LOADOUT "Loadout"
#define PREVIEW_PREF_UNDERWEAR "Underwear"
#define PREVIEW_PREF_NAKED "Naked"

#define READ_PREFS(target, pref) (target.client?.prefs?.read_preference(/datum/preference/pref))
