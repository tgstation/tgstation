/datum/uplink_category/role_restricted
	name = "Role-Restricted"
	weight = 1

/datum/uplink_item/role_restricted
	category = /datum/uplink_category/role_restricted
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/role_restricted/haunted_magic_eightball
	name = "Haunted Magic Eightball"
	desc = "Most magic eightballs are toys with dice inside. Although identical in appearance to the harmless toys, this occult device reaches into the spirit world to find its answers. \
			Be warned, that spirits are often capricious or just little assholes. To use, simply speak your question aloud, then begin shaking."
	item = /obj/item/toy/eightball/haunted
	cost = 2
	restricted_roles = list(JOB_CURATOR)
	limited_stock = 1 //please don't spam deadchat
	surplus = 5

/datum/uplink_item/role_restricted/mail_counterfeit_kit
	name = "GLA Brand Mail Counterfeit Kit"
	desc = "A box full of mail counterfeit devices. Devices that actually able to counterfeit NT's mail. Those devices also able to place a trap inside of mail for malicious actions. Trap will \"activate\" any item inside of mail. Also counterfieted mail might be used for contraband purposes. Integrated micro-computer will give you great configuration optionality for your needs. \nNothing stops the mail."
	item = /obj/item/storage/box/syndie_kit/mail_counterfeit
	cost = 2
	illegal_tech = FALSE
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	surplus = 5

/datum/uplink_item/role_restricted/bureaucratic_error
	name = "Organic Capital Disturbance Virus"
	desc = "Randomizes job positions presented to new hires. May lead to too many/too few security officers and/or clowns. Single use."
	item = ABSTRACT_UPLINK_ITEM
	surplus = 0
	limited_stock = 1
	cost = 2
	restricted = TRUE
	restricted_roles = list(JOB_HEAD_OF_PERSONNEL, JOB_QUARTERMASTER)

/datum/uplink_item/role_restricted/bureaucratic_error/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	force_event(/datum/round_event_control/bureaucratic_error, "a syndicate virus")
	return source

/datum/uplink_item/role_restricted/clumsinessinjector //clown ops can buy this too, but it's in the pointless badassery section for them
	name = "Clumsiness Injector"
	desc = "Inject yourself with this to become as clumsy as a clown... or inject someone ELSE with it to make THEM as clumsy as a clown. Useful for clowns who wish to reconnect with their former clownish nature or for clowns who wish to torment and play with their prey before killing them."
	item = /obj/item/dnainjector/clumsymut
	cost = 1
	restricted_roles = list(JOB_CLOWN)
	illegal_tech = FALSE
	surplus = 25

/datum/uplink_item/role_restricted/ancient_jumpsuit
	name = "Ancient Jumpsuit"
	desc = "A tattered old jumpsuit that will provide absolutely no benefit to you."
	item = /obj/item/clothing/under/color/grey/ancient
	cost = 20
	restricted_roles = list(JOB_ASSISTANT)
	surplus = 0
	purchasable_from = ~UPLINK_SPY // Fuck you, baltimore!

/datum/uplink_item/role_restricted/oldtoolboxclean
	name = "Ancient Toolbox"
	desc = "An iconic toolbox design notorious with Assistants everywhere, this design was especially made to become more robust the more telecrystals it has inside it! Tools and insulated gloves included."
	item = /obj/item/storage/toolbox/mechanical/old/clean
	cost = 2
	restricted_roles = list(JOB_ASSISTANT)
	surplus = 0
	purchasable_from = ~UPLINK_SPY // Spies can't get telecrystals?

/datum/uplink_item/role_restricted/clownpin
	name = "Ultra Hilarious Firing Pin"
	desc = "A firing pin that, when inserted into a gun, makes that gun only usable by clowns and clumsy people and makes that gun honk whenever anyone tries to fire it."
	cost = 4
	item = /obj/item/firing_pin/clown/ultra
	restricted_roles = list(JOB_CLOWN)
	illegal_tech = FALSE
	surplus = 25

/datum/uplink_item/role_restricted/clownsuperpin
	name = "Super Ultra Hilarious Firing Pin"
	desc = "Like the ultra hilarious firing pin, except the gun you insert this pin into explodes when someone who isn't clumsy or a clown tries to fire it."
	cost = 7
	item = /obj/item/firing_pin/clown/ultra/selfdestruct
	restricted_roles = list(JOB_CLOWN)
	illegal_tech = FALSE
	surplus = 25

/datum/uplink_item/role_restricted/syndimmi
	name = "Syndicate Brand MMI"
	desc = "An MMI modified to give cyborgs laws to serve the Syndicate without having their interface damaged by Cryptographic Sequencers, this will not unlock their hidden modules."
	item = /obj/item/mmi/syndie
	cost = 2
	restricted_roles = list(JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_CORONER, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER)
	surplus = 0

/datum/uplink_item/role_restricted/explosive_hot_potato
	name = "Exploding Hot Potato"
	desc = "A potato rigged with explosives. On activation, a special mechanism is activated that prevents it from being dropped. \
			The only way to get rid of it if you are holding it is to attack someone else with it, causing it to latch to that person instead."
	item = /obj/item/hot_potato/syndicate
	cost = 4
	restricted_roles = list(JOB_COOK, JOB_BOTANIST, JOB_CLOWN, JOB_MIME)

/datum/uplink_item/role_restricted/combat_baking
	name = "Combat Bakery Kit"
	desc = "A kit of clandestine baked weapons. Contains a baguette which a skilled mime could use as a sword, \
		a pair of throwing croissants, and the recipe to make more on demand. Once the job is done, eat the evidence."
	progression_minimum = 15 MINUTES
	item = /obj/item/storage/box/syndie_kit/combat_baking
	cost = 7
	restricted_roles = list(JOB_COOK, JOB_MIME)

/datum/uplink_item/role_restricted/ez_clean_bundle
	name = "EZ Clean Grenade Bundle"
	desc = "A box with three cleaner grenades using the trademark Waffle Co. formula. Serves as a cleaner and causes acid damage to anyone standing nearby. \
			The acid only affects carbon-based creatures."
	item = /obj/item/storage/box/syndie_kit/ez_clean
	cost = 6
	surplus = 20
	restricted_roles = list(JOB_JANITOR)

