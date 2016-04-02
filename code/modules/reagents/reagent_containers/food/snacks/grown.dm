

// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

//Grown foods
//Subclass so we can pass on values
/obj/item/weapon/reagent_containers/food/snacks/grown/
	var/plantname
	var/potency = -1
	var/datum/seed/seed
	icon = 'icons/obj/harvest.dmi'
	New(newloc, newpotency)
		if(!isnull(newpotency))
			potency = newpotency
		..()
		src.pixel_x = rand(-5.0, 5)
		src.pixel_y = rand(-5.0, 5)

/obj/item/weapon/reagent_containers/food/snacks/grown/New()
	..()

	//Handle some post-spawn var stuff.
	spawn(1)
		//Fill the object up with the appropriate reagents.
		if(!isnull(plantname))
			seed = plant_controller.seeds[plantname]
			if(!seed || !seed.chems)
				return

			potency = round(seed.potency)
			force = seed.thorny ? 5+seed.carnivorous*3 : 0

			var/totalreagents = 0
			for(var/rid in seed.chems)
				var/list/reagent_data = seed.chems[rid]
				var/rtotal = reagent_data[1]
				if(reagent_data.len > 1 && potency > 0)
					rtotal += round(potency/reagent_data[2])
				totalreagents += rtotal

			if(totalreagents)
				var/coeff = min(reagents.maximum_volume / totalreagents, 1)

				for(var/rid in seed.chems)
					var/list/reagent_data = seed.chems[rid]
					var/rtotal = reagent_data[1]
					if(reagent_data.len > 1 && potency > 0)
						rtotal += round(potency/reagent_data[2])
					reagents.add_reagent(rid, max(1, round(rtotal*coeff, 0.1)))

			if(seed.teleporting)
				name = "blue-space [name]"
			if(seed.stinging)
				name = "stinging [name]"
			if(seed.juicy == 2)
				name = "slippery [name]"

		if(reagents.total_volume > 0)
			bitesize = 1 + round(reagents.total_volume/2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom)
	..()
	if(!seed || !src) return
	//if(seed.stinging)   			//we do NOT want to transfer reagents on throw, as it would mean plantbags full of throwable chloral injectors
	//	stinging_apply_reagents(M)  //plus all sorts of nasty stuff like throw_impact not targeting a specific bodypart to check for protection.

	// We ONLY want to apply special effects if we're hitting a turf! That's because throw_impact will always be
	// called on a turf AFTER it's called on the things ON the turf, and will runtime if the item doesn't exist anymore.
	if(isturf(hit_atom))
		do_splat_effects(hit_atom)
	return

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/do_splat_effects(atom/hit_atom)
	if(seed.teleporting)
		splat_reagent_reaction(get_turf(hit_atom))
		if(do_fruit_teleport(hit_atom, usr, potency))
			visible_message("<span class='danger'>The [src] splatters, causing a distortion in space-time!</span>")
		else if(splat_decal(get_turf(hit_atom)))
			visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		qdel(src)
		return

	if(seed.juicy)
		splat_decal(get_turf(hit_atom))
		splat_reagent_reaction(get_turf(hit_atom))
		visible_message("<span class='notice'>The [src.name] has been squashed.</span>","<span class='moderate'>You hear a smack.</span>")
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/attack(mob/living/M, mob/user, def_zone)
	if(user.a_intent == I_HURT)
		. = handle_attack(src,M,user,def_zone)
		if(seed.stinging)
			if(M.getarmor(def_zone, "melee") < 5)
				var/reagentlist = stinging_apply_reagents(M)
				if(reagentlist)
					to_chat(M, "<span class='danger'>You are stung by \the [src]!</span>")
					add_attacklogs(user, M, "stung", object = src, addition = "Reagents: [english_list(seed.get_reagent_names())]", admin_warn = 1)
			to_chat(user, "<span class='alert'>Some of \the [src]'s stingers break off in the hit!</span>")
			potency -= rand(1,(potency/3)+1)
		do_splat_effects(M)
		return
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/Crossed(var/mob/living/carbon/M)
	..()
	if(!seed) return
	if(!istype(M)) return
	if(!M.on_foot())
		return
	if(seed.thorny || seed.stinging)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(!H.check_body_part_coverage(FEET))
				var/datum/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting && affecting.is_organic())
					if(thorns_apply_damage(M, affecting))
						to_chat(H, "<span class='danger'>You step on \the [src]'s sharp thorns!</span>")
						if(H.species && !(H.species.flags & NO_PAIN))
							H.Weaken(3)
					if(stinging_apply_reagents(M))
						to_chat(H, "<span class='danger'>Your step on \the [src]'s stingers!</span>")
						potency -= rand(1,(potency/3)+1)
	if(seed.juicy == 2)
		if(M.Slip(3, 2))
			to_chat(M, "<span class='notice'>You slipped on the [name]!</span>")
			do_splat_effects(M)

