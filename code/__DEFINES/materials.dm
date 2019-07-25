/// Is the material from an ore? currently unused but exists atm for categorizations sake
#define MAT_CATEGORY_ORE "ore capable"

/// Hard materials, such as iron or metal
#define MAT_CATEGORY_RIGID "rigid material"


/// Gets the reference for the material type that was given
#define getmaterialref(A) (SSmaterials.materials[A])

/// Flag for atoms, this flag ensures it isn't re-colored by materials. Useful for snowflake icons such as default toolboxes.
#define MATERIAL_NO_COLOR (1<<0)