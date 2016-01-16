/*
Research and Development System. (Designed specifically for the /tg/station 13 (Space Station 13) open source project)

///////////////Overview///////////////////
This system is a "tech tree" research and development system designed for SS13. It allows a "researcher" job (this document assumes
the "scientist" job is given this role) the tools necessiary to research new and better technologies. In general, the system works
by breaking existing technology and using what you learn from to advance your knowledge of SCIENCE! As your knowledge progresses,
you can build newer (and better?) devices (which you can also, eventually, deconstruct to advance your knowledge).

A brief overview is below. For more details, see the related files.

////////////Game Use/////////////
The major research and development is performed using a combination of four machines:
- R&D Console: A computer console that allows you to manipulate the other devices that are linked to it and view/manipulate the
technologies you have researched so far.
- Protolathe: Used to make new hand-held devices and parts for larger devices. All metals and reagents as raw materials.
- Destructive Analyzer: You can put hand-held objects into it and it'll analyze them for technological advancements but it destroys
them in the process. Destroyed items will send their raw materials to a linked Protolathe (if any)
- Circuit Imprinter: Similar to the Protolathe, it allows for the construction of circuit boards. Uses glass and acid as the raw
materials.

While researching you are dealing with two different types of information: Technology Paths and Device Designs. Technology Paths
are the "Tech Trees" of the game. You start out with a number of them at the game start and they are improved by using the
Destructive Analyzer. By themselves, they don't do a whole lot. However, they unlock Device Designs. This is the information used
by the circuit imprinter and the protolathe to produce objects. It also tracks the current reliability of that particular design.

//EXISTING TECH
Each tech path should have at LEAST one item at every level (levels 1 - 20). This is to allow for a more fluid progression of the
researching. Existing tech (ie, anything you can find on the station or get from the quartermaster) shouldn't go higher then
level 5 or 7. Everything past that should be stuff you research.

Below is a checklist to make sure every tree is filled. As new items get added to R&D, add them here if there is an empty slot.
When thinking about new stuff, check here to see if there are any slots unfilled.

//MATERIALS
1	|	Metal
2	|	Solid Plasma
3	|	Silver
4	|	Gold, Super Capacitor
5	|	Uranium, Nuclear Gun, SUPERPACMAN
6	|	Diamond, MRSPACMAN
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//PLASMA TECH
1	|
2	|	Solid Plasma
3	|	Pacman Generator
4	|
5	|
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//POWER TECH
1	|	Basic Capacitor, Basic Cell
2	|	High-Capacity Cell (10,000)
3	|	Super-Capacity Cell (20,000), Powersink, PACMAN
4	|	SUPERPACMAN
5	|	MRSPACMAN, Super Capacitor
6	|	Hyper-Capacity Cell (30,000)
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//BLUE SPACE
1	|
2	|	Teleporter Console Board
3	|	Teleport Gun, Hand Tele
4	|	Teleportation Scroll
5	|
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//BIOTECH
1	|	Bruise Pack, Scalple
2	|	PANDEMIC Board, Mass Spectrometer
3	|	AI Core, Brains (MMI)
4	|	MMI+Radio
5	|
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//MAGNETS
1	|	Basic Sensor
2	|	Comm Console Board
3	|	Adv Sensor
4	|	Adv Mass Spectrometer, Chameleon Projector
5	|	Phasic Sensor
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//PROGRAMMING
1	|	Arcade Board
2	|	Sec Camera
3	|	Cloning Machine Console Board
4	|	AI Core, Intellicard
5	|	Pico-Manipulator, Ultra-Micro-Laser
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//SYNDICATE
1	|	Sleepypen
2	|	TYRANT Module, Emag
3	|	Cloaking Device, Power Sink
4	|
5	|
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|

//COMBAT
1	|	Flashbang, Mousetrap, Nettle
2	|	Stun Baton
3	|	Power Axe, Death Nettle, Nuclear Gun
4	|
5	|
6	|
7	|
8	|
9	|
10	|
11	|
12	|
13	|
14	|
15	|
16	|
17	|
18	|
19	|
20	|







*/