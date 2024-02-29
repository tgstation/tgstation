/**************CKEY EXCLUSIVES*************/

// Donation reward for Grunnyyy
/obj/item/clothing/suit/jacket/ryddid
	name = "Ryddid"
	desc = "An old worn out piece of clothing belonging to a certain small demon."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "darkcoat"
	inhand_icon_state = "greatcoat"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

// Donation reward for Grunnyyy
/obj/item/clothing/neck/cloak/grunnyyy
	name = "black and red cloak"
	desc = "The design on this seems a little too familiar."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "infcloak"
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = NONE

// Donation reward for Thedragmeme
// might make it have some flavour functionality in future, a'la rewritable piece of paper - JOKES ON YOU I'M MAKING IT DRAW
/obj/item/canvas/drawingtablet
	name = "drawing tablet"
	desc = "A portable tablet that allows you to draw. Legends say these can earn the owner a fortune in some sectors of space."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "drawingtablet"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	inhand_icon_state = "electronic"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/dtselectcolor,/datum/action/item_action/dtcolormenu,/datum/action/item_action/dtcleargrid)
	pixel_x = 0
	pixel_y = 0
	width = 28
	height = 26
	nooverlayupdates = TRUE
	var/currentcolor = "#ffffff"
	var/list/colors = list("Eraser" = "#ffffff")

/obj/item/canvas/drawingtablet/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/dtselectcolor))
		currentcolor = tgui_color_picker(user, "", "Choose Color", currentcolor)
	else if(istype(action, /datum/action/item_action/dtcolormenu))
		var/list/selects = colors.Copy()
		selects["Save"] = "Save"
		selects["Delete"] = "Delete"
		var/selection = input(user, "", "Color Menu", currentcolor) as null|anything in selects
		if(QDELETED(src) || !user.can_perform_action(src))
			return
		switch(selection)
			if("Save")
				var/name = input(user, "", "Name the color!", "Pastel Purple") as text|null
				if(name)
					colors[name] = currentcolor
			if("Delete")
				var/delet = input(user, "", "Color Menu", currentcolor) as null|anything in colors
				if(delet)
					colors.Remove(delet)
			if(null)
				return
			else
				currentcolor = colors[selection]
	else if(istype(action, /datum/action/item_action/dtcleargrid))
		var/yesnomaybe = tgui_alert("Are you sure you wanna clear the canvas?", "", list("Yes", "No", "Maybe"))
		if(QDELETED(src) || !user.can_perform_action(src))
			return
		switch(yesnomaybe)
			if("Yes")
				reset_grid()
				SStgui.update_uis(src)
			if("No")
				return
			if("Maybe")
				playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
				audible_message(span_warning("The [src] buzzes!"))
				return

/obj/item/canvas/drawingtablet/get_paint_tool_color()
	return currentcolor

/obj/item/canvas/drawingtablet/finalize()
	return // no finalizing this piece

/obj/structure/sign/painting/frame_canvas(mob/user,obj/item/canvas/new_canvas)
	if(istype(new_canvas, /obj/item/canvas/drawingtablet)) // NO FINALIZING THIS BITCH.
		return FALSE
	else
		return ..()

/obj/item/canvas/var/nooverlayupdates = FALSE

/obj/item/canvas/update_overlays()
	if(nooverlayupdates)
		return
	. = ..()

/datum/action/item_action/dtselectcolor
	name = "Change Color"
	desc = "Change your color."
	button_icon = 'monkestation/icons/donator/obj/custom.dmi'
	button_icon_state = "drawingtablet"

/datum/action/item_action/dtcolormenu
	name = "Color Menu"
	desc = "Select, save, or delete a color in your tablet's color menu!"
	button_icon = 'monkestation/icons/donator/obj/custom.dmi'
	button_icon_state = "drawingtablet"

/datum/action/item_action/dtcleargrid
	name = "Clear Canvas"
	desc = "Clear the canvas of your drawing tablet."
	button_icon = 'monkestation/icons/donator/obj/custom.dmi'
	button_icon_state = "drawingtablet"

// Donation reward for Thedragmeme
/obj/item/clothing/suit/furcoat
	name = "leather coat"
	desc = "A thick, comfy looking leather coat. It's got some fluffy fur at the collar and sleeves."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "furcoat"
	inhand_icon_state = "hostrench"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	supports_variations_flags = NONE

// Donation reward for Thedragmeme
/obj/item/clothing/under/syndicate/tacticool/black
	name = "black turtleneck"
	desc = "Tacticool as fug. Comfy too."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "black_turtleneck"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	supports_variations_flags = NONE
	can_adjust = FALSE //There wasnt an adjustable sprite anyways
	armor_type = /datum/armor/tacticool_black
	has_sensor = HAS_SENSORS	//Actually has sensors, to balance the new lack of armor

// Donation reward for Thedragmeme

/datum/armor/tacticool_black
	wound = 5

/obj/item/clothing/shoes/jackboots/heel
	name = "high-heeled jackboots"
	desc = "Almost like regular jackboots... why are they on a high heel?"
	icon = 'monkestation/icons/donator/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/feet.dmi'
	icon_state = "heel-jackboots"
	unique_reskin = NONE

// Donation reward for Bloodrite
/obj/item/clothing/shoes/clown_shoes/britches
	desc = "The prankster's standard-issue clowning shoes. They look extraordinarily cute. Ctrl-click to toggle waddle dampeners."
	name = "Britches' shoes"
	icon = 'monkestation/icons/donator/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/feet.dmi'
	icon_state = "clown_shoes_cute"
	supports_variations_flags = NONE
	resistance_flags = FIRE_PROOF

// Donation reward for Bloodrite
/obj/item/clothing/under/rank/civilian/clown/britches
	name = "Britches' dress"
	desc = "<i>'HONK!' (but cute)</i>"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "clowndress"
	supports_variations_flags = NONE
	resistance_flags = FIRE_PROOF

// Donation reward for Bloodrite
/obj/item/clothing/mask/gas/britches
	name = "Britches' mask"
	desc = "A true prankster's facial attire. Cute."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	icon_state = "cute_mask"
	inhand_icon_state = null
	dye_color = "clown"
	supports_variations_flags = NONE
	clothing_flags = MASKINTERNALS
	w_class = WEIGHT_CLASS_SMALL
	flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF

