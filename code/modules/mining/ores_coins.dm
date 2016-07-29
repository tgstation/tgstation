<<<<<<< HEAD
/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into

/obj/item/weapon/ore/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.remove_fuel(15) && refined_type)
			new refined_type(get_turf(src.loc))
			qdel(src)
		else if(W.isOn())
			user << "<span class='info'>Not enough fuel to smelt [src].</span>"
	..()

/obj/item/weapon/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	points = 30
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/uranium

/obj/item/weapon/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	points = 1
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/metal

/obj/item/weapon/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	points = 1
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/glass
	w_class = 1

/obj/item/weapon/ore/glass/attack_self(mob/living/user)
	user << "<span class='notice'>You use the sand to make sandstone.</span>"
	var/sandAmt = 1
	for(var/obj/item/weapon/ore/glass/G in user.loc) // The sand on the floor
		sandAmt += 1
		qdel(G)
	while(sandAmt > 0)
		var/obj/item/stack/sheet/mineral/sandstone/SS = new /obj/item/stack/sheet/mineral/sandstone(user.loc)
		if(sandAmt >= SS.max_amount)
			SS.amount = SS.max_amount
		else
			SS.amount = sandAmt
			for(var/obj/item/stack/sheet/mineral/sandstone/SA in user.loc)
				if(SA != SS && SA.amount < SA.max_amount)
					SA.attackby(SS, user) //we try to transfer all old unfinished stacks to the new stack we created.
		sandAmt -= SS.max_amount
	qdel(src)
	return

/obj/item/weapon/ore/glass/throw_impact(atom/hit_atom)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.head && C.head.flags_cover & HEADCOVERSEYES)
		visible_message("<span class='danger'>[C]'s headgear blocks the sand!</span>")
		return
	if(C.wear_mask && C.wear_mask.flags_cover & MASKCOVERSEYES)
		visible_message("<span class='danger'>[C]'s mask blocks the sand!</span>")
		return
	if(C.glasses && C.glasses.flags_cover & GLASSESCOVERSEYES)
		visible_message("<span class='danger'>[C]'s glasses block the sand!</span>")
		return
	C.adjust_blurriness(6)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.confused += 5
	C << "<span class='userdanger'>\The [src] gets into your eyes! The pain, it burns!</span>"
	qdel(src)

/obj/item/weapon/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"

/obj/item/weapon/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "plasmatech=2;materials=2"
	points = 15
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/plasma

/obj/item/weapon/ore/plasma/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = I
		if(W.welding)
			user << "<span class='warning'>You can't hit a high enough temperature to smelt [src] properly!</span>"
	else
		..()


/obj/item/weapon/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	points = 16
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/silver

/obj/item/weapon/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	points = 18
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/gold

/obj/item/weapon/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	points = 50
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/diamond

/obj/item/weapon/ore/bananium
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	points = 60
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/bananium

/obj/item/weapon/ore/titanium
	name = "titanium ore"
	icon_state = "Titanium ore"
	origin_tech = "materials=4"
	points = 50
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium

/obj/item/weapon/ore/slag
	name = "slag"
	desc = "Completely useless"
	icon_state = "slag"

/obj/item/weapon/twohanded/required/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = 4
	throw_range = 0
	var/primed = 0
	var/det_time = 100
	var/quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"

/obj/item/weapon/twohanded/required/gibtonite/Destroy()
	qdel(wires)
	wires = null
	return ..()

/obj/item/weapon/twohanded/required/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/device/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", "<span class='notice'>You attach [I] to [src].</span>")
		wires = new /datum/wires/explosive/gibtonite(src)
		attacher = key_name(user)
		qdel(I)
		add_overlay("Gibtonite_igniter")
		return

	if(wires && !primed)
		if(is_wire_tool(I))
			wires.interact(user)
			return

	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/device/mining_scanner) || istype(I, /obj/item/device/t_scanner/adv_mining_scanner) || istype(I, /obj/item/device/multitool))
			primed = 0
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", "<span class='notice'>You stopped the chain reaction. ...The ore's quality looks diminished.</span>")
			icon_state = "Gibtonite ore"
			quality = 1
			return
	..()

