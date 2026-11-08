// Generated from the vibestation13 periodic table data. Element facts are real; game effects are not.

/**
 * Every element missing from upstream /tg/, as a reagent.
 *
 * The 24 elements upstream already has (hydrogen, carbon, iron, gold, uranium and so on) keep their
 * own types; GLOB.periodic_table maps all 118 atomic numbers to the right reagent either way.
 *
 * Three families, picked by what the element does to you:
 * - /datum/reagent/element: inert or near enough.
 * - /datum/reagent/toxin/element: heavy-metal style poisons, using the normal toxin and liver handling.
 * - /datum/reagent/uranium/element: radioactive, reusing uranium's irradiation and contamination code.
 *
 * None of them spawn in random sources (maint pills, geysers, strange seeds), and the toxic and
 * radioactive ones stay out of the randomised secret recipes, so adding 94 reagents doesn't
 * reshape the existing random pools.
 */

/datum/reagent/element
	abstract_type = /datum/reagent/element
	taste_description = "metal"
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM

/datum/reagent/toxin/element
	abstract_type = /datum/reagent/toxin/element
	taste_description = "metal"
	toxpwr = 1
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM

/datum/reagent/uranium/element
	abstract_type = /datum/reagent/uranium/element
	taste_description = "the inside of a reactor"
	material = null
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED|REAGENT_NO_RANDOM_RECIPE
	randomized_spawns = REAGENT_SPAWN_NO_RANDOM

/datum/reagent/element/helium
	name = "Helium"
	description = "A colourless, odourless noble gas lighter than air. Mostly wasted on party balloons."
	color = "#FFE9C9"
	taste_mult = 0

/datum/reagent/element/helium/expose_turf(turf/open/exposed_turf, reac_volume)
	. = ..()
	if(istype(exposed_turf))
		exposed_turf.atmos_spawn_air("[GAS_HELIUM]=[reac_volume/20];[TURF_TEMPERATURE(holder ? holder.chem_temp : T20C)]")

/datum/reagent/toxin/element/beryllium
	name = "Beryllium"
	description = "A light, rigid grey metal with a sweet taste. Do not trust the sweet taste: beryllium is highly toxic."
	color = "#C9CFC9"
	taste_description = "sweet metal"
	toxpwr = 1

/datum/reagent/element/boron
	name = "Boron"
	description = "A brittle, dark brown metalloid. Its compounds turn up in everything from borosilicate glass to cockroach powder."
	color = "#52372A"
	taste_description = "chalk"

/datum/reagent/element/neon
	name = "Neon"
	description = "An inert noble gas that glows a vivid red-orange under current. The signage industry thanks it."
	color = "#FF4B2B"
	taste_mult = 0

/datum/reagent/element/magnesium
	name = "Magnesium"
	description = "A light silvery metal that burns with a blinding white flame. Keep it away from welders."
	color = "#C2C4C6"
	taste_description = "metal"

/datum/reagent/element/argon
	name = "Argon"
	description = "A colourless, inert noble gas. Makes up nearly one percent of a planetary atmosphere and is used to shield welds."
	color = "#C9B4E6"
	taste_mult = 0

/datum/reagent/element/calcium
	name = "Calcium"
	description = "A soft, dull grey alkaline earth metal. Bones are full of it, which skeletons will happily tell you about."
	color = "#E8E4DC"
	taste_description = "chalk"

/datum/reagent/element/scandium
	name = "Scandium"
	description = "A soft, silvery transition metal, usually alloyed with aluminium to make sports gear lighter."
	color = "#D4D4D0"
	taste_description = "metal"

/datum/reagent/element/titanium
	name = "Titanium"
	description = "A strong, light, corrosion-resistant metal. Shuttle hulls are made from it."
	color = "#A7A9AC"
	taste_description = "metal"
	material = /datum/material/titanium

/datum/reagent/element/vanadium
	name = "Vanadium"
	description = "A hard, silvery-grey metal that toughens steel. Its compounds come in a rainbow of colours."
	color = "#A4A8AC"
	taste_description = "metal"

/datum/reagent/element/chromium
	name = "Chromium"
	description = "A hard, lustrous, steel-grey metal. It is what makes stainless steel stainless and chrome shiny."
	color = "#B8C2CC"
	taste_description = "metal"

