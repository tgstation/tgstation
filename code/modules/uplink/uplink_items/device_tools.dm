// File ordered based on progression

/datum/uplink_category/device_tools
	name = "Misc. Gadgets"
	weight = 3

/datum/uplink_item/device_tools
	category = /datum/uplink_category/device_tools

// No progression cost

/datum/uplink_item/device_tools/soap
	name = "Syndicate Soap"
	desc = "A sinister-looking surfactant used to clean blood stains to hide murders and prevent DNA analysis. \
			You can also drop it underfoot to slip people."
	item = /obj/item/soap/syndie
	cost = 1
	surplus = 50
	illegal_tech = FALSE

/datum/uplink_item/device_tools/surgerybag
	name = "Syndicate Surgery Duffel Bag"
	desc = "The Syndicate surgery duffel bag is a toolkit containing all surgery tools, surgical drapes, \
			a Syndicate brand MMI, a straitjacket, and a muzzle."
	item = /obj/item/storage/backpack/duffelbag/syndie/surgery
	cost = 3

/datum/uplink_item/device_tools/encryptionkey
	name = "Syndicate Encryption Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to all station department channels \
			as well as talk on an encrypted Syndicate channel with other agents that have the same key."
	item = /obj/item/encryptionkey/syndicate
	cost = 2
	surplus = 75
	restricted = TRUE

/datum/uplink_item/device_tools/syndietome
	name = "Syndicate Tome"
	desc = "Using rare artifacts acquired at great cost, the Syndicate has reverse engineered \
			the seemingly magical books of a certain cult. Though lacking the esoteric abilities \
			of the originals, these inferior copies are still quite useful, being able to provide \
			both weal and woe on the battlefield, even if they do occasionally bite off a finger."
	item = /obj/item/storage/book/bible/syndicate
	cost = 5

/datum/uplink_item/device_tools/thermal
	name = "Thermal Imaging Glasses"
	desc = "These goggles can be turned to resemble common eyewear found throughout the station. \
			They allow you to see organisms through walls by capturing the upper portion of the infrared light spectrum, \
			emitted as heat and light by objects. Hotter objects, such as warm bodies, cybernetic organisms \
			and artificial intelligence cores emit more of this light than cooler objects like walls and airlocks."
	item = /obj/item/clothing/glasses/thermal/syndi
	cost = 4

/datum/uplink_item/device_tools/cutouts
	name = "Adaptive Cardboard Cutouts"
	desc = "These cardboard cutouts are coated with a thin material that prevents discoloration and makes the images on them appear more lifelike. \
			This pack contains three as well as a crayon for changing their appearances."
	item = /obj/item/storage/box/syndie_kit/cutouts
	cost = 1
	surplus = 20

/datum/uplink_item/device_tools/briefcase_launchpad
	name = "Briefcase Launchpad"
	desc = "A briefcase containing a launchpad, a device able to teleport items and people to and from targets up to eight tiles away from the briefcase. \
			Also includes a remote control, disguised as an ordinary folder. Touch the briefcase with the remote to link it."
	surplus = 0
	item = /obj/item/storage/briefcase/launchpad
	cost = 6

/datum/uplink_item/device_tools/camera_bug
	name = "Camera Bug"
	desc = "Enables you to view all cameras on the main network, set up motion alerts and track a target. \
			Bugging cameras allows you to disable them remotely."
	item = /obj/item/camera_bug
	cost = 1
	surplus = 90

/datum/uplink_item/device_tools/military_belt
	name = "Chest Rig"
	desc = "A robust seven-slot set of webbing that is capable of holding all manner of tactical equipment."
	item = /obj/item/storage/belt/military
	cost = 1

/datum/uplink_item/device_tools/doorjack
	name = "Airlock Authentication Override Card"
	desc = "A specialized cryptographic sequencer specifically designed to override station airlock access codes. \
			After hacking a certain number of airlocks, the device will require some time to recharge."
	item = /obj/item/card/emag/doorjack
	cost = 3

/datum/uplink_item/device_tools/fakenucleardisk
	name = "Decoy Nuclear Authentication Disk"
	desc = "It's just a normal disk. Visually it's identical to the real deal, but it won't hold up under closer scrutiny by the Captain. \
			Don't try to give this to us to complete your objective, we know better!"
	item = /obj/item/disk/nuclear/fake
	cost = 1
	surplus = 1
	illegal_tech = FALSE

/datum/uplink_item/device_tools/frame
	name = "F.R.A.M.E. PDA Cartridge"
	desc = "When inserted into a personal digital assistant, this cartridge gives you five PDA viruses which \
			when used cause the targeted PDA to become a new uplink with zero TCs, and immediately become unlocked. \
			You will receive the unlock code upon activating the virus, and the new uplink may be charged with \
			telecrystals normally."
	item = /obj/item/cartridge/virus/frame
	cost = 4
	restricted = TRUE

