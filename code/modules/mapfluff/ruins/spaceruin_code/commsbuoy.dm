/obj/structure/fluff/commsbuoy_receiver
	name = "interstellar receiver"
	desc = "A dish-shaped component of the Comms Buoy used to detect and record interstellar signals."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcast receiver"

/obj/structure/fluff/commsbuoy_processor
	name = "comms buoy processor unit"
	desc = "This machine is used to process and unscramble interstellar transmissions, to then be relayed and broadcast."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"

/obj/structure/fluff/commsbuoy_broadcaster
	name = "interstellar broadcaster"
	desc = "A dish-shaped component of the  Comms Buoy used to broadcast processed interstellar signals."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster"

/obj/structure/fluff/sat_dish
	name = "satellite dish"
	desc = "I wonder if they get any sports channels out here."
	density = FALSE
	deconstructible = TRUE
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "sat_dish"

/obj/item/keycard/nt_commsbuoy
	name = "Nanotrasen comms buoy keycard"
	desc = "A keycard with the NT logo prominently displayed. The last user broke off the end; the card can still swipe, but this won't insert \
	into any chip readers now. On the back, mostly obscured by dried blood, the text \"SPINWARD\" is printed, followed by an illegible ID string."
	color = "#4c80b1"
	puzzle_id = "nt_commsbuoy"

/obj/machinery/door/puzzle/keycard/nt_commsbuoy
	name = "secure airlock"
	puzzle_id = "nt_commsbuoy"

/area/ruin/space/nt_commsbuoy
	name = "\improper Nanotrasen Comms Buoy"
	sound_environment = SOUND_AREA_SMALL_ENCLOSED
	has_gravity = FALSE
	ambientsounds = list(
		'sound/ambience/engineering/ambisin2.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/misc/signal.ogg',
		'sound/ambience/general/ambigen9.ogg',
		'sound/ambience/engineering/ambitech.ogg',
		'sound/ambience/engineering/ambitech2.ogg',
		'sound/ambience/engineering/ambitech3.ogg',
		'sound/ambience/misc/ambimystery.ogg',
		) //same ambience as tcommsat

/obj/item/paper/fluff/ruins/nt_commsbuoy
	color = COLOR_BLUE_GRAY