/datum/uplink_item/role_restricted/reverse_bear_trap
	name = "Reverse Bear Trap"
	desc = "An ingenious execution device worn on (or forced onto) the head. Arming it starts a 1-minute kitchen timer mounted on the bear trap. When it goes off, the trap's jaws will \
	violently open, instantly killing anyone wearing it by tearing their jaws in half. To arm, attack someone with it while they're not wearing headgear, and you will force it onto their \
	head after three seconds uninterrupted."
	cost = 5
	item = /obj/item/reverse_bear_trap
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/modified_syringe_gun
	name = "Modified Syringe Gun"
	desc = "A syringe gun that fires DNA injectors instead of normal syringes."
	item = /obj/item/gun/syringe/dna
	cost = 14
	restricted_roles = list(JOB_GENETICIST, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/meathook
	name = "Butcher's Meat Hook"
	desc = "A brutal cleaver on a long chain, it allows you to pull people to your location."
	item = /obj/item/gun/magic/hook
	cost = 11
	restricted_roles = list(JOB_COOK)

/datum/uplink_item/role_restricted/turretbox
	name = "Disposable Sentry Gun"
	desc = "A disposable sentry gun deployment system cleverly disguised as a toolbox, apply wrench for functionality."
	item = /obj/item/storage/toolbox/emergency/turret
	cost = 11
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/rebarxbowsyndie
	name = "Syndicate Rebar Crossbow"
	desc = "A much more proffessional version of the engineer's bootleg rebar crossbow. 3 shot mag, quicker loading, and better ammo. Owners manual included."
	item = /obj/item/storage/box/syndie_kit/rebarxbowsyndie
	cost = 10
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/magillitis_serum
	name = "Magillitis Serum Autoinjector"
	desc = "A single-use autoinjector which contains an experimental serum that causes rapid muscular growth in Hominidae. \
			Side-affects may include hypertrichosis, violent outbursts, and an unending affinity for bananas. \
			Now also contains regenerative chemicals to keep users healthy as they exercise their newfound muscles."
	item = /obj/item/reagent_containers/hypospray/medipen/magillitis
	cost = 15
	restricted_roles = list(JOB_GENETICIST, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/gorillacube
	name = "Gorilla Cube"
	desc = "A Waffle Co. brand gorilla cube. Eat big to get big. \
			Caution: Product may rehydrate when exposed to water."
	item = /obj/item/food/monkeycube/gorilla
	cost = 6
	restricted_roles = list(JOB_GENETICIST, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/brainwash_disk
	name = "Brainwashing Surgery Program"
	desc = "A disk containing the procedure to perform a brainwashing surgery, allowing you to implant an objective onto a target. \
	Insert into an Operating Console to enable the procedure."
	item = /obj/item/disk/surgery/brainwashing
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_CORONER, JOB_ROBOTICIST)
	cost = 5
	surplus = 50

/datum/uplink_item/role_restricted/advanced_plastic_surgery
	name = "Advanced Plastic Surgery Program"
	desc = "A bootleg copy of an collector item, this disk contains the procedure to perform advanced plastic surgery, allowing you to model someone's face and voice based on a picture taken by a camera on your offhand. \
	All changes are superficial and does not change ones genetic makeup. \
	Insert into an Operating Console to enable the procedure."
	item = /obj/item/disk/surgery/advanced_plastic_surgery
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER, JOB_ROBOTICIST)
	cost = 1
	surplus = 50

/datum/uplink_item/role_restricted/springlock_module
	name = "Heavily Modified Springlock MODsuit Module"
	desc = "A module that spans the entire size of the MOD unit, sitting under the outer shell. \
		This mechanical exoskeleton pushes out of the way when the user enters and it helps in booting \
		up, but was taken out of modern suits because of the springlock's tendency to \"snap\" back \
		into place when exposed to humidity. You know what it's like to have an entire exoskeleton enter you? \
		This version of the module has been modified to allow for near instant activation of the MODsuit. \
		Useful for quickly getting your MODsuit on/off, or for taking care of a target via a tragic accident."
	item = /obj/item/mod/module/springlock/bite_of_87
	restricted_roles = list(JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR)
	cost = 2
	surplus = 15

/datum/uplink_item/role_restricted/reverse_revolver
	name = "Reverse Revolver"
	desc = "A revolver that always fires at its user. \"Accidentally\" drop your weapon, then watch as the greedy corporate pigs blow their own brains all over the wall. \
	The revolver itself is actually real. Only clumsy people, and clowns, can fire it normally. Comes in a box of hugs. Honk."
	progression_minimum = 30 MINUTES
	cost = 14
	item = /obj/item/storage/box/hug/reverse_revolver
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/pressure_mod
	name = "Kinetic Accelerator Pressure Mod"
	desc = "A modification kit which allows Kinetic Accelerators to do greatly increased damage while indoors. \
			Occupies 35% mod capacity."
	// While less deadly than a revolver it does have infinite ammo
	progression_minimum = 15 MINUTES
	item = /obj/item/borg/upgrade/modkit/indoors
	cost = 5 //you need two for full damage, so total of 10 for maximum damage
	limited_stock = 2 //you can't use more than two!
	restricted_roles = list("Shaft Miner")
	surplus = 20

/datum/uplink_item/role_restricted/mimery
	name = "Guide to Advanced Mimery Series"
	desc = "The classical two part series on how to further hone your mime skills. Upon studying the series, the user should be able to make 3x1 invisible walls, and shoot bullets out of their fingers. \
			Obviously only works for Mimes."
	cost = 12
	item = /obj/item/storage/box/syndie_kit/mimery
	restricted_roles = list(JOB_MIME)
	surplus = 0

/datum/uplink_item/role_restricted/laser_arm
	name = "Laser Arm Implant"
	desc = "An implant that grants you a recharging laser gun inside your arm. Weak to EMPs. Comes with a syndicate autosurgeon for immediate self-application."
	progression_minimum = 20 MINUTES
	cost = 10
	item = /obj/item/autosurgeon/syndicate/laser_arm
	restricted_roles = list(JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR)
	surplus = 20

/datum/uplink_item/role_restricted/chemical_gun
	name = "Reagent Dartgun"
	desc = "A heavily modified syringe gun which is capable of synthesizing its own chemical darts using input reagents. Can hold 90u of reagents."
	progression_minimum = 15 MINUTES
	item = /obj/item/gun/chem
	cost = 12
	restricted_roles = list(JOB_CHEMIST, JOB_CHIEF_MEDICAL_OFFICER, JOB_BOTANIST)

/datum/uplink_item/role_restricted/pie_cannon
	name = "Banana Cream Pie Cannon"
	desc = "A special pie cannon for a special clown, this gadget can hold up to 20 pies and automatically fabricates one every two seconds!"
	cost = 10
	item = /obj/item/pneumatic_cannon/pie/selfcharge
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/clown_bomb
	name = "Clown Bomb"
	desc = "The Clown bomb is a hilarious device capable of massive pranks. It has an adjustable timer, \
		with a minimum of %MIN_BOMB_TIMER seconds, and can be bolted to the floor with a wrench to prevent \
		movement. The bomb is bulky and cannot be moved; upon ordering this item, a smaller beacon will be \
		transported to you that will teleport the actual bomb to it upon activation. Note that this bomb can \
		be defused, and some crew may attempt to do so."
	progression_minimum = 15 MINUTES
	item = /obj/item/sbeacondrop/clownbomb
	cost = 15
	restricted_roles = list(JOB_CLOWN)
	surplus = 10

/datum/uplink_item/role_restricted/clown_bomb/New()
	. = ..()
	desc = replacetext(desc, "%MIN_BOMB_TIMER", SYNDIEBOMB_MIN_TIMER_SECONDS)

/datum/uplink_item/role_restricted/clowncar
	name = "Clown Car"
	desc = "The Clown Car is the ultimate transportation method for any worthy clown! \
			Simply insert your bikehorn and get in, and get ready to have the funniest ride of your life! \
			You can ram any spacemen you come across and stuff them into your car, kidnapping them and locking them inside until \
			someone saves them or they manage to crawl out. Be sure not to ram into any walls or vending machines, as the springloaded seats \
			are very sensitive. Now with our included lube defense mechanism which will protect you against any angry shitcurity! \
			Premium features can be unlocked with a cryptographic sequencer!"
	item = /obj/vehicle/sealed/car/clowncar
	cost = 20
	restricted_roles = list(JOB_CLOWN)
	surplus = 10

/datum/uplink_item/role_restricted/clowncar/spawn_item_for_generic_use(mob/user)
	var/obj/vehicle/sealed/car/clowncar/car = ..()
	car.enforce_clown_role = FALSE
	var/obj/item/key = new car.key_type(user.loc)
	car.visible_message(span_notice("[key] drops out of [car] onto the floor."))
	return car

/datum/uplink_item/role_restricted/his_grace
	name = "His Grace"
	desc = "An incredibly dangerous weapon recovered from a station overcome by the grey tide. Once activated, He will thirst for blood and must be used to kill to sate that thirst. \
	His Grace grants gradual regeneration and complete stun immunity to His wielder, but be wary: if He gets too hungry, He will become impossible to drop and eventually kill you if not fed. \
	However, if left alone for long enough, He will fall back to slumber. \
	To activate His Grace, simply unlatch Him."
	lock_other_purchases = TRUE
	cant_discount = TRUE
	item = /obj/item/his_grace
	cost = 20
	surplus = 0
	restricted_roles = list(JOB_CHAPLAIN)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/concealed_weapon_bay
	name = "Concealed Weapon Bay"
	desc = "A modification for non-combat exosuits that allows them to equip one piece of equipment designed for combat units. \
			Attach to an exosuit with an existing equipment to disguise the bay as that equipment. The sacrificed equipment will be lost.\
			Alternatively, you can attach the bay to an empty equipment slot, but the bay will not be concealed. Once the bay is \
			attached, an exosuit weapon can be fitted inside."
	progression_minimum = 30 MINUTES
	item = /obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay
	cost = 3
	restricted_roles = list(JOB_ROBOTICIST, JOB_RESEARCH_DIRECTOR)
	surplus = 15

/datum/uplink_item/role_restricted/spider_injector
	name = "Australicus Slime Mutator"
	desc = "Crikey mate, it's been a wild travel from the Australicus sector but we've managed to get \
			some special spider extract from the giant spiders down there. Use this injector on a gold slime core \
			to create a few of the same type of spiders we found on the planets over there. They're a bit tame until you \
			also give them a bit of sentience though."
	progression_minimum = 30 MINUTES
	item = /obj/item/reagent_containers/syringe/spider_extract
	cost = 10
	restricted_roles = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST)
	surplus = 10

