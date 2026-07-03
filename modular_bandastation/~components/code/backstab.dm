/datum/component/backstabs
	var/backstab_multiplier = 2 // 2x damage by default
	var/cooldown_time = 0 SECONDS
	COOLDOWN_DECLARE(backstab_cooldown)

/datum/component/backstabs/Initialize(mult, cooldown)
	backstab_multiplier = mult
	cooldown_time = cooldown
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))

/datum/component/backstabs/proc/can_backstab(obj/item/source, atom/target, mob/living/user)
	if(!isliving(target))
		return FALSE
	if(!COOLDOWN_FINISHED(src, backstab_cooldown))
		return FALSE
	var/mob/living/living_target = target
	// No bypassing pacifism nerd
	if(source.force > 0 && HAS_TRAIT(user, TRAIT_PACIFISM) && (source.damtype != STAMINA))
		return FALSE
	// Same calculation that kinetic crusher uses
	var/backstab_dir = get_dir(user, living_target)
	// No backstabbing people if they're already in crit
	if(living_target.stat || !(user.dir & backstab_dir) || !(living_target.dir & backstab_dir))
		return FALSE
	return TRUE

/datum/component/backstabs/proc/on_attack(obj/item/source, mob/living/target, mob/living/user)
	if(!can_backstab(source, target, user))
		return
	var/multi = backstab_multiplier - 1
	var/dmg = source.force * multi
	if(dmg) // Truthy because backstabs can heal lol
		target.apply_damage(dmg, source.damtype, BODY_ZONE_CHEST, 0, source.wound_bonus*multi, source.exposed_wound_bonus*multi, source.sharpness*multi)
		log_combat(user, target, "scored a backstab", source.name, "(COMBAT MODE: [user.combat_mode ? "ON" : "OFF"]) (DAMTYPE: [uppertext(source.damtype)])")
	if(cooldown_time > 0)
		COOLDOWN_START(src, backstab_cooldown, cooldown_time)
