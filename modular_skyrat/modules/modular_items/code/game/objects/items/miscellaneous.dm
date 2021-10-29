/obj/item/hammer/makeshift
	name = "makeshift hammer"
	desc = "A makeshift hammer, flimsily constructed with miscellaneous parts."
	icon = 'modular_skyrat/modules/modular_items/icons/obj/items/tools.dmi'
	icon_state = "makeshift_hammer"
	force = 2
	throwforce = 3
	w_class = WEIGHT_CLASS_NORMAL

//loot
/obj/item/bloodcrawlbottle
	name = "bloodlust in a bottle"
	desc = "Drinking this will give you unimaginable powers... and mildly disgust you because of it's metallic taste."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/bloodcrawlbottle/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You drink the bottle's contents.</span>")
	var/obj/effect/proc_holder/spell/bloodcrawl/S = new()
	user.mind.AddSpell(S)
	user.log_message("learned the spell bloodcrawl ([S])", LOG_ATTACK, color="orange")
	qdel(src)

/obj/effect/proc_holder/spell/bloodcrawl/lesser
	name = "Lesser Blood Crawl"
	desc = "Use pools of blood to phase out of existence. Requires large pools of blood, and a lot of your blood."

/obj/effect/proc_holder/spell/bloodcrawl/lesser/choose_targets(mob/user = usr)
	for(var/obj/effect/decal/cleanable/target in range(range, get_turf(user)))
		if(target.can_bloodcrawl_in() && target.bloodiness >= 20)
			perform(target)
			return
	revert_cast()
	to_chat(user, "<span class='warning'>There must be a nearby source of plentiful blood!</span>")

/obj/effect/proc_holder/spell/bloodcrawl/lesser/perform(obj/effect/decal/cleanable/target, recharge = 1, mob/living/user = usr)
	if(istype(user) && user.canUseTopic(user, TRUE))
		if(phased)
			if(user.phasein(target))
				phased = FALSE
		else
			if(user.phaseout(target))
				phased = TRUE
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.blood_volume -= 150
		start_recharge()
		return
	revert_cast()
	to_chat(user, "<span class='warning'>You are unable to blood crawl!</span>")

/obj/item/storage/box/hero/ronin
    name = "Sword Saint, Wandering Vagabond - 1600's."
    desc = "Anyone can give up, it's the easiest thing in the world to do. But to hold it together when everyone else would understand if you fell apart, that's true strength. Become the wandering swordsman you were always meant to be!"

/obj/item/storage/box/hero/ronin/PopulateContents()
    new /obj/item/clothing/under/costume/kamishimo(src)
    new /obj/item/clothing/head/rice_hat(src)
    new /obj/item/katana/weak/curator(src)
    new /obj/item/clothing/shoes/sandal(src)