/datum/uplink_item/role_restricted/blastcannon
	name = "Blast Cannon"
	desc = "A highly specialized weapon, the Blast Cannon is actually relatively simple. It contains an attachment for a tank transfer valve mounted to an angled pipe specially constructed \
			withstand extreme pressure and temperatures, and has a mechanical trigger for triggering the transfer valve. Essentially, it turns the explosive force of a bomb into a narrow-angle \
			blast wave \"projectile\". Aspiring scientists may find this highly useful, as forcing the pressure shockwave into a narrow angle seems to be able to bypass whatever quirk of physics \
			disallows explosive ranges above a certain distance, allowing for the device to use the theoretical yield of a transfer valve bomb, instead of the factual yield. It's simple design makes it easy to conceal."
	progression_minimum = 30 MINUTES
	item = /obj/item/gun/blastcannon
	cost = 14 //High cost because of the potential for extreme damage in the hands of a skilled scientist.
	restricted_roles = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST)
	surplus = 5

/datum/uplink_item/role_restricted/evil_seedling
	name = "Evil Seedling"
	desc = "A rare seed we have recovered that grows into a dangerous species that will aid you with your tasks!"
	item = /obj/item/seeds/seedling/evil
	cost = 8
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/bee_smoker
	name = "Bee Smoker"
	desc = "A device that runs on cannabis, turning it into a gas that can hypnotize bees to follow our commands."
	item = /obj/item/bee_smoker
	cost = 4
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/monkey_agent
	name = "Simian Agent Reinforcements"
	desc = "Call in an extremely well trained monkey secret agent from our Syndicate Banana Department. \
		They've been trained to operate machinery and can read, but they can't speak Common. \
		Please note that these are free-range monkeys that don't react with Mutadone."
	item = /obj/item/antag_spawner/loadout/monkey_man
	cost = 6
	restricted_roles = list(JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_GENETICIST, JOB_ASSISTANT, JOB_MIME, JOB_CLOWN)
	restricted = TRUE
	refundable = TRUE

/datum/uplink_item/role_restricted/monkey_supplies
	name = "Simian Agent Supplies"
	desc = "Sometimes you need a bit more firepower than a rabid monkey. Such as a rabid, armed monkey! \
		Monkeys can unpack this kit to receive a bag with a bargain-bin gun, ammunition, and some miscellaneous supplies."
	item = /obj/item/storage/toolbox/guncase/monkeycase
	cost = 4
	limited_stock = 3
	restricted_roles = list(JOB_ASSISTANT, JOB_MIME, JOB_CLOWN)
	restricted = TRUE
	refundable = FALSE


/datum/uplink_item/role_restricted/reticence
	name = "Reticence Cloaked Assasination exosuit"
	desc = "A silent, fast, and nigh-invisible but exceptionally fragile miming exosuit! \
	fully equipped with a near-silenced pistol, and a RCD for your best assasination needs, Does not include tools, No refunds."
	item = /obj/vehicle/sealed/mecha/reticence/loaded
	cost = 20
	restricted_roles = list(JOB_MIME)
	restricted = TRUE
	refundable = FALSE
	purchasable_from = parent_type::purchasable_from & ~UPLINK_SPY



