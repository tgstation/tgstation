// TODO: remove the robot.mmi and robot.cell variables and completely rely on the robot component system

/datum/robot_component/var/name
/datum/robot_component/var/installed = 0
/datum/robot_component/var/powered = 0
/datum/robot_component/var/toggled = 1
/datum/robot_component/var/brute_damage = 0
/datum/robot_component/var/electronics_damage = 0
/datum/robot_component/var/energy_consumption = 0
/datum/robot_component/var/max_damage = 30
/datum/robot_component/var/mob/living/silicon/robot/owner

// The actual device object that has to be installed for this.
/datum/robot_component/var/external_type = null

// The wrapped device(e.g. radio), only set if external_type isn't null
/datum/robot_component/var/obj/item/wrapped = null

/datum/robot_component/New(mob/living/silicon/robot/R)
	src.owner = R

/datum/robot_component/proc/install()
/datum/robot_component/proc/uninstall()

/datum/robot_component/proc/destroy()
	if(wrapped)
		del wrapped


	wrapped = new/obj/item/broken_device

	// The thing itself isn't there anymore, but some fried remains are.
	installed = -1
	uninstall()

/datum/robot_component/proc/take_damage(brute, electronics, sharp)
	if(installed != 1) return

	brute_damage += brute
	electronics_damage += electronics

	if(brute_damage + electronics_damage >= max_damage) destroy()

/datum/robot_component/proc/heal_damage(brute, electronics)
	if(installed != 1)
		// If it's not installed, can't repair it.
		return 0

	brute_damage = max(0, brute_damage - brute)
	electronics_damage = max(0, electronics_damage - electronics)

/datum/robot_component/proc/is_powered()
	return (installed == 1) && (brute_damage + electronics_damage < max_damage) && (!energy_consumption || powered)


/datum/robot_component/proc/consume_power()
	if(toggled == 0)
		powered = 0
		return
	if(owner.cell.charge >= energy_consumption)
		owner.cell.use(energy_consumption)
		powered = 1
	else
		powered = 0

/datum/robot_component/armour
	name = "armour plating"
	energy_consumption = 0
	external_type = /obj/item/robot_parts/robot_component/armour
	max_damage = 60

/datum/robot_component/actuator
	name = "actuator"
	energy_consumption = 0 // seeing as we can move without any charge...
	external_type = /obj/item/robot_parts/robot_component/actuator
	max_damage = 50

/datum/robot_component/cell
	name = "power cell"
	max_damage = 50

/datum/robot_component/cell/destroy()
	..()
	owner.cell = null
	owner.updateicon()

/datum/robot_component/radio
	name = "radio"
	external_type = /obj/item/robot_parts/robot_component/radio
	energy_consumption = 1
	max_damage = 40

/datum/robot_component/binary_communication
	name = "binary communication device"
	external_type = /obj/item/robot_parts/robot_component/binary_communication_device
	energy_consumption = 0
	max_damage = 30

/datum/robot_component/camera
	name = "camera"
	external_type = /obj/item/robot_parts/robot_component/camera
	energy_consumption = 1
	max_damage = 40

/datum/robot_component/diagnosis_unit
	name = "self-diagnosis unit"
	energy_consumption = 0
	external_type = /obj/item/robot_parts/robot_component/diagnosis_unit
	max_damage = 30

/mob/living/silicon/robot/proc/initialize_components()
	// This only initializes the components, it doesn't set them to installed.

	components["actuator"] = new/datum/robot_component/actuator(src)
	components["radio"] = new/datum/robot_component/radio(src)
	components["power cell"] = new/datum/robot_component/cell(src)
	components["diagnosis unit"] = new/datum/robot_component/diagnosis_unit(src)
	components["camera"] = new/datum/robot_component/camera(src)
	components["comms"] = new/datum/robot_component/binary_communication(src)
	components["armour"] = new/datum/robot_component/armour(src)

/mob/living/silicon/robot/proc/is_component_functioning(module_name)
	var/datum/robot_component/C = components[module_name]
	return C && C.installed == 1 && C.toggled && C.is_powered()

/obj/item/broken_device
	name = "broken component"
	icon = 'icons/robot_component.dmi'
	icon_state = "broken"

/obj/item/robot_parts/robot_component
	icon = 'icons/robot_component.dmi'
	icon_state = "working"

