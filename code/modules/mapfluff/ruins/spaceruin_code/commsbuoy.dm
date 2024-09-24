/obj/structure/fluff/commsbuoy_reciever
	name = "interstellar reciever"
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
	name = "Nanotrasen comm buoy keycard"
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
		'sound/ambience/ambisin2.ogg',
		'sound/ambience/signal.ogg',
		'sound/ambience/signal.ogg',
		'sound/ambience/ambigen9.ogg',
		'sound/ambience/ambitech.ogg',
		'sound/ambience/ambitech2.ogg',
		'sound/ambience/ambitech3.ogg',
		'sound/ambience/ambimystery.ogg',) //same ambience as tcommsat

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
	2. Before entering the Comms Buoy, collect the Nanotrasen Comm Buoy keycard provided in the front of this manual. This keycard is vital to \
	the repair process, operational efficiency of the Buoy, and in disabling the automated defensive system. <br>
	3. Display this card prominently on your persons. This can be done with an official Nanotrasen neck lanyard or Nanotrasen clip-on retractible laynard, \
	worn on your collar, attached to a breast pocket, or on your waist. <br>
	4. Enter the Comms Buoy from the designated airlock. There is no system aboard to recycle air, so keep internals and a suit handy in case \
	the Comms Buoy has depressurized. <br>
	5. Immediately upon entering the room, be sure to disable the Automated Defense System (refer to page 29). \
	<b>Failiure to follow this step may risk injury or even death.</b> <br>
	6. Proceed to the terminal corresponding to the misaligned disk - the Primary Dish controller (pages 8/9) can be located in the room past the Local-Network Array (pages 12/13), \
	while the one closest to the airlock will control the Secondary Dish (page 10). <br>
	7. Insert the Nanotrasen Comm Buoy keycard into the slot along the bottom right of the terminal (refer to diagram RD-2).
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

/obj/machinery/computer/terminal/nt_commsbuoy/blackbox
	name = "blackbox transcription terminal"
	upperinfo = "BLACKBOX TRANSCRIPT - 13/08/2563"

/obj/machinery/computer/terminal/nt_commsbuoy/relay
	name = "long-range interstellar relay operations terminal"
	upperinfo = "LONG-RANGE INTERSTELLAR RELAY OPERATIONS READOUT"
