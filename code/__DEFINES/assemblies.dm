/// This assembly activates when has its wires pulsed
#define ASSEMBLY_WIRE_RECEIVE (1<<0)
/// This assembly pulses OTHER assemblies / its own wires when it pulses
#define ASSEMBLY_WIRE_PULSE (1<<1)
/// This assembly pulses OTHER assemblies / its own wires when it pulses, but in a special way.
#define ASSEMBLY_WIRE_PULSE_SPECIAL (1<<2)
/// This assembly can recieve activations via signal / radio
#define ASSEMBLY_WIRE_RADIO_RECEIVE (1<<3)
/// When combined in a holder, blacklists duplicate assemblies
#define ASSEMBLY_NO_DUPLICATES (1<<5)

/// How loud do assemblies beep at
#define ASSEMBLY_BEEP_VOLUME 5

/// The max amount of assemblies attachable on an assembly holder
#define HOLDER_MAX_ASSEMBLIES 12
