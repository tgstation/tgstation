// Basic materials and elements obtainable through mining. Most of them are useable as construction materials.
#define MAT_iron "iron"
/datum/mat/iron
	id = MAT_iron
	name = "Iron"
	specific_heat = 10
	state = SOLID
	value = 1
	desc = "An extremely versatile, ductile, and durable metal."
	color = "#555555"
	alpha = 255
	robustness = 100

#define MAT_liq_iron "liq_iron"
/datum/mat/iron/liquid
	id = MAT_liq_iron
	name = "Molten Iron"
	state = LIQUID
	desc = "An extremely versatile, ductile, and durable metal. It's white hot."
	color = "#FFDDAA" // FDA approved for consumption.
	robustness = 0 // It has no structural value.

#define MAT_rust "rust"
/datum/mat/iron/rusted
	id = MAT_rust
	name = "Rust"
	desc = "An extremely versatile, ductile, and durable metal. Or it used to be... It's quite flammable."
	color = "#774433"
	robustness = 1 // As walls rust they become easier to break.

#define MAT_alum "alum"
/datum/mat/aluminium
	id = MAT_alum
	name = "Aluminium"
	specific_heat = 20 // Useful for buffing heat resistance, at cost of robustness.
	state = SOLID
	value = 1
	desc = "An extremely versatile, ductile, and rust-resistant metal."
	color = "#999999"
	alpha = 255
	robustness = 75 // Weakens the alloy slightly.

#define MAT_liq_alum "liq_alum"
/datum/mat/aluminium/liquid
	id = MAT_liq_alum
	name = "Molten Aluminium"
	state = LIQUID
	color = "#DDCCBB"
	robustness = 0

#define MAT_titanium "titanium"
/datum/mat/titanium
	id = MAT_titanium
	name = "Titanium"
	specific_heat = 30 // Better than aluminium for alloying.
	state = SOLID
	value = 5
	desc = "A very durable, lightweight, and rust-resistant metal."
	color = "#AAAAAA"
	alpha = 255
	robustness = 150 // Strengthens the alloy slightly.

#define MAT_liq_titanium "liq_titanium"
/datum/mat/titanium/liquid
	id = MAT_liq_titanium
	name = "Molten Titanium"
	state = LIQUID
	color = "#DDCCBB"
	robustness = 0

#define MAT_uranium "uranium"
/datum/mat/uranium
	id = MAT_uranium
	name = "Uranium"
	specific_heat = 2 // Heats up very fast.
	state = SOLID
	value = 30
	desc = "A very heavy, radioactive material."
	color = "#227722"
	alpha = 255
	robustness = 50 // It's sort of useful. I guess.

#define MAT_liq_uranium "liq_uranium"
/datum/mat/uranium/liquid
	id = MAT_liq_uranium
	name = "Molten Uranium"
	state = LIQUID
	color = "#DDDD00"
	robustness = 0

#define MAT_copper "copper"
/datum/mat/copper
	id = MAT_copper
	name = "Copper"
	specific_heat = 6
	state = SOLID
	value = 1
	desc = "A very conductive, ductile, and rust-proof metal."
	color = "#CC8833"
	alpha = 255
	robustness = 25 // It's very weak.

#define MAT_liq_copper "liq_copper"
/datum/mat/copper/liquid
	id = MAT_liq_copper
	name = "Molten Copper"
	state = LIQUID
	color = "#FFDDAA"
	robustness = 0

#define MAT_silver "silver"
/datum/mat/silver
	id = MAT_silver
	name = "Silver"
	specific_heat = 4
	state = SOLID
	value = 5
	desc = "A very conductive, ductile, and rust-proof metal."
	color = "#EEEEEE"
	alpha = 255
	robustness = 17.5

#define MAT_liq_silver "liq_silver"
/datum/mat/silver/liquid
	id = MAT_liq_silver
	name = "Molten Silver"
	state = LIQUID
	robustness = 0

#define MAT_gold "gold"
/datum/mat/gold
	id = MAT_gold
	name = "Gold"
	specific_heat = 2
	state = SOLID
	value = 10
	desc = "A very soft, ductile, and rust-proof metal."
	color = "#FFCC00"
	alpha = 255
	robustness = 10

#define MAT_liq_gold "liq_gold"
/datum/mat/gold/liquid
	id = MAT_liq_gold
	name = "Molten Gold"
	state = LIQUID
	robustness = 0

#define MAT_platinum "platinum"
/datum/mat/gold
	id = MAT_platinum
	name = "Platinum"
	specific_heat = 5
	state = SOLID
	value = 30
	desc = "A very reactive, ductile, and rust-proof metal."
	color = "#EEEEFF"
	alpha = 255
	robustness = 25

#define MAT_liq_platinum "liq_platinum"
/datum/mat/gold/liquid
	id = MAT_liq_platinum
	name = "Molten Platinum"
	state = LIQUID
	robustness = 0

#define MAT_mercury "mercury"
/datum/mat/mercury
	id = MAT_mercury
	name = "Mercury"
	specific_heat = 2
	state = LIQUID
	value = 5
	desc = "An extremely toxic, heavy metal which exists in a natural liquid state."
	color = "#EEEEEE"
	alpha = 255

#define MAT_gas_mercury "gas_mercury"
/datum/mat/mercury/gas
	id = MAT_gas_mercury
	name = "Mercury Vapour"
	desc = "An extremely toxic, heavy metal vapour."
	state = PLASMA
	alpha = 64

#define MAT_wood "wood"
/datum/mat/wood
	id = MAT_wood
	name = "Wood"
	specific_heat = 40 // Aside from being flammable, this is pretty good.
	state = SOLID
	value = 1
	desc = "An organic structural material. Typically used to provide a rustic home-y feel."
	color = "#CC9955"
	alpha = 255
	robustness = 50

