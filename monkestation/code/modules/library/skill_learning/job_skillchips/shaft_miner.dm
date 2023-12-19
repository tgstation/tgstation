/*
	DRG Style callout list.
	Note the following:
	Subtypes MUST go above their base types.
	As in:
			/mob/living/basic/mining/legion/snow
	ABOVE 	/mob/living/basic/mining/legion
*/
GLOBAL_LIST_INIT(miner_callouts, list(
	//Mobs: Icemoon
	/mob/living/basic/mining/legion/snow = list("Legion!", "It's a snowy legion!", "Kill it before it creates more!"),
	/mob/living/basic/mining/wolf = list("Wolf!", "Winter wolf!", "It's hungry like the...", "Wolf pack!"),
	/mob/living/simple_animal/hostile/asteroid/polarbear = list("Bear!", "Polar bear!", "I want the pelt!"),
	/mob/living/basic/mining/ice_demon = list("Frost demon!", "Slippery demon!", "Look up! Ice demon!", "Demon watching us!"),
	/mob/living/basic/mining/ice_whelp = list("Ice whelp!", "Whelp above us!", "Bite-sized frost dragon!", "Watch out! It's small and it's dangerous!"),
	/obj/structure/spawner/ice_moon/demonic_portal = list("Portal!", "Take out the portal!", "Beasts coming out of that portal!", ""),

	//Mobs: Oshan
	/mob/living/basic/aquatic/fish = list("Fish!", "Feesh!", "Got a fish here!", "Watch out, fish!"),

	//Mobs: Misc
	/mob/living/carbon/alien/adult/royal = list("XENO ROYAL!!", "THICK XENO HERE!!", "WE'VE GOT COMPANY!!", "SHE'S A BIG ONE!!", "GLYPHID...I MEAN XENO ROYAL!!"),
	/mob/living/carbon/alien = list("Got a xenomorph here!", "Xeno! Watch for huggers!", "Xenomorph!", "We've got xenos!", "Don't let it grab you!"),
	/mob/living/simple_animal/hostile/alien = list("Got a xenomorph here!", "Xeno! Watch for huggers!", "Strange dog!", "Xenomorph!", "Die like your mother did!"),
	/obj/structure/alien/egg = list("Watch the eggs!", "Stay back from the egg!", "There's an egg here!", "Egg! I found an egg!", "EGG!", "Egg found!", "Careful! We don't want to wake up what's in that egg!", "I don't ever wanna meet whatever laid these eggs..."),
	/obj/item/food/egg = list("There's an egg here!", "Egg! I found an egg!", "EGG!", "Egg found!"),
	/obj/item/clothing/mask/facehugger = list("Watch it!", "Don't let that touch you!", "Mouthgrabber!", "It's one of those headhuggers!", "Don't touch that unless you wanna be a mother!", "Hugger! Shoot it from a distance!", "Is it real?"),
	/mob/living/carbon/human = list("Hey!", "You there!", "Hey you!", "Hello!", "You!"),

	//Mobs: Lavaland
	/mob/living/basic/mining/goldgrub = list("Lootbug!", "I found a goldgrub!", "Pop that lootbug!", "Lets tame the goldgrub!"),
	/mob/living/basic/mining/goliath = list("Goliath!", "Watch the tentacles!", "We got a goliath!", "Goliath! Don't let it grab you!", "Watch where you stick those tentacles, you blasted sack of hellspawn! "),
	/mob/living/basic/mining/legion/dwarf = list("Legion! He's adorable!", "Little legion here!", "I'm gonna call you Steeve!"),
	/mob/living/basic/mining/legion = list("Legion!", "Don't let it create more!", "Watch the legion!", "We've got a legion!"),
	/mob/living/basic/legion_brood = list("Legion spawn!", "Don't let it down you!", "Watch the legion spawn!", "Get the bigger one too!"),
	/mob/living/basic/mining/watcher  = list("Watcher!","Watcher spotted!", "Watcher! I hate these things!", "Break the watcher!", "Dodge the ice!"),
	/mob/living/basic/mining/brimdemon = list("Brimdemon!", "Brimdemon, watch the beams!", "Spotted a brimdemon!", "Keep your distance!"),
	/mob/living/basic/mining/bileworm = list("Bileworm!", "Take out that bileworm!", "Kill the bileworm before it melts us all!", "Acid spreader!"),
	/obj/structure/spawner/lavaland = list("Tendril!", "Don't let it take you with it!", "We got a tendril!", "Watch for beasties coming out!"),

	//Mobs: Megafauna
	/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner = list("BLOOD-DRUNK MINER! WATCH YOURSELVES!!", "THAT MINER WENT BLOOD-DRUNK!!", "WATCH THE BLOOD-DRUNK MINER!!"),
	/mob/living/simple_animal/hostile/megafauna/colossus = list("COLOSSUS!!", "COLOSSUS SPOTTED!!", "DON'T GET JUDGED BY THE COLOSSUS!!", "COLOSSUS, DODGE THE SHOTS!!", "WE'VE GOT A COLOSSUS, BULLET HELL TIME!!"),
	/mob/living/simple_animal/hostile/megafauna/clockwork_defender = list("A CLOCKWORK DEFENDER? AT THIS TIME OF YEAR? AT THIS TIME OF DAY? IN THIS PART OF THE GALAXY? LOCALIZED ENTIRELY WITHIN MY VISION?"), //This is an unused mob, write actual ones if we ever actually finish it.
	/mob/living/simple_animal/hostile/megafauna/bubblegum = list("BUBBLEGUM, WATCH THE BLOOD!!", "KEEP YOUR DISTANCE, BUBBLEGUM IS LETHAL UP CLOSE!!", "BLOODY HELL, BUBBLEGUM SPOTTED!!", "STAY OUT OF THE BLOOD POOLS, BUBBLEGUM!!"),
	/mob/living/simple_animal/hostile/megafauna/demonic_frost_miner = list("DEMONIC MINER!!", "WATCH YOURSELVES, DEMON MINER SPOTTED!!", "DEMON MINER, DON'T LET IT STEAL YOUR SOUL!!", "FROST-CRAZED MINER, DODGE THE BASTARD!!"),
	/mob/living/simple_animal/hostile/megafauna/dragon = list("BY THE BEARD, DRAGON!!", "WE'VE GOT A DRAGON ON OUR HANDS!!", "ASH DRAKE, DON'T LET IT BURN YOU!!", "THERE'S AN ASH DRAKE!!", "ASH DRAKE!!"),
	/mob/living/simple_animal/hostile/megafauna/hierophant = list("HIEROPHANT IN SIGHT!!", "WATCH IT, HIEROPHANT ON RHYTHM!!", "DANCE TO THE HIEROPHANT'S BEAT IF YOU WANNA LIVE!!", "HIEROPHANT!!"),
	/mob/living/simple_animal/hostile/megafauna/legion = list("LEGION!!", "SOMEONE WOKE THE LEGION!!", "THIS IS IT, LADS! LEGION SPOTTED!!", "A LEGION TO ONE, I LIKE THESE ODDS!!"),
	/mob/living/simple_animal/hostile/megafauna/wendigo = list("WENDIGO!!", "WE'VE GOT A WENDIGO HERE!!", "KEEP THE WENDIGO AT RANGE, LADS!!", "KEEP MOVING, THIS WENDIGO IS FAST!!"),


	//Items: Materials
	/obj/item/stack/sheet/mineral/diamond = list(),
	/obj/item/stack/sheet/mineral/uranium = list(),
	/obj/item/stack/sheet/mineral/plasma = list(),
	/obj/item/stack/sheet/mineral/gold = list(),
	/obj/item/stack/sheet/mineral/silver = list(),
	/obj/item/stack/sheet/mineral/bananium = list(),
	/obj/item/stack/sheet/mineral/titanium = list(),
	/obj/item/stack/sheet/mineral/plastitanium = list(),
	/obj/item/stack/sheet/mineral/adamantine = list(),
	/obj/item/stack/sheet/mineral/abductor = list(),
	/obj/item/stack/sheet/mineral/coal = list(),
	/obj/item/stack/sheet/mineral = list(),


	//Items: Raw Ore
	/obj/item/stack/ore/glass = list(),
	/obj/item/stack/ore/uranium = list(),
	/obj/item/stack/ore/iron = list(),
	/obj/item/stack/ore/plasma = list(),
	/obj/item/stack/ore/silver = list(),
	/obj/item/stack/ore/gold = list("WE'RE RICH!"), //Yes, yes, you're rich... time to get a move on! I got Management breathing down my neck here!
	/obj/item/stack/ore/diamond = list(),
	/obj/item/stack/ore/bananium = list(),
	/obj/item/stack/ore/titanium = list(),
	/obj/item/gibtonite = list(),
	/obj/item/stack/ore = list(),

	//Items: Mining
	/obj/item/pickaxe = list("Rock and stone!", "For rock and stone!", "For Karl!", "Rock and stone forever!", "We are unbreakable!", "Rock and roll and stone!", "If you don't rock and stone, you ain't comin' home!", "Rock solid!"),
	/obj/item/shovel = list("Can you dig it?", "Oh yeah, I dig it.", "Lets dig up some sand!"),
	/obj/structure/closet = list(),
	/obj/structure/ore_box = list("My grandpa told me they used real mules back in the day!", "Drag this behind you!", "Ore box!", "Throw the ores in here, lads!", "Grab an ore crate!", "Minerals in here!"),
	/obj/item/storage/bag/ore/holding = list("Finally, I can hold all of my rocks AND stones!", "Infinite ore storage!", "Why don't we make these for everything?", "Ore bag!", "Mineral bag!"),

	/obj/item/gun/energy/recharge/kinetic_accelerator = list(),
	/obj/item/borg/upgrade/modkit = list(),

	/obj/item/kinetic_crusher = list(),
	/obj/item/crusher_trophy = list(),

	/mob/living/basic/mining_drone = list("My reliable drone!", "Bosco!", "Bosco, buddy!", "My all-purpose drone!"),
	/obj/item/slimepotion/slime/sentience/mining = list("Lets upgrade Bosco!", "Time to make Bosco smarter!"),

	/obj/item/skeleton_key = list(),
	/obj/item/mining_voucher = list(),
	/obj/item/wormhole_jaunter = list(),

	/obj/item/organ/internal/monster_core = list(),
	/obj/item/reagent_containers/hypospray/medipen/survival = list(),
	/obj/item/extinguisher = list(),
	/obj/item/lazarus_injector = list(),
	/obj/item/extraction_pack = list(),
	/obj/item/fulton_core = list(),

	/obj/item/t_scanner/adv_mining_scanner = list(),
	/obj/item/mining_scanner = list(),
	/obj/item/clothing/glasses/meson = list(),
	/obj/item/survivalcapsule/luxuryelite = list(),
	/obj/item/survivalcapsule = list(),
	/obj/item/style_meter = list(),
	/obj/item/stack/spacecash = list(),

	//Items: Misc
	/obj/item/toy/plush/moth = list("Bug!", "Found a bug!", "There's a bug here!", "Moth!", "Moth here!", "🐛"),

	//Machines
	/obj/machinery/mineral/ore_redemption = list(),
	/obj/machinery/computer/shuttle = list(),

	//Static Objects: Icemoon
	/obj/structure/flora/ash/chilly = list(),

	//Static Objects: Oshan

	//Static Objects: Lavaland & Other
	/obj/structure/flora/rock = list("Rock! Or stone?", "Rock!", "Pioneers used to ride these babies for miles."),
	/obj/structure/geyser = list(),
	/obj/structure/flora/ash/cacti = list(),
	/obj/structure/flora/ash/fireblossom = list(),
	/obj/structure/flora/ash/seraka = list(),
	/turf/closed/mineral = list("Dig through here.", "Minerals inside?", "We need to dig here.", "Drill here?"),

	//You just know I had to do this.
	/obj/structure/flora/ash/cap_shroom = list("Mushroom!"),
	/obj/structure/flora/ash/leaf_shroom = list("Mushroom!"),
	/obj/structure/flora/ash/stem_shroom = list("Mushroom!"),
	/obj/structure/flora/ash/tall_shroom = list("Mushroom!")
))



