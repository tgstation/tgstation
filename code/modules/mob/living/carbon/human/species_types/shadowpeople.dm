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
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()

		if(light_amount > SHADOW_SPECIES_LIGHT_THRESHOLD) //if there's enough light, start dying
			H.take_overall_damage(1,1)
		else if (light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD) //heal in the dark
			H.heal_overall_damage(1,1)


/datum/species/shadow/nightmare
	name = "Nightmare"
	id = "nightmare"
	limbs_id = "shadow"
	burnmod = 1.5
	blacklisted = TRUE
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_w_uniform, slot_s_store)
	species_traits = list(NOBREATH,RESISTCOLD,RESISTPRESSURE,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,PIERCEIMMUNE,NODISMEMBER,NO_UNDERWEAR,NOHUNGER,NO_DNA_COPY,NOTRANSSTING)
	mutanteyes = /obj/item/organ/eyes/night_vision/nightmare
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/shadowwalk

	var/info_text = "You are a <span class='danger'>Nightmare</span>. The ability <span class='warning'>shadow walk</span> allows unlimited, unrestricted movement in the dark using. \
					Your <span class='warning'>light eater</span> will destroy any light producing objects you attack, as well as destroy any lights a living creature may be holding. You will automatically dodge gunfire and melee attacks when on a dark tile."

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/obj/effect/proc_holder/spell/targeted/shadowwalk/SW = new
	C.AddSpell(SW)
	shadowwalk = SW
	var/obj/item/light_eater/blade = new
	C.put_in_hands(blade)

	to_chat(C, "[info_text]")

	C.real_name = "Nightmare"
	C.name = "Nightmare"
	if(C.mind)
		C.mind.name = "Nightmare"
	C.dna.real_name = "Nightmare"

/datum/species/shadow/nightmare/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(shadowwalk)
		C.RemoveSpell(shadowwalk)

/datum/species/shadow/nightmare/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message("<span class='danger'>[H] dances in the shadows, evading [P]!</span>")
			playsound(T, "bullet_miss", 75, 1)
			return -1
	return 0

/obj/item/light_eater
	name = "light eater"
	icon_state = "arm_blade"
	item_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	w_class = WEIGHT_CLASS_HUGE
	sharpness = IS_SHARP

/obj/item/light_eater/afterattack(atom/movable/AM, mob/user, proximity)
	if(!proximity)
		return
	if(isopenturf(AM)) //So you can actually melee with it
		return
	if(isliving(AM))
		var/mob/living/L = AM
		if(iscyborg(AM))
			var/mob/living/silicon/robot/borg = AM
			if(!borg.lamp_cooldown)
				borg.update_headlamp(TRUE, INFINITY)
				to_chat(borg, "<span class='danger'>Your headlamp is fried! You'll need a human to help replace it.</span>")
		else
			for(var/obj/item/O in AM)
				if(O.light_range && O.light_power)
					disintegrate(O)
		if(L.pulling && L.pulling.light_range && isitem(L.pulling))
			disintegrate(L.pulling)
	else if(isitem(AM))
		var/obj/item/I = AM
		if(I.light_range && I.light_power)
			disintegrate(I)

/obj/item/light_eater/proc/disintegrate(obj/item/O)
	if(istype(O, /obj/item/device/pda))
		var/obj/item/device/pda/PDA = O
		PDA.set_light(0)
		PDA.fon = 0
		PDA.f_lum = 0
		PDA.update_icon()
		visible_message("<span class='danger'>The light in [PDA] shorts out!</span>")
	else
		visible_message("<span class='danger'>[O] is disintegrated by [src]!</span>")
		O.burn()
	playsound(src, 'sound/items/welder.ogg', 50, 1)
