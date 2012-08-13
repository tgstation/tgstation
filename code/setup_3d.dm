  ///////////////////////////////////////////////
 //Important ZAS Functionality.  3D simulation//
///////////////////////////////////////////////

//Uncomment if you want it enabled
//#define ZAS_3D

#ifdef ZAS_3D

var/list/levels_3d = list(1,2) //To expediate calculations, just do "z in levels_3d"

var/list/global_adjacent_z_levels = list("1" = list("up" = 2), "2" = list("down" = 1)) //Example.  2 is above 1

//Commented out ones are incomplete.
//#include "TriDimension\Pipes.dm" //Example
#include "TriDimension\Structures.dm"
#include "TriDimension\Turfs.dm"
//#include "TriDimension\Movement.dm"

#endif