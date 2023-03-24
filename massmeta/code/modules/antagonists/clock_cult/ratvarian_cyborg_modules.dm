/obj/item/clock_module
	name = "ратварский модуль киборга"
	desc = "норм."
	icon = 'massmeta/icons/mob/actions/actions_clockcult.dmi'
	icon_state = "Replicant"
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = NOBLUDGEON
	var/scripture_datum

/obj/item/clock_module/Initialize(mapload)
	..()
	var/datum/clockcult/scripture/S = new scripture_datum
	name = S.name
	desc = S.desc
	icon_state = S.button_icon_state

/obj/item/clock_module/attack_self(mob/user)
	..()
	if(!is_servant_of_ratvar(user))
		return
	var/mob/living/silicon/robot/R = user
	if(!istype(R))
		return
	if(!scripture_datum)
		return
	var/obj/item/clockwork/clockwork_slab/internal_slab = R.internal_clock_slab
	if(!internal_slab)
		return
	if(internal_slab.invoking_scripture)
		to_chat(user, span_brass("Не вышло вызвать [name]."))
		return FALSE
	var/datum/clockcult/scripture/new_scripture = new scripture_datum
	if(new_scripture.power_cost > GLOB.clockcult_power)
		to_chat(user, span_neovgre("Мне потребуется [new_scripture.power_cost]W для вызова [new_scripture.name]."))
		qdel(new_scripture)
		return FALSE
	//Create a new scripture temporarilly to process, when it's done it will be qdeleted.
	new_scripture.qdel_on_completion = TRUE
	new_scripture.begin_invoke(user, internal_slab, TRUE)

/obj/item/clock_module/abscond
	scripture_datum = /datum/clockcult/scripture/abscond

/obj/item/clock_module/kindle
	scripture_datum = /datum/clockcult/scripture/slab/kindle

/obj/item/clock_module/abstraction_crystal
	scripture_datum = /datum/clockcult/scripture/create_structure/abstraction_crystal

/obj/item/clock_module/sentinels_compromise
	scripture_datum = /datum/clockcult/scripture/slab/sentinelscompromise

/obj/item/clock_module/prosperity_prism
	scripture_datum = /datum/clockcult/scripture/create_structure/prosperityprism

/obj/item/clock_module/ocular_warden
	scripture_datum = /datum/clockcult/scripture/create_structure/ocular_warden

/obj/item/clock_module/tinkerers_cache
	scripture_datum = /datum/clockcult/scripture/create_structure/tinkerers_cache

/obj/item/clock_module/stargazer
	scripture_datum = /datum/clockcult/scripture/create_structure/stargazer

/obj/item/clock_module/vanguard
	scripture_datum = /datum/clockcult/scripture/slab/vanguard

/obj/item/clock_module/sigil_submission
	scripture_datum = /datum/clockcult/scripture/create_structure/sigil_submission