// Donation reward for Farsighted Nightlight
/obj/item/clothing/mask/gas/nightlight
	name = "FAR-14C IRU"
	desc = "A close-fitting respirator designed by Forestiian Armories, commonly used by Military and Civilian Personnel alike. It reeks of Militarism."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	icon_state = "far14c"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS //same flags as actual sec hailer gas mask
	flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	flags_cover = NONE
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACIALHAIR | HIDEFACE | HIDESNOUT
	w_class = WEIGHT_CLASS_SMALL
	tint = 0

// Donation reward for TheOOZ
/obj/item/clothing/mask/animal/kindle
	name = "wolf mask"
	desc = "A dark mask in the shape of a wolf's head.<br>The material feels like it's made entirely out of inexpensive plastic."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	icon_state = "kindle"
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	inhand_icon_state = "gasmask_captain"
	animal_type = "wolf"
	animal_sounds = list("Awoo!", "Woof.", "Arf!")
	animal_sounds_alt_probability = 15
	animal_sounds_alt = list("Join us!", "Wear the mask.")
	cursed = FALSE

	supports_variations_flags = NONE
	clothing_flags = MASKINTERNALS | VOICEBOX_DISABLED | VOICEBOX_TOGGLABLE
	flags_inv = HIDEFACIALHAIR | HIDESNOUT
	visor_flags_inv = HIDEFACIALHAIR | HIDESNOUT
	alternate_worn_layer = ABOVE_BODY_FRONT_HEAD_LAYER
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/animal/kindle/make_cursed()
	. = ..()
	clothing_flags = initial(clothing_flags)
	name = "\proper the accursed wolf mask"
	desc = "The mask which belongs to Nanotrasen's Outpost Captain Kindle, it is the symbol of her alleged cult.<br>It looks like a [animal_type] mask, but closer inspection reveals it's melded onto this person's face!"

// Donation reward for Random516
/obj/item/clothing/head/drake_skull
	name = "skull of an ashdrake"
	desc = "How did they get this?"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	icon_state = "drake_skull"
	worn_icon = 'monkestation/icons/donator/mob/clothing/large-worn-icons/32x64/head.dmi'
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	supports_variations_flags = NONE

// Donation reward for Random516
/obj/item/clothing/gloves/fingerless/blutigen_wraps
	name = "Blutigen wraps"
	desc = "The one who wears these had everything and yet lost it all..."
	icon = 'monkestation/icons/donator/obj/clothing/gloves.dmi'
	icon_state = "blutigen_wraps"
	worn_icon = 'monkestation/icons/donator/mob/clothing/hands.dmi'

// Donation reward for Random516
/obj/item/clothing/suit/blutigen_kimono
	name = "Blutigen kimono"
	desc = "For the eyes bestowed upon this shall seek adventure..."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	icon_state = "blutigen_kimono"
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = NONE

/obj/item/clothing/gloves/ring/hypno
	var/list/spans = list()
	actions_types = list(/datum/action/item_action/hypno_whisper)

// Donation reward for CoffeePot
/obj/item/clothing/gloves/ring/hypno/coffeepot
	name = "hypnodemon's ring"
	desc = "A pallid, softly desaturated-looking gold ring that doesn't look like it belongs. It's hard to put one's finger on why it feels at odds with the world around it - the shine coming off it looks like it could be a mismatch with the lighting in the room, or it could be that it seems to glint and twinkle occasionally when there's no obvious reason for it to - though only when you're not really looking."
	spans = list("hypnophrase")

/datum/action/item_action/hypno_whisper
	name = "Hypnotic Whisper"

/obj/item/clothing/gloves/ring/hypno/ui_action_click(mob/living/user, action)
	set waitfor = FALSE
	if(!isliving(user) || !can_use(user))
		return
	var/message = tgui_input_text(user, "Speak with a hypnotic whisper", "Whisper", encode = FALSE)
	if(QDELETED(src) || QDELETED(user) || !message || !user.can_speak())
		return
	user.whisper(message, spans = spans)

// Donation reward for SlippyJoe
/obj/item/clothing/head/avipilot
	name = "smuggler's flying cap"
	desc = "Shockingly, despite space winds, and the lack of any practicality, this pilot cap seems to be fairly well standing, there's a rabbit head seemingly stamped into the side of it."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "avipilotup"
	inhand_icon_state = "rus_ushanka"
	flags_inv = HIDEEARS|HIDEHAIR
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT //about as warm as an ushanka
	actions_types = list(/datum/action/item_action/adjust)
	supports_variations_flags = NONE
	var/goggles = FALSE

/obj/item/clothing/head/avipilot/proc/adjust_goggles(mob/living/carbon/user)
	if(user?.incapacitated())
		return
	if(goggles)
		icon_state = "avipilotup"
		to_chat(user, span_notice("You put all your effort into pulling the goggles up."))
	else
		icon_state = "avipilotdown"
		to_chat(user, span_notice("You focus all your willpower to put the goggles down on your eyes."))
	goggles = !goggles
	if(user)
		user.head_update(src, forced = 1)
		user.update_mob_action_buttons()

/obj/item/clothing/head/avipilot/ui_action_click(mob/living/carbon/user, action)
	adjust_goggles(user)

/obj/item/clothing/head/avipilot/attack_self(mob/living/carbon/user)
	adjust_goggles(user)

// Donation reward for NetraKyram - public use allowed via the command vendor
/obj/item/clothing/under/rank/captain/dress
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	name = "captain's dress"
	desc = "It's a blue dress with some worn-gold markings denoting the rank of \"Captain\"."
	icon_state = "dress_cap_s"
	worn_icon_state = "dress_cap_s"
	body_parts_covered = CHEST|GROIN|ARMS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	can_adjust = FALSE

// Donation reward for NetraKyram
/obj/item/clothing/under/rank/blueshield/netra
	name = "black and silver armored dress"
	desc = "An ankle length black and silver dress, made out of some shiny synthetic material with inlaid kevlar shards and silver reinforcements, a silver ring surrounds the collar, and it doesn't appear to have a zipper... How does somebody put this thing on anyways?"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "silver_dress"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	supports_variations_flags = NONE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

