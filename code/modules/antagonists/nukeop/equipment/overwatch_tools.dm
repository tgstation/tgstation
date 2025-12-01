///One of the special items that spawns in the overwatch agent's room.
/obj/item/paper/fluff/overwatch
	name = "OVERWATCH NOTES #1"
	color = COLOR_RED
	desc = "A note from Syndicate leadership regarding your new job. You should read this!"
	default_raw_text = @{"
Congratulations! You have been picked to be the Sole Survivor of an anti-Nanotrasen suicide mission!
We're kidding of course, these types of missions tend to have abnormally high survival rates. I guess that says a lot about who your team will be going up against.
<br>
You've been assigned to provide intelligence support to the ground-pounders carrying out the operation.
Each operative has been equipped with a bodycam that can be accessed via your Overwatch Camera Console.
Additionally, you have been given the boards to access station alerts, cameras, and remotely control the infiltrator shuttle.
<br>
Feel free to set up your workplace however you like. We've provided the tools and boards in your backroom.
<br>
Happy hunting!
	"}

/obj/machinery/computer/security/overwatch
	name = "overwatch camera console"
	desc = "Allows you to view members of your operative team via their bodycam feeds. We call them 'bodycams', but they're actually a swarm of tiny, near-imperceptible camera drones that follow each target. \
		It is believed that adversaries either don't notice the drones, or avoid attacking them in hopes that they'll capture footage of their combat prowess against our operatives."
	icon_screen = "commsyndie"
	icon_keyboard = "syndie_key"
	network = list(OPERATIVE_CAMERA_NET)
	circuit = /obj/item/circuitboard/computer/overwatch

/obj/item/circuitboard/computer/overwatch
	name = "Overwatch Body Cameras"
	build_path = /obj/machinery/computer/security/overwatch
	greyscale_colors = CIRCUIT_COLOR_SECURITY

/obj/item/circuitboard/computer/syndicate_shuttle_docker
	name = "Shuttle Controller"
	build_path = /obj/machinery/computer/camera_advanced/shuttle_docker/syndicate
	greyscale_colors = CIRCUIT_COLOR_SECURITY

/obj/item/clothing/glasses/overwatch
	name = "intelligence glasses"
	desc = "A set of incredibly advanced sunglasses, providing you with an array of different sensor scans and visual readouts for pretty much anything you look at. \
		It's kind of overwhelming, actually. Wearing this for a few hours will probably give you a migrane."
	icon_state = "sunhudmed"
	flags_cover = GLASSESCOVERSEYES
	flash_protect = FLASH_PROTECTION_WELDER
	clothing_traits = list(TRAIT_REAGENT_SCANNER, TRAIT_SECURITY_HUD, TRAIT_MEDICAL_HUD, TRAIT_DIAGNOSTIC_HUD)
