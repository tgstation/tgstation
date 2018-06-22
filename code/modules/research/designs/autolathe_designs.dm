///////////////////////////////////
//////////Autolathe Designs ///////
///////////////////////////////////

/datum/design/bucket
	name = "Bucket"
	id = "bucket"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200)
	build_path = /obj/item/reagent_containers/glass/bucket
	category = list("initial","Tools")

/datum/design/crowbar
	name = "Pocket Crowbar"
	id = "crowbar"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/crowbar
	category = list("initial","Tools")

/datum/design/flashlight
	name = "Flashlight"
	id = "flashlight"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/flashlight
	category = list("initial","Tools")

/datum/design/extinguisher
	name = "Fire Extinguisher"
	id = "extinguisher"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 90)
	build_path = /obj/item/extinguisher
	category = list("initial","Tools")

/datum/design/multitool
	name = "Multitool"
	id = "multitool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 20)
	build_path = /obj/item/multitool
	category = list("initial","Tools")

/datum/design/analyzer
	name = "Analyzer"
	id = "analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/analyzer
	category = list("initial","Tools")

/datum/design/tscanner
	name = "T-Ray Scanner"
	id = "tscanner"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/t_scanner
	category = list("initial","Tools")

/datum/design/weldingtool
	name = "Welding Tool"
	id = "welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 20)
	build_path = /obj/item/weldingtool
	category = list("initial","Tools")

/datum/design/mini_weldingtool
	name = "Emergency Welding Tool"
	id = "mini_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 10)
	build_path = /obj/item/weldingtool/mini
	category = list("initial","Tools")

/datum/design/screwdriver
	name = "Screwdriver"
	id = "screwdriver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/screwdriver
	category = list("initial","Tools")

/datum/design/wirecutters
	name = "Wirecutters"
	id = "wirecutters"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/wirecutters
	category = list("initial","Tools")

/datum/design/wrench
	name = "Wrench"
	id = "wrench"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150)
	build_path = /obj/item/wrench
	category = list("initial","Tools")

/datum/design/welding_helmet
	name = "Welding Helmet"
	id = "welding_helmet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1750, MAT_GLASS = 400)
	build_path = /obj/item/clothing/head/welding
	category = list("initial","Tools")

/datum/design/cable_coil
	name = "Cable Coil"
	id = "cable_coil"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 5)
	build_path = /obj/item/stack/cable_coil/random
	category = list("initial","Tools")
	maxstack = 30

/datum/design/toolbox
	name = "Toolbox"
	id = "tool_box"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/storage/toolbox
	category = list("initial","Tools")

/datum/design/apc_board
	name = "APC Module"
	id = "power control"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/electronics/apc
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airlock_board
	name = "Airlock Electronics"
	id = "airlock_board"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/electronics/airlock
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firelock_board
	name = "Firelock Circuitry"
	id = "firelock_board"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/electronics/firelock
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/airalarm_electronics
	name = "Air Alarm Electronics"
	id = "airalarm_electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/electronics/airalarm
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/firealarm_electronics
	name = "Fire Alarm Electronics"
	id = "firealarm_electronics"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/electronics/firealarm
	category = list("initial", "Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/camera
	name = "Camera"
	id = "camera"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 100)
	build_path = /obj/item/camera
	category = list("initial", "Misc")

/datum/design/camera_film
	name = "Camera Film Cartridge"
	id = "camera_film"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 10)
	build_path = /obj/item/camera_film
	category = list("initial", "Misc")

/datum/design/earmuffs
	name = "Earmuffs"
	id = "earmuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/clothing/ears/earmuffs
	category = list("initial", "Misc")

/datum/design/pipe_painter
	name = "Pipe Painter"
	id = "pipe_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000)
	build_path = /obj/item/pipe_painter
	category = list("initial", "Misc")

/datum/design/airlock_painter
	name = "Airlock Painter"
	id = "airlock_painter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 50)
	build_path = /obj/item/airlock_painter
	category = list("initial", "Misc")

/datum/design/metal
	name = "Metal"
	id = "metal"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/metal
	category = list("initial","Construction")
	maxstack = 50

/datum/design/glass
	name = "Glass"
	id = "glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/glass
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rglass
	name = "Reinforced Glass"
	id = "rglass"
	build_type = AUTOLATHE | SMELTER
	materials = list(MAT_METAL = 1000, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/rglass
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rods
	name = "Metal Rod"
	id = "rods"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000)
	build_path = /obj/item/stack/rods
	category = list("initial","Construction")
	maxstack = 50

