#define ARMORLISTID "[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[rad]-[fire]-[acid]"

GLOBAL_LIST_EMPTY(armorobjects)

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
  if (GLOB.armorobjects[ARMORLISTID])
    return GLOB.armorobjects[ARMORLISTID]
  else
    return new /datum/armor(melee, bullet, laser, energy, bomb, bio, rad, fire, acid)

/datum/armor
  var/melee
  var/bullet
  var/laser
  var/energy
  var/bomb
  var/bio
  var/rad
  var/fire
  var/acid

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
  src.melee = melee
  src.bullet = bullet
  src.laser = laser
  src.energy = energy
  src.bomb = bomb
  src.bio = bio
  src.rad = rad
  src.fire = fire
  src.acid = acid
  GLOB.armorobjects[ARMORLISTID] = src

/datum/armor/proc/modifyRating(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0)
  return getArmor(src.melee+melee, src.bullet+bullet, src.laser+laser, src.energy+energy, src.bomb+bomb, src.bio+bio, src.rad+rad, src.fire+fire, src.acid+acid)

/datum/armor/proc/modifyAllRatings(modifier = 0)
  return getArmor(src.melee+modifier, src.bullet+modifier, src.laser+modifier, src.energy+modifier, src.bomb+modifier, src.bio+modifier, src.rad+modifier, src.fire+modifier, src.acid+modifier)

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, rad, fire, acid)
  return getArmor((isnull(melee) ? src.melee : melee),\
                  (isnull(melee) ? src.bullet : bullet),\
                  (isnull(melee) ? src.laser : laser),\
                  (isnull(melee) ? src.energy : energy),\
                  (isnull(melee) ? src.bomb : bomb),\
                  (isnull(melee) ? src.bio : bio),\
                  (isnull(melee) ? src.rad : rad),\
                  (isnull(melee) ? src.fire : fire),\
                  (isnull(melee) ? src.acid : acid))

/datum/armor/proc/attachArmor(datum/armor/AA)
  return getArmor(src.melee+AA.melee, src.bullet+AA.bullet, src.laser+AA.laser, src.energy+AA.energy, src.bomb+AA.bomb, src.bio+AA.bio, src.rad+AA.rad, src.fire+AA.fire, src.acid+AA.acid)

/datum/armor/proc/detachArmor(datum/armor/AA)
  return getArmor(src.melee-AA.melee, src.bullet-AA.bullet, src.laser-AA.laser, src.energy-AA.energy, src.bomb-AA.bomb, src.bio-AA.bio, src.rad-AA.rad, src.fire-AA.fire, src.acid-AA.acid)

#undef ARMORLISTID
