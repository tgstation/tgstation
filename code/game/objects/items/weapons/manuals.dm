/*********************MANUALS (BOOKS)***********************/

/obj/item/weapon/book/manual
	icon = 'library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified


/obj/item/weapon/book/manual/engineering_construction
	name = "Station Repairs and Construction"
	icon_state ="bookEngineering"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://nanotrasen.com/wiki/index.php?title=Guide_to_construction&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/weapon/book/manual/engineering_particle_accelerator
	name = "Particle Accelerator User's Guide"
	icon_state ="bookParticleAccelerator"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

//big pile of shit below.

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h3>Experienced user's guide</h3>

				<h4>Setting up</h4>

				<ol>
					<li><b>Wrench</b> all pieces to the floor</li>
					<li>Add <b>wires</b> to all the pieces</li>
					<li>Close all the panels with your <b>screwdriver</b></li>
				</ol>

				<h4>Use</h4>

				<ol>
					<li>Open the control panel</li>
					<li>Set the speed to 2</li>
					<li>Start firing at the singularity generator</li>
					<li><font color='red'><b>When the singularity reaches a large enough size so it starts moving on it's own set the speed down to 0, but don't shut it off</b></font></li>
					<li>Remember to wear a radiation suit when working with this machine... we did tell you that at the start, right?</li>
				</ol>

				</body>
				</html>"}


/obj/item/weapon/book/manual/engineering_hacking
	name = "Hacking"
	icon_state ="bookHacking"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

//big pile of shit below.

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://nanotrasen.com/wiki/index.php?title=Hacking&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}

/obj/item/weapon/book/manual/engineering_singularity_safety
	name = "Singularity Safety in Special Circumstances"
	icon_state ="bookEngineeringSingularitySafety"
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

//big pile of shit below.

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Singularity Safety in Special Circumstances</h3>

				<h4>Power outage</h4>

				A power problem has made the entire station loose power? Could be station-wide wiring problems or syndicate power sinks. In any case follow these steps:
				<p>
				<b>Step one:</b> <b><font color='red'>PANIC!</font></b><br>
				<b>Step two:</b> Get your ass over to engineering! <b>QUICKLY!!!</b><br>
				<b>Step three:</b> Get to the <b>Area Power Controller</b> which controls the power to the emitters.<br>
				<b>Step four:</b> Swipe it with your <b>ID card</b> - if it doesn't unlock, continue with step 15.<br>
				<b>Step five:</b> Open the console and disengage the cover lock.<br>
				<b>Step six:</b> Pry open the APC with a <b>Crowbar.</b><br>
				<b>Step seven:</b> Take out the empty <b>power cell.</b><br>
				<b>Step eight:</b> Put in the new, <b>full power cell</b> - if you don't have one, continue with step 15.<br>
				<b>Step nine:</b> Quickly put on a <b>Radiation suit.</b><br>
				<b>Step ten:</b> Check if the <b>singularity field generators</b> withstood the down-time - if they didn't, continue with step 15.<br>
				<b>Step eleven:</b> Since disaster was averted you now have to ensure it doesn't repeat. If it was a powersink which caused it and if the engineering apc is wired to the same powernet, which the powersink is on, you have to remove the piece of wire which links the apc to the powernet. If it wasn't a powersink which caused it, then skip to step 14.<br>
				<b>Step twelve:</b> Grab your crowbar and pry away the tile closest to the APC.<br>
				<b>Step thirteen:</b> Use the wirecutters to cut the wire which is conecting the grid to the terminal. <br>
				<b>Step fourteen:</b> Go to the bar and tell the guys how you saved them all. Stop reading this guide here.<br>
				<b>Step fifteen:</b> <b>GET THE FUCK OUT OF THERE!!!</b><br>
				</p>

				<h4>Shields get damaged</h4>

				Step one: <b>GET THE FUCK OUT OF THERE!!! FORGET THE WOMEN AND CHILDREN, SAVE YOURSELF!!!</b><br>
				</body>
				</html>
				"}

/obj/item/weapon/book/manual/hydroponics_pod_people
	name = "The Human Harvest - From seed to market"
	icon_state ="bookHydroponicsPodPeople"
	author = "Farmer John"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<h3>Growing Humans</h3>

				Why would you want to grow humans? Well I'm expecting most readers to be in the slave trade, but a few might actually
				want to revive fallen comrades. Growing pod people is easy, but prone to disaster.
				<p>
				<ol>
				<li>Find a dead person who is in need of cloning. </li>
				<li>Take a blood sample with a syringe. </li>
				<li>Inject a seed pack with the blood sample. </li>
				<li>Plant the seeds. </li>
				<li>Tend to the plants water and nutrition levels until it is time to harvest the cloned human.</li>
				</ol>
				<p>
				It really is that easy! Good luck!

				</body>
				</html>
				"}

/obj/item/weapon/book/manual/medical_cloning
	name = "Cloning techniques of the 26th century"
	icon_state ="bookCloning"
	author = "Medical Journal, volume 3"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

