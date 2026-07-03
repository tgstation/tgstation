/datum/action/changeling/biodegrade
	name = "Biodegrade"
	desc = "Растворяет наручники и другие предметы, мешающие свободному движению. Стоит 30 химикатов."
	helptext = "Это очевидно для находящихся рядом людей и может разрушить стандартные наручники и шкафы. Работает против захватов."
	button_icon_state = "biodegrade"
	category = "utility"
	chemical_cost = 30
	dna_cost = 2
	req_human = TRUE
	disabled_by_fire = FALSE
	var/static/bio_acid_path = /datum/reagent/toxin/acid/bio_acid
	var/static/bio_acid_amount_per_spray = 6
	var/static/bio_acid_color = "#9455ff"

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	. = FALSE
	var/list/obj/restraints = list()
	var/obj/handcuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	var/obj/item/clothing/suit/straitjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
	var/obj/item/clothing/shoes/sneakers/orange/prisoner_shoes = user.get_item_by_slot(ITEM_SLOT_FEET)
	var/obj/item/clothing/shoes/knotted_shoes = user.get_item_by_slot(ITEM_SLOT_FEET)
	var/obj/some_manner_of_cage = astype(user.loc, /obj)
	var/mob/living/space_invader = user.pulledby || user.buckled

	if(!istype(prisoner_shoes) || !prisoner_shoes.attached_cuffs)
		prisoner_shoes = null
	if(!istype(knotted_shoes) || knotted_shoes.tied != SHOES_KNOTTED)
		knotted_shoes = null
	if(!straitjacket?.breakouttime)
		straitjacket = null

	if(!handcuffs && !legcuffs && !straitjacket && !prisoner_shoes && !knotted_shoes && !some_manner_of_cage && !space_invader)
		user.balloon_alert(user, "уже свободен!")
		return .
	..()

	if(handcuffs)
		restraints.Add(handcuffs)
	if(legcuffs)
		restraints.Add(legcuffs)
	if(straitjacket)
		restraints.Add(straitjacket)
	if(prisoner_shoes)
		restraints.Add(prisoner_shoes)
	if(knotted_shoes)
		restraints.Add(knotted_shoes)
	if(some_manner_of_cage)
		restraints.Add(some_manner_of_cage)

	for(var/obj/restraint as anything in restraints)
		if(restraint.obj_flags & (INDESTRUCTIBLE | ACID_PROOF | UNACIDABLE))
			to_chat(user, span_changeling("Мы не можем использовать био-кислоту для уничтожения [restraint.declent_ru(ACCUSATIVE)]!"))
			continue

		if(restraint == user.loc)
			restraint.visible_message(span_warning("Пузырящаяся кислота начинает извергаться из [restraint.declent_ru(ACCUSATIVE)]..."))
			addtimer(CALLBACK(restraint, TYPE_PROC_REF(/atom, atom_destruction), ACID), 4 SECONDS)
			for(var/beat in 1 to 3)
				addtimer(CALLBACK(src, PROC_REF(make_puddle), restraint), beat SECONDS)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), restraint, 'sound/items/tools/welder.ogg', 50, TRUE), beat SECONDS)
			log_combat(user = user, target = restraint, what_done = "melted restraining container", addition = "(biodegrade)")
			return
		//otherwise it's some kind of worn restraint
		addtimer(CALLBACK(restraint, TYPE_PROC_REF(/atom, atom_destruction), ACID), 1.5 SECONDS)
		log_combat(user = user, target = restraint, what_done = "melted restraining item", addition = "(biodegrade)")
		user.visible_message(
			span_warning("[user.declent_ru(NOMINATIVE)] извергает потоки кислоты на [restraint.declent_ru(ACCUSATIVE)], расплавляя его с ужасающей легкостью."),
			user.balloon_alert(user, "расплавляем оковы..."),
			span_danger("Вы слышите рвотный позыв, затем шипение мощной кислоты, ближе к звуку шипящего пара."))
		playsound(user, 'sound/items/tools/welder.ogg', 50, TRUE)
		. = TRUE

	if(space_invader)
		punish_with_acid(user, space_invader)
		. = TRUE
	return .

/// Spawn green acid puddle underneath obj, used for callback
/datum/action/changeling/biodegrade/proc/make_puddle(obj/melted_restraint)
	if (melted_restraint) // incase obj gets qdel'd
		return new /obj/effect/decal/cleanable/greenglow(get_turf(melted_restraint))

/datum/action/changeling/biodegrade/proc/acid_blast(atom/movable/user, atom/movable/target)
	var/datum/reagents/ephemeral_acid = new
	ephemeral_acid.add_reagent(bio_acid_path, bio_acid_amount_per_spray)
	var/mutable_appearance/splash_animation = mutable_appearance('icons/effects/effects.dmi', "splash")
	splash_animation.color = bio_acid_color
	target.flick_overlay_view(splash_animation, 3 SECONDS)
	ephemeral_acid.expose(target, TOUCH)

/datum/action/changeling/biodegrade/proc/punish_with_acid(mob/living/carbon/human/user, mob/living/hapless_manhandler)
	acid_blast(user, hapless_manhandler)
	playsound(user, 'sound/mobs/non-humanoids/bileworm/bileworm_spit.ogg', 50, TRUE)
	if(IS_CHANGELING(hapless_manhandler))
		user.visible_message(
			span_danger("[user.declent_ru(NOMINATIVE)] извергает струю шипящей кислоты на [hapless_manhandler.declent_ru(ACCUSATIVE)]... но ничего не произошло!"),
			span_changeling("Мы готовим наш побег, распыляя био-кислоту на нашего похитителя... [span_danger("Но ничего не произошло?!")]"),
			span_danger("Вы слышите рвотный позыв, затем шипение, которое довольно резко прекращается.")
			)
		to_chat(hapless_manhandler, span_changeling("Наша добыча пытается отпугнуть нас одной из простейших адаптаций нашей же биологии. Забавно."))
		return
	user.visible_message(
		span_danger("[user.declent_ru(NOMINATIVE)] извергает струю шипящей кислоты на [hapless_manhandler.declent_ru(ACCUSATIVE)], используя возможность вырваться."),
		user.balloon_alert(user, "отпугиваем похитителя..."),
		span_danger("Вы слышите рвотный позыв, затем шипение, быстро заглушаемое громким стоном боли."))
	hapless_manhandler.Stun(2 SECONDS)
	hapless_manhandler.emote("scream")
	hapless_manhandler.stop_pulling()
	log_combat(user = user, target = hapless_manhandler, what_done = "acid-spewed to escape a grab", addition = "(biodegrade)")
