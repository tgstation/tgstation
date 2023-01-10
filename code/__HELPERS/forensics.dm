/// Returns the fingerprints on this atom
#define GET_ATOM_FINGERPRINTS(atom) atom.forensics?.fingerprints
/// Returns the hidden prints on this atom
#define GET_ATOM_HIDDENPRINTS(atom) atom.forensics?.hiddenprints
/// Returns the blood dna on this atom
#define GET_ATOM_BLOOD_DNA(atom) atom.forensics?.blood_DNA
/// Returns the fibers on this atom
#define GET_ATOM_FIBRES(atom) atom.forensics?.fibers
/// Returns the number of unique blood dna sources on this atom
#define GET_ATOM_BLOOD_DNA_LENGTH(atom) (isnull(atom.forensics) ? 0 : length(atom.forensics.blood_DNA))
