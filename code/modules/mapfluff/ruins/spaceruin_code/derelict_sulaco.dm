/////////// derelictsulaco items

/obj/item/paper/crumpled/ruins/derelict_sulaco/captain
	name = "bloody paper scrap"
	icon_state = "scrap_bloodied"
	default_raw_text = "We gave it our all, yet we still lost. Now we're just waiting for the self-destruct to go off. But I had a good run. We all did. I led and fought with the bravest, most sincere people I ever had the pleasure of meeting.<BR><BR>Semper fi.<BR><BR>*Captain Romero Hernan*"

/obj/item/paper/ruins/derelict_sulaco/birthday
	name = "to our captain"
	desc = "Although faint, you can make out the words 'always faithful!' on the back of this photo."
	icon = 'icons/obj/art/camera.dmi'
	icon_state = "photo"
	show_written_words = FALSE

	default_raw_text = "*This looks to be a photo of the captain's birthday, held in a festivized cafeteria. The crew's smiles and laughter beam through discolored film, where one staff officer has his superior enveloped in a warm hug. Everyone looks happy together. A gift is being forced into the captain's hands: some silly, mischievous-looking 'runner' plushie.*"

/obj/item/clothing/suit/armor/vest/marine/sulaco
	name = "damaged tactical armor vest"
	desc = "An old, roughed-up set of the finest mass produced, stamped plasteel armor. This piece of equipment has lost most of its protective qualities to time, yet it is still more than serviceable for giving xenos the middle finger."
	armor_type = /datum/armor/derelict_marine

/obj/item/clothing/head/helmet/marine/sulaco
	name = "damaged tactical combat helmet"
	desc = "A tactical black helmet, barely sealed from outside hazards with a plate of glass and not much else. Not as protective as it used to be, but it is still completely functional."
	armor_type = /datum/armor/derelict_marine

/datum/armor/derelict_marine
	melee = 20
	bullet = 20
	bio = 100
	fire = 40
	acid = 50
	wound = 20

/obj/machinery/computer/terminal/sulaco
	tguitheme = "abductor"

/obj/machinery/computer/terminal/sulaco/overwatch
	name = "overwatch console"
	desc = "State of the art machinery for general overwatch purposes."
	upperinfo = "Bravo Overwatch Console"
	icon_screen = "explosive"
	content = list("<B>Operator:</B> Cas Ashpole <BR> <BR> <B><center>Squad Overwatch:</B> Cas Ashpole <BR> <BR> <b>Squad Leader Deployed</b> <BR> <b>Squad Smartgunners:</b> 1 Deployed <BR> <b>Squad Corpsmen:</b> 1 Deployed <BR> <b>Squad Engineers:</b> 2 Deployed <BR> <b>Squad Marines:</b> 4 Deployed <BR> <b>Total:</b> 9 Deployed <BR> <b>Marines Alive:</b> 0 <BR> <BR> <table>   <tr>     <th>Name</th>     <th>Role</th>     <th>State</th>     <th>Location</th>     <th>SL Distance</th>   </tr>   <tr>     <td>Chip Mello</td>     <td>Squad Leader</td>     <td>Dead</td>     <td>Self-Destruct Core Room</td>     <td> N/A </td>   </tr>   <tr>     <td>Sophie Knight</td>     <td>Squad Smartgunner</td>     <td>Dead</td>     <td>Self-Destruct Core Room</td>     <td>4</td>   </tr>   <tr>     <td>Marie Newman</td>     <td>Squad Corpsman</td>     <td>Dead</td>     <td>Unknown</td>     <td> N/A </td>   </tr>   <tr>     <td>Angelo Patton</td>     <td>Squad Engineer</td>     <td>Dead</td>     <td>Sulaco Maintenence</td>     <td>19</td>   </tr>   <tr>     <td>Marlon Foster</td>     <td>Squad Engineer</td>     <td>Dead</td>     <td>Sulaco Dropship Hangar</td>     <td>28</td>   </tr>   <tr>     <td>Doug Davidson</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Sulaco Hangar Workshop</td>     <td>33</td>   </tr>   <tr>     <td>Courtney Miller</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Sulaco Hangar Workshop</td>     <td>42</td>   </tr>   <tr>     <td>Cesar Jefferson</td>     <td>Squad Marine</td>     <td>Dead</td>     <td>Self-Destruct Core Room</td>     <td>14</td>   </tr> </table> <BR> <b>Primary Objective:</b> Defend the self-destruct core. <BR> <b>Secondary Objective:</b> Give them hell!</center>")

/obj/machinery/computer/terminal/sulaco/overwatch/main
	name = "main overwatch console"
	upperinfo = "Main Overwatch Console"
	icon_screen = "commsyndie"
	icon_keyboard = "syndie_key"
	content = list("<B>Main Operator:</B> Romero Hernan <BR> <BR> <center><B>Charlie Squad</B> <BR> <b>Leader:</b> Colin Norris <BR> <b>Squad Overwatch:</b> Cheryl Wade <BR> <BR> <B>Alpha Squad</B> <BR> <b>Leader</b>: NONE <BR> <b>Squad Overwatch:</b> NONE <BR> <BR> <B>Bravo Squad</B> <BR> <b>Leader</b>: Chip Mello <BR> <b>Squad Overwatch:</b> Cas Ashpole <BR> <BR> <B>Delta Squad</B> <BR> <b>Leader</b>: Scott Byrd <BR> <b>Squad Overwatch:</b> Casey Alle <BR> <BR> <BR> <b> Orbital Bombardment Cannon<BR> <BR>Current Cannon Status: </B> Unable to connect to the OBC! <BR> <b>Laser Targets:</b> None <BR> <b>Selected Targets:</b> None</center>")

/obj/machinery/computer/terminal/sulaco/helm
	name = "helms computer"
	desc = "The navigation console for the Sulaco."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	upperinfo = "Navigation"
	content = list("<center><b>Sulaco<BR><BR><BR>LOCATION UNKNOWN</b><BR><BR>Power Level: 0<BR>Engine status: N/A<BR><BR><b>Unable to change orbit.</b></center>")

/obj/machinery/computer/terminal/sulaco/map
	name = "map table"
	desc = "A table that displays a map of the current target location."
	icon_screen = "mining"
	upperinfo = "LV-624"
	content = list("The display can barely output an image of a map, owing to its damage, but you can make out bits and pieces of something. It appears to be a satellite image of a colony located on a jungle planet. Lush and thick greenery covers the southern part, while the northern area is encompassed by mountainous rock.<BR><BR>A river flows through the colony, splitting it in two. In addition, several icons are scattered across the map, but you are sadly not able to make much sense of them.")
