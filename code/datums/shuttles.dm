/datum/map_template/shuttle
	name = "Base Shuttle Template"
	var/prefix = "_maps/shuttles/"
	var/suffix
	var/port_id
	var/shuttle_id

	var/description
	var/admin_notes

/datum/map_template/shuttle/New()
	shuttle_id = "[port_id]_[suffix]"
	mappath = "[prefix][shuttle_id].dmm"
	. = ..()

/datum/map_template/shuttle/emergency
	port_id = "emergency"
	name = "Base Shuttle Template (Emergency)"

/datum/map_template/shuttle/cargo
	port_id = "cargo"
	name = "Base Shuttle Template (Cargo)"

/datum/map_template/shuttle/ferry
	port_id = "ferry"
	name = "Base Shuttle Template (Ferry)"

/datum/map_template/shuttle/whiteship
	port_id = "whiteship"

// Shuttles start here:

/datum/map_template/shuttle/emergency/airless
	suffix = "airless"
	name = "(Shuttle Under Construction)"
	description = "The documentation hasn't been finished yet for this \
		shuttle.\n\
		In case of emergency: Break glass."
	admin_notes = "No brig, no medical facilities, no air."

/datum/map_template/shuttle/emergency/asteroid
	suffix = "asteroid"
	name = "Asteroid emergency shuttle"

/datum/map_template/shuttle/emergency/bar
	suffix = "bar"
	name = "The Emergency Escape Bar"
	description = "Features include sentient bar staff (a Bardrone and a \
		Barmaid), bathroom, a quality lounge for the heads, and a \
		large gathering table."
	admin_notes = "Bardrone and Barmaid are GODMODE, will be automatically \
		sentienced by the fun balloon at 60 seconds before arrival. Has \
		medical facilities."

/datum/map_template/shuttle/emergency/birdboat
	suffix = "birdboat"
	name = "Birdboat emergency shuttle"

/datum/map_template/shuttle/emergency/box
	suffix = "box"
	name = "Box emergency shuttle"

/datum/map_template/shuttle/emergency/clown
	suffix = "clown"
	name = "Snappop(tm)!"
	description = "Hey kids and grownups! Are you bored of DULL and TEDIOUS \
		shuttle journeys after you're evacuating for probably BORING reasons. \
		Well then order the Snappop(tm) today! We've got fun activities for \
		everyone, an all access cockpit, and no boring security brig! Boo! \
		Play dress up with your friends! Collect all the bedsheets before \
		your neighbour does! Check if the AI is watching you with our patent \
		pending \"Peeping Tom AI Multitool Detector\" or PEEEEEETUR for \
		short. Have a fun ride!"
	admin_notes = "Brig is replaced by anchored greentext book surrounded by \
		lavaland chasms, stationside door has been removed to prevent \
		accidental dropping. No brig."

/datum/map_template/shuttle/emergency/cramped
	suffix = "cramped"
	name = "Secure Transport Vessel 5 (STV5)"
	description = "Well, looks like Centcomm only had this ship in the area, \
		they probably weren't expecting you to need evac for a while. \
		Probably best if you don't rifle around in whatever equipment they \
		were transporting. I hope you're friendly with your coworkers, \
		because there is very little space in this thing.\n\
		\n\
		Contains contraband armory guns, maintenance loot, and abandoned \
		crates!"
	admin_notes = "Due to origin as a solo piloted secure vessel, has an \
		active GPS onboard labeled STV5."

/datum/map_template/shuttle/emergency/meta
	suffix = "meta"
	name = "Meta emergency shuttle"

/datum/map_template/shuttle/emergency/mini
	suffix = "mini"
	name = "Mini emergency shuttle"

/datum/map_template/shuttle/emergency/narnar
	suffix = "narnar"
	name = "Shuttle 667"
	description = "Looks like this shuttle may have wandered into the \
		darkness between the stars on route to the station. Let's not think \
		too hard about where all the bodies came from."
	admin_notes = "Contains real cult ruins, mob eyeballs, and inactive \
		constructs. Cult mobs will automatically be sentienced by fun \
		balloon. Cloning pods in 'medbay' area are showcases and \
		nonfunctional."

