//Modular Map marker
/obj/modular_map_root/caves
	config_file = "strings/modular_maps/Caves.toml"

//Map objects
/obj/structure/fans/tiny/invisible/caves
	name = "strange field"
	invisibility = INVISIBILITY_MAXIMUM

//Mech used by the clockwork miners
/obj/vehicle/sealed/mecha/working/ripley/mk2/clockcult
	icon_state = "ripleyclockcult"
	base_icon_state = "ripleyclockcult"
	silicon_icon_state = "ripleyclockcult-empty"
	wreckage = /obj/structure/mecha_wreckage/ripley/mk2/clockcult
	desc = "Autonomous Power Loader Unit MK-II. This one seems adorned with strange pieces of bronze metal."
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/structure/mecha_wreckage/ripley/mk2/clockcult
	name = "\improper Ripley MK-II wreckage"
	icon_state = "ripleyclockcult-broken"
	parts = list(
				/obj/item/mecha_parts/part/ripley_torso,
				/obj/item/mecha_parts/part/ripley_left_arm,
				/obj/item/mecha_parts/part/ripley_right_arm,
				/obj/item/mecha_parts/part/ripley_left_leg,
				/obj/item/mecha_parts/part/ripley_right_leg,
				/obj/item/stack/sheet/bronze)

//Mobs specific to the caves mission
/mob/living/simple_animal/hostile/syndicate/mecha_pilot/clockminer //who gave the cultists a RIPLEY?
	name = "Clockwork Servant Mecha Pilot"
	desc = "Death to those who oppose His Gracious Light. This variant comes in MECHA DEATH flavour."
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	icon_state = "clockminer"
	icon_living = "clockminer"
	faction = list("clockwork")
	footstep_type = FOOTSTEP_MOB_HEAVY
	spawn_mecha_type = /obj/vehicle/sealed/mecha/working/ripley/mk2/clockcult

/mob/living/simple_animal/hostile/syndicate/mecha_pilot/no_mech/clockminer
	name = "Clockwork Servant Mecha Pilot"
	desc = "Death to those who oppose His Gracious Light. This variant comes in MECHA DEATH flavour."
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	icon_state = "clockminer"
	icon_living = "clockminer"
	footstep_type = FOOTSTEP_MOB_HEAVY
	faction = list("clockwork")

/mob/living/simple_animal/hostile/clockminer
	name = "Clockwork Servant"
	desc = "A miner adorned with shining bronze armor. They look particularly angry with you."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "clockminer"
	icon_living = "clockminer"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 100
	emote_taunt = list("Uvf Tenpvbhf Yvtug jvyy qnja hcba guvf qnex jbeyq bapr zber! Bear witness, Heretic!", "I will show you His Gracious One's guiding light, either willing or by force!", 
			"Znl Uvf Tenpvbhf Yvtug fuvar bire zr va guvf onggyr. Prepare to be enlightened, Heretic!", "You dare tread upon His Gracious One's sacred resting grounds??")
	var/death_phrases = list("Ratvar... forgive me", "So.. close...", "Where is His Light? Its so.. dark...", "You've forsaken us.. Heretic...")
	turns_per_move = 5
	speed = 2
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 150
	health = 150
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/effect/mob_spawn/corpse/human/clockminer)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("clockwork")
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1
	dodging = TRUE
	dodge_prob = 15
	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/clockminer/death()
	if(prob(25))
		say(pick(death_phrases))
		..()

