/datum/species/vampire
	name = "vampire"
	id = "vampire"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,NOHUNGER)
	mutant_bodyparts = list("tail_human", "ears", "wings")
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None")
	use_skintones = TRUE
	mutanteyes = /obj/item/organ/eyes/night_vision
	mutanttongue = /obj/item/organ/tongue/vampire
	blacklisted = TRUE
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	var/info_text = "You are a <span class='danger'>Vampire</span>. You will slowly but constantly lose blood if outside of a coffin. If inside a coffin, you will slowly heal. You may gain more blood by grabbing a live victim and using your drain ability."

/datum/species/vampire/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/vampire/on_species_gain(mob/living/carbon/human/C, datum/species/old_species)
	. = ..()
	to_chat(C, "[info_text]")
	C.skin_tone = "albino"
	C.update_body(0)
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/B = new
	C.AddSpell(B)

/datum/species/vampire/spec_life(mob/living/carbon/human/C)
	. = ..()
	if(istype(C.loc, /obj/structure/closet/coffin))
		C.heal_overall_damage(4,4)
		C.adjustToxLoss(-4)
		C.adjustOxyLoss(-4)
		return
	C.blood_volume -= 1.5
	if(C.blood_volume <= 0)
		to_chat(C, "<span class='danger'>You ran out of blood!</span>")
		C.dust()
	var/area/A = get_area(C)
	if(istype(A, /area/chapel))
		to_chat(C, "<span class='danger'>You don't belong here!</span>")
		C.adjustFireLoss(20)
		C.adjust_fire_stacks(6)
		C.IgniteMob()

/obj/item/organ/tongue/vampire
	name = "vampire tongue"
	actions_types = list(/datum/action/item_action/organ_action/vampire)
	color = "#1C1C1C"

/datum/action/item_action/organ_action/vampire/Trigger()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/H = owner
		if(H.pulling && iscarbon(H.pulling))
			var/mob/living/carbon/victim = H.pulling
			if(victim.stat == DEAD)
				to_chat(H, "<span class='notice'>You need a living victim!</span>")
				return
			if(victim.blood_volume < 50)
				to_chat(H, "<span class='notice'>Your victim doesn't have enough blood left.</span>")
				return
			if(!do_after(H, 30, target = victim))
				return
			to_chat(victim, "<span class='danger'>[H] is draining your blood!</span>")
			to_chat(H, "<span class='notice'>You drain some blood!</span>")
			playsound(H, 'sound/items/drink.ogg', 30, 1, -2)
			victim.blood_volume = Clamp(victim.blood_volume - 50, 0, BLOOD_VOLUME_MAXIMUM)
			H.blood_volume = Clamp(H.blood_volume + 50, 0, BLOOD_VOLUME_MAXIMUM)

/obj/effect/proc_holder/spell/targeted/shapeshift/bat
	name = "Bat Form"
	desc = "Take on the shape a space bat."
	invocation = "Squeak!"

	shapeshift_type = /mob/living/simple_animal/hostile/retaliate/bat
	list/current_shapes = list(/mob/living/simple_animal/hostile/retaliate/bat)
	list/current_casters = list()
	list/possible_shapes = list(/mob/living/simple_animal/hostile/retaliate/bat)