/datum/map_template/shuttle/emergency/supermatter
	suffix = "supermatter"
	name = "Hyperfractal Gigashuttle"
	description = "\"I dunno, this seems kinda needlessly complicated.\"\n\
		\"This shuttle has very a very high safety record, according to \
		Centcom Officer Cadet Yins.\"\n\
		\"Are you sure?\"\n\
		\"Yes, it has a safety record of N-A-N, which is apparently \
		larger than 100%.\""
	admin_notes = "Supermatter that spawns on shuttle is special anchored \
		'hugbox' supermatter that cannot take damage and does not take in \
		or emit gas. Outside of admin intervention, it cannot explode. \
		It does, however, still dust anything on contact, emits high levels \
		of radiation, and induce hallucinations in anyone looking at it \
		without protective goggles. Emitters spawn powered on, expect \
		admin notices, they are harmless."

/datum/map_template/shuttle/emergency/imfedupwiththisworld
	suffix = "imfedupwiththisworld"
	name = "Oh, Hi Daniel"
	description = "How was space work today? \
		Oh, pretty good. We got a new space station and the company will make a lot of money. \
		What space station? \
		I cannot tell you; it's space confidential. \
		Aw, come space on. Why not? \
		No, I can't. Anyway, how is your space roleplay life?"

/datum/map_template/shuttle/emergency/goon
	suffix = "goon"
	name = "NES Port"
	description = "The Nanotrasen Emergency Shuttle Port(NES Port for short) \
	is a shuttle used at other less known nanotrasen facilities \
	and has a more open inside for larger crowds."

/datum/map_template/shuttle/emergency/wabbajack
	suffix = "wabbajack"
	name = "NT Lepton Violet"
	description = "The research team based on this vessel went missing one \
	day, and no amount of investigation could discover what happened to \
	them. The only occupants were a number of dead rodents, who appeared to \
	have clawed each other to death. Needless to say, no engineering team \
	wanted to go  near the thing, and it's only being used as an Emergency \
	Escape Shuttle because there is literally nothing else available."
	admin_notes = "If the crew can solve the puzzle, they will wake the \
	wabbajack statue. It will likely not end well. There's a reason it's \
	boarded up. Maybe they should have just left it alone."

/datum/map_template/shuttle/ferry/base
	suffix = "base"
	name = "transport ferry"
	description = "Standard issue Box/Metastation Centcom ferry."

/datum/map_template/shuttle/ferry/meat
	suffix = "meat"
	name = "\"meat\" ferry"
	description = "Ahoy! We got all kinds o' meat aft here. Meat from plant \
		people, people who be dark, not in a racist way, just they're dark \
		black. Oh and lizard meat too,mighty popular that is. Definitely \
		100% fresh, just ask this guy here. *person on meatspike moans* See? \
		Definitely high quality meat, nothin' wrong with it, nothin' added, \
		definitely no zombifyin' reagents!"
	admin_notes = "Meat currently contains no zombifying reagents, lizard on \
		meatspike must be spawned in."

/datum/map_template/shuttle/ferry/lighthouse
	suffix = "lighthouse"
	name = "The Lighthouse(?)"
	description = "*static*... part of a much larger vessel, possibly \
		military in origin. The weapon markings aren't anything we've seen \
		... static ... by almost never the same person twice, possible use \
		of unknown storage ...  static ... seeing ERT officers onboard, but \
		no missions are on file for ... static ... static ... annoying \
		jingle ... only at The LIGHTHOUSE! Fulfilling needs you didn't even \
		know you had. We've got EVERYTHING, and something else!"
	admin_notes = "Currently larger than ferry docking port on Box, will not \
		hit anything, but must be force docked. Trader and ERT bodyguards are \
		not included."

/datum/map_template/shuttle/whiteship/box
	suffix = "box"
	name = "NT Medical Ship"

/datum/map_template/shuttle/whiteship/meta
	suffix = "meta"
	name = "NT Recovery White-ship"

/datum/map_template/shuttle/cargo/box
	suffix = "box"
	name = "supply shuttle (Box)"

/datum/map_template/shuttle/cargo/birdboat
	suffix = "birdboat"
	name = "supply shuttle (Birdboat)"
