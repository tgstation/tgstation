#define upgraded_val(x,y) ( CEILING((x * (1.07 ** y)), 1) )
#define CALIBER_BLOODSILVER "bloodsilver"
#define WEAPON_UPGRADE "weapon_upgrade"

/obj/item/melee/trick_weapon
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	lefthand_file = 'monkestation/icons/bloodsuckers/weapons_lefthand.dmi'
	righthand_file = 'monkestation/icons/bloodsuckers/weapons_righthand.dmi'
	///upgrade level of the weapon
	var/upgrade_level = 0
	///base force when transformed
	var/on_force
	///base force when in default state
	var/base_force
	///default name of the weapon
	var/base_name
	///is the weapon in its transformed state?
	var/enabled = FALSE
	///wounding chance while on
	var/on_wound_bonus

/obj/item/melee/trick_weapon/proc/upgrade_weapon()
	SIGNAL_HANDLER

	upgrade_level++
	force = upgraded_val(base_force,upgrade_level)
	var/datum/component/transforming/transform = GetComponent(/datum/component/transforming)
	transform.force_on = upgraded_val(on_force,upgrade_level)


/obj/item/melee/trick_weapon/attack(mob/target, mob/living/user, params) //our weapon does 25% less damage on non monsters
	var/old_force = force
	if(!(target.mind?.has_antag_datum(/datum/antagonist/changeling)) && !IS_BLOODSUCKER(target) && !IS_HERETIC(target))
		force = force * 0.75
	..()
	force = old_force

/obj/item/melee/trick_weapon/darkmoon
	name = "Darkmoon Greatsword"
	base_name = "Darkmoon Greatsword"
	desc = "Ahh my guiding moonlight, you were by my side all along."
	icon_state = "darkmoon"
	inhand_icon_state = "darkmoon_hilt"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	on_force = 20
	base_force = 17
	light_system = MOVABLE_LIGHT
	light_color = "#59b3c9"
	light_outer_range = 2
	light_power = 2
	light_on = FALSE
	throwforce = 12
	damtype = BURN
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	///ready to launch a beam attack?
	COOLDOWN_DECLARE(moonbeam_fire)


/obj/item/melee/trick_weapon/darkmoon/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/transforming, \
		force_on = on_force , \
		throwforce_on = 20, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_BULKY)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src, WEAPON_UPGRADE, PROC_REF(upgrade_weapon))



/obj/item/melee/trick_weapon/darkmoon/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, active ? "extended" : "collapsed")
	if(active)
		playsound(src, 'monkestation/sound/bloodsuckers/moonlightsword.ogg',50)
	inhand_icon_state = active ? "darkmoon" : "darkmoon_hilt"
	enabled = active
	set_light_on(active)
	force = active ? upgraded_val(on_force, upgrade_level) : upgraded_val(base_force, upgrade_level)
	return COMPONENT_NO_DEFAULT_MESSAGE


/obj/item/melee/trick_weapon/darkmoon/attack_secondary(atom/target, mob/living/user, clickparams)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/melee/trick_weapon/darkmoon/afterattack_secondary(atom/target, mob/living/user, clickparams)
	if(!enabled)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!COOLDOWN_FINISHED(src, moonbeam_fire))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(target == user)
		balloon_alert(user, "can't aim at yourself!")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	fire_moonbeam(target, user, clickparams)
	user.changeNext_move(CLICK_CD_MELEE)
	COOLDOWN_START(src, moonbeam_fire, 4 SECONDS)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/trick_weapon/darkmoon/proc/fire_moonbeam(atom/target, mob/living/user, clickparams)
	var/modifiers = params2list(clickparams)
	var/turf/proj_turf = user.loc
	if(!isturf(proj_turf))
		return
	var/obj/projectile/moonbeam/moon = new(proj_turf)
	moon.preparePixelProjectile(target, user, modifiers)
	moon.firer = user
	playsound(src, 'monkestation/sound/bloodsuckers/moonlightbeam.ogg',50)
	moon.fire()


/obj/projectile/moonbeam
	name = "Moonlight"
	icon = 'icons/effects/effects.dmi'
	icon_state = "plasmasoul"
	damage = 25
	light_system = MOVABLE_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = "#44acb1"
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'



/obj/item/melee/trick_weapon/threaded_cane
	name = "Threaded Cane"
	base_name = "Threaded Cane"
	desc = "A blind man's whip."
	icon_state = "threaded_cane"
	inhand_icon_state = "threaded_cane"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	on_force = 15
	base_force = 18
	throwforce = 12
	reach = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	damtype = BURN
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")