/obj/item/weapon/reagent_containers/food/snacks/grown/pickup(mob/user)
	..()
	if(!seed) return
	if(seed.thorny || seed.stinging)
		var/mob/living/carbon/human/H = user
		if(!istype(H))
			return
		if(H.check_body_part_coverage(HANDS))
			return
		var/datum/organ/external/affecting = H.get_organ(pick("r_hand","l_hand"))
		if(!affecting || !affecting.is_organic())
			return
		if(stinging_apply_reagents(H))
			to_chat(H, "<span class='danger'>You are stung by \the [src]!</span>")
			potency -= rand(1,(potency/3)+1)
		if(thorns_apply_damage(H, affecting))
			to_chat(H, "<span class='danger'>You are prickled by the sharp thorns on \the [src]!</span>")
			spawn(3)
				if(H.species && !(H.species.flags & NO_PAIN))
					H.drop_item(src)

/obj/item/weapon/reagent_containers/food/snacks/grown/On_Consume(var/mob/living/carbon/human/H)
	if(seed.thorny && istype(H))
		var/datum/organ/external/affecting = H.get_organ("head")
		if(affecting)
			if(thorns_apply_damage(H, affecting))
				to_chat(H, "<span class='danger'>Your mouth is cut by \the [src]'s sharp thorns!</span>")
				//H.stunned++ //just a 1 second pause to prevent people from spamming pagedown on this, since it's important
	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/examine(mob/user)
	..()
	if(!seed) return
	var/traits = ""
	if(seed.stinging) traits += "<span class='alert'>It's covered in tiny stingers.</span> "
	if(seed.thorny) traits += "<span class='alert'>It's covered in sharp thorns.</span> "
	if(seed.juicy == 2) traits += "It looks ripe and excessively juicy. "
	if(seed.teleporting) traits += "It seems to be spatially unstable. "
	if(traits) to_chat(user, traits)

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/splat_decal(turf/T)
	var/obj/effect/decal/cleanable/S = getFromPool(seed.splat_type,T)
	S.New(S.loc)
	if(seed.splat_type == /obj/effect/decal/cleanable/fruit_smudge/)
		if(filling_color != "#FFFFFF")
			S.color = filling_color
		else
			S.color = AverageColor(getFlatIcon(src, src.dir, 0), 1, 1)
		S.name = "[seed.seed_name] smudge"
	if(seed.biolum && seed.biolum_colour)
		S.set_light(1, l_color = seed.biolum_colour)
	return 1

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/splat_reagent_reaction(turf/T)
	if(src.reagents.total_volume > 0)
		src.reagents.reaction(T)
		for(var/atom/A in T)
			src.reagents.reaction(A)
		return 1
	return 0

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/thorns_apply_damage(mob/living/carbon/human/H, datum/organ/external/affecting)
	if(!seed.thorny || !affecting)
		return 0
	//if(affecting.take_damage(5+seed.carnivorous*3, 0, 0, "plant thorns")) //For some fucked up reason, it's not returning 1
	affecting.take_damage(5+seed.carnivorous*3, 0, 0, "plant thorns")
	H.UpdateDamageIcon()
	return 1

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/stinging_apply_reagents(mob/living/carbon/human/H)
	if(!seed.stinging)
		return 0
	if(!reagents || reagents.total_volume <= 0)
		return 0
	if(!seed.chems || !seed.chems.len)
		return 0
	var/injecting = Clamp(1, 3, potency/10)
	for(var/rid in seed.chems) //Only transfer reagents that the plant naturally produces, no injecting chloral into your nettles.
		reagents.trans_id_to(H,rid,injecting)
		. = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/do_fruit_teleport(atom/hit_atom, mob/M, var/potency)	//Does this need logging?
	var/datum/zLevel/L = get_z_level(src)
	if(!L || L.teleJammed)
		return 0

	var/outer_teleport_radius = potency/10 //Plant potency determines radius of teleport.
	var/inner_teleport_radius = potency/15 //At base potency, nothing will happen, since the radius is 0.
	if(inner_teleport_radius < 1)
		return 0
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread

	var/list/turfs = new/list()
	//This could likely use some standardization but I have no idea how to not break it.
	for(var/turf/T in trange(outer_teleport_radius, get_turf(hit_atom)))
		if(get_dist(T, hit_atom) <= inner_teleport_radius)
			continue
		if(is_blocked_turf(T) || istype(T, /turf/space))
			continue
		if(T.x > world.maxx-outer_teleport_radius || T.x < outer_teleport_radius)
			continue
		if(T.y > world.maxy-outer_teleport_radius || T.y < outer_teleport_radius)
			continue
		turfs += T
	if(!turfs.len)
		var/list/turfs_to_pick_from = list()
		for(var/turf/T in trange(outer_teleport_radius, get_turf(hit_atom)))
			if(get_dist(T, hit_atom) > inner_teleport_radius)
				turfs_to_pick_from += T
		turfs += pick(/turf in turfs_to_pick_from)
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return 0
	switch(rand(1, 2)) //50-50 % chance to teleport the thrower or the target.
		if(1) //Teleports the person who threw the fruit
			s.set_up(3, 1, M)
			s.start()
			new/obj/effect/decal/cleanable/molten_item(M.loc) //Leaves a pile of goo behind for dramatic effect.
			M.forceMove(picked) //Send then to that location we picked previously
			spawn()
				s.set_up(3, 1, M)
				s.start() //Two set of sparks, one before the teleport and one after. //Sure then ?
		if(2) //Teleports the target instead.
			s.set_up(3, 1, hit_atom)
			s.start()
			new/obj/effect/decal/cleanable/molten_item(get_turf(hit_atom)) //Leave a pile of goo behind for dramatic effect...
			for(var/mob/A in get_turf(hit_atom)) //For the mobs in the tile that was hit...
				A.forceMove(picked) //And teleport them to the chosen location.
				spawn()
					s.set_up(3, 1, A)
					s.start()
	return 1


