
// Clown Operative Stuff
// Maybe someday, someone will care to maintain this

/datum/uplink_item/weapon_kits/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 10
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/weapon_kits/bananashield
	name = "Bananium Energy Shield"
	desc = "A clown's most powerful defensive weapon, this personal shield provides near immunity to ranged energy attacks \
		by bouncing them back at the ones who fired them. It can also be thrown to bounce off of people, slipping them, \
		and returning to you even if you miss. WARNING: DO NOT ATTEMPT TO STAND ON SHIELD WHILE DEPLOYED, EVEN IF WEARING ANTI-SLIP SHOES."
	item = /obj/item/shield/energy/bananium
	cost = 16
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/weapon_kits/clownsword
	name = "Bananium Energy Sword"
	desc = "An energy sword that deals no damage, but will slip anyone it contacts, be it by melee attack, thrown \
		impact, or just stepping on it. Beware friendly fire, as even anti-slip shoes will not protect against it."
	item = /obj/item/melee/energy/sword/bananium
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/weapon_kits/clownoppin
	name = "Ultra Hilarious Firing Pin"
	desc = "A firing pin that, when inserted into a gun, makes that gun only useable by clowns and clumsy people and makes that gun honk whenever anyone tries to fire it."
	cost = 1 //much cheaper for clown ops than for clowns
	item = /obj/item/firing_pin/clown/ultra
	purchasable_from = UPLINK_CLOWN_OPS
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/weapon_kits/clownopsuperpin
	name = "Super Ultra Hilarious Firing Pin"
	desc = "Like the ultra hilarious firing pin, except the gun you insert this pin into explodes when someone who isn't clumsy or a clown tries to fire it."
	cost = 4 //much cheaper for clown ops than for clowns
	item = /obj/item/firing_pin/clown/ultra/selfdestruct
	purchasable_from = UPLINK_CLOWN_OPS
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND

/datum/uplink_item/weapon_kits/foamsmg
	name = "Toy Submachine Gun"
	desc = "A fully-loaded Donksoft bullpup submachine gun that fires riot grade darts with a 20-round magazine."
	item = /obj/item/gun/ballistic/automatic/c20r/toy
	cost = 5
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/weapon_kits/foammachinegun
	name = "Toy Machine Gun"
	desc = "A fully-loaded Donksoft belt-fed machine gun. This weapon has a massive 50-round magazine of devastating \
		riot grade darts, that can briefly incapacitate someone in just one volley."
	item = /obj/item/gun/ballistic/automatic/l6_saw/toy
	cost = 10
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/explosives/bombanana
	name = "Bombanana"
	desc = "A banana with an explosive taste! discard the peel quickly, as it will explode with the force of a Syndicate minibomb \
		a few seconds after the banana is eaten."
	item = /obj/item/food/grown/banana/bombanana
	cost = 4 //it is a bit cheaper than a minibomb because you have to take off your helmet to eat it, which is how you arm it
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/explosives/clown_bomb_clownops
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
		with a minimum of %MIN_BOMB_TIMER seconds, and can be bolted to the floor with a wrench to prevent \
		movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
		transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
		be defused, and some crew may attempt to do so."
	item = /obj/item/sbeacondrop/clownbomb
	cost = 15
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/explosives/clown_bomb_clownops/New()
	. = ..()
	desc = replacetext(desc, "%MIN_BOMB_TIMER", SYNDIEBOMB_MIN_TIMER_SECONDS)

/datum/uplink_item/explosives/tearstache
	name = "Teachstache Grenade"
	desc = "A teargas grenade that launches sticky moustaches onto the face of anyone not wearing a clown or mime mask. The moustaches will \
		remain attached to the face of all targets for one minute, preventing the use of breath masks and other such devices."
	item = /obj/item/grenade/chem_grenade/teargas/moustache
	cost = 3
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS | UPLINK_SPY

/datum/uplink_item/explosives/pinata
	name = "Weapons Grade Pinata Kit"
	desc = "A pinata filled with both candy and explosives as well as two belts to carry them on, crack it open and see what you get!"
	item = /obj/item/storage/box/syndie_kit/pinata
	purchasable_from = UPLINK_CLOWN_OPS
	limited_stock = 1
	cost = 12 //This is effectively the clown ops version of the grenadier belt where you should on average get 8 explosives if you use a weapon with exactly 10 force.
	surplus = 0

/datum/uplink_item/reinforcement/clown_reinforcement
	name = "Clown Reinforcements"
	desc = "Call in an additional clown to share the fun, equipped with full starting gear, but no telecrystals."
	item = /obj/item/antag_spawner/nuke_ops/clown
	cost = 20
	purchasable_from = UPLINK_CLOWN_OPS
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/reinforcement/monkey_agent
	name = "Simian Agent Reinforcements"
	desc = "Call in an extremely well trained monkey secret agent from our Syndicate Banana Department. \
		They've been trained to operate machinery and can read, but they can't speak Common."
	item = /obj/item/antag_spawner/loadout/monkey_man
	cost = 7
	purchasable_from = UPLINK_CLOWN_OPS
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/reinforcement/monkey_supplies
	name = "Simian Agent Supplies"
	desc = "Sometimes you need a bit more firepower than a rabid monkey. Such as a rabid, armed monkey! \
		Monkeys can unpack this kit to receive a bag with a bargain-bin gun, ammunition, and some miscellaneous supplies."
	item = /obj/item/storage/toolbox/guncase/monkeycase
	cost = 4
	purchasable_from = UPLINK_CLOWN_OPS
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/mech/honker
	name = "Dark H.O.N.K."
	desc = "A clown combat mech equipped with bombanana peel and tearstache grenade launchers, as well as the ubiquitous HoNkER BlAsT 5000."
	item = /obj/vehicle/sealed/mecha/honker/dark/loaded
	cost = 80
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/stealthy_tools/combatbananashoes
	name = "Combat Banana Shoes"
	desc = "While making the wearer immune to most slipping attacks like regular combat clown shoes, these shoes \
		can generate a large number of synthetic banana peels as the wearer walks, slipping up would-be pursuers. They also \
		squeak significantly louder."
	item = /obj/item/clothing/shoes/clown_shoes/banana_shoes/combat
	cost = 6
	surplus = 0
	purchasable_from = UPLINK_CLOWN_OPS

/datum/uplink_item/badass/clownopclumsinessinjector //clowns can buy this too, but it's in the role-restricted items section for them
	name = "Clumsiness Injector"
	desc = "Inject yourself with this to become as clumsy as a clown... or inject someone ELSE with it to make THEM as clumsy as a clown. Useful for clown operatives who wish to reconnect with their former clownish nature or for clown operatives who wish to torment and play with their prey before killing them."
	item = /obj/item/dnainjector/clumsymut
	cost = 1
	purchasable_from = UPLINK_CLOWN_OPS
	uplink_item_flags = SYNDIE_TRIPS_CONTRABAND