/mob/living/simple_animal/hostile/retaliate/trader/ashwalker
	name = "Sells-The-Wares"
	desc = "An assshwalker who recognizesss a good businessssss opportunity when ssshe ssseesss it."
	speak_emote = list("hisses")
	speech_span = SPAN_SANS
	sell_sound = 'sound/voice/hiss2.ogg'
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	weather_immunities = list(TRAIT_ASHSTORM_IMMUNE)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	itemrejectphrase = "...Perhapsss we do not ssshare sssimilar ideasss of.. worth?"
	itemsellcancelphrase = "What a ssshame, you know where to find me if you happen to... change your mind."
	itemsellacceptphrase = "Thisss will make a great trinket for the brood mother..."
	interestedphrase = "You.. I see you have ssshiny. Why not participate in some Nanotrasssen-approved capitalisssm?"
	buyphrase = "Hss.. Pleasssure doing busssinesss with you."
	nocashphrase = "Do you take me for a sssimpleton like my fellow walkersss? No casssh, no grasssss."
	//TODO: More items in this list that make sense for the mission
	products = list(
		/obj/item/spear/bonespear = 150,
		/obj/item/skeleton_key = 3000,
		/obj/item/shovel/serrated = 150
	)
	wanted_items = list(
		/obj/item/stack/sheet/mineral/snow = 150,
		/obj/item/stack/sheet/bone = 10,
		/obj/item/stack/sheet/bronze = 5,
		/obj/item/food/meat/slab/goliath = 10,
		/obj/item/stack/sheet/animalhide/goliath_hide = 15,
	)
	icon_state = "ashtrader"
	gender = FEMALE
	loot = list(/obj/effect/decal/remains/human)
	lore = list(
		"My brethern may not take ssso kindly to your presssense, but I for one know a good busssinessss opportunity when I sssee it..",
		"Ssstrange blue cryssstal beasssts walk thessse cavesss, their trailsss leaving behind an unusssually cold material... If you can bring me sssome of thisss exotic material, I can make it worth your while..",
		"Where did I get thessse creditsss, you may asssk yourself? Pleassse, keep thossse kindsss of quessstionsss to yourssself.",
		"Running a busssinesss is hard down here you know? The tribe ssstill expectsss you to chip in your fair ssshare of the daily hunt, but that isss work beneath me. Bring me trophiesss from your victoriesss against the local beassstsss, and I will pay handsssomely..",
		"A ssshiny machine livesss deep in thessse cavesss, makesss good metal for better toolsss for the tribe. I pay good price for any ssspare ssshiny you come acrosssss..",
		"I would appreciate you avoiding the needlessss ssslaughter of my kin, but I underssstand sssome of them are more... prone to violent outbreaksss againssst your kind."
	)


//Mob corpse spawns, outfits, and ID cards
/obj/effect/mob_spawn/corpse/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast

/obj/effect/mob_spawn/corpse/human/clockminer
	name = "Clock Cult Miner"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/clockminer

/datum/outfit/clockminer
	name = "Clock Cult Miner"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/bronze
	shoes = /obj/item/clothing/shoes/bronze
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/bronze
	mask = /obj/item/clothing/mask/gas/explorer

/obj/effect/mob_spawn/corpse/human/scientist/caves
	outfit = /datum/outfit/job/scientist/caves

/datum/outfit/job/scientist/caves
	id_trim = /datum/id_trim/away/caves/sci

/obj/effect/mob_spawn/corpse/human/engineer/caves
	outfit = /datum/outfit/job/engineer/gloved/caves

/datum/outfit/job/engineer/gloved/caves
	id_trim = /datum/id_trim/away/caves/engineer

/obj/effect/mob_spawn/corpse/human/miner/explorer/caves
	outfit = /datum/outfit/job/miner/equipped/caves

/datum/outfit/job/miner/equipped/caves
	id_trim = /datum/id_trim/away/caves

//ID Cards
/obj/item/card/id/away/caves
	name = "Mining Region Miner Access Card"
	desc = "An ID with Miner clearance for the lower mines."
	trim = /datum/id_trim/away
	icon_state = "retro"
	registered_age = null

/datum/id_trim/away/caves
	access = list(ACCESS_AWAY_GENERAL)
	assignment = "Mining Post Mining Personnel"

/obj/item/card/id/away/caves/sec
	name = "Mining Region Security Access Card"
	desc = "An ID with security clearance for the lower mines."
	trim = /datum/id_trim/away/caves/security

/datum/id_trim/away/caves/security
	access = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE, ACCESS_AWAY_SEC)
	assignment = "Mining Post Security Personnel"

/obj/item/card/id/away/caves/sci
	name = "Mining Region Science Access Card"
	desc = "An ID with science clearance for the lower mines."
	trim = /datum/id_trim/away/caves/sci

/datum/id_trim/away/caves/sci
	access = list(ACCESS_AWAY_SCIENCE, ACCESS_AWAY_GENERAL)
	assignment = "Mining Post Research Personnel"

/obj/item/card/id/away/caves/robo
	name = "Mining Region Mecha Access Card"
	desc = "An ID with mechabay clearance for the lower mines."
	trim = /datum/id_trim/away/caves/robo

/datum/id_trim/away/caves/robo
	access = list(ACCESS_AWAY_SCIENCE, ACCESS_AWAY_GENERAL)
	assignment = "Mining Post Mechabay Personnel"

/obj/item/card/id/away/caves/site_director
	name = "Mining Region Site Director"
	desc = "An ID with Site Director clearance for the lower mines."
	trim = /datum/id_trim/away/caves/site_director