/datum/design/rcd_ammo
	name = "Compressed Matter Cartridge"
	id = "rcd_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000, MAT_GLASS=8000)
	build_path = /obj/item/rcd_ammo
	category = list("initial","Construction")

/datum/design/kitchen_knife
	name = "Kitchen Knife"
	id = "kitchen_knife"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000)
	build_path = /obj/item/kitchen/knife
	category = list("initial","Dinnerware")

/datum/design/fork
	name = "Fork"
	id = "fork"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 80)
	build_path = /obj/item/kitchen/fork
	category = list("initial","Dinnerware")

/datum/design/tray
	name = "Tray"
	id = "tray"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/storage/bag/tray
	category = list("initial","Dinnerware")

/datum/design/bowl
	name = "Bowl"
	id = "bowl"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/bowl
	category = list("initial","Dinnerware")

/datum/design/drinking_glass
	name = "Drinking Glass"
	id = "drinking_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass
	category = list("initial","Dinnerware")

/datum/design/shot_glass
	name = "Shot Glass"
	id = "shot_glass"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/reagent_containers/food/drinks/drinkingglass/shotglass
	category = list("initial","Dinnerware")

/datum/design/shaker
	name = "Shaker"
	id = "shaker"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1500)
	build_path = /obj/item/reagent_containers/food/drinks/shaker
	category = list("initial","Dinnerware")

/datum/design/cultivator
	name = "Cultivator"
	id = "cultivator"
	build_type = AUTOLATHE
	materials = list(MAT_METAL=50)
	build_path = /obj/item/cultivator
	category = list("initial","Misc")

/datum/design/plant_analyzer
	name = "Plant Analyzer"
	id = "plant_analyzer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/plant_analyzer
	category = list("initial","Misc")

/datum/design/shovel
	name = "Shovel"
	id = "shovel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel
	category = list("initial","Misc")

/datum/design/spade
	name = "Spade"
	id = "spade"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50)
	build_path = /obj/item/shovel/spade
	category = list("initial","Misc")

/datum/design/hatchet
	name = "Hatchet"
	id = "hatchet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/hatchet
	category = list("initial","Misc")

/datum/design/foilhat
	name = "Tinfoil Hat"
	id = "tinfoil_hat"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5500)
	build_path = /obj/item/clothing/head/foilhat
	category = list("hacked", "Misc")

/datum/design/scalpel
	name = "Scalpel"
	id = "scalpel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 1000)
	build_path = /obj/item/scalpel
	category = list("initial", "Medical")

/datum/design/circular_saw
	name = "Circular Saw"
	id = "circular_saw"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000)
	build_path = /obj/item/circular_saw
	category = list("initial", "Medical")

/datum/design/surgicaldrill
	name = "Surgical Drill"
	id = "surgicaldrill"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 6000)
	build_path = /obj/item/surgicaldrill
	category = list("initial", "Medical")

/datum/design/retractor
	name = "Retractor"
	id = "retractor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 3000)
	build_path = /obj/item/retractor
	category = list("initial", "Medical")

/datum/design/cautery
	name = "Cautery"
	id = "cautery"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2500, MAT_GLASS = 750)
	build_path = /obj/item/cautery
	category = list("initial", "Medical")

/datum/design/hemostat
	name = "Hemostat"
	id = "hemostat"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2500)
	build_path = /obj/item/hemostat
	category = list("initial", "Medical")

/datum/design/beaker
	name = "Beaker"
	id = "beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/reagent_containers/glass/beaker
	category = list("initial", "Medical")

/datum/design/large_beaker
	name = "Large Beaker"
	id = "large_beaker"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 2500)
	build_path = /obj/item/reagent_containers/glass/beaker/large
	category = list("initial", "Medical")

/datum/design/healthanalyzer
	name = "Health Analyzer"
	id = "healthanalyzer"
	build_type = AUTOLATHE | PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/healthanalyzer
	category = list("initial", "Medical")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/pillbottle
	name = "Pill Bottle"
	id = "pillbottle"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 100)
	build_path = /obj/item/storage/pill_bottle
	category = list("initial", "Medical")

/datum/design/beanbag_slug
	name = "Beanbag Slug"
	id = "beanbag_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250)
	build_path = /obj/item/ammo_casing/shotgun/beanbag
	category = list("initial", "Security")

/datum/design/rubbershot
	name = "Rubber Shot"
	id = "rubber_shot"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/rubbershot
	category = list("initial", "Security")

/datum/design/c38
	name = "Speed Loader (.38)"
	id = "c38"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20000)
	build_path = /obj/item/ammo_box/c38
	category = list("initial", "Security")