/obj/item/weapon/reagent_containers/food/snacks/grown/corn
	name = "ear of corn"
	desc = "Needs some butter!"
	plantname = "corn"
	icon_state = "corn"
	potency = 40
	filling_color = "#FFEE00"
	trash = /obj/item/weapon/corncob

/obj/item/weapon/reagent_containers/food/snacks/grown/cherries
	name = "cherries"
	desc = "Great for toppings!"
	icon_state = "cherry"
	filling_color = "#FF0000"
	gender = PLURAL
	plantname = "cherry"
	slot_flags = SLOT_EARS

/obj/item/weapon/reagent_containers/food/snacks/grown/cinnamon
	name = "cinnamon sticks"
	desc = "Straight from the bark!"
	icon_state = "cinnamon"
	filling_color = "#D2691E"
	gender = PLURAL
	plantname = "cinnamomum"

/obj/item/weapon/reagent_containers/food/snacks/grown/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	potency = 30
	filling_color = "#CC6464"
	plantname = "poppies"

/obj/item/weapon/reagent_containers/food/snacks/grown/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten’d not thy breath.\""
	icon_state = "harebell"
	potency = 1
	filling_color = "#D4B2C9"
	plantname = "harebells"

/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	potency = 25
	filling_color = "#E6E6FA"
	plantname = "moonflowers"

