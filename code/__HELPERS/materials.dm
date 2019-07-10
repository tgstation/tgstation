/// Gets the reference for the material type that was given
#define getmaterialref(A) (SSmaterials.materials[A])

/// Checks if the material given is actually a material, or a category.
#define ismaterialcategory(A) (!istype(A, /datum/material) && !ispath(A, /datum/material) )