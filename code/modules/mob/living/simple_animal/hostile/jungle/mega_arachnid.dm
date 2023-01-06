//Large and powerful, but timid. It won't engage anything above 50 health, or anything without legcuffs.
//It can fire fleshy snares that legcuff anyone that it hits, making them look especially tasty to the arachnid.
/mob/living/simple_animal/hostile/jungle/mega_arachnid
	name = "mega arachnid"
	desc = "Though physically imposing, it prefers to ambush its prey, and it will only engage with an already crippled opponent."
	icon = 'icons/mob/simple/jungle/arachnid.dmi'
	icon_state = "arachnid"
	icon_living = "arachnid"
	icon_dead = "arachnid_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BUG
	melee_damage_lower = 30
	melee_damage_upper = 30
	maxHealth = 300
	health = 300
	speed = 1
	ranged = 1
	pixel_x = -16
	base_pixel_x = -16
	move_to_delay = 10
	aggro_vision_range = 9
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	ranged_cooldown_time = 60
	projectiletype = /obj/projectile/mega_arachnid
	projectilesound = 'sound/weapons/pierce.ogg'
	alpha = 50

	footstep_type = FOOTSTEP_MOB_CLAW
	var/datum/action/small_sprite/mini_arachnid = new/datum/action/small_sprite/mega_arachnid()

/mob/living/simple_animal/hostile/jungle/mega_arachnid/Life(delta_time = SSMOBS_DT, times_fired)
	..()
	if(target && ranged_cooldown > world.time && iscarbon(target))
		var/mob/living/carbon/C = target
		if(!C.legcuffed && C.health < 50)
			retreat_distance = 9
			minimum_distance = 9
			alpha = 125
			return
	retreat_distance = 0
	minimum_distance = 0
	alpha = 255


/mob/living/simple_animal/hostile/jungle/mega_arachnid/Aggro()
	..()
	alpha = 255

/mob/living/simple_animal/hostile/jungle/mega_arachnid/LoseAggro()
	..()
	alpha = 50

/mob/living/simple_animal/hostile/jungle/mega_arachnid/Initialize(mapload)
	. = ..()
	add_cell_sample()
	mini_arachnid.Grant(src)

/mob/living/simple_animal/hostile/jungle/mega_arachnid/add_cell_sample()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGA_ARACHNID, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/projectile/mega_arachnid
	name = "flesh snare"
	nodamage = TRUE


	damage = 0
	icon_state = "tentacle_end"

/obj/projectile/mega_arachnid/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target) && blocked < 100)
		var/obj/item/restraints/legcuffs/beartrap/mega_arachnid/B = new /obj/item/restraints/legcuffs/beartrap/mega_arachnid(get_turf(target))
		B.spring_trap(null, target)
	return ..()

/obj/item/restraints/legcuffs/beartrap/mega_arachnid
	name = "fleshy restraints"
	desc = "Used by mega arachnids to immobilize their prey."
	item_flags = DROPDEL
	flags_1 = NONE
	icon_state = "flesh_snare"
	armed = TRUE

/obj/item/restraints/legcuffs/beartrap/mega_arachnid/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_MEGA_ARACHNID, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)
