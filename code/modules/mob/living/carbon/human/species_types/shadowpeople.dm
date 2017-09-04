/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "???"
	id = "shadow"
	sexes = 0
	blacklisted = 1
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBREATH,NOBLOOD,RADIMMUNE,VIRUSIMMUNE)

	dangerous_existence = 1
	mutanteyes = /obj/item/organ/eyes/night_vision


/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()

		if(light_amount > 0.2) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < 0.2) //heal in the dark
			H.heal_overall_damage(1,1)


/datum/species/shadow/nightmare
	name = "Nightmare"
	id = "nightmare"
	burnmod = 1.5
	blacklisted = TRUE
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,NO_UNDERWEAR)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.AddSpell(/obj/effect/proc_holder/spell/targeted/shadowwalk)
	var/obj/item/light_eater/blade = new
	C.put_in_hands(blade)


/datum/species/shadow/nightmare/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = T.get_lumcount()
		if (light_amount < 0.2)
			H.visible_message("<span class='danger'>[H] dances in the shadows, evading [P]!</span>")
			playsound(T, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
			return -1
	return 0

/obj/item/light_eater
	name = "light eater"
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP

/obj/item/light_eater/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(isopenturf(AM)) //So you can actually melee with it
		return
	if(isliving(AM))
		for(var/obj/item/O in AM)
			if(O.light_power)
				disintegrate(O)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.light_power)
			disintegrate(I)

/obj/item/light_eater/proc/disintegrate(obj/item/O)
	if(prob((200 / O.light_range)))
		src.loc.visible_message("<span class='danger'>[O] is disintegrated by [src]!</span>")
		O.burn()