/datum/reagent/element/manganese
	name = "Manganese"
	description = "A hard, brittle, silvery metal essential to steelmaking."
	color = "#9C9C9C"
	taste_description = "metal"

/datum/reagent/toxin/element/cobalt
	name = "Cobalt"
	description = "A hard, lustrous, bluish-grey metal. The source of cobalt blue pigment, and mildly toxic in quantity."
	color = "#3D59AB"
	taste_description = "metal"
	toxpwr = 0.5

/datum/reagent/element/nickel
	name = "Nickel"
	description = "A silvery-white, slightly golden metal. Hard, ductile and very resistant to corrosion."
	color = "#B5B09F"
	taste_description = "coins"

/datum/reagent/element/zinc
	name = "Zinc"
	description = "A bluish-grey metal used to galvanise steel against rust. Good for the immune system in small doses."
	color = "#BAC4C8"
	taste_description = "metal"

/datum/reagent/element/gallium
	name = "Gallium"
	description = "A soft, silvery metal that melts at just under thirty degrees Celsius. It will melt in your hand."
	color = "#C9CFD4"
	taste_description = "metal"

/datum/reagent/element/germanium
	name = "Germanium"
	description = "A lustrous, hard, greyish-white metalloid. A staple of early semiconductors and infrared optics."
	color = "#8F8F8F"
	taste_description = "metal"

/datum/reagent/toxin/element/arsenic
	name = "Arsenic"
	description = "A grey metalloid and the classic poisoner's poison. A favourite of inheritance plots since antiquity."
	color = "#6B6B6B"
	taste_description = "garlic"
	toxpwr = 2

/datum/reagent/toxin/element/selenium
	name = "Selenium"
	description = "A red-grey nonmetal used in photocells. Essential in trace amounts and toxic past them."
	color = "#8B1A1A"
	taste_description = "rotten radishes"
	toxpwr = 0.5

/datum/reagent/element/krypton
	name = "Krypton"
	description = "A colourless, inert noble gas that glows a whitish blue in discharge lamps. No relation to any superhero's home world."
	color = "#E6F2FF"
	taste_mult = 0

/datum/reagent/element/rubidium
	name = "Rubidium"
	description = "A soft, silvery alkali metal that ignites in air and reacts violently with water. Store it under oil."
	color = "#B3B3B3"
	taste_description = "soapy metal"

/datum/reagent/element/strontium
	name = "Strontium"
	description = "A soft, silvery-yellow alkaline earth metal. Its salts give fireworks and flares their red colour."
	color = "#D9D9C6"
	taste_description = "metal"

/datum/reagent/element/yttrium
	name = "Yttrium"
	description = "A silvery transition metal found in red phosphors and high-temperature superconductors."
	color = "#C8C8C8"
	taste_description = "metal"

/datum/reagent/element/zirconium
	name = "Zirconium"
	description = "A strong, corrosion-resistant grey metal. Reactor fuel rods are clad in it because it barely absorbs neutrons."
	color = "#C4C4C0"
	taste_description = "metal"

/datum/reagent/element/niobium
	name = "Niobium"
	description = "A soft, grey, ductile metal used in superconducting magnets and jet engines."
	color = "#A3A3B8"
	taste_description = "metal"

/datum/reagent/element/molybdenum
	name = "Molybdenum"
	description = "A silvery refractory metal with one of the highest melting points of any element."
	color = "#9CA3A8"
	taste_description = "metal"

/datum/reagent/uranium/element/technetium
	name = "Technetium"
	description = "The lightest element with no stable isotopes. Every gram of it was made in a reactor."
	color = "#A8A8A8"
	taste_description = "the inside of a reactor"
	rad_power = 1
	tox_damage = 0.25

/datum/reagent/element/ruthenium
	name = "Ruthenium"
	description = "A rare, hard, white platinum-group metal used to harden other precious metals."
	color = "#BCBCBC"
	taste_description = "expensive metal"

/datum/reagent/element/rhodium
	name = "Rhodium"
	description = "A rare, silvery-white, highly reflective platinum-group metal. Often worth more than gold."
	color = "#D6D6D6"
	taste_description = "very expensive metal"

/datum/reagent/element/palladium
	name = "Palladium"
	description = "A rare, lustrous, silvery-white metal that soaks up hydrogen like a sponge."
	color = "#CED0DD"
	taste_description = "expensive metal"

