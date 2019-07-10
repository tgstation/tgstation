#define getmaterialref(A) (SSmaterials.materials[A])
#define ismaterialcategory(A) (!istype(A, /datum/material) && !ispath(A, /datum/material) )