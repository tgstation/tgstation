/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Glass shards - TODO: Move this into code/game/object/item/weapons
 */

/*
 * Glass sheets
 */
GLOBAL_LIST_INIT(glass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=1"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/glass

/obj/item/stack/sheet/glass/cyborg
	materials = list()
	is_cyborg = 1
	cost = 500

/obj/item/stack/sheet/glass/fifty
	amount = 50

/obj/item/stack/sheet/glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.glass_recipes
	return ..()
	
/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if (get_amount() < 1 || CC.get_amount() < 5)
			to_chat(user, "<span class='warning>You need five lengths of coil and one sheet of glass to make wired glass!</span>")
			return
		CC.use(5)
		use(1)
		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
		var/obj/item/stack/light_w/new_tile = new(user.loc)
		new_tile.add_fingerprint(user)
	else if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/rglass/RG = new (get_turf(user))
			RG.add_fingerprint(user)
			var/replace = user.get_inactive_held_item()==src
			V.use(1)
			use(1)
			if(QDELETED(src) && replace)
				user.put_in_hands(RG)
		else
			to_chat(user, "<span class='warning'>You need one rod and one sheet of glass to make reinforced glass!</span>")
			return
	else
		return ..()



GLOBAL_LIST_INIT(pglass_recipes, list ( \
	new/datum/stack_recipe("directional window", /obj/structure/window/plasma/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile window", /obj/structure/window/plasma/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/plasmaglass
	name = "plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy. It looks extremely tough and heavily fire resistant."
	singular_name = "plasma glass sheet"
	icon_state = "sheet-pglass"
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "plasmatech=2;materials=2"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plasmaglass

/obj/item/stack/sheet/plasmaglass/fifty
	amount = 50

/obj/item/stack/sheet/plasmaglass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.pglass_recipes
	return ..()
	
/obj/item/stack/sheet/plasmaglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/V = W
		if (V.get_amount() >= 1 && get_amount() >= 1)
			var/obj/item/stack/sheet/plasmarglass/RG = new (get_turf(user))
			RG.add_fingerprint(user)
			var/replace = user.get_inactive_held_item()==src
			V.use(1)
			use(1)
			if(QDELETED(src) && replace)
				user.put_in_hands(RG)
		else
			to_chat(user, "<span class='warning'>You need one rod and one sheet of plamsa glass to make reinforced plasma glass!</span>")
			return
	else
		return ..()



/*
 * Reinforced glass sheets
 */
GLOBAL_LIST_INIT(reinforced_glass_recipes, list ( \
	new/datum/stack_recipe("windoor frame", /obj/structure/windoor_assembly, 5, time = 0, on_floor = TRUE, window_checks = TRUE), \
	null, \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/reinforced/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/reinforced/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))


/obj/item/stack/sheet/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=2"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/rglass

/obj/item/stack/sheet/rglass/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	..()

/obj/item/stack/sheet/rglass/cyborg
	materials = list()
	var/datum/robot_energy_storage/glasource
	var/metcost = 250
	var/glacost = 500

/obj/item/stack/sheet/rglass/cyborg/get_amount()
	return min(round(source.energy / metcost), round(glasource.energy / glacost))

/obj/item/stack/sheet/rglass/cyborg/use(used, transfer = FALSE) // Requires special checks, because it uses two storages
	source.use_charge(used * metcost)
	glasource.use_charge(used * glacost)

/obj/item/stack/sheet/rglass/cyborg/add(amount)
	source.add_charge(amount * metcost)
	glasource.add_charge(amount * glacost)

/obj/item/stack/sheet/rglass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.reinforced_glass_recipes
	return ..()
	
GLOBAL_LIST_INIT(prglass_recipes, list ( \
	new/datum/stack_recipe("directional reinforced window", /obj/structure/window/plasma/reinforced/unanchored, time = 0, on_floor = TRUE, window_checks = TRUE), \
	new/datum/stack_recipe("fulltile reinforced window", /obj/structure/window/plasma/reinforced/fulltile/unanchored, 2, time = 0, on_floor = TRUE, window_checks = TRUE) \
))

/obj/item/stack/sheet/plasmarglass
	name = "reinforced plasma glass"
	desc = "A glass sheet made out of a plasma-silicate alloy and a rod matrice. It looks hopelessly tough and nearly fire-proof!"
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-prglass"
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT/2, MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	origin_tech = "materials=2;plasmatech=2"
	armor = list("melee" = 20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	resistance_flags = ACID_PROOF
	merge_type = /obj/item/stack/sheet/plasmarglass

/obj/item/stack/sheet/plasmarglass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.prglass_recipes
	return ..()


/obj/item/weapon/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	resistance_flags = ACID_PROOF
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	obj_integrity = 40
	max_integrity = 40
	var/cooldown = 0
	sharpness = IS_SHARP

/obj/item/weapon/shard/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shard of glass! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS)


/obj/item/weapon/shard/Initialize()
	. = ..()
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)

/obj/item/weapon/shard/afterattack(atom/A as mob|obj, mob/user, proximity)
	if(!proximity || !(src in user))
		return
	if(isturf(A))
		return
	if(istype(A, /obj/item/weapon/storage))
		return
	var/hit_hand = ((user.active_hand_index % 2 == 0) ? "r_" : "l_") + "arm"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !(PIERCEIMMUNE in H.dna.species.species_traits)) // golems, etc
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			H.apply_damage(force*0.5, BRUTE, hit_hand)
	else if(ismonkey(user))
		var/mob/living/carbon/monkey/M = user
		to_chat(M, "<span class='warning'>[src] cuts into your hand!</span>")
		M.apply_damage(force*0.5, BRUTE, hit_hand)


/obj/item/weapon/shard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/device/lightreplacer))
		I.attackby(src, user)
	else if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(0, user))
			var/obj/item/stack/sheet/glass/NG = new (user.loc)
			for(var/obj/item/stack/sheet/glass/G in user.loc)
				if(G == NG)
					continue
				if(G.amount >= G.max_amount)
					continue
				G.attackby(NG, user)
			to_chat(user, "<span class='notice'>You add the newly-formed glass to the stack. It now contains [NG.amount] sheet\s.</span>")
			qdel(src)
	else
		return ..()

/obj/item/weapon/shard/Crossed(mob/AM)
	if(istype(AM) && has_gravity(loc))
		playsound(loc, 'sound/effects/glass_step.ogg', 50, 1)
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(PIERCEIMMUNE in H.dna.species.species_traits)
				return
			var/picked_def_zone = pick("l_leg", "r_leg")
			var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
			if(!istype(O))
				return
			if(O.status == BODYPART_ROBOTIC)
				return
			var/feetCover = (H.wear_suit && H.wear_suit.body_parts_covered & FEET) || (H.w_uniform && H.w_uniform.body_parts_covered & FEET)
			if(H.shoes || feetCover || H.movement_type & FLYING || H.buckled)
				return
			H.apply_damage(5, BRUTE, picked_def_zone)
			if(cooldown < world.time - 10) //cooldown to avoid message spam.
				if(!H.incapacitated())
					H.visible_message("<span class='danger'>[H] steps in the broken glass!</span>", \
							"<span class='userdanger'>You step in the broken glass!</span>")
				else
					H.visible_message("<span class='danger'>[H] slides on the broken glass!</span>", \
							"<span class='userdanger'>You slide on the broken glass!</span>")

				cooldown = world.time
			H.Knockdown(60)