/obj/item/skillchip/drg_callout
	name = "D.R.G.R.A.S Skillchip" //Deep Rock Galactic Reactive Alert System (Or ROCK AND STONE)
	desc = "Smells faintly of alcohol and has an odd coffee stain on it."
	custom_price = PAYCHECK_CREW
	complexity = 0
	skill_name = "Miner Communication"
	skill_description = "Understand the skills required to rapidly recognize and call out objects you've pointed at to teammates."
	skill_icon = "person_digging"
	cooldown = 5 SECONDS //Honestly, this should be easy to turn off at any time if you don't want it anymore.
	activate_message = "<span class='notice'>You suddenly understand the need to shout about things you point at.</span>"
	deactivate_message = "<span class='notice'>You no longer understand why you were yelling so much.</span>"
	//5-10 second delay for radio messages
	COOLDOWN_DECLARE(radio_cooldown)
	//1 second delay for regular point shouts
	COOLDOWN_DECLARE(shout_cooldown)


/obj/item/skillchip/drg_callout/on_activate(mob/living/carbon/user, silent)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_POINTED, PROC_REF(point_handler))

/obj/item/skillchip/drg_callout/proc/point_handler(mob/pointing_mob, atom/pointed_at)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, shout_cooldown))
		return

	//Note that the reason I'm using this proc is because is_path_in_list actually only returns "list()", or "TRUE" rather than the list itself.
	var/type = is_path_in_list_return_path(pointed_at.type, GLOB.miner_callouts)
	if(!type)
		return
	var/list/callouts = GLOB.miner_callouts[type]
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
