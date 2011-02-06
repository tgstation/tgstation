/obj/item/weapon/book/manual/engineering_construction
	name = "Station Repairs and Construction"
	icon = 'library.dmi'
	icon_state ="bookEngineering"
	due_date = 0 // Game time in 1/10th seconds
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified

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


/obj/item/weapon/book/manual/engineering_hacking
	name = "Hacking"
	icon = 'library.dmi'
	icon_state ="bookHacking"
	due_date = 0 // Game time in 1/10th seconds
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified

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
	icon = 'library.dmi'
	icon_state ="bookEngineering2"
	due_date = 0 // Game time in 1/10th seconds
	author = "Engineering Encyclopedia"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified

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





/**********************Light************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/light_emitter
	name = "Light-emtter"
	anchored = 1
	unacidable = 1
	luminosity = 8

/**********************Random mine generator************************/

//this item is intended to give the effect of entering the mine, so that light gradually fades
/obj/mine_generator
	name = "Random mine generator"
	anchored = 1
	unacidable = 1
	var/turf/last_loc
	var/turf/target_loc
	var/turf/start_loc
	var/randXParam //the value of these two parameters are generated by the code itself and used to
	var/randYParam //determine the random XY parameters
	var/mineDirection = 3
	/*
		0 = none
		1 = N
		2 = NNW
		3 = NW
		4 = WNW
		5 = W
		6 = WSW
		7 = SW
		8 = SSW
		9 = S
		10 = SSE
		11 = SE
		12 = ESE
		13 = E
	 	14 = ENE
		15 = NE
		16 = NNE
	*/

/obj/mine_generator/New()
	last_loc = src.loc
	var/i
	for(i = 0; i < 50; i++)
		gererateTargetLoc()
		//target_loc = locate(last_loc.x + rand(5), last_loc.y + rand(5), src.z)
		fillWithAsteroids()
	del(src)
	return


/obj/mine_generator/proc/gererateTargetLoc()  //this proc determines where the next square-room will end.
	switch(mineDirection)
		if(1)
			randXParam = 0
			randYParam = 4
		if(2)
			randXParam = 1
			randYParam = 3
		if(3)
			randXParam = 2
			randYParam = 2
		if(4)
			randXParam = 3
			randYParam = 1
		if(5)
			randXParam = 4
			randYParam = 0
		if(6)
			randXParam = 3
			randYParam = -1
		if(7)
			randXParam = 2
			randYParam = -2
		if(8)
			randXParam = 1
			randYParam = -3
		if(9)
			randXParam = 0
			randYParam = -4
		if(10)
			randXParam = -1
			randYParam = -3
		if(11)
			randXParam = -2
			randYParam = -2
		if(12)
			randXParam = -3
			randYParam = -1
		if(13)
			randXParam = -4
			randYParam = 0
		if(14)
			randXParam = -3
			randYParam = 1
		if(15)
			randXParam = -2
			randYParam = 2
		if(16)
			randXParam = -1
			randYParam = 3
	target_loc = last_loc
	if (randXParam > 0)
		target_loc = locate(target_loc.x+rand(randXParam),target_loc.y,src.z)
	if (randYParam > 0)
		target_loc = locate(target_loc.x,target_loc.y+rand(randYParam),src.z)
	if (randXParam < 0)
		target_loc = locate(target_loc.x-rand(-randXParam),target_loc.y,src.z)
	if (randYParam < 0)
		target_loc = locate(target_loc.x,target_loc.y-rand(-randXParam),src.z)
	if (mineDirection == 1 || mineDirection == 5 || mineDirection == 9 || mineDirection == 13) //if N,S,E,W, turn quickly
		if(prob(50))
			mineDirection += 2
		else
			mineDirection -= 2
			if(mineDirection < 1)
				mineDirection += 16
	else
		if(prob(50))
			if(prob(50))
				mineDirection += 1
			else
				mineDirection -= 1
				if(mineDirection < 1)
					mineDirection += 16
	return


/obj/mine_generator/proc/fillWithAsteroids()

	if(last_loc)
		start_loc = last_loc

	if(start_loc && target_loc)
		var/x1
		var/y1

		var/turf/line_start = start_loc
		var/turf/column = line_start

		if(start_loc.x <= target_loc.x)
			if(start_loc.y <= target_loc.y)                                 //GOING NORTH-EAST
				for(y1 = start_loc.y; y1 <= target_loc.y; y1++)
					for(x1 = start_loc.x; x1 <= target_loc.x; x1++)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,EAST)
					line_start = get_step(line_start,NORTH)
					column = line_start
				last_loc = target_loc
				return
			else                                                            //GOING NORTH-WEST
				for(y1 = start_loc.y; y1 >= target_loc.y; y1--)
					for(x1 = start_loc.x; x1 <= target_loc.x; x1++)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,WEST)
					line_start = get_step(line_start,NORTH)
					column = line_start
				last_loc = target_loc
				return
		else
			if(start_loc.y <= target_loc.y)                                 //GOING SOUTH-EAST
				for(y1 = start_loc.y; y1 <= target_loc.y; y1++)
					for(x1 = start_loc.x; x1 >= target_loc.x; x1--)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,EAST)
					line_start = get_step(line_start,SOUTH)
					column = line_start
				last_loc = target_loc
				return
			else                                                            //GOING SOUTH-WEST
				for(y1 = start_loc.y; y1 >= target_loc.y; y1--)
					for(x1 = start_loc.x; x1 >= target_loc.x; x1--)
						new/turf/simulated/floor/airless/asteroid(column)
						column = get_step(column,WEST)
					line_start = get_step(line_start,SOUTH)
					column = line_start
				last_loc = target_loc
				return


	return



/**********************Mine areas**************************/

/area/mine/explored
	name = "Mine"
	icon_state = "janitor"
	music = null

/area/mine/unexplored
	name = "Mine"
	icon_state = "captain"
	music = null

/area/mine/lobby
	name = "Mining station"
	icon_state = "mine"


/**********************Mineral deposits**************************/

/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'walls.dmi'
	icon_state = "rock"
	oxygen = 0
	nitrogen = 0
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = TCMB
	var/mineralName = ""
	var/mineralAmt = 0
	var/spread = 0 //will the seam spread?
	var/spreadChance = 0 //the percentual chance of an ore spreading to the neighbouring tiles

/turf/simulated/mineral/Del()
	return

/turf/simulated/mineral/ex_act(severity)
	switch(severity)
		if(3.0)
			return
		if(2.0)
			if (prob(70))
				src.mineralAmt -= 1 //some of the stuff gets blown up
				src.gets_drilled()
		if(1.0)
			src.mineralAmt -= 2 //some of the stuff gets blown up
			src.gets_drilled()
	return

/turf/simulated/mineral/New()
	if (mineralName && mineralAmt && spread && spreadChance)
		if(prob(spreadChance))
			if(istype(get_step(src, SOUTH), /turf/simulated/mineral/random))
				new src.type(get_step(src, SOUTH))
		if(prob(spreadChance))
			if(istype(get_step(src, NORTH), /turf/simulated/mineral/random))
				new src.type(get_step(src, NORTH))
		if(prob(spreadChance))
			if(istype(get_step(src, WEST), /turf/simulated/mineral/random))
				new src.type(get_step(src, WEST))
		if(prob(spreadChance))
			if(istype(get_step(src, EAST), /turf/simulated/mineral/random))
				new src.type(get_step(src, EAST))
	return