/obj/item/robot_parts/robot_component/binary_communication_device
	name = "binary communication device"
	icon_state = "binary_translator"

/obj/item/robot_parts/robot_component/actuator
	name = "actuator"
	icon_state = "actuator"

/obj/item/robot_parts/robot_component/armour
	name = "armour plating"
	icon_state = "armor_plating"

/obj/item/robot_parts/robot_component/camera
	name = "camera"
	icon_state = "camera"

/obj/item/robot_parts/robot_component/diagnosis_unit
	name = "diagnosis unit"
	icon_state = "diagnosis_unit"

/obj/item/robot_parts/robot_component/radio
	name = "radio"
	icon_state = "radio"

//
//Robotic Component Analyser, basically a health analyser for robots
//
/obj/item/device/robotanalyzer
	name = "cyborg analyzer"
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	starting_materials = list(MAT_IRON = 200)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=3;engineering=3"
	var/mode = 1;

/obj/item/device/robotanalyzer/attack(mob/living/M as mob, mob/living/user as mob)
	if(( (M_CLUMSY in user.mutations) || user.getBrainLoss() >= 60) && prob(50))
		to_chat(user, text("<span class='warning'>You try to analyze the floor's vitals!</span>"))
		for(var/mob/O in viewers(M, null))
			O.show_message(text("<span class='warning'>[user] has analyzed the floor's vitals!</span>"), 1)
		user.show_message(text("<span class='notice'>Analyzing Results for The floor:\n\t Overall Status: Healthy</span>"), 1)
		user.show_message(text("<span class='notice'>\t Damage Specifics: [0]-[0]-[0]-[0]</span>"), 1)
		user.show_message("<span class='notice'>Key: Suffocation/Toxin/Burns/Brute</span>", 1)
		user.show_message("<span class='notice'>Body Temperature: ???</span>", 1)
		return
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(!istype(M, /mob/living/silicon/robot))
		to_chat(user, "<span class='warning'>You can't analyze non-robotic things!</span>")
		return

	user.visible_message("<span class='notice'> [user] has analyzed [M]'s components.","<span class='notice'> You have analyzed [M]'s components.")
	var/BU = M.getFireLoss() > 50 	? 	"<b>[M.getFireLoss()]</b>" 		: M.getFireLoss()
	var/BR = M.getBruteLoss() > 50 	? 	"<b>[M.getBruteLoss()]</b>" 	: M.getBruteLoss()
	user.show_message("<span class='notice'>Analyzing Results for [M]:\n\t Overall Status: [M.stat > 1 ? "fully disabled" : "[M.health - M.halloss]% functional"]</span>")
	user.show_message("\t Key: <font color='#FFA500'>Electronics</font>/<font color='red'>Brute</font>", 1)
	user.show_message("\t Damage Specifics: <font color='#FFA500'>[BU]</font> - <font color='red'>[BR]</font>")
	if(M.tod && M.stat == DEAD)
		user.show_message("<span class='notice'>Time of Disable: [M.tod]</span>")

	var/mob/living/silicon/robot/H = M
	var/list/damaged = H.get_damaged_components(1,1,1)
	user.show_message("<span class='notice'>Localized Damage:</span>",1)
	if(length(damaged)>0)
		for(var/datum/robot_component/org in damaged)
			user.show_message(text("<span class='notice'>\t []: [][] - [] - [] - []</span>",	\
			capitalize(org.name),					\
			(org.installed == -1)	?	"<font color='red'><b>DESTROYED</b></font> "							:"",\
			(org.electronics_damage > 0)	?	"<font color='#FFA500'>[org.electronics_damage]</font>"	:0,	\
			(org.brute_damage > 0)	?	"<font color='red'>[org.brute_damage]</font>"							:0,		\
			(org.toggled)	?	"Toggled ON"	:	"<font color='red'>Toggled OFF</font>",\
			(org.powered)	?	"Power ON"		:	"<font color='red'>Power OFF</font>"),1)
	else
		user.show_message("<span class='notice'>\t Components are OK.</span>",1)
	if(H.emagged && prob(5))
		user.show_message("<span class='warning'>\t ERROR: INTERNAL SYSTEMS COMPROMISED</span>",1)
	src.add_fingerprint(user)
	return
