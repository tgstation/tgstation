//Fluff structures serve no purpose and exist only for enriching the environment. They can be destroyed with a wrench.

/obj/structure/fluff
	name = "fluff structure"
	desc = "Effectively impervious to conventional methods of destruction."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "minibar"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE
	density = FALSE
	opacity = FALSE
	var/deconstructible = TRUE

/obj/structure/fluff/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WRENCH && deconstructible)
		user.visible_message("<span class='notice'>[user] starts disassembling [src]...</span>", "<span class='notice'>You start disassembling [src]...</span>")
		I.play_tool_sound(src)
		if(I.use_tool(src, user, 50))
			user.visible_message("<span class='notice'>[user] disassembles [src]!</span>", "<span class='notice'>You break down [src] into scrap metal.</span>")
			playsound(user, 'sound/items/deconstruct.ogg', 50, TRUE)
			new/obj/item/stack/sheet/metal(drop_location())
			qdel(src)
		return
	..()

/obj/structure/fluff/empty_terrarium //Empty terrariums are created when a preserved terrarium in a lavaland seed vault is activated.
	name = "empty terrarium"
	desc = "An ancient machine that seems to be used for storing plant matter. Its hatch is ajar."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "terrarium_open"
	density = TRUE

/obj/structure/fluff/empty_sleeper //Empty sleepers are created by a good few ghost roles in lavaland.
	name = "empty sleeper"
	desc = "An open sleeper. It looks as though it would be awaiting another patient, were it not broken."
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/fluff/empty_sleeper/nanotrasen
	name = "broken hypersleep chamber"
	desc = "A Nanotrasen hypersleep chamber - this one appears broken. \
		There are exposed bolts for easy disassembly using a wrench."
	icon_state = "sleeper-o"

/obj/structure/fluff/empty_sleeper/syndicate
	icon_state = "sleeper_s-open"

/obj/structure/fluff/empty_cryostasis_sleeper //Empty cryostasis sleepers are created when a malfunctioning cryostasis sleeper in a lavaland shelter is activated
	name = "empty cryostasis sleeper"
	desc = "Although comfortable, this sleeper won't function as anything but a bed ever again."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper_open"

/obj/structure/fluff/broken_flooring
	name = "broken tiling"
	desc = "A segment of broken flooring."
	icon = 'icons/obj/brokentiling.dmi'
	icon_state = "corner"

/obj/structure/fluff/drake_statue //Ash drake status spawn on either side of the necropolis gate in lavaland.
	name = "drake statue"
	desc = "A towering basalt sculpture of a proud and regal drake. Its eyes are six glowing gemstones."
	icon = 'icons/effects/64x64.dmi'
	icon_state = "drake_statue"
	pixel_x = -16
	density = TRUE
	deconstructible = FALSE
	layer = EDGED_TURF_LAYER

/obj/structure/fluff/drake_statue/falling //A variety of statue in disrepair; parts are broken off and a gemstone is missing
	desc = "A towering basalt sculpture of a drake. Cracks run down its surface and parts of it have fallen off."
	icon_state = "drake_statue_falling"


/obj/structure/fluff/bus
	name = "bus"
	desc = "GO TO SCHOOL. READ A BOOK."
	icon = 'icons/obj/bus.dmi'
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/bus/dense
	name = "bus"
	icon_state = "backwall"

/obj/structure/fluff/bus/passable
	name = "bus"
	icon_state = "frontwalltop"
	density = FALSE
	layer = ABOVE_ALL_MOB_LAYER //except for the stairs tile, which should be set to OBJ_LAYER aka 3.


/obj/structure/fluff/bus/passable/seat
	name = "seat"
	desc = "Buckle up! ...What do you mean, there's no seatbelts?!"
	icon_state = "backseat"
	pixel_y = 17
	layer = OBJ_LAYER


/obj/structure/fluff/bus/passable/seat/driver
	name = "driver's seat"
	desc = "Space Jesus is my copilot."
	icon_state = "driverseat"

/obj/structure/fluff/bus/passable/seat/driver/attack_hand(mob/user)
	playsound(src, 'sound/items/carhorn.ogg', 50, TRUE)
	. = ..()

/obj/structure/fluff/paper
	name = "dense lining of papers"
	desc = "A lining of paper scattered across the bottom of a wall."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "paper"
	deconstructible = FALSE

