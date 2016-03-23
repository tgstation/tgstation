/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	var/list/chameleon_blacklist = list()
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	if(button)
		button.name = "Change [chameleon_name] Appearance"
	chameleon_blacklist += target.type
	var/list/temp_list = typesof(chameleon_type)
	for(var/V in temp_list - (chameleon_blacklist))
		chameleon_list += V

/datum/action/item_action/chameleon/change/proc/update_look(mob/user)
	var/list/item_names = list()
	var/obj/item/picked_item
	for(var/U in chameleon_list)
		var/obj/item/I = U
		item_names += initial(I.name)
	var/picked_name
	picked_name = input("Select [chameleon_name] to change it to", "Chameleon [chameleon_name]", picked_name) in item_names
	if(!picked_name)
		return
	for(var/V in chameleon_list)
		var/obj/item/I = V
		if(initial(I.name) == picked_name)
			picked_item = V
			break
	if(!picked_item)
		return
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		target.name = initial(picked_item.name)
		target.desc = initial(picked_item.desc)
		target.icon_state = initial(picked_item.icon_state)
		if(istype(target, /obj/item))
			var/obj/item/I = target
			I.item_state = initial(picked_item.item_state)
			I.item_color = initial(picked_item.item_color)
			if(istype(I, /obj/item/clothing) && istype(initial(picked_item), /obj/item/clothing))
				var/obj/item/clothing/CL = I
				var/obj/item/clothing/PCL = picked_item
				CL.flags_cover = initial(PCL.flags_cover)
		target.icon = initial(picked_item.icon)

		C.regenerate_icons()	//so our overlays update.
	UpdateButtonIcon()

/datum/action/item_action/chameleon/change/Trigger()
	if(!IsAvailable())
		return

	update_look(owner)
	return 1

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	origin_tech = "syndicate=3"
	sensor_mode = 0 //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = 0
	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.initialize_disguises()

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	item_state = "armor"
	blood_overlay_type = "armor"
	origin_tech = "syndicate=3"
	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.initialize_disguises()

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	item_state = "meson"

	origin_tech = "syndicate=3"
	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/glasses/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.initialize_disguises()

/obj/item/clothing/gloves/chameleon
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"

	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/gloves/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.initialize_disguises()

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"

	burn_state = FIRE_PROOF
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	item_state = "gas_alt"
	burn_state = FIRE_PROOF
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 0, rad = 0)

	flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH

	var/vchange = 1

/obj/item/clothing/mask/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.initialize_disguises()

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	vchange = !vchange
	user << "<span class='notice'>The voice changer is now [vchange ? "on" : "off"]!</span>"

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "black"
	item_color = "black"
	desc = "A pair of black shoes."

	permeability_coefficient = 0.05
	flags = NOSLIP
	origin_tech = "syndicate=3"
	burn_state = FIRE_PROOF
	can_hold_items = 1
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.initialize_disguises()

/obj/item/weapon/gun/energy/laser/chameleon
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	needs_permit = 0
	pin = /obj/item/device/firing_pin
	cell_type = /obj/item/weapon/stock_parts/cell/bluespace

/obj/item/weapon/gun/energy/laser/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/weapon/gun
	chameleon_action.chameleon_name = "Gun"
	chameleon_action.chameleon_blacklist = typesof(/obj/item/weapon/gun/magic)
	chameleon_action.initialize_disguises()

/obj/item/weapon/storage/backpack/chameleon
	name = "chameleon backpack"

/obj/item/weapon/storage/backpack/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/weapon/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()

/obj/item/device/radio/headset/chameleon
	name = "chameleon headset"

/obj/item/device/radio/headset/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/device/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()

/obj/item/device/pda/chameleon
	name = "chameleon PDA"

/obj/item/device/pda/chameleon/New()
	..()
	var/datum/action/item_action/chameleon/change/chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/device/pda
	chameleon_action.chameleon_name = "PDA"
	chameleon_action.chameleon_blacklist = list(/obj/item/device/pda/ai)
	chameleon_action.initialize_disguises()
