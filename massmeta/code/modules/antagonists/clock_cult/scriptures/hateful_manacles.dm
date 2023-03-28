//==================================//
// !       Hateful Manacles       ! //
//==================================//
/datum/clockcult/scripture/slab/hateful_manacles
	name = "Оковы ненависти"
	desc = "Образует репликантные наручники вокруг запястий цели, которые действуют как наручники, удерживая цель."
	tip = "Образует репликантные наручники вокруг запястий цели, которые действуют как наручники, удерживая цель."
	button_icon_state = "Hateful Manacles"
	power_cost = 25
	invokation_time = 15
	invokation_text = list("Заковать еретика...", "Разбейте их телом и духом!")
	slab_overlay = "hateful_manacles"
	use_time = 200
	cogs_required = 1
	category = SPELLTYPE_SERVITUDE

/datum/clockcult/scripture/slab/hateful_manacles/apply_effects(atom/A)
	. = ..()
	var/mob/living/carbon/M = A
	if(!istype(M))
		return FALSE
	if(is_servant_of_ratvar(M))
		return FALSE
	if(M.handcuffed)
		to_chat(invoker, span_brass("[M] уже связан!"))
		return FALSE
	playsound(M, 'sound/weapons/handcuffs.ogg', 30, TRUE, -2)
	M.visible_message(span_danger("[invoker] формирует силовое поле вокруг [M], латунь стягивает руки!") ,\
						span_userdanger("[invoker] пытается меня связать!"))
	if(do_after(invoker, 30, target=M))
		if(M.handcuffed)
			return FALSE
		var/obj/item/restraints/handcuffs/clockwork/cuffs = new /obj/item/restraints/handcuffs/clockwork(M)
		cuffs.apply_cuffs(M, invoker)
		M.adjust_silence(10 SECONDS)
		return TRUE
	return FALSE

/obj/item/restraints/handcuffs/clockwork
	name = "репликантные наручники"
	desc = "Тяжелые наручники из холодного металла. Похоже на латунь, но кажутся более прочными."
	icon_state = "brass_manacles"
	item_flags = DROPDEL