/obj/structure/fluff/paper/corner
	icon_state = "papercorner"

/obj/structure/fluff/paper/stack
	name = "dense stack of papers"
	desc = "A stack of various papers, childish scribbles scattered across each page."
	icon_state = "paperstack"


/obj/structure/fluff/divine
	name = "Miracle"
	icon = 'icons/obj/hand_of_god_structures.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/fluff/divine/nexus
	name = "nexus"
	desc = "It anchors a deity to this world. It radiates an unusual aura. It looks well protected from explosive shock."
	icon_state = "nexus"

/obj/structure/fluff/divine/conduit
	name = "conduit"
	desc = "It allows a deity to extend their reach.  Their powers are just as potent near a conduit as a nexus."
	icon_state = "conduit"

/obj/structure/fluff/divine/convertaltar
	name = "conversion altar"
	desc = "An altar dedicated to a deity."
	icon_state = "convertaltar"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	can_buckle = 1

/obj/structure/fluff/divine/forge
	name = "Ruinous Forge"
	desc = "A forge dedicated to producing corrupting pieces of armor and weaponry... Bah, I'm sure we'll be fine using whatever comes out of it!"
	icon_state = "forge-blue"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE

/obj/structure/fluff/divine/powerpylon
	name = "power pylon"
	desc = "A pylon which increases the deity's rate it can influence the world."
	icon_state = "powerpylon"
	can_buckle = 1

/obj/structure/fluff/divine/defensepylon
	name = "defense pylon"
	desc = "A pylon which is blessed to withstand many blows, and fire strong bolts at nonbelievers. A god can toggle it."
	icon_state = "defensepylon"

/obj/structure/fluff/divine/shrine
	name = "shrine"
	desc = "A shrine dedicated to a deity."
	icon_state = "shrine"

/obj/structure/fluff/fokoff_sign
	name = "crude sign"
	desc = "A crudely-made sign with the words 'fok of' written in some sort of red paint."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "fokof"

/obj/structure/fluff/big_chain
	name = "giant chain"
	desc = "A towering link of chains leading up to the ceiling."
	icon = 'icons/effects/32x96.dmi'
	icon_state = "chain"
	layer = ABOVE_OBJ_LAYER
	anchored = TRUE
	density = TRUE
	deconstructible = FALSE

/obj/structure/fluff/beach_towel
	name = "beach towel"
	desc = "A towel decorated in various beach-themed designs."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "railing"
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/beach_umbrella
	name = "beach umbrella"
	desc = "A fancy umbrella designed to keep the sun off beach-goers."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "brella"
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/beach_umbrella/security
	icon_state = "hos_brella"

/obj/structure/fluff/beach_umbrella/science
	icon_state = "rd_brella"

/obj/structure/fluff/beach_umbrella/engine
	icon_state = "ce_brella"

/obj/structure/fluff/beach_umbrella/cap
	icon_state = "cap_brella"

/obj/structure/fluff/beach_umbrella/syndi
	icon_state = "syndi_brella"

/obj/structure/fluff/clockwork
	name = "Clockwork Fluff"
	icon = 'icons/obj/clockwork_objects.dmi'
	deconstructible = FALSE

/obj/structure/fluff/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	icon_state = "alloy_shards"

/obj/structure/fluff/clockwork/alloy_shards/small
	icon_state = "shard_small1"

/obj/structure/fluff/clockwork/alloy_shards/medium
	icon_state = "shard_medium1"

/obj/structure/fluff/clockwork/alloy_shards/medium_gearbit
	icon_state = "gear_bit1"

/obj/structure/fluff/clockwork/alloy_shards/large
	icon_state = "shard_large1"

/obj/structure/fluff/clockwork/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	icon_state = "blind_eye"

/obj/structure/fluff/clockwork/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	icon_state = "fallen_armor"

/obj/structure/fluff/clockwork/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	icon_state = "clockgolem_dead"

/obj/structure/fluff/hedge
	name = "hedge"
	desc = "A large bushy hedge."
	icon = 'icons/obj/smooth_structures/hedge.dmi'
	icon_state = "hedge-0"
	base_icon_state = "hedge"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HEDGE_FLUFF)
	canSmoothWith = list(SMOOTH_GROUP_HEDGE_FLUFF)
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/hedge/opaque //useful for mazes and such
	opacity = TRUE

