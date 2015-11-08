/////////////////////
// CULT STRUCTURES //
/////////////////////

/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 100 //The total health the structure has
	var/death_message = "<span class='warning'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'

/obj/structure/cult/proc/destroy_structure()
	visible_message(death_message)
	playsound(src, death_sound, 50, 1)
	qdel(src)

/obj/structure/cult/attackby(obj/item/I, mob/user, params)
	if(I.force)
		..()
		playsound(src, I.hitsound, 50, 1)
		health = Clamp(health - I.force, 0, initial(health))
		user.changeNext_move(CLICK_CD_MELEE)
		if(health <= 0)
			destroy_structure()
		return
	..()

/obj/structure/cult/talisman
	name = "sacrificial altar"
	desc = "An altar made of tough wood and draped with an ornamental, bloodstained cloth."
	icon_state = "talismanaltar"
	health = 150 //Sturdy
	death_message = "<span class='warning'>The altar breaks into splinters, releasing a cascade of spirits into the air!</span>"
	death_sound = 'sound/effects/altar_break.ogg'

/obj/structure/cult/forge
	name = "runed forge"
	desc = "A combination furnace and anvil. It glows with the heat of the lava flowing through its channel."
	icon_state = "forge"
	luminosity = 2
	health = 300 //Made of metal
	death_message = "<span class='warning'>The forge falls apart, its lava cooling and winking away!</span>"
	death_sound = 'sound/effects/forge_destroy.ogg'
	var/obj/item/anvil_object = null //The forge can modify certain objects. This variable controls what's on the anvil itself.

/obj/structure/cult/forge/examine(mob/user)
	..()
	if(anvil_object)
		user << "It has \icon[anvil_object] [anvil_object] prepared for smithing."
		if(iscultist(user))
			user << "Alt-click the forge to attempt to modify its object."

/obj/structure/cult/forge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!iscarbon(G.affecting))
			user << "<span class='warning'>You may only dunk carbon-based creatuers!</span>"
			return 0
		if(G.affecting.stat == DEAD)
			user << "<span class='warning'>[G.affecting] is dead!</span>"
			return 0
		var/mob/living/carbon/C = G.affecting
		C.visible_message("<span class='danger'>[user] dunks [C]'s face into [src]'s lava!</span>", \
						"<span class='userdanger'>[user] dunks your face into [src]'s lava!</span>")
		if(!C.stat)
			C.emote("scream")
		user.changeNext_move(CLICK_CD_MELEE)
		C.apply_damage(30, BURN, "head") //30 fire damage because it's FUCKING LAVA
		C.status_flags |= DISFIGURED //Your face is unrecognizable because it's FUCKING LAVA
		return 1
	if(user.a_intent == "harm")
		..()
	else
		if(anvil_object)
			user << "<span class='warning'>There is already an object on the anvil!</span>"
			return 0
		var/smith_or_no = alert(user,"Prepare [I] for modification? (Switch to Harm intent to attack!)",,"Yes","No")
		switch(smith_or_no)
			if("No")
				return 0
		user.visible_message("<span class='notice'>[user] places [I] onto [src]'s anvil.</span>", \
							"<span class='notice'>You prepare [I] for smithing.</span>")
		user.drop_item()
		I.loc = src
		anvil_object = I
		return 1

/obj/structure/cult/forge/attack_hand(mob/living/carbon/user)
	if(!anvil_object)
		user << "<span class='warning'>There isn't an object prepared on [src]!</span>"
		return 0
	user.visible_message("<span class='notice'>[user] removes [anvil_object] from [src].</span>", \
						"<span class='notice'>You pick up [anvil_object].</span>")
	anvil_object.loc = get_turf(src)
	user.put_in_hands(anvil_object)
	anvil_object = null

/obj/structure/cult/forge/AltClick(mob/living/user)
	if(anvil_object)
		if(!iscultist(user))
			user << "<span class='warning'>You aren't sure what to do with these tools...</span>"
			return 0
		user.visible_message("<span class='danger'>[user] brings down the anvil's hammer onto [anvil_object]!</span>", \
							"<span class='danger'>You bring down the hammer onto [anvil_object]...</span>")
		playsound(src, 'sound/effects/anvil.ogg', 50, 1)
		switch(anvil_object.type)
			if(/obj/item/weapon/bedsheet) //Standard bedsheet -> cult bedsheet
				if(!istype(anvil_object, /obj/item/weapon/bedsheet/cult)) //To prevent inception bedsheet modification
					user << "<span class='danger'>...and its cloth rapidly darkens to a more familiar color scheme.</span>"
					smith_object(/obj/item/weapon/bedsheet/cult)

			if(/obj/item/clothing/suit/space/eva) //EVA suit -> cultist navigator's armor
				user << "<span class='danger'>...and layers of runed armor form themselves on its surface."
				smith_object(/obj/item/clothing/suit/space/cult)

			if(/obj/item/clothing/head/helmet/space/eva) //EVA helmet -> cultist navigator's helmet
				user << "<span class='danger'>...and its visor turns blood-red, its material darkening with armor plates."
				smith_object(/obj/item/clothing/head/helmet/space/cult)

			if(/obj/item/weapon/twohanded/spear) //Spear -> cultist longsword
				user << "<span class='danger'>...and it contracts, its shaft shortening and tip elongating into razor-sharp runed metal.</span>"
				smith_object(/obj/item/weapon/melee/cultblade)

			if(/obj/item/weapon/book) //Book -> arcane tome
				user << "<span class='danger'>...and its pages glow with an eldritch red light, eyes emblazoning themselves on the darkening cover.</span>"
				smith_object(/obj/item/weapon/tome)

			if(/obj/item/weapon/storage/book/bible) //Bible -> accursed tome
				user << "<span class='danger'>...and its former holiness empowers its new use as an arcane tome.</span>"
				smith_object(/obj/item/weapon/tome/accursed)

			else
				user << "<span class='danger'>...but nothing happened!</span>"

