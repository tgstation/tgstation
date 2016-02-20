/obj/structure/chair
	name = "chair"
	desc = "You sit in this. Either by will or force.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	anchored = 1
	can_buckle = 1
	buckle_lying = 0 //you sit in a chair, not lay
	burn_state = FIRE_PROOF
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/hold_icon = "chair" // if null it can't be picked up

/obj/structure/chair/New()
	..()
	handle_layer()

/obj/structure/chair/deconstruct()
	if(buildstacktype)
		new buildstacktype(loc,buildstackamount)
	..()

/obj/structure/chair/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/chair/attack_animal(mob/living/simple_animal/M)//No more buckling hostile mobs to chairs to render them immobile forever
	if(M.environment_smash)
		deconstruct()

/obj/structure/chair/Move(atom/newloc, direct)
	..()
	handle_rotation()

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
		E.dir = dir
		E.part = SK
		SK.loc = E
		SK.master = E
		qdel(src)

/obj/structure/chair/attack_tk(mob/user)
	if(buckled_mob)
		..()
	else
		rotate()
	return

/obj/structure/chair/proc/handle_rotation(direction)
	if(buckled_mob)
		buckled_mob.buckled = null //Temporary, so Move() succeeds.
		if(!direction || !buckled_mob.Move(get_step(src, direction), direction))
			buckled_mob.buckled = src
			dir = buckled_mob.dir
			return 0
		buckled_mob.buckled = src //Restoring
	handle_layer()
	return 1

/obj/structure/chair/proc/handle_layer()
	if(dir == NORTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/structure/chair/proc/spin()
	dir = turn(dir, 90)
	handle_layer()
	if(buckled_mob)
		buckled_mob.dir = dir

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
	burn_state = FLAMMABLE
	burntime = 20
	buildstacktype = /obj/item/stack/sheet/mineral/wood
	buildstackamount = 3
	hold_icon = null

/obj/structure/chair/wood/normal
	icon_state = "wooden_chair"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy.\n<span class='notice'>Alt-click to rotate it clockwise.</span>"
	icon_state = "comfychair"
	color = rgb(255,255,255)
	burn_state = FLAMMABLE
	burntime = 30
	buildstackamount = 2
	var/image/armrest = null
	hold_icon = null

/obj/structure/chair/comfy/New()
	armrest = image("icons/obj/chairs.dmi", "comfychair_armrest")
	armrest.layer = MOB_LAYER + 0.1

	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	if(buckled_mob)
		overlays += armrest
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
	hold_icon = null

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
	hold_icon = "stool"

/obj/structure/chair/MouseDrop(over_object, src_location, over_location)
	. = ..()
	if(over_object == usr && Adjacent(usr))
		if(!hold_icon || !ishuman(usr) || buckled_mob)
			return
		usr.visible_message("<span class='notice'>[usr] grabs \the [src.name].</span>", "<span class='notice'>You grab \the [src.name].</span>")
		var/obj/item/chair/C = new /obj/item/chair(get_turf(src),src)
		usr.put_in_hands(C)
		qdel(src)

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	w_class = 5
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50

	var/origin_type = /obj/structure/chair

/obj/item/chair/New(loc,obj/structure/chair/origin)
	..()
	name = origin.name
	icon = origin.icon
	icon_state = "[origin.icon_state]_toppled"
	item_state = origin.hold_icon
	origin_type = origin.type


/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	for(var/obj/A in get_turf(loc))
		if(istype(A,/obj/structure/chair))
			user << "<span class='danger'>There is already a chair here.</span>"
			return
		if(A.density)
			user << "<span class='danger'>There is already something here.</span>"
			return

	user.visible_message("<span class='notice'>[user] rights \the [src.name].</span>", "<span class='notice'>You right \the [name].</span>")
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	C.dir = dir
	qdel(src)

/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message("<span class='danger'>[owner] fends off [attack_text] with [src]!</span>")
		return 1
	return 0