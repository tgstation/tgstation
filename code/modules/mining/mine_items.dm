/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/effect/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Miner Lockers**************************/

/obj/structure/closet/secure_closet/miner
	name = "miner's equipment"
	icon_state = "mining"
	req_access = list(access_mining)

/obj/structure/closet/secure_closet/miner/New()
	..()
	if(prob(50))
		new /obj/item/weapon/storage/backpack/industrial(src)
	else
		new /obj/item/weapon/storage/backpack/satchel_eng(src)
	new /obj/item/device/radio/headset/headset_cargo(src)
	new /obj/item/clothing/under/rank/miner(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/device/mining_scanner(src)
	new /obj/item/weapon/storage/bag/ore(src)
	new /obj/item/weapon/shovel(src)
	new /obj/item/weapon/pickaxe(src)
	new /obj/item/clothing/glasses/meson(src)


/**********************Shuttle Computer**************************/

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Used to call and send the mining shuttle."
	req_access = list(access_mining)
	circuit = /obj/item/weapon/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"

/*********************Pickaxe & Drills**************************/

/obj/item/weapon/pickaxe
	name = "pickaxe"
	desc = "An ancient tool still used in modern times due to its effectiveness and digging tunnels."
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 15
	throwforce = 10.0
	item_state = "pickaxe"
	w_class = 4.0
	m_amt = 3750 //one sheet, but where can you make them?
	var/digspeed = 40
	var/list/digsound = list('sound/effects/picaxe1.ogg','sound/effects/picaxe2.ogg','sound/effects/picaxe3.ogg')
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("hit", "pierced", "sliced", "attacked")

/obj/item/weapon/pickaxe/proc/playDigSound()
	playsound(src, pick(digsound),50,1)

/obj/item/weapon/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	item_state = "dpickaxe"
	digspeed = 20 //mines twice as fast as a normal pickaxe, bought from mining vendor
	origin_tech = "materials=4;engineering=3"
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."

/obj/item/weapon/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	item_state = "jackhammer"
	digspeed = 25 //available from roundstart, faster than a pickaxe.
	digsound = list('sound/weapons/drill.ogg')
	hitsound = 'sound/weapons/drill.ogg'
	origin_tech = "materials=2;powerstorage=3;engineering=2"
	desc = "An electric mining drill for the especially scrawny."
	var/mythrilPlated = 0

/obj/item/weapon/pickaxe/drill/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack/sheet/mineral/mythril))
		if(istype(src, /obj/item/weapon/pickaxe/drill/jackhammer) || mythrilPlated)
			return
		user << "<span class='notice'>\icon[src]\icon[W]You begin plating [src] with some mythril...</span>"
		if(!do_after(user, 50))
			return
		if(mythrilPlated)
			return
		mythrilPlated = 1
		user << "<span class='notice'>\icon[src]\icon[W]You plate [src]'s head with mythril!</span>"
		name = "mythril-plated [initial(name)]"
		desc = "[initial(desc)] It's been plated with some mythril."
		icon_state = "mythrildrill"
		digspeed -= 10
		digspeed = Clamp(digspeed, 0, INFINITY)
		var/obj/item/stack/sheet/mineral/mythril/A = W
		if(A.amount <= 1)
			user.drop_item()
			qdel(A)
		else
			A.amount--
		return
	..()

/obj/item/weapon/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags = NODROP

/obj/item/weapon/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	digspeed = 10
	origin_tech = "materials=6;powerstorage=4;engineering=5"
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/weapon/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	digspeed = 10

/obj/item/weapon/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	item_state = "jackhammer"
	digspeed = 5 //the epitome of powertools. extremely fast mining, laughs at puny walls
	origin_tech = "materials=3;powerstorage=2;engineering=2"
	digsound = list('sound/weapons/sonic_jackhammer.ogg')
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts, and doubles as a demolition power tool for smashing walls."

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 8.0
	throwforce = 4.0
	item_state = "shovel"
	w_class = 3.0
	m_amt = 50
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	item_state = "spade"
	force = 5.0
	throwforce = 7.0
	w_class = 2.0


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/structure/closet/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "mine cart"
	icon_crate = "miningcar"
	icon_state = "miningcar"


//Monster Bait: Stops any hostile simple animal in its tracks if they're hit by the bait.


/obj/item/weapon/miningBait
	name = "ball of raw meat"
	desc ="A chunk of raw meat used to distract hostile creatures to allow for an escape."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "icecream_strawberry" //Yeah, I improvised >.>
	w_class = 2
	throw_range = 9
	throw_speed = 2