//big pile of shit below.

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<H3>How to Clone People</H3>
				So there’s 50 dead people lying on the floor, chairs are spinning like no tomorrow and you haven’t the foggiest idea of what to do? Not to worry! This guide is intended to teach you how to clone people and how to do it right, in a simple step-by-step process! If at any point of the guide you have a mental meltdown, genetics probably isn’t for you and you should get a job-change as soon as possible before you’re sued for malpractice.

				<ol>
					<li><a href='#1'>Acquire body</a></li>
					<li><a href='#2'>Strip body</a></li>
					<li><a href='#3'>Put body in cloning machine</a></li>
					<li><a href='#4'>Scan body</a></li>
					<li><a href='#5'>Clone body</a></li>
					<li><a href='#6'>Get clean Structurel Enzymes for the body</a></li>
					<li><a href='#7'>Put body in morgue</a></li>
					<li><a href='#8'>Await cloned body</a></li>
					<li><a href='#9'>Use the clean SW injector</a></li>
					<li><a href='#10'>Give person clothes back</a></li>
					<li><a href='#11'>Send person on their way</a></li>
				</ol>

				<a name='1'><H4>Step 1: Acquire body</H4>
				This is pretty much vital for the process because without a body, you cannot clone it. Usually, bodies will be brought to you, so you do not need to worry so much about this step. If you already have a body, great! Move on to the next step.

				<a name='2'><H4>Step 2: Strip body</H4>
				The cloning machine does not like abiotic items. What this means is you can’t clone anyone if they’re wearing clothes, so take all of it off. If it’s just one person, it’s courteous to put their possessions in the closet. If you have about seven people awaiting cloning, just leave the piles where they are, but don’t mix them around and for God’s sake don’t let the Clown in to steal them.

				<a name='3'><H4>Step 3: Put body in cloning machine</H4>
				Grab the body and then put it inside the DNA modifier. If you cannot do this, then you messed up at Step 2. Go back and check you took EVERYTHING off - a commonly missed item is their headset.

				<a name='4'><H4>Step 4: Scan body</H4>
				Go onto the computer and scan the body by pressing ‘Scan - <Subject Name Here>’. If you’re successful, they will be added to the records (note that this can be done at any time, even with living people, so that they can be cloned without a body in the event that they are lying dead on port solars and didn‘t turn on their suit sensors)! If not, and it says “Error: Mental interface failure.”, then they have left their bodily confines and are one with the spirits. If this happens, just shout at them to get back in their body, click ‘Refresh‘ and try scanning them again. If there’s no success, threaten them with gibbing. Still no success? Skip over to Step 7 and don‘t continue after it, as you have an unresponsive body and it cannot be cloned. If you got “Error: Unable to locate valid genetic data.“, you are trying to clone a monkey - start over.

				<a name='5'><H4>Step 5: Clone body</H4>
				Now that the body has a record, click ’View Records’, click the subject’s name, and then click ‘Clone’ to start the cloning process. Congratulations! You’re halfway there. Remember not to ‘Eject’ the cloning pod as this will kill the developing clone and you’ll have to start the process again.

				<a name='6'><H4>Step 6: Get clean SEs for body</H4>
				Cloning is a finicky and unreliable process. Whilst it will most certainly bring someone back from the dead, they can have any number of nasty disabilities given to them during the cloning process! For this reason, you need to prepare a clean, defect-free Structural Enzyme (SE) injection for when they’re done. If you’re a competent Geneticist, you will already have one ready on your working computer. If, for any reason, you do not, then eject the body from the DNA modifier (NOT THE CLONING POD) and take it next door to the Genetics research room. Put the body in one of those DNA modifiers and then go onto the console. Go into View/Edit/Transfer Buffer, find an open slot and click “SE“ to save it. Then click ‘Injector’ to get the SEs in syringe form. Put this in your pocket or something for when the body is done.

				<a name='7'><H4>Step 7: Put body in morgue</H4>
				Now that the cloning process has been initiated and you have some clean Structural Enzymes, you no longer need the body! Drag it to the morgue and tell the Chef over the radio that they have some fresh meat waiting for them in there. To put a body in a morgue bed, simply open the tray, grab the body, put it on the open tray, then close the tray again. Use one of the nearby pens to label the bed “CHEF MEAT” in order to avoid confusion.

				<a name='8'><H4>Step 8: Await cloned body</H4>
				Now go back to the lab and wait for your patient to be cloned. It won’t be long now, I promise.

				<a name='9'><H4>Step 9: Use the clean SE injector on person</H4>
				Has your body been cloned yet? Great! As soon as the guy pops out, grab your injector and jab it in them. Once you’ve injected them, they now have clean Structural Enzymes and their defects, if any, will disappear in a short while.

				<a name='10'><H4>Step 10: Give person clothes back</H4>
				Obviously the person will be naked after they have been cloned. Provided you weren’t an irresponsible little shit, you should have protected their possessions from thieves and should be able to give them back to the patient. No matter how cruel you are, it’s simply against protocol to force your patients to walk outside naked.

				<a name='11'><H4>Step 11: Send person on their way</H4>
				Give the patient one last check-over - make sure they don’t still have any defects and that they have all their possessions. Ask them how they died, if they know, so that you can report any foul play over the radio. Once you’re done, your patient is ready to go back to work! Chances are they do not have Medbay access, so you should let them out of Genetics and the Medbay main entrance.

				<p>If you’ve gotten this far, congratulations! You have mastered the art of cloning. Now, the real problem is how to resurrect yourself after that traitor had his way with you for cloning his target.



				</body>
				</html>
				"}