/obj/item/melee/trick_weapon/threaded_cane/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/transforming, \
		force_on = on_force, \
		throwforce_on = 10, \
		throw_speed_on = throw_speed, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_BULKY)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src,WEAPON_UPGRADE, PROC_REF(upgrade_weapon))



/obj/item/melee/trick_weapon/threaded_cane/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, active ? "extended" : "collapsed")
	inhand_icon_state = active ? "chain" : "threaded_cane"
	if(active)
		playsound(src,'sound/magic/clockwork/fellowship_armory.ogg',50)
	reach = active ? 2 : 1
	enabled = active
	force = active ? upgraded_val(on_force, upgrade_level) : upgraded_val(base_force, upgrade_level)
	return COMPONENT_NO_DEFAULT_MESSAGE


/obj/item/melee/trick_weapon/hunter_axe
	name = "Hunter's Axe"
	base_name = "Hunter's Axe"
	desc = "A brute's tool of choice."
	icon_state = "hunteraxe0"
	base_icon_state = "hunteraxe"
	w_class = WEIGHT_CLASS_SMALL
	block_chance = 20
	base_force = 20
	on_force = 25
	throwforce = 12
	reach = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	damtype = BURN
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")



/obj/item/melee/trick_weapon/hunter_axe/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/two_handed, \
		force_unwielded=base_force, \
		force_wielded= on_force, \
		icon_wielded="[base_icon_state]1", \
		wield_callback = CALLBACK(src, PROC_REF(on_wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(on_unwield)), \
	)
	RegisterSignal(src, WEAPON_UPGRADE, PROC_REF(upgrade_weapon))

/obj/item/melee/trick_weapon/hunter_axe/upgrade_weapon()

	upgrade_level++
	var/datum/component/two_handed/handed = GetComponent(/datum/component/two_handed)
	handed.force_wielded = upgraded_val(on_force, upgrade_level)
	handed.force_unwielded = upgraded_val(base_force,upgrade_level)
	force = handed.force_unwielded

/obj/item/melee/trick_weapon/hunter_axe/update_icon_state()
	icon_state = "[base_icon_state]0"
	playsound(src,'sound/magic/clockwork/fellowship_armory.ogg',50)
	return ..()

/obj/item/melee/trick_weapon/hunter_axe/proc/on_wield(obj/item/source)
	enabled = TRUE
	block_chance = 75

/obj/item/melee/trick_weapon/hunter_axe/proc/on_unwield(obj/item/source)
	enabled = FALSE
	block_chance = 20

/obj/item/melee/trick_weapon/beast_claw
	name = "\improper Beast Claw"
	base_name = "\improper Beast Claw"
	desc = "The bones seem to still be twitching."
	icon_state = "Bone_Claw"
	base_icon_state = "Claw"
	w_class =  WEIGHT_CLASS_SMALL
	block_chance = 20
	base_force = 18
	on_force = 23
	throwforce = 10
	wound_bonus = 25
	bare_wound_bonus = 35
	demolition_mod = 1.5 //ripping through doors and windows should be a little easier with a claw shouldnt it?
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/fwoosh.ogg'
	damtype = BRUTE //why can i not make things do wounds i want
	attack_verb_continuous = list("rips", "claws", "gashes", "tears", "lacerates", "dices", "cuts", "attacks")
	attack_verb_simple = list("rip", "claw", "gash", "tear", "lacerate", "dice", "cut", "attack" )

/obj/item/melee/trick_weapon/beast_claw/Initialize(mapload)
	. = ..()
	force = base_force
	AddComponent(/datum/component/transforming, \
		force_on = on_force, \
		w_class_on = WEIGHT_CLASS_BULKY)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	RegisterSignal(src,WEAPON_UPGRADE, PROC_REF(upgrade_weapon))

/obj/item/melee/trick_weapon/beast_claw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER
	balloon_alert(user, active ? "extended" : "collapsed")
	inhand_icon_state = active ? "Claw" : "BoneClaw"
	if(active)
		playsound(src, 'sound/weapons/fwoosh.ogg',50)
	enabled = active
	active = wound_bonus ? 45 : initial(wound_bonus)
	force = active ? upgraded_val(on_force, upgrade_level) : upgraded_val(base_force, upgrade_level)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/rabbit_eye
	name = "Rabbit eye"
	desc = "An item that resonates with trick weapons."
	icon_state = "rabbit_eye"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'