/turf/simulated/mineral/random
	name = "Mineral deposit"
	var/mineralAmtList = list("Uranium" = 5, "Iron" = 5, "Diamond" = 5, "Gold" = 5, "Silver" = 5, "Plasma" = 5)
	var/mineralSpawnChanceList = list("Uranium" = 5, "Iron" = 50, "Diamond" = 1, "Gold" = 5, "Silver" = 5, "Plasma" = 25)
	var/mineralChance = 10  //means 10% chance of this plot changing to a mineral deposit

/turf/simulated/mineral/random/New()
	if (prob(mineralChance))
		var/mName = pickweight(mineralSpawnChanceList) //temp mineral name
		//spawn(5)
		if (mName)
			var/turf/simulated/mineral/M
			switch(mName)
				if("Uranium")
					M = new/turf/simulated/mineral/uranium(src)
				if("Iron")
					M = new/turf/simulated/mineral/iron(src)
				if("Diamond")
					M = new/turf/simulated/mineral/diamond(src)
				if("Gold")
					M = new/turf/simulated/mineral/gold(src)
				if("Silver")
					M = new/turf/simulated/mineral/silver(src)
				if("Plasma")
					M = new/turf/simulated/mineral/plasma(src)
			if(M)
				src = M
				M.levelupdate()
	return

/turf/simulated/mineral/random/Del()
	return

/turf/simulated/mineral/uranium
	name = "Uranium deposit"
	icon_state = "rock_Uranium"
	mineralName = "Uranium"
	mineralAmt = 5
	spreadChance = 10
	spread = 1



/turf/simulated/mineral/iron
	name = "Iron deposit"
	icon_state = "rock_Iron"
	mineralName = "Iron"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/diamond
	name = "Diamond deposit"
	icon_state = "rock_Diamond"
	mineralName = "Diamond"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/gold
	name = "Gold deposit"
	icon_state = "rock_Gold"
	mineralName = "Gold"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/silver
	name = "Silver deposit"
	icon_state = "rock_Silver"
	mineralName = "Silver"
	mineralAmt = 5
	spreadChance = 10
	spread = 1


/turf/simulated/mineral/plasma
	name = "Plasma deposit"
	icon_state = "rock_Plasma"
	mineralName = "Plasma"
	mineralAmt = 5
	spreadChance = 25
	spread = 1


/turf/simulated/mineral/clown
	name = "Bananium deposit"
	icon_state = "rock_Clown"
	mineralName = "Clown"
	mineralAmt = 3
	spreadChance = 0
	spread = 0


/turf/simulated/mineral/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/airless/asteroid/W
	var/old_dir = dir

	W = new /turf/simulated/floor/airless/asteroid( locate(src.x, src.y, src.z) )
	W.dir = old_dir
	W.fullUpdateMineralOverlays()

	/*
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	*/
	W.opacity = 1
	W.sd_SetOpacity(0)
	W.levelupdate()
	return W


/turf/simulated/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/pickaxe))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		user << "\red You start picking."
		//playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(40)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You finish cutting into the rock."
			gets_drilled()

	else
		return attack_hand(user)
	return

/turf/simulated/mineral/proc/gets_drilled()
	if ((src.mineralName != "") && (src.mineralAmt > 0) && (src.mineralAmt < 11))
		var/i
		for (i=0;i<mineralAmt;i++)
			if (src.mineralName == "Uranium")
				new /obj/item/weapon/ore/uranium(src)
			if (src.mineralName == "Iron")
				new /obj/item/weapon/ore/iron(src)
			if (src.mineralName == "Gold")
				new /obj/item/weapon/ore/gold(src)
			if (src.mineralName == "Silver")
				new /obj/item/weapon/ore/silver(src)
			if (src.mineralName == "Plasma")
				new /obj/item/weapon/ore/plasma(src)
			if (src.mineralName == "Diamond")
				new /obj/item/weapon/ore/diamond(src)
			if (src.mineralName == "Clown")
				new /obj/item/weapon/ore/clown(src)
	ReplaceWithFloor()
	return

/*
/turf/simulated/mineral/proc/setRandomMinerals()
	var/s = pickweight(list("uranium" = 5, "iron" = 50, "gold" = 5, "silver" = 5, "plasma" = 50, "diamond" = 1))
	if (s)
		mineralName = s

	var/N = text2path("/turf/simulated/mineral/[s]")
	if (N)
		var/turf/simulated/mineral/M = new N
		src = M
		if (src.mineralName)
			mineralAmt = 5
	return*/


/**********************Asteroid**************************/

/turf/simulated/floor/airless/asteroid //floor piece
	name = "Asteroid"
	icon = 'floors.dmi'
	icon_state = "asteroid"
	oxygen = 0
	nitrogen = 0
	temperature = TCMB
	var/seedName = "" //Name of the seed it contains
	var/seedAmt = 0   //Ammount of the seed it contains
	var/dug = 0       //0 = has not yet been dug, 1 = has already been dug

/turf/simulated/floor/airless/asteroid/New()
	..()
	if (prob(50))
		seedName = pick(list("1","2","3","4"))
		seedAmt = rand(1,4)
	spawn(2)
		updateMineralOverlays()

/turf/simulated/floor/airless/asteroid/ex_act(severity)
	return

/turf/simulated/floor/airless/asteroid/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/shovel))
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (dug == 1)
			user << "\red This area has already been dug"
			return

		user << "\red You start digging."
		playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(50)
		if ((user.loc == T && user.equipped() == W))
			user << "\blue You dug a hole."
			gets_dug()
			dug = 1
			icon_state = "asteroid_dug"

	else
		return attack_hand(user)
	return

/turf/simulated/floor/airless/asteroid/proc/gets_dug()
	if ((src.seedName != "") && (src.seedAmt > 0) && (src.seedAmt < 11))
		var/i
		for (i=0;i<seedAmt;i++)
			if (src.seedName == "1")
				new /obj/item/seeds/alien/alien1(src)
			if (src.seedName == "2")
				new /obj/item/seeds/alien/alien2(src)
			if (src.seedName == "3")
				new /obj/item/seeds/alien/alien3(src)
			if (src.seedName == "4")
				new /obj/item/seeds/alien/alien4(src)
		seedName = ""
		seedAmt = 0
	return