/obj/item/weapon/reagent_containers/food/snacks/grown/potato
	name = "potato"
	desc = "Boil 'em! Mash 'em! Stick 'em in a stew!"
	icon_state = "potato"
	potency = 25
	filling_color = "#E6E8DA"
	plantname = "potato"

/obj/item/weapon/reagent_containers/food/snacks/grown/potato/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/stack/cable_coil))
		if(W:amount >= 5)
			W:amount -= 5
			if(!W:amount)
				qdel(W)
			to_chat(user, "<span class='notice'>You add some cable to \the [src] and slide it inside the battery encasing.</span>")
			var/obj/item/weapon/cell/potato/pocell = new /obj/item/weapon/cell/potato(user.loc)
			pocell.maxcharge = src.potency * 10
			pocell.charge = pocell.maxcharge
			qdel(src)
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/grapes
	name = "bunch of grapes"
	desc = "Nutritious!"
	icon_state = "grapes"
	filling_color = "#A332AD"
	plantname = "grapes"

/obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes
	name = "bunch of green grapes"
	desc = "Nutritious!"
	icon_state = "greengrapes"
	potency = 25
	filling_color = "#A6FFA3"
	plantname = "greengrapes"

/obj/item/weapon/reagent_containers/food/snacks/grown/peanut
	name = "peanut"
	desc = "Nuts!"
	icon_state = "peanut"
	filling_color = "857e27"
	potency = 25
	plantname = "peanut"

/obj/item/weapon/reagent_containers/food/snacks/grown/cabbage
	name = "cabbage"
	desc = "Ewwwwwwwwww. Cabbage."
	icon_state = "cabbage"
	potency = 25
	filling_color = "#A2B5A1"
	plantname = "cabbage"

/obj/item/weapon/reagent_containers/food/snacks/grown/berries
	name = "bunch of berries"
	desc = "Nutritious!"
	icon_state = "berrypile"
	filling_color = "#C2C9FF"
	plantname = "berries"

/obj/item/weapon/reagent_containers/food/snacks/grown/plastellium
	name = "clump of plastellium"
	desc = "Hmm, needs some processing"
	icon_state = "plastellium"
	filling_color = "#C4C4C4"
	plantname = "plastic"

/obj/item/weapon/reagent_containers/food/snacks/grown/glowberries
	name = "bunch of glow-berries"
	desc = "Nutritious!"
	var/light_on = 1
	var/brightness_on = 2 //luminosity when on
	filling_color = "#D3FF9E"
	icon_state = "glowberrypile"
	plantname = "glowberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod
	name = "cocoa pod"
	desc = "Can be ground into cocoa powder."
	icon_state = "cocoapod"
	potency = 50
	filling_color = "#9C8E54"
	plantname = "cocoa"

/obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane
	name = "sugarcane"
	desc = "Sickly sweet."
	icon_state = "sugarcane"
	potency = 50
	filling_color = "#C0C9AD"
	plantname = "sugarcane"

