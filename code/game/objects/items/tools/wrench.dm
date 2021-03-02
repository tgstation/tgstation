/obj/item/wrench
	name = "wrench"
	desc = "A wrench with common uses. Can be found in your hand."
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	worn_icon_state = "wrench"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	custom_materials = list(/datum/material/iron=150)
	drop_sound = 'sound/items/handling/wrench_drop.ogg'
	pickup_sound =  'sound/items/handling/wrench_pickup.ogg'

	attack_verb_continuous = list("bashes", "batters", "bludgeons", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "whack")
	tool_behaviour = TOOL_WRENCH
	toolspeed = 1
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30)

/obj/item/wrench/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beating [user.p_them()]self to death with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/genhit.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1


/obj/item/wrench/medical
	name = "medical wrench"
	desc = "A medical wrench with common(medical?) uses. Can be found in your hand."
	icon_state = "wrench_medical"
	force = 2 //MEDICAL
	throwforce = 4
	attack_verb_continuous = list("heals", "medicals", "taps", "pokes", "analyzes") //"cobbyed"
	attack_verb_simple = list("heal", "medical", "tap", "poke", "analyze")
	///var to hold the name of the person who suicided
	var/suicider

/obj/item/wrench/medical/examine(mob/user)
	. = ..()
	if(suicider)
		. += "<span class='notice'>For some reason, it reminds you of [suicider].</span>"

/obj/item/wrench/medical/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is praying to the medical wrench to take [user.p_their()] soul. It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.Stun(100, ignore_canstun = TRUE)// Stun stops them from wandering off
	user.set_light_color(COLOR_VERY_SOFT_YELLOW)
	user.set_light(2)
	user.add_overlay(mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER))
	playsound(loc, 'sound/effects/pray.ogg', 50, TRUE, -1)

	// Let the sound effect finish playing
	add_fingerprint(user)
	sleep(20)
	if(!user)
		return
	for(var/obj/item/W in user)
		user.dropItemToGround(W)
	suicider = user.real_name
	user.dust()
	return OXYLOSS

/obj/item/wrench/cyborg
	name = "hydraulic wrench"
	desc = "An advanced robotic wrench, powered by internal hydraulics. Twice as fast as the handheld version."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "wrench_cyborg"
	toolspeed = 0.5

/obj/item/wrench/combat
	name = "combat wrench"
	desc = "It's like a normal wrench but edgier. Can be found on the battlefield."
	icon_state = "wrench_combat"
	inhand_icon_state = "wrench_combat"
	attack_verb_continuous = list("devastates", "brutalizes", "commits a war crime against", "obliterates", "humiliates")
	attack_verb_simple = list("devastate", "brutalize", "commit a war crime against", "obliterate", "humiliate")
	tool_behaviour = null
	toolspeed = null
	var/on = FALSE

/obj/item/wrench/combat/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/wrench/combat/attack_self(mob/living/user)
	if(on)
		on = FALSE
		force = initial(force)
		w_class = initial(w_class)
		throwforce = initial(throwforce)
		tool_behaviour = initial(tool_behaviour)
		toolspeed = initial(toolspeed)
		playsound(user, 'sound/weapons/saberoff.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] can now be kept at bay.</span>")
	else
		on = TRUE
		force = 6
		w_class = WEIGHT_CLASS_NORMAL
		throwforce = 8
		tool_behaviour = TOOL_WRENCH
		toolspeed = 1
		playsound(user, 'sound/weapons/saberon.ogg', 5, TRUE)
		to_chat(user, "<span class='warning'>[src] is now active. Woe onto your enemies!</span>")
	update_appearance()

/obj/item/wrench/combat/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]_on"
		inhand_icon_state = "[initial(inhand_icon_state)]1"
	else
		icon_state = "[initial(icon_state)]"
		inhand_icon_state = "[initial(inhand_icon_state)]"
	return ..()