/turf/simulated/floor/airless/asteroid/proc/updateMineralOverlays()

	src.overlays = null

	if(istype(get_step(src, NORTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_n")
	if(istype(get_step(src, SOUTH), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_s", layer=6)
	if(istype(get_step(src, EAST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_e", layer=6)
	if(istype(get_step(src, WEST), /turf/simulated/mineral))
		src.overlays += image('walls.dmi', "rock_side_w", layer=6)


/turf/simulated/floor/airless/asteroid/proc/fullUpdateMineralOverlays()
	var/turf/simulated/floor/airless/asteroid/A
	if(istype(get_step(src, WEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, WEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, EAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, EAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTH), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTH)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHWEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, NORTHEAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, NORTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHWEST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTHWEST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTHEAST), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTHEAST)
		A.updateMineralOverlays()
	if(istype(get_step(src, SOUTH), /turf/simulated/floor/airless/asteroid))
		A = get_step(src, SOUTH)
		A.updateMineralOverlays()
	src.updateMineralOverlays()

/**********************Mineral ores**************************/

/obj/item/weapon/ore
	name = "Rock"
	icon = 'Mining.dmi'
	icon_state = "ore"

/obj/item/weapon/ore/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/satchel))
		var/obj/item/weapon/satchel/S = W
		if (S.mode == 1)
			for (var/obj/item/weapon/ore/O in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += O;
				else
					user << "\blue The satchel is full."
					break
			user << "\blue You pick up all the ores."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The satchel is full."
	return

/obj/item/weapon/ore/uranium
	name = "Uranium ore"
	icon = 'Mining.dmi'
	icon_state = "Uranium ore"

/obj/item/weapon/ore/iron
	name = "Iron ore"
	icon = 'Mining.dmi'
	icon_state = "Iron ore"

/obj/item/weapon/ore/plasma
	name = "Plasma ore"
	icon = 'Mining.dmi'
	icon_state = "Plasma ore"

/obj/item/weapon/ore/silver
	name = "Silver ore"
	icon = 'Mining.dmi'
	icon_state = "Silver ore"

/obj/item/weapon/ore/gold
	name = "Gold ore"
	icon = 'Mining.dmi'
	icon_state = "Gold ore"

/obj/item/weapon/ore/diamond
	name = "Diamond ore"
	icon = 'Mining.dmi'
	icon_state = "Diamond ore"

/obj/item/weapon/ore/clown
	name = "Bananium ore"
	icon = 'Mining.dmi'
	icon_state = "Clown ore"

/obj/item/weapon/ore/slag
	name = "Slag"
	desc = "Completely useless"
	icon = 'Mining.dmi'
	icon_state = "slag"

/obj/item/weapon/ore/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/**********************Ore pile (not used)**************************/

/obj/item/weapon/ore_pile
	name = "Pile of ores"
	icon = 'Mining.dmi'
	icon_state = "orepile"

/**********************Satchel**************************/

/obj/item/weapon/satchel
	icon = 'mining.dmi'
	icon_state = "satchel"
	name = "Mining Satchel"
	var/mode = 0;  //0 = pick one at a time, 1 = pick all on tile
	var/capacity = 50; //the number of ore pieces it can carry.

/obj/item/weapon/satchel/attack_self(mob/user as mob)
	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = user.loc
	user << "\blue You empty the satchel."
	return

/obj/item/weapon/satchel/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		var/obj/item/weapon/ore/O = W
		src.contents += O;
	return

/obj/item/weapon/satchel/verb/all_on_tile()
	mode = 1
	return

/obj/item/weapon/satchel/verb/one_at_a_time()
	mode = 0
	return

/**********************Ore box**************************/

/obj/ore_box
	icon = 'mining.dmi'
	icon_state = "orebox"
	name = "A box of ores"
	desc = "It's heavy"
	density = 1

/obj/ore_box/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/ore))
		src.contents += W;
	if (istype(W, /obj/item/weapon/satchel))
		src.contents += W.contents
		user << "\blue You empty the satchel into the box."
	return

/obj/ore_box/attack_hand(obj, mob/user as mob)
	for (var/obj/item/weapon/ore/O in contents)
		contents -= O
		O.loc = src.loc
	user << "\blue You empty the box"
	return

/**********************Alien Seeds**************************/

/obj/item/seeds/alien/alien1
	name = "Space Fungus seed"
	desc = "The seed to the most abundant and annoying weed in the galaxy"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien1"

/obj/item/seeds/alien/alien2
	name = "Asynchronous Catitius seed"
	desc = "This seed was only recently discovered and has not been studied properly yet."
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien2"

/obj/item/seeds/alien/alien3
	name = "Previously undiscovered seed"
	desc = "This appears to be a new type of seed"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien3"

/obj/item/seeds/alien/alien4
	name = "Donot plant seed"
	desc = "Is the X a warning?"
	icon = 'Hydroponics.dmi'
	icon_state = "seed-alien4"

/**********************Artifacts**************************/

/obj/machinery/artifact/artifact1
	name = "Alien artifact 1"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact2
	name = "Alien artifact 2"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact3
	name = "Alien artifact 3"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/obj/machinery/artifact/artifact4
	name = "Alien artifact 4"
	desc = "This odd artifact is something from an alien civilization. I wonder what it does"
	icon = 'Items.dmi'
	icon_state = "strangepresent"

/**********************Input and output plates**************************/

/obj/machinery/mineral/input
	icon = 'craft.dmi'
	icon_state = "core"
	name = "Input area"
	density = 0
	anchored = 1.0

/obj/machinery/mineral/output
	icon = 'craft.dmi'
	icon_state = "core"
	name = "Output area"
	density = 0
	anchored = 1.0


/**********************Mineral purifier (not used, replaced with mineral processing unit)**************************/

/obj/machinery/mineral/purifier
	name = "Ore Purifier"
	desc = "A machine which makes building material out of ores"
	icon = 'computer.dmi'
	icon_state = "aiupload"
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/processed = 0
	var/processing = 0
	density = 1
	anchored = 1.0

/obj/machinery/mineral/purifier/attack_hand(user as mob)

	if(processing == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><A href='?src=\ref[src];purify=[input]'>Purify</A>")

	dat += text("<br><br>found: <font color='green'><b>[processed]</b></font>")
	user << browse("[dat]", "window=purifier")

/obj/machinery/mineral/purifier/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["purify"])
		if (src.output)
			processing = 1;
			var/obj/item/weapon/ore/O
			processed = 0;
			while(locate(/obj/item/weapon/ore, input.loc))
				O = locate(/obj/item/weapon/ore, input.loc)
				if (istype(O,/obj/item/weapon/ore/iron))
					new /obj/item/stack/sheet/metal(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/diamond))
					new /obj/item/stack/sheet/diamond(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/plasma))
					new /obj/item/stack/sheet/plasma(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/gold))
					new /obj/item/stack/sheet/gold(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/silver))
					new /obj/item/stack/sheet/silver(output.loc)
					del(O)
				if (istype(O,/obj/item/weapon/ore/uranium))
					new /obj/item/weapon/ore/uranium(output.loc)
					del(O)
				processed++
				sleep(5);
			processing = 0;
	src.updateUsrDialog()
	return


/obj/machinery/mineral/purifier/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, WEST))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, EAST))
		return
	return

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "Produciton machine console"
	icon = 'terminals.dmi'
	icon_state = "production_console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/processing_unit/machine = null

