/*********************MANUALS (BOOKS)***********************/

//Oh god what the fuck I am not good at computer
/obj/item/book/manual
	icon = 'icons/obj/service/library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = TRUE   // FALSE - Normal book, TRUE - Should not be treated as normal book, unable to be copied, unable to be modified

/obj/item/book/manual/hydroponics_pod_people
	name = "The Human Harvest: From Seed to Market"
	icon_state ="bookHydroponicsPodPeople"
	starting_author = "Farmer John" // Whoever wrote the paper or book, can be changed by pen or PC. It is not automatically assigned.
	starting_title = "The Human Harvest: From Seed to Market"
	//book contents below
	starting_content = "\
				<h3>Growing Humans</h3>\
				\
				Why would you want to grow humans? Well, I'm expecting most readers to be in the slave trade, but a few might actually\
				want to revive fallen comrades. Growing pod people is actually quite simple:\
				<p>\
				<ol>\
				<li>Find a dead person who is in need of revival. </li>\
				<li>Take a blood sample with a syringe (samples of their blood taken BEFORE they died will also work). </li>\
				<li>Inject a packet of replica pod seeds (which can be acquired by either mutating cabbages into replica pods (and then harvesting said replica pods) or by purchasing them from certain corporate entities) with the blood sample. </li>\
				<li>It is imperative to understand that injecting the replica pod plant with blood AFTER it has been planted WILL NOT WORK; you have to inject the SEED PACKET, NOT the TRAY. </li>\
				<li>Plant the seeds. </li>\
				<li>Tend to the replica pod's water and nutrition levels until it is time to harvest the podcloned humanoid. </li>\
				<li>Note that if the corpse's mind (or spirit, or soul, or whatever the hell your local chaplain calls it) is already in a new body or has left this plane of existence entirely, you will just receive seed packets upon harvesting the replica pod plant, not a podperson. </li>\
				</ol>\
				It really is that easy! Good luck!\
				\
				"

/obj/item/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	starting_author = "Weyland-Yutani Corp"
	starting_title = "APLU \"Ripley\" Construction and Operation Manual"
	starting_content = "\
				<center>\
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>\
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>\
				</center>\
				<h2>Specifications:</h2>\
				<ul>\
				<li><b>Class:</b> Autonomous Power Loader</li>\
				<li><b>Scope:</b> Logistics and Construction</li>\
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>\
				<li><b>Height:</b> 2.5m</li>\
				<li><b>Width:</b> 1.8m</li>\
				<li><b>Top speed:</b> 5km/hour</li>\
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>\
				<li><b>Airtank Volume:</b> 500liters</li>\
				<li><b>Devices:</b>\
					<ul>\
					<li>Hydraulic Clamp</li>\
					<li>High-speed Drill</li>\
					</ul>\
				</li>\
				<li><b>Propulsion Device:</b> Power cell powered electro-hydraulic system.</li>\
				<li><b>Power cell capacity:</b> Varies.</li>\
				</ul>\
				\
				<h2>Construction:</h2>\
				<ol>\
				<li>Connect all exosuit parts to the chassis frame</li>\
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>\
				<li>Adjust the servohydraulics with a screwdriver</li>\
				<li>Wire the chassis. (Cable is not included.)</li>\
				<li>Use the wirecutters to remove the excess cable if needed.</li>\
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>\
				<li>Secure the mainboard with a screwdriver.</li>\
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>\
				<li>Secure the peripherals control module with a screwdriver</li>\
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 iron sheets.)</li>\
				<li>Secure the internal armor plating with a wrench</li>\
				<li>Weld the internal armor plating to the chassis</li>\
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced iron sheets.)</li>\
				<li>Secure the external reinforced armor plating with a wrench</li>\
				<li>Weld the external reinforced armor plating to the chassis</li>\
				\
				<h2>Operation</h2>\
				Please consult the Nanotrasen compendium \"Robotics for Dummies\".\
			"