/obj/item/weapon/reagent_containers/food/snacks/grown/poisonberries
	name = "bunch of poison-berries"
	desc = "Taste so good, you could die!"
	icon_state = "poisonberrypile"
	gender = PLURAL
	potency = 15
	filling_color = "#B422C7"
	plantname = "poisonberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/deathberries
	name = "bunch of death-berries"
	desc = "Taste so good, you could die!"
	icon_state = "deathberrypile"
	gender = PLURAL
	potency = 50
	filling_color = "#4E0957"
	plantname = "deathberries"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	filling_color = "#125709"
	plantname = "ambrosia"

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		qdel(O)
		to_chat(user, "<span class='notice'>You roll a blunt out of \the [src].</span>")
		var/obj/item/clothing/mask/cigarette/blunt/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/rolled(src.loc)
		B.name = "[src.name] blunt"
		B.filling = "[src.name]"
		reagents.trans_to(B, (reagents.total_volume))
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	potency = 10
	filling_color = "#229E11"
	plantname = "ambrosiadeus"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/deus/attackby(var/obj/item/weapon/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/paper))
		qdel(O)
		to_chat(user, "<span class='notice'>You roll a godly blunt.</span>")
		var/obj/item/clothing/mask/cigarette/blunt/deus/rolled/B = new/obj/item/clothing/mask/cigarette/blunt/deus/rolled(src.loc)
		reagents.trans_to(B, (reagents.total_volume))
		B.light_color = filling_color
		user.put_in_hands(B)
		user.drop_from_inventory(src)
		qdel(src)
	else
		return ..()

/obj/item/weapon/reagent_containers/food/snacks/grown/apple
	name = "apple"
	desc = "It's a little piece of Eden."
	icon_state = "apple"
	potency = 15
	filling_color = "#DFE88B"
	plantname = "apple"

/obj/item/weapon/reagent_containers/food/snacks/grown/apple/poisoned
	filling_color = "#B3BD5E"
	plantname = "poisonapple"

/obj/item/weapon/reagent_containers/food/snacks/grown/goldapple
	name = "golden apple"
	desc = "Emblazoned upon the apple is the word 'Kallisti'."
	icon_state = "goldapple"
	potency = 15
	filling_color = "#F5CB42"
	plantname = "goldapple"

/obj/item/weapon/reagent_containers/food/snacks/grown/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	potency = 10
	filling_color = "#FA2863"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/watermelonslice
	slices_num = 5
	plantname = "watermelon"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin
	name = "pumpkin"
	desc = "It's large and scary."
	icon_state = "pumpkin"
	potency = 10
	filling_color = "#FAB728"
	plantname = "pumpkin"

/obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(W.is_sharp() >= 1)
		user.visible_message("<span class='notice'>[user] carves a face into \the [src] with \the [W]!</span>", "<span class='notice'>You carve a face into \the [src] with \the [W]!</span>")
		new /obj/item/clothing/head/pumpkinhead(get_turf(src)) //Don't move it
		qdel(src)
		return

/obj/item/weapon/reagent_containers/food/snacks/grown/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	potency = 20
	filling_color = "#28FA59"
	plantname = "lime"

/obj/item/weapon/reagent_containers/food/snacks/grown/lemon
	name = "lemon"
	desc = "When life gives you lemons, be grateful they aren't limes."
	icon_state = "lemon"
	potency = 20
	filling_color = "#FAF328"
	plantname = "lemon"

/obj/item/weapon/reagent_containers/food/snacks/grown/orange
	name = "orange"
	desc = "It's an tangy fruit."
	icon_state = "orange"
	potency = 20
	filling_color = "#FAAD28"
	plantname = "orange"

/obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet
	name = "white-beet"
	desc = "You can't beat white-beet."
	icon_state = "whitebeet"
	potency = 15
	filling_color = "#FFFCCC"
	plantname = "whitebeet"

/obj/item/weapon/reagent_containers/food/snacks/grown/banana
	name = "banana"
	desc = "It's an excellent prop for a comedy."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana"
	item_state = "banana"
	filling_color = "#FCF695"
	trash = /obj/item/weapon/bananapeel
	plantname = "banana"

/obj/item/weapon/reagent_containers/food/snacks/grown/chili
	name = "chili"
	desc = "It's spicy! Wait... IT'S BURNING ME!!"
	icon_state = "chilipepper"
	filling_color = "#FF0000"
	plantname = "chili"

/obj/item/weapon/reagent_containers/food/snacks/grown/eggplant
	name = "eggplant"
	desc = "Maybe there's a chicken inside?"
	icon_state = "eggplant"
	filling_color = "#550F5C"
	plantname = "eggplant"