/obj/machinery/mineral/processing_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, EAST))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/processing_unit_console/attack_hand(user as mob)

	var/dat = "<b>Smelter control console</b><br><br>"
	//iron
	if (machine.selected_iron==1)
		dat += text("<A href='?src=\ref[src];sel_iron=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_iron=yes'><font color='red'>N</font></A> ")
	dat += text("Iron: [machine.ore_iron]<br>")

	//plasma
	if (machine.selected_plasma==1)
		dat += text("<A href='?src=\ref[src];sel_plasma=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_plasma=yes'><font color='red'>N</font></A> ")
	dat += text("Plasma: [machine.ore_plasma]<br>")

	//uranium
	if (machine.selected_uranium==1)
		dat += text("<A href='?src=\ref[src];sel_uranium=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_uranium=yes'><font color='red'>N</font></A> ")
	dat += text("Uranium: [machine.ore_uranium]<br>")

	//gold
	if (machine.selected_gold==1)
		dat += text("<A href='?src=\ref[src];sel_gold=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_gold=yes'><font color='red'>N</font></A> ")
	dat += text("Gold: [machine.ore_gold]<br>")

	//silver
	if (machine.selected_silver==1)
		dat += text("<A href='?src=\ref[src];sel_silver=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_silver=yes'><font color='red'>N</font></A> ")
	dat += text("Silver: [machine.ore_silver]<br>")

	//diamond
	if (machine.selected_diamond==1)
		dat += text("<A href='?src=\ref[src];sel_diamond=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_diamond=yes'><font color='red'>N</font></A> ")
	dat += text("Diamond: [machine.ore_diamond]<br>")

	//bananium
	if (machine.selected_clown==1)
		dat += text("<A href='?src=\ref[src];sel_clown=no'><font color='green'>Y</font></A> ")
	else
		dat += text("<A href='?src=\ref[src];sel_clown=yes'><font color='red'>N</font></A> ")
	dat += text("Bananium: [machine.ore_clown]<br>")

	//On or off
	dat += text("Machine is currently ")
	if (machine.on==1)
		dat += text("<A href='?src=\ref[src];set_on=off'>On</A> ")
	else
		dat += text("<A href='?src=\ref[src];set_on=on'>Off</A> ")



	user << browse("[dat]", "window=console_processing_unit")



/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["sel_iron"])
		if (href_list["sel_iron"] == "yes")
			machine.selected_iron = 1
		else
			machine.selected_iron = 0
	if(href_list["sel_plasma"])
		if (href_list["sel_plasma"] == "yes")
			machine.selected_plasma = 1
		else
			machine.selected_plasma = 0
	if(href_list["sel_uranium"])
		if (href_list["sel_uranium"] == "yes")
			machine.selected_uranium = 1
		else
			machine.selected_uranium = 0
	if(href_list["sel_gold"])
		if (href_list["sel_gold"] == "yes")
			machine.selected_gold = 1
		else
			machine.selected_gold = 0
	if(href_list["sel_silver"])
		if (href_list["sel_silver"] == "yes")
			machine.selected_silver = 1
		else
			machine.selected_silver = 0
	if(href_list["sel_diamond"])
		if (href_list["sel_diamond"] == "yes")
			machine.selected_diamond = 1
		else
			machine.selected_diamond = 0
	if(href_list["sel_clown"])
		if (href_list["sel_clown"] == "yes")
			machine.selected_clown = 1
		else
			machine.selected_clown = 0
	if(href_list["set_on"])
		if (href_list["set_on"] == "on")
			machine.on = 1
		else
			machine.on = 0
	src.updateUsrDialog()
	return

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "Furnace"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/CONSOLE = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_plasma = 0;
	var/ore_uranium = 0;
	var/ore_iron = 0;
	var/ore_clown = 0;
	var/selected_gold = 0
	var/selected_silver = 0
	var/selected_diamond = 0
	var/selected_plasma = 0
	var/selected_uranium = 0
	var/selected_iron = 0
	var/selected_clown = 0
	var/on = 0 //0 = off, 1 =... oh you know!

/obj/machinery/mineral/processing_unit/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/processing_unit/process()
	if (src.output && src.input)
		var/i
		for (i = 0; i < 10; i++)
			if (on)
				if (selected_gold == 1 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_gold > 0)
						ore_gold--;
						new /obj/item/stack/sheet/gold(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 1 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_silver > 0)
						ore_silver--;
						new /obj/item/stack/sheet/silver(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 1 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_diamond > 0)
						ore_diamond--;
						new /obj/item/stack/sheet/diamond(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 1 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 0)
					if (ore_plasma > 0)
						ore_plasma--;
						new /obj/item/stack/sheet/plasma(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 1 && selected_iron == 0 && selected_clown == 0)
					if (ore_uranium > 0)
						ore_uranium--;
						new /obj/item/weapon/ore/uranium(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0)
					if (ore_iron > 0)
						ore_iron--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue
				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 1 && selected_clown == 0)
					if (ore_iron > 0)
						ore_iron--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue

				if (selected_gold == 0 && selected_silver == 0 && selected_diamond == 0 && selected_plasma == 0 && selected_uranium == 0 && selected_iron == 0 && selected_clown == 1)
					if (ore_clown > 0)
						ore_clown--;
						new /obj/item/stack/sheet/metal(output.loc)
					else
						on = 0
					continue


				//if a non valid combination is selected

				var/b = 1 //this part checks if all required ores are available

				if (!(selected_gold || selected_silver ||selected_diamond || selected_uranium | selected_plasma || selected_iron))
					b = 0

				if (selected_gold == 1)
					if (ore_gold <= 0)
						b = 0
				if (selected_silver == 1)
					if (ore_silver <= 0)
						b = 0
				if (selected_diamond == 1)
					if (ore_diamond <= 0)
						b = 0
				if (selected_uranium == 1)
					if (ore_uranium <= 0)
						b = 0
				if (selected_plasma == 1)
					if (ore_plasma <= 0)
						b = 0
				if (selected_iron == 1)
					if (ore_iron <= 0)
						b = 0

				if (selected_clown == 1)
					if (ore_clown <= 0)
						b = 0

				if (b) //if they are, deduct one from each, produce slag and shut the machine off
					if (selected_gold == 1)
						ore_gold--
					if (selected_silver == 1)
						ore_silver--
					if (selected_diamond == 1)
						ore_diamond--
					if (selected_uranium == 1)
						ore_uranium--
					if (selected_plasma == 1)
						ore_plasma--
					if (selected_iron == 1)
						ore_iron--
					if (selected_clown == 1)
						ore_clown--
					new /obj/item/weapon/ore/slag(output.loc)
					on = 0
				else
					on = 0
					break
				break
			else
				break
		for (i = 0; i < 10; i++)
			var/obj/item/O
			O = locate(/obj/item, input.loc)
			if (O)
				if (istype(O,/obj/item/weapon/ore/iron))
					ore_iron++;
					//new /obj/item/stack/sheet/metal(output.loc)
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/diamond))
					ore_diamond++;
					//new /obj/item/stack/sheet/diamond(output.loc)
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/plasma))
					ore_plasma++
					//new /obj/item/stack/sheet/plasma(output.loc)
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/gold))
					ore_gold++
					//new /obj/item/stack/sheet/gold(output.loc)
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/silver))
					ore_silver++
					//new /obj/item/stack/sheet/silver(output.loc)
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/uranium))
					ore_uranium++
					del(O)
					continue
				if (istype(O,/obj/item/weapon/ore/clown))
					ore_clown++
					del(O)
					continue
				O.loc = src.output.loc
			else
				break
	return



/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "Stacking machine console"
	icon = 'terminals.dmi'
	icon_state = "production_console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/machine = null

/obj/machinery/mineral/stacking_unit_console/New()
	..()
	spawn(7)
		src.machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, SOUTHEAST))
		if (machine)
			machine.CONSOLE = src
		else
			del(src)