/obj/item/book/manual/chef_recipes
	name = "Chef Recipes"
	icon_state = "cooked_book"
	starting_author = "Lord Frenrir Cageth"
	starting_title = "Chef Recipes"
	starting_content = "\
				\
				<h1>Food for Dummies</h1>\
				Here is a guide on basic food recipes and also how to not poison your customers accidentally.\
				\
				\
				<h2>Basic ingredients preparation:</h2>\
				\
				<b>Dough:</b> 10u water + 15u flour for simple dough.<br>\
				6u egg yolk + 12 egg white + 15u flour + 5u sugar for cake batter.<br>\
				Doughs can be transformed by using a knife and rolling pin.<br>\
				All doughs can be baked.<br>\
				<b>Bowl:</b> Add recipe ingredients and liquid to make soups.<br>\
				<b>Meat:</b> Grill it, process it, slice it into grillable cutlets with your knife, or use it raw.<br>\
				<b>Cheese:</b> Add 5u universal enzyme (catalyst) to milk and soy milk to prepare cheese (sliceable) and tofu.<br>\
				<b>Rice:</b> Mix 10u rice with 10u water then microwave it.\
				\
				<h2>Custom food:</h2>\
				Add ingredients to a base item to prepare a custom meal.<br>\
				The bases are:<br>\
				- bun (burger)<br>\
				- breadslices(sandwich)<br>\
				- plain bread<br>\
				- vanilla cake<br>\
				- empty bowl (salad)<br>\
				- bowl with liquid (soup)<br>\
				- boiled spaghetti<br>\
				- pizza bread<br>\
				- iron rod (kebab)<br>\
				- plain pie<br>\
				- seaweed sheet(sushi)<br>\
				\
				<h2>Cooking menu:</h2>\
				Open the crafting menu and click the cooking tab to see the list of cookable food.\
				\
				<h2>Microwave:</h2>\
				Use it to cook or boil food ingredients (egg, spaghetti, donkpocket, etc...).\
				It can cook multiple items at once.\
				\
				<h2>Processor:</h2>\
				Use it to process certain ingredients (meat into meatballs, doughslice into spaghetti, etc...)\
				\
				<h2>Gibber:</h2>\
				Stuff an animal in it to grind it into meat.\
				\
				<h2>Meat spike:</h2>\
				Stick an animal on it then begin collecting its meat.\
				\
				\
				<h2>Example recipes:</h2>\
				<b>Vanilla Cake</b>: Bake cake base.<br>\
				<b>Burger:</b> 1 bun + 1 patty<br>\
				<b>Bread:</b> Bake dough.<br>\
				<b>Waffles:</b> 2 pastry base<br>\
				<b>Popcorn:</b> Microwave corn.<br>\
				<b>Meat Steak:</b> Grill meat.<br>\
				<b>Meat Pie:</b> 1 plain pie + 1u black pepper + 1u salt + 1 meat steak<br>\
				<b>Boiled Spagetti:</b> Microwave spaghetti.<br>\
				<b>Donuts:</b> 1u sugar + 1 pastry base<br>\
				<b>Fries:</b> Cut and process potato.\
				\
				<h2>Sharing your food:</h2>\
				You can put your meals on your kitchen counter or load them in the snack vending machines.\
				"

/obj/item/book/manual/nuclear
	name = "Fission Mailed: Nuclear Sabotage 101"
	icon_state ="bookNuclear"
	starting_author = "Syndicate"
	starting_title = "Fission Mailed: Nuclear Sabotage 101"
	starting_content = "\
			Nuclear Explosives 101:<br>\
			Hello and thank you for choosing the Syndicate for your nuclear information needs.<br>\
			Today's crash course will deal with the operation of a Fusion Class Nanotrasen made Nuclear Device.<br>\
			First and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.<br>\
			Pressing any button on the compacted bomb will cause it to extend and bolt itself into place.<br>\
			If this is done to unbolt it one must completely log in which at this time may not be possible.<br>\
			To make the nuclear device functional:<br>\
			<li>Place the nuclear device in the designated detonation zone.</li>\
			<li>Extend and anchor the nuclear device from its interface.</li>\
			<li>Insert the nuclear authorisation disk into slot.</li>\
			<li>Type numeric authorisation code into the keypad. This should have been provided. Note: If you make a mistake press R to reset the device.\
			<li>Press the E button to log onto the device.</li>\
			You now have activated the device. To deactivate the buttons at anytime for example when you've already prepped the bomb for detonation remove the auth disk OR press the R on the keypad.<br>\
			Now the bomb CAN ONLY be detonated using the timer. Manual detonation is not an option.<br>\
			Note: Nanotrasen is a pain in the neck.<br>\
			Toggle off the SAFETY.<br>\
			Note: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step.<br>\
			So use the - - and + + to set a det time between 5 seconds and 10 minutes.<br>\
			Then press the timer toggle button to start the countdown.<br>\
			Now remove the auth. disk so that the buttons deactivate.<br>\
			Note: THE BOMB IS STILL SET AND WILL DETONATE<br>\
			Now before you remove the disk if you need to move the bomb you can:<br>\
			Toggle off the anchor, move it, and re-anchor.<br><br>\
			Good luck. Remember the order:<br>\
			<b>Disk, Code, Safety, Timer, Disk, RUN!</b><br>\
			Intelligence Analysts believe that normal Nanotrasen procedure is for the Captain to secure the nuclear authorisation disk.<br>\
			Good luck!\
			"