/obj/item/weapon/reagent_containers/food/snacks/grown/soybeans
	name = "soybeans"
	desc = "It's pretty bland, but oh the possibilities..."
	gender = PLURAL
	filling_color = "#E6E8B7"
	icon_state = "soybeans"
	plantname = "soybean"

/obj/item/weapon/reagent_containers/food/snacks/grown/koibeans
	name = "koibean"
	desc = "Something about these seems fishy."
	gender = PLURAL
	icon_state = "koibeans"
	filling_color = "#F0E68C"
	plantname = "koibean"

/obj/item/weapon/reagent_containers/food/snacks/grown/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	filling_color = "#FF0000"
	potency = 10
	plantname = "tomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	potency = 10
	filling_color = "#FF0000"
	plantname = "killertomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/killertomato/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	new /mob/living/simple_animal/tomato(user.loc)
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the killer-tomato.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/bloodtomato
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	potency = 10
	filling_color = "#FF0000"
	plantname = "bloodtomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/bluetomato
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	potency = 10
	filling_color = "#586CFC"
	plantname = "bluetomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/wheat
	name = "wheat"
	desc = "Sigh... wheat... a-grain?"
	gender = PLURAL
	icon_state = "wheat"
	filling_color = "#F7E186"
	plantname = "wheat"

/obj/item/weapon/reagent_containers/food/snacks/grown/ricestalk
	name = "rice stalk"
	desc = "Rice to see you."
	gender = PLURAL
	icon_state = "rice"
	filling_color = "#FFF8DB"
	plantname = "rice"

/obj/item/weapon/reagent_containers/food/snacks/grown/kudzupod
	name = "kudzu pod"
	desc = "<I>Pueraria Virallis</I>: An invasive species with vines that rapidly creep and wrap around whatever they contact."
	icon_state = "kudzupod"
	filling_color = "#59691B"
	plantname = "kudzu"

/obj/item/weapon/reagent_containers/food/snacks/grown/icepepper
	name = "ice-pepper"
	desc = "It's a mutant strain of chili"
	icon_state = "icepepper"
	potency = 20
	filling_color = "#66CEED"
	plantname = "icechili"

/obj/item/weapon/reagent_containers/food/snacks/grown/carrot
	name = "carrot"
	desc = "It's good for the eyes!"
	icon_state = "carrot"
	potency = 10
	filling_color = "#FFC400"
	plantname = "carrot"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/reishi
	name = "reishi"
	desc = "<I>Ganoderma lucidum</I>: A special fungus believed to help relieve stress."
	icon_state = "reishi"
	potency = 10
	filling_color = "#FF4800"
	plantname = "reishi"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/amanita
	name = "fly amanita"
	desc = "<I>Amanita Muscaria</I>: Learn poisonous mushrooms by heart. Only pick mushrooms you know."
	icon_state = "amanita"
	potency = 10
	filling_color = "#FF0000"
	plantname = "amanita"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/angel
	name = "destroying angel"
	desc = "<I>Amanita Virosa</I>: Deadly poisonous basidiomycete fungus filled with alpha amatoxins."
	icon_state = "angel"
	potency = 35
	filling_color = "#FFDEDE"
	plantname = "destroyingangel"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap
	name = "liberty-cap"
	desc = "<I>Psilocybe Semilanceata</I>: Liberate yourself!"
	icon_state = "libertycap"
	potency = 15
	filling_color = "#F714BE"
	plantname = "libertycap"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	name = "plump-helmet"
	desc = "<I>Plumus Hellmus</I>: Plump, soft and s-so inviting~"
	icon_state = "plumphelmet"
	filling_color = "#F714BE"
	plantname = "plumphelmet"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom
	name = "walking mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "walkingmushroom"
	filling_color = "#FFBFEF"
	potency = 30
	plantname = "walkingmushroom"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/walkingmushroom/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	new /mob/living/simple_animal/hostile/mushroom(user.loc)
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the walking mushroom.</span>")

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle
	name = "chanterelle cluster"
	desc = "<I>Cantharellus Cibarius</I>: These jolly yellow little shrooms sure look tasty!"
	icon_state = "chanterelle"
	filling_color = "#FFE991"
	plantname = "mushrooms"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom
	name = "glowshroom cluster"
	desc = "<I>Mycena Bregprox</I>: This species of mushroom glows in the dark. Or does it?"
	icon_state = "glowshroom"
	filling_color = "#DAFF91"
	potency = 30
	plantname = "glowshroom"