/obj/item/weapon/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon_state ="book"
	author = "Weyland-Yutani Corp"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned

//big pile of shit below.

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the peripherals control module with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations. Can be made using 5 metal sheets.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations. Can be made using 5 reinforced metal sheets.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Coming soon...
			"}


/obj/item/weapon/book/manual/research_and_development
	name = "Research and Development 101"
	icon_state = "rdbook"
	author = "Dr. L. Ight"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Science For Dummies</h1>
				So you want to further SCIENCE? Good man/woman/thing! However, SCIENCE is a complicated process even though it's quite easy. For the most part, it's a three step process:
				<ol>
					<li> 1) Deconstruct items in the Destructive Analyzer to advance technology or improve the design.</li>
					<li> 2) Build unlocked designs in the Protolathe and Circuit Imprinter</li>
					<li> 3) Repeat!</li>
				</ol>

				Those are the basic steps to furthing science. What do you do science with, however? Well, you have four major tools: R&D Console, the Destructive Analyzer, the Protolathe, and the Circuit Imprinter.

				<h2>The R&D Console</h2>
				The R&D console is the cornerstone of any research lab. It is the central system from which the Destructive Analyzer, Protolathe, and Circuit Imprinter (your R&D systems) are controled. More on those systems in their own sections. On it's own, the R&D console acts as a database for all your technological gains and new devices you discover. So long as the R&D console remains intact, you'll retain all that SCIENCE you've discovered. Protect it though, because if it gets damaged, you'll lose your data! In addition to this important purpose, the R&D console has a disk menu that lets you transfer data from the database onto disk or from the disk into the database. It also has a settings menu that lets you re-sync with nearby R&D devices (if they've become disconnected), lock the console from the unworthy, upload the data to all other R&D consoles in the network (all R&D consoles are networked by default), connect/disconnect from the network, and purge all data from the database.
				<b>NOTE:</b> The technology list screen, circuit imprinter, and protolathe menus are accessible by non-scientists. This is intended to allow 'public' systems for the plebians to utilize some new devices.

				<h2>Destructive Analyzer</h2>
				This is the source of all technology. Whenever you put a handheld object in it, it analyzes it and determines what sort of technological advancements you can discover from it. If the technology of the object is equal or higher then your current knowledge, you can destroy the object to further those sciences. Some devices (notably, some devices made from the protolathe and circuit imprinter) aren't 100% reliable when you first discover them. If these devices break down, you can put them into the Destructive Analyzer and improve their reliability rather then futher science. If their reliability is high enough ,it'll also advance their related technologies.

				<h2>Circuit Imprinter</h2>
				This machine, along with the Protolathe, is used to actually produce new devices. The Circuit Imprinter takes glass and various chemicals (depends on the design) to produce new circuit boards to build new machines or computers. It can even be used to print AI modules.

				<h2>Protolathe</h2>
				This machine is an advanced form of the Autolathe that produce non-circuit designs. Unlike the Autolathe, it can use processed metal, glass, solid plasma, silver, gold, and diamonds along with a variety of chemicals to produce devices. The downside is that, again, not all devices you make are 100% reliable when you first discover them.

				<h1>Reliability and You</h1>
				As it has been stated, many devices when they're first discovered do not have a 100% reliablity when you first discover them. Instead, the reliablity of the device is dependent upon a base reliability value, whatever improvements to the design you've discovered through the Destructive Analyzer, and any advancements you've made with the device's source technologies. To be able to improve the reliability of a device, you have to use the device until it breaks beyond repair. Once that happens, you can analyze it in a Destructive Analyzer. Once the device reachs a certain minimum reliability, you'll gain tech advancements from it.

				<h1>Building a Better Machine</h1>
				Many machines produces from circuit boards and inserted into a machine frame require a variety of parts to construct. These are parts like capacitors, batteries, matter bins, and so forth. As your knowledge of science improves, more advanced versions are unlocked. If you use these parts when constructing something, it's attributes may be improved. For example, if you use an advanced matter bin when constructing an autolathe (rather then a regular one), it'll hold more materials. Experiment around with stock parts of various qualities to see how they affect the end results! Be warned, however: Tier 3 and higher stock parts don't have 100% reliability and their low reliability may affect the reliability of the end machine.
				</body>
				</html>
			"}


/obj/item/weapon/book/manual/robotics_cyborgs
	name = "Cyborgs for Dummies"
	icon_state = "borgbook"
	author = "XISC"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 21px; margin: 15px 0px 5px;}
				h2 {font-size: 18px; margin: 15px 0px 5px;}
        h3 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Cyborgs for Dummies</h1>

				<h2>Chapters</h2>

				<ol>
					<li><a href="#Equipment">Cyborg Related Equipment</a></li>
					<li><a href="#Modules">Cyborg Modules</a></li>
					<li><a href="#Construction">Cyborg Construction</a></li>
					<li><a href="#Maintenance">Cyborg Maintenance</a></li>
					<li><a href="#Repairs">Cyborg Repairs</a></li>
					<li><a href="#Emergency">In Case of Emergency</a></li>
				</ol>


				<h2><a name="Equipment">Cyborg Related Equipment</h2>

				<h3>Exosuit Fabricator</h3>
				The Exosuit Fabricator is the most important piece of equipment related to cyborgs. It allows the construction of the core cyborg parts. Without these machines, cyborgs can not be built. It seems that they may also benefit from advanced research techniques.

				<h3>Cyborg Recharging Station</h3>
				This useful piece of equipment will suck power out of the power systems to charge a cyborg's power cell back up to full charge.

				<h3>Robotics Control Console</h3>
				This useful piece of equipment can be used to immobolize or destroy a cyborg. A word of warning: Cyborgs are expensive pieces of equipment, do not destroy them without good reason, or Nanotrasen may see to it that it never happens again.


				<h2><a name="Modules">Cyborg Modules</h2>
				When a cyborg is created it picks out of an array of modules to designate it's purpose. There are 6 different cyborg modules.

				<h3>Standard Cyborg</h3>
				The standard cyborg module is a multi-purpose cyborg. It is equipped with various modules, allowing it to do basic tasks.<br>A Standard Cyborg comes with:
				<ul>
				  <li>Crowbar</li>
				  <li>Stun Baton</li>
				  <li>Health Analyzer</li>
				  <li>Fire Extinguisher</li>
				</ul>

				<h3>Engineering Cyborg</h3>
				The Engineering cyborg module comes equipped with various engineering-related tools to help with engineering-related tasks.<br>An Engineering Cyborg comes with:
				<ul>
				  <li>A basic set of engineering tools</li>
				  <li>Metal Synthesizer</li>
				  <li>Reinforced Glass Synthesizer</li>
				  <li>An RCD</li>
				  <li>Wire Synthesizer</li>
				  <li>Fire Extinguisher</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Mining Cyborg</h3>
				The Mining Cyborg module comes equipped with the latest in mining equipment. They are efficient at mining due to no need for oxygen, but their power cells limit their time in the mines.<br>A Mining Cyborg comes with:
				<ul>
				  <li>Jackhammer</li>
				  <li>Shovel</li>
				  <li>Mining Satchel</li>
				  <li>Built-in Optical Meson Scanners</li>
				</ul>

				<h3>Security Cyborg</h3>
				The Security Cyborg module is equipped with effective secuity measures used to apprehend and arrest criminals without harming them a bit.<br>A Security Cyborg comes with:
				<ul>
				  <li>Stun Baton</li>
				  <li>Handcuffs</li>
				  <li>Taser</li>
				</ul>

				<h3>Janitor Cyborg</h3>
				The Janitor Cyborg module is equipped with various cleaning-facilitating devices.<br>A Janitor Cyborg comes with:
				<ul>
				  <li>Mop</li>
				  <li>Hand Bucket</li>
				  <li>Cleaning Spray Synthesizer and Spray Nozzle</li>
				</ul>

				<h3>Service Cyborg</h3>
				The service cyborg module comes ready to serve your human needs. It includes various entertainment and refreshment devices. Occasionally some service cyborgs may have been referred to as "Bros"<br>A Service Cyborg comes with:
				<ul>
				  <li>Shaker</li>
				  <li>Industrail Dropper</li>
				  <li>Platter</li>
				  <li>Beer Synthesizer</li>
				  <li>Zippo Lighter</li>
				  <li>Rapid-Service-Fabricator (Produces various entertainment and refreshment objects)</li>
				  <li>Pen</li>
				</ul>

				<h2><a name="Construction">Cyborg Construction</h2>
				Cyborg construction is a rather easy process, requiring a decent amount of metal and a few other supplies.<br>The required materials to make a cyborg are:
				<ul>
				  <li>Metal</li>
				  <li>Two Flashes</li>
				  <li>One Power Cell (Preferrably rated to 15000w)</li>
				  <li>Some electrical wires</li>
				  <li>One Human Brain</li>
				  <li>One Man-Machine Interface</li>
				</ul>
				Once you have acquired the materials, you can start on construction of your cyborg.<br>To construct a cyborg, follow the steps below:
				<ol>
				  <li>Start the Exosuit Fabricators constructing all of the cyborg parts</li>
				  <li>While the parts are being constructed, take your human brain, and place it inside the Man-Machine Interface</li>
				  <li>Once you have a Robot Head, place your two flashes inside the eye sockets</li>
				  <li>Once you have your Robot Chest, wire the Robot chest, then insert the power cell</li>
				  <li>Attach all of the Robot parts to the Robot frame</li>
				  <li>Insert the Man-Machine Interface (With the Brain inside) Into the Robot Body</li>
				  <li>Congratulations! You have a new cyborg!</li>
				</ol>

				<h2><a name="Maintenance">Cyborg Maintenance</h2>
				Occasionally Cyborgs may require maintenance of a couple types, this could include replacing a power cell with a charged one, or possibly maintaining the cyborg's internal wiring.

				<h3>Replacing a Power Cell</h3>
				Replacing a Power cell is a common type of maintenance for cyborgs. It usually involves replacing the cell with a fully charged one, or upgrading the cell with a larger capacity cell.<br>The steps to replace a cell are follows:
				<ol>
				  <li>Unlock the Cyborg's Interface by swiping your ID on it</li>
				  <li>Open the Cyborg's outer panel using a crowbar</li>
				  <li>Remove the old power cell</li>
				  <li>Insert the new power cell</li>
				  <li>Close the Cyborg's outer panel using a crowbar</li>
				  <li>Lock the Cyborg's Interface by swiping your ID on it, this will prevent non-qualified personnel from attempting to remove the power cell</li>
				</ol>

				<h3>Exposing the Internal Wiring</h3>
				Exposing the internal wiring of a cyborg is fairly easy to do, and is mainly used for cyborg repairs.<br>You can easily expose the internal wiring by following the steps below:
				<ol>
				  <li>Follow Steps 1 - 3 of "Replacing a Cyborg's Power Cell"</li>
				  <li>Open the cyborg's internal wiring panel by using a screwdriver to unsecure the panel</li>
			  </ol>
			  To re-seal the cyborg's internal wiring:
			  <ol>
			    <li>Use a screwdriver to secure the cyborg's internal panel</li>
			    <li>Follow steps 4 - 6 of "Replacing a Cyborg's Power Cell" to close up the cyborg</li>
			  </ol>

			  <h2><a name="Repairs">Cyborg Repairs</h2>
			  Occasionally a Cyborg may become damaged. This could be in the form of impact damage from a heavy or fast-travelling object, or it could be heat damage from high temperatures, or even lasers or Electromagnetic Pulses (EMPs).

			  <h3>Dents</h3>
			  If a cyborg becomes damaged due to impact from heavy or fast-moving objects, it will become dented. Sure, a dent may not seem like much, but it can compromise the structural integrity of the cyborg, possibly causing a critical failure.
			  Dents in a cyborg's frame are rather easy to repair, all you need is to apply a welding tool to the dented area, and the high-tech cyborg frame will repair the dent under the heat of the welder.

        <h3>Excessive Heat Damage</h3>
        If a cyborg becomes damaged due to excessive heat, it is likely that the internal wires will have been damaged. You must replace those wires to ensure that the cyborg remains functioning properly.<br>To replace the internal wiring follow the steps below:
        <ol>
          <li>Unlock the Cyborg's Interface by swiping your ID</li>
          <li>Open the Cyborg's External Panel using a crowbar</li>
          <li>Remove the Cyborg's Power Cell</li>
          <li>Using a screwdriver, expose the internal wiring or the Cyborg</li>
          <li>Replace the damaged wires inside the cyborg</li>
          <li>Secure the internal wiring cover using a screwdriver</li>
          <li>Insert the Cyborg's Power Cell</li>
          <li>Close the Cyborg's External Panel using a crowbar</li>
          <li>Lock the Cyborg's Interface by swiping your ID</li>
        </ol>
        These repair tasks may seem difficult, but are essential to keep your cyborgs running at peak efficiency.

        <h2><a name="Emergency">In Case of Emergency</h2>
        In case of emergency, there are a few steps you can take.

        <h3>"Rogue" Cyborgs</h3>
        If the cyborgs seem to become "rogue", they may have non-standard laws. In this case, use extreme caution.
        To repair the situation, follow these steps:
        <ol>
          <li>Locate the nearest robotics console</li>
          <li>Determine which cyborgs are "Rogue"</li>
          <li>Press the lockdown button to immobolize the cyborg</li>
          <li>Locate the cyborg</li>
          <li>Expose the cyborg's internal wiring</li>
          <li>Check to make sure the LawSync and AI Sync lights are lit</li>
          <li>If they are not lit, pulse the LawSync wire using a multitool to enable the cyborg's Law Sync</li>
          <li>Proceed to a cyborg upload console. Nanotrasen usually places these in the same location as AI uplaod consoles.</li>
          <li>Use a "Reset" upload moduleto reset the cyborg's laws</li>
          <li>Proceed to a Robotics Control console</li>
          <li>Remove the lockdown on the cyborg</li>
        </ol>

        <h3>As a last resort</h3>
        If all else fails in a case of cyborg-related emergency. There may be only one option. Using a Robotics Control console, you may have to remotely detonate the cyborg.
        <h3>WARNING:</h3> Do not detonate a borg without an explicit reason for doing so. Cyborgs are expensive pieces of Nanotrasen equipment, and you may be punished for detonating them without reason.

        </body>
		</html>
		"}

