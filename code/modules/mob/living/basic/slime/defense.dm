
/mob/living/basic/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!


/mob/living/basic/slime/attack_hand(mob/living/carbon/human/user, list/modifiers)
	user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
	if(buckled)
		if(buckled == user ? prob(60) : prob(30)) //its easier to remove the slime from yourself
			user.visible_message(span_warning("[user] attempts to wrestle \the [name] off [buckled == user ? "" : buckled] !"), \
			span_danger("[buckled == user ? "You attempt" : (user + " attempts") ] to wrestle \the [name] off [buckled == user ? "" : buckled]!"))
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			return

		user.visible_message(span_warning("[user] manages to wrestle \the [name] off!"), span_notice("You manage to wrestle \the [name] off!"))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		//discipline_slime
		return
	return ..()

/mob/living/basic/slime/attackby(obj/item/attacking_item, mob/living/user, params)

 	//Lets you feed slimes plasma. Checks before the passthrough force check
	if(istype(attacking_item, /obj/item/stack/sheet/mineral/plasma) && !stat)
		befriend(user)
		to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
		var/obj/item/stack/sheet/mineral/plasma/sheet = attacking_item
		sheet.use(1)
		return

	//Checks if the item passes through the slime first. Safe items can be used simply
	if(attacking_item.force > 0)
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_danger("[attacking_item] passes right through [src]!"))
			return

//SLIMETODO: do we keep this? Move it to an ondamage component?
/*	if(attacking_item.force >= 3)
		var/force_effect =  attacking_item.force * (life_stage == SLIME_LIFE_STAGE_BABY ? 2 : 1)
		if(prob(10 + force_effect))
			discipline_slime(user) */

	if(!istype(attacking_item, /obj/item/storage/bag/xeno))
		return ..()

	var/obj/item/storage/xeno_bag = attacking_item
	if(!crossbreed_modification)
		to_chat(user, span_warning("The slime is not currently being mutated."))
		return
	var/has_output = FALSE //Have we outputted text?
	var/has_found = FALSE //Have we found an extract to be added?
	for(var/obj/item/slime_extract/extract in xeno_bag.contents)
		if(extract.crossbreed_modification == crossbreed_modification)
			xeno_bag.atom_storage.attempt_remove(extract, get_turf(src), silent = TRUE)
			qdel(extract)
			applied_crossbreed_amount++
			has_found = TRUE
		if(applied_crossbreed_amount >= SLIME_EXTRACT_CROSSING_REQUIRED)
			to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
			playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
			spawn_corecross()
			has_output = TRUE
			break

	if(has_output)
		return

	if(!has_found)
		to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
	else
		to_chat(user, span_notice("You feed the slime some extracts from the bag."))
		playsound(src, 'sound/effects/attackblob.ogg', 50, TRUE)
	return

