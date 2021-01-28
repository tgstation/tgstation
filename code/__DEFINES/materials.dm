/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"

/// Hard materials, such as iron or metal
#define MAT_CATEGORY_RIGID "rigid material"

/// Materials that can be used to craft items
#define MAT_CATEGORY_ITEM_MATERIAL "item material"

///Use this flag on TRUE if you want the basic recipes
#define MAT_CATEGORY_BASE_RECIPES "basic recipes"

/// Used to make a material initialize at roundstart.
#define MATERIAL_INIT_MAPLOAD	(1<<0)
/// Used to make a material type able to be instantiated on demand after roundstart.
#define MATERIAL_INIT_BESPOKE	(1<<1)

//Material Container Flags.
///If the container shows the amount of contained materials on examine.
#define MATCONTAINER_EXAMINE		(1<<0)
///If the container cannot have materials inserted through attackby().
#define MATCONTAINER_NO_INSERT		(1<<1)
///if the user can insert mats into the container despite the intent.
#define MATCONTAINER_ANY_INTENT			(1<<2)
///if the user won't receive a warning when attacking the container with an unallowed item.
#define MATCONTAINER_SILENT				(1<<3)

// The following flags are for decomposing alloys. Should be expanded upon and diversified once someone gets around to reworking recycling.
/// Can reduce an alloy into its component materials.
#define BREAKDOWN_ALLOYS				(1<<4)
/// Makes the material composition include transmuted materials objects
#define BREAKDOWN_INCLUDE_ALCHEMY		(1<<5)
/// Breakdown flags used by techfabs and circuit printers.
#define BREAKDOWN_FLAGS_LATHE			(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ORM.
#define BREAKDOWN_FLAGS_ORM				(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the recycler.
#define BREAKDOWN_FLAGS_RECYCLER		(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the sheetifier.
#define BREAKDOWN_FLAGS_SHEETIFIER		(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the ore processor.
#define BREAKDOWN_FLAGS_ORE_PROCESSOR	(BREAKDOWN_ALLOYS)
/// Breakdown flags used by the drone dispenser.
#define BREAKDOWN_FLAGS_DRONE_DISPENSER	(BREAKDOWN_ALLOYS)
/// Breakdown flags used when exporting materials.
#define BREAKDOWN_FLAGS_EXPORT			(NONE)

/// Flag for atoms, this flag ensures it isn't re-colored by materials. Useful for snowflake icons such as default toolboxes.
#define MATERIAL_COLOR (1<<0)
#define MATERIAL_ADD_PREFIX (1<<1)
#define MATERIAL_NO_EFFECTS (1<<2)
#define MATERIAL_AFFECT_STATISTICS (1<<3)

/// Wrapper for fetching material references. Exists exclusively so that people don't need to wrap everything in a list every time.
#define GET_MATERIAL_REF(arguments...) SSmaterials._GetMaterialRef(list(##arguments))

#define MATERIAL_SOURCE(mat) "[mat.name]_material"



// Slowdown values.
/// The slowdown value of one [MINERAL_MATERIAL_AMOUNT] of plasteel.
#define MATERIAL_SLOWDOWN_PLASTEEL		(0.05)
/// The slowdown value of one [MINERAL_MATERIAL_AMOUNT] of alien alloy.
#define MATERIAL_SLOWDOWN_ALIEN_ALLOY	(0.1)