// Donation reward for NetraKyram
/obj/item/clothing/gloves/netra
	name = "black and silver gloves"
	desc = "Some black gloves with silver reinforcements, made of a shiny synthetic material."
	icon = 'monkestation/icons/donator/obj/clothing/gloves.dmi'
	icon_state = "silver_dress_gloves"
	worn_icon = 'monkestation/icons/donator/mob/clothing/hands.dmi'

// Donation reward for NetraKyram
/obj/item/clothing/shoes/jackboots/netra
	name = "polished jackboots"
	desc = "Some standard issue jackboots, spit-shined to a reflective sheen, wreaking of the scent of silicon parade polish."
	icon = 'monkestation/icons/donator/obj/clothing/shoes.dmi'
	icon_state = "silver_dress_boots"
	worn_icon = 'monkestation/icons/donator/mob/clothing/feet.dmi'
	supports_variations_flags = NONE

/****************LEGACY REWARDS***************/
// Donation reward for inferno707
/obj/item/clothing/neck/cloak/inferno
	name = "Kiara's cloak"
	desc = "The design on this seems a little too familiar."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "infcloak"
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

// Donation reward for inferno707
/obj/item/clothing/neck/inferno_collar
	name = "Kiara's collar"
	desc = "A soft black collar that seems to stretch to fit whoever wears it."
	icon_state = "infcollar"
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	alternate_worn_layer = UNDER_SUIT_LAYER
	/// What's the name on the tag, if any?
	var/tagname = null
	/// What treat item spawns inside the collar?
	var/treat_path = /obj/item/food/cookie

/obj/item/clothing/neck/inferno_collar/Initialize(mapload)
	. = ..()
	if(treat_path)
		new treat_path(src)

/obj/item/clothing/neck/inferno_collar/attack_self(mob/user)
	tagname = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", "Kiara", MAX_NAME_LEN)
	if(tagname)
		name = "[initial(name)] - [tagname]"

// Donation reward for inferno707
/obj/item/clothing/accessory/medal/steele
	name = "Insignia Of Steele"
	desc = "An intricate pendant given to those who help a key member of the Steele Corporation."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "steele"
	medaltype = "medal-silver"

// Donation reward for inferno707
/obj/item/toy/darksabre
	name = "Kiara's sabre"
	desc = "This blade looks as dangerous as its owner."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	icon_state = "darksabre"
	lefthand_file = 'monkestation/icons/donator/mob/inhands/donator_left.dmi'
	righthand_file = 'monkestation/icons/donator/mob/inhands/donator_right.dmi'

/obj/item/toy/darksabre/get_belt_overlay()
	return mutable_appearance('monkestation/icons/donator/obj/custom.dmi', "darksheath-darksabre")

// Donation reward for inferno707
/obj/item/storage/belt/sabre/darksabre
	name = "ornate sheathe"
	desc = "An ornate and rather sinister looking sabre sheathe."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	icon_state = "darksheath"
	worn_icon_state = "darksheath"

/obj/item/storage/belt/sabre/darksabre/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(
		/obj/item/toy/darksabre
		))

/obj/item/storage/belt/sabre/darksabre/PopulateContents()
	new /obj/item/toy/darksabre(src)
	update_icon()

// Donation reward for inferno707
/obj/item/clothing/suit/armor/vest/darkcarapace
	name = "dark armor"
	desc = "A dark, non-functional piece of armor sporting a red and black finish."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	icon_state = "darkcarapace"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	supports_variations_flags = NONE
	armor_type = /datum/armor/none

// Donation reward for inferno707
/obj/item/clothing/mask/hheart
	name = "Hollow Heart"
	desc = "It's an odd ceramic mask. Set in the internal side are several suspicious electronics branded by Steele Tech."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	icon_state = "hheart"
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	var/c_color_index = 1
	var/list/possible_colors = list("off", "blue", "red")
	actions_types = list(/datum/action/item_action/hheart)
	supports_variations_flags = NONE

/obj/item/clothing/mask/hheart/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/clothing/mask/hheart/update_icon()
	. = ..()
	icon_state = "hheart-[possible_colors[c_color_index]]"

/datum/action/item_action/hheart
	name = "Toggle Mode"
	desc = "Toggle the color of the hollow heart."

/obj/item/clothing/mask/hheart/ui_action_click(mob/user, action)
	. = ..()
	if(istype(action, /datum/action/item_action/hheart))
		if(!isliving(user))
			return
		var/mob/living/ooser = user
		var/the = possible_colors.len
		var/index = 0
		if(c_color_index >= the)
			index = 1
		else
			index = c_color_index + 1
		c_color_index = index
		update_icon()
		ooser.update_worn_mask()
		ooser.update_mob_action_buttons()
		to_chat(ooser, span_notice("You toggle the [src] to [possible_colors[c_color_index]]."))

// Donation reward for asky / Zulie
/obj/item/clothing/suit/hooded/cloak/zuliecloak
	name = "Project: Zul-E"
	desc = "A standard version of a prototype cloak given out by Nanotrasen higher ups. It's surprisingly thick and heavy for a cloak despite having most of it's tech stripped. It also comes with a bluespace trinket which calls it's accompanying hat onto the user. A worn inscription on the inside of the cloak reads 'Fleuret' ...the rest is faded away."
	icon_state = "zuliecloak"
	icon = 'monkestation/icons/donator/obj/clothing/cloaks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	hoodtype = /obj/item/clothing/head/hooded/cloakhood/zuliecloak
	body_parts_covered = CHEST|GROIN|ARMS
	slot_flags = ITEM_SLOT_OCLOTHING | ITEM_SLOT_NECK //it's a cloak. it's cosmetic. so why the hell not? what could possibly go wrong?
	supports_variations_flags = NONE

/obj/item/clothing/head/hooded/cloakhood/zuliecloak
	name = "NT special issue"
	desc = "This hat is unquestionably the best one, bluespaced to and from CentCom. It smells of Fish and Tea with a hint of antagonism"
	icon_state = "zuliecap"
	icon = 'monkestation/icons/donator/obj/clothing/cloaks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	flags_inv = null
	supports_variations_flags = NONE

// Donation reward for Lyricalpaws
/obj/item/clothing/neck/cloak/healercloak
	name = "legendary healer's cloak"
	desc = "Worn by the most skilled professional medics on the station, this legendary cloak is only attainable by becoming the pinnacle of healing. This status symbol represents the wearer has spent countless years perfecting their craft of helping the sick and wounded."
	icon_state = "healercloak"
	icon = 'monkestation/icons/donator/obj/clothing/cloaks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'

