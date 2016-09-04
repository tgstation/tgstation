// Living clothing for possible future antag type. Not ripping off Kill la Kill, no siree.
// ~a-t48/Flexicode

// Design todos:
// TODO: figure out progression mechanic. It would be nice to gate abilities behind number of clothes eaten, but that means thinking up of more abilities.
// TODO: figure out goals better

// Work todos:
// Fucking everything
// Work on attachment system
// Make it so that you can hear shit your host can hear
//

////////////////////////////////////////////////////////
// Summary
//
// You are an alien living piece of clothing. Find a host (or start off with one?) rip off theif clothes and transform.
// Your goal is probably to eat other clothing that has been worn. Jumpsuits that people spawn in work, as do clothes worn for longer than 15 minutes.
// You could always ask your target to give up his clothes, but good luck with that. On the other hand, you only need to leave people naked and unconscious, rather than dead.

////////////////////////////////////////////////////////
// Abilities

////////////////////////////////////////////////////////
// Without host:
// 	Vent crawl
//		Nuff said.
//
// 	Able to leap onto a human, tear off their clothes. This also forces a transform the first time you do this to a host.
//
//  Someone can also willingly put you on, but where's the fun in that?
//
//	Able to open doors if you have an id in pocket
//
//  Can change look to any jumpsuits and a bunch of costumes. (or maybe you have to eat the clothes to change to them)
//
//  Doesn't need oxygen.
//
//  Resists crushing damage, vulnerable to slicing and fire damage.


////////////////////////////////////////////////////////
// Host 'benefits'
//
//	Blood regeneration
//		You regenerate blood 3 times as fast.
//
//  Natural healing
//		Wearing living clothing SLOWLY heals you from brute
//
//	Can no longer wear clothes over your living clothing.
//
//  Can't take off your clothes, have to ask the clothing to remove itself. (?)
//
//  Can strip people twice as fast.

////////////////////////////////////////////////////////
// With host (untransformed):
//
// 	Can change look as above.
//
//	Unconscious movement
// 		If host goes unconscious, you can slowly move the host to somewhere safe.
//
// 	Transformation
//		Drink some blood - you transform into a stronger form.
//
//  Untransform
//		Can do this any time you are transformed, or if you take too much damage.
//
// 	Overload\Blood heat
//		You absorb most of the blood of your host, transform into an extremely powerful form.
//		The host goes unconscious and loses control. You now control movement.
//		You lose some control too. You autoattack everything around you.
//
//  Eat clothing
//		Lets you eat clothes. Heals you. Unworn shit works kind of crappily - the more worn the clothing the better.

////////////////////////////////////////////////////////
// With host (transformed)
//
//  All damage to host except for targeted at head is damage reduced and applied to you.
//		Spews blood everywhere because you drank it from your host.
//
// 	Chem injections instead go to you. Probably have no effect?
//
//
//	All forms have an initial blood cost for the transformation and slowly drain blood
//
// 	Flight form
//		Lets you jetpack around, even with gravity on
//
// 	Blades form
//		Gain armblade (steal from ling, gogogo), people get damage if they attack\grab you.
//		Transforming breaks cuffs.
//

////////////////////////////////////////////////////////
// the mob code

/mob/living/clothing
	languages_spoken = HUMAN // TODO: replace with CLOTHING. People you possess gain the ability to speak CLOTHING
	languages_understood = HUMAN

	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL

	ventcrawler = 2

	blood_volume = 0 // We want this?

	// Damage vars
	var/melee_damage_lower = 1
	var/melee_damage_upper = 1
	var/obj_damage = 0 //how much damage this simple animal does to objects, if any
	var/armour_penetration = 0 //How much armour they ignore, as a flat reduction from the targets armour value
	var/melee_damage_type = BRUTE //Damage type of a simple mob's melee attack, should it do damage.
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) // 1 for full damage , 0 for none , -1 for 1:1 heal from that source
	var/attacktext = "attacks"
	var/sound/attack_sound = 'sound/weapons/punch1.ogg'
	var/sound/miss_sound = 'sound/weapons/punchmiss.ogg'
	//var/friendly = "nuzzles" //If the mob does no damage with it's attack
	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls

	// Appearance vars
	var/appearance_name = "blue schoolgirl uniform"

	var/list/stored_appearances = list(
		//initial(/obj/item/clothing/under/color/grey.name) = /obj/item/clothing/under/color/grey,
		"blue schoolgirl uniform" = /obj/item/clothing/under/schoolgirl,
		)

	var/list/stored_apparence_names = list(
		//initial(/obj/item/clothing/under/color/grey.name),
		"blue schoolgirl uniform"
		)

	// Attachment vars
	var/obj/item/clothing/under/living/linked_clothes = null

