//Calibers for guns
///used in mk58
#define CALIBER_435 "4.35"
///used in mk58
#define CALIBER_235 "2.35"
/// The caliber used by the Oldarms 'Mk.11.4 rifle', designed to be worse .223.
#define CALIBER_223S ".223 Stinger"

/// Caliber used by the giant anti materiel rifle in guncargo
#define CALIBER_60STRELA ".60 Strela"

/// CIN pistol caliber
#define CALIBER_CESARZOWA ".27-54 Cesarzowa"

/// Standard Sol rifle caliber
#define CALIBER_SOL40LONG ".40 Sol Long"
/// Standard Sol pistol caliber
#define CALIBER_SOL35SHORT ".35 Sol Short"

/// Basically 20mm grenades, I'd be concerned if a grenade launcher didn't use this
#define CALIBER_980TYDHOUER ".980 Tydhouer"

/// Large caliber pistol round for Sol hand cannons
#define CALIBER_585TRAPPISTE ".585 Trappiste"

/// Caliber used by the pepperball gun
#define CALIBER_PEPPERBALL "pepperball"

// open to suggestions on where to put these overrides
// hugely not a fan of this but we do what we gotta

/*
 * gotta redefine EVERY goddamn ammo type irt to new mat costs for the ammobench's sake
 * previously, SMALL_MATERIAL_AMOUNT was 100 units out of 2000 from a sheet (5%)
 * so the old cost of SMALL_MATERIAL_AMOUNT * 5 was 500/2000 from a sheet (25%)
 * experimental material balance PR makes it so that SMALL_MATERIAL_AMOUNT is actually 10 units out of 100 (10%)
 * which made it so that the old assumed value of SMALL_MATERIAL_AMOUNT * 5 is 50/100 (50% of a sheet for a single bullet) (suboptimal)
 * these updated, more consistent defines make it so that a single round's total materials should total 20% of a sheet, or 2 SMALL_MATERIAL_AMOUNT
*/

#define AMMO_MATS_BASIC list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2, \
)

#define AMMO_MATS_AP list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/titanium = SMALL_MATERIAL_AMOUNT * 0.4, \
)

#define AMMO_MATS_TEMP list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 0.4, \
)

#define AMMO_MATS_EMP list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/uranium = SMALL_MATERIAL_AMOUNT * 0.4, \
)

#define AMMO_MATS_PHASIC list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.4, \
)

#define AMMO_MATS_TRAC list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/silver = SMALL_MATERIAL_AMOUNT * 0.2, \
	/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.2, \
)

#define AMMO_MATS_HOMING list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1, \
	/datum/material/silver = SMALL_MATERIAL_AMOUNT * 0.2, \
	/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.2, \
	/datum/material/plasma = SMALL_MATERIAL_AMOUNT * 0.2, \
	/datum/material/diamond = SMALL_MATERIAL_AMOUNT * 0.2, \
	/datum/material/bluespace = SMALL_MATERIAL_AMOUNT * 0.2, \
)

// for .35 Sol Ripper
#define AMMO_MATS_RIPPER list( \
	/datum/material/iron = SMALL_MATERIAL_AMOUNT * 1.6, \
	/datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.4, \
)

/obj/item/ammo_casing
	custom_materials = AMMO_MATS_BASIC