// Donation reward for Kathrin Bailey / Floof Ball
/obj/item/clothing/under/custom/lannese
	name = "Lannese dress"
	desc = "An alien cultural garment for women, coming from a distant planet named Cantalan."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "lannese"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	supports_variations_flags = NONE
	inhand_icon_state = "firefighter"
	can_adjust = TRUE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|LEGS|FEET

/obj/item/clothing/under/custom/lannese/vambrace
	desc = "An alien cultural garment for women, coming from a distant planet named Cantalan. Shiny vambraces included!"
	icon_state = "lannese_vambrace"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|FEET

// Donation reward for Hacker T.Dog
/obj/item/clothing/suit/scraparmour
	name = "scrap armour"
	desc = "A shoddily crafted piece of armour. It provides no benefit apart from being clunky."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	icon_state = "scraparmor"
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	worn_icon_state = "scraparmor"
	body_parts_covered = CHEST

// Donation reward for Enzoman
/obj/item/clothing/mask/luchador/enzo
	name = "mask of El Red Templar"
	desc = "A mask belonging to El Red Templar, a warrior of lucha. Taking it from him is not recommended."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	icon_state = "luchador"
	worn_icon_state = "luchador"
	clothing_flags = MASKINTERNALS
	supports_variations_flags = NONE

// Donation Reward for Grand Vegeta
/obj/item/clothing/under/mikubikini
	name = "starlight singer bikini"
	desc = " "
	icon_state = "mikubikini"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	worn_icon_state = "mikubikini"
	body_parts_covered = CHEST|GROIN
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY

// Donation Reward for Grand Vegeta
/obj/item/clothing/suit/mikujacket
	name = "starlight singer jacket"
	desc = " "
	icon_state = "mikujacket"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	worn_icon_state = "mikujacket"

// Donation Reward for Grand Vegeta
/obj/item/clothing/head/mikuhair
	name = "starlight singer hair"
	desc = " "
	icon_state = "mikuhair"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	worn_icon_state = "mikuhair"
	flags_inv = HIDEHAIR

// Donation Reward for Grand Vegeta
/obj/item/clothing/gloves/mikugloves
	name = "starlight singer gloves"
	desc = " "
	icon_state = "mikugloves"
	icon = 'monkestation/icons/donator/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/hands.dmi'
	worn_icon_state = "mikugloves"

// Donation reward for CandleJax
/obj/item/clothing/head/helmet/space/plasmaman/candlejax
	name = "emission's helmet"
	desc = "A special containment helmet designed for heavy usage. Multiple dings and notches are on this one."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "emissionhelm"

// Donation reward for CandleJax
/obj/item/clothing/under/plasmaman/candlejax
	name = "emission's containment suit"
	desc = "A modified envirosuit featuring a reserved color scheme."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "emissionsuit"

// Donation reward for CandleJax
/obj/item/clothing/head/bio_hood/jax
	name = "xuracorp biohazard hood"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "bio_hood_jax"
	desc = "A hood composed of proprietary material from a Nanotrasen Affiliate."

/obj/item/clothing/under/plasmaman/jax2
	name = "xuracorp hazard underfitting"
	desc = "A hazard suit fitted with bio-resistant fibers. Utilizes self-sterilizing pumps fitted in the back."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "plasmaman_jax"

/obj/item/clothing/suit/toggle/labcoat/skyrat/rd/jax
	name = "xuracorp enameled labcoat"
	desc = "A XuraCorp designed labcoat for Research Directors. Small triangular indents suggest a protective interior."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "labcoat_xc"
	body_parts_covered = CHEST|ARMS|LEGS
	armor_type = /datum/armor/rd_jax
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

// Donation reward for Raxraus

/datum/armor/rd_jax
	melee = 5
	bio = 80
	fire = 80
	acid = 70

/obj/item/clothing/under/rax_turtleneck
	icon = 'icons/obj/clothing/under/security.dmi'
	worn_icon = 'icons/mob/clothing/under/security.dmi'
	name = "black turtleneck"
	desc = "A stylish black turtleneck."
	icon_state = "hosalt"
	inhand_icon_state = "bl_suit"
	alt_covers_chest = TRUE

// Donation reward for Raxraus
/obj/item/clothing/suit/armor/vest/warden/rax
	name = "peacekeeper jacket"
	desc = "A navy-blue armored jacket with blue shoulder designations."

// Donation reward for DeltaTri
/obj/item/clothing/suit/jacket/delta
	name = "grey winter hoodie"
	desc = "A plain old grey hoodie. It has some puffing on the inside, and a animal fur trim around half of the hood."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "greycoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

// Donation reward for Cherno_00
/obj/item/clothing/suit/jacket/cherno
	name = "silver-buttoned coat"
	desc = "A comfy-looking blue coat. It looks a bit fancy, with shiny silver buttons and a few belts!"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "chernocoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

// Donation reward for GoldenAlpharex
/obj/item/clothing/glasses/welding/steampunk_goggles
	name = "steampunk goggles"
	desc = "This really feels like something you'd expect to see sitting on top of a certain ginger's head... They have a rather fancy brass trim around the lenses."
	icon = 'monkestation/icons/donator/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/eyes.dmi'
	icon_state = "goldengoggles"
	slot_flags = ITEM_SLOT_EYES | ITEM_SLOT_HEAD // Making it fit in both first just so it can properly fit on the head slot in the loadout
	flash_protect = FLASH_PROTECTION_NONE
	flags_cover = GLASSESCOVERSEYES
	custom_materials = null // Don't want that to go in the autolathe
	visor_vars_to_toggle = 0
	tint = 0

	/// Was welding protection added yet?
	var/welding_upgraded = FALSE
	/// Was welding protection toggled on, if welding_upgraded is TRUE?
	var/welding_protection = FALSE
	/// The sound played when toggling the shutters.
	var/shutters_sound = 'sound/effects/clock_tick.ogg'

/obj/item/clothing/glasses/welding/steampunk_goggles/Initialize(mapload)
	. = ..()
	visor_toggling()

