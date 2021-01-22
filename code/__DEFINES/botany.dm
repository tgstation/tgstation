/// Botany plant stat defines.
#define MAX_PLANT_YIELD 10
#define MAX_PLANT_LIFESPAN 100
#define MAX_PLANT_ENDURANCE 100
#define MAX_PLANT_PRODUCTION 10
#define MAX_PLANT_POTENCY 100
#define MAX_PLANT_INSTABILITY 100
#define MAX_PLANT_WEEDRATE 10
#define MAX_PLANT_WEEDCHANCE 67

/// Some botany trait value defines.
#define WEED_HARDY_YIELD_MIN 3
#define CARNIVORY_POTENCY_MIN 30
#define FUNGAL_METAB_YIELD_MIN 1

/// Hydroponics tray defines.
#define TRAY_NAME_UPDATE name = myseed ? "[initial(name)] ([myseed.plantname])" : initial(name)
#define STATIC_NUTRIENT_CAPACITY 10
#define MAX_TRAY_TOXINS 100
#define MAX_TRAY_PESTS 10
#define MAX_TRAY_WEEDS 10
#define GENE_SHEAR_MIN_HEALTH 15

/// Plant analyzer scanning modes.
#define PLANT_SCANMODE_STATS		0
#define PLANT_SCANMODE_CHEMICALS 	1

/// Flags for seeds.
#define MUTATE_EARLY	(1<<0)

/// Flags for traits.
#define TRAIT_HALVES_YIELD (1<<0)
