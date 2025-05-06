/**
 * POWERS
 * All defines related to the powers system
 */

// Maximum amount of points a player can spend on their powers


#define MAXIMUM_POWER_POINTS 20

GLOBAL_LIST_INIT(path_core_powers, list(
	"path_sorcerous" = /datum/power/prestidigitation,
	"path_resonant" = /datum/power/meditate,
	"path_mortal" = /datum/power/tenacious
))

/**MORTAL DEFINES
* I'm literally just using this to define Breacher Knuckle right now
* These things, they take time.
*/

#define MARTIALART_BREACHERKNUCKLE "breacher knuckle"
