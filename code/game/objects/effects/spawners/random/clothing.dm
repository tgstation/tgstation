/obj/effect/spawner/random/clothing
	name = "clothing loot spawner"
	desc = "Time to look pretty."
	icon_state = "hat"

/obj/effect/spawner/random/clothing/costume
	name = "random costume spawner"
	icon_state = "costume"
	loot_subtype_path = /obj/effect/spawner/costume
	loot = list()

/obj/effect/spawner/random/clothing/beret_or_rabbitears
	name = "beret or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/costume/rabbitears,
	)

/obj/effect/spawner/random/clothing/bowler_or_that
	name = "bowler or top hat spawner"
	loot = list(
		/obj/item/clothing/head/hats/bowler,
		/obj/item/clothing/head/hats/tophat,
	)

/obj/effect/spawner/random/clothing/kittyears_or_rabbitears
	name = "kitty ears or rabbit ears spawner"
	loot = list(
		/obj/item/clothing/head/costume/kitty,
		/obj/item/clothing/head/costume/rabbitears,
	)

/obj/effect/spawner/random/clothing/pirate_or_bandana
	name = "pirate hat or bandana spawner"
	loot = list(
		/obj/item/clothing/head/costume/pirate,
		/obj/item/clothing/head/costume/pirate/bandana,
	)

/obj/effect/spawner/random/clothing/twentyfive_percent_cyborg_mask
	name = "25% cyborg mask spawner"
	spawn_loot_chance = 25
	loot = list(/obj/item/clothing/mask/gas/cyborg)

/obj/effect/spawner/random/clothing/mafia_outfit
	name = "mafia outfit spawner"
	icon_state = "costume"
	loot = list(
		/obj/effect/spawner/costume/mafia = 20,
		/obj/effect/spawner/costume/mafia/white = 5,
		/obj/effect/spawner/costume/mafia/beige = 5,
		/obj/effect/spawner/costume/mafia/checkered = 2,
	)

/obj/effect/spawner/random/clothing/syndie
	name = "syndie outfit spawner"
	icon_state = "syndicate"
	loot = list(
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/under/syndicate/skirt,
		/obj/item/clothing/under/syndicate/bloodred,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/under/syndicate/tacticool/skirt,
		/obj/item/clothing/under/syndicate/sniper,
		/obj/item/clothing/under/syndicate/camo,
		/obj/item/clothing/under/syndicate/soviet,
		/obj/item/clothing/under/syndicate/combat,
		/obj/item/clothing/under/syndicate/rus_army,
		/obj/item/clothing/under/syndicate/bloodred/sleepytime,
	)

/obj/effect/spawner/random/clothing/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon_state = "gloves"
	loot = list(
		/obj/item/clothing/gloves/color/orange,
		/obj/item/clothing/gloves/color/red,
		/obj/item/clothing/gloves/color/blue,
		/obj/item/clothing/gloves/color/purple,
		/obj/item/clothing/gloves/color/green,
		/obj/item/clothing/gloves/color/grey,
		/obj/item/clothing/gloves/color/light_brown,
		/obj/item/clothing/gloves/color/brown,
		/obj/item/clothing/gloves/color/white,
		/obj/item/clothing/gloves/color/rainbow,
	)

/obj/effect/spawner/random/clothing/lizardboots
	name = "random lizard boot quality"
	desc = "Which ever gets picked, the lizard race loses"
	icon_state = "lizard_boots"
	loot = list(
		/obj/item/clothing/shoes/cowboy/lizard = 7,
		/obj/item/clothing/shoes/cowboy/lizard/masterwork = 1
	)