/obj/structure/cult/forge/proc/smith_object(var/obj_path)
	new obj_path(get_turf(src))
	qdel(anvil_object)
	anvil_object = null

/obj/structure/cult/pylon
	name = "energy pylon"
	desc = "A hovering red crystal that thrums with energy and light. Kept aloft by two metal prongs."
	icon_state = "pylon"
	luminosity = 5
	health = 50 //Very fragile
	death_message = "<span class='warning'>The pylon's crystal vibrates and glows fiercely before violently shattering!</span>"
	death_sound = 'sound/effects/Glassbr2.ogg'

/obj/structure/cult/pylon/destroy_structure()
	var/turf/T = get_turf(src)
	..()
	for(var/mob/living/M in range(5, T))
		if(!issilicon(M))
			M.visible_message("<span class='warning'>Deadly shards of red crystal impact [M]!</span>", \
							"<span class='userdanger'>Deadly red crystal shards fly into you!</span>")
			M.adjustBruteLoss(rand(5,10))
		else
			M.visible_message("<span class='warning'>Red crystal shards bounce off of [M]'s casing!</span>", \
							"<span class='userdanger'>Red crystal shards bounce off of your casing!</span>")

/obj/structure/cult/tome
	name = "research desk"
	desc = "A writing desk covered in strange volumes written in an unknown tongue."
	icon_state = "tomealtar"
	luminosity = 1
	health = 125 //Slightly sturdy
	death_message = "<span class='warning'>The desk breaks apart, its books falling to the floor.</span>"
	death_sound = 'sound/effects/wood_break.ogg'

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that the abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1

////////////////
// CULT TURFS //
////////////////

/turf/simulated/floor/plasteel/cult
	name = "engraved floor"
	desc = "A runed floor inlaid with shifting symbols."
	icon_state = "cult"

/turf/simulated/floor/plasteel/cult/process()
	for(var/mob/living/M in src)
		if(iscultist(M)) //Cult floors heal cultists on top of them for a small amount
			M.adjustBruteLoss(-1)
			M.adjustFireLoss(-1)

/turf/simulated/floor/plasteel/cult/New()
	..()
	SSobj.processing |= src

/turf/simulated/floor/plasteel/cult/Destroy()
	SSobj.processing.Remove(src)
	..()

/turf/simulated/floor/engine/cult
	name = "engraved floor"
	desc = "A runed floor inlaid with shifting symbols."
	icon_state = "cult"

/turf/simulated/floor/engine/cult/narsie_act()
	return

/turf/simulated/floor/engine/cult/process()
	for(var/mob/living/M in src)
		if(iscultist(M)) //Cult floors heal cultists on top of them for a small amount
			M.adjustBruteLoss(-1)
			M.adjustFireLoss(-1)

/turf/simulated/floor/engine/cult/New()
	..()
	SSobj.processing |= src

/turf/simulated/floor/engine/cult/Destroy()
	SSobj.processing.Remove(src)
	..()

/turf/simulated/floor/engine/cult/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/crowbar))
		user << "<span class='warning'>[src] is too tightly pressed to pry up!</span>"
		return 0
	if(istype(I, /obj/item/weapon/nullrod))
		if(iscultist(user))
			return ..()
		user.visible_message("<span class='warning'>[user] dispels the taint from [src]!</span>", \
							"<span class='danger'>You strike [src] with [I], cleansing its cultist taint!</span>")
		ChangeTurf(/turf/simulated/floor/plasteel)
		return 1
	..()

/turf/simulated/wall/cult
	name = "engraved wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	walltype = "cult"
	builtin_sheet = null
	canSmoothWith = null

/turf/simulated/wall/cult/break_wall()
	new /obj/effect/decal/cleanable/blood(src)
	return (new /obj/structure/cultgirder(src))

/turf/simulated/wall/cult/devastate_wall()
	new /obj/effect/decal/cleanable/blood(src)
	new /obj/effect/decal/remains/human(src)

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/cult/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		user << "<span class='warning'>[src] seems immune to the heat!</span>"
		return 0
	if(istype(I, /obj/item/weapon/nullrod))
		if(iscultist(user))
			return ..()
		user.visible_message("<span class='warning'>[user] dispels the taint from [src]!</span>", \
							"<span class='danger'>You strike [src] with [I], cleansing its cultist taint!</span>")
		ChangeTurf(/turf/simulated/wall)
		return 1
	..()