/obj/structure/fluff/corn_wall
	name = "corn wall"
	desc = "A large wall of corn. Perfect for a maize."
	icon = 'icons/obj/fluff_large.dmi'
	icon_state = "corn_wall"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/support // someone test to see if projectiles can go through this later.
	name = "support beam"
	desc = "This helps keep the tent up."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "support"
	max_integrity = 5000
	mouse_opacity = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = 3.9
	pass_flags = LETPASSTHROW
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

// ------------------- SIGNS

/obj/structure/fluff/books_sign
	name = "crude sign"
	desc = "A crudely-made sign with the words 'books' written. What could it mean?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "books"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/hop_sign
	name = "crude sign"
	desc = "A crudely-made sign with the the symbol of a HoP's hat drawn. Paperwork at a place meant for fun? Sounds even more fun!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "paperwork"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/medieval_sign
	name = "crude sign"
	desc = "A crudely-made sign with the the symbol of a crown, implying that this is a medieval stand."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "medieval"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/oranges_sign
	name = "crude sign"
	desc = "A crudely-made sign with the a drawn orange. Has the day of the juicer finally arrived?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "juicer"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/ruinous_sign
	name = "crude sign"
	desc = "A crudely-made sign with an even more crude symbol. Who made this crap? A bunch of evil lunatics?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "evil"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/store_sign
	name = "crude sign"
	desc = "A crudely-made sign with two letters representing an ancient company. It's also the only company whose plastic is still expensive in 2560."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "satire"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/diy_sign
	name = "crude sign"
	desc = "A crudely-made sign with three letters standing for Do It Yourself. Well, go on!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "DIY"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/yeah_go_heck_yourself
	name = "very important disclaimer"
	desc = "The sign is telling you that, in an objectively truthful way, this is not canon. Lizards are now also kinda dumb for this one."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "inept_no_stop"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/spaghetti_sign
	name = "crude sign"
	desc = "A crudely-made sign with a chef hat drawn onto it. Hope they brought lots of spaghetti!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "foodghetti"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/dough_sign
	name = "extremely crude sign"
	desc = "A crudely-made sign with three symbols of the letter M drawn onto it an- Is that a landmine underneath it?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "motherfucking_fried_dough"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/donuts_sign
	name = "crude sign"
	desc = "A crudely-made sign with a donut symbol drawn onto it. Try not to eat too much!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "donuts"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/pastry_sign
	name = "crude sign"
	desc = "A crudely-made sign with a pie symbol drawn onto it. Hope you had dinner first!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "pastry_goods"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/offtopic_sign
	name = "crude sign"
	desc = "A crudely-made sign with a small popsicle drawn onto it. It doesn't seem to fit the stand at all, besides the color, however surely NO ONE would notice..."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "ice_cream"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

// -------------------

/obj/structure/fluff/headstone
	name = "headstone"
	desc = "R.I.P."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "headstone"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/thefuckinggate // this shit is 9 fucking tiles, dude. This is a bruh moment.
	name = "Gate of the Toolbox Tournament"
	desc = "Man, that looks really fancy! Now, how much of our wages did Nanotrasen cut to afford this?"
	icon = 'icons/obj/fancy_gate.dmi'
	icon_state = "gateblue" // I LIKE BLUE SO MY BIAS IS BETTER - blue gang
	max_integrity = 9999
	layer = 5
	bound_width = 288 // should hopefully be 9x1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/haunted_tv
	name = "Television"
	desc = "Hey, where did the signal go?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "haunted_tv"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/medieval_stage1
	name = "Anvil"
	desc = "Top of the line technology from around ten centuries ago."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "anvil"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/medieval_stage2
	name = "Forge"
	desc = "Top of the line technology from around ten centuries ago."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "furnace_on"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/skeletal_bodybody
	name = "remains"
	desc = "A fake pile of bones and a skull. Spooky!"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	layer = 3
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/skeletal_showcase
	name = "skeleton showcase"
	desc = "A totally fake replica of a spooky skeleton! On second thought, wait, is it fake?"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "showcase_6"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/unfinished_placeholder // meant so I can reveal a missing structure more easily.
	name = "FINISH THIS LATER"
	desc = "guys, someone code it in pls"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "error" // don't fix the error on purpose
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/fakespace
	name = "space"
	desc = ""
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	mouse_opacity = 0
	layer = 5

