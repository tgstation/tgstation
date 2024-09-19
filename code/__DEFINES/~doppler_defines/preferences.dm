#define MAX_FLAVOR_SHORT_DESC_LEN 250
#define MAX_FLAVOR_EXTENDED_DESC_LEN 4096

#define PREFERENCE_CATEGORY_DOPPLER_LORE "doppler_lore"

#define READ_PREFS(target, pref) (target.client?.prefs?.read_preference(/datum/preference/pref))
