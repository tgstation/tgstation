#define LOWEST_POSSIBLE_CLICK_CD 3
#define HIGHEST_POSSIBLE_CLICK_CD 15

/datum/component/artifact/gun
	associated_object = /obj/item/gun/magic/artifact
	artifact_size = ARTIFACT_SIZE_SMALL
	type_name = "Ranged Weapon"
	weight = ARTIFACT_VERYUNCOMMON //rare
	xray_result = "COMPLEX"
	valid_activators = list(
		/datum/artifact_activator/range/heat,
		/datum/artifact_activator/range/shock,
		/datum/artifact_activator/range/radiation
	)
	valid_faults = list(
		/datum/artifact_fault/ignite = 10,
		/datum/artifact_fault/warp = 10,
		/datum/artifact_fault/reagent/poison = 10,
		/datum/artifact_fault/death = 2,
		/datum/artifact_fault/tesla_zap = 5,
		/datum/artifact_fault/grow = 10,
		/datum/artifact_fault/explosion = 2,
	)

	//list of projectile exclusive projectiles
	///damage each shot does
	var/damage
	///the icon state
	var/projectile_icon
	///the damage type
	var/dam_type
	///total ricochets
	var/ricochets_max = 0
	///chance to ricochets
	var/ricochet_chance = 0
	///range until it auto aims
	var/ricochet_auto_aim_range = 0
	///wound bonus for the shot
	var/wound_bonus = CANT_WOUND
	///is it sharp?
	var/sharpness = NONE
	///does it spread? if so how much
	var/spread = 0

	///list of damage types
	var/list/damage_types = list(
		BRUTE,
		BURN,
		TOX,
		OXY,
		BRAIN,
		STAMINA
	)

/datum/component/artifact/gun/setup()
	var/obj/item/gun/magic/artifact/our_wand = holder
	var/obj/item/ammo_casing/casing = our_wand.chambered
	//randomize our casing
	casing.click_cooldown_override = rand(LOWEST_POSSIBLE_CLICK_CD, HIGHEST_POSSIBLE_CLICK_CD)
	if(prob(30))
		casing.pellets = rand(1,3)
		spread += 0.1

	spread += prob(65) ? rand(0.0, 0.2) : rand(0.3, 1.0)
	damage = rand(-5, 25)

	projectile_icon = pick("energy","scatterlaser","toxin","energy","spell","pulse1","bluespace","gauss","gaussweak","gaussstrong","redtrac","omnilaser","heavylaser","laser","infernoshot","cryoshot","arcane_barrage")
	dam_type = pick(damage_types)
	if(prob(30)) //bouncy
		ricochets_max = rand(1, 40)
		ricochet_chance = rand(80, 600) // will bounce off anything and everything, whether they like it or not
		ricochet_auto_aim_range = rand(0, 4)
	if(prob(50))
		wound_bonus = rand(CANT_WOUND, 15)
	if(prob(40))
		sharpness = pick(SHARP_POINTY,SHARP_EDGED)

#undef LOWEST_POSSIBLE_CLICK_CD
#undef HIGHEST_POSSIBLE_CLICK_CD