/obj/item/rabbit_eye/proc/upgrade(obj/item/melee/trick_weapon/killer, mob/user)
	if(killer.upgrade_level >= 3)
		user.balloon_alert(user, "Already at maximum upgrade!")
		return
	if(killer.enabled)
		user.balloon_alert(user, "Weapon must be in base form!")
		return
	SEND_SIGNAL(killer,WEAPON_UPGRADE)
	killer.name = "[killer.base_name] +[killer.upgrade_level]"
	balloon_alert(user, "[src] crumbles away...")
	playsound(src, 'monkestation/sound/bloodsuckers/weaponsmithing.ogg', 50)
	qdel(src)

/obj/item/gun/ballistic/revolver/hunter_revolver
	name = "\improper Hunter's Revolver"
	desc = "Does minimal damage but slows down the enemy."
	icon_state = "revolver"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	initial_caliber = CALIBER_BLOODSILVER

/datum/movespeed_modifier/silver_bullet
	movetypes = GROUND
	multiplicative_slowdown = 4
	flags = IGNORE_NOSLOW


/obj/item/ammo_box/magazine/internal/cylinder/bloodsilver
	name = "detective revolver cylinder"
	ammo_type = /obj/item/ammo_casing/silver
	caliber = CALIBER_BLOODSILVER
	max_ammo = 2

/obj/item/ammo_casing/silver
	name = "Bloodsilver casing"
	desc = "A Bloodsilver bullet casing."
	icon_state = "bloodsilver"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	projectile_type = /obj/projectile/bullet/bloodsilver
	caliber = CALIBER_BLOODSILVER


/obj/projectile/bullet/bloodsilver
	name = "Bloodsilver bullet"
	damage = 3
	ricochets_max = 4

/obj/projectile/bullet/bloodsilver/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/man = target
	if(!man)
		return
	if(man.has_movespeed_modifier(/datum/movespeed_modifier/silver_bullet))
		return
	if(!IS_HERETIC(man) && !(IS_BLOODSUCKER(man)) && !(man.mind.has_antag_datum(/datum/antagonist/changeling)))
		return
	man.add_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)
	if(!(man.has_movespeed_modifier(/datum/movespeed_modifier/silver_bullet)))
		return
	addtimer(CALLBACK(man, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/silver_bullet), 8 SECONDS)

/obj/structure/rack/weaponsmith
	name = "Weapon Forge"
	desc = "Fueled by the tears of rabbits."
	icon = 'icons/obj/cult/structures.dmi'
	icon_state = "altar"
	resistance_flags = INDESTRUCTIBLE

/obj/structure/rack/weaponsmith/attackby(obj/item/organ, mob/living/user, params)
	if(!istype(organ, /obj/item/rabbit_eye))
		return ..()
	var/obj/item/rabbit_eye/eye = organ
	var/obj/item/melee/trick_weapon/tool
	for(var/obj/item/weapon in src.loc.contents)
		if(!istype(weapon, /obj/item/melee/trick_weapon))
			continue
		tool = weapon
		break
	if(!tool)
		to_chat(user, span_warning ("Place your weapon upon the table before upgrading it!"))
		return
	eye.upgrade(tool,user)


/obj/item/clothing/mask/cursed_rabbit
	name = "Damned Rabbit Mask"
	desc = "Slip into the wonderland."
	icon =  'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "rabbit_mask"
	worn_icon = 'monkestation/icons/bloodsuckers/worn_mask.dmi'
	worn_icon_state = "rabbit_mask"
	flags_inv = HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	flash_protect = FLASH_PROTECTION_WELDER
	///the paradox rabbit ability
	var/datum/action/cooldown/paradox/paradox
	///teleporting to the wonderland
	var/datum/action/cooldown/wonderland_drop/wonderland


/obj/item/clothing/mask/cursed_rabbit/Initialize(mapload)
	. = ..()
	generate_abilities()


/obj/item/clothing/mask/cursed_rabbit/proc/generate_abilities()
	var/datum/action/cooldown/paradox/para = new
	if(!para.landmark || !para.chessmark)
		return
	paradox = para
	var/datum/action/cooldown/wonderland_drop/drop = new
	if(!drop.landmark)
		return
	wonderland = drop


/obj/item/clothing/mask/cursed_rabbit/equipped(mob/living/carbon/human/user,slot)
	..()
	if(!paradox)
		return
	if(!wonderland)
		return
	if(!(slot & ITEM_SLOT_MASK))
		return
	if(!IS_MONSTERHUNTER(user))
		return
	paradox.Grant(user)
	wonderland.Grant(user)


