//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/mimic
	response_help = "touches"
	response_disarm = "pushes"
	response_harm = "hits"
	speed = -1
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

	var/atom/copied_object = /obj/structure/closet/crate
	var/angry = 0

/mob/living/simple_animal/hostile/mimic/New()
	.=..()
	if(ispath(copied_object))
		appearance = initial(copied_object.appearance)

/mob/living/simple_animal/hostile/mimic/Die()
	..()
	visible_message("<span class='warning'><b>[src]</b> stops moving!</span>")
	qdel(src)

/mob/living/simple_animal/hostile/mimic/show_inv() //Makes it harder to distinguish mimics from real dudes
	return

//
// Crate mimic
//
// Sits still until somebody tries to open it!

/mob/living/simple_animal/hostile/mimic/crate
	a_intent = I_HURT //To prevent dudes from swapping positions with us

	maxHealth = 100
	health = 100

/mob/living/simple_animal/hostile/mimic/crate/New()
	..()

	drop_meat(src) //Fill the mimic up with its own meat
	initialize() //Collect all items from its turf!

/mob/living/simple_animal/hostile/mimic/crate/Life()
	if(!angry) return

	.=..()

/mob/living/simple_animal/hostile/mimic/crate/Destroy()
	..()

	Die()

/mob/living/simple_animal/hostile/mimic/crate/initialize()
	..()
	//Put all loot inside us!
	for(var/obj/item/I in loc)
		if(I.anchored || I.density) continue

		I.forceMove(src)

/mob/living/simple_animal/hostile/mimic/crate/Die()
	if(copied_object)
		var/obj/structure/C = new copied_object(get_turf(src))
		//Drop all loot!
		for(var/atom/movable/AM in src)
			AM.loc = C
	..()

/mob/living/simple_animal/hostile/mimic/crate/attackby(obj/W, mob/user)
	if(angry) //If we're angry - proceed as normal
		return ..()
	else
		return attack_hand(user) //If we're hidden - attempt to open (same as a normal crate)

/mob/living/simple_animal/hostile/mimic/crate/attack_hand(mob/user)
	if(angry)
		return ..()

	user << "<span class='notice'>It won't budge.</span>"

	spawn(rand(1,20))
		visible_message("<span class='warning'>\The [src] starts moving!</span>")
		anger()

/mob/living/simple_animal/hostile/mimic/crate/LoseTarget()
	..()
	calm_down()

/mob/living/simple_animal/hostile/mimic/crate/LostTarget()
	..()
	calm_down()

/mob/living/simple_animal/hostile/mimic/crate/proc/anger(berserk = 0, change_icon = 1)
	angry = 1
	if(change_icon)
		icon_state = "[initial(icon_state)]open"

	if(berserk)
		angry = 2 //Can't calm down
		melee_damage_lower = initial(melee_damage_lower) + 4
		melee_damage_upper = initial(melee_damage_upper) + 4 //Increase damage
		move_to_delay = 0 //Remove delay for automated movement
		name = "[initial(name)] mimic"

/mob/living/simple_animal/hostile/mimic/crate/proc/calm_down(change_icon = 1)
	if(angry > 1) return //If angry is 2, can't calm down!

	angry = 0
	if(change_icon)
		icon_state = initial(icon_state)

	health = maxHealth //Fully heal. Wow

/mob/living/simple_animal/hostile/mimic/crate/hitby() //This is called when the mimic is hit by a thrown object
	..()

	if(!angry)
		anger(berserk = 1) //Go berserk because some asshole tried to snipe us
		visible_message("<span class='danger'>\The [src] roars in rage!</span>")

/mob/living/simple_animal/hostile/mimic/crate/bullet_act(obj/item/projectile/P, def_zone)
	..()

	if(P.damage > 0) //The projectile isn't a dummy
		if(!angry)
			anger(berserk = 1)
			visible_message("<span class='danger'>\The [src] roars in rage!</span>")

// Chest mimic - more robust than crate mimic
// Does more damage, has a robust tongue that it uses to grab things
// When attacking, it GRABS a dude and eats him

/mob/living/simple_animal/hostile/mimic/crate/chest
	name = "chest"
	copied_object = /obj/structure/closet/crate/chest

	melee_damage_lower = 12
	melee_damage_upper = 16

	maxHealth = 140
	health = 140

	stat_attack = 1 //Attack unconscious dudes

	icon_state = "chest"

	maxbodytemp = AUTOIGNITION_WOOD //The chest is wooden

