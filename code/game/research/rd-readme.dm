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
- Protolathe: Used to make new hand-held devices and parts for larger devices. Uses metal and glass as raw materials.
- Destructive Analyzer: You can put hand-held objects into it and it'll analyze them for technological advancements but it destroys
them in the process. Destroyed items will send their raw materials to a linked Protolathe (if any)
- Circuit Imprinter: Similar to the Protolathe, it allows for the construction of circuit boards. Uses glass and acid as the raw
materials.

While researching you are dealing with two different types of information: Technology Paths and Device Designs. Technology Paths
are the "Tech Trees" of the game. You start out with a number of them at the game start and they are improved by using the
Destructive Analyzer. By themselves, they don't do a whole lot. However, they unlock Device Designs. This is the information used
by the circuit imprinter and the protolathe to produce objects. It also tracks the current reliability of that particular design.

MORE STUFF HERE LATER.

*/