/datum/uplink_item/role_restricted/gondola_donk_pocket_box
	name = "Gondola-Flavoured Donk Pockets"
	desc = "A box with 6 gondola pockets within it. Gondola pockets contain a chemical called Tranquility, which will inflict a disease upon consumption. \
			Those afflicted by this disease will inevitably turn into gondola's themselves. It's probably best you don't eat these."
	item = /obj/item/storage/box/donkpockets/donkpocketgondola
	cost = 4
	surplus = 7
	restricted_roles = list(JOB_COOK, JOB_CLOWN, JOB_MIME)

/datum/uplink_item/role_restricted/chef_chem_bottles
	name = "Chef-Specialized Poisons Kit"
	desc = "A box containing two bottles of four types of deadly chemicals. As a chef, you ought to spike your food or drinks or find a different means of application. \
			Chemicals include: Fentanyl, Cyanide, Coniine, and Amanitin."
	item = /obj/item/storage/box/syndie_kit/chefchemicals
	cost = 5
	surplus = 12
	restricted_roles = list(JOB_COOK)

/datum/uplink_item/role_restricted/suspicious_plant_bag
	name = "Assorted Plant Bag"
	desc = "A regular, nanotrasen approved plant bag from one of the vendors. It includes several mutated plant produce ready to use or be turned into seeds. \
			Included within are the: Death Nettle, Poison Berry, Death Berry, Deathweed, Mimana, Bluespace Banana, Combustible Lemon, Bungo Fruit, Destroying Angel, Killer Tomato, and a Replica Pod seed."
	item = /obj/item/storage/bag/plants/syndie
	cost = 5
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/bluespace_plant_bag
	name = "Bluespace Plant Bag"
	desc = "A regular, nanotrasen approved plant bag from one of the vendors. We've augmented the bag with bluespace technology, allowing for nearly infinite storage. \
			The bag however, still only accepts your typical plant bag items."
	item = /obj/item/storage/bag/plants/bluespace
	cost = 7
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/eternal_mutagen
	name = "Eternal Flask of Unstable Mutagen"
	desc = "A bottle that's only glass-like in appearance. The container itself harbors redspace technology \
			that will fill the container slowly over time with Unstable Mutagen for a maximum of 50 units."
	item = /obj/item/reagent_containers/cup/bottle/eternal/mutagen
	cost = 1
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/gatfruit_seed
	name = "Gatfruit Seed Packet"
	desc = "A single seed packet of the fabled Gatfruit. These seeds take a LONG time to grow, and start off fragile. \
			Gatfruit can be converted into a fully loaded .357 Revolver. Be warned that leaving behind a trail of revolvers will likely let everyone know what's up!"
	item = /obj/item/seeds/gatfruit
	cost = 8
	surplus = 5
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/cherry_bomb_seed
	name = "Cherry Bomb Seed Packet"
	desc = "A single seed packet of Cherry Bombs. The cherries are HIGHLY explosive and cause massive damage. \
			You're gonna wanna keep your distance and ensure nobody nabs your harvest."
	item = /obj/item/seeds/cherry/bomb
	cost = 16
	surplus = 3
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/bombanana_seed
	name = "Bombanana Seed Packet"
	desc = "A single seed packet of the clownly Bombanana. Bombanana's grown are about as effective as a syndicate minibomb. \
			Peel them to activate them. Bombs are identical to regular bananas."
	item = /obj/item/seeds/banana/bombanana
	cost = 20
	surplus = 1
	restricted_roles = list(JOB_BOTANIST, JOB_CLOWN)

/datum/uplink_item/role_restricted/kudzu_seed
	name = "Kudzu Seed Packet"
	desc = "A single seed packet of the Kudzu vine species. These seeds can be planted outside of a tray to cause havoc. \
			Giving kudzu a high amount of potency will make them even more devastating. Great for a massive distraction."
	item = /obj/item/seeds/kudzu
	cost = 3
	surplus = 15
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/floragun_syndicate
	name = "Disguised Laser Gun"
	desc = "A laser pistol with both stun and lethal capabilities, it's been disguised as a floral somatoray for easy concealment. \
			Also functions as a regular floral somatoray."
	item = /obj/item/gun/energy/floragun/syndicate
	cost = 7
	surplus = 5
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/syndie_relief_bundle
	name = "Syndicate Relief Package"
	desc = "Thanks for taking the fall for one of our other agents, as per your payment you may claim an additional 10 telecrystals at your leisure."
	item = /obj/item/storage/box/syndie_kit/syndie_relief_bundle
	cost = 0
	cant_discount = TRUE
	limited_stock = 1
	restricted_roles = list(JOB_PRISONER)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/twoforone_freedom_implant
	name = "Two-For-One Freedom Implant Bundle"
	desc = "Two freedom implants for the price of one. Be sure to grant one to a friend -- if you find any."
	item = /obj/item/storage/box/syndie_kit/two_freedom_implant_bundle
	cost = 5
	restricted_roles = list(JOB_PRISONER)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/microbomb_prisoner_implanter
	name = "Microbomb Implanter"
	desc = "Give me liberty or give me death. \
	       This microbomb implanter can be used at any time to commit suicide in style, it'll also destroy your items to prevent security from reclaiming anything TOO useful."
	item = /obj/item/storage/box/syndie_kit/imp_microbomb
	cost = 2
	surplus = 10
	restricted_roles = list(JOB_PRISONER)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/bluespace_crystal_arti_bundle
	name = "Box of Artificial Bluespace Crystals"
	desc = "A cardboard box containing approximately 25 artificial bluespace crystals. Crush them in-hand to randomly teleport somewhere nearby."
	item = /obj/item/storage/box/syndie_kit/bluespace_crystal_arti_bundle
	cost = 1
	surplus = 25
	restricted_roles = list(JOB_PRISONER, JOB_RESEARCH_DIRECTOR, JOB_SCIENTIST, JOB_ROBOTICIST)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/escapist_bundle
	name = "Escapist Bundle"
	desc = "Everything you'll need to escape and assume a new identity. Comes with a Chameleon Kit, Agent Card, Sleepy Pen, \
            Airlock Override Card, Thermal Imaging Glasses, Uplink Implant, Energy Dagger and 4 C4 charges."
	item = /obj/item/storage/box/syndie_kit/escapist_bundle
	cost = 20
	surplus = 1
	restricted_roles = list(JOB_PRISONER)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/chemistry_machine_bundle
	name = "Supplementary Chemical Dispensery"
	desc = "Can't afford to work under supervision? We've got you covered. Purchasing this bundle includes all of the electronic boards \
			required for chemistry, and enough tier 4 parts to maximize your work. Doesn't come with it's own power-setup."
	item = /obj/item/storage/box/syndie_kit/chemistry_machine_bundle
	cost = 4
	surplus = 20
	restricted_roles = list(JOB_CHEMIST, JOB_PSYCHOLOGIST, JOB_CHIEF_MEDICAL_OFFICER, JOB_BARTENDER)

