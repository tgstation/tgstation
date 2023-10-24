#define SPECIAL_LAUNCH "launch"
#define SPECIAL_IGNITE "ignite"
#define SPECIAL_TELEPORT "teleport"

/obj/item/melee/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	inhand_icon_state = "plasmashiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	var/special_cooldown_time
	var/special
	var/datum/component/artifact/assoc_comp = /datum/component/artifact/melee
	COOLDOWN_DECLARE(special_cooldown)
	
ARTIFACT_SETUP(/obj/item/melee/artifact, SSobj)

/obj/item/melee/artifact/afterattack(mob/living/victim, mob/user, proximity)
	SIGNAL_HANDLER
	if(!istype(victim) || !assoc_comp.active || !COOLDOWN_FINISHED(src,special_cooldown) || !special || !proximity)
		return
	. |= AFTERATTACK_PROCESSED_ITEM
	switch(special)
		if(SPECIAL_IGNITE)
			victim.adjust_fire_stacks(5)
			victim.ignite_mob(silent = TRUE)
			if(victim.on_fire) //check to make sure they actually caught on fire, or if it was prevented cause they were wet.
				victim.visible_message(span_warning("[victim] catches fire!"), ignored_mobs = victim)
				to_chat(victim, span_userdanger("You feel a sudden wave of heat as you burst into flames!"))
		if(SPECIAL_LAUNCH)
			var/owner_turf = get_turf(user)
			var/throwtarget = get_edge_target_turf(owner_turf, get_dir(owner_turf, get_step_away(victim, owner_turf)))
			victim.safe_throw_at(throwtarget, rand(3,7), 1, force = MOVE_FORCE_VERY_STRONG)
		if(SPECIAL_TELEPORT)
			if(victim.move_resist < MOVE_FORCE_OVERPOWERING)
				do_teleport(victim, get_turf(victim), 15, channel = TELEPORT_CHANNEL_BLUESPACE)
	COOLDOWN_START(src,special_cooldown,special_cooldown_time)

/datum/component/artifact/melee
	associated_object = /obj/item/melee/artifact
	artifact_size = ARTIFACT_SIZE_SMALL
	type_name = "Melee Weapon"
	weight = ARTIFACT_VERYUNCOMMON //rare
	xray_result = "DENSE"
	valid_triggers = list(/datum/artifact_trigger/silicon_touch,/datum/artifact_trigger/heat, /datum/artifact_trigger/shock, /datum/artifact_trigger/radiation)
	var/active_force //force when active
	var/active_reach
	var/active_woundbonus = 0

/datum/component/artifact/melee/setup() //RNG incarnate
	var/obj/item/melee/artifact/weapon = holder
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

/datum/component/artifact/melee/effect_activate()
	var/obj/item/melee/artifact/weapon = holder
	weapon.reach = active_reach
	weapon.force = active_force
	weapon.wound_bonus = active_woundbonus
	weapon.throwforce = weapon.force

/datum/component/artifact/melee/effect_deactivate()
	var/obj/item/melee/artifact/weapon = holder
	weapon.force = active_force / 3
	weapon.throwforce = weapon.force
	weapon.reach = 1
	weapon.wound_bonus = 0

#undef SPECIAL_LAUNCH
#undef SPECIAL_IGNITE
#undef SPECIAL_TELEPORT