/datum/id_trim/away/caves/site_director
	access = list(ACCESS_AWAY_SCIENCE, ACCESS_AWAY_GENERAL, ACCESS_AWAY_COMMAND, ACCESS_AWAY_MAINTENANCE)
	assignment = "Mining Post Site Director"

/obj/item/card/id/away/caves/engineer
	name = "Mining Region Engineer"
	desc = "An ID with engineering clearance for the lower mines."
	trim = /datum/id_trim/away/caves/engineer

/datum/id_trim/away/caves/engineer
	access = list(ACCESS_AWAY_ENGINEERING, ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINTENANCE)
	assignment = "Mining Post Engineering Personnel"

//Areas
/area/awaymission/caves/bmp_asteroid
	name = "Outpost Region Delta"
	icon_state = "awaycontent1"
	sound_environment = SOUND_AREA_LAVALAND

/area/awaymission/caves/bmp_asteroid/level_two
	name = "Outpost Region Echo"
	icon_state = "awaycontent2"

/area/awaymission/caves/bmp_asteroid/level_three
	name = "Uncharted Depths"
	icon_state = "awaycontent3"

/area/awaymission/caves/bmp_asteroid/level_four
	name = "-INFORMATION REDACTED-"
	icon_state = "awaycontent4"

/area/awaymission/caves/main_outpost
	name = "Mining Outpost Delta"
	icon_state = "awaycontent1"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/caves/main_outpost/storage
	name = "Mining Outpost Delta Suit Storage"

/area/awaymission/caves/main_outpost/dorm
	name = "Mining Outpost Delta Living Quarters"

/area/awaymission/caves/main_outpost/engineering
	name = "Mining Outpost Delta Power Wing"

/area/awaymission/caves/main_outpost/depo
	name = "Mining Outpost Delta Ore Processing"

/area/awaymission/caves/main_outpost/rec
	name = "Mining Outpost Delta Mess Hall"

/area/awaymission/caves/main_outpost/seconadry/storage
	name = "Delta Outpost Storage Lot"

/area/awaymission/caves/main_outpost/seconadry/engineering
	name = "Delta Outpost Life Support"

/area/awaymission/caves/main_outpost/seconadry/mecha
	name = "Delta Outpost Mecha Bay"

/area/awaymission/caves/main_outpost/seconadry/recycle
	name = "Delta Outpost Recycling Post"

/area/awaymission/caves/main_outpost/seconadry/mecha/living
	name = "Delta Outpost Mecha Bay Living Quarters"

/area/awaymission/caves/main_outpost/seconadry/secpost
	name = "Delta Outpost Security Post"

/area/awaymission/caves/main_outpost/seconadry/research
	name = "Delta Outpost Research Post"

/area/awaymission/caves/main_outpost/seconadry/research/living
	name = "Delta Outpost Research Post Living Quarters"

/area/awaymission/caves/main_outpost/seconadry/data
	name = "Delta Outpost Research Post Data Center"

/area/awaymission/caves/main_outpost/seconadry/engineering
	name = "Delta Outpost Research Post Life Support"

/area/awaymission/caves/main_outpost/seconadry/gateway
	name = "Gateway Terminal Delta"

/area/awaymission/caves/main_outpost/seconadry/between_access
	name = "Level Transit Delta"

/area/awaymission/caves/second_outpost
	name = "Mining Outpost Echo"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/caves/second_outpost/tunnel
	name = "Transit Tunnel Access"

/area/awaymission/caves/second_outpost/rest
	name = "Mining Outpost Echo Rest Area"

/area/awaymission/caves/second_outpost/barracks
	name = "Mining Outpost Echo Barracks"

/area/awaymission/caves/second_outpost/researchcenter
	name = "Research Outpost Echo Research Center"

/area/awaymission/caves/second_outpost/researchcenter/dorm
	name = "Research Outpost Echo Research Center Dorms"

/area/awaymission/caves/second_outpost/researchcenter/work
	name = "Research Outpost Echo Research Center Offices"

/area/awaymission/caves/second_outpost/researchcenter/messhall
	name = "Research Outpost Echo Research Center Mess Hall"

/area/awaymission/caves/second_outpost/researchcenter/sitedirector
	name = "Research Outpost Echo Research Center Site Director's Office"

/area/awaymission/caves/second_outpost/researchcenter/engineering
	name = "Research Outpost Echo Research Center Life Support"

/area/awaymission/caves/second_outpost/researchcenter/maint
	name = "Research Outpost Echo Research Center Maintenance"

