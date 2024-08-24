#define SPECIAL_LAUNCH "launch"
#define SPECIAL_IGNITE "ignite"
#define SPECIAL_TELEPORT "teleport"

/datum/artifact_effect/melee
	artifact_size = ARTIFACT_SIZE_SMALL
	type_name = "Melee Weapon Effect"
	weight = ARTIFACT_VERYUNCOMMON //rare
	valid_activators = list(
		/datum/artifact_activator/touch/silicon,
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation
	)
	var/active_force //force when active
	var/active_reach
	var/active_woundbonus = 0

	examine_discovered = span_warning("It appears to be some sort of melee weapon")

/datum/artifact_effect/melee/setup() //RNG incarnate
	var/obj/item/melee/artifact/weapon = our_artifact.holder
	weapon.special_cooldown_time = rand(3,8) SECONDS
	active_force = rand(-10,30)
	weapon.demolition_mod = rand(-1.0, 2.0)
	weapon.force = active_force / 3
	weapon.throwforce = weapon.force
	potency += abs(active_force)
	if(prob(40))
		weapon.sharpness = pick(SHARP_EDGED,SHARP_POINTY)
		if(weapon.sharpness == SHARP_POINTY)
			weapon.attack_verb_continuous = list("stabs", "shanks", "pokes")
			weapon.attack_verb_simple = list("stab", "shank", "poke")
		else
			weapon.attack_verb_continuous = list("slashes", "slices", "cuts")
			weapon.attack_verb_simple = list("slash", "slice", "cut")
		weapon.hitsound = 'sound/weapons/bladeslice.ogg'
		potency += 9
	if(prob(30))
		active_woundbonus = rand(3,20)
	if(prob(30))
		weapon.armour_penetration = rand(5,15)//this barely does anything inactive so its fine to have it always
	if(prob(50))
		weapon.damtype = pick(BRUTE, BURN, TOX, STAMINA)
	if(prob(10))
		active_reach = rand(1,3) // this CANT possibly backfire
		potency += 20
	if(prob(30))
		potency += 15
		weapon.special = pick(SPECIAL_LAUNCH, SPECIAL_IGNITE, SPECIAL_TELEPORT)

/datum/artifact_effect/melee/effect_activate()
	var/obj/item/melee/artifact/weapon = our_artifact.holder
	weapon.reach = active_reach
	weapon.force = active_force
	weapon.wound_bonus = active_woundbonus
	weapon.throwforce = weapon.force

/datum/artifact_effect/melee/effect_deactivate()
	var/obj/item/melee/artifact/weapon = our_artifact.holder
	weapon.force = active_force / 3
	weapon.throwforce = weapon.force
	weapon.reach = 1
	weapon.wound_bonus = 0

#undef SPECIAL_LAUNCH
#undef SPECIAL_IGNITE
#undef SPECIAL_TELEPORT
