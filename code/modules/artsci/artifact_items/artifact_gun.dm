/obj/item/ammo_casing/magic/artifact
	projectile_type = /obj/projectile/magic/artifact

/obj/item/ammo_casing/magic/artifact/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/fired_from)
	if(!loaded_projectile)
		return
	var/datum/component/artifact/gun/gun = fired_from.GetComponent(/datum/component/artifact/gun)
	loaded_projectile.damage = gun.damage / pellets
	loaded_projectile.icon_state = gun.projectile_icon
	loaded_projectile.damage_type = gun.dam_type
	loaded_projectile.ricochets_max = gun.ricochets_max
	loaded_projectile.ricochet_chance = gun.ricochet_chance
	loaded_projectile.ricochet_auto_aim_range = gun.ricochet_auto_aim_range
	loaded_projectile.wound_bonus = gun.wound_bonus
	loaded_projectile.sharpness = gun.sharpness
	loaded_projectile.spread = gun.spread
	return ..()

/obj/projectile/magic/artifact
	name = "incomprehensible energy"
	antimagic_flags = null
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9
	hitsound_wall = SFX_RICOCHET
	impact_effect_type = /obj/effect/temp_visual/impact_effect


/obj/item/gun/magic/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-item1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	icon = 'icons/obj/artifacts.dmi'
	inhand_icon_state = "plasmashiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	ammo_type = /obj/item/ammo_casing/magic/artifact
	school = SCHOOL_UNSET
	max_charges = 8
	pinless = TRUE
	recharge_rate = 1
	antimagic_flags = null
	var/datum/component/artifact/assoc_comp = /datum/component/artifact/gun

ARTIFACT_SETUP(/obj/item/gun/magic/artifact, SSobj)

/obj/item/gun/magic/artifact/can_shoot()
	return assoc_comp.active

/obj/item/gun/magic/artifact/shoot_with_empty_chamber()
	return

/datum/component/artifact/gun
	associated_object = /obj/item/gun/magic/artifact
	artifact_size = ARTIFACT_SIZE_SMALL
	type_name = "Ranged Weapon"
	weight = ARTIFACT_VERYUNCOMMON //rare
	xray_result = "COMPLEX"
	valid_triggers = list(/datum/artifact_trigger/heat, /datum/artifact_trigger/shock, /datum/artifact_trigger/radiation)
	var/damage
	var/projectile_icon
	var/dam_type
	var/ricochets_max = 0
	var/ricochet_chance = 0
	var/ricochet_auto_aim_range = 0
	var/wound_bonus = CANT_WOUND
	var/sharpness = NONE
	var/spread = 0

/datum/component/artifact/gun/setup()
	var/obj/item/gun/magic/artifact/our_wand = holder
	var/obj/item/ammo_casing/casing = our_wand.chambered
	//randomize our casing
	casing.click_cooldown_override = rand(3,10)
	if(prob(30))
		casing.pellets = rand(1,3)
		spread += 0.1

	spread += prob(65) ? rand(0.0,0.2) : rand(0.3,1.0)
	damage = rand(-5,25)
	projectile_icon = pick("energy","scatterlaser", "toxin", "energy", "spell", "pulse1", "bluespace", "gauss","gaussweak","gaussstrong", "redtrac", "omnilaser", "heavylaser", "laser", "infernoshot", "cryoshot", "arcane_barrage")
	dam_type = pick(BRUTE,BURN,TOX,STAMINA,BRAIN)
	if(prob(30)) //bouncy
		ricochets_max = rand(1,40)
		ricochet_chance = rand(80,600) // will bounce off anything and everything, whether they like it or not
		ricochet_auto_aim_range = rand(0,4)
	if(prob(50))
		wound_bonus = rand(CANT_WOUND,15)
	if(prob(40))
		sharpness = pick(SHARP_POINTY,SHARP_EDGED)