/area/awaymission/caves/third_outpost
	name = "Scouting Outpost Charlie"

/area/awaymission/caves/third_outpost/transit
	name = "Scouting Outpost Charlie Level Transit"

/area/awaymission/caves/third_outpost/engineering
	name = "Scouting Outpost Charlie Life Support"

/area/awaymission/caves/third_outpost/pod
	name = "Scouting Outpost Charlie Main Office"

/area/awaymission/caves/misc/ashwalker_village
	name = "Lower Region Tribal Area"

/area/awaymission/caves/misc/ayylmao
	name = "Strange Exhibit"

/area/awaymission/caves/misc/ayylmao/holding_cell
	name = "Strange Exhibit Cell"

/area/awaymission/caves/misc/ayylmao/office
	name = "Strange Exhibit Central Room"

/area/awaymission/caves/misc/syndicate
	name = "Recon Outpost Tango-Bravo-443"

/area/awaymission/caves/misc/syndicate/genetics
	name = "Recon Outpost Tango-Bravo-443 Genetics Divison"

/area/awaymission/caves/misc/syndicate/vault
	name = "Recon Outpost Tango-Bravo-443 Secure Storage"

/area/awaymission/caves/misc/syndicate/gateway
	name = "Recon Outpost Tango-Bravo-443 Secure Temporal Transportation Lounge"

/area/awaymission/caves/misc/syndicate/barracks
	name = "Recon Outpost Tango-Bravo-443 Barracks"

/area/awaymission/caves/misc/mining_post
	name = "Mining Depo Golf"

/area/awaymission/caves/misc/mining_post/diverter
	name = "Mining Depo Golf Ore Line Diversion Center"

/area/awaymission/caves/misc/mining_post/smelter1
	name = "Mining Depo Golf Ore Drop-off A"

/area/awaymission/caves/misc/mining_post/smelter2
	name = "Mining Depo Golf Ore Drop-off B"

/area/awaymission/caves/misc/ratvar
	name = "His Eminence's Domain"

/area/awaymission/caves/misc/ratvar/barracks
	name = "Corrupted Barracks"	


//Lore/fluff items for detailing

//Lore terminals
//TODO: MORE LORE MORE LORE MORE LORE
/obj/machinery/computer/terminal/caves/robo
	content = list("MINER-MAIL - #344 - Site Director Richard Evans -> K. Simmers -- I just finished approving your request for additional access to more combat-orienated mecha-based designs. \
	With the introduction of the concern with the locals, Central has deemed it neccesary to elevate our security contract and will be sending blueprint schematics with relevant printing diagnostics. \
	I'll be sending you a material list shortly of what'll be required for manufactoring along with the first few designs our security personnel suggested for the mining crew.")

/obj/machinery/computer/terminal/caves/security
	content = list("MINER-MAIL - #365 - Security Officer Rachael Cleeves -> R. Evans -- I've been watching the cameras between the posts and I think the miners are up to something. \
	They've been awfully secluded during off-hours and they get more tight-lipped than usual when I come past for my hourly route. I confiscated a weird chunk of metal one of them brought in without having it checked out first. \
	Handed it off to Ullman, I think the miners found something valuable and don't want to share with the company..")

/obj/machinery/computer/terminal/caves/research
	content = list("MINER-MAIL - #445 - Shaft Miner Jim Joffee -> J. Ullman -- Just checking for an update on that last email I sent about the debris I found on the lower levels. I know these caves are inhabited by those cave lizards, \
	 but them having bronze metal seems really odd. Don't tell me these lizardbrains are entering the bronze age, they might actually start being a problem.")

/obj/machinery/computer/terminal/caves/research2
	content = list("MINER-MAIL - #456 - Mineral Specialist J. Ullman -> E. Queef -- Do you know if the time clock down by your office was fixed? \
	 I'm tired of checking in at the office by the ravine and if I get docked another half point for being a minute late from lunch again they're going to make me sign a dumb fucking paper about being 'IrReSpOnSiBlE' with my breaks. I hate management.")

/obj/machinery/computer/terminal/caves/research3
	content = list("MINER-MAIL - #420 - Greater Outernet Service Gateway -> W. Zach -- Looking to get absolutely ZOINKED this BLAZER season??? \
	Well, look NO FURTHER than ZERMA'S ZERKIN' EMPORIUM OF KUSH & BUSH. We got strains that'd melt your hydroponic tables! Enter promo code 'ZERKIN20' for 20% off your first intra-space delivery purchase!")

