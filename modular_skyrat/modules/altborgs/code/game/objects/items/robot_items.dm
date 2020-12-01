/obj/item/dogborg_tongue
	name = "synthetic tongue"
	desc = "Useful for slurping mess off the floor before affectionally licking the crew members in the face."
	icon = 'modular_skyrat/modules/altborgs/icons/mob/robot_items.dmi'
	icon_state = "synthtongue"
	hitsound = 'sound/effects/attackblob.ogg'
	desc = "For giving affectionate kisses."
	item_flags = NOBLUDGEON

/obj/item/dogborg_tongue/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity || !isliving(target))
		return
	var/mob/living/silicon/robot/R = user
	var/mob/living/L = target

	if(check_zone(R.zone_selected) == "head")
		R.visible_message("<span class='warning'>\the [R] affectionally licks \the [L]'s face!</span>", "<span class='notice'>You affectionally lick \the [L]'s face!</span>")
		playsound(R, 'sound/effects/attackblob.ogg', 50, 1)
	else
		R.visible_message("<span class='warning'>\the [R] affectionally licks \the [L]!</span>", "<span class='notice'>You affectionally lick \the [L]!</span>")
		playsound(R, 'sound/effects/attackblob.ogg', 50, 1)

/obj/item/dogborg_nose
	name = "boop module"
	desc = "The BOOP module"
	icon = 'modular_skyrat/modules/altborgs/icons/mob/robot_items.dmi'
	icon_state = "nose"
	flags_1 = CONDUCT_1|NOBLUDGEON
	force = 0

/obj/item/dogborg_nose/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	do_attack_animation(target, null, src)
	user.visible_message("<span class='notice'>[user] [pick("nuzzles", "pushes", "boops")] \the [target.name] with their nose!</span>")
