//Defines for amount of material retrieved from sheets & other items
/// The amount of materials you get from a sheet of mineral like iron/diamond/glass etc. 100 Units.
#define SHEET_MATERIAL_AMOUNT 100
/// The amount of materials you get from half a sheet. Used in standard object quantities. 50 units.
#define HALF_SHEET_MATERIAL_AMOUNT (SHEET_MATERIAL_AMOUNT / 2)
/// The amount of materials used in the smallest of objects, like pens and screwdrivers. 10 units.
#define SMALL_MATERIAL_AMOUNT (HALF_SHEET_MATERIAL_AMOUNT / 5)
/// The amount of material that goes into a coin, which determines the value of the coin.
#define COIN_MATERIAL_AMOUNT (HALF_SHEET_MATERIAL_AMOUNT * 0.4)

//Cable related values
/// The maximum size of a stack object.
#define MAX_STACK_SIZE 50
/// Maximum amount of cable in a coil
#define MAXCOIL 30

// Flags for material loading
/// Used to make a material initialize at roundstart.
#define MATERIAL_INIT_MAPLOAD (1 << 0)
/// Used to make a material type able to be instantiated on demand after roundstart.
#define MATERIAL_INIT_BESPOKE (1 << 1)

// Flags for material behaviors
// Negative values can be used to instead act as a blacklist
/// This material can be stored in an ore silo
#define MATERIAL_SILO_STORED (1 << 0)
/// This material can be used in basic recipes, such as chairs/toilets/tiles
#define MATERIAL_BASIC_RECIPES (1 << 1)
/// This material counts as a rigid enough solid to be used to craft tough objects like carving blocks or air tanks
#define MATERIAL_CLASS_RIGID (1 << 2)
/// The opposite of rigid, this means that the material cannot hold a solid form (like sand) and cannot be used in item crafting
#define MATERIAL_CLASS_AMORPHOUS (1 << 3)
/// This material is a metal and can be used in construction as one
#define MATERIAL_CLASS_METAL (1 << 4)
/// This material is a fabric and can be used to make clothing
#define MATERIAL_CLASS_FABRIC (1 << 5)
/// This material is a crystal and can be used to make windows or shards
#define MATERIAL_CLASS_CRYSTAL (1 << 6)
/// This is an organic material, meaning its probably alive in some way. Or was alive at one point, rather.
#define MATERIAL_CLASS_ORGANIC (1 << 7)
/// This is a polymer of some sorts
#define MATERIAL_CLASS_POLYMER (1 << 8)

/// Wildcard flag for recipes and alike to allow any material to be used
#define MATERIAL_CLASS_ANY 0

/// All material class flags usable for generic crafting
#define ITEM_MATERIAL_CLASSES (MATERIAL_CLASS_METAL | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_POLYMER | MATERIAL_CLASS_RIGID)
/// All material type class flags
#define MATERIAL_TYPE_CLASSES (MATERIAL_CLASS_METAL | MATERIAL_CLASS_FABRIC | MATERIAL_CLASS_CRYSTAL | MATERIAL_CLASS_ORGANIC | MATERIAL_CLASS_POLYMER)

/// Assoc list of material flags used in designs to their display names
GLOBAL_LIST_INIT(material_flags_to_string, alist(
	MATERIAL_CLASS_RIGID = "rigid",
	MATERIAL_CLASS_AMORPHOUS = "amorphous",
	MATERIAL_CLASS_METAL = "metallic",
	MATERIAL_CLASS_FABRIC = "fabric",
	MATERIAL_CLASS_CRYSTAL = "crystalline",
	MATERIAL_CLASS_ORGANIC = "organic",
	MATERIAL_CLASS_POLYMER = "polymer",
))

// You can use a calculator at https://www.desmos.com/calculator/wbkx4ttj3j for easy property calculations

// Core material property IDs
#define MATERIAL_DENSITY "density"
#define MATERIAL_HARDNESS "hardness"
#define MATERIAL_FLEXIBILITY "flexibility"
#define MATERIAL_REFLECTIVITY "reflectivity"
#define MATERIAL_ELECTRICAL "electrical_conductivity"
#define MATERIAL_THERMAL "thermal_conductivity"
#define MATERIAL_CHEMICAL "chemical_resistance"

// Optional material property IDs
#define MATERIAL_FLAMMABILITY "flammability"
#define MATERIAL_RADIOACTIVITY "radioactivity"

// Derived material property IDs
#define MATERIAL_INTEGRITY "integrity"
#define MATERIAL_BEAUTY "beauty"

/// Maximum value for a core material property
#define MATERIAL_PROPERTY_MAX 10
/// Allows to easily add "deadzones" for properties, and only adjust stats if they go below/above said deadzones. Basically two starting points for modifiers.
#define MATERIAL_PROPERTY_DIVERGENCE(property, minimum, maximum) (min(0, property - minimum) + max(0, property - maximum))

/// Minimum theoretical item force multiplier from materials
#define MATERIAL_MIN_FORCE_MULTIPLIER 0.1
/// Maximum theoretical item force multiplier from materials
#define MATERIAL_MAX_FORCE_MULTIPLIER 2

