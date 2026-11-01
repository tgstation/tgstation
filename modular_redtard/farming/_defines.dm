// Farming (farming/): Ratwood's soil, crops, saplings, composting and threshing. Cross-file defines of the farming module.

/// The most a soil holds of crop health, water, nutrition and weeds (Ratwood MAX_PLANT_HEALTH, MAX_PLANT_WATER,
/// MAX_PLANT_NUTRITION, MAX_PLANT_WEEDS). The shares and rates of config/redtard/mechanics/values/farming.txt are against these.
#define ROGUE_SOIL_MAX_HEALTH 100
#define ROGUE_SOIL_MAX_WATER 300
#define ROGUE_SOIL_MAX_NUTRITION 300
#define ROGUE_SOIL_MAX_WEEDS 100

/// The four looks of a crop on its soil (Ratwood "[icon_state]0" to "[icon_state]3"): growing, matured, ready for harvest, dead.
#define ROGUE_CROP_GROWING 1
#define ROGUE_CROP_MATURE 2
#define ROGUE_CROP_READY 3
#define ROGUE_CROP_DEAD 4

/// Stages of a tree sapling (Ratwood TREESAP_STAGE_*): the sapling and the shrub drink from their soil, the young tree stands alone.
#define ROGUE_TREESAP_SAPLING 1
#define ROGUE_TREESAP_SHRUB 2
#define ROGUE_TREESAP_YOUNG 3

/// Stages of a bush sapling (Ratwood BUSHSAP_STAGE_*): the sapling and the sprout drink from their soil, the bush bears fruit.
#define ROGUE_BUSHSAP_SAPLING 1
#define ROGUE_BUSHSAP_BUDDING 2
#define ROGUE_BUSHSAP_MATURE 3

/// The farming skill (Ratwood /datum/skill/labor/farming).
#define ROGUE_FARMING_SKILL /datum/attribute/skill/labor/farming

/// Ratwood's crop sheet (icons/roguetown/misc/crops.dmi): every crop's four looks, a few saplings' too.
#define ROGUE_CROPS_ICON 'modular_redtard/rockhill/icons/roguetown/misc/crops.dmi'

/// Ratwood's sounds of farm work: the "plantcross" rustle of something growing walked through or cut, a shovel or a hoe in the dirt,
/// seeds sown or a crop picked, seeds knocked out of produce.
#define ROGUE_PLANTCROSS_SOUNDS list('modular_redtard/rockhill/sound/foley/plantcross1.ogg', 'modular_redtard/rockhill/sound/foley/plantcross2.ogg', 'modular_redtard/rockhill/sound/foley/plantcross3.ogg', 'modular_redtard/rockhill/sound/foley/plantcross4.ogg')
#define ROGUE_DIG_SOUND 'modular_redtard/husbandry/sound/dig_shovel.ogg'
#define ROGUE_SEED_SOUND 'modular_redtard/farming/sound/seed.ogg'
#define ROGUE_SEED_EXTRACT_SOUND 'modular_redtard/farming/sound/seedextract.ogg'
