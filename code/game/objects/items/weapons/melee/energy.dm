<<<<<<< HEAD
/obj/item/weapon/melee/energy
	var/active = 0
	var/force_on = 30 //force when active
	var/throwforce_on = 20
	var/icon_state_on = "axe1"
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	w_class = 2
	var/w_class_on = 4
	heat = 3500

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting \his stomach open with [src]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='suicide'>[user] is falling on [src]! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/add_blood(list/blood_dna)
	return 0

/obj/item/weapon/melee/energy/is_sharp()
	return active * sharpness

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40
	force_on = 150
	throwforce = 25
	throwforce_on = 30
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 5
	w_class = 3
	w_class_on = 5
	flags = CONDUCT
	armour_penetration = 100
	origin_tech = "combat=4;magnets=3"
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	attack_verb_on = list()

/obj/item/weapon/melee/energy/axe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] swings the [src.name] towards \his head! It looks like \he's trying to commit suicide.</span>")
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	force = 3
	throwforce = 5
	hitsound = "swing_hit" //it starts deactivated
	throw_speed = 3
	throw_range = 5
	sharpness = IS_SHARP
	embed_chance = 75
	embedded_impact_pain_multiplier = 10
	armour_penetration = 35
	origin_tech = "combat=3;magnets=4;syndicate=4"
	block_chance = 50
	var/hacked = 0

/obj/item/weapon/melee/energy/sword/New()
	if(item_color == null)
		item_color = pick("red", "blue", "green", "purple")

/obj/item/weapon/melee/energy/sword/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/melee/energy/sword/process()
	if(active)
		open_flame()
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/melee/energy/sword/hit_reaction(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(active)
		return ..()
	return 0

/obj/item/weapon/melee/energy/attack_self(mob/living/carbon/user)
	if(user.disabilities & CLUMSY && prob(50))
		user << "<span class='warning'>You accidentally cut yourself with [src], like a doofus!</span>"
		user.take_organ_damage(5,5)
	active = !active
	if (active)
		force = force_on
		throwforce = throwforce_on
		hitsound = 'sound/weapons/blade1.ogg'
		throw_speed = 4
		if(attack_verb_on.len)
			attack_verb = attack_verb_on
		if(!item_color)
			icon_state = icon_state_on
		else
			icon_state = "sword[item_color]"
		w_class = w_class_on
		playsound(user, 'sound/weapons/saberon.ogg', 35, 1) //changed it from 50% volume to 35% because deafness
		user << "<span class='notice'>[src] is now active.</span>"
		START_PROCESSING(SSobj, src)
	else
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		throw_speed = initial(throw_speed)
		if(attack_verb_on.len)
			attack_verb = list()
		icon_state = initial(icon_state)
		w_class = initial(w_class)
		playsound(user, 'sound/weapons/saberoff.ogg', 35, 1)  //changed it from 50% volume to 35% because deafness
		user << "<span class='notice'>[src] can now be concealed.</span>"
		STOP_PROCESSING(SSobj, src)
	add_fingerprint(user)

/obj/item/weapon/melee/energy/is_hot()
	return active * heat

/obj/item/weapon/melee/energy/ignition_effect(atom/A, mob/user)
	if(!active)
		return ""

	var/in_mouth = ""
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.wear_mask == src)
			in_mouth = ", barely missing their nose"
	. = "<span class='warning'>[user] swings their \
		[src][in_mouth]. They light [A] in the process.</span>"
	playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	add_fingerprint(user)

/obj/item/weapon/melee/energy/sword/cyborg
	var/hitcost = 50

/obj/item/weapon/melee/energy/sword/cyborg/attack(mob/M, var/mob/living/silicon/robot/R)
	if(R.cell)
		var/obj/item/weapon/stock_parts/cell/C = R.cell
		if(active && !(C.use(hitcost)))
			attack_self(R)
			R << "<span class='notice'>It's out of charge!</span>"
			return
		..()
	return