/datum/reagent/toxin/element/cadmium
	name = "Cadmium"
	description = "A soft, bluish-white metal once used in batteries and yellow paint. Severely toxic and very slow to leave the body."
	color = "#B8B8C8"
	taste_description = "metal"
	toxpwr = 2

/datum/reagent/element/indium
	name = "Indium"
	description = "A very soft, silvery metal that squeals when bent. Touchscreens rely on it."
	color = "#C2C2D1"
	taste_description = "metal"

/datum/reagent/element/tin
	name = "Tin"
	description = "A soft, silvery metal used in solder and bronze. It crumbles into grey powder in the deep cold."
	color = "#D3D4D5"
	taste_description = "tin cans"

/datum/reagent/toxin/element/antimony
	name = "Antimony"
	description = "A lustrous, grey metalloid used in flame retardants and old cosmetics. Toxic, much like arsenic."
	color = "#9E9EA8"
	taste_description = "metal"
	toxpwr = 1

/datum/reagent/toxin/element/tellurium
	name = "Tellurium"
	description = "A brittle, silvery-white metalloid. Exposure leaves a garlic smell on the breath for weeks."
	color = "#B5B5B5"
	taste_description = "garlic"
	toxpwr = 0.5

/datum/reagent/element/xenon
	name = "Xenon"
	description = "A dense, colourless noble gas used in bright arc lamps, ion thrusters and anaesthesia."
	color = "#B8D4FF"
	taste_mult = 0

/datum/reagent/element/caesium
	name = "Caesium"
	description = "A soft, pale gold alkali metal that melts on a warm day and explodes on contact with water. Atomic clocks tick on it."
	color = "#E0C878"
	taste_description = "soapy metal"

/datum/reagent/toxin/element/barium
	name = "Barium"
	description = "A soft, silvery alkaline earth metal. Its soluble compounds are toxic; the insoluble sulfate shows up in X-ray contrast."
	color = "#C8C8B0"
	taste_description = "chalk"
	toxpwr = 1

/datum/reagent/element/lanthanum
	name = "Lanthanum"
	description = "A soft, silvery-white metal that gives the lanthanide series its name. Used in camera lenses and lighter flints."
	color = "#D0D0C8"
	taste_description = "metal"

/datum/reagent/element/cerium
	name = "Cerium"
	description = "The most abundant rare earth. Scraped cerium alloy throws the sparks in a lighter flint."
	color = "#D4D0C0"
	taste_description = "metal"

/datum/reagent/element/praseodymium
	name = "Praseodymium"
	description = "A soft, silvery rare earth metal that develops a green oxide coating. It tints welder's goggles."
	color = "#C0C8B0"
	taste_description = "metal"

/datum/reagent/element/neodymium
	name = "Neodymium"
	description = "A silvery rare earth metal. Neodymium magnets are the strongest permanent magnets in common use."
	color = "#C8C0C8"
	taste_description = "metal"

/datum/reagent/uranium/element/promethium
	name = "Promethium"
	description = "A radioactive rare earth with no stable isotopes. It once lit the dials of watches."
	color = "#C0D0C0"
	taste_description = "the inside of a reactor"
	rad_power = 1
	tox_damage = 0.25

/datum/reagent/element/samarium
	name = "Samarium"
	description = "A moderately hard, silvery rare earth metal used in powerful heat-resistant magnets."
	color = "#D0D0C0"
	taste_description = "metal"

/datum/reagent/element/europium
	name = "Europium"
	description = "The most reactive rare earth. Its red phosphor once lit every colour television; it also helps make banknotes hard to forge."
	color = "#D0C8D8"
	taste_description = "metal"

/datum/reagent/element/gadolinium
	name = "Gadolinium"
	description = "A silvery rare earth metal that strongly absorbs neutrons. Used as an MRI contrast agent."
	color = "#C8C8C8"
	taste_description = "metal"

/datum/reagent/element/terbium
	name = "Terbium"
	description = "A soft, silvery rare earth metal whose green phosphor lights up screens and lamps."
	color = "#C0C8C0"
	taste_description = "metal"

/datum/reagent/element/dysprosium
	name = "Dysprosium"
	description = "A silvery rare earth metal added to neodymium magnets so they keep working when hot."
	color = "#C8C8D0"
	taste_description = "metal"