/obj/item/clothing/glasses/welding/steampunk_goggles/examine(mob/user)
	. = ..()
	if(welding_upgraded)
		. += "It has been upgraded with welding shutters, which are currently [welding_protection ? "closed" : "opened"]."

/obj/item/clothing/glasses/welding/steampunk_goggles/item_action_slot_check(slot, mob/user)
	. = ..()
	if(. && (slot & ITEM_SLOT_HEAD))
		return FALSE

/obj/item/clothing/glasses/welding/steampunk_goggles/attack_self(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		to_chat(user, span_warning("You can't seem to slip those on your eyes from the top of your head!"))
		return
	. = ..()

/obj/item/clothing/glasses/welding/steampunk_goggles/visor_toggling()
	. = ..()
	slot_flags = up ? ITEM_SLOT_EYES | ITEM_SLOT_HEAD : ITEM_SLOT_EYES
	toggle_vision_effects()

/obj/item/clothing/glasses/welding/steampunk_goggles/weldingvisortoggle(mob/user)
	. = ..()
	handle_sight_updating(user)

/obj/item/clothing/glasses/welding/steampunk_goggles/attackby(obj/item/attacking_item, mob/living/user, params)
	if(!istype(attacking_item, /obj/item/clothing/glasses/welding))
		..()
	if(welding_upgraded)
		to_chat(user, span_warning("\The [src] was already upgraded to have welding protection!"))
		return
	qdel(attacking_item)
	welding_upgraded = TRUE
	to_chat(user, span_notice("You upgrade \the [src] with some welding shutters, offering you the ability to toggle welding protection!"))
	actions += new /datum/action/item_action/toggle_steampunk_goggles_welding_protection(src)

/// Proc that handles the whole toggling the welding protection on and off, with user feedback.
/obj/item/clothing/glasses/welding/steampunk_goggles/proc/toggle_shutters(mob/user)
	if(!can_use(user) || !user)
		return FALSE
	if(!toggle_welding_protection(user))
		return FALSE

	to_chat(user, span_notice("You slide \the [src]'s welding shutters slider, [welding_protection ? "closing" : "opening"] them."))
	playsound(user, shutters_sound, 100, TRUE)
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.head_update(src, forced = 1)
	update_item_action_buttons()
	return TRUE

/// This is the proc that handles toggling the welding protection, while also making sure to update the sight of a mob wearing it.
/obj/item/clothing/glasses/welding/steampunk_goggles/proc/toggle_welding_protection(mob/user)
	if(!welding_upgraded)
		return FALSE
	welding_protection = !welding_protection

	visor_vars_to_toggle = welding_protection ? VISOR_FLASHPROTECT | VISOR_TINT : initial(visor_vars_to_toggle)
	toggle_vision_effects()
	// We also need to make sure the user has their vision modified. We already checked that there was a user, so this is safe.
	handle_sight_updating(user)
	return TRUE

/// Proc handling changing the flash protection and the tint of the goggles.
/obj/item/clothing/glasses/welding/steampunk_goggles/proc/toggle_vision_effects()
	if(welding_protection)
		if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
			flash_protect = up ? FLASH_PROTECTION_NONE : FLASH_PROTECTION_WELDER
	else
		flash_protect = FLASH_PROTECTION_NONE
	tint = flash_protect

/// Proc handling to update the sight of the user, while forcing an update_tint() call every time, due to how the welding protection toggle works.
/obj/item/clothing/glasses/welding/steampunk_goggles/proc/handle_sight_updating(mob/user)
	if(user && (user.get_item_by_slot(ITEM_SLOT_HEAD) == src || user.get_item_by_slot(ITEM_SLOT_EYES) == src))
		user.update_sight()
		if(iscarbon(user))
			var/mob/living/carbon/carbon_user = user
			carbon_user.update_tint()
			carbon_user.head_update(src, forced = TRUE)

/obj/item/clothing/glasses/welding/steampunk_goggles/ui_action_click(mob/user, actiontype, is_welding_toggle = FALSE)
	if(!is_welding_toggle)
		return ..()
	else
		toggle_shutters(user)

/// Action button for toggling the welding shutters (aka, welding protection) on or off.
/datum/action/item_action/toggle_steampunk_goggles_welding_protection
	name = "Toggle Welding Shutters"

/// We need to do a bit of code duplication here to ensure that we do the right kind of ui_action_click(), while keeping it modular.
/datum/action/item_action/toggle_steampunk_goggles_welding_protection/Trigger(trigger_flags)
	if(!IsAvailable())
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, src) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	if(!target || !istype(target, /obj/item/clothing/glasses/welding/steampunk_goggles))
		return FALSE

	var/obj/item/clothing/glasses/welding/steampunk_goggles/goggles = target
	goggles.ui_action_click(owner, src, is_welding_toggle = TRUE)
	return TRUE

// End of the code for GoldenAlpharex's donator item :^)

// Donation reward for MyGuy49
/obj/item/clothing/suit/cloak/ashencloak
	name = "ashen wastewalker cloak"
	desc = "A cloak of advanced make. Clearly beyond what ashwalkers are capable of, it was probably pulled from a downed vessel or something. It seems to have been reinforced with goliath hide and watcher sinew, and the hood has been torn off."
	icon_state = "ashencloak"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	body_parts_covered = CHEST|LEGS|ARMS
	supports_variations_flags = NONE

//Donation reward for Hacker T.Dog
/obj/item/clothing/head/nanotrasen_consultant/hubert
	name = "CC ensign's cap"
	desc = "A tailor made peaked cap, denoting the rank of Ensign."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "CCofficerhat"

//Donation reward for Hacker T.Dog
/obj/item/clothing/suit/armor/vest/nanotrasen_consultant/hubert
	name = "CC ensign's armoured vest"
	desc = "A tailor made Ensign's armoured vest, providing the same protection - but in a more stylish fashion."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "CCvest"

/obj/item/clothing/suit/armor/vest/nanotrasen_consultant/hubert/Initialize(mapload)
	. = ..()
	set_armor(/datum/armor/vest_ntc_hubert)

/datum/armor/vest_ntc_hubert
	melee = 0
	bullet = 0
	energy = 0
	laser = 0

//Donation reward for Hacker T.Dog
/obj/item/clothing/under/rank/nanotrasen_consultant/hubert
	name = "CC ensign's uniform"
	desc = "A tailor-made Ensign's uniform, various medals and chains hang down from it."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "CCofficer"