/mob/living/clothing/New()
	// I guess we want this
	create_reagents(1000)

	var/datum/action/generic/set_living_clothing_appearance/CC = new(src)
	CC.Grant(src)

	set_appearance(appearance_name)

	..()

// Handle dir change due to clicking around on screen
/mob/living/clothing/setDir(newDir)
	handleDir(newDir)
	return ..()

// Handle dir change due to movement
/mob/living/clothing/Moved(atom/OldLoc, newDir)
	handleDir(newDir)
	return ..()

/mob/living/clothing/proc/handleDir(newDir)
	// TODO: we should maybe use icon rotations instead...
	// TODO: is this mob scalable??
	//if(newDir != dir)
	var/angle = dir2angle(newDir)
	var/matrix/ntransform = matrix()
	ntransform.Turn(angle)
	transform = ntransform

/mob/living/clothing/proc/set_appearance_action()
	set_appearance()

/mob/living/clothing/proc/set_appearance(appearance_name = "")
	world << "set_appearance"
	
	if(appearance_name == "")
		appearance_name = input("Select your appearance!", "Living Clothing Appearance", null, null) in stored_apparence_names
		world << appearance_name

	src.appearance_name = appearance_name

	var/appearance = stored_appearances[appearance_name]

	var/obj/item/clothing/C = new appearance()

	icon = C.icon
	icon_state = C.icon_state
	
	if(linked_clothes)
		linked_clothes.icon = C.icon
		linked_clothes.icon_state = C.icon_state
		linked_clothes.item_state = C.item_state
		linked_clothes.item_color = C.item_color


		if(linked_clothes && istype(linked_clothes.loc,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = linked_clothes.loc
			H.update_inv_w_uniform()
		
	qdel(C)


//TODO: how do I properly namespace this??
/datum/action/generic/set_living_clothing_appearance
	name = "Change Appearance"
	desc = "Switch what you want to look like."
	button_icon_state = "meson"
	procname = /mob/living/clothing/proc/set_appearance_action


/mob/living/clothing/UnarmedAttack(atom/A, proximity)
	var/mob/living/M = A
	if(M)
		if(TryAttach(M))
			return
	..()

/mob/living/clothing/proc/TryAttach(mob/living/M)
	if(!isliving(M))
		return 0
	if(!ishuman(M))
		return 0 // As fun as trying to implement this for aliens and corgi would be...

	if(stat != CONSCIOUS)
		return 0

	if(linked_clothes)
		return 0

	M.visible_message("<span class='danger'>[src] leaps at [M]'s body!</span>", \
						"<span class='userdanger'>[src] leaps at [M]'s body!</span>")

	var/mob/living/carbon/human/target = M

	if(target.wear_suit)
		var/obj/item/clothing/Suit = target.w_uniform
		if(Suit.flags & NODROP)
			return 0
		target.unEquip(Suit)
		target.visible_message("<span class='danger'>[src] tears [Suit] off of [target]'s body!</span>", \
								"<span class='userdanger'>[src] tears [Suit] off of [target]'s body!</span>")

	if(target.w_uniform)
		var/obj/item/clothing/Uniform = target.w_uniform
		if(Uniform.flags & NODROP)
			return 0
		target.unEquip(Uniform)
		target.visible_message("<span class='danger'>[src] tears [Uniform] off of [target]'s body!</span>", \
								"<span class='userdanger'>[src] tears [Uniform] off of [target]'s body!</span>")

		// Save this type of uniform for later
		var/name = Uniform.name
		if(!stored_appearances[name])
			stored_appearances[name] = Uniform.type
			stored_apparence_names.Insert(0, name)

		qdel(Uniform)

	// Create new clothing
	var/obj/item/clothing/under/living/U = new()

	U.linked_mob = src
	linked_clothes = U

	set_appearance(appearance_name)

	target.equip_to_slot_if_possible(U, slot_w_uniform)
	loc = linked_clothes

	return 1

////////////////////////////////////////////////////////
// The clothes item code

/obj/item/clothing/under/living
	desc = "Some clothes - they feel weird to the touch."
	name = "strange clothing"
	var/mob/living/clothing/linked_mob = null