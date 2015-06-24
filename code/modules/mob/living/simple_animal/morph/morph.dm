#define MORPH_COOLDOWN 50

/mob/living/simple_animal/morph
	name = "Morph"
	real_name = "Morph"
	desc = "some amorphous blob"
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	speed = 2
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	environment_smash = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM

	var/morphed = 0
	var/atom/form = null
	var/morph_time = 0

/mob/living/simple_animal/morph/examine(mob/user)
	if(morphed)
		form.examine(user) // Refactor examine to return desc ? Not sure if worth it
		if(get_dist(user,src)<=3) 
			user << "<span class='notice'>Looks odd!</span>"
	else
		..()
	return

/mob/living/simple_animal/morph/ShiftClickOn(var/atom/A)
	if(morph_time <= world.time)
		if(A == src)
			restore()
			return
		if(istype(A,/atom/movable/))
			assume(A)
	else
		..()

/mob/living/simple_animal/morph/proc/assume(var/atom/target)
	morphed = 1
	form = target
	
	//anim(loc,src,'icons/mob/mob.dmi',,"morph",,src.dir) No effect better than shit effect

	//Todo : update to .appearance once 508 hits
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		overlays = H.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	else
		overlays = target.overlays.Copy()

	name = target.name
	icon = target.icon
	icon_state = target.icon_state
	overlays = target.overlays

	//Morphed is weaker
	melee_damage_lower = 5
	melee_damage_upper = 5
	speed = 0

	morph_time = world.time + MORPH_COOLDOWN
	return

/mob/living/simple_animal/morph/proc/restore()
	if(!morphed)
		return
	morphed = 0
	form = null
	
	//anim(loc,src,'icons/mob/mob.dmi',,"morph",,src.dir) 
	
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	overlays.Cut()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	speed = initial(speed)

	morph_time = world.time + MORPH_COOLDOWN
	return

/mob/living/simple_animal/morph/death()
	if(morphed)
		visible_message("<span class='danger'>The [src] dissolves!</span>")
		restore()
	..(0)
	return