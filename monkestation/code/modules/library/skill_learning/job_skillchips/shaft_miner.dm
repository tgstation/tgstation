/obj/item/skillchip/drg_callout
	name = "D.R.G.R.A.S Skillchip" //Deep Rock Galactic Reactive Alert System (Or ROCK AND STONE)
	desc = "Smells faintly of alcohol and has an odd coffee stain on it."
	custom_price = PAYCHECK_CREW
	complexity = 0
	skill_name = "Miner Communication"
	skill_description = "Understand the skills required to rapidly recognize and call out objects you've pointed at to teammates."
	skill_icon = "bullhorn"
	cooldown = 5 SECONDS //Honestly, this should be easy to turn off at any time if you don't want it anymore.
	activate_message = span_notice("You suddenly understand the need to shout about things you point at.")
	deactivate_message = span_notice("You no longer understand why you were yelling so much.")
	//5-10 second delay for radio messages
	COOLDOWN_DECLARE(radio_cooldown)
	//1 second delay for regular point shouts
	COOLDOWN_DECLARE(shout_cooldown)

	/*
	DRG Style callout list.
	Note the following:
	Subtypes MUST go above their base types.
	As in:
			/mob/living/basic/mining/legion/snow/
	ABOVE 	/mob/living/basic/mining/legion/

	Typepaths must have a trailing forward slash.
	*/
	var/list/static/miner_callouts = list(
	//Mobs: Icemoon
	/mob/living/basic/mining/legion/snow/ = list("Legion!", "It's a snowy legion!", "Kill it before it creates more!"),
	/mob/living/basic/mining/wolf/ = list("Wolf!", "Winter wolf!", "It's hungry like the...", "Wolf pack!"),
	/mob/living/simple_animal/hostile/asteroid/polarbear/ = list("Bear!", "Polar bear!", "I want the pelt!"),
	/mob/living/basic/mining/ice_demon/ = list("Frost demon!", "Slippery demon!", "Look up! Ice demon!", "Demon watching us!"),
	/mob/living/basic/mining/ice_whelp/ = list("Ice whelp!", "Whelp above us!", "Bite-sized frost dragon!", "Watch out! It's small and it's dangerous!"),
	/obj/structure/spawner/ice_moon/demonic_portal/ = list("Portal!", "Take out the portal!", "Beasts coming out of that portal!"),

	//Mobs: Oshan
	/mob/living/basic/aquatic/fish/ = list("Fish!", "Feesh!", "Got a fish here!", "Watch out, fish!"),

	//Mobs: Misc
	/mob/living/carbon/alien/adult/royal/ = list("XENO ROYAL!!", "THICK XENO HERE!!", "WE'VE GOT COMPANY!!", "SHE'S A BIG ONE!!", "GLYPHID...I MEAN XENO ROYAL!!"),
	/mob/living/carbon/alien/ = list("Got a xenomorph here!", "Xeno! Watch for huggers!", "Xenomorph!", "We've got xenos!", "Don't let it grab you!"),
	/mob/living/simple_animal/hostile/alien/ = list("Got a xenomorph here!", "Xeno! Watch for huggers!", "Strange dog!", "Xenomorph!", "Die like your mother did!"),
	/obj/structure/alien/egg/ = list("Watch the eggs!", "Stay back from the egg!", "There's an egg here!", "Egg! I found an egg!", "EGG!", "Egg found!", "Careful! We don't want to wake up what's in that egg!", "I don't ever wanna meet whatever laid these eggs..."),
	/obj/item/food/egg/ = list("There's an egg here!", "Egg! I found an egg!", "EGG!", "Egg found!"),
	/obj/item/clothing/mask/facehugger/ = list("Watch it!", "Don't let that touch you!", "Mouthgrabber!", "It's one of those headhuggers!", "Don't touch that unless you wanna be a mother!", "Hugger! Shoot it from a distance!", "Is it real?"),
	/mob/living/carbon/human/ = list("Hey!", "You there!", "Hey you!", "Hello!", "You!"),

	//Mobs: Lavaland
	/mob/living/basic/mining/goldgrub/ = list("Lootbug!", "I found a goldgrub!", "Pop that lootbug!", "Lets tame the goldgrub!"),
	/mob/living/basic/mining/goliath/ = list("Goliath!", "Watch the tentacles!", "We got a goliath!", "Goliath! Don't let it grab you!", "Watch where you stick those tentacles, you blasted sack of hellspawn! "),
	/mob/living/basic/mining/legion/dwarf/ = list("Legion! He's adorable!", "Little legion here!", "I'm gonna call you Steeve!"),
	/mob/living/basic/mining/legion/ = list("Legion!", "Don't let it create more!", "Watch the legion!", "We've got a legion!"),
	/mob/living/basic/legion_brood/ = list("Legion spawn!", "Don't let it down you!", "Watch the legion spawn!", "Get the bigger one too!"),
	/mob/living/basic/mining/watcher/  = list("Watcher!","Watcher spotted!", "Watcher! I hate these things!", "Break the watcher!", "Dodge the ice!"),
	/mob/living/basic/mining/brimdemon/ = list("Brimdemon!", "Brimdemon, watch the beams!", "Spotted a brimdemon!", "Keep your distance!"),
	/mob/living/basic/mining/bileworm/ = list("Bileworm!", "Take out that bileworm!", "Kill the bileworm before it melts us all!", "Acid spreader!"),
	/obj/structure/spawner/lavaland/ = list("Tendril!", "Don't let it take you with it!", "We got a tendril!", "Watch for beasties coming out!"),

	//Mobs: Megafauna
	/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/ = list("BLOOD-DRUNK MINER! WATCH YOURSELVES!!", "THAT MINER WENT BLOOD-DRUNK!!", "WATCH THE BLOOD-DRUNK MINER!!", "BLOOD-DRUNK MINER! THAT'S WHAT HAPPENS WHEN YOU DRINK LEAFLOVERS!!"),
	/mob/living/simple_animal/hostile/megafauna/colossus/ = list("COLOSSUS!!", "COLOSSUS SPOTTED!!", "DON'T GET JUDGED BY THE COLOSSUS!!", "COLOSSUS, DODGE THE SHOTS!!", "WE'VE GOT A COLOSSUS, BULLET HELL TIME!!"),
	/mob/living/simple_animal/hostile/megafauna/clockwork_defender/ = list("CLOCKWORK DEFENDER!!", "CLOCKWORK! TICK TOCK, HEAVY LIKE AN AFTERSHOCK!!", "RATVARIAN KNIGHT! WATCH IT!!", "DAMN, BRASS BEAST IN SIGHT!!"),
	/mob/living/simple_animal/hostile/megafauna/bubblegum/ = list("BUBBLEGUM, WATCH THE BLOOD!!", "KEEP YOUR DISTANCE, BUBBLEGUM IS LETHAL UP CLOSE!!", "BLOODY HELL, BUBBLEGUM SPOTTED!!", "STAY OUT OF THE BLOOD POOLS, BUBBLEGUM!!"),
	/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner/ = list("DEMONIC MINER!!", "WATCH YOURSELVES, DEMON MINER SPOTTED!!", "DEMON MINER, DON'T LET IT STEAL YOUR SOUL!!", "FROST-CRAZED MINER, DODGE THE BASTARD!!"),
	/mob/living/simple_animal/hostile/megafauna/dragon/ = list("BY THE BEARD, DRAGON!!", "WE'VE GOT A DRAGON ON OUR HANDS!!", "ASH DRAKE, DON'T LET IT BURN YOU!!", "THERE'S AN ASH DRAKE!!", "ASH DRAKE!!", "WHERE'S A DRAGONBORN WHEN YOU NEED THEM?!!"),
	/mob/living/simple_animal/hostile/megafauna/hierophant/ = list("HIEROPHANT IN SIGHT!!", "WATCH IT, HIEROPHANT ON RHYTHM!!", "DANCE TO THE HIEROPHANT'S BEAT IF YOU WANNA LIVE!!", "HIEROPHANT!!"),
	/mob/living/simple_animal/hostile/megafauna/legion/ = list("LEGION!!", "SOMEONE WOKE THE LEGION!!", "THIS IS IT, LADS! LEGION SPOTTED!!", "A LEGION TO ONE, I LIKE THESE ODDS!!"),
	/mob/living/simple_animal/hostile/megafauna/wendigo/ = list("WENDIGO!!", "WE'VE GOT A WENDIGO HERE!!", "KEEP THE WENDIGO AT RANGE, LADS!!", "KEEP MOVING, THIS WENDIGO IS FAST!!", "WENDIGO, GO, GO!!"),

	//Items: Materials
	/obj/item/stack/sheet/iron/ = list("Iron sheets!", "Got some iron!", "Iron, cold iron!", "Master of metals!", "Let all who build beware!"),
	/obj/item/stack/sheet/glass/ = list("Glass sheets!", "Glass, clear and crystal!", "Glass, ready to be made into mugs!"),
	/obj/item/stack/sheet/mineral/diamond/ = list("Diamonds!", "Got some diamonds!", "I like the sound of these!", "I wonder if it's edible..."),
	/obj/item/stack/sheet/mineral/uranium/ = list("Uranium!", "Enriched uranium!", "You and U-235!", "Radical! Uranium!"),
	/obj/item/stack/sheet/mineral/plasma/ = list("Plasma!", "That's why we're here!", "They call it 'phoron' in some sectors! Bloody weird!", "Plasma sheets!", "No smoking near the plasma!"),
	/obj/item/stack/sheet/mineral/gold/ = list("Gold!", "Gold for the mistress!", "All that is gold does not glitter, but this does!", "Gold bars!", "Precious aurum!", "We're rich!"),
	/obj/item/stack/sheet/mineral/silver/ = list("Silver!", "Silver for the maid!", "Beautiful silver!", "Silver bars!", "Pure silver!", "Silver for sterile floors!"),
	/obj/item/stack/sheet/mineral/bananium/ = list("Bananium!", "Prayers for the clown!", "By the beard, Bananium sheets...", "Sheets of bananium!"),
	/obj/item/stack/sheet/mineral/titanium/ = list("Titanium!", "Strong as steel, beautiful as silver!", "Titanium sheets right here!"),
	/obj/item/stack/sheet/mineral/coal/ = list("Coal!", "Someone got on the naughty list!", "If only it were a diamond!"),
	/obj/item/stack/sheet/ = list("Materials!", "Got some materials!", "Some materials here!", "Look, materials!"),

	//Items: Raw Ore
	/obj/item/stack/ore/glass/ = list("Sand!", "Some sand!", "Wow, sand!", "Rough, coarse, and gets into everything!", "Common sand!"),
	/obj/item/stack/ore/uranium/ = list("Uranium ore!", "I've got uranium fever!", "Found uranium!", "It's nuclear, it's wild!"),
	/obj/item/stack/ore/iron/ = list("Iron ore!", "Raw iron!", "There is iron here!", "Iron!"),
	/obj/item/stack/ore/plasma/ = list("Plasma ore!", "Fuel for the cutters here!", "What we're here for!", "Raw plasma!"),
	/obj/item/stack/ore/silver/ = list("Silver ore!", "I'm so glad to announce that I found some silver!", "Silver here!", "Silver!"),
	/obj/item/stack/ore/gold/ = list("WE'RE RICH!"), //Yes, yes, you're rich... time to get a move on! I got Management breathing down my neck here!
	/obj/item/stack/ore/diamond/ = list("Raw diamond!", "Uncut diamonds!", "Found some diamonds!", "There's a diamond here!"),
	/obj/item/stack/ore/bananium/ = list("Bananium ore!", "Raw and slippery bananium!", "The clown will be pleased!", "Bananium! We know what comes next!"),
	/obj/item/stack/ore/titanium/ = list("Titanium ore!", "Raw titanium!", "You ever wonder how we smelt this without magnesium?", "Titanium deposit!"),
	/obj/item/gibtonite/ = list("Gibtonite!", "Watch it, gibtonite!", "When this glows, you better go!", "Is it stable?"),
	/obj/item/stack/ore/ = list("Ore!", "Some ore!", "Got ore here!"),

	//Items: Mining
	/obj/item/pickaxe/ = list("Rock and stone!", "For rock and stone!", "For Karl!", "Rock and stone forever!", "We are unbreakable!", "Rock and roll and stone!", "If you don't rock and stone, you ain't comin' home!", "Rock solid!"),
	/obj/item/shovel/ = list("Can you dig it?", "Oh yeah, I dig it.", "Lets dig up some sand!", "May they bury you deep!"),
	/obj/structure/closet/ = list("Storage here!", "Check inside!", "I bet there's loot in here!"),
	/obj/structure/ore_box/ = list("My grandpa told me they used mules back in the day!", "Drag this behind you!", "Ore box!", "Throw the ores in here, lads!", "Grab an ore crate!", "Minerals in here!"),
	/obj/item/storage/bag/ore/holding/ = list("Finally, I can hold all of my rocks AND stones!", "Infinite ore storage!", "Why don't we make these for everything?", "Ore bag!", "Mineral bag!"),

	/obj/item/gun/energy/recharge/kinetic_accelerator/ = list("Kinetic accelerator!", "You modern wonder, you!", "Miner's best friend.", "Hit 'em where it hurts!", "No pressure, no problem!", "Infinite ammo, and no bandana needed!"),
	/obj/item/borg/upgrade/modkit/ = list("Upgrades!", "Want something done right, you do it yourself!", "I almost feel bad putting this on a weapon...almost!", "Just the mod I needed!", "Mod time is fun time!"),

	/obj/item/kinetic_crusher/ = list("Kinetic crusher!", "Aerodynamic, I like it!", "Keeping this for close encounters!", "Oh, nice shape!", "Time to hunt!", "Bloody deadly weapon!", "I'm back and brutal!"),
	/obj/item/crusher_trophy/ = list("Crusher trophy!", "Earned this one!", "Crusher getting stronger every day!", "Slap this on a crusher!", "Going to hunt them all with this!"),

	/obj/item/gun/energy/plasmacutter/ = list("Plasma cutter!", "Got a cutter here!", "My trusty 211-V!", "Hot plasma ready to go!", "The good ol' breach cutter!", "Perfect for minerals and limbs alike!"),

	/mob/living/basic/mining_drone/ = list("My reliable drone!", "Bosco!", "Bosco, buddy!", "My all-purpose drone!"),
	/obj/item/slimepotion/slime/sentience/mining/ = list("Lets upgrade Bosco!", "Time to make Bosco smarter!"),

	/obj/item/skeleton_key/ = list("Skeleton key!", "Key! Time to crack a crate!", "Time for some rewards!", "Key here!"),
	/obj/item/mining_voucher/ = list("Voucher!", "Freebie time!", "Mining voucher, time to spend it wisely!"),
	/obj/item/wormhole_jaunter/ = list("Jaunter!", "Yeesh, never liked traveling by wormhole!", "Safe...ish wormholes!", "Saves your rear from a chasm if you keep it on you!", "Ready to open a wormhole!"),

	/obj/item/organ/internal/monster_core/ = list("Got some beast organs!", "Organ here!", "Crush this in a pinch!", "Monster organ, grab it before it goes bad!", "Organ! I prefer red sugar..."),
	/obj/item/reagent_containers/hypospray/medipen/survival/ = list("Survival pen!", "Medipen here!", "Keep one of these in your pocket!", "With this, the fight goes on!", "No time for a lie-down!"),
	/obj/item/extinguisher/ = list("Fire extinguisher!", "Extinguisher here!", "Works against magma fires too!", "Never know when you'll need this!", "Where's the fire?"),
	/obj/item/lazarus_injector/ = list("Lazarus Injector!", "Wish I had this for my goldfish!", "Lazarus here!", "Lets go revive some pets!"),
	/obj/item/extraction_pack/ = list("Fulton Pack!", "They're coming too?", "Use this, it's a fulton recovery device.", "Time to grab everything not nailed down!","Heard about a guy that brought home a bear with one of these!", "Link this to a beacon!"),
	/obj/item/fulton_core/ = list("Fulton beacon!", "Get this beacon set up!", "Ready to place beacon!", "Extraction beacon here!"),
	/obj/structure/extraction_point/ = list("Fulton beacon!", "Beacon ready to bring things home!", "Extraction beacon here!"),

	/obj/item/t_scanner/adv_mining_scanner/ = list("Mining scanner!", "Scanner! Get the ores revealed!", "Ready to find those minerals!", "Ore scanner at the ready!"),
	/obj/item/mining_scanner/ = list("Mining scanner!", "A manual scanner?!", "Doesn't NT have better than this?", "This is trash!", "I wish I had better!"),
	/obj/item/clothing/glasses/meson/ = list("Meson goggles!", "Mesons! I can see my house with these!", "Mesons here, perfect for mining!", "Mesons! You know, false walls don't show up on 'em!"),
	/obj/item/survivalcapsule/luxuryelite/ = list("Survival, in style!", "Finally, my own bar!", "Survival capsule!", "Earned a drink in here, I think!", "Survive the storms with a few drinks!"),
	/obj/item/survivalcapsule/ = list("Survival capsule!", "Capsule! Pop it when the storms come!", "Just like my cabin on the rig!", "Capsule here!", "Ready for the storms!"),
	/obj/item/style_meter/ = list("Style meter!", "Now I'm stylish!", "Lookin' cool!", "Only way to mine!", "Time to beat my high score!"),
	/obj/item/stack/spacecash/ = list("Loads of money!", "Money, money, money~", "It's raining money!", "Dosh!", "Dosh! Grab it while you can, lads!", "Cash here!", "My name is loadsamoney!", "Wallets, watch out for the ladies!", "Right, whop it out!", "Money makes the world go 'round!", "All this mining's making me rich!", "Sorry mate, don't take cheques! Just loads of money!"), //Yes, you get a Killing Floor reference too, as a treat.

	//Items: Misc
	/obj/item/toy/plush/moth/ = list("Bug!", "Found a bug!", "There's a bug here!", "Moth!", "Moth here!", "🐛"),

	//Machines
	/obj/machinery/mineral/ore_redemption/ = list("ORM! Drop off your rocks and stones!", "It's a mystery to me how all these minerals fit inside!", "Making a deposit!", "Molly!", "Bloody scientists never upgrade this thing..."),
	/obj/machinery/computer/shuttle/ = list("Shuttle console!", "Away we go!"),
	/obj/machinery/computer/order_console/mining = list("Order console!", "Time to spend my hard-earned points!", "What should I buy today?", "Capitalism, ho!"),

	//Static Objects: Icemoon
	/obj/structure/flora/ash/chilly/ = list("Got some fruit here!", "Ice pepper plant!", "Cold as ice!", "Frosty peppers!", "Time for some chilly chili!"),

	//Static Objects: Oshan
	//None yet, but I am leaving it open.

	//Static Objects: Lavaland & Other
	/obj/structure/flora/rock/ = list("Rock! Or stone?", "Rock!", "Pioneers used to ride these babies for miles."),
	/obj/structure/geyser/ = list("Chemical geyser!", "Geyser here! Get the chemists!", "Found a geyser!", "Got some mystery chems here!", "Geyser! Probably tastes better than the chef's cooking..."),
	/obj/structure/flora/ash/cacti/ = list("Cacti here!", "Don't step on this one!", "Yeast Cones?", "Cactus right here!"),
	/obj/structure/flora/ash/fireblossom/ = list("Fireblossom here!", "Got a fireblossom plant!", "Fireblossom, for when you need to glow!"),
	/obj/structure/flora/ash/ = list("Mushroom!"), //You just know I had to do this.
	/turf/closed/mineral/ = list("Dig through here.", "Minerals inside?", "We need to dig here.", "Drill here?")
)


/obj/item/skillchip/drg_callout/on_activate(mob/living/carbon/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_POINTED, PROC_REF(point_handler))

/obj/item/skillchip/drg_callout/proc/point_handler(mob/pointing_mob, atom/pointed_at)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, shout_cooldown))
		return

	var/type = is_path_in_list_return_path(pointed_at.type, miner_callouts)
	if(!type)
		return
	var/list/callouts = miner_callouts[type]
	if(!length(callouts))
		return

	if(COOLDOWN_FINISHED(src, radio_cooldown))
		pointing_mob.say(".h [pick(callouts)]", forced = "Miner Skillchip")
		COOLDOWN_START(src, radio_cooldown, rand(5 SECONDS, 10 SECONDS))
	else
		pointing_mob.say("[pick(callouts)]", forced = "Miner Skillchip")

	COOLDOWN_START(src, shout_cooldown, 1 SECONDS)



/obj/item/skillchip/drg_callout/on_deactivate(mob/living/carbon/user, silent)
	. = ..()
	UnregisterSignal(holding_brain.owner, COMSIG_MOB_POINTED)
