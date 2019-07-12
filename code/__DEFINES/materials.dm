#define MAT_CATEGORY_ORE "ore capable"
#define MAT_CATEGORY_RIGID "rigid material"


/// Gets the reference for the material type that was given
#define getmaterialref(A) (SSmaterials.materials[A])

/// Checks if the material given is actually a material, or a category.
#define ismaterialcategory(A) (!istype(A, /datum/material) && !ispath(A, /datum/material) )


#define MATERIAL_NO_COLOR (1<<0)