/obj/item/weapon/melee/energy/sword/cyborg/saw //Used by medical Syndicate cyborgs
	name = "energy saw"
	desc = "For heavy duty cutting. It has a carbon-fiber blade in addition to a toggleable hard-light edge to dramatically increase sharpness."
	icon_state = "esaw"
	force_on = 30
	force = 18 //About as much as a spear
	hitsound = 'sound/weapons/circsawhit.ogg'
	icon = 'icons/obj/surgery.dmi'
	icon_state = "esaw_0"
	icon_state_on = "esaw_1"
	hitcost = 75 //Costs more than a standard cyborg esword
	item_color = null
	w_class = 3
	sharpness = IS_SHARP

/obj/item/weapon/melee/energy/sword/cyborg/saw/New()
	..()
	icon_state = "esaw_0"
	item_color = null

/obj/item/weapon/melee/energy/sword/cyborg/saw/hit_reaction()
	return 0

/obj/item/weapon/melee/energy/sword/saber

/obj/item/weapon/melee/energy/sword/saber/blue
	item_color = "blue"

/obj/item/weapon/melee/energy/sword/saber/purple
	item_color = "purple"

/obj/item/weapon/melee/energy/sword/saber/green
	item_color = "green"

/obj/item/weapon/melee/energy/sword/saber/red
	item_color = "red"

/obj/item/weapon/melee/energy/sword/saber/attackby(obj/item/weapon/W, mob/living/user, params)
	if(istype(W, /obj/item/weapon/melee/energy/sword/saber))
		user << "<span class='notice'>You attach the ends of the two \
			energy swords, making a single double-bladed weapon! \
			You're cool.</span>"
		var/obj/item/weapon/melee/energy/sword/saber/other_esword = W
		var/obj/item/weapon/twohanded/dualsaber/newSaber = new(user.loc)
		if(hacked || other_esword.hacked)
			newSaber.hacked = TRUE
			newSaber.item_color = "rainbow"
		user.unEquip(W)
		user.unEquip(src)
		qdel(W)
		qdel(src)
		user.put_in_hands(newSaber)
	else if(istype(W, /obj/item/device/multitool))
		if(hacked == 0)
			hacked = 1
			item_color = "rainbow"
			user << "<span class='warning'>RNBW_ENGAGE</span>"

			if(active)
				icon_state = "swordrainbow"
				// Updating overlays, copied from welder code.
				// I tried calling attack_self twice, which looked cool, except it somehow didn't update the overlays!!
				if(user.r_hand == src)
					user.update_inv_r_hand(0)
				else if(user.l_hand == src)
					user.update_inv_l_hand(0)
		else
			user << "<span class='warning'>It's already fabulous!</span>"
	else
		return ..()

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	icon_state_on = "cutlass1"

/obj/item/weapon/melee/energy/sword/pirate/New()
	return

/obj/item/weapon/melee/energy/blade
	name = "energy blade"
	desc = "A concentrated beam of energy in the shape of a blade. Very stylish... and lethal."
	icon_state = "blade"
	force = 30	//Normal attacks deal esword damage
	hitsound = 'sound/weapons/blade1.ogg'
	active = 1
	throwforce = 1//Throwing or dropping the item deletes it.
	throw_speed = 3
	throw_range = 1
	w_class = 4//So you can't hide it in your pocket or some such.
	var/datum/effect_system/spark_spread/spark_system

//Most of the other special functions are handled in their own files. aka special snowflake code so kewl
/obj/item/weapon/melee/energy/blade/New()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/weapon/melee/energy/blade/dropped()
	..()
	qdel(src)

/obj/item/weapon/melee/energy/blade/attack_self(mob/user)
	return
=======
/obj/item/weapon/melee/energy
	var/active = 0
	sharpness = 1.5 //very very sharp
	heat_production = 3500

