/obj/item/clock_module
	name = "ratvarian borg module"
	desc = "cool."
	icon = 'monkestation/icons/mob/clock_cult/actions_clock.dmi'
	icon_state = "Replicant"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = NOBLUDGEON
	///what scripture type are we
	var/scripture_datum = /datum/scripture

/obj/item/clock_module/Initialize(mapload)
	. = ..()

	var/datum/scripture/new_scripture = new scripture_datum
	name = new_scripture.name
	desc = new_scripture.desc
	icon_state = new_scripture.button_icon_state

/obj/item/clock_module/attack_self(mob/user, modifiers)
	. = ..()

	if(!IS_CLOCK(user))
		return
	var/mob/living/silicon/robot/our_borg = user
	if(!istype(our_borg))
		return
	if(!scripture_datum)
		return

	var/obj/item/clockwork/clockwork_slab/internal_slab = our_borg.internal_clock_slab
	if(!internal_slab)
		to_chat(user, span_userdanger("You dont have an internal slab, this should not be the case and you should tell an admin with an ahelp(f1)."))
		return
	if(internal_slab.invoking_scripture)
		to_chat(user, span_brass("You fail to invoke [name]."))
		return FALSE

	var/datum/scripture/selected_scripture = GLOB.clock_scriptures_by_type[scripture_datum]
	if(selected_scripture.power_cost > GLOB.clock_power)
		return FALSE

	selected_scripture.begin_invoke(user, internal_slab, TRUE)

/obj/item/clock_module/abscond
	scripture_datum = /datum/scripture/abscond

/obj/item/clock_module/kindle
	scripture_datum = /datum/scripture/slab/kindle

/obj/item/clock_module/sentinels_compromise
	scripture_datum = /datum/scripture/slab/sentinels_compromise

/obj/item/clock_module/prosperity_prism
	scripture_datum = /datum/scripture/create_structure/prosperity_prism

/obj/item/clock_module/ocular_warden
	scripture_datum = /datum/scripture/create_structure/ocular_warden

/obj/item/clock_module/tinkerers_cache
	scripture_datum = /datum/scripture/create_structure/tinkerers_cache

///obj/item/clock_module/stargazer need to add this as well
//	scripture_datum = /datum/scripture/create_structure/stargazer

/obj/item/clock_module/vanguard
	scripture_datum = /datum/scripture/slab/vanguard

///obj/item/clock_module/sigil_submission yes also this
//	scripture_datum = /datum/scripture/create_structure/sigil_submission
