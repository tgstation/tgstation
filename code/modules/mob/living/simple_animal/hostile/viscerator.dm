/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "syndicate"
	can_butcher = 0
	flying = 1

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	size = SIZE_SMALL
	meat_type = null

/mob/living/simple_animal/hostile/viscerator/Life()
	..()
	if(stat == CONSCIOUS)
		animate(src, pixel_x = rand(-12,12), pixel_y = rand(-12,12), time = 15, easing = SINE_EASING)

/mob/living/simple_animal/hostile/viscerator/Die()
	..()
	visible_message("<span class='warning'><b>[src]</b> is smashed into pieces!</span>")
	qdel (src)
	return

/mob/living/simple_animal/hostile/viscerator/CanPass(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(air_group || (height == 0))
		return 1
	if(istype(mover, /mob/living/simple_animal/hostile/viscerator))
		return 1
	if(istype(mover, /obj/item/projectile))
		return prob(66)
	else
		return !density