/obj/item/paper/fluff/ruins/nt_commsbuoy/table_of_contents
	name = "Table of Contents: NT-EBCB Model 7"
	desc = "The Table of Contents page, text mostly faded. Rest of handbook not included."
	default_raw_text = {"
	<center><h3>Nanotrasen Extraorbital Bluespace Communications Buoy Operations Manual</h3>
	<h5><i>PROPERTY OF NANOTRASEN. DO NOT DISTRIBUTE.</i></h5></center>
	<hr>
	<h4>Table of Contents</h4>
	Legal Disclaimers: p1-p6 <br>
	How to Sign: Nondisclosure Agreement: p7 <br>
	Main and Secondary Dish: p8-p10 <br>
	Standard Operation Codes: p11 <br>
	Local-Network Array: p12-p13 <br>
	Interstellar Relay: p14-p27 <br>
	Maintinence: p28-p46 <br>
	Common Error Codes: p47 <br>
	Contacting NT Tech Support: p48-54 <br>
	<hr>
	<i>(The page is torn straight along the end of the Table of Contents... wish they'd left the actual Contents.)</i>
	"}

/obj/item/paper/fluff/ruins/nt_commsbuoy/torn_page
	name = "Page 33: NT-EBCB Model 7"
	desc = "Page 33, torn out and annotated with lots of underlining."
	default_raw_text = {"
	<center><h5><i>PROPERTY OF NANOTRASEN. DO NOT DISTRIBUTE.</i></h5></center>
	<hr>
	... is listing any of the mentioned Operation or Error codes. If the shown error is \
	not listed in the manual, please refer to pages 48/54 to contact a Nanotrasen Techician for direct assistance. <br>
	<center><h4>Realigning the Satellite Dish</hr></center>
	Now that you have identified the Error code as an alignment issue, repairs will follow a simple step-by-step list. Be sure to follow the \
	list precisely, as additional damage may occur while the dish is misaligned. <br>
	1. Assess the outside of the Comms Buoy for any damage or indication of impact to the dish. If any is found, refer to the Replacement Parts subsection\
	on page 43. <br>
	2. Before entering the Comms Buoy, collect the Nanotrasen Comms Buoy keycard provided in the front of this manual. This keycard is vital to \
	the repair process, operational efficiency of the Buoy, and in disabling the automated defensive system. <br>
	3. Display this card prominently on your persons. This can be done with an official Nanotrasen neck lanyard or Nanotrasen clip-on retractible laynard, \
	worn on your collar, attached to a breast pocket, or on your waist. <br>
	4. Enter the Comms Buoy from the designated airlock. There is no system aboard to recycle air, so keep internals and a suit handy in case \
	the Comms Buoy has depressurized. <br>
	5. Immediately upon entering the room, be sure to disable the Automated Defense System (refer to page 29). \
	<b>Failiure to follow this step may risk injury or even death.</b> <br>
	6. Proceed to the terminal corresponding to the misaligned disk - the Primary Dish controller (pages 8/9) can be located in the room past the Local-Network Array (pages 12/13), \
	while the one closest to the airlock will control the Secondary Dish (page 10). <br>
	7. Insert the Nanotrasen Comms Buoy keycard into the slot along the bottom right of the terminal (refer to diagram RD-2).
	<hr>
	(The back of the page is covered in blood. A shame, now you can't see the diagram...)
	"}

/obj/item/paper/fluff/ruins/nt_commsbuoy/inspection
	name = "Spinward-NT-EBCB Inspection Report"
	desc = "A few notes from the pre-activation inspection. Probably shouldn't still be here post-activation."
	default_raw_text = {"
	<center><h3>"SS13-Relay" Spinward NT-EBCB Pre-Activation Inspection</h3></center>
	<hr>
	Alright, just a few notes for consideration before we launch this new model. Would really appreciate review and action on the listed items. <br>
	- Open space on the exterior chassis. Nanotrasen insignia and paint? <u>Could sell advertising space?</u> <br>
	- The Primary Dish has proven to be sufficient for even severe network loads. Offloading half of its processing to the Secondary just creates \
	a fault risk; isn't this meant to be a backup? Why are we using it at all times? <br>
	- Interstellar Relay has some outdated encryption. This sat shouldn't have even <b>left</b> CC until this was updated. <br>
	- <b>Please reconsider deployment location.</b> SS13's local space is not secure enough for untested comms equipment. Combine with above \
	note about encryption, this is a <b>serious security risk.</b> <br>
	- Turrets are functioning as expected, read the ID correctly as long as the full barcode is unobscured. However, please review: location of \
	turrets. Critical consoles are in the firing line and NOT laser-resistant. No, a backup recorder in the Main Dish is not sufficient. <br>
	- A note of praise: including a manual with each satellite is very good. Better recommendation might be a console, or something similar \
	which people can't just tear off the corkboard. <br>
	- I fixed the breaker while I was aboard; it was routing 2kW into lighting and blew them all out. Simple wiring fault. Fix before launching \
	other Model-7s to prevent power issues. <br>
	- While it's not a habitable satellite, a fax machine might have been handy. Now I have to make sure not to lose these notes during the return \
	trip.
	<hr>
	<center><h5><i>PROPERTY OF NANOTRASEN. DO NOT DISTRIBUTE.</i></h5></center>
	"}

/obj/machinery/computer/terminal/nt_commsbuoy
	name = "satellite dish operations terminal"
	icon_screen = "comm"
	tguitheme = "ntos"
	upperinfo = "SATELLITE DISH OPERATIONS READOUT"
	content = list(
		"<b>10/07/2563</b> - Inbound Packet Stability - FAIL <br>\
		<i>Please realign dish!</i><hr>",
		"<b>17/07/2563</b> - Inbound Packet Stability - FAIL <br>\
		<i>Please realign dish!</i><hr>",
		"<b>19/07/2563</b> - Outbound Packet Stability - SUCCESS <hr>",
		"<b>24/07/2563</b> - Inbound Packet Stability - FAIL <br>\
		<i>Please realign dish!</i><hr>",
		"<b>02/08/2563</b> - Inbound Packet Stability - FAIL <br>\
		<i>Please realign dish!</i><hr>",
		"<b>09/08/2563</b> - Inbound Packet Stability - FAIL <br>\
		<i>Please realign dish!</i><hr>",
		"<b>13/08/2563</b> - Secondary Dish reports manual alignment changes. <br>\
		<i>If this was not intentional, please check the exterior for signs of impact damage!</i><hr>",
		"<b>13/08/2563</b> - Outbound Packet Stability - SUCCESS <hr>",
		"<b>14/08/2563</b> - Inbound Packet Stability - SUCCESS <br>\
		<i>Forwarding to Processor for signal restoration.</i><br>\
		... <i>Signal restored, Inbound relayed to Outbound</i><br>\
		... Outbound Packet Stability - SUCCESS <hr>",
		"<b>15/08/2563</b> - Outbound Packet Stability - SUCCESS <hr>",
	)

/obj/machinery/computer/terminal/nt_commsbuoy/blackbox
	name = "blackbox transcription terminal"
	upperinfo = "BLACKBOX TRANSCRIPT - 13/08/2563"
	content = list(
		"<i>Notice: this transcript was generated by Nanotrasen speech-to-text. By reading this transcript you are hereby agreeing to the speech-to-text terms \
		of service, and agree that any fault or inaccuracies in transcriptions legally falls entirely on the speaker.</i><hr>",
		"11:07 - <b>NTSS WAKAHIRU</b><br> \
		Yeah, we're close enough. Passing within about a thousand meters of that Buoy that's been having trouble. We can re-route to check on it, I've got \
		an extraorbital engineer aboard. <i>Hell, guy's already looking for the right handbook.</i><br>",
		"11:08 - <b>NANOTRASEN TRAFFIC CONTROL</b><br> \
		Approved, Wakahiru. Redirect per the updated charts coming in on your CDTI, keep your speed below sub-light until further notice. ETA will be 27 minutes. \
		Be sure to follow all Company regulations during repairs, these systems are extremely sensitive and you will be held liable for any new damages.",
		"11:10 - <b>NTSS WAKAHIRU</b><br> \
		Adjusting course now, and already printing out the waivers. Clearing Broadband.",
		"<i>11:11 -  <b>NTSS WAKAHIRU - Local</b></i><br> \
		Operations to the Bridge, repeat, Operations to the Bridge.<hr>",
		"11:34 - <b>(TRANSPONDER INACTIVE)</b><br> \
		Control, I've got a, uh- fish or something chewing through my NAV array, can you guys dispatch a team or something? Bring a, like, big net?",
		"11:37 - <b>NANOTRASEN TRAFFIC CONTROL</b><br> \
		Negative. Your Transponder is inactive - stop all operations, a Security patrol is being dispatched to your location.",
		"11:37 - <b>(TRANSPONDER INACTIVE)</b><br> \
		<i>Y'know what, that's close enough.</i> Make sure that they bring some repair tools with them. <i>And a harpoon.</i><hr>",
		"<i>11:40 - <b>NTSS WAKAHIRU - Local</b></i><br> \
		Allllllright, guys, we're at the reported Buoy. NT's Traffic-Con said they've been getting messy data through the relay, too messy to forward. \
		Probably just a misaligned dish. Operations will be dispatching the Away team soon, but otherwise just keep doing whatever it is you're doing.",
		"<i>11:47 - <b>Unidentified - Local</b></i><br> \
		This is Away to Wakahiru, how read.",
		"<i>11:47 - <b>NTSS WAKAHIRU - Local</b></i><br> \
		Loud and clear Away. What's the hold-up?",
		"<i>11:48 - <b>Unidentified - Local</b></i><br> \
		Yeah, uh, this access card doesn't seem to be working on the dish controller. Kept the turrets tame and opened the front door, but \
		the console's not responding to it. Lost that manual page I brought with me too... <i>Huh?</i> One second- <i>Oh, insert it entirely? I don't think- Dude- dude, I know how to put a card into a reader, just let me-</i>",
		"11:50 - <b>NT-EBCB-7 ARRAY</b><br> \
		ALERT. LIFE FORMS DETECTED WITHOUT VALID IDENTIFICATION. INITIATING DEFENSIVE PROTOCOL.",
		"<i>11:50 - <b>Unidentified - Local</b></i><br> \
		SHIIIIIT!! GET THE CARD BACK OUT OF THE CONSOLE! GET IT OUT! G-",
		"11:51 - <b>NT-EBCB-7 ARRAY</b><br> \
		ALL LIFE FORMS ELIMINATED. HAVE A SECURE DAY!<hr>",
		"12:07 - <b>NTSS WAKAHIRU</b><br> \
		NT-TC, this is the NTSS Wakahiru. You're, uh... going to need to dispatch a cleanup crew to that satellite. Sending you our Operations report now.",
	)

/obj/machinery/computer/terminal/nt_commsbuoy/relay
	name = "long-range interstellar relay operations terminal"
	upperinfo = "LONG-RANGE INTERSTELLAR RELAY OPERATIONS READOUT"
	content = list(
		"<b>19/07/2563</b> - Outbound Direct - <br>\
		<i>From: totally_not_a_burner@kosmokomm.net</i> <br>\
		<i>To: john_doe_a_deer_a_female_deer@kosmokomm.net</i> <br>\
		<br>\
		im telling you! they dont monitor this relay. ive had a bug on the interstellar relay since it was launched. outdated encryption, \
		its an easy tap. just be patient.<hr>\
		<center><b><i>PACKET FLAGGED AS SUSPICIOUS.</b> LOGGING FOR REVIEW.</i></center><hr>",

		"<b>13/08/2563</b> - Outbound Direct - <br>\
		<i>From: NT_S13TC_OFFICIAL@NTFIDspinward.nt</i> <br>\
		<i>To: wilson_peters@NTFIDspinward.nt</i> <br>\
		<br>\
		Hello, <br>\
		Your ticket has been marked as Resolved with the following comment: <br>\
		\"This is Spinward Sector 13 NT Traffic Control, reaching out to inform you that your ticket has been resolved. The relay should now \
		be operating as expected. Please re-attempt sending that message again. If any other issue arises, open a new ticket.\" <br>\
		Thank you for your patience and continued support. <br>\
		<center><h5>The Spinward Project - brought to you by Nanotrasen Futures and Innovation Division, in partnership with Nanotrasen \
		Heavy Industry.</h5></center><hr>",

		"<b>14/08/2563</b> - Inbound to Foward - <br>\
		<i>From: wilson_peters@NTFIDspinward.nt</i> <br>\
		<i>Relay Target: PORT_ELLIS</i> <br>\
		<br>\
		Hey. I miss you. Hope we can holo-call again soon. <br>\
		Work's been busy. Wish you could be here for it, but I know you were adamant on getting your citizenship. I hope Gateway's been nice to you. <br>\
		I was working on that project folder you left me, the plasma stuff. Really see why you asked to change divisions... <br>\
		<br>\
		Regardless of the heavy topic of the research, I've made some astounding breakthroughs. A majority of this is still your notes just progressing, \
		long-term ingestion of plasma - specifically Pudicitite - in humanoid species. I really had hoped these projections weren't so accurate. \
		Guess it just shows your dazzling intellect... as dark as this is. <br>\
		<br>\
		That doomed assistant you had on observation finally expired. The constant medium-level exposure, even treated with a myriad of medications, \
		left the Amygdala extremely malformed like we were seeing prior. Additionally, it entirely and irrepairably destroyed every neural pathway in \
		the Hypothalamus, leaving the subject on a direct path to literally burning out. <br>\
		The damage to their bodily temperature regulation wasn't the focus, nor did I get much opportunity to make it one. Security had to kill them \
		pre-emptively; their Amygdala is engorged and stained with purple and white streaks (almost as vibrant as your scales). Whatever this damage \
		truly is seems to have contributed to overstimulation and amplified emotional responses to the testing. <br>\
		<br>\
		It's... a perfect storm. The loss of control of emotional responses in tandem with the exaggurated environmental stimuli. I've already pushed \
		a few of the results up as high as I can and advised we push towards improving our plasma filtration, especially in masks. Specifically \
		the Mining gas masks, as your papers mentioned - the elevated gas exposure makes them a high risk group. <br>\
		My peers over here are already adjusting their testing to boost this to Central's attention so that other stations might \
		contribute to improving our protections from this. <br>\
		<br>\
		I know you told me to stop messaging you, especially about this - but I thought you deserved to know, of all people. You were right. You were \
		always right. Please... respond. Even just to tell me if *I* did something right. <br>\
		<center><h5>The Spinward Project - brought to you by Nanotrasen Futures and Innovation Division, in partnership with Nanotrasen Heavy Industry.</h5></center><hr>",

		"<b>15/08/2563</b> - Outbound Direct - <br>\
		<i>From: totally_not_a_burner@kosmokomm.net</i> <br>\
		<i>To: john_doe_a_deer_a_female_deer@kosmokomm.net</i> <br>\
		<br>\
		IM THE BEST HACKER IN THE GALAXY. youre paying me TRIPLE for that, holy CRAP the syndicate are going to pay us so much. actually you owe me \
		at least half the profits. no no over half i did all the work. <br>\
		(Attached data file: WEGOTIT.syndzip)<hr>\
		<center><i><b>PACKET FLAGGED AS SUSPICIOUS.</b> BEGINNING TRACE.</i></center> \
		<h5>ORIGIN TRACED. NT-DAP DISPATCHED. <br>\
		DESTINATION TRACED. NT-DAP DISPATCHED. <br>\
		DATA FILE SCANNED AND FORWARDED TO NT-DAP. <br>\
		<br>\
		FILE ORIGIN TRACED TO NT STATION. LOCKDOWN INITIATED. <br>\
		SECURITY ADVISORY RAISED TO: RED STAR. <br>\
		NT-DAP DISPATCHED. TARGET: wilson_peters.</h5><hr>",
	)
