/mob/living/simple_animal/chicken/mime
	icon_suffix = "mime"

	breed_name = "Mime"
	egg_type = /obj/item/food/egg/mime

	book_desc = "..."

/obj/item/food/egg/mime
	name = "Mime Egg"
	icon_state = "mime"

	layer_hen_type = /mob/living/simple_animal/chicken/mime

/obj/item/food/egg/mime/Initialize(mapload)
	. = ..()
	icon_state = "mime-[rand(1,3)]"

/obj/item/food/egg/mime/consumed_egg(datum/source, mob/living/eater, mob/living/feeder)
	. = ..()
	eater.apply_status_effect(MIME_EGG)

/datum/status_effect/ranching/mime
	id = "mime_egg"
	duration = 5 MINUTES
	var/has_mute = FALSE
	var/is_miming = FALSE
	var/obj/effect/proc_holder/spell/power = new /obj/effect/proc_holder/spell/targeted/forcewall/mime

/datum/status_effect/ranching/mime/on_apply()
	if(owner.mind)
		if(owner.mind.miming)
			is_miming = TRUE
		else
			owner.mind.miming = TRUE
	if(HAS_TRAIT(owner, TRAIT_MUTE))
		has_mute = TRUE
	else
		ADD_TRAIT(owner, TRAIT_MUTE, "egg_buff")
	owner.AddSpell(power)
	return ..()

/datum/status_effect/ranching/mime/on_remove()
	if(has_mute == FALSE)
		REMOVE_TRAIT(owner, TRAIT_MUTE, "egg_buff")
	if(is_miming == FALSE)
		if(owner.mind)
			owner.mind.miming = FALSE
	owner.RemoveSpell(power)
