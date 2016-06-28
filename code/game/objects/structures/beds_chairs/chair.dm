/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force.\n<span class='notice'>Drag your sprite to sit in the chair. Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = 1
	can_buckle = 1
	buckle_lying = 0 //you sit in a chair, not lay
	burn_state = FIRE_PROOF
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up

/obj/structure/chair/New()
	..()
	handle_layer()

/obj/structure/chair/deconstruct()
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(buildstacktype && (!(flags & NODECONSTRUCT)))
		new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/attack_animal(mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		deconstruct()

/obj/structure/chair/ex_act(severity, target)
	switch(severity)
		if(1)
			qdel(src)
			return
		if(2)
			if(prob(70))
				deconstruct()
				return
		if(3)
			if(prob(50))
				deconstruct()
				return

/obj/structure/chair/narsie_act()
	if(prob(20))
		var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/structure/chair/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/wrench) && !(flags&NODECONSTRUCT))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		deconstruct()
	else if(istype(W, /obj/item/assembly/shock_kit))
		if(!user.drop_item())
			return
		var/obj/item/assembly/shock_kit/SK = W
		var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(src.loc)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		E.setDir(dir)
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)
	else
		return ..()

/obj/structure/chair/attack_tk(mob/user)
	if(has_buckled_mobs())
		..()
	else
		rotate()
	return

/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(direction)

/obj/structure/chair/proc/handle_layer()
	if(dir == NORTH)
		layer = ABOVE_ALL_MOB_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/proc/spin()
	setDir(turn(dir, 90))

/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)

/obj/structure/chair/verb/rotate()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	if(config.ghost_interaction)
		spin()
	else
		if(!usr || !isturf(usr.loc))
			return
		if(usr.stat || usr.restrained())
			return
		spin()

/obj/structure/chair/AltClick(mob/user)
	..()
	if(user.incapacitated())
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(!in_range(src, user))
		return
	else
		rotate()

// Chair types
/obj/structure/chair/wood
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	burn_state = FLAMMABLE
	burntime = 20
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	item_chair = /obj/item/chair/wood

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/normal //Kept for map compatibility


/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "comfychair"
	color = rgb(255,255,255)
	burn_state = FLAMMABLE
	burntime = 30
	buildstackamount = 2
	var/image/armrest = null
	item_chair = null

/obj/structure/chair/comfy/New()
	armrest = image("icons/obj/chairs.dmi", "comfychair_armrest")
	armrest.layer = ABOVE_MOB_LAYER

	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		overlays -= armrest


/obj/structure/chair/comfy/brown
	color = rgb(255,113,0)

/obj/structure/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/chair/comfy/teal
	color = rgb(0,255,255)

/obj/structure/chair/comfy/black
	color = rgb(167,164,153)

/obj/structure/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/chair/office
	anchored = 0
	buildstackamount = 5
	item_chair = null

/obj/structure/chair/office/light
	icon_state = "officechair_white"

/obj/structure/chair/office/dark
	icon_state = "officechair_dark"

//Stool

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	can_buckle = 0
	buildstackamount = 1
	item_chair = /obj/item/chair/stool

/obj/structure/chair/stool/narsie_act()
	return

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!item_chair || !ishuman(usr) || has_buckled_mobs() || src.flags & NODECONSTRUCT)
			return
		if(usr.incapacitated())
			usr << "<span class='warning'>You can't do that right now!</span>"
			return
		usr.visible_message("<span class='notice'>[usr] grabs \the [src.name].</span>", "<span class='notice'>You grab \the [src.name].</span>")
		var/C = new item_chair(loc)
		usr.put_in_hands(C)
		qdel(src)

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	item_state = "chair"
	w_class = 5
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair

/obj/item/chair/narsie_act()
	if(prob(20))
		var/obj/item/chair/wood/W = new/obj/item/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	for(var/obj/A in get_turf(loc))
		if(istype(A,/obj/structure/chair))
			user << "<span class='danger'>There is already a chair here.</span>"
			return
		if(A.density && !(A.flags & ON_BORDER))
			user << "<span class='danger'>There is already something here.</span>"
			return

	user.visible_message("<span class='notice'>[user] rights \the [src.name].</span>", "<span class='notice'>You right \the [name].</span>")
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.setDir(dir)
	qdel(src)

/obj/item/chair/proc/smash(mob/living/user)
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically dissapears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	user.unEquip(src,1) //Even NODROP chairs are destroyed.
	qdel(src)




/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>[owner] fends off [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/chair/afterattack(atom/target, mob/living/carbon/user, proximity)
	..()
	if(!proximity)
		return
	if(prob(break_chance))
		user.visible_message("<span class='danger'>[user] smashes \the [src] to pieces against \the [target]</span>")
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			if(C.health < C.maxHealth*0.5)
				C.Weaken(1)
		smash(user)


/obj/item/chair/stool
	name = "stool"
	icon_state = "stool_toppled"
	item_state = "stool"
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	item_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/narsie_act()
	return //sturdy enough to ignore a god

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	item_state = "woodenchair"
	burn_state = FLAMMABLE
	burntime = 20
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	break_chance = 50

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/structure/chair/old
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks REALLY uncomfortable."
	icon_state = "chairold"
	item_chair = null