/obj/item/weapon/twohanded/required/gibtonite/attack_self(user)
	if(wires)
		wires.interact(user)
	else
		..()

/obj/item/weapon/twohanded/required/gibtonite/bullet_act(obj/item/projectile/P)
	GibtoniteReaction(P.firer)
	..()

/obj/item/weapon/twohanded/required/gibtonite/ex_act()
	GibtoniteReaction(null, 1)



/obj/item/weapon/twohanded/required/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/notify_admins = 0
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1

		if(notify_admins)
			if(triggered_by == 1)
				message_admins("An explosion has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else if(triggered_by == 2)
				message_admins("A signal has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>. Igniter attacher: [key_name_admin(attacher)]<A HREF='?_src_=holder;adminmoreinfo=\ref[attacher]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[attacher]'>FLW</A>)")
			else
				message_admins("[key_name_admin(user)]<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A> (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[user]'>FLW</A>) has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
		if(triggered_by == 1)
			log_game("An explosion has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		else if(triggered_by == 2)
			log_game("A signal has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z]). Igniter attacher: [key_name(attacher)].")
		else
			user.visible_message("<span class='warning'>[user] strikes \the [src], causing a chain reaction!</span>", "<span class='danger'>You strike \the [src], causing a chain reaction.</span>")
			log_game("[key_name(user)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		spawn(det_time)
		if(primed)
			if(quality == 3)
				explosion(src.loc,2,4,9,adminlog = notify_admins)
			if(quality == 2)
				explosion(src.loc,1,2,5,adminlog = notify_admins)
			if(quality == 1)
				explosion(src.loc,-1,1,3,adminlog = notify_admins)
			qdel(src)

/obj/item/weapon/ore/New()
	..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/ore/ex_act()
	return

/*****************************Coin********************************/

// The coin's value is a value of it's materials.
// Yes, the gold standard makes a come-back!
// This is the only way to make coins that are possible to produce on station actually worth anything.
/obj/item/weapon/coin
	icon = 'icons/obj/economy.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 1
	throwforce = 2
	w_class = 1
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/value = 1

/obj/item/weapon/coin/New()
	..()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

	icon_state = "coin_[cmineral]_heads"
	if(cmineral)
		name = "[cmineral] coin"

/obj/item/weapon/coin/examine(mob/user)
	..()
	if(value)
		user << "<span class='info'>It's worth [value] credit\s.</span>"

/obj/item/weapon/coin/gold
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	value = 50
	materials = list(MAT_GOLD = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/silver
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	value = 20
	materials = list(MAT_SILVER = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/diamond
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	value = 500
	materials = list(MAT_DIAMOND = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/iron
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	value = 1
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/plasma
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	value = 100
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/uranium
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	value = 80
	materials = list(MAT_URANIUM = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/clown
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	value = 1000 //makes the clown cry
	materials = list(MAT_BANANIUM = MINERAL_MATERIAL_AMOUNT*0.2)

/obj/item/weapon/coin/adamantine
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	value = 1500

/obj/item/weapon/coin/mythril
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	value = 3000

/obj/item/weapon/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT*0.2)
	value = 1

/obj/item/weapon/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	value = 0

/obj/item/weapon/coin/antagtoken/New()
	return

/obj/item/weapon/coin/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			user << "<span class='warning'>There already is a string attached to this coin!</span>"
			return

		if (CC.use(1))
			add_overlay(image('icons/obj/economy.dmi',"coin_string_overlay"))
			string_attached = 1
			user << "<span class='notice'>You attach a string to the coin.</span>"
		else
			user << "<span class='warning'>You need one length of cable to attach a string to the coin!</span>"
			return

	else if(istype(W,/obj/item/weapon/wirecutters))
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		user << "<span class='notice'>You detach the string from the coin.</span>"
	else ..()

/obj/item/weapon/coin/attack_self(mob/user)
	if(cooldown < world.time - 15)
		if(string_attached) //does the coin have a wire attached
			user << "<span class='warning'>The coin won't flip very well with something attached!</span>" //Tell user it will not flip
			return //do not flip the coin
		var/coinflip = pick(sideslist)
		cooldown = world.time
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		var/oldloc = loc
		sleep(15)
		if(loc == oldloc && user && !user.incapacitated())
			user.visible_message("[user] has flipped [src]. It lands on [coinflip].", \
 							 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
							 "<span class='italics'>You hear the clattering of loose change.</span>")
=======
/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	w_type = RECYK_MISC
	var/material=null
	var/datum/geosample/geologic_data

/obj/item/weapon/ore/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 1)
	return w_type

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	material=MAT_URANIUM
	melt_temperature = 1070+T0C

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	material=MAT_IRON
	melt_temperature = MELTPOINT_STEEL

/obj/item/weapon/ore/glass
	name = "Sand"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	material=MAT_GLASS
	melt_temperature = MELTPOINT_GLASS
	slot_flags = SLOT_POCKET
	throw_range = 1 //It just scatters to the ground as soon as you throw it.

/obj/item/weapon/ore/glass/throw_impact(atom/hit_atom)
	//Intentionally not calling ..()
	if(isturf(hit_atom))
		new/obj/effect/decal/cleanable/scattered_sand(hit_atom)
		qdel(src)
	else if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if (H.check_body_part_coverage(EYES))
			to_chat(H, "<span class='warning'>Your eyewear protects you from \the [src]!</span>")
		else
			H.visible_message("<span class='warning'>[H] is blinded by the [src]!</span>", \
				"<span class='warning'>\The [src] flies into your eyes!</span>")
			H.eye_blurry = max(H.eye_blurry, rand(3,8))
			H.eye_blind = max(H.eye_blind, rand(1,3))
			H.drop_hands(get_turf(H))
		log_attack("<font color='red'>[hit_atom] ([H ? H.ckey : "what"]) was pocketsanded by ([src.fingerprintslast])</font>")

/obj/item/weapon/ore/glass/attack_self(mob/living/user as mob) //It's magic I ain't gonna explain how instant conversion with no tool works. -- Urist
	var/location = get_turf(user)
	for(var/obj/item/weapon/ore/glass/sandToConvert in location)
		drop_stack(/obj/item/stack/sheet/mineral/sandstone, location, 1, user)
		qdel(sandToConvert)

	drop_stack(/obj/item/stack/sheet/mineral/sandstone, location, 1, user)
	qdel(src)

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "materials=2"
	material=MAT_PLASMA
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	material=MAT_SILVER
	melt_temperature = 961+T0C

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	material=MAT_GOLD
	melt_temperature = 1064+T0C

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	material=MAT_DIAMOND

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	material=MAT_CLOWN
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/phazon
	name = "Phazite"
	desc = "What the fuck?"
	icon_state = "Phazon ore"
	origin_tech = "materials=7"
	material=MAT_PHAZON
	melt_temperature = MELTPOINT_GLASS

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless unless recycled."
	icon_state = "slag"
	melt_temperature=MELTPOINT_PLASTIC

	// melt_temperature is automatically adjusted.

	var/datum/materials/mats=new

/obj/item/weapon/ore/slag/recycle(var/datum/materials/rec)
	if(mats.getVolume() == 1)
		return NOT_RECYCLABLE

	rec.addFrom(mats) // NOT removeFrom.  Some things just check for the return value.
	return RECYK_MISC

/obj/item/weapon/ore/mauxite
	name = "mauxite ore"
	desc = "A chunk of Mauxite, a sturdy common metal."
	icon_state = "mauxite"
	material="mauxite"
/obj/item/weapon/ore/molitz
	name = "molitz crystal"
	desc = "A crystal of Molitz, a common crystalline substance."
	icon_state = "molitz"
	material="molitz"
/obj/item/weapon/ore/pharosium
	name = "pharosium ore"
	desc = "A chunk of Pharosium, a conductive metal."
	icon_state = "pharosium"
	material="pharosium"
// Common Cluster Ores

/obj/item/weapon/ore/cobryl
	name = "cobryl ore"
	desc = "A chunk of Cobryl, a somewhat valuable metal."
	icon_state = "cobryl"
	material="cobryl"
/obj/item/weapon/ore/char
	name = "char ore"
	desc = "A heap of Char, a fossil energy source similar to coal."
	icon_state = "char"
	material="char"
// Rare Vein Ores

/obj/item/weapon/ore/claretine
	name = "claretine ore"
	desc = "A heap of Claretine, a highly conductive salt."
	icon_state = "claretine"
	material="claretine"
/obj/item/weapon/ore/bohrum
	name = "bohrum ore"
	desc = "A chunk of Bohrum, a heavy and highly durable metal."
	icon_state = "bohrum"
	material="bohrum"
/obj/item/weapon/ore/syreline
	name = "syreline ore"
	desc = "A chunk of Syreline, an extremely valuable and coveted metal."
	icon_state = "syreline"
	material="syreline"
// Rare Cluster Ores

/obj/item/weapon/ore/erebite
	name = "erebite ore"
	desc = "A chunk of Erebite, an extremely volatile high-energy mineral."
	icon_state = "erebite"
	material="erebite"
/obj/item/weapon/ore/erebite/ex_act()
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/weapon/ore/erebite/bullet_act(var/obj/item/projectile/P)
	explosion(src.loc,-1,0,2)
	qdel(src)

/obj/item/weapon/ore/cerenkite
	name = "cerenkite ore"
	desc = "A chunk of Cerenkite, a highly radioactive mineral."
	icon_state = "cerenkite"
	material="cerenkite"
/obj/item/weapon/ore/cerenkite/ex_act()
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
	qdel(src)
/obj/item/weapon/ore/cerenkite/attack_hand(mob/user as mob)
	var/L = get_turf(user)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
	qdel(src)
/obj/item/weapon/ore/cerenkite/bullet_act(var/obj/item/projectile/P)
	var/L = get_turf(src)
	for(var/mob/living/carbon/human/M in viewers(L, null))
		M.apply_effect((rand(10, 50)), IRRADIATE, 0)
	qdel(src)
/obj/item/weapon/ore/cytine
	name = "cytine"
	desc = "A glowing Cytine gemstone, somewhat valuable but not paticularly useful."
	icon_state = "cytine"
	material="cytine"
/obj/item/weapon/ore/cytine/New()
	..()
	color = pick("#FF0000","#0000FF","#008000","#FFFF00")

/obj/item/weapon/ore/cytine/attack_hand(mob/user as mob)
	var/obj/item/weapon/glowstick/G = new /obj/item/weapon/glowstick(user.loc)
	G.color = color
	G.light_color = color
	qdel(src)

/obj/item/weapon/ore/uqill
	name = "uqill nugget"
	desc = "A nugget of Uqill, a rare and very dense stone."
	icon_state = "uqill"
	material="uqill"
/obj/item/weapon/ore/telecrystal
	name = "telecrystal"
	desc = "A large unprocessed telecrystal, a gemstone with space-warping properties."
	icon_state = "telecrystal"
	material="telecrystal"
/obj/item/weapon/gibtonite
	name = "Gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = W_CLASS_LARGE
	throw_range = 0
	anchored = 1 //Forces people to carry it by hand, no pulling!
	flags = FPRINT | TWOHANDABLE | MUSTTWOHAND
	var/primed = 0
	var/det_time = 100
	var/quality = 1 //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher shipping_value = better

/obj/item/weapon/gibtonite/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/pickaxe) || istype(I, /obj/item/weapon/resonator))
		GibtoniteReaction(user)
		return
	if(istype(I, /obj/item/device/mining_scanner) && primed)
		primed = 0
		user.visible_message("<span class='notice'>The chain reaction was stopped! ...The ore's quality went down.</span>")
		icon_state = "Gibtonite ore"
		quality = 1
		return
	..()

/obj/item/weapon/gibtonite/bullet_act(var/obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/bullet))
		GibtoniteReaction(P.firer)
	..()

/obj/item/weapon/gibtonite/ex_act()
	GibtoniteReaction(triggered_by_explosive = 1)

/obj/item/weapon/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by_explosive = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/area/A = get_area(bombturf)
		var/notify_admins = 0
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1
		if(notify_admins)
			if(triggered_by_explosive)
				message_admins("An explosion has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			else
				message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has triggered a [name] to detonate at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
		if(triggered_by_explosive)
			log_game("An explosion has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		else
			user.visible_message("<span class='warning'>[user] strikes the [src], causing a chain reaction!</span>")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name]([bombturf.x],[bombturf.y],[bombturf.z])")
		spawn(det_time)
			if(primed)
				switch(quality)
					if(1)
						explosion(src.loc,-1,1,3,adminlog = notify_admins)
					if(2)
						explosion(src.loc,1,2,5,adminlog = notify_admins)
					if(3)
						explosion(src.loc,2,4,9,adminlog = notify_admins)
				qdel(src)

/obj/item/weapon/ore/New()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 0)

/obj/item/weapon/ore/ex_act()
	return

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
	else
		return ..()

/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT
	siemens_coefficient = 1
	force = 0.0
	throwforce = 0.0
	w_class = W_CLASS_TINY
	var/string_attached
	var/material=MAT_IRON // Ore ID, used with coinbags.
	var/credits = 0 // How many credits is this coin worth?

/obj/item/weapon/coin/New()
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 0)

/obj/item/weapon/coin/recycle(var/datum/materials/rec)
	if(material==null)
		return NOT_RECYCLABLE
	rec.addAmount(material, 0.2) // 5 coins per sheet.
	return w_type

/obj/item/weapon/coin/gold
	material=MAT_GOLD
	name = "Gold coin"
	icon_state = "coin_gold"
	credits = 5
	melt_temperature=1064+T0C

/obj/item/weapon/coin/silver
	material=MAT_SILVER
	name = "Silver coin"
	icon_state = "coin_silver"
	credits = 1
	melt_temperature=961+T0C

/obj/item/weapon/coin/diamond
	material=MAT_DIAMOND
	name = "Diamond coin"
	icon_state = "coin_diamond"
	credits = 25

/obj/item/weapon/coin/iron
	material=MAT_IRON
	name = "Iron coin"
	icon_state = "coin_iron"
	credits = 0.01
	melt_temperature=MELTPOINT_STEEL

/obj/item/weapon/coin/plasma
	material=MAT_PLASMA
	name = "Solid plasma coin"
	icon_state = "coin_plasma"
	credits = 0.1
	melt_temperature=MELTPOINT_STEEL+500

/obj/item/weapon/coin/uranium
	material=MAT_URANIUM
	name = "Uranium coin"
	icon_state = "coin_uranium"
	credits = 25
	melt_temperature=1070+T0C

/obj/item/weapon/coin/clown
	material=MAT_CLOWN
	name = "Bananaium coin"
	icon_state = "coin_clown"
	credits = 1000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/phazon
	material=MAT_PHAZON
	name = "Phazon coin"
	icon_state = "coin_phazon"
	credits = 2000
	melt_temperature=MELTPOINT_GLASS

/obj/item/weapon/coin/adamantine
	material="adamantine"
	name = "Adamantine coin"
	icon_state = "coin_adamantine"

/obj/item/weapon/coin/mythril
	material="mythril"
	name = "Mythril coin"
	icon_state = "coin_mythril"

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='notice'>There already is a string attached to this coin.</span>")
			return

		if(CC.amount <= 0)
			to_chat(user, "<span class='notice'>This cable coil appears to be empty.</span>")
			qdel(CC)
			CC = null
			return

		overlays += image('icons/obj/items.dmi',"coin_string_overlay")
		string_attached = 1
		to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		CC.use(1)
	else if(istype(W,/obj/item/weapon/wirecutters) )
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	else ..()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
