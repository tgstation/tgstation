#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[fire]-[acid]-[wound]-[consume]"

#define MAXIMUM_DAMAGE_RESIST 85 // 85%, set this to 100 to disable maximum resistance with DR but not recommended
#define DAMAGE_THRESHOLD_MINIMUM 0 // 20%, set this to 0 to disable minimum damage w/ DT but not recommended
#define WEAK_AGAINST_ARMOR_MULTIPLIER 3 // 3x
#define CALCULATE_DR(damage, DR) (damage * ((100 - min(DR, MAXIMUM_DAMAGE_RESIST)) / 100))
#define CALCULATE_DT(damage_DR, DT, damage_base) (max(damage_DR - DT, damage_base * DAMAGE_THRESHOLD_MINIMUM))

#define NO_DAMAGE_THRESHOLD 0
#define LIGHT_DAMAGE_THRESHOLD 5
#define MEDIUM_DAMAGE_THRESHOLD 10
#define HEAVY_DAMAGE_THRESHOLD 15

#define LIGHT_DAMAGE_THRESHOLD_HEAD 1
#define MEDIUM_DAMAGE_THRESHOLD_HEAD 3
#define HEAVY_DAMAGE_THRESHOLD_HEAD 5

#define ARMOR_LIGHT_BLUNT_CHEST list(MELEE = LIGHT_DAMAGE_THRESHOLD, BULLET = LIGHT_DAMAGE_THRESHOLD)
#define ARMOR_MEDIUM_BLUNT_CHEST list(MELEE = MEDIUM_DAMAGE_THRESHOLD, BULLET = MEDIUM_DAMAGE_THRESHOLD)
#define ARMOR_HEAVY_BLUNT_CHEST list(MELEE = HEAVY_DAMAGE_THRESHOLD, BULLET = HEAVY_DAMAGE_THRESHOLD)

#define ARMOR_LIGHT_BLUNT_HEAD list(MELEE = LIGHT_DAMAGE_THRESHOLD_HEAD, BULLET = LIGHT_DAMAGE_THRESHOLD_HEAD)
#define ARMOR_MEDIUM_BLUNT_HEAD list(MELEE = MEDIUM_DAMAGE_THRESHOLD_HEAD, BULLET = MEDIUM_DAMAGE_THRESHOLD_HEAD)
#define ARMOR_HEAVY_BLUNT_HEAD list(MELEE = HEAVY_DAMAGE_THRESHOLD_HEAD, BULLET = HEAVY_DAMAGE_THRESHOLD_HEAD)

#define ARMOR_LIGHT_ENERGY_CHEST list(LASER = LIGHT_DAMAGE_THRESHOLD, ENERGY = LIGHT_DAMAGE_THRESHOLD)
#define ARMOR_MEDIUM_ENERGY_CHEST list(LASER = MEDIUM_DAMAGE_THRESHOLD, ENERGY = MEDIUM_DAMAGE_THRESHOLD)
#define ARMOR_HEAVY_ENERGY_CHEST list(LASER = HEAVY_DAMAGE_THRESHOLD, ENERGY = HEAVY_DAMAGE_THRESHOLD)

#define ARMOR_LIGHT_ENERGY_HEAD list(LASER = LIGHT_DAMAGE_THRESHOLD_HEAD, ENERGY = LIGHT_DAMAGE_THRESHOLD_HEAD)
#define ARMOR_MEDIUM_ENERGY_HEAD list(LASER = MEDIUM_DAMAGE_THRESHOLD_HEAD, ENERGY = MEDIUM_DAMAGE_THRESHOLD_HEAD)
#define ARMOR_HEAVY_ENERGY_HEAD list(LASER = HEAVY_DAMAGE_THRESHOLD_HEAD, ENERGY = HEAVY_DAMAGE_THRESHOLD_HEAD)

#define ARMOR_INVINCIBLE list(MELEE = 100, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0, wound = 0, consume = 0)
	. = locate(ARMORID)
	if (!.)
		. = new /datum/armor(melee, bullet, laser, energy, bomb, bio, fire, acid, wound, consume)

/datum/armor
	datum_flags = DF_USE_TAG
	var/melee
	var/bullet
	var/laser
	var/energy
	var/bomb
	var/bio
	var/fire
	var/acid
	var/wound
	var/consume

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0, wound = 0, consume = 0)
	src.melee = melee
	src.bullet = bullet
	src.laser = laser
	src.energy = energy
	src.bomb = bomb
	src.bio = bio
	src.fire = fire
	src.acid = acid
	src.wound = wound
	src.consume = consume
	tag = ARMORID

/datum/armor/proc/modifyRating(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, fire = 0, acid = 0, wound = 0, consume = 0)
	return getArmor(src.melee+melee, src.bullet+bullet, src.laser+laser, src.energy+energy, src.bomb+bomb, src.bio+bio, src.fire+fire, src.acid+acid, src.wound+wound, src.consume+consume)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee+modifier, bullet+modifier, laser+modifier, energy+modifier, bomb+modifier, bio+modifier, fire+modifier, acid+modifier, wound+modifier, consume+modifier)

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, fire, acid, wound, consume)
	return getArmor((isnull(melee) ? src.melee : melee),\
					(isnull(bullet) ? src.bullet : bullet),\
					(isnull(laser) ? src.laser : laser),\
					(isnull(energy) ? src.energy : energy),\
					(isnull(bomb) ? src.bomb : bomb),\
					(isnull(bio) ? src.bio : bio),\
					(isnull(fire) ? src.fire : fire),\
					(isnull(acid) ? src.acid : acid),\
					(isnull(wound) ? src.wound : wound),\
					(isnull(consume) ? src.consume : consume))

/datum/armor/proc/getRating(rating)
	return vars[rating]

/datum/armor/proc/getList()
	return list(MELEE = melee, BULLET = bullet, LASER = laser, ENERGY = energy, BOMB = bomb, BIO = bio, FIRE = fire, ACID = acid, WOUND = wound, CONSUME = consume)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee+AA.melee, bullet+AA.bullet, laser+AA.laser, energy+AA.energy, bomb+AA.bomb, bio+AA.bio, fire+AA.fire, acid+AA.acid, wound+AA.wound, consume+AA.consume)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee-AA.melee, bullet-AA.bullet, laser-AA.laser, energy-AA.energy, bomb-AA.bomb, bio-AA.bio, fire-AA.fire, acid-AA.acid, wound-AA.wound, consume-AA.consume)

/datum/armor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

#undef ARMORID