/datum/design/recorder
	name = "Universal Recorder"
	id = "recorder"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 60, MAT_GLASS = 30)
	build_path = /obj/item/taperecorder/empty
	category = list("initial", "Misc")

/datum/design/tape
	name = "Tape"
	id = "tape"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 5)
	build_path = /obj/item/tape/random
	category = list("initial", "Misc")

/datum/design/igniter
	name = "Igniter"
	id = "igniter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/igniter
	category = list("initial", "Misc")

/datum/design/signaler
	name = "Remote Signaling Device"
	id = "signaler"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 120)
	build_path = /obj/item/assembly/signaler
	category = list("initial", "T-Comm")

/datum/design/radio_headset
	name = "Radio Headset"
	id = "radio_headset"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75)
	build_path = /obj/item/radio/headset
	category = list("initial", "T-Comm")

/datum/design/bounced_radio
	name = "Station Bounced Radio"
	id = "bounced_radio"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75, MAT_GLASS = 25)
	build_path = /obj/item/radio/off
	category = list("initial", "T-Comm")

/datum/design/intercom_frame
	name = "Intercom Frame"
	id = "intercom_frame"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75, MAT_GLASS = 25)
	build_path = /obj/item/wallframe/intercom
	category = list("initial", "T-Comm")

/datum/design/infrared_emitter
	name = "Infrared Emitter"
	id = "infrared_emitter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/assembly/infra
	category = list("initial", "Misc")

/datum/design/health_sensor
	name = "Health Sensor"
	id = "health_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/health
	category = list("initial", "Medical")

/datum/design/timer
	name = "Timer"
	id = "timer"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/timer
	category = list("initial", "Misc")

/datum/design/voice_analyser
	name = "Voice Analyser"
	id = "voice_analyser"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/assembly/voice
	category = list("initial", "Misc")

/datum/design/light_tube
	name = "Light Tube"
	id = "light_tube"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/tube
	category = list("initial", "Construction")

/datum/design/light_bulb
	name = "Light Bulb"
	id = "light_bulb"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 100)
	build_path = /obj/item/light/bulb
	category = list("initial", "Construction")

/datum/design/camera_assembly
	name = "Camera Assembly"
	id = "camera_assembly"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 400, MAT_GLASS = 250)
	build_path = /obj/item/wallframe/camera
	category = list("initial", "Construction")

/datum/design/newscaster_frame
	name = "Newscaster Frame"
	id = "newscaster_frame"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 14000, MAT_GLASS = 8000)
	build_path = /obj/item/wallframe/newscaster
	category = list("initial", "Construction")

/datum/design/syringe
	name = "Syringe"
	id = "syringe"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10, MAT_GLASS = 20)
	build_path = /obj/item/reagent_containers/syringe
	category = list("initial", "Medical")

/datum/design/prox_sensor
	name = "Proximity Sensor"
	id = "prox_sensor"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 800, MAT_GLASS = 200)
	build_path = /obj/item/assembly/prox_sensor
	category = list("initial", "Misc")

/datum/design/foam_dart
	name = "Box of Foam Darts"
	id = "foam_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/ammo_box/foambox
	category = list("initial", "Misc")

//hacked autolathe recipes
/datum/design/flamethrower
	name = "Flamethrower"
	id = "flamethrower"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/flamethrower/full
	category = list("hacked", "Security")

/datum/design/rcd
	name = "Rapid Construction Device (RCD)"
	id = "rcd"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/construction/rcd
	category = list("hacked", "Construction")

/datum/design/rpd
	name = "Rapid Pipe Dispenser (RPD)"
	id = "rpd"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 75000, MAT_GLASS = 37500)
	build_path = /obj/item/pipe_dispenser
	category = list("hacked", "Construction")

/datum/design/electropack
	name = "Electropack"
	id = "electropack"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 2500)
	build_path = /obj/item/electropack
	category = list("hacked", "Tools")

/datum/design/large_welding_tool
	name = "Industrial Welding Tool"
	id = "large_welding_tool"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 70, MAT_GLASS = 60)
	build_path = /obj/item/weldingtool/largetank
	category = list("hacked", "Tools")

/datum/design/handcuffs
	name = "Handcuffs"
	id = "handcuffs"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 500)
	build_path = /obj/item/restraints/handcuffs
	category = list("hacked", "Security")

/datum/design/receiver
	name = "Modular Receiver"
	id = "reciever"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 15000)
	build_path = /obj/item/weaponcrafting/receiver
	category = list("hacked", "Security")

/datum/design/shotgun_slug
	name = "Shotgun Slug"
	id = "shotgun_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun
	category = list("hacked", "Security")