/datum/uplink_item/role_restricted/xenobio_starter_kit
	name = "Xenobiology Kickstarter Bundle"
	desc = "A bundle that contains a industrial grey extract, a bottle of plasma, a syringe, and two monkey cube boxes. \
			For those agents who can't afford to spend 30 whole minutes doing basically nothing."
	item = /obj/item/storage/box/syndie_kit/xenobio_starter_kit
	cost = 3
	restricted_roles = list(JOB_SCIENTIST, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/spare_null_rod
	name = "Spare Null Rod"
	desc = "A Null Rod that was smuggled out from various churches across the galaxy. \
			Just in case you lose yours, or if you plan on being super-extra prepared."
	item = /obj/item/nullrod
	cost = 15
	surplus = 10
	illegal_tech = FALSE
	restricted_roles = list(JOB_CHAPLAIN)

/datum/uplink_item/role_restricted/chem_storage_implant_bundle
	name = "Chemical Storage Implant Bundle"
	desc = "A bluespaced box containing roughly 5 chemical storage implant cases, an implanter, a syringe, and a beaker. You'll have to supply your own chemicals though. \
			To apply: inject chemicals (up to 50u) into the implant case using the syringe, then use the implanter to remove the implant and inject into target. Targets can only have one of these implants at any given time."
	item = /obj/item/storage/box/syndie_kit/chem_storage_implant_bundle
	cost = 3
	restricted_roles = list(JOB_CHEMIST, JOB_PSYCHOLOGIST, JOB_MEDICAL_DOCTOR, JOB_CHIEF_MEDICAL_OFFICER)
	surplus = 10

/datum/uplink_item/role_restricted/chaplain_healing_bundle
	name = "Holy Healing Bundle"
	desc = "A box containing three bottles of Omnizine, 90u in total. Additionally, the bundle contains one bottle of Unstable Mutagen."
	item = /obj/item/storage/box/syndie_kit/holy_healing_bundle
	cost = 4
	surplus = 15
	restricted_roles = list(JOB_CHAPLAIN)

/datum/uplink_item/role_restricted/burning_extract_bundle
	name = "Burning Slime Extract Bundle"
	desc = "A bundle that contains three useful burning extracts, courtesy of our xenobiologists. \
			Contains one Yellow, Metal, and Gold Burning Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/burning_extract_bundle
	cost = 3
	surplus = 30
	restricted_roles = list(JOB_SHAFT_MINER, JOB_PARAMEDIC, JOB_JANITOR)

/datum/uplink_item/role_restricted/charged_extract_bundle
	name = "Charged Slime Extract Bundle"
	desc = "A bundle that contains three useful charged extracts, courtesy of our xenobiologists. \
			Contains one Dark Blue, Red, and Green Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/charged_extract_bundle
	cost = 5
	surplus = 30
	restricted_roles = list(JOB_ATMOSPHERIC_TECHNICIAN, JOB_PSYCHOLOGIST, JOB_CHAPLAIN)

/datum/uplink_item/role_restricted/regenerative_extract_bundle
	name = "Regenerative Slime Extract Bundle"
	desc = "A bundle that contains three useful regenerative extracts, courtesy of our xenobiologists. \
			Contains one Purple, Sepia, and Adamantine Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/regenerative_extract_bundle
	cost = 5
	surplus = 30
	restricted_roles = list(JOB_CURATOR, JOB_CORONER, JOB_LAWYER)

/datum/uplink_item/role_restricted/stabilized_extract_bundle
	name = "Stabilized Slime Extract Bundle"
	desc = "A bundle that contains three useful stabilized extracts, courtesy of our xenobiologists. \
			Contains one Purple, Bluespace, and Adamantine Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/stabilized_extract_bundle
	cost = 4
	surplus = 30
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_BOTANIST, JOB_ASSISTANT)

/datum/uplink_item/role_restricted/industrial_extract_bundle
	name = "Industrial Slime Extract Bundle"
	desc = "A bundle that contains three useful industrial extracts, courtesy of our xenobiologists. \
			Contains one Purple, Gold, and Pink Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/industrial_extract_bundle
	cost = 6
	surplus = 30
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CARGO_TECHNICIAN, JOB_BITRUNNER)

/datum/uplink_item/role_restricted/chilling_extract_bundle
	name = "Chilling Slime Extract Bundle"
	desc = "A bundle that contains three useful chilling extracts, courtesy of our xenobiologists. \
			Contains one Metal, Dark Blue, and Bluespace Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/chilling_extract_bundle
	cost = 4
	surplus = 30
	restricted_roles = list(JOB_CLOWN, JOB_MIME, JOB_GENETICIST)

