// Shotgun

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A 12 gauge lead slug."
	icon_state = "blshell"
	worn_icon_state = "shell"
	caliber = CALIBER_SHOTGUN
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)
	projectile_type = /obj/projectile/bullet/shotgun_slug

/obj/item/ammo_casing/shotgun/syndie
	name = "syndicate shotgun slug"
	desc = "An illegal 12-gauge slug produced by the Syndicate."
	icon_state = "sblshell"
	projectile_type = /obj/projectile/bullet/shotgun/slug/syndie

/obj/item/ammo_casing/shotgun/buckshot/syndie
	name = "syndicate buckshot shell"
	desc = "An illegal 12-gauge buckshot shell produced by the Syndicate."
	icon_state = "sgshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/syndie

/obj/item/ammo_casing/shotgun/flechette
	name = "flechette shell"
	desc = "A 12-gauge flechette shell."
	icon_state = "flshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_flechette
	pellets = 6
	variance = 10

/obj/item/ammo_casing/shotgun/executioner
	name = "executioner slug"
	desc = "A 12 gauge lead slug purpose built to annihilate flesh on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/executioner

/obj/item/ammo_casing/shotgun/pulverizer
	name = "pulverizer slug"
	desc = "A 12 gauge lead slug purpose built to annihilate bones on impact."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_slug/pulverizer

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A weak beanbag slug for riot control."
	icon_state = "bshell"
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)
	projectile_type = /obj/projectile/bullet/shotgun_beanbag

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "An incendiary-coated shotgun slug."
	icon_state = "ishell"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun

/obj/item/ammo_casing/shotgun/incendiary/no_trail
	name = "precision incendiary slug"
	desc = "An incendiary-coated shotgun slug, specially treated to only ignite on impact."
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/no_trail

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/laserbuckshot
	name = "laser buckshot"
	desc = "An advanced shotgun shell that uses micro lasers to replicate the effects of a laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/projectile/beam/laser/buckshot
	pellets = 5
	variance = 30

/obj/item/ammo_casing/shotgun/uraniumpenetrator
	name = "depleted uranium slug"
	desc = "A relatively low-tech shell, utilizing the unique properties of Uranium, and possessing \
	very impressive armor penetration capabilities."
	icon_state = "dushell"
	projectile_type = /obj/projectile/bullet/shotgun/slug/uranium

/obj/item/ammo_casing/shotgun/cryoshot
	name = "cryoshot shell"
	desc = "A state-of-the-art shell which uses the cooling power of Cryogelidia to snap freeze a target, without causing \
	them much harm."
	icon_state = "fshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_cryoshot
	pellets = 4
	variance = 30

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A stunning taser slug."
	icon_state = "stunshell"
	projectile_type = /obj/projectile/bullet/shotgun_stunslug
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2.5)

/obj/item/ammo_casing/shotgun/meteorslug
	name = "meteorslug shell"
	desc = "A shotgun shell rigged with CMC technology, which launches a massive slug when fired."
	icon_state = "mshell"
	projectile_type = /obj/projectile/bullet/cannonball/meteorslug

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/projectile/beam/pulse/shotgun

/obj/item/ammo_casing/shotgun/frag12
	name = "FRAG-12 slug"
	desc = "A high explosive breaching round for a 12 gauge shotgun."
	icon_state = "heshell"
	projectile_type = /obj/projectile/bullet/shotgun_frag12

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell"
	desc = "A 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 25

/obj/item/ammo_casing/shotgun/buckshot/spent
	projectile_type = null

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "rshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 20
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)

/obj/item/ammo_casing/shotgun/incapacitate
	name = "custom incapacitating shot"
	desc = "A shotgun casing filled with... something. used to incapacitate targets."
	icon_state = "bountyshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_incapacitate
	pellets = 12//double the pellets, but half the stun power of each, which makes this best for just dumping right in someone's face.
	variance = 25
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "A homemade shotgun casing filled with crushed glass, used to commmit vandalism and property damage."
	icon_state = "improvshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_improvised
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*2, /datum/material/glass=SMALL_MATERIAL_AMOUNT*1)
	pellets = 6
	variance = 30

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "An advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/scatterlaser
	name = "scatter laser shell"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a scatter laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/projectile/beam/scatter
	pellets = 6
	variance = 35