/obj/machinery/mineral/stacking_unit_console/attack_hand(user as mob)

	var/dat

	dat += text("<b>Stacking unit console</b><br><br>")

	dat += text("Iron: [machine.ore_iron] <A href='?src=\ref[src];release=iron'>Release</A><br>")
	dat += text("Plasma: [machine.ore_plasma] <A href='?src=\ref[src];release=plasma'>Release</A><br>")
	dat += text("Gold: [machine.ore_gold] <A href='?src=\ref[src];release=gold'>Release</A><br>")
	dat += text("Silver: [machine.ore_silver] <A href='?src=\ref[src];release=silver'>Release</A><br>")
	dat += text("Damond: [machine.ore_diamond] <A href='?src=\ref[src];release=diamond'>Release</A><br><br>")
	dat += text("Bananium: [machine.ore_clown] <A href='?src=\ref[src];release=clown'>Release</A><br><br>")

	dat += text("Stacking: [machine.stack_amt]<br><br>")

	user << browse("[dat]", "window=console_stacking_machine")

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["release"])
		switch(href_list["release"])
			if ("plasma")
				if (machine.ore_plasma > 0)
					var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
					G.amount = machine.ore_plasma
					G.loc = machine.output.loc
					machine.ore_plasma = 0
			if ("gold")
				if (machine.ore_gold > 0)
					var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
					G.amount = machine.ore_gold
					G.loc = machine.output.loc
					machine.ore_gold = 0
			if ("silver")
				if (machine.ore_silver > 0)
					var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
					G.amount = machine.ore_silver
					G.loc = machine.output.loc
					machine.ore_silver = 0
			if ("diamond")
				if (machine.ore_diamond > 0)
					var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
					G.amount = machine.ore_diamond
					G.loc = machine.output.loc
					machine.ore_diamond = 0
			if ("iron")
				if (machine.ore_iron > 0)
					var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
					G.amount = machine.ore_iron
					G.loc = machine.output.loc
					machine.ore_iron = 0
			if ("clown")
				if (machine.ore_clown > 0)
					var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
					G.amount = machine.ore_clown
					G.loc = machine.output.loc
					machine.ore_iron = 0
	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "Stacking machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/stacking_unit_console/CONSOLE
	var/stk_types = list()
	var/stk_amt   = list()
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/ore_gold = 0;
	var/ore_silver = 0;
	var/ore_diamond = 0;
	var/ore_plasma = 0;
	var/ore_iron = 0;
	var/ore_clown = 0;
	var/stack_amt = 50; //ammount to stack before releassing

/obj/machinery/mineral/stacking_machine/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, EAST))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, WEST))
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/obj/item/O
		while (locate(/obj/item, input.loc))
			O = locate(/obj/item, input.loc)
			if (istype(O,/obj/item/stack/sheet/metal))
				ore_iron++;
				//new /obj/item/stack/sheet/metal(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/diamond))
				ore_diamond++;
				//new /obj/item/stack/sheet/diamond(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/plasma))
				ore_plasma++
				//new /obj/item/stack/sheet/plasma(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/gold))
				ore_gold++
				//new /obj/item/stack/sheet/gold(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/silver))
				ore_silver++
				//new /obj/item/stack/sheet/silver(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/stack/sheet/clown))
				ore_clown++
				//new /obj/item/stack/sheet/silver(output.loc)
				del(O)
				continue
			if (istype(O,/obj/item/weapon/ore/slag))
				del(O)
				continue
			O.loc = src.output.loc
	if (ore_gold >= stack_amt)
		var/obj/item/stack/sheet/gold/G = new /obj/item/stack/sheet/gold
		G.amount = stack_amt
		G.loc = output.loc
		ore_gold -= stack_amt
		return
	if (ore_silver >= stack_amt)
		var/obj/item/stack/sheet/silver/G = new /obj/item/stack/sheet/silver
		G.amount = stack_amt
		G.loc = output.loc
		ore_silver -= stack_amt
		return
	if (ore_diamond >= stack_amt)
		var/obj/item/stack/sheet/diamond/G = new /obj/item/stack/sheet/diamond
		G.amount = stack_amt
		G.loc = output.loc
		ore_diamond -= stack_amt
		return
	if (ore_plasma >= stack_amt)
		var/obj/item/stack/sheet/plasma/G = new /obj/item/stack/sheet/plasma
		G.amount = stack_amt
		G.loc = output.loc
		ore_plasma -= stack_amt
		return
	if (ore_iron >= stack_amt)
		var/obj/item/stack/sheet/metal/G = new /obj/item/stack/sheet/metal
		G.amount = stack_amt
		G.loc = output.loc
		ore_iron -= stack_amt
		return
	if (ore_clown >= stack_amt)
		var/obj/item/stack/sheet/clown/G = new /obj/item/stack/sheet/clown
		G.amount = stack_amt
		G.loc = output.loc
		ore_clown -= stack_amt
		return
	return


/**********************Unloading unit**************************/


/obj/machinery/mineral/unloading_machine
	name = "Unloading machine"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null


/obj/machinery/mineral/unloading_machine/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, SOUTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, NORTH))
		processing_items.Add(src)
		return
	return

/obj/machinery/mineral/unloading_machine/process()
	if (src.output && src.input)
		if (locate(/obj/ore_box, input.loc))
			var/obj/ore_box/BOX = locate(/obj/ore_box, input.loc)
			var/i = 0
			for (var/obj/item/weapon/ore/O in BOX.contents)
				BOX.contents -= O
				O.loc = output.loc
				i++
				if (i>=10)
					return
		if (locate(/obj/item, input.loc))
			var/obj/item/O
			var/i
			for (i = 0; i<10; i++)
				O = locate(/obj/item, input.loc)
				if (O)
					O.loc = src.output.loc
				else
					return
	return


/**********************Mint**************************/


/obj/machinery/mineral/mint
	name = "Coin press"
	icon = 'stationobjs.dmi'
	icon_state = "controller"
	density = 1
	anchored = 1.0
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/amt_silver = 0 //amount of silver
	var/amt_gold = 0   //amount of gold
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	//var/amt_uranium = 0
	var/amt_clown = 0
	var/newCoins = 0   //how many coins the machine made in it's last load
	var/processing = 0
	var/chosen = "metal" //which material will be used to make coins
	var/coinsToProduce = 10


/obj/machinery/mineral/mint/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		processing_items.Add(src)
		return
	return


/obj/machinery/mineral/mint/process()
	if ( src.input)
		var/obj/item/stack/sheet/O
		O = locate(/obj/item/stack/sheet, input.loc)
		if(O)
			if (istype(O,/obj/item/stack/sheet/gold))
				amt_gold += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/silver))
				amt_silver += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/diamond))
				amt_diamond += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/plasma))
				amt_plasma += 100 * O.amount
				del(O)
			/*if (istype(O,/obj/item/weapon/ore/uranium))
				amt_uranium += 100
				del(O)*/
			if (istype(O,/obj/item/stack/sheet/metal))
				amt_iron += 100 * O.amount
				del(O)
			if (istype(O,/obj/item/stack/sheet/clown))
				amt_clown += 100 * O.amount
				del(O)


