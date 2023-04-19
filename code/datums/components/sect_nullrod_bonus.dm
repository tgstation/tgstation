/**
 * sect nullrod bonus component; for sekret rite combos
 *
 * Good example is the bow and pyre sect. pick the bow, get a special rite in the pyre sect.
 */
/datum/component/sect_nullrod_bonus
	/// assoc list of nullrod type -> rites it unlocks
	var/list/bonus_rites
	/// has this component given the bonus yet
	var/bonus_applied = FALSE

/datum/component/sect_nullrod_bonus/Initialize(list/bonus_rites)
	if(!istype(parent, /datum/religion_sect))
		return COMPONENT_INCOMPATIBLE
	src.bonus_rites = bonus_rites
	check_bonus_rites()

/datum/component/sect_nullrod_bonus/RegisterWithParent()


/datum/component/sect_nullrod_bonus/UnregisterFromParent()


/datum/component/sect_nullrod_bonus/proc/check_bonus_rites()
	if(bonus_applied || !GLOB.holy_weapon_type)
		return
	var/list/unlocked_rites = bonus_rites[GLOB.holy_weapon_type]
	if(!unlocked_rites)
		return
