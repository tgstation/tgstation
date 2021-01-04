/**
 * # Alien Sentinel
 *
 * A slightly more durable but less mobile xeno caste.  Utilizes neurotoxin to bring down prey, and has a unique cloaking ability.
 *
 * A caste of alien which prefers to act more at a range and with stealth compared to the hunter.  While it is slower than
 * the average human, its neurotoxin spit allows to to stun a target from afar so it can close the distance and capture prey.
 * To assist with this, the sentinel also has the unique ability to become barely visible, allowing it to ambush targets and
 * evade pursuers, especially in the dark or when standing on resin.
 */
/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 150
	health = 150
	speed = 0.2
	icon_state = "aliens"

/mob/living/carbon/alien/humanoid/sentinel/Initialize()
	AddAbility(new /obj/effect/proc_holder/alien/sneak)
	. = ..()

/mob/living/carbon/alien/humanoid/sentinel/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	..()