// Donation reward for Cherno_00
/obj/item/clothing/head/costume/ushanka/frosty
	name = "blue ushanka"
	desc = "A dark blue ushanka with a hand-stitched snowflake on the front. Cool to the touch."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "fushankadown"
	upsprite = "fushankaup"
	downsprite = "fushankadown"

// Donation reward for M97screwsyourparents
/obj/item/clothing/neck/cross
	name = "silver cross"
	desc = "A silver cross to be worn on a chain around your neck. Certain to bring you favour from up above."
	icon = 'monkestation/icons/donator/obj/clothing/necklaces.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	icon_state = "cross"

// Donation reward for gamerguy14948
/obj/item/storage/belt/fannypack/occult
	name = "trinket belt"
	desc = "A belt covered in various trinkets collected through time. Doesn't look like there's much space for anything else nowadays."
	icon = 'monkestation/icons/donator/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/belt.dmi'
	icon_state = "occultfannypack"
	worn_icon_state = "occultfannypack"

// Donation reward for gamerguy14948
/obj/item/clothing/under/occult
	name = "occult collector's outfit"
	desc = "A set of clothes fit for someone dapper that isn't afraid of getting dirty."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "occultoutfit"
	supports_variations_flags = NONE

// Donation reward for gamerguy14948
/obj/item/clothing/head/hooded/occult
	name = "hood"
	desc = "Certainly makes you look more ominous."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "occulthood"
	supports_variations_flags = NONE

// Donation reward for gamerguy14948
/obj/item/clothing/suit/hooded/occult
	name = "occult collector's coat"
	desc = "A big, heavy coat lined with leather and ivory cloth, adorned with a hood. It looks dusty."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "occultcoat"
	hoodtype = /obj/item/clothing/head/hooded/occult
	supports_variations_flags = NONE

// Donation reward for Octus
/obj/item/clothing/mask/breath/vox/octus
	name = "sinister visor"
	desc = "Skrektastic."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	icon_state = "death"

// Donation reward for 1ceres
/obj/item/clothing/glasses/rosecolored
	name = "rose-colored glasses"
	desc = "Goggle-shaped glasses that seem to have a HUD-like feed in some odd line-based script. It doesn’t look like they were made by NT."
	icon = 'monkestation/icons/donator/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/eyes.dmi'
	icon_state = "rose"

// Donation reward for Fuzlet
/obj/item/card/fuzzy_license
	name = "license to hug"
	desc = "A very official looking license. Not actually endorsed by Nanotrasen."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	icon_state = "license"

	var/possible_types = list(
		"hug",
		"snuggle",
		"cuddle",
		"kiss",
		"feed Dan Kelly",
		"hoard Shinzo Shore",
		"spoil friends",
		"hold hands",
		"have this license",
		"squeak",
		"cute",
		"pat",
		"administer plushies",
		"distribute cookies",
		"weh")

/obj/item/card/fuzzy_license/attack_self(mob/user)
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [src.name]."), span_notice("You show \the [src.name]."))
	add_fingerprint(user)

/obj/item/card/fuzzy_license/attackby(obj/item/used, mob/living/user, params)
	if(user.ckey != "fuzlet")
		return

	if(istype(used, /obj/item/pen) || istype(used, /obj/item/toy/crayon))
		var/choice = input(user, "Select the license type", "License Type Selection") as null|anything in possible_types
		if(!isnull(choice))
			name = "license to [choice]"

// Donation reward for 1ceres
/obj/item/clothing/suit/jacket/gorlex_harness
	name = "engine technician harness"
	desc = "A blood-red engineering technician harness. You can't seem to figure out a use to it, but it seems to seal magnetically in some places."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "gorlexharness"


// Donation reward for Kay-Nite
/obj/item/clothing/glasses/eyepatch/rosecolored
	name = "rose-colored eyepatch"
	desc = "A customized eyepatch with a bright pink HUD floating in front of it. It looks like there's more to it than just an eyepatch, considering the materials it's made of."
	icon = 'monkestation/icons/donator/obj/clothing/glasses.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/eyes.dmi'
	icon_state = "rosepatch_R"
	base_icon_state = "rosepatch"

// Donation reward for Cimika
/obj/item/clothing/suit/toggle/labcoat/skyrat/tenrai
	name = "Tenrai labcoat"
	desc = "A labcoat crafted from a variety of pristine materials, sewn together with a frightening amount of skill. The fabric is aery, smooth as silk, and exceptionally pleasant to the touch. The golden stripes are visible in the dark, working as a beacon to the injured. A small label on the inside of it reads \"Tenrai Kitsunes Supremacy\"."
	base_icon_state = "tenraicoat"
	icon_state = "tenraicoat"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/toggle/labcoat/skyrat/tenrai/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)

//Donation reward for RealWinterFrost
/obj/item/clothing/neck/cloak/fluffycloak
	name = "Cloak of the Fluffy One"
	desc = "Hugs and kisses is only what this one knows, may their hugs be for all and not for their own \"For Fuffy Use Only\"."
	icon_state = "fluffycloak"
	icon = 'monkestation/icons/donator/obj/clothing/cloaks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'

/obj/item/clothing/neck/cloak/fluffycloak/worn_overlays(mutable_appearance/standing, isinhands, icon_file)
	. = ..()
	if(!isinhands)
		. += emissive_appearance(icon_file, "[icon_state]-emissive", src, alpha = src.alpha)


/obj/item/clothing/mask/gas/larpswat
	name = "Foam Force SWAT Mask"
	desc = "What seems to be a SWAT mask at first, is actually a gasmask that has replica parts of a SWAT mask made from cheap plastic. Hey at least it looks good if you enjoy looking like a security larper."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	icon_state = "larpswat"
	supports_variations_flags = NONE

// Donation reward for Cimika, on behalf of tf4
/obj/item/clothing/neck/fishpendant
	name = "fish necklace"
	desc = "A simple, silver necklace with a blue tuna pendant.\n\"L. Alazawi\" is inscribed on the back. You get the feeling it would go well with potatoes and green beans."
	icon = 'monkestation/icons/donator/obj/clothing/necklaces.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	icon_state = "fishpendant"