/obj/machinery/mineral/mint/attack_hand(user as mob)

	var/dat = "<b>Coin Press</b><br>"

	if (!input)
		dat += text("input connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")
	if (!output)
		dat += text("<br>output connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")

	dat += text("<br><font color='#ffcc00'><b>Gold inserterd: </b>[amt_gold]</font> ")
	if (chosen == "gold")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=gold'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Silver inserterd: </b>[amt_silver]</font> ")
	if (chosen == "silver")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=silver'>Choose</A>")
	dat += text("<br><font color='#555555'><b>Iron inserterd: </b>[amt_iron]</font> ")
	if (chosen == "metal")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=metal'>Choose</A>")
	dat += text("<br><font color='#8888FF'><b>Diamond inserterd: </b>[amt_diamond]</font> ")
	if (chosen == "diamond")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=diamond'>Choose</A>")
	dat += text("<br><font color='#FF8800'><b>Plasma inserterd: </b>[amt_plasma]</font> ")
	if (chosen == "plasma")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=plasma'>Choose</A>")
	/*dat += text("<br><font color='#008800'><b>uranium inserterd: </b>[amt_uranium]</font> ")
	if (chosen == "uranium")
		dat += text("chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=uranium'>Choose</A>")*/
	if(amt_clown > 0)
		dat += text("<br><font color='#AAAA00'><b>Bananium inserterd: </b>[amt_clown]</font> ")
		if (chosen == "clown")
			dat += text("chosen")
		else
			dat += text("<A href='?src=\ref[src];choose=clown'>Choose</A>")

	dat += text("<br><br>Will produce [coinsToProduce] [chosen] coins if enough materials are available.<br>")
	dat += text("The dial which controls the number of conins to produce seems to be stuck. A technician has already been dispatched to fix this.")
	/*dat += text("<A href='?src=\ref[src];chooseAmt=[-10]'>-10</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=[-5]'>-5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=[-1]'>-1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=[1]'>+1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=[5]'>+5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=[10]'>+10</A> ")*/

	dat += text("<br><br>In total this machine produced <font color='green'><b>[newCoins]</b></font> coins.")
	dat += text("<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")
	user << browse("[dat]", "window=mint")