/// Slowdown per density over 6 / below 3 per sheet of material
#define MATERIAL_DENSITY_SLOWDOWN 0.02

/// Multiplier for the amount of reagents added to the item upon accidental consumption
#define MATERIAL_REAGENT_CONSUMPTION_MULT 0.4
/// Amount of reagents per sheet of material. Not affected by density for simplicity and easier consistency upkeep
#define MATERIAL_REAGENTS_PER_SHEET 20

// Material Container Flags.
/// If the container shows the amount of contained materials on examine.
#define MATCONTAINER_EXAMINE (1 << 0)
/// If the container cannot have materials inserted through attackby().
#define MATCONTAINER_NO_INSERT (1 << 1)
/// If the user can insert mats into the container despite the intent.
#define MATCONTAINER_ANY_INTENT (1 << 2)
/// If the user won't receive a warning when attacking the container with an unallowed item.
#define MATCONTAINER_SILENT (1 << 3)
/// Alloys won't be disassembled in its components when inserted.
#define MATCONTAINER_ACCEPT_ALLOYS (1 << 4)
/// Prevents material items from displaying their descriptors in examine_more with sci glasses
#define MATERIAL_NO_DESCRIPTORS (1 << 5)

// Atom material behavior flags
/// Whether a material's mechanical effects should apply to the atom. This is necessary for other flags to work.
#define MATERIAL_EFFECTS (1 << 0)
/// Applies the material color to the atom's color. Deprecated, use MATERIAL_GREYSCALE instead
#define MATERIAL_COLOR (1 << 1)
/// Whether a prefix describing the material should be added to the name
#define MATERIAL_ADD_PREFIX (1 << 2)
/// Whether a material should affect the stats of the atom
#define MATERIAL_AFFECT_STATISTICS (1 << 3)
/// Applies the material greyscale color to the atom's greyscale color.
#define MATERIAL_GREYSCALE (1 << 4)
/// Materials like plasteel and alien alloy won't apply slowdowns.
#define MATERIAL_NO_SLOWDOWN (1 << 5)
/// This item is not affected by the standard food-related effects of materials like meat and pizza.
/// Necessary for the edible component counterparts, on_edible_applied() and on_edible_removed()
#define MATERIAL_NO_EDIBILITY (1 << 6)
/// Ignore custom material grind results
#define MATERIAL_NO_REAGENTS (1 << 7)

//Special return values of [/datum/material_container/insert_item]
/// No material was found inside them item
#define MATERIAL_INSERT_ITEM_NO_MATS -1
/// The container does not have the space for the item
#define MATERIAL_INSERT_ITEM_NO_SPACE -2
/// The item material type was not accepted or other reasons
#define MATERIAL_INSERT_ITEM_FAILURE 0

// Slowdown values.
/// The slowdown value of one [SHEET_MATERIAL_AMOUNT] of plasteel.
#define MATERIAL_SLOWDOWN_PLASTEEL (0.05)
/// The slowdown value of one [SHEET_MATERIAL_AMOUNT] of alien alloy.
#define MATERIAL_SLOWDOWN_ALIEN_ALLOY (0.1)

// Stock market stock values.
/// How much quantity of a material stock exists for common materials like iron & glass.
#define MATERIAL_QUANTITY_COMMON 5000
/// How much quantity of a material stock exists for uncommon materials like silver & titanium.
#define MATERIAL_QUANTITY_UNCOMMON 1000
/// How much quantity of a material stock exists for rare materials like gold, uranium, & diamond.
#define MATERIAL_QUANTITY_RARE 200
/// How much quantity of a material stock exists for exotic materials like diamond & bluespace crystals.
#define MATERIAL_QUANTITY_EXOTIC 50

// The number of ore vents that will spawn boulders with this material.
/// Is this material going to spawn often in ore vents? (80% of vents on lavaland)
#define MATERIAL_RARITY_COMMON 12
/// Is this material going to spawn often in ore vents? (53% of vents on lavaland)
#define MATERIAL_RARITY_SEMIPRECIOUS 8
/// Is this material going to spawn uncommonly in ore vents? (33% of vents on lavaland)
#define MATERIAL_RARITY_PRECIOUS 5
/// Is this material going to spawn rarely in ore vents? (20% of vents on lavaland)
#define MATERIAL_RARITY_RARE 3
/// Is this material only going to spawn once in ore vents? (6% of vents on lavaland)
#define MATERIAL_RARITY_UNDISCOVERED 1

/// The key to access the 'optimal' amount of a material key from its assoc value list.
#define MATERIAL_LIST_OPTIMAL_AMOUNT "optimal_amount"
/// The key to access the multiplier used to selectively control effects and modifiers of a material.
#define MATERIAL_LIST_MULTIPLIER "multiplier"
/// A macro that ensures some multiplicative modifiers higher than 1 don't become lower than 1 and vice-versa because of the multiplier.
#define GET_MATERIAL_MODIFIER(modifier, multiplier) (modifier >= 1 ? 1 + ((modifier) - 1) * (multiplier) : (modifier)**(multiplier))