////////////////
// CULT ITEMS //
////////////////

/obj/item/weapon/melee/cultblade
	name = "cultist longsword"
	desc = "A sword humming with unholy energy. It glows with a dim red light."
	icon_state = "cultblade"
	item_state = "cultblade"
	flags = CONDUCT
	w_class = 4
	force = 30
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!iscultist(user))
		user.Weaken(5)
		user.visible_message("<span class='warning'>A powerful force shoves [user] away from [target]!</span>", \
							 "<span class='cult'>\"You shouldn't play with sharp things. You'll poke someone's eye out.\"</span>")
		user << "<span class='warning'>A powerful force shoves the sword's blade backwards into your arm!</span>"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(rand(force/2, force), BRUTE, pick("l_arm", "r_arm"))
		else
			user.adjustBruteLoss(rand(force/2,force))
		return
	..()

/obj/item/weapon/melee/cultblade/pickup(mob/living/user)
	if(!iscultist(user))
		user << "<span class='cult'>\"I wouldn't advise that.\"</span>"
		user << "<span class='warning'>An overwhelming sense of nausea overpowers you!</span>"
		user.Dizzy(120)

/obj/item/clothing/head/culthood
	name = "ancient cultist hood"
	icon_state = "culthood"
	desc = "A torn, dust-caked hood. Strange letters line the inside."
	flags_inv = HIDEFACE
	flags_cover = HEADCOVERSEYES
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT

/obj/item/clothing/suit/cultrobes
	name = "ancient cultist robes"
	desc = "A ragged, dusty set of robes. Strange letters line the inside."
	icon_state = "cultrobes"
	item_state = "cultrobes"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|ARMS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|ARMS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT

/obj/item/clothing/head/culthood/alt
	name = "cultist invoker's hood"
	desc = "An armored hood worn by the followers of Nar-Sie."
	icon_state = "cult_hoodalt"
	item_state = "cult_hoodalt"

/obj/item/clothing/suit/cultrobes/alt
	name = "cultist invoker's hood"
	desc = "An armored set of robes worn by the followers of Nar-Sie."
	icon_state = "cultrobesalt"
	item_state = "cultrobesalt"

/obj/item/clothing/head/magus
	name = "magus helm"
	icon_state = "magus"
	item_state = "magus"
	desc = "A helm worn by the followers of Nar-Sie."
	flags_inv = HIDEFACE
	flags = BLOCKHAIR
	armor = list(melee = 30, bullet = 30, laser = 30,energy = 20, bomb = 0, bio = 0, rad = 0)
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/suit/magusred
	name = "magus robes"
	desc = "A set of armored robes worn by the followers of Nar-Sie."
	icon_state = "magusred"
	item_state = "magusred"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/head/helmet/space/cult
	name = "cultist navigator's helmet"
	desc = "A heavily-armored helmet worn by warriors of Nar-Sie. It can withstand hard vacuum."
	icon_state = "cult_helmet"
	item_state = "cult_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 30)

/obj/item/clothing/suit/space/cult
	name = "cultist navigator's armor"
	icon_state = "cult_armor"
	item_state = "cult_armor"
	desc = "A heavily-armored exosuit worn by warriors of Nar-Sie. It can withstand hard vacuum."
	w_class = 3
	allowed = list(/obj/item/weapon/tome,/obj/item/weapon/melee/cultblade,/obj/item/weapon/tank/internals/)
	armor = list(melee = 70, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 100, rad = 30)

/////////////////
// RUNED METAL //
/////////////////

var/global/list/datum/stack_recipe/runed_metal_recipes = list ( \
	new/datum/stack_recipe("pylon", /obj/structure/cult/pylon, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("forge", /obj/structure/cult/forge, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("archives", /obj/structure/cult/tome, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	new/datum/stack_recipe("altar", /obj/structure/cult/talisman, 5, time = 25, one_per_turf = 1, on_floor = 1), \
	)

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of unsettlingly cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal"
	icon_state = "sheet-runed"
	icon = 'icons/obj/items.dmi'
	sheettype = "runed"

/obj/item/stack/sheet/runed_metal/New(var/loc, var/amount=null)
	recipes = runed_metal_recipes
	return ..()

/obj/item/stack/sheet/runed_metal/attack_self(mob/user)
	if(!iscultist(user))
		user << "<span class='warning'>[src] can't seem to be manipulated...</span>"
		return
	..()

/obj/item/stack/sheet/runed_metal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/nullrod) && !iscultist(user))
		user.visible_message("<span class='warning'>[user] dispels the taint from [src]!</span>", \
							"<span class='danger'>You strike [src] with [I], cleansing its cultist taint!</span>")
		var/obj/item/stack/sheet/metal/M = new(get_turf(src))
		M.amount = amount
		qdel(src)
		return 1
	..()