/datum/design/buckshot_shell
	name = "Buckshot Shell"
	id = "buckshot_shell"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/buckshot
	category = list("hacked", "Security")

/datum/design/shotgun_dart
	name = "Shotgun Dart"
	id = "shotgun_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/dart
	category = list("hacked", "Security")

/datum/design/incendiary_slug
	name = "Incendiary Slug"
	id = "incendiary_slug"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 4000)
	build_path = /obj/item/ammo_casing/shotgun/incendiary
	category = list("hacked", "Security")

/datum/design/riot_dart
	name = "Foam Riot Dart"
	id = "riot_dart"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 1000) //Discount for making individually - no box = less metal!
	build_path = /obj/item/ammo_casing/caseless/foam_dart/riot
	category = list("hacked", "Security")

/datum/design/riot_darts
	name = "Foam Riot Dart Box"
	id = "riot_darts"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 50000) //Comes with 40 darts
	build_path = /obj/item/ammo_box/foambox/riot
	category = list("hacked", "Security")

/datum/design/a357
	name = "Speed Loader (.357)"
	id = "a357"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/ammo_box/a357
	category = list("hacked", "Security")

/datum/design/c10mm
	name = "Ammo Box (10mm)"
	id = "c10mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/ammo_box/c10mm
	category = list("hacked", "Security")

/datum/design/c45
	name = "Ammo Box (.45)"
	id = "c45"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/ammo_box/c45
	category = list("hacked", "Security")

/datum/design/c9mm
	name = "Ammo Box (9mm)"
	id = "c9mm"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 30000)
	build_path = /obj/item/ammo_box/c9mm
	category = list("hacked", "Security")

/datum/design/cleaver
	name = "Butcher's Cleaver"
	id = "cleaver"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 18000)
	build_path = /obj/item/kitchen/knife/butcher
	category = list("hacked", "Dinnerware")

/datum/design/spraycan
	name = "Spraycan"
	id = "spraycan"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/toy/crayon/spraycan
	category = list("initial", "Tools")

/datum/design/desttagger
	name = "Destination Tagger"
	id = "desttagger"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 250, MAT_GLASS = 125)
	build_path = /obj/item/destTagger
	category = list("initial", "Electronics")

/datum/design/handlabeler
	name = "Hand Labeler"
	id = "handlabel"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 125)
	build_path = /obj/item/hand_labeler
	category = list("initial", "Electronics")

/datum/design/geiger
	name = "Geiger Counter"
	id = "geigercounter"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 150, MAT_GLASS = 150)
	build_path = /obj/item/geiger_counter
	category = list("initial", "Tools")

/datum/design/turret_control_frame
	name = "Turret Control Frame"
	id = "turret_control"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 12000)
	build_path = /obj/item/wallframe/turret_control
	category = list("initial", "Construction")

/datum/design/conveyor_belt
	name = "Conveyor Belt"
	id = "conveyor_belt"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 5000)
	build_path = /obj/item/conveyor_construct
	category = list("initial", "Construction")

/datum/design/conveyor_switch
	name = "Conveyor Belt Switch"
	id = "conveyor_switch"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 450, MAT_GLASS = 190)
	build_path = /obj/item/conveyor_switch_construct
	category = list("initial", "Construction")

/datum/design/laptop
	name = "Laptop Frame"
	id = "laptop"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 1000)
	build_path = /obj/item/modular_computer/laptop/buildable
	category = list("initial","Misc")

/datum/design/tablet
	name = "Tablet Frame"
	id = "tablet"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/modular_computer/tablet
	category = list("initial","Misc")

/datum/design/slime_scanner
	name = "Slime Scanner"
	id = "slime_scanner"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/slime_scanner
	category = list("initial", "Misc")

/datum/design/pet_carrier
	name = "Pet Carrier"
	id = "pet_carrier"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 7500, MAT_GLASS = 100)
	build_path = /obj/item/pet_carrier
	category = list("initial", "Misc")

/datum/design/miniature_power_cell
	name = "Light Fixture Battery"
	id = "miniature_power_cell"
	build_type = AUTOLATHE
	materials = list(MAT_GLASS = 20)
	build_path = /obj/item/stock_parts/cell/emergency_light
	category = list("initial", "Electronics")

/datum/design/packageWrap
	name = "Package Wrapping"
	id = "packagewrap"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)
	build_path = /obj/item/stack/packageWrap
	category = list("initial", "Misc")
	maxstack = 30

/datum/design/holodisk
	name = "Holodisk"
	id = "holodisk"
	build_type = AUTOLATHE
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	build_path = /obj/item/disk/holodisk
	category = list("initial", "Misc")