/mob/living/simple_animal/hostile/mimic/crate/chest/Die()
	for(var/atom/A in locked_atoms)
		unlock_atom(A)
		visible_message("<span class='notice'>\The [src] lets go of \the [A]!</span>")
	..()

/mob/living/simple_animal/hostile/mimic/crate/chest/AttackingTarget()
	..()
	if(istype(target, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(!locked_atoms.len) //Eating nobody
			if(prob(60))
				lock_atom(H)
				visible_message("<span class='danger'>\The [src] grabs \the [H]!")
		else
			if(H in locked_atoms)
				if(prob(20))
					H << "<span class='danger'>You feel very weak!</span>"
					H.Weaken(3)

/mob/living/simple_animal/hostile/mimic/crate/chest/LoseTarget()
	if(target in locked_atoms)
		unlock_atom(target)

	var/mob/living/L = target
	if(istype(L) && Adjacent(L)) //If we're near our ex-target!
		if(L.stat == DEAD) //The target is dead (which what caused us to lose it in the first place)
			L.forceMove(src)
			visible_message("<span class='danger'>\The [src] eats \the [L]'s corpse!</span>")

	return ..()

/mob/living/simple_animal/hostile/mimic/crate/chest/relaymove(mob/user)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		return

	if(user.loc == src) //We're inside the chest
		user << "<span class='info'>You try to escape from \the [src]. This will take a while!</span>"
		if(do_after(user, src, 300)) //30 seconds
			user << "<span class='info'>You successfully escape from \the [src].</span>"
			user.forceMove(get_turf(src))
	else //We're being held by the mimic
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if((M_HULK in H.mutations) || (M_STRONG in H.mutations)) //Finally a use for M_STRONG
				unlock_atom(H)
				visible_message("<span class='notice'>[H] easily breaks free of \the [src]'s hold!</span>")
				return

/mob/living/simple_animal/hostile/mimic/crate/chest/attackby(obj/item/W, mob/user)
	if(angry)
		if(locked_atoms.len)
			if(W.is_sharp())
				user.visible_message("<span class='danger'>[user] slashes at \the [src]'s tongue!</span>")

				for(var/atom/M in locked_atoms)
					unlock_atom(M)
					visible_message("<span class='notice'>\The [src] loses its hold on [M].</span>")
	..()

/mob/living/simple_animal/hostile/mimic/crate/chest/anger(berserk, change_icon = 1)
	..()

	icon_state = "chestmimic"

//
// Item mimic
//
// Lies still until somebody tries to pick it up

var/global/list/allowed_itemmimic_appearances = list(
	/obj/item/alien_embryo,
	/obj/item/ammo_storage,
	/obj/item/asteroid/goliath_hide,
	/obj/item/blueprints,
	/obj/item/device/chameleon,
	/obj/item/toy/minimeteor,
	/obj/item/toy/crossbow,
	/obj/item/toy/spinningtoy,
	/obj/item/toy/waterflower,
	/obj/item/trash/discountchocolate,
	/obj/item/trash/tray,
	/obj/item/weapon/banhammer/admin, //hunk
	/obj/item/weapon/barricade_kit,
	/obj/item/weapon/batteringram,
	/obj/item/weapon/beach_ball,
	/obj/item/weapon/bonesetter,
	/obj/item/weapon/card/emag,
	/obj/item/weapon/caution,
	/obj/item/weapon/circular_saw,
	/obj/item/weapon/crossbow,
	/obj/item/weapon/extinguisher,
	/obj/item/weapon/fireaxe,
	/obj/item/weapon/gun/gatling,
	/obj/item/weapon/gun/hookshot,
	/obj/item/weapon/gun/projectile/deagle,
	/obj/item/weapon/gun/projectile/shotgun/doublebarrel,
	/obj/item/weapon/gun/stickybomb,
	/obj/item/weapon/gun/syringe/rapidsyringe,
	/obj/item/weapon/hand_labeler,
	/obj/item/weapon/katana/hfrequency,
	/obj/item/weapon/melee/baton,
	/obj/item/weapon/melee/defibrillator,
	/obj/item/weapon/pinpointer,
	/obj/item/weapon/soap,
	/obj/item/weapon/spellbook,
	/obj/item/weapon/surgicaldrill,
	/obj/item/weapon/table_parts,
	/obj/item/weapon/tome,
	/obj/item/weapon/wrench/socket
	)

/mob/living/simple_animal/hostile/mimic/crate/item
	name = "item mimic"
	density = 0

	move_to_delay = 2 //Faster than crate mimics
	maxHealth = 80
	health = 80 //Slightly less robust

	var/icon/mouth_overlay = icon('icons/mob/mob.dmi', icon_state = "mimic_mouth")

/mob/living/simple_animal/hostile/mimic/crate/item/New()
	copied_object = pick(allowed_itemmimic_appearances)
	..()

/mob/living/simple_animal/hostile/mimic/crate/item/initialize()
	return //Don't take any items!

/mob/living/simple_animal/hostile/mimic/crate/item/Crossed(atom/movable/AM)
	if(ishuman(AM))
		anger()
	..()

/mob/living/simple_animal/hostile/mimic/crate/item/examine(mob/user) //Total override to make the mimics look EXACTLY like items!
	var/s_size
	switch(src.size)
		if(1.0)
			s_size = "tiny"
		if(2.0)
			s_size = "small"
		if(3.0)
			s_size = "normal-sized"
		if(4.0)
			s_size = "bulky"
		if(5.0)
			s_size = "huge"
		else
	//if ((M_CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"
	var/pronoun
	if (src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"

	user << "\icon[src] That's \a [src]. [pronoun] a [s_size] item."
	if(desc)
		user << desc

/mob/living/simple_animal/hostile/mimic/crate/item/Die()
	copied_object = meat_type //Without this line, mimics would spawn items they're disguised as. Since they're relatively weak and can appear as gatling guns, this is required!
	..()

/mob/living/simple_animal/hostile/mimic/crate/item/attack_hand(mob/user)
	if(angry)
		return ..()

	user.simple_message("<span class='warning'>Oh no! \The [src] is actually a mimic!</span>",\
		"<span class='info'>\The [src] starts moving. Wow.</span>") //Second line is for hallucinating dudes
	anger()

/mob/living/simple_animal/hostile/mimic/crate/item/anger(berserk)
	..(berserk, change_icon = 0) //Don't change icon state
	overlays += mouth_overlay
	visible_message("<span class='danger'>\The [src] comes to life!</span>")
	name = "[initial(copied_object.name)] mimic"
	density = 1

/mob/living/simple_animal/hostile/mimic/crate/item/calm_down()
	..(change_icon = 0)
	overlays -= mouth_overlay
	visible_message("<span class='notice'>\The [src] falls to the ground, lifeless.</span>")
	density = 0

	//Disguise as something else for bonus stealth points
	copied_object = pick(allowed_itemmimic_appearances)
	appearance = initial(copied_object.appearance)

	var/obj/item/I = copied_object
	size = initial(I.w_class)

//
// Copy Mimic
//

var/global/list/protected_objects = list(
	/obj/structure/table,
	/obj/structure/cable,
	/obj/structure/window,
	/obj/structure/particle_accelerator // /vg/ Redmine #116
)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100

	copied_object = null
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0
	var/time_to_die=0 // The world.time after which we expire. (0 = no time limit)

/mob/living/simple_animal/hostile/mimic/copy/New(loc, var/obj/copy, var/mob/living/creator, var/destroy_original = 0, var/duration=0)
	..(loc)
	CopyObject(copy, creator, destroy_original)
	if(duration)
		time_to_die=world.time+duration

/mob/living/simple_animal/hostile/mimic/copy/Life()
	if(timestopped) return 0 //under effects of time magick
	..()
	// Die after a specified time limit
	if(time_to_die && world.time >= time_to_die)
		Die()
		return
	for(var/mob/living/M in contents) //a fix for animated statues from the flesh to stone spell
		Die()
		return

/mob/living/simple_animal/hostile/mimic/copy/Die()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner(var/mob/owner)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/simple_animal/hostile/mimic/copy/proc/ChangeOwner() called tick#: [world.time]")
	if(owner != creator)
		LoseTarget()
		creator = owner
		faction = "\ref[owner]"

/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject(var/obj/O)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/simple_animal/hostile/mimic/copy/proc/CheckObject() called tick#: [world.time]")
	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))
		return 1
	return 0

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(var/obj/O, var/mob/living/creator, var/destroy_original = 0)

	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject() called tick#: [world.time]")

	if(destroy_original || CheckObject(O))

		O.loc = src

		src.appearance = O.appearance
		src.icon_living = src.icon_state

		if(istype(O, /obj/structure) || istype(O, /obj/machinery))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(istype(O, /obj/item))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class

		maxHealth = health
		if(creator)
			src.creator = creator
			faction = "\ref[creator]" // very unique
		if(destroy_original)
			qdel(O)
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. =..()
	if(knockdown_people)
		var/mob/living/L = .
		if(istype(L))
			if(prob(15))
				L.Weaken(1)
				L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")