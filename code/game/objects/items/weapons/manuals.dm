/*********************MANUALS (BOOKS)***********************/

/obj/item/weapon/book/manual
	icon = 'library.dmi'
	due_date = 0 // Game time in 1/10th seconds
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified


/obj/item/weapon/book/manual/engineering_construction
	name = "Station Repairs and Construction"
	icon_state ="bookEngineering"
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
				<h2> Construction </h2>

				<h3>  Advanced Materials </h3>

				<h4>   Rods </h4>

				Use <font color='gray'><b>metal</b></font> and click "2x metal rods" (makes two sets of rods)

				<h4>   Floor tiles </h4>

				Use <font color='gray'><b>metal</b></font> and click "4x floor tiles" (makes 4 floor tiles)


				<h4>   Reinforced Glass </h4>

				Use <font color='gray'><b>rods</b></font> on <font color='blue'><b>glass</b></font>

				<h4>   Reinforced Metal </h4>

				Click the <font color='gray'></b>metal<b></font> in your hand to open the construction panel,
				<br>Choose 'Reinforced sheets' form the list

				<h3>  Floor </h3>

				Use the <font color="gray"><b>rods</b></font> on <b>space</b>
				<br>Use the <font color="gray"><b>floor tile</b></font> on <b>space</b> with lattice
				<br>Use another <font color="gray"><b>floor tile</b></font> on the plating
				<br>Alternate method - Click on <font color="gray"></b>floor tile</b></font> in hand while on top of an area of <b>space</b>. No need for <font color="gray"><b>rods</b></font> with this method.

				<h3>  Walls </h3>

				Click the <font color='gray'><b>metal</b></font> in your hand to open the construction panel,
				<br>Choose 'Build wall girders' form the list
				<br>Use the remaining 2 sheets of <font color='gray'><b>metal</b></font> on the girders

				<h3>  Reinforced walls </h3>

				Click the <font color='gray'><b>metal</b></font> in your hand to open the construction panel,
				<br>Choose 'Build wall girders' form the list
				<br>Use the <font color='gray'><b>reinforced metal</b></font> on the girders to reinforce them
				<br>Use the last <font color='gray'><b>reinforced metal</b></font> sheet reinforced girders to finish the wall


				<h3>  Grille </h3>

				Stand where you wish the grille to be placed
				<br>Click on the stack of 2 <font color="gray"><b>rods</b></font> with the hand you have them in

				<h3>  Glass panels </h3>

				<h4>   One directional </h4>

				Click the <font color="blue"><b>glass</b></font> pane
				<br>Click the "one direct" button
				<br>Right-click the new pane and rotate it
				<br>Use the screwdriver to fasten it down

				<h4>   Full </h4>

				Click the <font color="blue"><b>glass</b></font> pane
				<br>Click the "full" button
				<br>Use the screwdriver to fasten it down

				<h3>  Reinforced glass panels </h3>

				<h4>   One directional </h4>

				Click the <font color="blue"><b>reinforced glass</b></font> pane
				<br>Click the "one direct" button
				<br>Right-click the new pane and rotate it
				<br>Screwdriver (Unsecure pane.)
				<br>Crowbar (Pane out of frame.)
				<br>Screwdriver (Secure frame to floor.)
				<br>Crowbar (Pop pane in.)
				<br>Screwdriver (Secure pane.)

				<h4>   Full </h4>

				Click the <font color="blue"><b>reinforced glass</b></font> pane
				<br>Click the "full" button
				<br>Screwdriver
				<br>Crowbar
				<br>Screwdriver

				<h3>  Hidden Door </h3>

				Click the <font color='gray'><b>metal</b></font> in your hand to open the construction panel,
				<br>Choose 'Build wall girders' form the list
				<br>Use crowbar on girders and wait a few seconds for the girders to dislodge.
				<br>Use the remaining 2 sheets of <font color='gray'><b>metal</b></font> on the girders

				To turn a wall into a hidden door, follow the deconstruction guide for the wall type until the final wrenching, and instead proceed from the "Use crowbar on girders" line above.

				<h4>   Reinforced </h4>

				Click the <font color='gray'><b>metal</b></font> in your hand to open the construction panel,
				<br>Choose 'Build wall girders' form the list
				<br>Use crowbar on girders and wait a few seconds for the girders to dislodge.
				<br>Use the <font color='gray'><b>reinforced metal</b></font> on the dislodged girders twice to finish it

				<h3>  APC </h3>

				Use the <font color='gray'><b>metal</b></font> and make an APC Assembly
				<br>Use the assembly on the wall you want the APC on.
				<br>Fit it with the wire coil.
				<br>Fit it with the Power Control Module.
				<br>Screwdriver the electronics into place.
				<br>Add the Power Cell.
				<br>Crowbar shut. It starts ID locked, with the cover engaged and the main switch turned off.

				<h3>  Airlock </h3>

				Use the <font color='gray'><b>metal</b></font> and make an Airlock Assembly
				<br>Wrench it inplace
				<br>Add reinforced glass (Only if you wish to make a glass airlock)
				<br>Add wires
				<br>Unlock the airlock electronic board with an ID
				<br>Use the airlock electronic board and set the access level
				<br>Add the airlock electronic board to the airlock frame.
				<br>Screwdriver to finish

				<h3>  Computers </h3>

				Use the <font color='gray'><b>metal</b></font> to open the construction panel
				<br>Choose Computer frame
				<br>Wrench it inplace
				<br>Insert Circuitboard
				<br>Screwdriver
				<br>Wires
				<br><font color='blue'><b>glass</b></font>
				<br>Screwdriver to finish

				<h3>  AI Core </h3>

				Build Frame from 4 <font color='fray'><b>reinforced sheets</b></font>
				<br>Wrench into place
				<br>Add Circuit board
				<br>Screwdriver
				<br>Add wires
				<br>Add brain (only if you want a NEW AI)
				<br>Add <font color='blue'><b>reinforced glass</b></font>
				<br>Screwdriver

				<h2> Deconstruction </h2>

				<h3>  Walls </h3>

				Wdlder
				<br>Wrench

				<h3>  Reinforced walls </h3>

				Wirecutters.
				<br>Screwdriver.
				<br>Welder.
				<br>Crowbar.
				<br>Wrench.
				<br>Welder.
				<br>Crowbar.
				<br>Screwdriver.
				<br>Wirecutters.
				<br>Wrench.

				<h3>  Grille </h3>

				Wirecutters
				<br>Welder (to destroy it)
				<br>or
				<br>screwdriver (to unfasten it)

				<h3>  Glass panels </h3>

				The first method destroys it, the second gives a pullable pane of glass.

				<br>Welding glass shards creates a pane of glass.

				<h3>  Reinforced glass panels </h3>

				Screwdriver to loosen the pane.
				<br>Crowbar to pop it out.
				<br>Screwdriver to unscrew the frame.
				<br>Crowbar to pop the pane in.
				<br>Screwdriver to secure it.

				Hitting the pane repeatedly with a blunt item will smash it into one set of metal rods and a glass shard.

				<h3>  Hidden Door (Regular or Reinforced) </h3>

				Screwdriver
				<br>Welder
				<br>Wrench

				<h3>APC </h3>

				Swipe Card to unlock APC.
				<br>Remove Power Cell.
				<br>Screwdriver to unsecure electronics.
				<br>Wirecutters to remove cables.
				<br>Crowbar to remove Power Control Board.
				<br>Welder to remover from wall.
				<br>Wrenching the frame that is now detached from the wall de-constructs it to two metal sheets.

				<h3>  Airlock </h3>

				Screwdriver the door.
				<br>Use multitool and wirecutters to disable everything except the doorbolts as detailed in books on hacking. Doorbolts must be up for this to work.
				<br>Weld the door shut.
				<br>Crowbar the electronics out.
				<br>Wirecut the wires out.
				<br>Unsecure it with a wrench.
				<br>Weld it to deconstruct to metal plates.

				Cannot be done to emagged airlock. RCD deconstruction must be used for that.

				<h3>  Computers </h3>

				Screwdriver.
				<br>Crowbar.
				<br>Wirecutters.
				<br>Screwdriver.
				<br>Wrench.
				<br>Welder.	"}

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
				<h2>What you'll need</h2>
				<ul>
				<li><b>Insulated gloves</b> Hackables have power lines, and cutting/pulsing these without gloves can harm you.</li>
				<li><b>Screwdriver</b> for opening up panels and the like. A necessary tool</li>
				<li><b>Wirecutters</b> for cutting and mending wires. Also a necessary tool</li>
				<li><b>Multitool</b> for pulsing wires; not necessary for most hacking, but makes life a lot easier.</li>
				</ul>

				<h2>Important Hackables</h2>

				<h3>Airlocks</h3>
				Both internal and external access airlocks are hackable, despite the fact that external ones look a lot like firelocks, which are not hackable. Wires are randomized at the start of each round, but are standardized throughout the station, e.g., every orange wire might toggle the bolts. This is probably where you'll be doing the most of your hacking. Remember, cutting power to the door will stop everything else from working.
				<ol>
				<li> Screwdriver in hand, click on the airlock to open the panel and expose the wiring</li>
				<li> With multitool, wirecutters, or an empty hand, click on the airlock to access the wiring.</li>
				<li> Fiddle with the wires by pulsing to test each one and cutting what you need to.</li>
				<ul>
					<li><b>ID wire</b>: <i>Pulsing</i> will flash the 'access denied' red light; <i>cutting</i> will prevent anyone from opening the door if it's a restricted door; otherwise, it does nothing.</li>
					<li><b>AI control wire</b>: <i>Pulsing</i> will flash the 'AI control light' off and on quickly; <i>cutting</i> will prevent the AI from accessing the door unless s/he hacks the power wires</li>
					<li><b>Main power wire</b>: <i>Pulsing</i> will turn off the 'test light' and kill the power for 1 minute; <i>cutting</i> will kill the power for 10 seconds before backup power kicks in.</li>
					<li><b>Backup power wire</b>: <i>Pulsing</i> will turn off the 'test light' kill the power for 1 minute of the main power is out, otherwise, nothing. <i>Cutting</i> will obviously disable the backup power.</li>
					<li><b>Bolt control wire</b>: <i>Pulsing</i> will toggle the bolts; <i>cutting</i> will drop the bolts.</li>
					<li><b>Door control wire</b>: If the door is ID restricted, this is pretty much useless. If not, <i>Pulsing</i> will open/close the door and <i>cutting</i> will keep it that way, sortof like bolting.</li>
					<li><b>Electrifying wire</b>: <i>Pulsing</i> will electrify the door for 30 seconds; <i>cutting</i> will permanently electrify it until mended. I haven't a clue how to find this wire out except through trial and painful error. Obviously useless if there is no power to the door.</li>
				</ul>
				<li> Screwdriver the door again to shut the panel. Otherwise, trying to open the door will always give you the wiring popup.</li>
				</ol>

				<h4>Airlock Strategies</h4>
				<ul>
					<li><b>Ghetto hacking</b> involves accessing a useless airlock and cutting all of the wires in order until the bolts drop, making a note of the wire you just cut. Keeping this in mind, you can now open restricted doors by cutting all the wires except the bolt control and then crowbarring that fucker open. Useful if you don't have a multi-tool. Note that this is a bad idea if you lack gloves.</li>
					<li><b>Open ID restricted doors</b> by pulsing a main power wire and then crowbarring it open. If it's bolted, be sure to pulse the bolt wire before you kill the power or you're shit outta luck for a minute. (You can shorten this by cutting and mending the power wire, but by then the power would probably have reset anyway. Still, taking 20 seconds less to unhack the Escape shuttle doors is always good)</li>
					<li><b>Create a pain in the ass obstacle</b> by dropping the bolts, cutting all the wires, and then welding the door shut. This is especially effective if you happen to have the only pair of insulated gloves on the station.</li>
					<li><b>Remotely pulse an airlock</b> by attaching a signaler, which when signaled pulses the wire it's attached to. This allows you to remotely bolt and unbolt a door, for instance. Be sure to turn off the speaker so no one can hear it being toggled.</li>
					<li><b>Use multitools for bolted </b> as they are awesome. First find two wires of importance. The bolts wire, and the main power wire. Pulse a random door to find out the wires. If you hear sparks, see your health going down or see the message "You feel a powerful shock coursing through your body!", close that hacking window and move onto another door. Once you got the main power wire, head to an unbolted door, pulse the wire, crowbar it open. You get a larger window of time to crowbar, and you can do it without gloves. If a door is bolted, pulse the bolts wires, and go and cut the power then crowbar it.</li>
				</ul>

				<h3>APCs</h3>
				Used to control power to a certain room. Nice to know when a rogue AI or douchebag engineers keep turning off your power. All APC breakers can be accessed via Power Monitoring Computers regardless of the lock status, so hope that whoever's fucking with the power isn't paying attention
				<ol>
				<li>Screwdriver in hand, click on APC to open the panel and expose the wiring</li>
				<li>Click with an empty hand to access the wiring</li>
				<li>Fiddle with the wires by pulsing to test each one and cutting what you need to.</li>
				<ul>
					<li><b>Power wires (2)</b>: <i>Pulse</i> will short out the APC. You must <i>cut and mend</i> the wire to restore power. Not repairing the short will render the main breaker moot, even if accessed remotely.</li>
					<li><b>AI control wire</b>: Like the airlock, <i>pulsing</i> will flash the light off and on quickly; <i>cutting</i> will disable AI control</li>
				</ul>
				<li>Screwdriver it back up to toggle lighting, equipment, and atmospherics as you see fit (unless you've killed the power)</li>
				</ol>

				<h3>Autolathe</h3>
				<ol>
				<li>Click on the autolathe to open it</li>
				<li>Click on the autolathe with an empty hand to access the wiring, then get a tool in your hand</li>
				<li>The window is glitched and won't show what wires are cut, so you better track what wires you modify. There are three important wires, which are randomized. Cutting them toggles their light permanently, pulsing does so temporarily(30 secs or something). Red light is power, green light is electrocution and blue is hacked options.</li>
				<li>Have fun accessing some new options</li>
				<ul>
				<li>RCD supplies</li>
				<li>Infrared beam (security)</li>
				<li>Infrared sensor</li>
				<li>Bullets</li>
				<li>Other shit</li>
				</ul>
				</ol>

				<h3>Air alarm/Fire alarm/Cameras</h3>
				Use wirecutters to enable/disable. Disabled <i>air alarms</i> will show no lights, <i>fire alarms</i> will not automatically trigger firelocks, and <i>cameras</i> will show a red light and prevent anyone from viewing the room through a console (including AI).


				<h3>MULE</h3>
				No better way to get away from it all with a joyride on a MULE! And run over some people with it too.
				<ol>
				<li>Unlock the controls with a Quartermaster's ID.</li>
				<li>Unscrew the maintenance panel with the screwdriver.</li>
				<li>Pulse various wires with a multitool. Pay attention to the reaction the MULE gives.</li>
				<ol>
					<li>Cutting the wire that causes the loading bay to thunk will remove cargo restrictions.</li>
					<li>Cutting the wire that leads to the safety light will awaken its thirst for blood and cause it to run over people in its path. DO NOT DO THIS UNLESS YOU ARE A TRAITOR OR LOVE GETTING THE SHIT ROBUSTED OUT OF YOU.</li>
					<li>Cutting <i>one</i> of the wires that makes the motor whine will safely speed up the MULE. Cutting both will immobilize it.</li>
				</ol>
				<li>Screw the panel back on.</li>
				</ol>

				<h2>Minor Hackables</h2>
				I haven't a clue why you'd ever want to hack any of these things, but you can!

				<h3>Radio/Signaler</h3>
				<ol>
				<li>Screwdriver in hand, click on the offending radio so it can be modified or attached
				<li>The usual radio use panel will pop up, but now with access to the wiring. If you've closed it by accident, just click on the radio as if you were going to change the settings on it.
				<li>There are three wires. Two have apparent uses; the third is pretty much useless.
				<ul>
					<li><b>Output wire</b> will disengage the speakers (or signal-receiving on a signaler)
					<li><b>Input wire</b> will permanently disengage the microphone (or signal-sending on a signaler)
				</ul>
				</ol>
				Interestingly, tracking beacons and station intercoms also count as radios.

				<h3>Secure Briefcase, Safes</h3>
				<i>seriously who is dumb enough to use these things anyway god damn</i>
				<ol>
				<li>Screwdriver in hand, click on the (briefcase/safe) to open the panel and expose the wiring</li>
				<li>Multi-tool-spam the (briefcase/safe) until you get a confirmation that the memory is reset.</li>
				<li>The memory is now reset. Punch in your favorite code and hit E to set it.</li>
				<li>Screwdriver the panel shut.</li>
				</ol>

				<h3> Vending machines </h3>
				The only thing worth hacking!

				Four wires
				<ol>
				<li><b>Firing wire</b> when cut fires stuff at people. When pulsed will do so. Controlled by the blinking light.</li>
				<li><b>Contraband wire</b> does nothing when cut, when pulsed unlocks illegal or rare goods. Wire is unknown. </li>
				<li><b>Access wire</b> when cut it turns on a yellow light, allowing for ID restricted machines(med machines, sec machines, possibly botany machines) to be used by anyone.</li>
				<li><b>Shock wire</b> Like the firing wire in effects from hacking, except it shocks instead of shoots.</li>
				</ol>
"}



/obj/item/weapon/book/manual/engineering_guide
	name = "Engineering Textbook"
	icon_state ="bookEngineering2"
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
				So, you're an Engineer, fresh from the academy, eh? Well here is a guide for you, then. Engineering, the Space station 13 way!

				<h2> How much game experience do i need to be a good engineer? </h2>

				Engineering is rather complex, but in itself teaches you many of the station's core mechanics. Even someone with very little experience, who can pick up and empty a toolbox is able to become a good engineer.

				<h2> Before we start </h2>

				<h3> Engineering equipment </h3>

				This is an image of the tools every engineer should be trusted to have on him at all times:

				<p><img src='http://tgstation13.servehttp.com/wiki/images/7/72/Engineers_loadout.png'>

				<p><table cellpadding=3 cellspacing=0 border=1>
				<tr bgcolor='#ddaa77'>
				<td><b>Container picture</b></td>
				<td><b>Container name</b></td>
				<td><b>Contents</b></td>
				<tr bgcolor='#eeccaa' align='center'>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/1/17/Eng_toolbelt.PNG'></td>
				<td><b>Utility belt</b></td>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/e/e2/Toolbelt.png'></td>
				</tr>
				<tr bgcolor='#eeccaa' align='center'>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/e/eb/Eng_backpack.PNG'></td>
				<td><b>Backpack</b></td>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/9/97/Engineers_backpack_contents.png'></td>
				</tr>
				<tr bgcolor='#eeccaa' align='center'>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/f/fc/Eng_box.PNG'></td>
				<td><b>Box</b></td>
				<td><img src='http://tgstation13.servehttp.com/wiki/images/b/b1/Engineers_box_contents.PNG'></td>
				</tr>
				</table>

				<p>Note that some of these are for roleplay reasons only. Although you can wear a welding mask all the time it makes little to no sense to do that from a roleplay standpoint. Same applies to keeping a pen (but you will not start with a pen). You'll need it very rarely, but a time will come when you'll actually need it. Roleplay too determines if you're a good engineer or not.

				<h2> The engine, solars and power </h2>

				<h3> Generating power </h3>

				The primary purpose of engineering is to maintain the station's power. To do this, you will need to start the Singularity Engine. Please read the book entitled: 'Singularity engine' for details on this.

				<p>The solars are the next thing you need to worry about. As starting the singularity can be a bit risky, you should watch others do it before you attempt it alone. In the mean time, you can do the wiring of the solars. To do this you will need the RIG suit as well as internals (oxygen tank and gas mask), all of which can be found in engineering. Note that it is a good idea to return the RIG suit once you're done. More on wiring solars can be found in the book entitled 'Solar Panels on Space Stations'

				<h3> Wiring </h3>

				If a part of the station looses power it is likely wires have been cut somewhere. To search for cut wires under floors you will need a T-Ray Scanner. To cut wires, use the wirecutters and to place new ones click on the floor where you'd like them to be placed. The wire will be placed on the targeted tile from the tile you're standing on. You can also place wires on the tile you're currently on by clicking the tile. the wire will be placed in the direction you're currently facing. To place smooth wires, click on the red dot (end point) of an existing wire with more wire in your hand.

				<p>Wiring intersections demand special mention. Making an intersection requires all the wire pieces to be end-points. If you make a smooth wire going south to north and place a half-wire going east, they will not be connected. To connect them you have to remove the smooth wire and replace it with two half-wires. Once all of them are placed, if you right click the tile you should see three wire pieces, all of which meet in the center.

				<h3> Power monitoring and distribution </h3>

				an APC or Area Power Controller is located in every room. It is usually locked, but you can unlock it by swiping your ID on it. It contains a power cell. You can shut off a room's power or disable or enable lighting, equipment or atmospheric systems with it. Every room can have only one APC. The guide to their construction and deconstruction can be found in the book entitled 'Station repairs and construction'. APC's can also be hacked (More on that in the book entitled 'Hacking'). It's also a good idea to know how to do that. DO NOT PRACTICE ON THE ENGINE APCs! If you mess up, you can destroy it through hacking which can set the singularity free if you do it in engineering! You know this warning is here because it happened before.

				<h2> Station structural integrity </h2>

				An educated word which basically means wall repairs.

				<h3> The secrets surrounding walls </h3>

				Walls come in two forms: Regular and reinforced. Building a regular wall is a two step process: constructing girders and adding plating. To construct a girder have a stack of two or more sheets of metal on you (right click the metal and examine it to see how many sheets are in the stack). Left click the metal for a construction window to appear. choose "Construct wall girders" from the list and wait a few seconds while they're built. Once they're built, click on the girders with another stack of two or more metal to add the plating. Note that only fully built walls will prevent air from escaping freely through them. Reinforced walls share the first step: the building of the girders. after this, you'll need 4 sheets of metal. In the same way as you built the girders, create two reinforced sheets. Use one of them on the girders to create reinforced girders and the other on the reinforced girders to finalize them. Reinforced walls are much stronger than regular walls and take much longer to get through using regular tools.

				<p>For more on construction read the book entitled 'Station Repairs and Construction'

				<h3> Pretty glass </h3>

				Notice how most of the glass around the station is built as a double pane, which surrounds a grille. Making this by hand can be a bit tricky at first, but is simple once you get the hang of it. To build such a wall, you'll need 4 sheets of glass and 3 sheets of metal, alternatively you can have 6 sets of rods. You'll also need a screwdriver and crowbar, tho having wirecutters and a welder with you is a good idea, as you'll likely get it wrong the first time and will need those to dismantle the grille. First you have to prepare your materials. Use the metal on itself and create 6 sets of rods (2 are made each time). Now pick the rods up (you can stack them, but don't click too quickly or the game might think you wanted to build a grille). After this, use 4 of the rods on 4 sheets of glass to create 4 sheets of reinforced glass. Now pick up all your tools (put them on your utility belt if you have one or in your backpack) and pick up the remaining two rods in one hand and the 4 sheets of reinforced glass in your other (remember, you can stack glass too). Now stand where you'd like the glass to be. Use the rods on themselves and this will create a grille. DO NOT MOVE! Now use the glass on itself 4 times and create a single paned glass every time. Right click on the glass to rotate it until you have 3 of the 4 sides covered. The remaining side is your escape route. use the combination of screwdriver - crowbar - screwdriver on each of the 3 panes which are already in place to secure them. Now move out of the grille and rotate the last window so it covers the last side. Fasten that with the same screwdriver - crowbar - screwdriver combination. Congratulations. You've just made a proper window. You're already better at construction than most.

				<p>For more on construction read the book entitled 'Station Repairs and Construction'

				<h2> Robots, Artificial Intelligence and Computers </h2>

				As an engineer, it is required of you to understand how most computers are operated, how they work, how they're created, dismantled and repaired. You're also the best equipped station employee to prevent the AI from taking a life of it's own.

				<h3> Computers </h3>

				Computers are everywhere on SS13. Engineering has a power monitoring computer, several solar computers and a general alerts computer. Almost everything you can control is done through a computer. Making them is described in the book entitled 'Station Repairs and Construction', as is their dissasembly (for those which can be deconstructed). To learn how to operate different computer you'll need to start using them and find out how they work while doing so. There are too many to explain them all here.

				<h3> Artificial int... stupidity </h3>

				More often than not, the AI will be rogue. This means it has laws which are harmful. It will try it's best to kill any crew members by flooding the halls with toxic plasma, sparking fires, overloading APC's, electrifying doors, etc. At such a time you have two choices: Destroy it or reset it. As said, the AI works on a principle of laws. People can upload new ones to it and if these are harmful, you'll first want to try to reset it. In technical storage (in the maintenance hallway between assistant's storage and EVA) you have an AI upload card and an AI reset module. To reset the AI, first create an AI upload computer and once it is created, click on it to choose the rogue AI and use the module on it to reset it. If the person has uploaded a core law, then it's a bit harder. A core law cannot be reset with the AI reset module. You'll need to override it with another AI core module. These can be found in the AI upload area under lock and key. But if the person who uploaded the traitorous law got in, you can get in too, right? The often preferred alternative is to simply kill the AI. Tear down the walls and shoot it, blow it up, use the chemist to prepare something. There are many ways of doing this. Note that if hostile runtimes are reported, you'll have to get to the AI satellite, as the rogue AI is there.

				<p>Blowing up cyborgs is normally done by the roboticist or Research Director, but you may need to help them create a robotics console at some point. One of these can be found in tech storage, but is usually stolen quickly.

				<p>The alternative methods to being helpful included hacking APCs and doors, usually to disable the AI control. This is especially important anywhere near a robotics control, engine, or any of the SMES rooms. The AI has no reason to have control over these anyway.

				<h2> Getting the man out of danger... alive! </h2>

				It's your job to save lives when they cry out for help.

				<h3> Firefighting </h3>

				Engineers get access to maintenance hallways, which contain several firesuits and extinguishers. If a fire breaks out somewhere, put it out. Firesuits allow you to walk in almost any fire. Extinguishers have a limited capacity. Refill them with water tanks, which can be found all around the station.

				<h3> Physical rescue </h3>

				If someone cries that he can't get out of somewhere and no one can get him out, then it's your job to do so. Hacking airlocks, deconstructing walls, basically whatever it takes to get to them. I don't need to point out that you should never put others or yourself at risk in doing so!

				<h3> Space recovery </h3>

				A body's been spaced? Well now it's your job to recover it. Ask the AI or captain to get a jetpack and space suit from EVA and go after the body. You'll most frequently find bodies either somewhere near the derelict or the AI satellite. Drag them to a teleporter and get them back to the station. The use of lockers will help greatly, as lockers do not drift like bodies do, but cannot travel across Z-levels. ALWAYS have tools, glass and metal with you when doing this! Some teleporters need to be rebuilt and some bodies float around randomly and need floor tiles to be build in their path to actually stop

				<h2> Space exploration </h2>

				Space exploration can be fun. Although there are not too many things to see in space at the moment, but things change sometimes. You may also get some things which could come in handy.


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