/obj/machinery/mineral/mint/Topic(href, href_list)
	if(..())
		return
	if(processing==1)
		usr << "\blue The machine is processing."
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["choose"])
		chosen = href_list["choose"]
	if(href_list["chooseamt"])
		coinsToProduce += href_list["chooseamt"]
	if(href_list["makeCoins"])
		if (src.output)
			processing = 1;
			var/obj/item/weapon/moneybag/M
			switch(chosen)
				if("metal")
					while(amt_iron > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new/obj/item/weapon/coin/iron(M)
						amt_iron -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("gold")
					while(amt_gold > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/gold(M)
						amt_gold -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("silver")
					while(amt_silver > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/silver(M)
						amt_silver -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("diamond")
					while(amt_diamond > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/diamond(M)
						amt_diamond -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				if("plasma")
					while(amt_plasma > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/plasma(M)
						amt_plasma -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
				/*if("uranium")
					while(amt_uranium > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/uranium(M)
						amt_uranium -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5)*/
				if("clown")
					while(amt_clown > 0 && coinsToProduce > 0)
						if (locate(/obj/item/weapon/moneybag,output.loc))
							M = locate(/obj/item/weapon/moneybag,output.loc)
						else
							M = new/obj/item/weapon/moneybag(output.loc)
						new /obj/item/weapon/coin/clown(M)
						amt_clown -= 20
						coinsToProduce--
						newCoins++
						src.updateUsrDialog()
						sleep(5);
			processing = 0;
	coinsToProduce = 10;
	src.updateUsrDialog()
	return


/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/coin/gold
	name = "Gold coin"
	icon_state = "coin_gold"

/obj/item/weapon/coin/silver
	name = "Silver coin"
	icon_state = "coin_silver"

/obj/item/weapon/coin/diamond
	name = "Diamond coin"
	icon_state = "coin_diamond"

/obj/item/weapon/coin/iron
	name = "Iron coin"
	icon_state = "coin_iron"

/obj/item/weapon/coin/plasma
	name = "Solid plasma coin"
	icon_state = "coin_plasma"

/obj/item/weapon/coin/uranium
	name = "Uranium coin"
	icon_state = "coin_uranium"

/obj/item/weapon/coin/clown
	name = "Bananaium coin"
	icon_state = "coin_clown"

/*****************************Money bag********************************/

/obj/item/weapon/moneybag
	icon = 'storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 2.0
	w_class = 4.0

/obj/item/weapon/moneybag/attack_hand(user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0

	for (var/obj/item/weapon/coin/C in contents)
		if (istype(C,/obj/item/weapon/coin/diamond))
			amt_diamond++;
		if (istype(C,/obj/item/weapon/coin/plasma))
			amt_plasma++;
		if (istype(C,/obj/item/weapon/coin/iron))
			amt_iron++;
		if (istype(C,/obj/item/weapon/coin/silver))
			amt_silver++;
		if (istype(C,/obj/item/weapon/coin/gold))
			amt_gold++;
		if (istype(C,/obj/item/weapon/coin/uranium))
			amt_uranium++;
		if (istype(C,/obj/item/weapon/coin/clown))
			amt_clown++;

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if (amt_gold)
		dat += text("Gold coins: [amt_gold]<br>")
	if (amt_silver)
		dat += text("Silver coins: [amt_silver]<br>")
	if (amt_iron)
		dat += text("Metal coins: [amt_iron]<br>")
	if (amt_diamond)
		dat += text("Diamond coins: [amt_diamond]<br>")
	if (amt_plasma)
		dat += text("Plasma coins: [amt_plasma]<br>")
	if (amt_uranium)
		dat += text("Uranium coins: [amt_uranium]<br>")
	if (amt_clown)
		dat += text("Bananium coins: [amt_clown]<br>")
	if (amt_clown)
		dat += text("<br>Strangely you can only view the bag's contents. There is no way to remove them.")
	user << browse("[dat]", "window=moneybag")

/obj/item/weapon/moneybag/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/coin))
		var/obj/item/weapon/coin/C = W
		user << "\blue You add the [C.name] into the bag."
		contents += C
	if (istype(W, /obj/item/weapon/moneybag))
		var/obj/item/weapon/moneybag/C = W
		for (var/obj/O in C.contents)
			contents += O;
		user << "\blue You empty the [C.name] into the bag."
	return

/**********************Gas extractor**************************/

/obj/machinery/mineral/gasextractor
	name = "Gas extractor"
	desc = "A machine which extracts gasses from ores"
	icon = 'computer.dmi'
	icon_state = "aiupload"
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/message = "";
	var/processing = 0
	var/newtoxins = 0
	density = 1
	anchored = 1.0

/obj/machinery/mineral/gasextractor/New()
	..()
	spawn( 5 )
		src.input = locate(/obj/machinery/mineral/input, get_step(src, NORTH))
		src.output = locate(/obj/machinery/mineral/output, get_step(src, SOUTH))
		return
	return

/obj/machinery/mineral/gasextractor/attack_hand(user as mob)

	if(processing == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("input connection status: ")
	if (input)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")
	dat += text("<br>output connection status: ")
	if (output)
		dat += text("<b><font color='green'>CONNECTED</font></b>")
	else
		dat += text("<b><font color='red'>NOT CONNECTED</font></b>")

	dat += text("<br><br><A href='?src=\ref[src];extract=[input]'>Extract gas</A>")

	dat += text("<br><br>Message: [message]")

	user << browse("[dat]", "window=purifier")

/obj/machinery/mineral/gasextractor/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["extract"])
		if (src.output)
			if (locate(/obj/machinery/portable_atmospherics/canister,output.loc))
				newtoxins = 0
				processing = 1
				var/obj/item/weapon/ore/O
				while(locate(/obj/item/weapon/ore/plasma, input.loc) && locate(/obj/machinery/portable_atmospherics/canister,output.loc))
					O = locate(/obj/item/weapon/ore/plasma, input.loc)
					if (istype(O,/obj/item/weapon/ore/plasma))
						var/obj/machinery/portable_atmospherics/canister/C
						C = locate(/obj/machinery/portable_atmospherics/canister,output.loc)
						C.air_contents.toxins += 100
						newtoxins += 100
						del(O)
					sleep(5);
				processing = 0;
				message = "Canister filled with [newtoxins] units of toxins"
			else
				message = "No canister found"
	src.updateUsrDialog()
	return

/******************************Lantern*******************************/

/obj/item/device/flashlight/lantern
	name = "Mining Lantern"
	icon = 'lighting.dmi'
	icon_state = "lantern-off"
	desc = "A miner's lantern"
	anchored = 0
	var/brightness = 12			// luminosity when on

/obj/item/device/flashlight/lantern/New()
	luminosity = 0
	on = 0
	return

/obj/item/device/flashlight/lantern/attack_self(mob/user)
	..()
	if (on == 1)
		icon_state = "lantern-on"
	else
		icon_state = "lantern-off"


/*****************************Pickaxe********************************/

/obj/item/weapon/pickaxe
	name = "Miner's pickaxe"
	icon = 'items.dmi'
	icon_state = "pickaxe"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 15.0
	throwforce = 4.0
	item_state = "wrench"
	w_class = 4.0
	m_amt = 50

/*****************************Shovel********************************/

/obj/item/weapon/shovel
	name = "Shovel"
	icon = 'items.dmi'
	icon_state = "shovel"
	flags = FPRINT | TABLEPASS| CONDUCT | ONBELT
	force = 8.0
	throwforce = 4.0
	item_state = "wrench"
	w_class = 4.0
	m_amt = 50


/******************************Materials****************************/

/obj/item/stack/sheet/gold
	name = "gold"
	icon_state = "sheet-gold"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/gold/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/silver
	name = "silver"
	icon_state = "sheet-silver"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/silver/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/diamond/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4

/obj/item/stack/sheet/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/clown
	name = "bananium"
	icon_state = "sheet-clown"
	force = 5.0
	g_amt = 3750
	throwforce = 5
	w_class = 3.0
	throw_speed = 3
	throw_range = 3

/obj/item/stack/sheet/diamond/New()
	pixel_x = rand(0,4)-4
	pixel_y = rand(0,4)-4


/**********************Rail track**************************/

/obj/machinery/rail_track
	name = "Rail track"
	icon = 'Mining.dmi'
	icon_state = "rail"
	dir = 2
	var/id = null    //this is needed for switches to work Set to the same on the whole length of the track
	anchored = 1

/**********************Rail intersection**************************/

/obj/machinery/rail_track/intersections
	name = "Rail track intersection"
	icon_state = "rail_intersection"

/obj/machinery/rail_track/intersections/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (5) dir = 4
		if (4) dir = 9
		if (9) dir = 2
		if (2) dir = 10
		if (10) dir = 8
		if (8) dir = 6
		if (6) dir = 1
	return

/obj/machinery/rail_track/intersections/NSE
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSE"
	dir = 2

/obj/machinery/rail_track/intersections/NSE/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 5
		if (2) dir = 5
		if (5) dir = 9
		if (9) dir = 2
	return

/obj/machinery/rail_track/intersections/SEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_SEW"
	dir = 8

/obj/machinery/rail_track/intersections/SEW/attack_hand(user as mob)
	switch (dir)
		if (8) dir = 6
		if (4) dir = 6
		if (6) dir = 5
		if (5) dir = 8
	return

/obj/machinery/rail_track/intersections/NSW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NSW"
	dir = 2

/obj/machinery/rail_track/intersections/NSW/attack_hand(user as mob)
	switch (dir)
		if (1) dir = 10
		if (2) dir = 10
		if (10) dir = 6
		if (6) dir = 2
	return

/obj/machinery/rail_track/intersections/NEW
	name = "Rail track T intersection"
	icon_state = "rail_intersection_NEW"
	dir = 8

/obj/machinery/rail_track/intersections/NEW/attack_hand(user as mob)
	switch (dir)
		if (4) dir = 9
		if (8) dir = 9
		if (9) dir = 10
		if (10) dir = 8
	return

/**********************Rail switch**************************/

/obj/machinery/rail_switch
	name = "Rail switch"
	icon = 'Mining.dmi'
	icon_state = "rail"
	dir = 2
	icon = 'recycling.dmi'
	icon_state = "switch-off"
	var/obj/machinery/rail_track/track = null
	var/id            //used for to change the track pieces

/obj/machinery/rail_switch/New()
	spawn(10)
		src.track = locate(/obj/machinery/rail_track, get_step(src, NORTH))
		if(track)
			id = track.id
	return

/obj/machinery/rail_switch/attack_hand(user as mob)
	user << "You switch the rail track's direction"
	for (var/obj/machinery/rail_track/T in world)
		if (T.id == src.id)
			var/obj/machinery/rail_car/C = locate(/obj/machinery/rail_car, T.loc)
			if (C)
				switch (T.dir)
					if(1)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(2)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "N"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(4)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(8)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "W"
							if("W") C.direction = "E"
					if(5)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "E"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(6)
						switch(C.direction)
							if("N") C.direction = "S"
							if("S") C.direction = "W"
							if("E") C.direction = "S"
							if("W") C.direction = "S"
					if(9)
						switch(C.direction)
							if("N") C.direction = "E"
							if("S") C.direction = "E"
							if("E") C.direction = "N"
							if("W") C.direction = "E"
					if(10)
						switch(C.direction)
							if("N") C.direction = "W"
							if("S") C.direction = "W"
							if("E") C.direction = "W"
							if("W") C.direction = "N"
	return


/**********************Mining car (Crate like thing, not the rail car)**************************/

/obj/crate/miningcar
	desc = "A mining car. This one doesn't work on rails, but has to be dragged."
	name = "Mining car (not for rails)"
	icon = 'storage.dmi'
	icon_state = "miningcar"
	density = 1
	openicon = "miningcaropen"
	closedicon = "miningcar"

/**********************Rail car**************************/

/obj/machinery/rail_car
	name = "Rail car"
	icon = 'Storage.dmi'
	icon_state = "miningcar"
	var/direction = "S"  //S = south, N = north, E = east, W = west. Determines whichw ay it'll look first
	var/moving = 0;
	anchored = 1
	density = 1
	var/speed = 0
	var/slowing = 0
	var/atom/movable/load = null //what it's carrying

/obj/machinery/rail_car/attack_hand(user as mob)
	if (moving == 0)
		processing_items.Add(src)
		moving = 1
	else
		processing_items.Remove(src)
		moving = 0
	return

/*
for (var/client/C)
	C << "Dela."
*/

/obj/machinery/rail_car/MouseDrop_T(var/atom/movable/C, mob/user)

	if(user.stat)
		return

	if (!istype(C) || C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return

	if(ismob(C))
		load(C)


/obj/machinery/rail_car/proc/load(var/atom/movable/C)

	if(get_dist(C, src) > 1)
		return
	//mode = 1

	C.loc = src.loc
	sleep(2)
	C.loc = src
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	overlays += C

	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

	//mode = 0
	//send_status()

/obj/machinery/rail_car/proc/unload(var/dirn = 0)
	if(!load)
		return

	overlays = null

	load.loc = src.loc
	load.pixel_y -= 9
	load.layer = initial(load.layer)
	if(ismob(load))
		var/mob/M = load
		if(M.client)
			M.client.perspective = MOB_PERSPECTIVE
			M.client.eye = src


	if(dirn)
		step(load, dirn)

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		AM.loc = src.loc
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src

/obj/machinery/rail_car/relaymove(var/mob/user)
	if(user.stat)
		return
	if(load == user)
		unload(0)
	return

/obj/machinery/rail_car/process()
	if (moving == 1)
		if (slowing == 1)
			if (speed > 0)
				speed--;
				if (speed == 0)
					slowing = 0
		else
			if (speed < 10)
				speed++;
		var/i = 0
		for (i = 0; i < speed; i++)
			if (moving == 1)
				switch (direction)
					if ("S")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y-1,src.z))
							if (R.dir == 10)
								direction = "W"
							if (R.dir == 9)
								direction = "E"
							if (R.dir == 2 || R.dir == 1 || R.dir == 10 || R.dir == 9)
								for (var/mob/living/M in locate(src.x,src.y-1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("N")
						for (var/obj/machinery/rail_track/R in locate(src.x,src.y+1,src.z))
							if (R.dir == 5)
								direction = "E"
							if (R.dir == 6)
								direction = "W"
							if (R.dir == 5 || R.dir == 1 || R.dir == 6 || R.dir == 2)
								for (var/mob/living/M in locate(src.x,src.y+1,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("E")
						for (var/obj/machinery/rail_track/R in locate(src.x+1,src.y,src.z))
							if (R.dir == 6)
								direction = "S"
							if (R.dir == 10)
								direction = "N"
							if (R.dir == 4 || R.dir == 8 || R.dir == 10 || R.dir == 6)
								for (var/mob/living/M in locate(src.x+1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
					if ("W")
						for (var/obj/machinery/rail_track/R in locate(src.x-1,src.y,src.z))
							if (R.dir == 9)
								direction = "N"
							if (R.dir == 5)
								direction = "S"
							if (R.dir == 8 || R.dir == 9 || R.dir == 5 || R.dir == 4)
								for (var/mob/living/M in locate(src.x-1,src.y,src.z))
									step(M,get_dir(src,R))
								step(src,get_dir(src,R))
								break
							else
								moving = 0
								speed = 0
				sleep(1)
	else
		processing_items.Remove(src)
		moving = 0
	return


/**********************Spaceship builder area definitions**************************/

/area/shipbuilder
	requires_power = 0
	luminosity = 1
	sd_lighting = 0

/area/shipbuilder/station
	name = "shipbuilder station"
	icon_state = "teleporter"

/area/shipbuilder/ship1
	name = "shipbuilder ship1"
	icon_state = "teleporter"

/area/shipbuilder/ship2
	name = "shipbuilder ship2"
	icon_state = "teleporter"

/area/shipbuilder/ship3
	name = "shipbuilder ship3"
	icon_state = "teleporter"

/area/shipbuilder/ship4
	name = "shipbuilder ship4"
	icon_state = "teleporter"

/area/shipbuilder/ship5
	name = "shipbuilder ship5"
	icon_state = "teleporter"

/area/shipbuilder/ship6
	name = "shipbuilder ship6"
	icon_state = "teleporter"


/**********************Spaceship builder**************************/

/obj/machinery/spaceship_builder
	name = "Robotic Fabricator"
	icon = 'surgery.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	var/metal_amount = 0
	var/operating = 0
	var/area/currentShuttleArea = null
	var/currentShuttleName = null

/obj/machinery/spaceship_builder/proc/buildShuttle(var/shuttle)

	var/shuttleat = null
	var/shuttleto = "/area/shipbuilder/station"

	var/req_metal = 0
	switch(shuttle)
		if("hopper")
			shuttleat = "/area/shipbuilder/ship1"
			currentShuttleName = "Planet hopper"
			req_metal = 25000
		if("bus")
			shuttleat = "/area/shipbuilder/ship2"
			currentShuttleName = "Blnder Bus"
			req_metal = 60000
		if("dinghy")
			shuttleat = "/area/shipbuilder/ship3"
			currentShuttleName = "Space dinghy"
			req_metal = 100000
		if("van")
			shuttleat = "/area/shipbuilder/ship4"
			currentShuttleName = "Boxvan MMDLVI"
			req_metal = 120000
		if("secvan")
			shuttleat = "/area/shipbuilder/ship5"
			currentShuttleName = "Boxvan MMDLVI - Security edition"
			req_metal = 125000
		if("station4")
			shuttleat = "/area/shipbuilder/ship6"
			currentShuttleName = "Space station 4"
			req_metal = 250000

	if (metal_amount - req_metal < 0)
		return

	if (!shuttleat)
		return

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest)
		return

	currentShuttleArea = shuttleat
	from.move_contents_to(dest)
	return

/obj/machinery/spaceship_builder/proc/scrapShuttle()

	var/shuttleat = "/area/shipbuilder/station"
	var/shuttleto = currentShuttleArea

	if (!shuttleto)
		return

	var/area/from = locate(shuttleat)
	var/area/dest = locate(shuttleto)

	if(!from || !dest)
		return

	currentShuttleArea = null
	currentShuttleName = null
	from.move_contents_to(dest)
	return

/obj/machinery/spaceship_builder/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(operating == 1)
		user << "The machine is processing"
		return

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/stack/sheet/metal))

		var/obj/item/stack/sheet/metal/M = W
		user << "\blue You insert all the metal into the machine."
		metal_amount += M.amount * 100
		del(M)

	else
		return attack_hand(user)
	return

/obj/machinery/spaceship_builder/attack_hand(user as mob)
	if(operating == 1)
		user << "The machine is processing"
		return

	var/dat
	dat = text("<b>Ship fabricator</b><br><br>")
	dat += text("Current ammount of <font color='gray'>Metal: <b>[metal_amount]</b></font><br><hr>")

	if (currentShuttleArea)
		dat += text("<b>Currently building</b><br><br>[currentShuttleName]<br><br>")
		dat += text("<b>Build the shuttle to your liking.</b><br>This shuttle will be sent to the station in the event of an emergency along with a centcom emergency shuttle.")
		dat += text("<br><br><br><A href='?src=\ref[src];scrap=1'>Scrap current shuttle</A>")
	else
		dat += text("<b>Available ships to build:</b><br><br>")
		dat += text("<A href='?src=\ref[src];ship=hopper'>Planet hopper</A> - Tiny, Slow, 25000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=bus'>Blunder Bus</A> - Small, Decent speed, 60000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=dinghy'>Space dinghy</A> - Medium size, Decent speed, 100000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=van'>Boxvan MMDLVIr</A> - Medium size, Decent speed, 120000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=secvan'>Boxvan MMDLVI - Security eidition</A> - Large, Rather slow, 125000 metal<br>")
		dat += text("<A href='?src=\ref[src];ship=station4'>Space station 4</A> - Huge, Slow, 250000 metal<br>")

	user << browse("[dat]", "window=shipbuilder")


/obj/machinery/spaceship_builder/Topic(href, href_list)
	if(..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if(href_list["ship"])
		buildShuttle(href_list["ship"])
	if(href_list["scrap"])
		scrapShuttle(href_list["ship"])
	src.updateUsrDialog()
	return