/datum/reagent/element/holmium
	name = "Holmium"
	description = "A silvery rare earth metal with the highest magnetic strength of any element."
	color = "#D0D0C8"
	taste_description = "metal"

/datum/reagent/element/erbium
	name = "Erbium"
	description = "A silvery rare earth metal. Its pink salts colour glass, and it amplifies signals in fibre-optic cables."
	color = "#E0C8D0"
	taste_description = "metal"

/datum/reagent/element/thulium
	name = "Thulium"
	description = "One of the rarest rare earths. It powers some portable X-ray devices."
	color = "#C8D0C8"
	taste_description = "metal"

/datum/reagent/element/ytterbium
	name = "Ytterbium"
	description = "A soft, silvery rare earth metal used in some of the most precise atomic clocks ever built."
	color = "#D0D0C0"
	taste_description = "metal"

/datum/reagent/element/lutetium
	name = "Lutetium"
	description = "The last and densest of the lanthanides. Hard, silvery and very expensive."
	color = "#C8C8C8"
	taste_description = "metal"

/datum/reagent/element/hafnium
	name = "Hafnium"
	description = "A lustrous, silvery-grey metal that eats neutrons. Reactor control rods are made from it."
	color = "#B8B8C0"
	taste_description = "metal"

/datum/reagent/element/tantalum
	name = "Tantalum"
	description = "A dense, blue-grey, highly corrosion-resistant metal used in capacitors and surgical implants."
	color = "#9EA2B3"
	taste_description = "metal"

/datum/reagent/element/tungsten
	name = "Tungsten"
	description = "A dense, steel-grey metal with the highest melting point of any metal. The filament in old light bulbs."
	color = "#8E9091"
	taste_description = "metal"

/datum/reagent/element/rhenium
	name = "Rhenium"
	description = "One of the rarest metals in the crust. Dense, silvery and almost impossible to melt."
	color = "#A8A8B0"
	taste_description = "metal"

/datum/reagent/element/osmium
	name = "Osmium"
	description = "A hard, brittle, bluish-white metal and the densest naturally occurring element. A beaker of it is uncomfortably heavy."
	color = "#9CA6B8"
	taste_description = "very heavy metal"

/datum/reagent/element/iridium
	name = "Iridium"
	description = "A very hard, dense, corrosion-resistant metal. A layer of it in ancient rock marks a dinosaur-killing impact."
	color = "#C8CCD4"
	taste_description = "very expensive metal"

/datum/reagent/element/platinum
	name = "Platinum"
	description = "A dense, malleable, silvery-white precious metal and a superb catalyst. Rarer than gold."
	color = "#E5E4E2"
	taste_description = "very expensive metal"

/datum/reagent/toxin/element/thallium
	name = "Thallium"
	description = "A soft grey post-transition metal. Odourless, tasteless and lethal; it is called the poisoner's poison for a reason."
	color = "#B0B0B8"
	taste_description = "nothing at all"
	taste_mult = 0
	toxpwr = 3

/datum/reagent/element/bismuth
	name = "Bismuth"
	description = "A brittle, pinkish-silver metal that forms iridescent stair-step crystals. Surprisingly non-toxic for a heavy metal."
	color = "#D4A5C9"
	taste_description = "metal"

/datum/reagent/uranium/element/astatine
	name = "Astatine"
	description = "The rarest naturally occurring element; there is less than a gram of it in a planet's crust at any time. Intensely radioactive."
	color = "#4A4A4A"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/radon
	name = "Radon"
	description = "A colourless, odourless, radioactive noble gas that collects in basements and maintenance tunnels."
	color = "#E0E8FF"
	taste_mult = 0
	rad_power = 2
	tox_damage = 0.5

/datum/reagent/uranium/element/francium
	name = "Francium"
	description = "The most unstable naturally occurring element. A visible amount of it would vaporise from its own decay heat."
	color = "#C8A050"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/actinium
	name = "Actinium"
	description = "A soft, silvery radioactive metal that glows pale blue in the dark. It gives the actinide series its name."
	color = "#B0C8E8"
	taste_description = "the inside of a reactor"
	rad_power = 2
	tox_damage = 0.5

/datum/reagent/uranium/element/thorium
	name = "Thorium"
	description = "A weakly radioactive, silvery metal that tarnishes black. A promising fuel for breeder reactors."
	color = "#B4B4A8"
	taste_description = "the inside of a reactor"
	rad_power = 1
	tox_damage = 0.25