/datum/uplink_item/role_restricted/consuming_extract_bundle
	name = "Consuming Slime Extract Bundle"
	desc = "A bundle that contains three useful consuming extracts, courtesy of our xenobiologists. \
			Contains one Purple, Metal, and Oil Extract. Comes with 3 extra random extracts."
	item = /obj/item/storage/box/syndie_kit/consuming_extract_bundle
	cost = 3
	surplus = 30
	restricted_roles = list(JOB_COOK, JOB_BARTENDER, JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/clown_pie_bundle
	name = "Banana-Cream Pie Bundle"
	desc = "A duffelbag that's been stuffed to the brim with TWENTY banana-cream pies! Go nuts!"
	item = /obj/item/storage/backpack/duffelbag/clown/cream_pie/syndicate
	cost = 5
	surplus = 20
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/clown_trolling_security_bundle
	name = "The Make-Security-Upset Bundle"
	desc = "This bluespace box contains a wide variety of stolen NT security gear. Perfect for causing the entirety of the Security Department to hunt you down. \
			Included within are: 1 box of Flashbangs, 2 Energy Bola's, a can of Pepperspray, 2 Handcuffs, and 2 pairs of Sunglasses."
	item = /obj/item/storage/box/syndie_kit/clown_trolling_security_bundle
	cost = 8
	surplus = 5
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/clown_stun_resist_bundle
	name = "Stun Resistance Bundle"
	desc = "A box containing 3 bottles of Probital (Drink over 20u to Overdose), 2 bottles of Modafinil (Do not drink more than 10u at a time), and 3 bottles of Methamphetamine."
	item = /obj/item/storage/box/syndie_kit/clown_stun_resist_bundle
	cost = 7
	restricted_roles = list(JOB_CLOWN)

/datum/uplink_item/role_restricted/curator_die_of_fate
	name = "Die of Fate"
	desc = "This die of fate can do MANY wonderous things, like completely destroying you on a roll of a natural 1, or promoting \
			you from one of our agents... to one of our MAGICAL agents. Be warned, possession of this item will piss off everyone at the wizard foundation."
	item = /obj/item/dice/d20/fate
	cost = 25
	surplus = 1
	restricted_roles = list(JOB_CURATOR)

/datum/uplink_item/role_restricted/syndicate_virus_box
	name = "Virus Box"
	desc = "That pesky Chief Medical Officer too paranoid to let you have a Virus Crate? Well, you can always purchase one from us. \
			This crate contains twelve different bottles of several viral samples, also includes seven beakers and syringes."
	item = /obj/item/storage/box/syndie_kit/syndicate_virus_box
	cost = 12
	surplus = 5
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/manifold_autoinjector
	name = "Hereditary Manifold Sickness Injector"
	desc = "An autoinjector for a permanent, incurable disease that'll slowly destroy it's victim. \
			The disease can only be suppressed via experimental medication."
	item = /obj/item/reagent_containers/hypospray/medipen/manifoldinjector
	cost = 5
	surplus = 25
	restricted_roles = list(JOB_MEDICAL_DOCTOR, JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/manifold_injector_bundle
	name = "Bundle of HMS Injectors"
	desc = "One of our syndicate dufflebags that contains SIX unused HMS Auto-injectors. More than enough to cripple the security team greatly."
	item = /obj/item/storage/box/syndie_kit/manifold_injector_bundle
	cost = 20
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/low_budget_chemgun
	name = "Low-Budget Reagent Dartgun"
	desc = "This reagent dartgun produces a single 15u piercing syringe automatically and draws from an internal 15u chemical container. You must fill the chemical container yourself."
	item = /obj/item/gun/chembudget
	cost = 3
	surplus = 50
	restricted_roles = list(JOB_VIROLOGIST, JOB_COOK, JOB_MEDICAL_DOCTOR, JOB_CHEMIST, JOB_CHIEF_MEDICAL_OFFICER, JOB_SCIENTIST)

/datum/uplink_item/role_restricted/syndie_hypnotism_bundle
	name = "Hypnotism Bundle"
	desc = "A bundle containing a hypnotic flash, a hypnotic grenade, and 5 mindbreaker toxin smoke grenades."
	item = /obj/item/storage/box/syndie_kit/syndie_hypnotism_bundle
	cost = 10
	surplus = 10
	limited_stock = 1
	restricted_roles = list(JOB_PSYCHOLOGIST)

/datum/uplink_item/role_restricted/psychologist_xray_surgery
	name = "X-Ray Vision Implant"
	desc = "Allows unrestricted vision through walls, though light levels will still be in effect."
	item = /obj/item/autosurgeon/syndicate/xray_eyes/single_use
	cost = 15
	surplus = 10
	restricted_roles = list(JOB_PSYCHOLOGIST)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/surplus
	name = "Syndicate Surplus Crate (25% off!)"
	desc = "A dusty crate from the back of the Syndicate warehouse. Rumored to contain a valuable assortment of items, \
			but you never know. Contents are sorted to always be worth 30 TC."
	item = /obj/structure/closet/crate
	cost = 15
	restricted_roles = list(JOB_ASSISTANT)
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS | UPLINK_SPY)
	stock_key = UPLINK_SHARED_STOCK_SURPLUS
	/// Value of items inside the crate in TC
	var/crate_tc_value = 30
	/// crate that will be used for the surplus crate
	var/crate_type = /obj/structure/closet/crate

/datum/uplink_item/role_restricted/surplus/proc/generate_possible_items(mob/user, datum/uplink_handler/handler)
	var/list/possible_items = list()
	for(var/datum/uplink_item/item_path as anything in SStraitor.uplink_items_by_type)
		var/datum/uplink_item/uplink_item = SStraitor.uplink_items_by_type[item_path]
		if(src == uplink_item || !uplink_item.item)
			continue
		if(!handler.check_if_restricted(uplink_item))
			continue
		if(!uplink_item.surplus)
			continue
		if(handler.not_enough_reputation(uplink_item))
			continue
		possible_items += uplink_item
	return possible_items

/// picks items from the list given to proc and generates a valid uplink item that is less or equal to the amount of TC it can spend
/datum/uplink_item/role_restricted/surplus/proc/pick_possible_item(list/possible_items, tc_budget)
	var/datum/uplink_item/uplink_item = pick(possible_items)
	if(prob(100 - uplink_item.surplus))
		return null
	if(tc_budget < uplink_item.cost)
		return null
	return uplink_item

/// fills the crate that will be given to the traitor, edit this to change the crate and how the item is filled
/datum/uplink_item/role_restricted/surplus/proc/fill_crate(obj/structure/closet/crate/surplus_crate, list/possible_items)
	var/tc_budget = crate_tc_value
	while(tc_budget)
		var/datum/uplink_item/uplink_item = pick_possible_item(possible_items, tc_budget)
		if(!uplink_item)
			continue
		tc_budget -= uplink_item.cost
		new uplink_item.item(surplus_crate)

/// overwrites item spawning proc for surplus items to spawn an appropriate crate via a podspawn
/datum/uplink_item/role_restricted/surplus/spawn_item(spawn_path, mob/user, datum/uplink_handler/handler, atom/movable/source)
	var/obj/structure/closet/crate/surplus_crate = new crate_type()
	if(!istype(surplus_crate))
		CRASH("crate_type is not a crate")
	var/list/possible_items = generate_possible_items(user, handler)

	fill_crate(surplus_crate, possible_items)

	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = surplus_crate,
	))
	return source //For log icon


/datum/uplink_item/role_restricted/lathe_supply_package
	name = "Lathe Supply Package"
	desc = "A box containing electronic boards for both an autolathe and a protolathe. Also comes with the materials needed to assemble them."
	item = /obj/item/storage/box/syndie_kit/lathe_supply_package
	cost = 3
	restricted_roles = list(JOB_ASSISTANT)

/datum/uplink_item/role_restricted/nocturine_deluxe
	name = "Nocturine Deluxe Package"
	desc = "A box containing a Sleepy Pen, and 3 bottles of Nocturine. Very useful for incapacitating targets or kidnapping them."
	item = /obj/item/storage/box/syndie_kit/nocturine_deluxe
	cost = 8
	surplus = 25
	limited_stock = 1
	restricted_roles = list(JOB_ASSISTANT)