/obj/item/ammo_casing/shotgun/scatterlaser/emp_act(severity)
	. = ..()
	if(isnull(loaded_projectile) || !prob(40/severity))
		return
	name = "malfunctioning laser shell"
	desc = "An advanced shotgun shell that uses a micro laser to replicate the effects of a scatter laser weapon in a ballistic package. The capacitor powering this assembly appears to be smoking."
	projectile_type = /obj/projectile/beam/scatter/pathetic
	loaded_projectile = new projectile_type(src)

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded technological shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null

/obj/item/ammo_casing/shotgun/techshell/Initialize(mapload)
	. = ..()

	var/static/list/slapcraft_recipe_list = list(/datum/crafting_recipe/meteorslug, /datum/crafting_recipe/pulseslug, /datum/crafting_recipe/dragonsbreath, /datum/crafting_recipe/ionslug)

	AddComponent(
		/datum/component/slapcrafting,\
		slapcraft_recipes = slapcraft_recipe_list,\
	)

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A dart for use in shotguns. Can be injected with up to 15 units of any chemical."
	icon_state = "cshell"
	projectile_type = /obj/projectile/bullet/dart
	var/reagent_amount = 15

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "An improved shotgun dart filled with deadly toxins. Can be injected with up to 30 units of any chemical."
	reagent_amount = 30

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)

/obj/item/ammo_casing/shotgun/breacher
	name = "breaching slug"
	desc = "A 12 gauge anti-material slug. Great for breaching airlocks and windows, quickly and efficiently."
	icon_state = "breacher"
	projectile_type = /obj/projectile/bullet/shotgun_breaching
	custom_materials = list(/datum/material/iron=SHEET_MATERIAL_AMOUNT*2)

/obj/item/ammo_casing/shotgun/thundershot
	name = "thunder slug"
	desc = "An advanced shotgun shell that uses stored electrical energy to discharge a massive shock on impact, arcing to nearby targets."
	icon_state = "Thshell"
	pellets = 3
	variance = 25
	projectile_type = /obj/projectile/bullet/pellet/shotgun_thundershot

/obj/item/ammo_casing/shotgun/hardlight
	name = "hardlight shell"
	desc = "An advanced shotgun shell that fires a hardlight beam and scatters it."
	icon_state = "hshell"
	projectile_type = /obj/projectile/bullet/pellet/hardlight
	harmful = FALSE
	pellets = 6
	variance = 20

/obj/item/ammo_casing/shotgun/hardlight/emp_act(severity)
	if (. & EMP_PROTECT_SELF)
		return
	variance = initial(variance) + severity*4 // yikes
	if(severity > EMP_LIGHT)
		pellets = initial(pellets) * (0.5**(severity / EMP_HEAVY)) // also yikes
	addtimer(CALLBACK(src, PROC_REF(remove_emp)), severity SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/item/ammo_casing/shotgun/hardlight/proc/remove_emp()
	variance = initial(variance)
	pellets = initial(pellets)

/obj/item/ammo_casing/shotgun/rip //two pellet slug bc why not
	name = "ripslug shell"
	desc = "An advanced shotgun shell that uses a narrow choke in the shell to split the slug in two.\
	This makes them less able to break through armor, but really hurts everywhere else."
	icon_state = "rsshell"
	projectile_type = /obj/projectile/bullet/shotgun/slug/rip
	pellets = 2
	variance = 3 // the tight spread

/obj/item/ammo_casing/shotgun/anarchy
	name = "anarchy shell"
	desc = "An advanced shotgun shell that has low impact damage, wide spread, and loads of pellets that bounce everywhere. Good luck"
	icon_state = "anashell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_anarchy
	pellets = 10 // AWOOGA!!
	variance = 50

/obj/item/ammo_casing/shotgun/clownshot
	name = "buckshot shell..?"
	desc = "This feels a little light for a buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_clownshot
	pellets = 20
	variance = 35