/datum/reagent/uranium/element/protactinium
	name = "Protactinium"
	description = "A dense, silvery-grey radioactive metal, both rare and highly toxic."
	color = "#B8B8B0"
	taste_description = "the inside of a reactor"
	rad_power = 2
	tox_damage = 0.5

/datum/reagent/uranium/element/neptunium
	name = "Neptunium"
	description = "A silvery radioactive metal and the first element after uranium, produced in reactors as a by-product."
	color = "#A8B0B8"
	taste_description = "the inside of a reactor"
	rad_power = 2
	tox_damage = 0.5

/datum/reagent/uranium/element/plutonium
	name = "Plutonium"
	description = "A silvery-grey radioactive metal that feels warm to the touch from its own decay. The core of the classic nuclear device. Handle with tongs."
	color = "#8C8C8C"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/americium
	name = "Americium"
	description = "A silvery radioactive metal. A tiny speck of it sits in every ionisation smoke detector."
	color = "#C8C8C8"
	taste_description = "the inside of a reactor"
	rad_power = 2
	tox_damage = 0.5

/datum/reagent/uranium/element/curium
	name = "Curium"
	description = "A hard, dense, silvery radioactive metal that glows purple in the dark. Used to power deep-space probes."
	color = "#C0C0C0"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/berkelium
	name = "Berkelium"
	description = "A synthetic, silvery radioactive metal produced by the milligram in high-flux reactors."
	color = "#C8C8C8"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/californium
	name = "Californium"
	description = "A synthetic radioactive metal and a fierce neutron emitter, used to kick-start reactors."
	color = "#C0C0C8"
	taste_description = "the inside of a reactor"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/einsteinium
	name = "Einsteinium"
	description = "A synthetic element first found in the debris of a thermonuclear test. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/fermium
	name = "Fermium"
	description = "A synthetic element first found in the debris of a thermonuclear test, alongside einsteinium. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/mendelevium
	name = "Mendelevium"
	description = "A synthetic element, first produced a few atoms at a time. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/nobelium
	name = "Nobelium"
	description = "A synthetic element whose discovery was argued over for decades. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/lawrencium
	name = "Lawrencium"
	description = "The last of the actinides, produced only in particle accelerators. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/rutherfordium
	name = "Rutherfordium"
	description = "The first transactinide element, made by bombarding heavy targets with ions. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/dubnium
	name = "Dubnium"
	description = "A synthetic transactinide whose name was the subject of a long dispute. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/seaborgium
	name = "Seaborgium"
	description = "A synthetic transactinide element, made a handful of atoms at a time. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/bohrium
	name = "Bohrium"
	description = "A synthetic transactinide element, made a handful of atoms at a time. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/hassium
	name = "Hassium"
	description = "A synthetic transactinide element, predicted to be denser than osmium. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/meitnerium
	name = "Meitnerium"
	description = "A synthetic superheavy element. Its chemistry is almost entirely unknown. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/darmstadtium
	name = "Darmstadtium"
	description = "A synthetic superheavy element. Its chemistry is almost entirely unknown. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/roentgenium
	name = "Roentgenium"
	description = "A synthetic superheavy element, predicted to be a noble metal like gold. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/copernicium
	name = "Copernicium"
	description = "A synthetic superheavy element, predicted to be a volatile liquid or gas like mercury. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/nihonium
	name = "Nihonium"
	description = "A synthetic superheavy element. Its chemistry is almost entirely unknown. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/flerovium
	name = "Flerovium"
	description = "A synthetic superheavy element that sits near the predicted island of stability. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/moscovium
	name = "Moscovium"
	description = "A synthetic superheavy element. Its chemistry is almost entirely unknown. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/livermorium
	name = "Livermorium"
	description = "A synthetic superheavy element. Its chemistry is almost entirely unknown. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/tennessine
	name = "Tennessine"
	description = "A synthetic superheavy element, nominally a halogen. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1

/datum/reagent/uranium/element/oganesson
	name = "Oganesson"
	description = "The heaviest element known, nominally a noble gas but probably nothing like one. This sample is suspended in a bluespace stasis lattice; without it, it would decay to nothing in seconds or less."
	color = "#7A6FD1"
	taste_description = "the end of the periodic table"
	rad_power = 3
	tox_damage = 1
