/obj/effect/spawner/random/mining_loot/shoe_factory
	name = "random shoe factory loot"
	desc = "Spawns shoes from the loot list. Shoes have a randomized slowdown modifier."
	icon = 'icons/obj/clothing/shoes.dmi'
	icon_state = "sneakers"
	loot = list()
	loot_subtype_path = /obj/item/clothing/shoes
	spawn_loot_count = 5
	spawn_scatter_radius = 2
	spawn_random_offset = TRUE

/obj/effect/spawner/random/mining_loot/shoe_factory/make_item(spawn_loc, type_path_to_make)
	var/obj/item/clothing/shoes/shoe = ..()
	if(istype(shoe))
		// shoes will spawn anywhere from -0.5 speed modifer (fast) to +0.5 speed (slow)
		// See https://tadeohepperle.com/dice-calculator-frontend/?d1=%2B5d3 to view dice chances for rolls (higher rolls == faster shoes)
		var/dice_result = roll("5d3")
		var/slowdown_modifier = (1 - (dice_result * 0.1))
		shoe.slowdown += slowdown_modifier

	return shoe

/obj/item/paper/fluff/ruins/shoe_factory/osha_shutdown
	name = "Official Spess OSHA Closure Notice"
	desc = "A heavily stamped document with a bright red 'CONDEMNED' watermark."
	default_raw_text = "<b>SPESS OCCUPATIONAL SAFETY & HEALTH ADMINISTRATION</b><br><br> \
	<b>ORDER OF IMMEDIATE CLOSURE</b><br><br> \
	Facility 44-S (Footwear Manufacturing Division) is hereby ordered to cease all operations indefinitely pending a Class-A kinetic anomaly investigation.<br><br> \
	<b>Citations:</b><br> \
	<ul> \
	<li><b>Violation 882.A:</b> Extreme deviation in product density. Random inspections reveal that approximately 99% of 'Sprint-Mate' footwear units possess a localized gravitational anomaly. Users report immense physical exertion, equating standard walking to 'dragging an asteroid through wet cement.'</li> \
	<li><b>Violation 882.B:</b> Lethal kinetic acceleration. The remaining 1% of the production line exhibits zero-friction bluespace properties. A OSHA inspector testing a pair was accelerated to 150 km/h into a reinforced plasma glass window, resulting in critical injuries and a localized hull breach.</li> \
	</ul><br> \
	All assets are frozen. Do not attempt to transport the remaining stock. If you must move a crate, DO NOT wear the contents."


/obj/item/paper/fluff/shoe_factory_osha
	name = "Space OSHA Inspection Notice"
	default_raw_text = {"
		<center><b>NANOTRASEN OCCUPATIONAL SAFETY AND HAZARD ADMINISTRATION</b><br>
		<i>Form 77-B: Mandatory Facility Closure Order</i></center><br>
		<hr>
		<b>Facility:</b> Cobbleton & Sons Shoe Manufacturing, Ltd.<br>
		<b>Inspector:</b> H. Bootsworth, Senior Field Auditor<br>
		<b>Date of Inspection:</b> ██/██/25██<br>
		<b>Outcome:</b> <font color='red'><b>IMMEDIATE CLOSURE ORDERED</b></font><br>
		<hr>
		<b>Summary of Violations:</b><br>
		<br>
		Following a routine workplace safety audit, the following CRITICAL violations
		were observed on the factory floor:<br>
		<br>
		1. Multiple pairs of finished footwear were found to exhibit anomalous and
		hazardous properties inconsistent with standard shoe behavior. Products were
		observed (REDACTED), emitting unlicensed energy signatures, and in one case
		actively resisting removal from the test subject's feet.<br>
		<br>
		2. ZERO quality assurance records were found on-site. When asked about QA
		procedures, the floor manager gestured vaguely at a clown and said
		"he tries them on sometimes."<br>
		<br>
		3. The manufacturing line lacks any form of anomalous material handling
		protocols despite the finished product clearly being outside baseline
		safety parameters.<br>
		<br>
		<b>Closing Remarks:</b><br>
		<br>
		I have been a Safety Auditor for 15 years across 3 sectors. I have shut down
		plasma refineries. I have cited singularity engine rooms. I have written
		violations for clown cars exceeding maximum occupancy by a factor of eleven.<br>
		<br>
		I have never seen shoes do the things these shoes do.<br>
		<br>
		This facility is to remain sealed until such time as a full anomalous item
		review board can assess the product line. Any remaining inventory is
		NOT to be removed from the premises.<br>
		<br>
		<i>(Addendum: if anyone from Corporate is reading this - no, you cannot
		sell these. I don't care how much the profit margin is. Stop asking.)</i><br>
		<hr>
		<i>This notice is the property of Space OSHA. Removal or defacement of this
		notice is punishable under Nanotrasen Workplace Safety Code § 4.77.2</i>
	"}

/obj/item/paper/fluff/shoe_factory_closure
	name = "NOTICE OF CLOSURE"
	desc = "An official-looking document bearing the Space OSHA seal. Someone has drawn a tiny angry face on the corner."
	default_raw_text = {"<center><b>SPACE OCCUPATIONAL SAFETY & HAZARDS ADMINISTRATION</b></center>
<center><b>OFFICIAL NOTICE OF FACILITY CLOSURE</b></center>
<hr>
<b>Facility:</b> Unnamed Bootwear Manufactory, Sector (REDACTED)<br>
<b>Inspecting Officer:</b> Senior Agent Greaves, Division VII<br>
<b>Status:</b> <b>PERMANENTLY CLOSED</b>, pending owner's response (owner has not responded in 14 standard months).<br>
<hr>

To whom it may concern,<br><br>

Following a routine compliance audit, this facility has been found in gross violation of no fewer than <i>thirty-two</i> distinct Space OSHA regulations. A full list is appended in Annex B. For the purposes of this summary notice, the most egregious are reproduced below:<br><br>

<b>1.</b> Complete absence of any functioning Quality Assurance pipeline. Upon questioning, the foreman claimed the previous QA officer "left in a hurry" through an unpatched hole in the ceiling. The hole has been independently verified. The QA officer has not.<br><br>

<b>2.</b> Production of footwear containing <i>undeclared active components</i>. This office has recovered several finished units displaying behavior wildly inconsistent with what a reasonable being would call "a shoe." The proprietor insists these are "premium features" for "the discerning adventurer." This office insists they are lawsuits.<br><br>

<b>3.</b> Failure to properly label hazardous stock. If you are reading this notice, and you are standing in the facility, and you are considering putting on a pair of the shoes on the floor: <b>please do not.</b> Or do. We are no longer liable either way.<br><br>

<b>4.</b> No fire exits. No fire extinguishers. Considerable amounts of flammable leather. We don't even know where to start.<br><br>

By the authority vested in this office, all operations are to cease immediately. Any remaining inventory is the property of the Crown and/or whoever gets here first.<br><br>

Stay safe out there.<br><br>

— <i>Sr. Agent Greaves, Space OSHA</i><br>
<i>"If it looks unsafe, it probably is. If it looks safe, it probably still is."</i>"}