/obj/item/weapon/miningBait/throw_impact(atom/hitAtom)
	..()
	src.visible_message("<span class='warning'>[src] breaks apart upon impact!</span>")
	if(ismob(hitAtom))
		var/mob/living/simple_animal/hostile/M = hitAtom
		if(!istype(M) || !M)
			return
		else
			M.visible_message("<span class='warning'>[M] stops and begins chomping at the remains of [src].</span>", \
					  "<span class='notice'>Free food? Truth be told, you're pretty hungry. Can't let this go to waste...</span>")
			M.LoseAggro()
			M.notransform = 1
			qdel(src)
			sleep(100) //10 seconds
			M.visible_message("<span class='warning'>[M] finishes eating the meat scraps.</span>", \
					  		  "<span class='notice'>That wasn't very filling. Now what were you doing again?</span>")
			M.notransform = 0
	if(src)
		qdel(src)


//CAPTURE SPHERE: Captures a monster for later use. Gotta catch 'em all. Highly WIP, so commented out.


/obj/item/device/captureSphere
	name = "capture sphere"
	desc = "An odd device that can be used to entrap a creature for later release."
	w_class = 2
	icon = 'icons/obj/mining.dmi'
	icon_state = "miningCharge"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 7
	slot_flags = SLOT_BELT
	var/mob/living/simple_animal/capturedMob = null
	var/capturing = 0
	var/newlyCaught = 0

/obj/item/device/captureSphere/attack_hand(mob/user)
	user << "<span class='notice'>You aren't sure what to do with this yet.</span>"
	return
	/*if(capturing)
		return 0
	if(newlyCaught)
		capturedMob.name = stripped_input(usr, "Give a name to the newly-caught monster?", "Monster Capture", "")
		newlyCaught = 0
		name = "[initial(name)] ([capturedMob.name])"
	..()

/obj/item/device/captureSphere/attack_self(mob/user)
	if(capturedMob && capturedMob.loc != src)
		if(!in_range(user, capturedMob))
			return
		capturedMob.visible_message("<span class='warning'>[capturedMob] is sucked into [src]!</span>")
		capturedMob.loc = src
		user.say("[pick("That's enough", "Come back", "Retreat")], [capturedMob.name]!")
		capturedMob.revive() //todo: replace
	..()

/obj/item/device/captureSphere/throw_impact(atom/hitAtom)
	..()
	if(!capturedMob)
		if(ismob(hitAtom))
			Capture(hitAtom)
		return
	if(capturedMob)
		Release(usr)

/obj/item/device/captureSphere/proc/Capture(var/mob/living/simple_animal/M)
	if(M.client || M.key || !istype(M) || !M || capturedMob || capturing)
		return 0
	capturing = 1
	src.visible_message("<span class='warning'>[M] is sucked into [src]!</span>")
	anchored = 1
	M.loc = src
	for(var/i = 0; i < 3; i++)
		sleep(10)
		src.visible_message("<span class='danger'>[src] [pick("jiggles", "wiggles", "spins", "rolls", "bounces")]...</span>")
		playsound(get_turf(src), 'sound/effects/stealthoff.ogg', 50, 1)
		if(prob(M.health))
			playsound(get_turf(src), 'sound/effects/bang.ogg', 50, 1)
			src.visible_message("<span class='warning'>[M] broke free!</span>")
			M.loc = get_turf(src)
			anchored = 0
			capturing = 0
			return 0
	capturedMob = M
	src.visible_message("<span class='notice'>[M] was caught!</span>")
	capturing = 0
	anchored = 0
	newlyCaught = 1
	capturedMob.faction = list("neutral")
	name = "[initial(name)] ([capturedMob.name])"
	return

/obj/item/device/captureSphere/proc/Release(var/mob/user)
	if(!capturedMob)
		return
	if(capturedMob && capturedMob.loc != src)
		return
	user.say("[pick("Go", "Get 'em")], [capturedMob.name]!")
	capturedMob.loc = get_turf(src)
	capturedMob.say("[capturedMob.name]!")
*/


//PORTABLE REFRIGERATOR: Allows storage of hivelord cores to prevent them from decaying.


/obj/item/device/hivelordFridge
	name = "portable refrigerator"
	desc = "A heavy cube used to store hivelord cores for later use. Will indefinitely prevent them from becoming inert."
	w_class = 3
	icon = 'icons/obj/mining.dmi'
	icon_state = "fridgeOff"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 2
	slot_flags = SLOT_BELT
	var/obj/item/asteroid/hivelord_core/storedCore = null

/obj/item/device/hivelordFridge/attack_self(mob/user)
	if(!storedCore)
		return
	user.visible_message("<span class='notice'>[user] removes [storedCore] from [src].</span>", \
						 "<span class='notice'>\icon[src]You pop open [src] and remove [storedCore].</span>")
	if(!user.put_in_hands(storedCore))
		storedCore.loc = get_turf(user)
	storedCore.preserved = 0
	storedCore = null
	icon_state = "fridgeOff"
	..()

/obj/item/device/hivelordFridge/examine(mob/user)
	..()
	if(storedCore)
		user << "<span class='notice'>It has\icon [storedCore][storedCore] loaded.</span>"
	else
		user << "<span class='notice'>Nothing is loaded.</span>"

