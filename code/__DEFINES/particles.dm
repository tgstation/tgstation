// /obj/effect/abstract/particle_holder/var/particle_flags
// Flags that effect how a particle holder displays something

/// If we're inside something inside a mob, display off that mob too
#define PARTICLE_ATTACH_MOB (1<<0)

// Flags that control how apply_particles_to behaves for adding a holder

///Add a single unique holder instance
#define PARTICLES_SINGULAR "singular"
///Add a shared holder
#define PARTICLES_SHARED "shared"