/obj/machinery/computer/terminal/caves/research4
	content = list("MINER-MAIL - #356 - Site Director Richard Evans -> C. Coffee -- The 3rd quarter is almost over! Please have your self-evaluation sheet submitted to me by the end of the week so we may proper aquire on your strengths and weaknesses in this department. \
	Please note that your month-end report on the local floral activity is still due at the same time, so please adjust your schedule properly to make sure both reports are submitted within adaquate time.")

/obj/machinery/computer/terminal/caves/research5
	content = list("INFO-SECURE: Your number one source of encrypted text files! ERROR: Encryption hash not found, file not encrypted! -- NOTES: Cycle 34 - Miners uncovered pieces of scrap bronze from one of the local lizard nests they cleared out recently. \
	 Ullman is a bit perplexed by this as this hellscape we survey has no natural deposits of neither tin nor copper, let alone humoring the prospects these primals may actually be learning metalworking to some extent due to our prolonged presence here. \
	 I've asked the QM if anything in previous request logs had anything made of bronze, mostly to see if maybe they're just stealing from our storage bay during off-hours.")

/obj/machinery/computer/terminal/caves/researchbroke1
	content = list("INFO-SECURE: Your number one source of encrypted text files! ERROR: Terminal set in showcase mode, encryption not available!  -- NOTES: Cycle 20 - Seismic activity in the lower regions has caused fractures to form in the less stable regions of the caves. \
	These fractures seem to go hundreds of feet down, to a point where its hard to judge the actual drop. The Site Director has had a few crates of jaunters ordered for personnel safety, as we can't be certain if these rifts will be kept to the lower levels or not. ")

/obj/machinery/computer/terminal/caves/researchbroke2
	content = list("INFO-SECURE: Your number one source of encrypted text files! ERROR: Subscription service ended, your files are no longer encrypted! -- NOTES: Cycle 12 - Miners discovered a local tribe of lizardpeople native to these lands, the miners have nicknamed them 'Ash Walkers' due to their soot-covered garbs. \
	Initial confrontations ended in hostilities as they threw a few spears at the mining group before fleeing from their kinetic accelerators. The Site Director has contacted central asking for additional defensive measures to keep the locals at bay during our stay down here.")

//Lore papers
/obj/item/paper/fluff/awaymissions/caves/seismic_log
	name = "Seismic Activity Report Log 43-2"
	info = "<b><center>Seismic Activity Chart</b></center><br><br><center>*Various line graphs documenting seismic acitivty of the region over the last several months. \
			The chart seems to spike around a month ago before going back to the baseline*</center>"

/obj/item/paper/fluff/awaymissions/caves/floralguide
	name = "Local Flora Guide"
	info = "<b><center>C. Coffee's Extensive List of Local Wild Flora and What-Not</b></center><br><br><center><b>Leafy Mushrooms</b> are actually native to late Earth, but managed to find its way here. \
			Harvested for it's leaf canopy, the leaves can be ground into a paste with simple medicinal and relaxant properties.</center><br><br><center><b>Tall Mushrooms</b> \
			are several separate mushrooms grouped together, usually with the largest in the center with a circular shelf on the shaft. The caps themselves seem to be harvested by the local \
			lizardkin population for ritualistic purposes, as they have intense hallucigenic properties when ingested.</center><br><br><center><b>Stem Shrooms</b> are small groups of tiny mushrooms that have a bioluminescent property. \
			Harvested for their glowing stems, nutritious when eaten but the fungal itself seems to adhere and grow on the victim's skin with a minor hallucigenic property. Advised against eating unless neccesary. \
			</center><br><br><center><b>Ash Cacti</b> are a type of cacti that find itself native to these lands, growing in small bundles. They grow a sweet fruit that is safe to eat and even has \
			a smaller medicial property to it when used. </center><br><br><center><b>Seraka Mushrooms</b> are a savory mushroom that seems to have a tight cultural connection with the local \
			lizardkin populace. The caps seem to be made into a fine powder for tea prep by the locals, internal research shows that lizardkin seem to have a restorative/healing property from \
			ingesting this, not just limited to the natives but other Nanotrasen-hired crew as well. While not as useful for other species, the extract from the caps themselves make a decent blood clotter \
			in emergency situations with excessive bleeding. Low usage is advised, as its effective coagulating properties can be TOO effective if used in larger doses.</center>"

/obj/item/paper/fluff/awaymissions/caves/researchfluff
	name = "random research document"
	info = "<center>*The paper itself dictates various research scribblings ranging from the local populace to rocks. You try to read on, but you stop yourself as your eyes begin to glaze over.*</center>"
