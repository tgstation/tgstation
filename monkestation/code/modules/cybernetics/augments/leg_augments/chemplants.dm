/obj/item/organ/internal/cyberimp/leg/chemplant
	name = "Debug Chemplant"
	desc = "You shouldn't see this!"
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "chemplant"
	implant_overlay = "chemplant_overlay"
	var/list/reagent_list = list()
	var/health_threshold = 40
	var/max_ticks_cooldown = 60 SECONDS
	var/current_ticks_cooldown = 0
	var/mutable_appearance/overlay

/obj/item/organ/internal/cyberimp/leg/chemplant/Initialize()
	. = ..()

/obj/item/organ/internal/cyberimp/leg/chemplant/on_life()
	if(!check_compatibility())
		return
		//Cost of refilling is a little bit of nutrition, some blood and getting jittery
	if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.blood_volume > BLOOD_VOLUME_SURVIVE && current_ticks_cooldown > 0)

		owner.nutrition -= 5
		owner.blood_volume--
		owner.adjust_jitter(1)
		owner.adjust_dizzy(1)

		current_ticks_cooldown -= SSmobs.wait

		return

	if(owner.health < health_threshold)
		current_ticks_cooldown = max_ticks_cooldown
		on_effect()

/obj/item/organ/internal/cyberimp/leg/chemplant/emp_act(severity)
	. = ..()
	health_threshold += rand(-10,10)
	current_ticks_cooldown = max_ticks_cooldown
	on_effect()

/obj/item/organ/internal/cyberimp/leg/chemplant/proc/on_effect()
	var/obj/effect/temp_visual/chempunk/punk = new /obj/effect/temp_visual/chempunk(get_turf(owner))
	punk.color = implant_color
	owner.reagents.add_reagent_list(reagent_list)

	overlay = mutable_appearance('icons/effects/effects.dmi', "biogas",ABOVE_MOB_LAYER)
	overlay.color = implant_color

	RegisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))

	addtimer(CALLBACK(src, PROC_REF(remove_overlay)),max_ticks_cooldown/2)

	to_chat(owner,"<span class = 'notice'> You feel a sharp pain as the cocktail of chemicals is injected into your bloodstream!</span>")
	return

/obj/item/organ/internal/cyberimp/leg/chemplant/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(overlay)
		overlays += overlay

/obj/item/organ/internal/cyberimp/leg/chemplant/proc/remove_overlay()
	QDEL_NULL(overlay)

	UnregisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS)

/obj/effect/temp_visual/chempunk
	icon = 'monkestation/code/modules/cybernetics/icons/96x96.dmi'
	icon_state = "chempunk"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	layer = BELOW_MOB_LAYER
	duration = 5

/obj/item/organ/internal/cyberimp/leg/chemplant/drugs
	name = "deep-vein emergency morale rejuvenator"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."
	implant_color = "#74942a"
	encode_info = AUGMENT_SYNDICATE_LEVEL
	reagent_list = list(
		/datum/reagent/determination = 5,
		/datum/reagent/drug/methamphetamine = 5 ,
		/datum/reagent/medicine/atropine = 5
	)

/obj/item/organ/internal/cyberimp/leg/chemplant/emergency
	name = "deep emergency chemical infuser"
	desc = "Dangerous implant used by the syndicate to reinforce their assault forces that go on suicide missions."
	implant_color = "#2a6194"
	encode_info = AUGMENT_NT_HIGHLEVEL
	reagent_list = list(
		/datum/reagent/medicine/atropine = 5,
		/datum/reagent/medicine/omnizine = 3 ,
		/datum/reagent/medicine/leporazine = 3,
		/datum/reagent/medicine/c2/aiuri = 2,
		/datum/reagent/medicine/c2/libital = 2
	)