// Donation reward for Weredoggo
/obj/item/hairbrush/tactical
	name = "tactical hairbrush"
	desc = "Sometimes, after a brush with death, a good grooming is just the thing for tactical stress relief. "
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	lefthand_file = 'monkestation/icons/donator/mob/inhands/donator_left.dmi'
	righthand_file = 'monkestation/icons/donator/mob/inhands/donator_right.dmi'
	icon_state = "tacticalbrush"
	inhand_icon_state = "tacticalbrush"

// Donation reward for ultimarifox
/obj/item/clothing/under/rank/security/head_of_security/alt/roselia
	name = "black and red turtleneck"
	desc = "A black turtleneck with red livery attached. Reminds you of a time before the color blue. It seems padded to hell and back as well."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "hosaltred"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'

/obj/item/clothing/glasses/hud/security/sunglasses/gars/giga/roselia
	name = "red-tinted giga HUD gar glasses"
	desc = "GIGA GAR glasses with a security hud implanted in the lens. Reminds you of a time before the color blue."
	icon = 'monkestation/icons/donator/obj/clothing/glasses.dmi'
	icon_state = "supergarsred"
	worn_icon = 'monkestation/icons/donator/mob/clothing/eyes.dmi'

//Donation reward for Konstyantyn
/obj/item/clothing/accessory/badge/holo/jade
	name = "jade holobadge"
	desc = "A strangely green holobadge. 'Lieutenant Uriah' is stamped onto it, above the letters JS."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	icon_state = "greenbadge"

// Donation reward for Dudewithatude
/obj/item/clothing/suit/toggle/rainbowcoat
	name = "rainbow coat"
	desc = "A wonderfully brilliant coat that displays the color of the rainbow!"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "rainbowcoat"
	base_icon_state = "rainbowcoat"

// Donation reward for M97screwsyourparents
/obj/item/clothing/head/recruiter_cap
	name = "recruiter cap"
	desc = "Hey, free college!"
	icon_state = "officerhat"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	worn_icon_state = "officerhat"

// Donation reward for M97screwsyourparents
/obj/item/clothing/suit/toggle/recruiter_jacket
	name = "recruiter jacket"
	desc = "Hey, free college!"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "officerjacket"
	base_icon_state = "officerjacket"

// Donation reward for M97screwsyourparents
/obj/item/clothing/under/recruiter_uniform
	name = "recruiter uniform"
	desc = "Hey, free college!"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "oldmarine_whites"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'

//Donation reward for Tetrako
/obj/item/clothing/under/nt_idol_skirt
	name = "\improper NT Idol's suitskirt"
	desc = "This outfit resembles much the same as other ranking NT Officers, but comes with certain bells and whistles, like frills around the dress, slight puffs around the shoulders and most importantly, several golden buckles to accentuate the green! The only thing fit for NT's very own idols to wear!"
	icon = 'icons/obj/clothing/under/centcom.dmi'
	worn_icon = 'icons/mob/clothing/under/centcom.dmi'
	icon_state = "centcom_skirt"
	inhand_icon_state = "dg_suit"
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

// Donation reward for SlippyJoe
/obj/item/clothing/accessory/hypno_watch
	name = "cracked pocket watch"
	desc = "A shining pocket watch, cast in gold and embossed with metallic swirls that almost seem  amethyst under the right light... There's a button on the top to unlatch the front panel, although all that's inside is a layer of cracked glass, the argent hands stuck pointing to 7:07 PM. The brushed silver of these arrows almost seems to swirl if one's gaze lingers for too long. Despite its inert appearance, the eerie mechanical sound of gears turning and clicking in place seems to quietly ring out from the artifact. In the right hands..."
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/custom_w.dmi'
	lefthand_file = 'monkestation/icons/donator/mob/inhands/donator_left.dmi'
	righthand_file = 'monkestation/icons/donator/mob/inhands/donator_right.dmi'
	worn_icon_state = "pocketwatch"
	icon_state = "pocketwatch"
	inhand_icon_state = "pocketwatch"
	var/list/spans = list("hypnophrase")
	actions_types = list(/datum/action/item_action/hypno_whisper)

//TODO: make a component for all that various hypno stuff instead of adding it to items individually
/obj/item/clothing/accessory/hypno_watch/ui_action_click(mob/living/user, action)
	set waitfor = FALSE
	if(!isliving(user) || !can_use(user))
		return
	var/message = tgui_input_text(user, "Speak with a hypnotic whisper", "Whisper", encode = FALSE)
	if(QDELETED(src) || QDELETED(user) || !message || !user.can_speak())
		return
	user.whisper(message, spans = spans)

/obj/item/clothing/accessory/hypno_watch/examine()
	. = ..()
	. += span_boldwarning("Who knows what it could be used for?")

// Donation reward for BoisterousBeebz

/obj/item/clothing/under/bubbly_clown/skirt
	name = "bubbly clown dress"
	desc = "A bright and cheerful clown dress, honk!"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "bubbly_clown_dress"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

// Donation reward for Sweetsoulbrother
/obj/item/coin/donator/marsoc
	name = "MARSOC Challenge Coin"
	desc = "This is a challenge coin given to all MARSOC members upon honorable separation from the Corps. \
			The coin has the insignia of the Marine Special Operations Command on one side, and the Sol Federation Marine Corps logo on the other. \
			This one has an engraving on the Marine Corps logo side, etched in a circle around it: \
			\"To Staff Sargent Henry Rockwell, for his exemplary service to the Special Operations community and his outstanding moral fiber \
			and shining example to the core values of the Sol Federation Marine Corps.\""
	icon = 'monkestation/icons/donator/obj/custom.dmi'
	sideslist = list("MARSOC", "SFMC")

// Donation reward for Kay-Nite
/obj/item/clothing/under/tactichill
	name = "tactichill jacket"
	desc = "The brighter variant of the tacticool clotheswear, for when you want to look even cooler than usual and still operate at the same time."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	icon_state = "tactichill"

// Donation reward for Razurath

/obj/item/clothing/under/bimpcap
	name = "Formal Matte Black Captain Uniform"
	desc = "A professional looking matte black uniform cladded with medals of distintive service and valor, only worn by the highest of station officials."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "bimpcap"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