/obj/item/weapon/melee/energy/suicide_act(mob/user)
	to_chat(viewers(user), pick("<span class='danger'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>", \
						"<span class='danger'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/is_hot()
	if(active)
		return heat_production
	return 0

/obj/item/weapon/melee/energy/is_sharp()
	if(active)
		return sharpness
	return 0

/obj/item/weapon/melee/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40.0
	throwforce = 25.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = "combat=3"
	attack_verb = list("attacks", "chops", "cleaves", "tears", "cuts")


	suicide_act(mob/user)
		to_chat(viewers(user), "<span class='danger'>[user] swings the [src.name] towards /his head! It looks like \he's trying to commit suicide.</span>")
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/melee/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword0"
	var/base_state = "sword"
	var/active_state = ""
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")


/obj/item/weapon/melee/energy/sword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/New()
	..()
	_color = pick("red","blue","green","purple")
	if(!active_state)
		active_state = base_state + _color
	update_icon()

/obj/item/weapon/melee/energy/sword/attack_self(mob/living/user as mob)
	if ((M_CLUMSY in user.mutations) && prob(50) && active) //only an on blade can cut
		to_chat(user, "<span class='danger'>You accidentally cut yourself with [src].</span>")
		user.take_organ_damage(5,5)
		return
	toggleActive(user)
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/sword/proc/toggleActive(mob/user, var/togglestate = "") //you can use togglestate to manually set the sword on or off
	switch(togglestate)
		if("on")
			active = 1
		if("off")
			active = 0
		else
			active = !active
	if (active)
		force = 30
		w_class = W_CLASS_LARGE
		sharpness = 1.5
		hitsound = "sound/weapons/blade1.ogg"
		playsound(user, 'sound/weapons/saberon.ogg', 50, 1)
		to_chat(user, "<span class='notice'> [src] is now active.</span>")
	else
		force = 3
		w_class = W_CLASS_SMALL
		sharpness = 0
		playsound(user, 'sound/weapons/saberoff.ogg', 50, 1)
		hitsound = "sound/weapons/empty.ogg"
		to_chat(user, "<span class='notice'> [src] can now be concealed.</span>")
	update_icon()

/obj/item/weapon/melee/energy/sword/update_icon()
	if(active && _color)
		icon_state = active_state
	else
		icon_state = "[base_state][active]"

/obj/item/weapon/melee/energy/sword/attackby(obj/item/weapon/W, mob/living/user)
	..()
	if(istype(W, /obj/item/weapon/melee/energy/sword))
		to_chat(user, "<span class='notice'>You attach the ends of the two energy swords, making a single double-bladed weapon! You're cool.</span>")
		new /obj/item/weapon/dualsaber(user.loc)
		qdel(W)
		W = null
		qdel(src)


/obj/item/weapon/melee/energy/sword/bsword
	name = "banana"
	desc = "It's yellow."
	base_state = "bsword0"
	active_state = "bsword1"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	flags = FPRINT
	origin_tech = "magnets=3;syndicate=4"
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")


/obj/item/weapon/melee/energy/sword/bsword/IsShield()
	if(active)
		return 1
	return 0

/obj/item/weapon/melee/energy/sword/bsword/attack_self(mob/living/user as mob)
	toggleActive(user)
	add_fingerprint(user)
	return

/obj/item/weapon/melee/energy/sword/bsword/update_icon()
	if(active)
		icon_state = active_state
		name = "energized bananium sword"
		desc = "Advanced technology from a long forgotten clown civilization."
	else
		icon_state = "[base_state]"
		name = "banana"
		desc = "It's yellow."

/obj/item/weapon/melee/energy/sword/bsword/attackby(obj/item/weapon/W, mob/living/user)
	if(istype(W, /obj/item/weapon/melee/energy/sword/bsword))
		to_chat(user, "<span class='notice'>You attach the ends of the two energized bananium swords, making a bushel bruiser! That's dangerous.</span>")
		new /obj/item/weapon/dualsaber/bananabunch(user.loc)
		qdel(W)
		qdel(src)

/obj/item/weapon/melee/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass0"
	base_state = "cutlass"

/obj/item/weapon/melee/energy/sword/pirate/New()
	..()
	_color = null
	update_icon()

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