/obj/item/clothing/mask/cursed_rabbit/dropped(mob/user)
	. = ..()
	if(!paradox)
		return
	if(paradox.owner != user)
		return
	paradox.Remove(user)
	if(!wonderland)
		return
	if(wonderland.owner != user)
		return
	wonderland.Remove(user)

/obj/item/rabbit_locator
	name = "Accursed Red Queen card"
	desc = "Hunts down the white rabbits."
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "locator"
	w_class = WEIGHT_CLASS_SMALL
	///the hunter the card is tied too
	var/datum/antagonist/monsterhunter/hunter
	///cooldown for the locator
	var/cooldown = TRUE

	COOLDOWN_DECLARE(locator_timer)


/obj/item/rabbit_locator/Initialize(mapload, datum/antagonist/monsterhunter/killer)
	. = ..()
	if(!killer)
		return
	hunter = killer
	hunter.locator = src

/obj/item/rabbit_locator/attack_self(mob/user, modifiers)
	if (!COOLDOWN_FINISHED(src, locator_timer))
		return
	if(!cooldown)
		return
	if(!hunter)
		to_chat(user,span_warning("It's just a normal playing card!"))
		return
	if(hunter.owner.current != user)
		to_chat(user,span_warning("It's just a normal playing card!"))
		return
	if(!is_station_level(user.loc.z))
		to_chat(user,span_warning("The card cannot be used here..."))
		return
	var/distance = get_minimum_distance(user)
	var/sound_value
	if(distance >= 50)
		sound_value = 0
		to_chat(user,span_warning("Too far away..."))
	if(distance >= 40 && distance < 50)
		sound_value = 20
		to_chat(user,span_warning("You feel the slightest hint..."))
	if(distance >=30 && distance < 40)
		sound_value = 40
		to_chat(user,span_warning("You feel a mild hint..."))
	if(distance >=20 && distance < 30)
		sound_value = 60
		to_chat(user,span_warning("You feel a strong hint..."))
	if(distance >= 10 && distance < 20)
		sound_value = 80
		to_chat(user,span_warning("You feel a VERY strong hint..."))
	if(distance < 10)
		sound_value = 100
		to_chat(user,span_warning("Here...its definitely here!"))
	user.playsound_local(src, 'monkestation/sound/bloodsuckers/rabbitlocator.ogg',sound_value)
	COOLDOWN_START(src, locator_timer, 7 SECONDS)

/obj/item/rabbit_locator/proc/get_minimum_distance(mob/user)
	var/dist=1000
	if(!hunter)
		return
	if(!hunter.rabbits.len)
		return
	var/obj/effect/selected_bunny
	for(var/obj/effect/located as anything in hunter.rabbits)
		if(get_dist(user,located) < dist)
			dist = get_dist(user,located)
			selected_bunny = located
	var/z_difference = abs(selected_bunny.z - user.z)
	if(dist < 50 && z_difference != 0)
		to_chat(user,span_warning("[z_difference] [z_difference == 1 ? "floor" : "floors"] [selected_bunny.z > user.z ? "above" : "below"]..."))
	return dist

/obj/item/rabbit_locator/Destroy()
	if(hunter)
		hunter.locator = null
		hunter = null
	return ..()

/obj/item/grenade/jack
	name = "jack in the bomb"
	desc = "Best kids' toy"
	w_class = WEIGHT_CLASS_SMALL
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	icon_state = "jack_in_the_bomb"
	inhand_icon_state = "flashbang"
	worn_icon_state = "grenade"
	det_time = 12 SECONDS
	ex_dev = 1
	ex_heavy = 2
	ex_light = 4
	ex_flame = 2



/obj/item/grenade/jack/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	playsound(src, 'monkestation/sound/bloodsuckers/jackinthebomb.ogg', volume, TRUE)
	if(istype(user))
		user.add_mob_memory(/datum/memory/bomb_planted, protagonist = user, antagonist = src)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(detonate)), isnull(delayoverride)? det_time : delayoverride)


/obj/item/grenade/jack/detonate(mob/living/lanced_by)
	if (dud_flags)
		active = FALSE
		update_appearance()
		return FALSE

	dud_flags |= GRENADE_USED // Don't detonate if we have already detonated.
	icon_state = "jack_in_the_bomb_live"
	addtimer(CALLBACK(src, PROC_REF(exploding)), 1 SECONDS)


/obj/item/grenade/jack/proc/exploding(mob/living/lanced_by)
	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
	explosion(src, ex_dev, ex_heavy, ex_light, ex_flame)