/obj/effect/spawner/random/clothing/wardrobe_closet
	name = "wardrobe closet spawner"
	icon_state = "locker_clothing"
	loot = list(
		/obj/structure/closet/gmcloset,
		/obj/structure/closet/chefcloset,
		/obj/structure/closet/jcloset,
		/obj/structure/closet/lawcloset,
		/obj/structure/closet/wardrobe/chaplain_black,
		/obj/structure/closet/wardrobe/red,
		/obj/structure/closet/wardrobe/cargotech,
		/obj/structure/closet/wardrobe/atmospherics_yellow,
		/obj/structure/closet/wardrobe/engineering_yellow,
		/obj/structure/closet/wardrobe/white/medical,
		/obj/structure/closet/wardrobe/robotics_black,
		/obj/structure/closet/wardrobe/chemistry_white,
		/obj/structure/closet/wardrobe/genetics_white,
		/obj/structure/closet/wardrobe/virology_white,
		/obj/structure/closet/wardrobe/science_white,
		/obj/structure/closet/wardrobe/botanist,
		/obj/structure/closet/wardrobe/curator,
		/obj/structure/closet/wardrobe/pjs,
	)

/obj/effect/spawner/random/clothing/wardrobe_closet_colored
	name = "colored uniform closet spawner"
	icon_state = "locker_clothing"
	loot = list(
		/obj/structure/closet/wardrobe/mixed,
		/obj/structure/closet/wardrobe,
		/obj/structure/closet/wardrobe/pink,
		/obj/structure/closet/wardrobe/black,
		/obj/structure/closet/wardrobe/green,
		/obj/structure/closet/wardrobe/orange,
		/obj/structure/closet/wardrobe/yellow,
		/obj/structure/closet/wardrobe/white,
		/obj/structure/closet/wardrobe/grey,
	)

/obj/effect/spawner/random/clothing/backpack
	name = "backpack spawner"
	icon_state = "backpack"
	loot = list(
		/obj/item/storage/backpack,
		/obj/item/storage/backpack/clown,
		/obj/item/storage/backpack/explorer,
		/obj/item/storage/backpack/mime,
		/obj/item/storage/backpack/medic,
		/obj/item/storage/backpack/security,
		/obj/item/storage/backpack/industrial,
		/obj/item/storage/backpack/botany,
		/obj/item/storage/backpack/chemistry,
		/obj/item/storage/backpack/genetics,
		/obj/item/storage/backpack/science,
		/obj/item/storage/backpack/virology,
		/obj/item/storage/backpack/satchel,
		/obj/item/storage/backpack/satchel/leather,
		/obj/item/storage/backpack/satchel/eng,
		/obj/item/storage/backpack/satchel/med,
		/obj/item/storage/backpack/satchel/vir,
		/obj/item/storage/backpack/satchel/chem,
		/obj/item/storage/backpack/satchel/gen,
		/obj/item/storage/backpack/satchel/science,
		/obj/item/storage/backpack/satchel/hyd,
		/obj/item/storage/backpack/satchel/sec,
		/obj/item/storage/backpack/satchel/explorer,
		/obj/item/storage/backpack/duffelbag,
		/obj/item/storage/backpack/duffelbag/med,
		/obj/item/storage/backpack/duffelbag/explorer,
		/obj/item/storage/backpack/duffelbag/hydroponics,
		/obj/item/storage/backpack/duffelbag/chemistry,
		/obj/item/storage/backpack/duffelbag/genetics,
		/obj/item/storage/backpack/duffelbag/science,
		/obj/item/storage/backpack/duffelbag/virology,
		/obj/item/storage/backpack/duffelbag/sec,
		/obj/item/storage/backpack/duffelbag/engineering,
		/obj/item/storage/backpack/duffelbag/clown,
		/obj/item/storage/backpack/messenger,
		/obj/item/storage/backpack/messenger/eng,
		/obj/item/storage/backpack/messenger/med,
		/obj/item/storage/backpack/messenger/vir,
		/obj/item/storage/backpack/messenger/chem,
		/obj/item/storage/backpack/messenger/gen,
		/obj/item/storage/backpack/messenger/science,
		/obj/item/storage/backpack/messenger/hyd,
		/obj/item/storage/backpack/messenger/sec,
		/obj/item/storage/backpack/messenger/explorer,
	)