// Donation reward for Nikohyena
/obj/item/clothing/glasses/gold_aviators
	name = "purple and gold aviators"
	desc = "A round pair of gold aviator glasses, the lenses having been applied with a gem-like purple tint."
	worn_icon = 'monkestation/icons/donator/mob/clothing/eyes.dmi'
	icon = 'monkestation/icons/donator/obj/clothing/glasses.dmi'
	icon_state = "goldaviator"

// Donation reward for Thedragmeme
/obj/item/clothing/under/caged_dress/skirt
	name = "Caged Purple Dress"
	desc = "A silky purple dress with a partially exposed crinoline underneath."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	icon_state = "caged_dress"
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'

// Donation reward for Thedragmeme
/obj/item/clothing/suit/short_coat
	name = "Short Purple Coat"
	desc = "A short black and purple coat, mostly used for asthetics then insulating the person wearing it."
	icon_state = "short_coat"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'

// Donation reward for Thedragmeme
/obj/item/clothing/neck/flower_collar
	name = "Flower Collar"
	desc = "A purple collar with a dainty red flower attached to the right side of the item."
	icon = 'monkestation/icons/donator/obj/clothing/necklaces.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/neck.dmi'
	icon_state = "flower_collar"

// Donation reward for Sigmar Alkahest
/obj/item/clothing/under/costume/skyrat/kimono/sigmar
	name = "short-sleeved kimono"
	desc = "A traditional ancient Earth Japanese Kimono. It's white with a gold trim and burnished gold ivy pattern."
	icon_state = "kimono-gold"
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform.dmi'

// Donation reward for Sigmar Alkahest
/obj/item/clothing/head/hooded/sigmarcoat
	name = "black raincoat hood"
	desc = "Certainly makes you look more ominous."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "long-coat-hood"
	supports_variations_flags = NONE

// Donation reward for Sigmar Alkahest
/obj/item/clothing/suit/hooded/sigmarcoat
	name = "black open-faced raincoat"
	desc = "A light black raincoat. You didn't even know they're made in this color."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "long-coat"
	hoodtype = /obj/item/clothing/head/hooded/sigmarcoat
	supports_variations_flags = NONE

//reward for SomeRandomOwl
/obj/item/clothing/head/costume/strigihat
	name = "starry witch hat"
	desc = "A cute witch hat typically worn by an owl-like teshari."
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "strigihat"

//Donation reward for Razurath
/obj/item/clothing/head/razurathhat
	name = "Golden Nanotrasen Officer Cap"
	desc = "A Nanotrasen officer cap. Now darker, golder, and cooler!"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "razurath_hat"

//Donation reward for Razurath
/obj/item/clothing/suit/razurathcoat
	name = "Golden Nanotrasen Officer Coat"
	desc = "A fancy Nanotrasen officer coat. Now darker, golder, and cooler than ever!"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "razurath_coat"

// Donation reward for MaSvedish
/obj/item/clothing/mask/holocigarette/masvedishcigar
	name = "holocigar"
	desc = "A soft buzzing device that, using holodeck technology, replicates a slow burn cigar. Now with less-shock technology."
	icon = 'monkestation/icons/donator/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/mask.dmi'
	lefthand_file = 'monkestation/icons/donator/mob/inhands/donator_left.dmi'
	righthand_file = 'monkestation/icons/donator/mob/inhands/donator_right.dmi'
	inhand_icon_state = "masvedishcigar_off"
	worn_icon_state = "masvedishcigar_off"
	icon_state = "masvedishcigar_off"

// Donation reward for LT3
/obj/item/clothing/suit/armor/skyy
	name = "silver jacket mk II"
	desc = "A jacket for those with a commanding presence. Made of synthetic fabric, it's interwoven with a special alloy that provides extra protection and style."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "lt3_jacket"
	inhand_icon_state = "syndicate-black"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/suit/jacket/skyy
	name = "silver jacket"
	desc = "A jacket for those with a commanding presence. Made of synthetic fabric, it's interwoven with a special alloy that provides extra protection and style."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "lt3_jacket"
	inhand_icon_state = "syndicate-black"
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/pants/skyy
	name = "silver jeans"
	desc = "A pair of jeans for those with a commanding presence. Made of shining, silver denim, it's interwoven with a special alloy that provides extra protection and style."
	icon = 'monkestation/icons/donator/obj/clothing/uniform.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/uniform_digi.dmi'
	lefthand_file = 'monkestation/icons/donator/mob/inhands/donator_left.dmi'
	righthand_file = 'monkestation/icons/donator/mob/inhands/donator_right.dmi'
	icon_state = "lt3_jeans"
	inhand_icon_state = "lt3_jeans"

/obj/item/clothing/gloves/skyy
	name = "charcoal fingerless gloves"
	desc = "Valuing form over function, these gloves barely cover more than the palm of your hand."
	icon = 'monkestation/icons/donator/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/hands.dmi'
	icon_state = "lt3_gloves"

// Donation reward for Lolpopomg101
/obj/item/clothing/suit/hooded/colorblockhoodie
	name = "color-block hoodie"
	desc = "A soft pastel color-block hoodie from an unrecognizable brand."
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	icon_state = "colorblockhoodie"
	hoodtype = /obj/item/clothing/head/hooded/colorblockhoodie
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/head/hooded/colorblockhoodie
	name = "hood"
	desc = "Very soft on the inside!"
	icon = 'monkestation/icons/donator/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/head.dmi'
	icon_state = "colorblockhood"
	flags_inv = HIDEHAIR

/obj/item/clothing/suit/toggle/digicoat
	toggle_noun = "holo-dislpay"
	icon = 'monkestation/icons/donator/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/donator/mob/clothing/suit.dmi'
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON

//Donation reward for Razurath
/obj/item/clothing/suit/toggle/digicoat/glitched
	name = "hacked digicoat"
	desc = "Glitched images display across the back. Cool!"
	base_icon_state = "digicoat_glitched"
	icon_state = "digicoat_glitched"

/obj/item/clothing/suit/toggle/digicoat/nanotrasen
	name = "nanotrasen digicoat"
	desc = "A company jacket of popular design."
	base_icon_state = "digicoat_nt"
	icon_state = "digicoat_nt"

/obj/item/clothing/suit/toggle/digicoat/interdyne
	name = "interdyne digicoat"
	desc = "A sinister colored jacket from a familiar company."
	base_icon_state = "digicoat_interdyne"
	icon_state = "digicoat_interdyne"
