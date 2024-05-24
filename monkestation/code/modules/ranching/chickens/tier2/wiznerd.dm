/mob/living/basic/chicken/wiznerd //No matter what you say Zanden this is staying as wiznerd
	icon_suffix = "wiznerd"

	maxHealth = 150
	melee_damage_upper = 7
	melee_damage_lower = 3
	obj_damage = 5
	ai_controller = /datum/ai_controller/chicken/retaliate

	pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/point_targeting/attack/chicken/ranged,
		/datum/pet_command/point_targeting/fetch,
		/datum/pet_command/play_dead,
	)

	breed_name_female = "Witchen"
	breed_name_male = "Wizter"

	egg_type = /obj/item/food/egg/wiznerd
	mutation_list = list()

	projectile_type = /obj/projectile/magic/magic_missle_weak
	ranged_cooldown = 1.5 SECONDS

	book_desc = "It seems the Wizard's Federation has spread its influence into the local chicken population, Nano-Transen higher ups will look into this."

/obj/item/food/egg/wiznerd
	name = "Bewitching Egg"
	icon_state = "wiznerd"

	layer_hen_type = /mob/living/basic/chicken/wiznerd

/obj/item/food/egg/wiznerd/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	. = ..()
	var/datum/action/cooldown/spell/pointed/projectile/arcane_barrage/new_barrage = new
	new_barrage.Grant(eater)
	addtimer(CALLBACK(new_barrage, TYPE_PROC_REF(/datum/action/cooldown/spell/pointed/projectile/arcane_barrage, Remove), eater), 3 MINUTES)

/obj/item/ammo_casing/magic/magic_missle_weak
	projectile_type = /obj/projectile/magic/magic_missle_weak

/obj/projectile/magic/magic_missle_weak
	name = "magic missile"
	icon_state = "arcane_barrage"
	damage = 10
	damage_type = BURN
	hitsound = 'sound/weapons/barragespellhit.ogg'


/datum/action/cooldown/spell/pointed/projectile/arcane_barrage
	name = "Magic Missle Barrage"
	desc = "This spell fires a series of arcane bolts at a target."
	button_icon_state = "arcane_barrage"

	sound = 'sound/magic/fireball.ogg'
	school = SCHOOL_EVOCATION
	cooldown_time = 45 SECONDS

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	active_msg = "You prepare to cast your barrage spell!"
	deactive_msg = "You extinguish your barrage... for now."
	cast_range = 8
	projectile_type = /obj/projectile/magic/arcane_barrage
	projectile_amount = 3