/datum/uplink_item/device_tools/failsafe
	name = "Failsafe Uplink Code"
	desc = "When entered the uplink will self-destruct immediately."
	item = /obj/effect/gibspawner/generic
	cost = 1
	surplus = 0
	restricted = TRUE
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/device_tools/failsafe/spawn_item(spawn_path, mob/user, datum/uplink_handler/uplink_handler, atom/movable/source)
	var/datum/component/uplink/uplink = source.GetComponent(/datum/component/uplink)
	if(!uplink)
		return
	uplink.failsafe_code = uplink.generate_code()
	var/code = "[islist(uplink.failsafe_code) ? english_list(uplink.failsafe_code) : uplink.failsafe_code]"
	to_chat(user, span_warning("The new failsafe code for this uplink is now : [code]. You may check your antagonist info to recall this."))
	return source //For log icon

/datum/uplink_item/device_tools/toolbox
	name = "Full Syndicate Toolbox"
	desc = "The Syndicate toolbox is a suspicious black and red. It comes loaded with a full tool set including a \
			multitool and combat gloves that are resistant to shocks and heat."
	item = /obj/item/storage/toolbox/syndicate
	cost = 1
	illegal_tech = FALSE

/datum/uplink_item/device_tools/rad_laser
	name = "Radioactive Microlaser"
	desc = "A radioactive microlaser disguised as a standard Nanotrasen health analyzer. When used, it emits a \
			powerful burst of radiation, which, after a short delay, can incapacitate all but the most protected \
			of humanoids. It has two settings: intensity, which controls the power of the radiation, \
			and wavelength, which controls the delay before the effect kicks in."
	item = /obj/item/healthanalyzer/rad_laser
	cost = 3


/datum/uplink_item/device_tools/suspiciousphone
	name = "Protocol CRAB-17 Phone"
	desc = "The Protocol CRAB-17 Phone, a phone borrowed from an unknown third party, it can be used to crash the space market, funneling the losses of the crew to your bank account.\
	The crew can move their funds to a new banking site though, unless they HODL, in which case they deserve it."
	item = /obj/item/suspiciousphone
	restricted = TRUE
	cost = 7
	limited_stock = 1

/datum/uplink_item/device_tools/binary
	name = "Binary Translator Key"
	desc = "A key that, when inserted into a radio headset, allows you to listen to and talk with silicon-based lifeforms, \
			such as AI units and cyborgs, over their private binary channel. Caution should \
			be taken while doing this, as unless they are allied with you, they are programmed to report such intrusions."
	item = /obj/item/encryptionkey/binary
	cost = 5
	surplus = 75
	restricted = TRUE

// Low progression cost

/datum/uplink_item/device_tools/emag
	name = "Cryptographic Sequencer"
	desc = "The cryptographic sequencer, electromagnetic card, or emag, is a small card that unlocks hidden functions \
			in electronic devices, subverts intended functions, and easily breaks security mechanisms. Cannot be used to open airlocks."
	progression_minimum = 20 MINUTES
	item = /obj/item/card/emag
	cost = 4

/datum/uplink_item/device_tools/stimpack
	name = "Stimpack"
	desc = "Stimpacks, the tool of many great heroes, make you nearly immune to stuns and knockdowns for about \
			5 minutes after injection."
	progression_minimum = 20 MINUTES
	item = /obj/item/reagent_containers/hypospray/medipen/stimulants
	cost = 5
	surplus = 90


// Medium progression cost

/datum/uplink_item/device_tools/hacked_module
	name = "Hacked AI Law Upload Module"
	desc = "When used with an upload console, this module allows you to upload priority laws to an artificial intelligence. \
			Be careful with wording, as artificial intelligences may look for loopholes to exploit."
	progression_minimum = 30 MINUTES
	item = /obj/item/ai_module/syndicate
	cost = 4

/datum/uplink_item/device_tools/hypnotic_flash
	name = "Hypnotic Flash"
	desc = "A modified flash able to hypnotize targets. If the target is not in a mentally vulnerable state, it will only confuse and pacify them temporarily."
	progression_minimum = 30 MINUTES
	item = /obj/item/assembly/flash/hypnotic
	cost = 7

/datum/uplink_item/device_tools/hypnotic_grenade
	name = "Hypnotic Grenade"
	desc = "A modified flashbang grenade able to hypnotize targets. The sound portion of the flashbang causes hallucinations, and will allow the flash to induce a hypnotic trance to viewers."
	progression_minimum = 30 MINUTES
	item = /obj/item/grenade/hypnotic
	cost = 12

/datum/uplink_item/device_tools/singularity_beacon
	name = "Power Beacon"
	desc = "When screwed to wiring attached to an electric grid and activated, this large device pulls any \
			active gravitational singularities or tesla balls towards it. This will not work when the engine is still \
			in containment. Because of its size, it cannot be carried. Ordering this \
			sends you a small beacon that will teleport the larger beacon to your location upon activation."
	progression_minimum = 30 MINUTES
	item = /obj/item/sbeacondrop
	cost = 10

/datum/uplink_item/device_tools/powersink
	name = "Power Sink"
	desc = "When screwed to wiring attached to a power grid and activated, this large device lights up and places excessive \
			load on the grid, causing a station-wide blackout. The sink is large and cannot be stored in most \
			traditional bags and boxes. Caution: Will explode if the powernet contains sufficient amounts of energy."
	progression_minimum = 30 MINUTES
	item = /obj/item/powersink
	cost = 11