/obj/structure/fluff/starspawn
	name = "meta-transdimensional rift"
	desc = "<span class='hypnophrase'>What mindfuckery is this?! Agh, I'm going MAD! I'M GOING INSANE!!! AAAAAAAAARGH!!!!!</span>"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "portal"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/robot
	name = "Inactive Robot"
	desc = "That doesn't look good. Well, at least for the A.I. that is."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "getting_wacked"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/spookedya
	name = "True Mr. Bones"
	desc = "You've been spooked by, you've been scared by, a smooth skeleton!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "moonspook"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/spookedaltar // i am tired of it fucking breaking.
	name = "sacrifical altar"
	desc = "Hm, I don't think we should actually try and sacrifice anyone on this. Unless..."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "altar"
	layer = 2.8
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/spookedclue
	name = "Blue's Clue"
	desc = "One of the many Blue's Clues. It says, 'WILD RIDE.' No meaning can be gained from this."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "wildride1"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/narsie
	name = "ritual rune" // man, i really hope no one expects this to be a real rune. that'd suck.
	desc = "Is that a rune of the Geometer? Man, I really hope fake runes don't count for rituals..."
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	max_integrity = 9999
	layer = 2.54
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/blue
	name = "Blutopia Flag"
	desc = "A banner with the logo of the color blue. Team-related violence has never been the same since this flag was made."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner-blue"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/red
	name = "Redemoracy Flag"
	desc = "A banner with the logo of the color red. Team-related violence has never been the same since this flag was made."
	icon = 'icons/obj/banner.dmi'
	icon_state = "banner-red"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/stop1
	name = "Holobarrier Sign"
	desc = "What do you mean we can't go on the really cool ferris wheel?!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign_sec"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/stop2
	name = "Holobarrier Sign"
	desc = "What do you mean we can't go on the really cool ferris wheel?!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holosign_engi"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/body1
	name = "Body Outline"
	desc = "Someone must've died. Did the ferris wheel do it? Murderers always return to the scene of the crime!"
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "body"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/playertrophy1 // Ashe
	name = "Bust of The Rat"
	desc = "A bust that resembles the head of a rat. Don't worry, it won't chomp down on you!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "rat_bust"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/ferriswheel
	name = "Old Swaying Relaxation Spinner" // i didn't come up with this name for nothing, tattlemothe.
	desc = "You'd be surprised to learn that the most expensive thing for this year's Toolbox Tournament isn't the tents, the arena technology, the announcers' paychecks, or even the golden gate south of us. The most expensive thing is actually straight from Earth/Terra itself: The O.S.R.S. It's a highly advanc- Oh, for fucksake, it's just a ferris wheel. Hop in alre... Wait, we can't. Well, reading this was a waste of time."
	icon = 'icons/misc/ferris1d.dmi'
	icon_state = "ferris"
	pixel_x = -64 //So the big ol' 160x160 sprite shows up right
	max_integrity = 9999
	layer = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/eldritchbig
	name = "Transmutation rune" // this is but a tribute!
	desc = "Yeah, I guess that looks eldritch."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "eldritch_rune1"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = 2.54
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/playertrophy2 // Nalzul
	name = "\improper Reliquia De La Antigua Casa"
	desc = "An ancient artpiece that has been redrawn over and over again until we received this as a final product. Still looks very prestigious!"
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "i_am_not_good_at_art"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/playertrophy3 // Swept
	name = "The Watermark"
	desc = "A neat statue of a single letter 'S' that seems very fancy, but I really hope this isn't someone's weird NTnet page watermark..."
	icon = 'icons/misc/tourny_items.dmi'
	icon_state = "swhold"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = FALSE
	anchored = TRUE
	deconstructible = FALSE

/obj/structure/fluff/playertrophy4 // Jackrip
	name = "The Lich"
	desc = "Ah, relax! It's just a really tall skeleton replica that has pyrotechnics coming out of the hands and eyes! It's not an actual lich, but unless it was pretending to be fake... Nah, I'm sure it's not real."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "the_lich"
	max_integrity = 9999
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	density = TRUE
	anchored = TRUE
	deconstructible = FALSE