/obj/item/weapon/book/manual/security_space_law
	name = "Space Law"
	desc = "A set of Nanotrasen guidelines for keeping law and order on their space stations."
	icon_state = "bookSpaceLaw"
	author = "Nanotrasen Inc."

	dat = {"
		<html><head>
		</head>

		<body>
		<p><b>If you can't find the crime listed in here you need to set up a proper trial</b> Go here: <a href="/index.php/Legal_Standard_Operating_Procedure" title="Legal Standard Operating Procedure">Legal Standard Operating Procedure</a></p>
		<p>The time you took for bringing the suspect in and the time you spend questioning are NOT to be calculated into this. This is the pure time someone spends in a cell starring at the wall.<br />
		On laggy games first take a look at how quickly the cell timer tick... we don't want people to spend an eternity in jail for staling a pair of gloves. I am sure you have a system clock on your PC that you can keep an eye on.</p>
		<p><font size="3" color="red"><b>The maximum time someone can be put in jail for is 10 minutes (exceptions are listed below)</b></font><br />
		Always remember that when you add crimes together!</p>
		<p><br />
		Note: Compare the ingame version of this found in Security with the version on the wiki regularly. If the ingame version differs, follow the rules on the wiki, since they are easier to update.
		Link to the wiki page: <a href="http://wiki.baystation12.co.cc/index.php/Security_Sentences" class="external free" title="http://wiki.baystation12.co.cc/index.php/Security_Sentences" rel="nofollow">http://wiki.baystation12.co.cc/index.php/Security_Sentences</a>
		Compare changes here: <a href="http://wiki.baystation12.co.cc/index.php?title=Security_Sentences&amp;action=history" class="external free" title="http://wiki.baystation12.co.cc/index.php?title=Security_Sentences&amp;action=history" rel="nofollow">http://wiki.baystation12.co.cc/index.php?title=Security_Sentences&amp;action=history</a></p>

		<a name="Minor_Crimes" id="Minor_Crimes"></a><h3> <span class="mw-headline"> Minor Crimes </span></h3>
		<table width="1150px" style="text-align:center; background-color:#ffee99;" border="1" cellspacing="0">
		<tr>
		<th style="background-color:#ffee55;" width="150px">Crime
		</th><th style="background-color:#ffee55;" width="500px">Description
		</th><th style="background-color:#ffee55;" width="100px">Punishment
		</th><th style="background-color:#ffee55;" width="300px">Notes
		</th></tr>
		<tr>
		<td><b>Resisting Arrest</b>
		</td><td>Not cooperating with the officer who demands you turn yourself in peacefully. Shouting "No!" or otherwise making the officer have the need to tase you to put handcuffs on.
		</td><td> +30 seconds to original time
		</td><td> See manhunt if the suspect runs away. Or attack on an officer if he fights back. This is for shouting/swearing and moving around a bit (just so you cant cuff him) only.
		</td></tr>
		<tr>
		<td><b>Petty Theft</b>
		</td><td>Stealing non-crucial items from the ship. Items can include anything from toolboxes to metal to insulated gloves. To steal something the person must take it from a place which he doesn't have access to.
		</td><td> 60 seconds (Half the time of Theft)
		</td><td> Remember to take the items away from them and return them to where they stole them.
		</td></tr>
		<tr>
		<td><b>Theft</b>
		</td><td>Stealing of important, dangerous or otherwise crucial items like IDs, weapons or something similar. To steal something the person must take it from a place which he doesn't have access to.
		</td><td> 2 minutes (2x the time of Petty Theft)
		</td><td> Remember to take the items away from them and return them to where they stole them. Compare Robbery.
		</td></tr>
		<tr>
		<td><b>Robbery</b>
		</td><td> Robbery is stealing items from another person's possession. This can be the stealing of ID's, backpack contents or anything else.
		</td><td> 1m 30s (3m)
		</td><td> Remember to take the stolen items from the person and return them, if you can find the person they've been stolen from. Otherwise put them in a locker in security. Taking the items for yourself is considered stealing!! Remember to double the time if the robbed item was an ID or something else crucial or dangerous. Compare Theft and Petty Theft.
		</td></tr>
		<tr>
		<td><b>Assault</b>
		</td><td> To assault means to attack someone without causing them to die and without the intent to kill them.
		</td><td> 3m
		</td><td> Example: Knocking someone out to take their ID yields: Assault + Robbery
		</td></tr>
		<tr>
		<td><b>Trespassing</b>
		</td><td> Trespassing means to be in an area which you don't have access to.
		</td><td> Remove from area, if the crime is repeated imprison for 60s
		</td><td>
		</td></tr>
		<tr>
		<td><b>Indecent Exposure or being a nuisance</b>
		</td><td> Running around the ship naked, yelling at people for no reason (don't arrest someone because they are arguing), throwing around stuff where it could hit someone, etc.
		</td><td> 30s
		</td><td> Drunks can be keep to sober up, but only if they are badly harassing other crew members. Regular drunks don't get arrested and if they are only a nuisance you keep them for the regular time.
		</td></tr></table>
		<a name="Medium_Crimes" id="Medium_Crimes"></a><h3> <span class="mw-headline"> Medium Crimes </span></h3>
		<table width="1150px" style="text-align:center; background-color:#ffcc99;" border="1" cellspacing="0">
		<tr>
		<th style="background-color:#ffaa55;" width="150px">Crime
		</th><th style="background-color:#ffaa55;" width="500px">Description
		</th><th style="background-color:#ffaa55;" width="100px">Punishment
		</th><th style="background-color:#ffaa55;" width="300px">Notes
		</th></tr>
		<tr>
		<td><b>Assault with a deadly or dangerous weapon</b>
		</td><td> Getting assaulted with a knife or tased without the intention of your attacker killing you.
		</td><td> 5m
		</td><td> Usual weapons: Stun baton, taser or other gun, wirecutters, knife or scalpel, crowbar or fire extinguisher/oxygen tank.
		</td></tr>
		<tr>
		<td><b>Assault on an officer</b>
		</td><td> Assault with whichever weapon or object on an officer. An officer is defined as either a member of the security force (forensic technician included) or one of the heads of staff.
		</td><td> 5m
		</td><td> Don't abuse him. I know you want to, but don't. At least try not to. You'll get fired. Most likely.
		</td></tr>
		<tr>
		<td><b>Unlawful conduct or negligence resulting in ship damage or harm to crewmen.</b>
		</td><td> It's impossible to list everything that can lead up to this. Starting a fire in toxins is one thing, smashing windows and major vandalism is another, as is putting someone else in harms way. If you can't put it somewhere else, bets are good that it is this. If it is still not this, you need a trial.
		</td><td> 3m 30s
		</td><td> If someone dies directly related to it, add manslaughter.
		</td></tr>
		<tr>
		<td><b>Manslaughter</b>
		</td><td> Manslaughter is the unintentional killing of a fellow human being. If you cause a fire in toxins and someone else get's trapped and dies, that's manslaughter.
		</td><td> 5m
		</td><td> If there is the intention to kill, it's murder.
		</td></tr>
		<tr>
		<td><b>Theft of a high value item</b>
		</td><td> Stealing something which we know traitors often want.
		</td><td> 3m
		</td><td> Theft of a rapid construction device (RCD), Captain's jumpsuit, Hand teleporter, captain's antique laser or other items which the traitors want. Note that they have to be kept in areas which this person doesn't have access to.
		</td></tr>
		<tr>
		<td><b>Threatening Ship Integrity</b>
		</td><td> To threaten the ships integrity means to cause mediocre damage to the ships atmosphere, this means to create an air or gas leak that affects a vital part of the ship, or destroying an interior wall.
		</td><td> 5m
		</td><td> If it wasn't on purpose or if the damage is easily fixed see Unlawful conduct.
		</td></tr>
		<tr>
		<td><b>Threatening Power Supply</b>
		</td><td> Cutting power lines, shutting down power storage units, engine's power generators, etc.
		</td><td> 4m + remove insulated gloves and wirecutters and anything else that might be related, like engineering access.
		</td><td> This does not include blowing up the Engine. See Compromising Ship Integrity further down.
		</td></tr>
		<tr>
		<td><b>Sparking a man-hunt or chase</b>
		</td><td> This means the officer needs to chase after you to catch you. It means you actually flee from the scene.
		</td><td> +3m to original time
		</td><td> This will happen to you often...
		</td></tr>
		<tr>
		<td><b>Escape attempt</b>
		</td><td> Attempting to escape from the brig.
		</td><td> +2m to current time, this can exceed the maximum jail time.
		</td><td> It's the job of the officer to prevent such events.
		</td></tr></table>
		<a name="Major_Crimes" id="Major_Crimes"></a><h3> <span class="mw-headline"> Major Crimes </span></h3>
		<table width="1150px" style="text-align:center; background-color:#ffaa99;" border="1" cellspacing="0">
		<tr>
		<th style="background-color:#ff8855;" width="150px">Crime
		</th><th style="background-color:#ff8855;" width="500px">Description
		</th><th style="background-color:#ff8855;" width="100px">Punishment
		</th><th style="background-color:#ff8855;" width="300px">Notes
		</th></tr>
		<tr>
		<td><b>Identity Theft</b>
		</td><td> Stealing someones ID and/or other objects of identification with the purpose to appear to others as them or to enter into areas where the suspect would normally not have access.
		</td><td> 10 minutes
		</td><td> The case of impersonation regarding ship equipment(doors, computer terminals, AI, etc) or personnel has to be proven, otherwise see Petty Theft/Robbery. Remember to double the time if the object was an ID or something similar crucial (Compare Petty Theft).
		</td></tr>
		<tr>
		<td><b>Syndicate collaboration</b>
		</td><td> Being either a traitor, a syndicate operative or a head revolutionary
		</td><td> Until the end of the round <br />(disregard maximum sentence time) <br />or DEATH <br />(if approved by the <a href="/index.php/Captain" title="Captain">Captain</a>)
		</td><td> You have two choices: Killing them or permabrigging them. If you choose to kill them, first ask for permission from the <a href="/index.php/Captain" title="Captain">Captain</a>. If permission is given, it is wise to first <a href="/index.php/Adminhelp" title="Adminhelp" class="mw-redirect">Adminhelp</a> your intentions. Adminhelp something like: "I have grounds to believe X is a rev head. I have him locked in the brig and intend to kill him. If you have any objections to this action, please contact me." then wait for about a minute. If no PM comes, proceed to kill him. The other option is to permabrig them. This simply means you put them in the brig and don't ever let them out until your are going to evac. Then cuff them and secure them on one of the pods. (Note that Head Revolutionaries MUST be executed for you to win the round.)
		</td></tr>
		<tr>
		<td><b>Murder</b>
		</td><td> Killing someone with the intent to kill.
		</td><td> Death Sentence if authorised by the Captain. Otherwise brigging for the rest of the round.
		</td><td> Not to be confused with Manslaughter. Hint: Cyborgification is a valid execution method, since he will be bound by laws.
		</td></tr>
		<tr>
		<td><b>Attempted Murder</b>
		</td><td> Attempting to kill someone. The victim survives.
		</td><td> See Murder
		</td><td> Regardless if you succeed or not, if you try to commit murder, the punishment is the same! You have to be sure there was intent to kill though!
		</td></tr>
		<tr>
		<td><b>Compromising Ship Integrity</b>
		</td><td> Compromising a large part of the Ships atmosphere or integrity.
		</td><td> 10m (You are going to evac anyway. Cuff him and secure him on a pod.)
		</td><td> Blowing up the <a href="/index.php/Engine" title="Engine">Engine</a> is included here.
		</td></tr></table>
		<a name="Parole_Circumstances" id="Parole_Circumstances"></a><h3> <span class="mw-headline"> Parole Circumstances </span></h3>
		<p>Okay, we've covered all the punishments. Now for the parole circumstances. These circumstances will shorten your prisoner's time in jail.
		</p><p>Note that all of these add up to a maximum of <b>33%</b>!!
		</p>
		<table width="1150px" style="text-align:center; background-color:#aaffaa;" border="1" cellspacing="0">
		<tr>
		<th style="background-color:#55ff55;" width="150px">Crime
		</th><th style="background-color:#55ff55;" width="500px">Description
		</th><th style="background-color:#55ff55;" width="100px">Benefit
		</th><th style="background-color:#55ff55;" width="300px">Notes
		</th></tr>
		<tr>
		<td><b>Good behavior</b>
		</td><td> Behaving well, not attempting any problems or causing riots or screaming and yelling.
		</td><td> -20% of original time
		</td><td> It sounds like a good deal... but few will actually take it.
		</td></tr>
		<tr>
		<td><b>Reeducation</b>
		</td><td> Getting de-converted from revolutionary, renouncing traitoring (must be arranged with admins), etc. (most of these must be arranged with admins)
		</td><td> -15% of original time
		</td><td>
		</td></tr>
		<tr>
		<td><b>Cooperation with prosecution or security</b>
		</td><td> Being helpful to the members of security, revealing things during questioning or providing names of head revolutionaries.
		</td><td> -10%
		</td><td> In the case of revealing a head revolutionary: Immediate release
		</td></tr>
		<tr>
		<td><b>Surrender</b>
		</td><td> Coming to the brig, confessing what you've done and taking the punishment.
		</td><td> -25%
		</td><td> Getting arrested without putting a fuss is not surrender. For this, you have to actually come to the brig yourself.
		</td></tr>
		<tr>
		<td><b>Immediate threat to the prisoner</b>
		</td><td> Call for evac, atmospheric problems in the <a href="/index.php/Brig" title="Brig">Brig</a> or <a href="/index.php/SecHQ" title="SecHQ" class="mw-redirect">SecHQ</a> area, threat of being overrun by revolutionaries, etc
		</td><td> Immediately move the prisoner.<br /> If that is not possible: Immediate Release!
		</td><td> Keep in mind the time until they get released. Exception is if the person is a <i>CONFIRMED</i> traitor, syndicate operative or head of revolutionary. In those cases you can leave them to die.
		</td></tr>
		<tr>
		<td><b>Medical reasons</b>
		</td><td> The person needs immediate medical attention
		</td><td> Immediate escort to medbay
		</td><td> The sentence timer continues to tick while he's at medbay, it's not paused.
		</td></tr></table>

		</body>
		</html>
		"}

/obj/item/weapon/book/manual/engineering_guide
	name = "Engineering Textbook"
	icon_state ="bookEngineering2"
	author = "Engineering Encyclopedia"

	dat = {"

		<html><head>
		</head>

		<body>
		<iframe width='100%' height='97%' src="http://nanotrasen.com/wiki/index.php?title=Guide_to_engineering&printable=yes&remove_links=1" frameborder="0" id="main_frame"></iframe>
		</body>

		</html>

		"}


/obj/item/weapon/book/manual/chef_recipes
	name = "Chef Recipes"
	icon_state = "cooked_book"
	author = "Lord Frenrir Cageth"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Food for Dummies</h1>
				Here is a guide on basic food recipes and also how to not poison your customers accidentally.

				<h2>Burger:<h2>
				Put 1 meat and 1 flour into the microwave and turn it on. Then wait.

				<h2>Bread:<h2>
				Put 3 flour into the microwave and then wait.

				<h2>Waffles:<h2>
				Add 2 flour and 2 egg to the microwave and then wait.

				<h2>Popcorn:<h2>
				Add 1 corn to the microwave and wait.

				<h2>Meat Steak:<h2>
				Put 1 meat, 1 unit of salt and 1 unit of pepper into the microwave and wait.

				<h2>Meat Pie:<h2>
				Put 1 meat and 2 flour into the microwave and wait.

				<h2>Boiled Spagetti:<h2>
				Put 1 spagetti and 5 units of water into the microwave and wait.

				<h2>Donuts:<h2>
				Add 1 egg and 1 flour to the microwave and wait.

				<h2>Fries:<h2>
				Add one potato to the processor and wait.


				</body>
				</html>
			"}

/obj/item/weapon/book/manual/barman_recipes
	name = "Barman Recipes"
	icon_state = "barbook"
	author = "Sir John Rose"

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>

				<h1>Drinks for dummies</h1>
				Heres a guide for some basic drinks.

				<h2>Manly Dorf:</h2>
				Mix ale and beer into a glass.

				<h2>Grog:</h2>
				Mix rum and water into a glass.

				<h2>Black Russian:</h2>
				Mix vodka and kahlua into a glass.

				<h2>Irish Cream:</h2>
				Mix cream and whiskey into a glass.

				<h2>Screwdriver:</h2>
				Mix vodka and orange juice into a glass.

				<h2>Cafe Latte:</h2>
				Mix milk and coffee into a glass.

				<h2>Mead:</h2>
				Mix Enzyme, water and sugar into a glass.

				<h2>Gin Tonic:</h2>
				Mix gin and tonic into a glass.

				<h2>Classic Martini:</h2>
				Mix vermouth and gin into a glass.


				</body>
				</html>
			"}