/obj/item/device/hivelordFridge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/asteroid/hivelord_core) && !storedCore)
		var/obj/item/asteroid/hivelord_core/H = W
		user.visible_message("<span class='notice'>[user] places [H] into [src].</span>", \
							 "\icon[src]<span class='notice'>You place [H] into [src] and close it with a hiss of cold air.</span>")
		user.drop_item()
		H.loc = src
		icon_state = "fridgeOn"
		playsound(src, 'sound/machines/hiss.ogg', 50, 0, 0)
		H.preserved = 1
		storedCore = H
		return
	..()


//MINING CHARGE: Slap it in rocks to cause a controlled explosion. Can be emagged to slap on other things.


/obj/item/device/miningCharge
	name = "standard mining charge"
	desc = "A pyrotechnical device used to cause controlled explosions for digging tunnels without manual labor. It can only be attached to rocks and mineral deposits."
	w_class = 2
	icon = 'icons/obj/mining.dmi'
	icon_state = "miningCharge"
	item_state = "electronic"
	throw_speed = 3
	throw_range = 5
	slot_flags = SLOT_BELT
	var/detonating = 0 //If the charge is currently primed
	var/safety = 1 //If the charge can be put on things other than rocks
	var/explosionPower = 2 //The power of the explosion; larger powers = bigger boom
	var/atom/movable/putOn = null //The atom the charge is on
	var/primedOverlay = null

/obj/item/device/miningCharge/emag_act(mob/user)
	if(!safety)
		return
	user << "<span class='warning'>You press the cryptographic sequencer onto [src], disabling its safeties.</span>"
	safety = 0
	explosionPower-- //Makes them less powerful when you emag them - for balance

/obj/item/device/miningCharge/New()
	..()
	primedOverlay = image('icons/obj/mining.dmi', "miningCharge_active")

/obj/item/device/miningCharge/examine(mob/user)
	..()
	user << "A small LED is blinking [safety ? "green" : "red"]."
	if(detonating)
		user << "It appears to be primed."

/obj/item/device/miningCharge/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/screwdriver) && !safety)
		user << "<span class='notice'>You restore the safeties on [src].</span>"
		safety = 1
		return
	..()

/obj/item/device/miningCharge/attack_hand(mob/user)
	if(detonating)
		return
	..()

/obj/item/device/miningCharge/afterattack(atom/movable/target, mob/user, flag)
	if(!istype(target, /turf/simulated/mineral) && safety)
		return
	if(!in_range(user, target))
		return
	user.visible_message("<span class='notice'>[user] starts placing [src] onto [target].</span>", \
						 "<span class='notice'>You start placing the charge.</span>")
	if(do_after(user, 30 && in_range(user, target)))
		user.visible_message("<span class='notice'>[user] places [src] onto [target].</span>", \
							 "<span class='warning'>You slap [src] onto [target]!</span>")
		user.drop_item()
		if(ismob(target))
			var/mob/living/M = target
			M << "<span class='boldannounce'>[src]'s clamps dig into you!</span>" //Fluff
		loc = target
		putOn = target
		anchored = 1
		icon_state = "miningCharge_active"
		target.overlays += primedOverlay
		Detonate()

/obj/item/device/miningCharge/proc/Detonate(var/timer = 5)
	icon_state = "miningCharge_active"
	update_icon()
	detonating = 1
	luminosity = 1
	for(var/i = 0, i < timer, i++)
		sleep(10)
		playsound(get_turf(src), 'sound/machines/defib_saftyOff.ogg', 50, 1)
	sleep(10)
	playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 100, 1)
	sleep(20)
	if(putOn)
		loc = get_turf(putOn)
	src.visible_message("<span class='boldannounce'>[src] explodes!</span>")
	switch(explosionPower)
		if(-INFINITY to 0)
			explosion(src.loc,-1,0,3)
		if(1)
			explosion(src.loc,-1,1,6)
		if(2)
			explosion(src.loc,-1,2,9)
		if(3 to INFINITY)
			explosion(src.loc,-1,4,12)
	if(putOn)
		putOn.overlays -= primedOverlay
		putOn = null
	if(src) //In case it survived
		qdel(src)

/obj/item/device/miningCharge/small
	name = "compact mining charge"
	desc = "A smaller mining charge that weighs less at the cost of a less powerful explosion."
	w_class = 1
	explosionPower = 1

/obj/item/weapon/storage/box/miningCharges
	name = "box of mining charges"
	desc = "A box shaped to hold mining charges."
	can_hold = list(/obj/item/device/miningCharge/)

/obj/item/weapon/storage/box/miningCharges/New()
	..()
	contents = list()
	new /obj/item/device/miningCharge(src)
	new /obj/item/device/miningCharge(src)
	new /obj/item/device/miningCharge/small(src)
	new /obj/item/device/miningCharge/small(src)
	new /obj/item/device/miningCharge/small(src)
	new /obj/item/device/miningCharge/small(src)
	new /obj/item/device/miningCharge/small(src)
	return