/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/glowshroom/attack_self(mob/user as mob)
	if(istype(user.loc, /turf/space))
		return
	var/obj/effect/glowshroom/planted = new /obj/effect/glowshroom(user.loc)

	planted.delay = 50
	planted.endurance = 100
	planted.potency = potency
	qdel(src)

	to_chat(user, "<span class='notice'>You plant the glowshroom.</span>")

// *************************************
// Complex Grown Object Defines -
// Putting these at the bottom so they don't clutter the list up. -Cheridan
// *************************************

/obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato
	name = "tomato" //"blue-space" is applied on new(), provided it's teleporting trait hasn't been removed
	desc = "Its juices lubricate so well, you might slip through space-time."
	icon_state = "bluespacetomato"
	potency = 20
	origin_tech = "bluespace = 3"
	filling_color = "#91F8FF"
	plantname = "bluespacetomato"

/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosiavulgaris/cruciatus
	plantname = "ambrosiacruciatus"
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	icon_state = "ambrosiavulgaris"
	potency = 10
	/*New() //NO SNOWFLAKE ALLOWED
		..()
		spawn(5)	//So potency can be set in the proc that creates these crops
			reagents.add_reagent("nutriment", 1)
			reagents.add_reagent("space_drugs", 1 + round(potency/8, 1))
			reagents.add_reagent("kelotane", 1 + round(potency/8, 1))
			reagents.add_reagent("bicaridine", 1 + round(potency/10, 1))
			reagents.add_reagent("toxin", 1 + round(potency/10, 1))
			reagents.add_reagent("spiritbreaker", 10)
			bitesize = 1+round(reagents.total_volume/2, 1)*/

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit
	name = "no-fruit"
	desc = "Any plant you want, at your fingertips."
	icon_state = "nofruit"
	potency = 15
	filling_color = "#FFFCCC"
	plantname = "nofruit"
	var/list/available_fruits = list()
	var/switching = 0
	var/current_path = null
	var/counter = 1

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/New()
	..()
	available_fruits = existing_typesof(/obj/item/weapon/reagent_containers/food/snacks/grown)

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/verb/pick_leaf()
	set name = "Pick no-fruit leaf"
	set category = "Object"
	set src in range(1)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	verbs -= /obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/verb/pick_leaf

	randomize()

/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/attackby(obj/item/weapon/W, mob/user)
	if(switching)
		if(!current_path)
			return
		switching = 0
		var/N = rand(1,3)
		switch(N)
			if(1)
				playsound(user, 'sound/weapons/genhit1.ogg', 50, 1)
			if(2)
				playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
			if(3)
				playsound(user, 'sound/weapons/genhit3.ogg', 50, 1)
		user.visible_message("[user] smacks \the [src] with \the [W].","You smack \the [src] with \the [W].")
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/I = new current_path(get_turf(user))
			user.put_in_hands(I)
		else
			new current_path(get_turf(src))
		qdel(src)


/obj/item/weapon/reagent_containers/food/snacks/grown/nofruit/proc/randomize()
	switching = 1
	spawn()
		while(switching)
			current_path = available_fruits[counter]
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = current_path
			icon_state = initial(G.icon_state)
			playsound(src, 'sound/misc/click.ogg', 50, 1)
			sleep(1)
			if(counter == available_fruits.len)
				counter = 0
			counter++