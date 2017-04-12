//Ranged
/obj/item/projectile/sutando
	name = "crystal spray"
	icon_state = "sutando"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

//rore zone

/datum/sutando_abilities/ranged
	id = "ranged"
	name = "Long-Range Ability"
	value = 4
	var/datum/action/innate/snare/plant/P = new
	var/datum/action/innate/snare/remove/R = new
	var/list/snares

/datum/sutando_abilities/ranged/Destroy()
	snares.Cut()
	QDEL_NULL(P)
	QDEL_NULL(R)
	QDEL_NULL(snares)
	return ..()

/datum/sutando_abilities/ranged/handle_stats()
	. = ..()
	LAZYINITLIST(snares)
	stand.has_mode = TRUE
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.05
	stand.projectiletype = /obj/item/projectile/sutando
	stand.ranged_cooldown_time = 1 //fast!
	stand.projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	stand.ranged = TRUE
	stand.range += 6
	stand.has_mode = TRUE

	stand.see_invisible = SEE_INVISIBLE_LIVING
	stand.see_in_dark += 4
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode
	P.Grant(stand)
	R.Grant(stand)



/datum/sutando_abilities/ranged/handle_mode()
	if(stand.loc == user)
		if(toggle)
			stand.ranged = initial(stand.ranged)
			stand.melee_damage_lower = initial(stand.melee_damage_lower)
			stand.melee_damage_upper = initial(stand.melee_damage_upper)
			stand.obj_damage = initial(stand.obj_damage)
			stand.environment_smash = initial(stand.environment_smash)
			stand.alpha = 255
			stand.range = initial(stand.range)
			stand.incorporeal_move = 0
			to_chat(stand,"<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			stand.ranged = TRUE
			stand.melee_damage_lower = 0
			stand.melee_damage_upper = 0
			stand.obj_damage = 0
			stand.environment_smash = 0
			stand.alpha = 45
			stand.range = 255
			stand.incorporeal_move = 1
			to_chat(stand,"<span class='danger'><B>You switch to scout mode.</span></B>")
			toggle = TRUE
	else
		to_chat(stand,"<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")

/datum/sutando_abilities/ranged/light_switch()
	var/msg
	switch(stand.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			stand.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "You activate your night vision."
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			stand.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "You increase your night vision."
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			stand.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "You maximize your night vision."
		else
			stand.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "You deactivate your night vision."

	to_chat(stand, "<span class='notice'>[msg]</span>")

/datum/action/innate/snare
	background_icon_state = "bg_alien"

/datum/action/innate/snare/plant
	name = "Plant Snare"
	button_icon_state = "set_drop"

/datum/action/innate/snare/plant/Activate()
	var/mob/living/simple_animal/hostile/sutando/A = owner
	for(var/datum/sutando_abilities/ranged/I in A.current_abilities)
		if(I.snares.len <6)
			var/turf/snare_loc = get_turf(owner.loc)
			var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
			S.spawner = owner
			S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
			I.snares |= S
			to_chat(owner,"<span class='danger'><B>Surveillance snare deployed!</span></B>")
		else
			to_chat(owner,"<span class='danger'><B>You have too many snares deployed. Remove some first.</span></B>")

/datum/action/innate/snare/remove
	name = "Remove Snare"
	button_icon_state = "camera_off"

/datum/action/innate/snare/remove_snare/Activate()
	var/mob/living/simple_animal/hostile/sutando/A = owner
	for(var/datum/sutando_abilities/ranged/I in A.current_abilities)
		var/picked_snare = input(owner, "Pick which snare to remove", "Remove Snare") as null|anything in I.snares
		if(picked_snare)
			owner -= picked_snare
			qdel(picked_snare)
			to_chat(owner,"<span class='danger'><B>Snare disarmed.</span></B>")



/datum/sutando_abilities/ranged/ranged_attack(atom/target_atom)
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		stand.say("[battlecry][battlecry][battlecry]!!")
		if(stand.namedatum)
			P.color = stand.namedatum.colour


/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/sutando/spawner
	invisibility = INVISIBILITY_ABSTRACT


/obj/effect/snare/Crossed(AM as mob|obj)
	if(isliving(AM) && spawner && spawner.summoner && AM != spawner && !spawner.hasmatchingsummoner(AM))
		spawner.summoner << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"
		var/list/sutandos = spawner.summoner.hasparasites()
		for(var/para in sutandos)
			para << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"