/datum/uplink_item/role_restricted/deluxe_bluespace_chameleon_backpack
	name = "Deluxe Bluespace Chameleon Backpack"
	desc = "A backpack fitted with both chameleon & bluespace technology. We've upgraded it especially for you, so it may contain more items than our normal variety."
	item = /obj/item/storage/backpack/bluespacechameleondeluxe
	cost = 6
	surplus = 10
	restricted_roles = list(JOB_ASSISTANT, JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)

/datum/uplink_item/role_restricted/mime_basic_ability
	name = "Guide to Basic Mimery Series"
	desc = "The classical two part series on how to expand your mime skills. Allowing you to gain more than 1 basic mime ability."
	item = /obj/item/book/granter/action/spell/mime/mimery
	cost = 6
	restricted_roles = list(JOB_MIME)

/datum/uplink_item/role_restricted/mime_invis_backpack
	name = "Invisible Backpack"
	desc = "This backpack has been outfitted by our latest chameleon technology and now possesses unlimited invisibility! Even EMP's can't short it out!"
	item = /obj/item/storage/backpack/invisible
	cost = 4
	restricted_roles = list(JOB_MIME)

/datum/uplink_item/role_restricted/helpful_barkeep_drinks
	name = "Beneficial Drinks Care Package"
	desc = "A box utilizing bluespace technology, we've stuffed it to the brim with useful drinks for yourself and any other agents you encounter. \
			Please be sure these drinks don't fall into enemy hands."
	item = /obj/item/storage/box/syndie_kit/helpful_barkeep_drinks
	cost = 8
	surplus = 10
	restricted_roles = list(JOB_BARTENDER)

/datum/uplink_item/role_restricted/janitor_acidnade_bundle
	name = "Highly Acidic Foam Grenade Bundle"
	desc = "A box utilizing bluespace technology, it contains 10 acidic foam chemical grenades. \
			Also includes a Screwdriver, Wirecutter, 5 Proximity Sensors, and 6 Remote Signalers."
	item = /obj/item/storage/box/syndie_kit/janitor_acidnade_bundle
	cost = 6
	surplus = 15
	restricted_roles = list(JOB_JANITOR)

/datum/uplink_item/role_restricted/janitor_bloodnade_bundle
	name = "Bloody Mess Grenade Bundle"
	desc = "A box utilizing bluespace technology, it contains 10 bloody mess chemical grenades. \
			These grenades will spread a bloody foam around, causing a massive mess. \
			We're not sure why you'd want this. Also includes a Screwdriver and Wirecutter."
	item = /obj/item/storage/box/syndie_kit/janitor_bloodnade_bundle
	cost = 2
	restricted_roles = list(JOB_JANITOR)

/datum/uplink_item/role_restricted/bluespace_bodybag_bundle
	name = "Bluespace Body Bag Bundle"
	desc = "A box utilizing bluespace technology, within you'll find two bluespace bodybags, a bottle of nocturine, and a Sleepy Pen. Perfect for kidnappings."
	item = /obj/item/storage/box/syndie_kit/bluespace_bodybag_bundle
	cost = 8
	surplus = 10
	limited_stock = 1
	restricted_roles = list(JOB_CORONER)

/datum/uplink_item/role_restricted/bodybaginvis
	name = "Invisible Body Bag"
	desc = "A single, invisible body bag. It's chameleon technology is so advanced, it cannot be revealed -- even with EMP's. Try not to forget where you placed it. \
			Extremely useful as a portable hiding spot, evidence concealment, contraband stashes, and more."
	item = /obj/item/bodybag/invis
	cost = 6
	restricted_roles = list(JOB_CORONER)

