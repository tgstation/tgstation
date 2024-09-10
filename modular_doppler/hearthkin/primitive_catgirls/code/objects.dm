/obj/item/anointing_oil
	name = "anointing bloodresin"
	desc = "And so Helgar Knife-Arm spoke to the Hearth, and decreed that all of the Kin who gave name to beasts would do so with conquest and blood."
	icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/objects.dmi'
	icon_state = "anointingbloodresin"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY

	var/being_used = FALSE

/obj/item/anointing_oil/attack(mob/living/target_mob, mob/living/user, params)
	if (!is_species(user, /datum/species/human/felinid/primitive))
		to_chat(user, span_warning("You have no idea what this disgusting concoction is used for."))
		return
	if(being_used || !ismob(target_mob)) //originally this was going to check if the mob was friendly, but if an icecat wants to name some terror mob while it's tearing chunks out of them, why not?
		return
	if(target_mob.ckey)
		to_chat(user, span_warning("You would never shame a creature so intelligent by not allowing it to choose its own name."))
		return

	if(try_anoint(target_mob, user))
		qdel(src)
	else
		being_used = FALSE

/obj/item/anointing_oil/proc/try_anoint(mob/living/target_mob, mob/living/user)
	being_used = TRUE

	var/new_name = sanitize_name(tgui_input_text(user, "Speak forth this beast's new name for all the Kin to hear.", "Input a name", target_mob.name, MAX_NAME_LEN))

	if(!new_name || QDELETED(src) || QDELETED(target_mob) || new_name == target_mob.name || !target_mob.Adjacent(user))
		being_used = FALSE
		return FALSE

	target_mob.visible_message(span_notice("[user] leans down and smears twinned streaks of glistening bloodresin upon [target_mob], then straightens up with ritual purpose..."))
	user.say("Let the ice know you forevermore as +[new_name]+.")

	user.log_message("used [src] on [target_mob], renaming it to [new_name].", LOG_GAME)

	target_mob.name = new_name

	//give the stupid dog zoomies from getting named
	if(istype(target_mob, /mob/living/basic/mining/wolf))
		target_mob.emote("awoo")
		target_mob.emote("spin")

	return TRUE

/obj/item/anointing_oil/examine(mob/user)
	. = ..()
	if(is_species(user, /datum/species/human/felinid/primitive))
		. += span_info("Using this on the local wildlife will allow you to give them a name.")

/datum/crafting_recipe/anointing_oil
	name = "Anointing Bloodresin"
	category = CAT_MISC
	//recipe given to icecats as part of their spawner/team setting
	crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

	reqs = list(
		/datum/reagent/consumable/liquidgibs = 20,
		/datum/reagent/blood = 20,
	)

	result = /obj/item/anointing_oil

// Hearthkin exclusive object to make their special lungs.
/obj/item/frozen_breath
    name = "Frozen Breath"
    desc = "A strange brew, it smells minty and is extremely cold to the touch. It is rumored that a cold-hearted witch managed to make this, to mend the breath of her kindred."
    icon = 'modular_doppler/hearthkin/primitive_catgirls/icons/objects.dmi'
    icon_state = "frozenbreath"
    throwforce = 0
    w_class = WEIGHT_CLASS_TINY

/obj/item/frozen_breath/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
    if (!is_species(user, /datum/species/human/felinid/primitive))
        to_chat(user, span_warning("You have no idea how to use this freezing concoction."))
        return

    if(istype(interacting_with, /obj/item/organ/internal/lungs))
        var/obj/item/organ/internal/lungs/target_lungs = interacting_with
        if(IS_ROBOTIC_ORGAN(target_lungs))
            user.balloon_alert(user, "The lungs have to be organic!")
            return
        var/location = get_turf(target_lungs)
        playsound(location, 'sound/effects/slosh.ogg', 25, TRUE)
        user.visible_message(span_notice("[user] pours a strange blue liquid over the set of lungs. The flesh starts glistening in a strange cyan light, transforming before your very eyes!"),
            span_notice("Recalling the instructions for the lung transfiguration ritual, you pour the liquid over the flesh of the organ. Soon, the lungs glow in a mute cyan light, before they turn dim and change form before your very eyes!"))
        var/obj/item/organ/internal/lungs/icebox_adapted/new_lungs = new(location)
        new_lungs.damage = target_lungs.damage
        qdel(target_lungs)
        qdel(src)

/obj/item/frozen_breath/examine(mob/user)
    . = ..()
    if(is_species(user, /datum/species/human/felinid/primitive))
        . += span_info("Using this on a pair of organic lungs transforms them into hardy lungs. This will remove any other special features from the old lungs, if there were any.")

/datum/crafting_recipe/frozen_breath
    name = "Frozen Breath"
    category = CAT_MISC
    //recipe given to icecats as part of their spawner/team setting
    crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_MUST_BE_LEARNED

    reqs = list(
        /datum/reagent/consumable/frostoil = 50,
        /datum/reagent/medicine/c2/synthflesh = 50,
    )

    result = /obj/item/frozen_breath