#define MAT_mineral "mineral" // Default Asteroid. Consists of SiO primarily.
/datum/mat/mineral
	id = MAT_mineral
	name = "Sandstone"
	specific_heat = 10
	state = SOLID
	value = 0 // Worthless.
	desc = "A mineral composed primarily of silicon dioxide. It can be found on many asteroids."
	color = "#EECC66"
	alpha = 255
	robustness = 25

#define MAT_glass "glass" // Made from SiO
/datum/mat/glass
	id = MAT_glass
	name = "Glass"
	specific_heat = 20
	state = SOLID
	value = 1
	desc = "A hard transparent material composed primarily of silicon dioxide."
	color = "#99EEDD"
	alpha = 128
	robustness = 30 // a bit tougher than sandstone

#define MAT_liq_glass "liq_glass"
/datum/mat/glass/liquid
	id = MAT_liq_glass
	name = "Molten Glass"
	state = LIQUID
	desc = "A molten transparent material composed primarily of silicon dioxide."
	color = "#EEFFFF"
	robustness = 0

#define MAT_basalt "basalt" // Consists of MgO, CaO, and a small amount of SiO
/datum/mat/basalt
	id = MAT_basalt
	name = "Basalt"
	specific_heat = 50
	state = SOLID
	value = 0 // worthless.
	desc = "A hard igneous stone material consisting of a variety of different minerals."
	color = "#555555"
	alpha = 255
	robustness = 40 // A bit stronger than sandstone.

#define MAT_magma "magma" // Molten Basalt.
/datum/mat/basalt/liquid
	id = MAT_magma
	name = "Magma"
	state = LIQUID
	desc = "A slow moving fluid consisting of molten slag and other minerals."
	color = "#FF7711"
	alpha = 255
	robustness = 0

#define MAT_diamond "diamond"
/datum/mat/diamond
	id = MAT_diamond
	name = "Diamond"
	specific_heat = 10
	state = SOLID
	value = 50
	desc = "An ultra-hard carbon-based crystal."
	color = "#BBEEFF"
	alpha = 240
	robustness = 1000 // If you're gunna waste it. Might as well make it worthwhile.

// EXOTIC MINERALS START HERE //

#define MAT_xenoresin "xenoresin" // Produced by xenomorphs. It heats up on its own.
/datum/mat/xenoresin
	id = MAT_xenoresin
	name = "Xeno-Resin"
	specific_heat = 25
	state = LIQUID
	value = 15
	desc = "A dark sticky resin of unknown origin."
	color = "#665588"
	alpha = 240
	robustness = 25 // It's not very strong, but it's still a 'liquid'.

#define MAT_xenocarbide "xenocarbide" // Made from xenoresin. It's stronger than plasma-metal alloys.
/datum/mat/xenocarbide
	id = MAT_xenocarbide
	name = "Xeno-Carbide"
	specific_heat = 50
	state = SOLID
	value = 20
	desc = "A dark, ultra-hard material of unknown origin."
	color = "#333344"
	alpha = 255
	robustness = 600 // A bit stronger than plasteel.

#define MAT_xenochitin "xenochitin"
/datum/mat/xenochitin
	id = MAT_xenochitin
	name = "Xeno-Chitin"
	specific_heat = 50
	state = SOLID
	value = 25
	desc = "A dark, hard, organic chitinous material of unknown origin."
	color = "#333344"
	alpha = 255
	robustness = 300 // Half the strength of xenocarbide. But easier to work with.

#define MAT_goliath "goliath"
/datum/mat/goliath
	id = MAT_goliath
	name = "Goliath Chitin"
	specific_heat = 250
	state = SOLID
	value = 15
	desc = "A hard chitinous material collected from the corpse of a goliath. It's quite durable and heat resistant."
	color = "#773322"
	alpha = 255
	robustness = 200

#define MAT_adamantine "adamantine"
/datum/mat/adamantine
	id = MAT_adamantine
	name = "Adamantine"
	specific_heat = 100
	state = SOLID
	value = 40
	desc = "A heavy, ultra-hard metallic material. It seems to sparkle with strange energy."
	color = "#662222"
	alpha = 255
	robustness = 1000 // It's really fuckin' hard. But still beaten by hypersteel.

#define MAT_mithril "mithril"
/datum/mat/mithril
	id = MAT_mithril
	name = "Mithril"
	specific_heat = 50
	state = SOLID
	value = 50
	desc = "A shiny, light, and ultra-hard metallic alloy. It seems to sparkle with strange energy."
	color = "#FFAAAA"
	alpha = 255
	robustness = 800 // Not as strong as adamantine. But still very strong.

#define MAT_bananium "bananium"
/datum/mat/bananium
	id = MAT_bananium
	name = "Bananium"
	specific_heat = 20
	state = SOLID
	value = 50
	desc = "A strange yellow material. You feel a sense of impending doom just looking at it."
	color = "#FFFF00"
	alpha = 255
	robustness = 200

#define MAT_abductor "abductor"
/datum/mat/abductor
	id = MAT_abductor
	name = "Alien Alloy"
	specific_heat = 5000 // Great for toxins and engineering.
	state = SOLID
	value = 50
	desc = "A very strong and heat resistant metal alloy of unknown origin."
	color = "#665588"
	alpha = 255
	robustness = 1500 // Three times as strong as plasteel.

#define MAT_adminium "adminium"
/datum/mat/adminium
	id = MAT_adminium
	name = "Adminium"
	specific_heat = -1
	state = SOLID
	value = -1
	desc = "An ultra-hard material of unknown origin. How did it get here?"
	color = "#888888"
	alpha = 255
	robustness = -1