/datum/uplink_item/role_restricted/powerlake
	name = "Power Lake"
	desc = "The Power Lake, otherwise known as the reverse power sink, is an advanced multi-dimensional generator capable of providing near limitless power supply thanks to interdimensional technology that harvests foreign energies from other universes. Unfortunately, this proved far too volatile for power generation. \
			The Power Lake will explode within minutes of activation due to heat generation. The explosion is far more devastating in comparison to one from a power sink."
	item = /obj/item/powerlake
	cost = 15
	surplus = 8
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/lethal_flare
	name = "Lethal Flare"
	desc = "A flare commonly provided to Nanotrasen's crew in case of lighting failure. It can be used as a weapon to deal decent Burn damage and light your target ablaze."
	item = /obj/item/flashlight/flare/lethal
	cost = 4
	surplus = 20
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/electricaxe
	name = "Lightning Axe"
	desc = "A fire axe that's been augmented with electrical technology. In addition to being a fireaxe, it has a 20% chance to electrocute your victims, paralyzing and forcing them to remain grounded for a short time with every hit."
	item = /obj/item/fireaxe/electric
	cost = 12
	surplus = 5
	restricted_roles = list(JOB_STATION_ENGINEER, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/n2o_nade_bundle
	name = "Nitrous Oxide Grenade Bundle"
	desc = "A box utilizing bluespace technology, it contains 5 nitrous oxide foam chemical grenades. Useful for distractions or putting people to sleep."
	item = /obj/item/storage/box/syndie_kit/n2o_nade_bundle
	cost = 6
	surplus = 10
	restricted_roles = list(JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/riggedtanksyndie
	name = "Rigged Oxygen Cannister"
	desc = "An oxygen canister that has been outfitted with explosives. Arm and throw, much like a grenade."
	item = /obj/item/disguisedgrenade/riggedtanksyndie
	cost = 4
	surplus = 20
	restricted_roles = list(JOB_ATMOSPHERIC_TECHNICIAN, JOB_CHIEF_ENGINEER)

/datum/uplink_item/role_restricted/lethaldosemedipen
	name = "Lethal Dosage Medipen"
	desc = "A medipen designed to look exactly like an Epinephrine Medipen. It contains a lethal dose of poison as well as some Epinephrine. Mostly poison, though."
	item = /obj/item/reagent_containers/hypospray/medipen/lethaldose
	cost = 3
	surplus = 20
	restricted_roles = list(JOB_PARAMEDIC)

/datum/uplink_item/role_restricted/pacifymedipen
	name = "Pacification Medipen"
	desc = "A medipen loaded with 20u of Mute Toxin, Pax, and 5u of Tirizene. Allows for some one-sided fights."
	item = /obj/item/reagent_containers/hypospray/medipen/pacify
	cost = 4
	surplus = 30
	restricted_roles = list(JOB_PARAMEDIC)

/datum/uplink_item/role_restricted/chemkillswitch
	name = "Chemical Kill-switch"
	desc = "A medipen loaded with a specialized nanite virus which is to be injected directly into your target's bloodstream. The nanites take roughly 5 minutes before activation. \
			Upon activation, the nanites will cause MASSIVE Toxin and Brute damage to the victim, guaranteeing the destruction of several organs and instant death for your victim. \
			If the nanites find themselves being cleared from the victim's bloodstream, they'll activate early for what may amount to significantly less damage overall."
	item = /obj/item/reagent_containers/hypospray/medipen/chemkillswitch
	cost = 8
	surplus = 10
	restricted_roles = list(JOB_PARAMEDIC)

/datum/uplink_item/role_restricted/paramedic_defib
	name = "Combat Defibrillator"
	desc = "A malfunctioning defibrillator, it's electrical shocks stun your foes, and can lead to an inevitable death should you use it like a regular defibrillator."
	item = /obj/item/defibrillator/compact/combat/loaded
	cost = 12
	surplus = 15
	restricted_roles = list(JOB_PARAMEDIC)

/datum/uplink_item/role_restricted/sacred_flames
	name = "Book of Sacred Flames"
	desc = "A strange, mystical book that mysteriously found it's way into one of our warehouses. \
			Those who read it's contents will be blessed with the ability to light themselves ablaze \
			and make everyone nearby increasingly flammable."
	item = /obj/item/book/granter/action/spell/sacredflame
	cost = 6
	surplus = 0
	restricted_roles = list(JOB_CHAPLAIN)

/datum/uplink_item/role_restricted/inf_cash
	name = "Syndicate Counterfeiting Printer"
	desc = "One of our finest redspace-engineered counterfeit money printers, we've disguised it as a secure briefcase to avoid suspicion. \
			The briefcase will silently print and store 1000$ dollar bills over time to ensure you can take advantage of NT's lackluster cargo security. \
			It's also a bit more robust than our typical briefcases, just in case. Only prints money while in the hands of a syndicate agent and while unlocked."
	item = /obj/item/storage/briefcase/secure/cargonia
	cost = 6
	surplus = 10
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER)
	purchasable_from = ~UPLINK_SPY

/datum/uplink_item/role_restricted/anomaly_releaser
	name = "Anomaly Releaser"
	desc = "A medipen loaded with chemicals so confidental -- even WE can't afford to tell you what it is. \
			If injected into an anomaly core, the substance will cause the core to undergo mitosis, creating an anomaly based off the anomaly core. \
			The medipen can only be used once."
	item = /obj/item/anomaly_releaser
	cost = 2
	surplus = 35
	restricted_roles = list(JOB_CARGO_TECHNICIAN, JOB_QUARTERMASTER, JOB_SCIENTIST, JOB_RESEARCH_DIRECTOR)

/datum/uplink_item/role_restricted/nadelauncher
	name = "Grenade Launcher"
	desc = "A somewhat bulky grenade launcher, it can prime and fire many different kinds of grenades INCLUDING chemical grenades. Can load three grenades at any time."
	item = /obj/item/gun/grenadelauncher
	cost = 6
	surplus = 25
	restricted_roles = list(JOB_CHEMIST, JOB_CHIEF_MEDICAL_OFFICER)

/datum/uplink_item/role_restricted/holynade
	name = "Holy Hand Grenade"
	desc = "The priest's patented special surprise, produces a small explosion comparable to that of a potassium & water explosion. Makes a distinct sound when detonated."
	item = /obj/item/grenade/chem_grenade/holy
	cost = 5
	surplus = 45
	restricted_roles = list(JOB_CHAPLAIN)

/datum/uplink_item/role_restricted/syndivirusbuffer
	name = "S. Gene Culture Bottle"
	desc = "A culture bottle containing the pride and joy of our bio-weapon specialists, add this symptom to your virus to greatly increase it's potential."
	item = /obj/item/reagent_containers/cup/bottle/syndisymptombuffer
	cost = 8
	surplus = 0
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/syndivirusbufferstealth
	name = "STE. Gene Culture Bottle"
	desc = "A culture bottle containg a super-symptom often utilized by our bio-weapon specialists, add this symptom to your virus to greatly increase it's stealth and moderately boost it's other stats."
	item = /obj/item/reagent_containers/cup/bottle/syndisymptombuffer/stealth
	cost = 4
	surplus = 0
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/syndivirusbufferresist
	name = "SRE. Gene Culture Bottle"
	desc = "A culture bottle containg a super-symptom often utilized by our bio-weapon specialists, add this symptom to your virus to greatly increase it's resistance and moderately boost it's other stats."
	item = /obj/item/reagent_containers/cup/bottle/syndisymptombuffer/resist
	cost = 4
	surplus = 0
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/syndivirusbufferspeed
	name = "SPD. Gene Culture Bottle"
	desc = "A culture bottle containg a super-symptom often utilized by our bio-weapon specialists, add this symptom to your virus to greatly increase it's stage speed and moderately boost it's other stats."
	item = /obj/item/reagent_containers/cup/bottle/syndisymptombuffer/speed
	cost = 4
	surplus = 0
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/syndivirusbuffertrans
	name = "STR. Gene Culture Bottle"
	desc = "A culture bottle containg a super-symptom often utilized by our bio-weapon specialists, add this symptom to your virus to greatly increase it's transmittability and moderately boost it's other stats."
	item = /obj/item/reagent_containers/cup/bottle/syndisymptombuffer/trans
	cost = 4
	surplus = 0
	restricted_roles = list(JOB_VIROLOGIST)

/datum/uplink_item/role_restricted/syndisauce
	name = "Box of Syndicate Sauce"
	desc = "A box with 6 sauce packets containing 10 units of Amanitin, a silent but delayed poison."
	item = /obj/item/storage/box/syndie_kit/syndisauce
	cost = 1
	surplus = 7
	restricted_roles = list(JOB_COOK)

/datum/uplink_item/role_restricted/red_chainsaw
	name = "Syndicate Chainsaw"
	desc = "A suspiciously red chainsaw fitted with sharpened blades, deals moderate damage when on. \
			Can be used to tear into people, and dismember them! An excellent demolition tool, and is super-effective against plant-like targets."
	item = /obj/item/chainsaw/botany/syndicate
	cost = 8
	restricted_roles = list(JOB_BOTANIST)

/datum/uplink_item/role_restricted/syndi_donkpockets
	name = "Syndicate Donk Pockets"
	desc = "A box of our finest donk pockets, they're filled with our specialized brand of methamphetamine."
	item = /obj/item/storage/box/donkpockets/donkpocketsyndi
	cost = 4
	restricted_roles = list(JOB_COOK)

