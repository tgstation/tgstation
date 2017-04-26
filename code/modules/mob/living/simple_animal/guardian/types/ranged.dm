//Ranged
/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

//rore zone

/datum/guardian_abilities/ranged
	id = "ranged"
	name = "Long-Range Ability"
	value = 4
	var/datum/action/innate/snare/plant/P = new
	var/datum/action/innate/snare/remove/R = new
	var/list/snares

/datum/guardian_abilities/ranged/Destroy()
	snares.Cut()
	QDEL_NULL(P)
	QDEL_NULL(R)
	QDEL_NULL(snares)
	return ..()

/datum/guardian_abilities/ranged/handle_stats()
	. = ..()
	LAZYINITLIST(snares)
	guardian.has_mode = TRUE
	guardian.melee_damage_lower += 5
	guardian.melee_damage_upper += 5
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.05
	guardian.projectiletype = /obj/item/projectile/guardian
	guardian.ranged_cooldown_time = 1 //fast!
	guardian.projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	guardian.ranged = TRUE
	guardian.range += 6
	guardian.has_mode = TRUE

	guardian.see_invisible = SEE_INVISIBLE_LIVING
	guardian.see_in_dark += 4
	guardian.toggle_button_type = /obj/screen/guardian/ToggleMode
	P.Grant(guardian)
	R.Grant(guardian)



/datum/guardian_abilities/ranged/handle_mode()
	if(guardian.loc == user)
		if(toggle)
			guardian.ranged = initial(guardian.ranged)
			guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
			guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
			guardian.obj_damage = initial(guardian.obj_damage)
			guardian.environment_smash = initial(guardian.environment_smash)
			guardian.alpha = 255
			guardian.range = initial(guardian.range)
			guardian.incorporeal_move = 0
			to_chat(guardian,"<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			guardian.ranged = TRUE
			guardian.melee_damage_lower = 0
			guardian.melee_damage_upper = 0
			guardian.obj_damage = 0
			guardian.environment_smash = 0
			guardian.alpha = 45
			guardian.range = 255
			guardian.incorporeal_move = 1
			to_chat(guardian,"<span class='danger'><B>You switch to scout mode.</span></B>")
			toggle = TRUE
	else
		to_chat(guardian,"<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")

/datum/guardian_abilities/ranged/light_switch()
	var/msg
	switch(guardian.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			guardian.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			msg = "You activate your night vision."
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			guardian.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			msg = "You increase your night vision."
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			guardian.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			msg = "You maximize your night vision."
		else
			guardian.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			msg = "You deactivate your night vision."

	to_chat(guardian, "<span class='notice'>[msg]</span>")

/datum/action/innate/snare
	background_icon_state = "bg_alien"

/datum/action/innate/snare/plant
	name = "Plant Snare"
	button_icon_state = "set_drop"

/datum/action/innate/snare/plant/Activate()
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/ranged/I in A.current_abilities)
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
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/ranged/I in A.current_abilities)
		var/picked_snare = input(owner, "Pick which snare to remove", "Remove Snare") as null|anything in I.snares
		if(picked_snare)
			owner -= picked_snare
			qdel(picked_snare)
			to_chat(owner,"<span class='danger'><B>Snare disarmed.</span></B>")



/datum/guardian_abilities/ranged/ranged_attack(atom/target_atom)
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		guardian.say("[battlecry][battlecry][battlecry]!!")
		if(guardian.namedatum)
			P.color = guardian.namedatum.colour


/obj/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/simple_animal/hostile/guardian/spawner
	invisibility = INVISIBILITY_ABSTRACT


/obj/effect/snare/Crossed(AM as mob|obj)
	if(isliving(AM) && spawner && spawner.summoner && AM != spawner && !spawner.hasmatchingsummoner(AM))
		spawner.summoner << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"
		var/list/guardians = spawner.summoner.hasparasites()
		for(var/para in guardians)
			para << "<span class='danger'><B>[AM] has crossed surveillance snare, [name].</span></B>"
