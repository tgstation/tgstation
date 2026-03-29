/**
 * Detaches a limb and animates it, so that it attacks its former owner.
 * Stop hitting yourself. Stop hitting yourself.
 */
/obj/item/gun/magic/wand/rebel
	name = "wand of rebellion"
	desc = "The dark power of this wand turns the victim's body against itself."
	school = SCHOOL_NECROMANCY
	ammo_type = /obj/item/ammo_casing/magic/rebellion
	icon_state = "necrowand"
	base_icon_state = "necrowand"
	fire_sound = 'sound/effects/magic/wandodeath.ogg'
	max_charges = 6

/obj/item/gun/magic/wand/rebel/zap_self(mob/living/user, suicide = FALSE)
	. = ..()
	charges--
	var/obj/projectile/magic/rebellion/blast = new()
	if (suicide)
		blast.valid_zones = list(BODY_ZONE_HEAD)
	user.projectile_hit(blast, suicide ? BODY_ZONE_HEAD : BODY_ZONE_CHEST)
	qdel(blast)

/obj/item/gun/magic/wand/rebel/do_suicide(mob/living/user)
	. = ..()
	if (user.stat != DEAD)
		return SHAME // God damn dullahans
	return BRUTELOSS

/obj/item/ammo_casing/magic/rebellion
	projectile_type = /obj/projectile/magic/rebellion

/obj/projectile/magic/rebellion
	name = "bolt of rebellion"
	icon_state = "soulslash"
	damage = 15
	damage_type = BRUTE
	/// Valid locations to shoot someone
	var/list/valid_zones

/obj/projectile/magic/rebellion/Initialize(mapload)
	. = ..()
	valid_zones = GLOB.limb_zones.Copy() // We don't want to mutate the global list

/obj/projectile/magic/rebellion/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/carbon/victim = target
	if (!istype(victim))
		if (isliving(victim))
			victim.apply_damage(35, BRUTE, sharpness = SHARP_EDGED)
		return

	var/obj/item/bodypart/slapper

	while (!slapper && length(valid_zones))
		var/zone = pick_n_take(valid_zones)
		slapper = victim.get_bodypart(zone)

	if (!slapper)
		victim.apply_damage(35, BRUTE, wound_bonus = 20, sharpness = SHARP_EDGED)
		return

	slapper.dismember(silent = FALSE, wounding_type = WOUND_SLASH)
	var/mob/living/bully = slapper.animate_atom_living(firer)
	if (!bully.ai_controller)
		return
	bully.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, victim)
	bully.ai_controller.ai_interact(victim, combat_mode = TRUE)