/obj/effect/spawner/random/clothing/funny_hats
	name = "random hat spawner"
	icon_state = "hat"
	desc = "This is the update that ruined Spacestation 13 forever. I can't believe what the TG Coders have done. \
		They've added fucking HATS! HATS!!! In MY competitive-roleplay-action-click-shooter-stabber-against-two-sides-to-detonate-the-payload game? \
		This isn't what I signed up for and why I supported this game! My game is chugging with every update to this stupid project and \
		I can't fucking stand it anymore. And instead of fixing the bugs or getting rid of the exploits, they just keep adding more \
		fucking hats so that the dumbasses that keep feeding into the coders bullshit will eat it up and ignore the glaring problems with it. \
		They've stopped caring. We've not had a REAL update in almost 5 years of development! Just removals! It's been all downhill since cloning and stuns were removed. \
		And frankly, I don't know what to do. There isn't any other competitive-roleplay-action-click-shooter-stabber-against-two-sides-to-detonate-the-payload game \
		out there that isn't trying to get my donator money just so I can have a single sprite added to the game and autoequipped to my character. \
		Next thing you know, the coders are going to have us PAY for these goddamn pixels on our character! Imagine having to pay for extra pixels! \
		I'm fucking DONE WITH THIS GAME! I'M THROUGH WITH THIS SHIT! FUCK THE CODERS! I JUST WANT TO PLAY MY COMPETITIVE-ROLEPLAY-ACTION-\
		CLICK-SHOOTER-STABBER-AGAINST-TWO-SIDES-TO-DETONATE-THE-PAYLOAD GAME THAT ISN'T DRAGGED DOWN BY HORRIBLE ADMINS THAT BAN ME WHEN I SAY \
		CERTAIN WORDS THAT I AM ENTITLED TO SAY ON THE INTERNET! I'M THROUGH WITH THIS! I'M GOING TO GO PLAY A PURE, GENUINE GAME. WITH NO FUCKING HATS!"
	loot = list(
		/obj/item/clothing/head/costume/powdered_wig,
		/obj/item/clothing/head/costume/cueball,
		/obj/item/clothing/head/costume/snowman,
		/obj/item/clothing/head/costume/witchwig,
		/obj/item/clothing/head/costume/maid_headband,
		/obj/item/clothing/head/costume/chicken,
		/obj/item/clothing/head/costume/griffin,
		/obj/item/clothing/head/costume/xenos,
		/obj/item/clothing/head/costume/lobsterhat,
		/obj/item/clothing/head/costume/cardborg,
		/obj/item/clothing/head/costume/football_helmet,
		/obj/item/clothing/head/costume/tv_head,
		/obj/item/clothing/head/costume/tmc,
		/obj/item/clothing/head/costume/deckers,
		/obj/item/clothing/head/costume/yuri,
		/obj/item/clothing/head/costume/allies,
		/obj/item/clothing/head/beret/frenchberet,
		/obj/item/clothing/head/costume/crown,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/head/beanie/red,
		/obj/item/clothing/head/beanie/darkblue,
		/obj/item/clothing/head/rasta,
		/obj/item/clothing/head/costume/constable,
		/obj/item/clothing/head/bio_hood/plague,
		/obj/item/clothing/head/costume/nursehat,
		/obj/item/clothing/head/hats/bowler,
		/obj/item/clothing/head/costume/bearpelt,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/head/cowboy,
		/obj/item/clothing/head/costume/rice_hat,
		/obj/item/clothing/head/costume/pharaoh,
		/obj/item/clothing/head/costume/delinquent,
		/obj/item/clothing/head/costume/jackbros,
		/obj/item/clothing/head/costume/ushanka,
		/obj/item/clothing/head/costume/nightcap/blue,
		/obj/item/clothing/head/costume/nightcap/red,
		/obj/item/clothing/head/mothcap,
		/obj/item/clothing/head/cone,
		/obj/item/clothing/head/collectable/petehat,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/wizard/marisa/fake,
	)
