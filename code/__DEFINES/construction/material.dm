//Defines for amount of material retrived from sheets & other items
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

//Category of materials
/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"
/// Hard materials, such as iron or silver
#define MAT_CATEGORY_RIGID "rigid material"
/// Materials that can be used to craft items
#define MAT_CATEGORY_ITEM_MATERIAL "item material"
/// Use this flag on TRUE if you want the basic recipes
#define MAT_CATEGORY_BASE_RECIPES "basic recipes"

///Flags for map loaded materials
/// Used to make a material initialize at roundstart.
#define MATERIAL_INIT_MAPLOAD (1<<0)
/// Used to make a material type able to be instantiated on demand after roundstart.
#define MATERIAL_INIT_BESPOKE (1<<1)

//Material Container Flags.
///If the container shows the amount of contained materials on examine.
#define MATCONTAINER_EXAMINE (1<<0)
///If the container cannot have materials inserted through attackby().
#define MATCONTAINER_NO_INSERT (1<<1)
///If the user can insert mats into the container despite the intent.
#define MATCONTAINER_ANY_INTENT (1<<2)
///If the user won't receive a warning when attacking the container with an unallowed item.
#define MATCONTAINER_SILENT (1<<3)

// The following flags are for decomposing alloys. Should be expanded upon and diversified once someone gets around to reworking recycling.
/// Can reduce an alloy into its component materials.
#define BREAKDOWN_ALLOYS (1<<4)
/// Makes the material composition include transmuted materials objects
#define BREAKDOWN_INCLUDE_ALCHEMY (1<<5)
/// Breakdown flags used by techfabs and circuit printers.
#define BREAKDOWN_FLAGS_LATHE (BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ORM.
#define BREAKDOWN_FLAGS_ORM (BREAKDOWN_ALLOYS)
/// Breakdown flags used by the recycler.
#define BREAKDOWN_FLAGS_RECYCLER (BREAKDOWN_ALLOYS)
/// Breakdown flags used by the sheetifier.
#define BREAKDOWN_FLAGS_SHEETIFIER (BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ore processor.
#define BREAKDOWN_FLAGS_ORE_PROCESSOR (BREAKDOWN_ALLOYS)
/// Breakdown flags used by the drone dispenser.
#define BREAKDOWN_FLAGS_DRONE_DISPENSER (BREAKDOWN_ALLOYS)
/// Breakdown flags used when exporting materials.
#define BREAKDOWN_FLAGS_EXPORT (NONE)

/// Whether a material's mechanical effects should apply to the atom. This is necessary for other flags to work.
#define MATERIAL_EFFECTS (1<<0)
/// Applies the material color to the atom's color. Deprecated, use MATERIAL_GREYSCALE instead
#define MATERIAL_COLOR (1<<1)
/// Whether a prefix describing the material should be added to the name
#define MATERIAL_ADD_PREFIX (1<<2)
/// Whether a material should affect the stats of the atom
#define MATERIAL_AFFECT_STATISTICS (1<<3)
/// Applies the material greyscale color to the atom's greyscale color.
#define MATERIAL_GREYSCALE (1<<4)

//Special return values of [/datum/component/material_container/insert_item]
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

//Stock market stock values.
/// How much quantity of a material stock exists for common materials like iron & glass.
#define MATERIAL_QUANTITY_COMMON 25000
/// How much quantity of a material stock exists for uncommon materials like silver & titanium.
#define MATERIAL_QUANTITY_UNCOMMON 10000
/// How much quantity of a material stock exists for rare materials like gold, uranium, & diamond.
#define MATERIAL_QUANTITY_RARE 2500
/// How much quantity of a material stock exists for exotic materials like diamond & bluespace crystals.
#define MATERIAL_QUANTITY_EXOTIC 500
