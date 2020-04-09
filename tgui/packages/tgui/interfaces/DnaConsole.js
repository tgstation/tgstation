import { filter, uniqBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes } from 'common/react';
import { capitalize } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Dimmer, Divider, Dropdown, Flex, Icon, LabeledList, NumberInput, ProgressBar, Section } from '../components';
import { createLogger } from '../logging';

// TODO: Combining mutations (E.g. Radioactive + Strength = Hulk)
// https://tgstation13.org/wiki/Guide_to_genetics#List_of_Mutations

const logger = createLogger('DnaConsole');

const SUBJECT_CONCIOUS = 0;
const SUBJECT_SOFT_CRIT = 1;
const SUBJECT_UNCONSCIOUS = 2;
const SUBJECT_DEAD = 3;
const SUBJECT_TRANSFORMING = 4;

const GENES = ['A', 'T', 'C', 'G'];
const GENE_COLORS = {
  A: 'green',
  T: 'green',
  G: 'blue',
  C: 'blue',
  X: 'grey',
};

const CONSOLE_MODE_STORAGE = 'storage';
const CONSOLE_MODE_SEQUENCER = 'sequencer';
const CONSOLE_MODE_ENZYMES = 'enzymes';
const CONSOLE_MODE_INJECTORS = 'injectors';

const STORAGE_MODE_CONSOLE = 'console';
const STORAGE_MODE_DISK = 'disk';
const STORAGE_MODE_ADVINJ = 'injector';

const STORAGE_CONS_SUBMODE_MUTATIONS = 'mutations';
const STORAGE_CONS_SUBMODE_CHROMOSOMES = 'chromosomes';
const STORAGE_DISK_SUBMODE_MUTATIONS = 'mutations';
const STORAGE_DISK_SUBMODE_ENZYMES = 'diskenzymes';

const CHROMOSOME_NEVER = 0;
const CHROMOSOME_NONE = 1;
const CHROMOSOME_USED = 2;

const MUT_NORMAL = 1;
const MUT_EXTRA = 2;
const MUT_OTHER = 3;

// __DEFINES/DNA.dm - Mutation "Quality"
const POSITIVE = 1;
const NEGATIVE = 2;
const MINOR_NEGATIVE = 4;
const MUT_COLORS = {
  1: 'good',
  2: 'bad',
  4: 'average',
};

const RADIATION_STRENGTH_MAX = 15;
const RADIATION_DURATION_MAX = 30;

/**
 * The following predicate tests if two mutations are functionally
 * the same on the basis of their metadata. Useful if your intent is
 * to prevent "true" duplicates - i.e. mutations with identical metadata.
 */
const isSameMutation = (a, b) => {
  return a.Alias === b.Alias
    && a.AppliedChromo === b.AppliedChromo;
};

export const DnaConsole = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const {
    isPulsingRads,
    radPulseSeconds,
  } = data;
  const { consoleMode } = data.view;
  return (
    <Fragment>
      {!!isPulsingRads && (
        <Dimmer
          fontSize="14px"
          textAlign="center">
          <Icon
            mr={1}
            name="spinner"
            spin />
          Radiation pulse in progress...
          <Box mt={1} />
          {radPulseSeconds}s
        </Dimmer>
      )}
      <DnaScanner state={state} />
      <DnaConsoleCommands state={state} />
      {consoleMode === CONSOLE_MODE_STORAGE && (
        <DnaConsoleStorage state={state} />
      )}
      {consoleMode === CONSOLE_MODE_SEQUENCER && (
        <DnaConsoleSequencer state={state} />
      )}
      {consoleMode === CONSOLE_MODE_ENZYMES && (
        <DnaConsoleEnzymes state={state} />
      )}
    </Fragment>
  );
};

const DnaScanner = props => {
  const { state } = props;
  return (
    <Section
      title="DNA Scanner"
      buttons={(
        <DnaScannerButtons state={state} />
      )}>
      <DnaScannerContent state={state} />
    </Section>
  );
};

const DnaScannerButtons = props => {
  const { data, act } = useBackend(props);
  const {
    hasDelayedAction,
    isPulsingRads,
    isScannerConnected,
    isScrambleReady,
    isViableSubject,
    scannerLocked,
    scannerOpen,
    scrambleSeconds,
  } = data;
  if (!isScannerConnected) {
    return (
      <Button
        content="Connect Scanner"
        onClick={() => act('connect_scanner')} />
    );
  }
  return (
    <Fragment>
      {!!hasDelayedAction && (
        <Button
          content="Cancel Delayed Action"
          onClick={() => act('cancel_delay')} />
      )}
      {!!isViableSubject && (
        <Button
          disabled={!isScrambleReady || isPulsingRads}
          onClick={() => act('scramble_dna')}>
          Scramble DNA
          {!isScrambleReady && ` (${scrambleSeconds}s)`}
        </Button>
      )}
      <Box inline mr={1} />
      <Button
        icon={scannerLocked ? 'lock' : 'lock-open'}
        color={scannerLocked && 'bad'}
        disabled={scannerOpen}
        content={scannerLocked ? 'Locked' : 'Unlocked'}
        onClick={() => act('toggle_lock')} />
      <Button
        disabled={scannerLocked}
        content={scannerOpen ? 'Close' : 'Open'}
        onClick={() => act('toggle_door')} />
    </Fragment>
  );
};

/**
 * Displays subject status based on the value of the status prop.
 */
const SubjectStatus = props => {
  const { status } = props;
  if (status === SUBJECT_CONCIOUS) {
    return (
      <Box inline color="good">Conscious</Box>
    );
  }
  if (status === SUBJECT_UNCONSCIOUS) {
    return (
      <Box inline color="average">Unconscious</Box>
    );
  }
  if (status === SUBJECT_SOFT_CRIT) {
    return (
      <Box inline color="average">Critical</Box>
    );
  }
  if (status === SUBJECT_DEAD) {
    return (
      <Box inline color="bad">Dead</Box>
    );
  }
  if (status === SUBJECT_TRANSFORMING) {
    return (
      <Box inline color="bad">Transforming</Box>
    );
  }
  return (
    <Box inline>Unknown</Box>
  );
};

const DnaScannerContent = props => {
  const { data, act } = useBackend(props);
  const {
    subjectName,
    isScannerConnected,
    isViableSubject,
    subjectHealth,
    subjectRads,
    subjectStatus,
  } = data;
  if (!isScannerConnected) {
    return (
      <Box color="bad">
        DNA Scanner is not connected.
      </Box>
    );
  }
  if (!isViableSubject) {
    return (
      <Box color="average">
        No viable subject found in DNA Scanner.
      </Box>
    );
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        {subjectName}
        <Icon
          mx={1}
          color="label"
          name="long-arrow-alt-right" />
        <SubjectStatus status={subjectStatus} />
      </LabeledList.Item>
      <LabeledList.Item label="Health">
        <ProgressBar
          value={subjectHealth}
          minValue={0}
          maxValue={100}
          ranges={{
            olive: [101, Infinity],
            good: [70, 101],
            average: [30, 70],
            bad: [-Infinity, 30],
          }}>
          {subjectHealth}%
        </ProgressBar>
      </LabeledList.Item>
      <LabeledList.Item label="Radiation">
        <ProgressBar
          value={subjectRads}
          minValue={0}
          maxValue={100}
          ranges={{
            bad: [71, Infinity],
            average: [30, 71],
            good: [0, 30],
            olive: [-Infinity, 0],
          }}>
          {subjectRads}%
        </ProgressBar>
      </LabeledList.Item>
    </LabeledList>
  );
};

export const DnaConsoleCommands = props => {
  const { data, act } = useBackend(props);
  const { hasDisk, isInjectorReady, injectorSeconds } = data;
  const { consoleMode } = data.view;
  return (
    <Section
      title="DNA Console"
      buttons={!isInjectorReady && (
        <Box
          lineHeight="20px"
          color="label">
          Injector on cooldown ({injectorSeconds}s)
        </Box>
      )}>
      <LabeledList>
        <LabeledList.Item label="Mode">
          <Button
            content="Storage"
            selected={consoleMode === CONSOLE_MODE_STORAGE}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_STORAGE,
            })} />
          <Button
            content="Sequencer"
            disabled={!data.isViableSubject}
            selected={consoleMode === CONSOLE_MODE_SEQUENCER}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_SEQUENCER,
            })} />
          <Button
            content="Enzymes"
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_ENZYMES,
            })} />
        </LabeledList.Item>
        {!!hasDisk && (
          <LabeledList.Item label="Disk">
            <Button
              icon="eject"
              content="Eject"
              onClick={() => {
                act('eject_disk');
                act('set_view', {
                  storageMode: STORAGE_MODE_CONSOLE,
                });
              }} />
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
};

const StorageButtons = props => {
  const { data, act } = useBackend(props);
  const { hasDisk } = data;
  const { storageMode, storageConsSubMode, storageDiskSubMode } = data.view;
  return (
    <Fragment>
      {storageMode === STORAGE_MODE_CONSOLE && (
        <Fragment>
          <Button
            selected={storageConsSubMode === STORAGE_CONS_SUBMODE_MUTATIONS}
            content="Mutations"
            onClick={() => act('set_view', {
              storageConsSubMode: STORAGE_CONS_SUBMODE_MUTATIONS,
            })} />
          <Button
            selected={storageConsSubMode === STORAGE_CONS_SUBMODE_CHROMOSOMES}
            content="Chromosomes"
            onClick={() => act('set_view', {
              storageConsSubMode: STORAGE_CONS_SUBMODE_CHROMOSOMES,
            })} />
        </Fragment>
      )}
      {storageMode === STORAGE_MODE_DISK && (
        <Fragment>
          <Button
            selected={storageDiskSubMode === STORAGE_CONS_SUBMODE_MUTATIONS}
            content="Mutations"
            onClick={() => act('set_view', {
              storageDiskSubMode: STORAGE_CONS_SUBMODE_MUTATIONS,
            })} />
          <Button
            selected={storageDiskSubMode === STORAGE_DISK_SUBMODE_ENZYMES}
            content="Enzymes"
            onClick={() => act('set_view', {
              storageDiskSubMode: STORAGE_DISK_SUBMODE_ENZYMES,
            })} />
        </Fragment>
      )}
      <Box inline mr={1} />
      <Button
        content="Console"
        selected={storageMode === STORAGE_MODE_CONSOLE}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_CONSOLE,
          storageConsSubMode: STORAGE_CONS_SUBMODE_MUTATIONS
            ?? storageConsSubMode,
        })} />
      <Button
        content="Disk"
        disabled={!hasDisk}
        selected={storageMode === STORAGE_MODE_DISK}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_DISK,
          storageDiskSubMode: STORAGE_DISK_SUBMODE_MUTATIONS
            ?? storageDiskSubMode,
        })} />
      <Button
        content="Adv. Injector"
        selected={storageMode === STORAGE_MODE_ADVINJ}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_ADVINJ,
        })} />
    </Fragment>
  );
};

const DnaConsoleStorage = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const { storageMode, storageConsSubMode, storageDiskSubMode } = data.view;
  const { diskMakeupBuffer, diskHasMakeup } = data;
  const mutations = data.storage[storageMode];
  return (
    <Section
      title="Storage"
      buttons={(
        <StorageButtons state={state} />
      )}>
      {storageMode === STORAGE_MODE_CONSOLE
        && storageConsSubMode === STORAGE_CONS_SUBMODE_MUTATIONS && (
        <StorageMutations state={state} mutations={mutations} />
      )}
      {storageMode === STORAGE_MODE_CONSOLE
        && storageConsSubMode === STORAGE_CONS_SUBMODE_CHROMOSOMES && (
        <StorageChromosomes state={state} />
      )}
      {storageMode === STORAGE_MODE_DISK
        && storageDiskSubMode === STORAGE_DISK_SUBMODE_MUTATIONS && (
        <StorageMutations state={state} mutations={mutations} />
      )}
      {storageMode === STORAGE_MODE_DISK
        && storageDiskSubMode === STORAGE_DISK_SUBMODE_ENZYMES && (
        <Fragment>
          <GeneticMakeupInfo makeup={diskMakeupBuffer} />
          <Button
            icon="times"
            color="red"
            disabled={!diskHasMakeup}
            content={'Delete'}
            onClick={() => act('del_makeup_disk')} />
        </Fragment>
      )}
      {storageMode === STORAGE_MODE_ADVINJ && (
        <DnaConsoleAdvancedInjectors state={state} />
      )}
    </Section>
  );
};

const StorageMutations = props => {
  const { state, mutations, customMode = '' } = props;
  const { data, act } = useBackend(props);
  const mode = data.view.storageMode + customMode;

  let mutationRef = data.view[`storage${mode}MutationRef`];
  let mutation = mutations
    .find(mutation => mutation.ByondRef === mutationRef);

  // If no mutation is selected but there are stored mutations, pick the first
  // mutation and set that as the currently showed one.
  if (!mutation && mutations.length > 0) {
    mutation = mutations[0];
    mutationRef = mutation.ByondRef;
  }

  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title={`${capitalize(data.view.storageMode)} Storage`}
          level={2}>
          {mutations.map(mutation => (
            <Button
              key={mutation.ByondRef}
              fluid
              ellipsis
              color="transparent"
              selected={mutation.ByondRef === mutationRef}
              content={mutation.Name}
              onClick={() => act('set_view', {
                [`storage${mode}MutationRef`]: mutation.ByondRef,
              })} />
          ))}
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Divider vertical />
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Section
          title="Mutation Info"
          level={2}>
          <MutationInfo
            state={state}
            mutation={mutation} />
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const StorageChromosomes = props => {
  const { data, act } = useBackend(props);
  const chromos = data.chromoStorage ?? [];
  const uniqueChromos = uniqBy(chromo => chromo.Name)(chromos);
  const chromoName = data.view.storageChromoName;
  const chromo = chromos.find(chromo => chromo.Name === chromoName);
  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title="Console Storage"
          level={2}>
          {uniqueChromos.map(chromo => (
            <Button
              key={chromo.Index}
              fluid
              ellipsis
              color="transparent"
              selected={chromo.Name === chromoName}
              content={chromo.Name}
              onClick={() => act('set_view', {
                storageChromoName: chromo.Name,
              })} />
          ))}
        </Section>
      </Flex.Item>
      <Flex.Item>
        <Divider vertical />
      </Flex.Item>
      <Flex.Item grow={1} basis={0}>
        <Section
          title="Chromosome Info"
          level={2}>
          {!chromo && (
            <Box color="label">
              Nothing to show.
            </Box>
          ) || (
            <Fragment>
              <LabeledList>
                <LabeledList.Item label="Name">
                  {chromo.Name}
                </LabeledList.Item>
                <LabeledList.Item label="Description">
                  {chromo.Description}
                </LabeledList.Item>
                <LabeledList.Item label="Amount">
                  {chromos
                    .filter(x => x.Name === chromo.Name)
                    .length}
                </LabeledList.Item>
              </LabeledList>
              <Button
                mt={2}
                icon="eject"
                content={"Eject Chromosome"}
                onClick={() => act('eject_chromo', {
                  chromo: chromo.Name,
                })} />
            </Fragment>
          )}
        </Section>
      </Flex.Item>
    </Flex>
  );
};

const MutationInfo = props => {
  const { state, mutation } = props;
  const { data, act } = useBackend(props);
  const {
    diskCapacity,
    diskReadOnly,
    hasDisk,
    isInjectorReady,
    mutationCapacity,
  } = data;
  const diskMutations = data.storage.disk ?? [];
  const mutationStorage = data.storage.console ?? [];
  const advInjectors = data.storage.injector ?? [];
  if (!mutation) {
    return (
      <Box color="label">
        Nothing to show.
      </Box>
    );
  }
  if (mutation.Source === 'occupant' && !mutation.Discovered) {
    return (
      <LabeledList>
        <LabeledList.Item label="Name">
          {mutation.Alias}
        </LabeledList.Item>
      </LabeledList>
    );
  }
  const savedToConsole = mutationStorage
    .find(x => isSameMutation(x, mutation));
  const savedToDisk = diskMutations
    .find(x => isSameMutation(x, mutation));
  const combinedMutations = flow([
    uniqBy(mutation => mutation.Name),
    filter(x => x.Name !== mutation.Name),
  ])([
    ...diskMutations,
    ...mutationStorage,
  ]);
  return (
    <Fragment>
      <LabeledList>
        <LabeledList.Item label="Name">
          <Box inline color={MUT_COLORS[mutation.Quality]}>{mutation.Name}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {mutation.Description}
        </LabeledList.Item>
        <LabeledList.Item label="Instability">
          {mutation.Instability}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box>
        {mutation.Source === 'disk' && (
          <MutationCombiner
            disabled={!hasDisk
              || diskCapacity <= 0
              || diskReadOnly}
            state={state}
            mutations={combinedMutations}
            source={mutation} />
        )}
        {mutation.Source === 'console' && (
          <MutationCombiner
            state={state}
            disabled={mutationCapacity <= 0}
            mutations={combinedMutations}
            source={mutation} />
        )}
        {['occupant', 'disk', 'console'].includes(mutation.Source) && (
          <Fragment>
            <Dropdown
              width="240px"
              options={advInjectors.map(injector => injector.name)}
              disabled={advInjectors.length === 0 || !mutation.Active}
              selected="Add to advanced injector"
              onSelected={value => act('add_advinj_mut', {
                mutref: mutation.ByondRef,
                advinj: value,
                source: mutation.Source,
              })} />
            <Button
              icon="syringe"
              disabled={!isInjectorReady || !mutation.Active}
              content="Print Activator"
              onClick={() => act('print_injector', {
                mutref: mutation.ByondRef,
                is_activator: 1,
                source: mutation.Source,
              })} />
            <Button
              icon="syringe"
              disabled={!isInjectorReady || !mutation.Active}
              content="Print Mutator"
              onClick={() => act('print_injector', {
                mutref: mutation.ByondRef,
                is_activator: 0,
                source: mutation.Source,
              })} />
          </Fragment>
        )}
      </Box>
      {['disk', 'occupant'].includes(mutation.Source) && (
        <Button
          icon="save"
          disabled={savedToConsole
            || mutationCapacity <= 0
            || !mutation.Active}
          content="Save to Console"
          onClick={() => act('save_console', {
            mutref: mutation.ByondRef,
            source: mutation.Source,
          })} />
      )}
      {['console', 'occupant'].includes(mutation.Source) && (
        <Button
          icon="save"
          disabled={savedToDisk
            || !hasDisk
            || diskCapacity <= 0
            || diskReadOnly
            || !mutation.Active}
          content="Save to Disk"
          onClick={() => act('save_disk', {
            mutref: mutation.ByondRef,
            source: mutation.Source,
          })} />
      )}
      {['console', 'disk', 'injector'].includes(mutation.Source) && (
        <Button
          icon="times"
          color="red"
          content={`Delete from ${mutation.Source}`}
          onClick={() => act(`delete_${mutation.Source}_mut`, {
            mutref: mutation.ByondRef,
          })} />
      )}
      {(mutation.Class === MUT_EXTRA || !!mutation.Scrambled
        && mutation.Source === 'occupant')
        && (
          <Button
            content="Nullify"
            onClick={() => act('nullify', {
              mutref: mutation.ByondRef,
            })} />
        )}
      <Divider />
      <ChromosomeInfo
        disabled={mutation.Source !== 'occupant'}
        state={state}
        mutation={mutation} />
    </Fragment>
  );
};

const ChromosomeInfo = props => {
  const { mutation, disabled } = props;
  const { data, act } = useBackend(props);
  if (mutation.CanChromo === CHROMOSOME_NEVER) {
    return (
      <Box color="label">
        No compatible chromosomes
      </Box>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_NONE) {
    if (disabled) {
      return (
        <Box color="label">
          No chromosome applied.
        </Box>
      );
    }
    return (
      <Fragment>
        <Dropdown
          width="240px"
          options={mutation.ValidStoredChromos}
          disabled={mutation.ValidStoredChromos.length === 0}
          selected={mutation.ValidStoredChromos.length === 0
            ? "No Suitable Chromosomes"
            : "Select a chromosome"}
          onSelected={e => act('apply_chromo', {
            chromo: e,
            mutref: mutation.ByondRef,
          })} />
        <Box color="label" mt={1}>
          Compatible with: {mutation.ValidChromos}
        </Box>
      </Fragment>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_USED) {
    return (
      <Box color="label">
        Applied chromosome: {mutation.AppliedChromo}
      </Box>
    );
  }
  return null;
};

const DnaConsoleSequencer = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const mutations = data.storage?.occupant ?? [];
  const {
    isJokerReady,
    isMonkey,
    jokerSeconds,
    subjectStatus,
  } = data;
  const { sequencerMutation, jokerActive } = data.view;
  const mutation = mutations.find(mutation => (
    mutation.Alias === sequencerMutation
  ));
  return (
    <Fragment>
      <Flex spacing={1} mb={1}>
        <Flex.Item width={mutations.length <= 8 && "154px" || "174px"}>
          <Section
            title="Sequences"
            height="214px"
            overflowY={mutations.length > 8 && "scroll"}>
            {mutations.map(mutation => (
              <GenomeImage
                key={mutation.Alias}
                url={mutation.Image}
                selected={mutation.Alias === sequencerMutation}
                onClick={() => {
                  act('set_view', {
                    sequencerMutation: mutation.Alias,
                  });
                  act('check_discovery', {
                    alias: mutation.Alias,
                  });
                }} />
            ))}
          </Section>
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <Section
            title="Sequence Info"
            minHeight="100%">
            <MutationInfo
              state={state}
              mutation={mutation} />
          </Section>
        </Flex.Item>
      </Flex>
      {subjectStatus === SUBJECT_DEAD && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: DECEASED.
        </Section>
      ) || (isMonkey && mutation?.Name !== 'Monkified') && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: MONKEY.
        </Section>
      ) || (subjectStatus === SUBJECT_TRANSFORMING) && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: TRANSFORMING.
        </Section>
      ) || (
        <Section
          title="Genome Sequencer™"
          buttons={(
            !isJokerReady && (
              <Box
                lineHeight="20px"
                color="label">
                Joker on cooldown ({jokerSeconds}s)
              </Box>
            ) || jokerActive && (
              <Fragment>
                <Box
                  mr={1}
                  inline
                  color="label">
                  Click on a gene to reveal it.
                </Box>
                <Button
                  content="Cancel Joker"
                  onClick={() => act('set_view', {
                    jokerActive: '',
                  })} />
              </Fragment>
            ) || (
              <Button
                icon="crown"
                color="purple"
                content="Use Joker"
                onClick={() => act('set_view', {
                  jokerActive: '1',
                })} />
            )
          )}>
          <GenomeSequencer
            state={state}
            mutation={mutation} />
        </Section>
      )}
    </Fragment>
  );
};

const GenomeImage = props => {
  const { url, selected, onClick } = props;
  let outline;
  if (selected) {
    outline = '2px solid #22aa00';
  }
  return (
    <Box
      as="img"
      src={url}
      style={{
        width: '64px',
        margin: '2px',
        'margin-left': '4px',
        outline,
      }}
      onClick={onClick} />
  );
};

const GeneCycler = props => {
  const { gene, onChange, disabled, ...rest } = props;
  const length = GENES.length;
  const index = GENES.indexOf(gene);
  const color = (disabled && GENE_COLORS['X']) || GENE_COLORS[gene];
  return (
    <Button
      {...rest}
      color={color}
      onClick={e => {
        e.preventDefault();
        if (!onChange) {
          return;
        }
        if (index === -1) {
          onChange(e, GENES[0]);
          return;
        }
        const nextGene = GENES[(index + 1) % length];
        onChange(e, nextGene);
      }}
      oncontextmenu={e => {
        e.preventDefault();
        if (!onChange) {
          return;
        }
        if (index === -1) {
          onChange(e, GENES[length - 1]);
          return;
        }
        const prevGene = GENES[(index - 1 + length) % length];
        onChange(e, prevGene);
      }}>
      {gene}
    </Button>
  );
};

const GenomeSequencer = props => {
  const { state, mutation } = props;
  const { data, act } = useBackend(props);
  const { jokerActive } = data.view;
  if (!mutation) {
    return (
      <Box color="average">
        No genome selected for sequencing.
      </Box>
    );
  }
  if (mutation.Scrambled) {
    return (
      <Box color="average">
        Sequence unreadable due to unpredictable mutation.
      </Box>
    );
  }
  // Create gene cycler buttons
  const sequence = mutation.Sequence;
  const defaultSeq = mutation.DefaultSeq;
  const buttons = [];
  for (let i = 0; i < sequence.length; i++) {
    const gene = sequence.charAt(i);
    const button = (
      <GeneCycler
        width="22px"
        textAlign="center"
        disabled={!!mutation.Scrambled || mutation.Class !== MUT_NORMAL}
        className={
          (defaultSeq?.charAt(i) === 'X' && !mutation.Active)
            ? classes([
              "outline-solid",
              "outline-color-orange",
            ])
            : false
        }
        gene={gene}
        onChange={(e, nextGene) => {
          if (e.ctrlKey) {
            act('pulse_gene', {
              pos: i + 1,
              gene: 'X',
              alias: mutation.Alias,
            });
            return;
          }
          if (jokerActive) {
            act('pulse_gene', {
              pos: i + 1,
              gene: 'J',
              alias: mutation.Alias,
            });
            act('set_view', {
              jokerActive: '',
            });
            return;
          }
          act('pulse_gene', {
            pos: i + 1,
            gene: nextGene,
            alias: mutation.Alias,
          });
        }} />
    );
    buttons.push(button);
  }
  // Render genome in two rows
  const pairs = [];
  for (let i = 0; i < buttons.length; i += 2) {
    const pair = (
      <Box
        key={i}
        inline
        m={0.5}>
        {buttons[i]}
        <Box
          mt="-2px"
          ml="10px"
          width="2px"
          height="8px"
          backgroundColor="label" />
        {buttons[i + 1]}
      </Box>
    );
    pairs.push(pair);
  }
  return (
    <Fragment>
      <Box m={-0.5}>
        {pairs}
      </Box>
      <Box color="label" mt={1}>
        <b>Tip:</b> Ctrl+Click on the gene to set it to X.
        Right Click to cycle in reverse.
      </Box>
    </Fragment>
  );
};

const DnaConsoleEnzymes = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const {
    isScannerConnected,
    stdDevAcc,
    stdDevStr,
  } = data;
  if (!isScannerConnected) {
    return (
      <Section color="bad">
        DNA Scanner is not connected.
      </Section>
    );
  }
  return (
    <Fragment>
      <Flex spacing={1} mb={1}>
        <Flex.Item width="155px">
          <RadiationEmitterSettings state={state} />
        </Flex.Item>
        <Flex.Item width="140px">
          <RadiationEmitterProbs state={state} />
        </Flex.Item>
        <Flex.Item grow={1} basis={0}>
          <RadiationEmitterPulseBoard state={state} />
        </Flex.Item>
      </Flex>
      <GeneticMakeupBuffers state={state} />
    </Fragment>
  );
};

const RadiationEmitterSettings = props => {
  const { data, act } = useBackend(props);
  const {
    radStrength,
    radDuration,
  } = data;
  return (
    <Section
      title="Radiation Emitter"
      minHeight="100%">
      <LabeledList>
        <LabeledList.Item label="Output level">
          <NumberInput
            animated
            width="32px"
            stepPixelSize={10}
            value={radStrength}
            minValue={1}
            maxValue={RADIATION_STRENGTH_MAX}
            onDrag={(e, value) => act('set_pulse_strength', {
              val: value,
            })} />
        </LabeledList.Item>
        <LabeledList.Item label="Pulse duration">
          <NumberInput
            animated
            width="32px"
            stepPixelSize={10}
            value={radDuration}
            minValue={1}
            maxValue={RADIATION_DURATION_MAX}
            onDrag={(e, value) => act('set_pulse_duration', {
              val: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RadiationEmitterProbs = props => {
  const { data } = useBackend(props);
  const {
    stdDevAcc,
    stdDevStr,
  } = data;
  return (
    <Section
      title="Probabilities"
      minHeight="100%">
      <LabeledList>
        <LabeledList.Item
          label="Accuracy"
          textAlign="right">
          {stdDevAcc}
        </LabeledList.Item>
        <LabeledList.Item
          label={`P(±${stdDevStr})`}
          textAlign="right">
          68 %
        </LabeledList.Item>
        <LabeledList.Item
          label={`P(±${stdDevStr * 2})`}
          textAlign="right">
          95 %
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const RadiationEmitterPulseBoard = props => {
  const { data, act } = useBackend(props);
  const {
    subjectUNI = [],
  } = data;
  // Build blocks of buttons of unique enzymes
  const blocks = [];
  let buffer = [];
  for (let i = 0; i < subjectUNI.length; i++) {
    const char = subjectUNI.charAt(i);
    // Push a button into the buffer
    const button = (
      <Button
        fluid
        key={i}
        textAlign="center"
        content={char}
        onClick={() => act('makeup_pulse', {
          index: i + 1,
        })} />
    );
    buffer.push(button);
    // Create a block from the current buffer
    if (buffer.length >= 3) {
      const block = (
        <Box inline width="22px" mx="1px">
          {buffer}
        </Box>
      );
      blocks.push(block);
      // Clear the buffer
      buffer = [];
    }
  }
  return (
    <Section
      title="Unique Enzymes"
      minHeight="100%"
      position="relative">
      <Box mx="-1px">
        {blocks}
      </Box>
    </Section>
  );
};

const GeneticMakeupBuffers = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const {
    diskHasMakeup,
    hasDisk,
    isViableSubject,
    makeupCapacity = 3,
    makeupStorage,
  } = data;
  const elements = [];
  for (let i = 1; i <= makeupCapacity; i++) {
    const makeup = makeupStorage[i];
    const element = (
      <Collapsible
        title={makeup
          ? (makeup.label || makeup.name)
          : `Slot ${i}`}
        buttons={
          <Fragment>
            {!!(hasDisk && diskHasMakeup) && (
              <Button
                mr={1}
                disabled={!hasDisk || !diskHasMakeup}
                content="Import from disk"
                onClick={() => act('load_makeup_disk', {
                  index: i,
                })} />
            )}
            <Button
              disabled={!isViableSubject}
              content="Save"
              onClick={() => act('save_makeup_console', {
                index: i,
              })} />
            <Button
              ml={1}
              icon="times"
              color="red"
              disabled={!makeup}
              onClick={() => act('del_makeup_console', {
                index: i,
              })} />
          </Fragment>
        }>
        <GeneticMakeupBufferInfo
          state={state}
          index={i}
          makeup={makeup} />
      </Collapsible>
    );
    elements.push(element);
  }
  return (
    <Section title="Genetic Makeup Buffers">
      {elements}
    </Section>
  );
};

const GeneticMakeupInfo = props => {
  const { makeup } = props;

  return (
    <Section title="Enzyme Information">
      <LabeledList>
        <LabeledList.Item label="Name">
          {makeup.name || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Blood Type">
          {makeup.blood_type || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Unique Enzyme">
          {makeup.UE || 'None'}
        </LabeledList.Item>
        <LabeledList.Item label="Unique Identifier">
          {makeup.UI || 'None'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const GeneticMakeupBufferInfo = props => {
  const { index, makeup } = props;
  const { act, data } = useBackend(props);
  const {
    isViableSubject,
    hasDisk,
    diskReadOnly,
    isInjectorReady,
  } = data;
  // Type of the action for applying makeup
  const ACTION_MAKEUP_APPLY = isViableSubject
    ? 'makeup_apply'
    : 'makeup_delay';
  if (!makeup) {
    return (
      <Box color="average">
        No stored subject data.
      </Box>
    );
  }
  return (
    <Fragment>
      <GeneticMakeupInfo makeup={makeup} />
      <Divider />
      <Box bold color="label" mb={1}>
        Makeup Actions
      </Box>
      <LabeledList>
        <LabeledList.Item label="Enzymes">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'ue',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'ue',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Identity">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'ui',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'ui',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Full Makeup">
          <Button
            icon="syringe"
            disabled={!isInjectorReady}
            content="Print"
            onClick={() => act('makeup_injector', {
              index,
              type: 'mixed',
            })} />
          <Button
            icon="exchange-alt"
            onClick={() => act(ACTION_MAKEUP_APPLY, {
              index,
              type: 'mixed',
            })}>
            Transfer
            {!isViableSubject && ' (Delayed)'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            icon="save"
            disabled={!hasDisk || diskReadOnly}
            content="Export To Disk"
            onClick={() => act('save_makeup_disk', {
              index,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Fragment>
  );
};

const DnaConsoleAdvancedInjectors = props => {
  const { state } = props;
  const { act, data } = useBackend(props);
  const {
    maxAdvInjectors,
    isInjectorReady,
  } = data;
  const advInjectors = data.storage.injector ?? [];
  return (
    <Section title="Advanced Injectors">
      {advInjectors.map(injector => (
        <Collapsible
          key={injector.name}
          title={injector.name}
          buttons={(
            <Fragment>
              <Button
                icon="syringe"
                disabled={!isInjectorReady}
                content="Print"
                onClick={() => act('print_adv_inj', {
                  name: injector.name,
                })} />
              <Button
                ml={1}
                color="red"
                icon="times"
                onClick={() => act('del_adv_inj', {
                  name: injector.name,
                })} />
            </Fragment>
          )}>
          <StorageMutations
            state={state}
            mutations={injector.mutations}
            customMode={`advinj${advInjectors.findIndex(
              e => injector.name === e.name)}`} />
        </Collapsible>
      ))}
      <Box mt={2}>
        <Button.Input
          minWidth="200px"
          content="Create new injector"
          disabled={advInjectors.length >= maxAdvInjectors}
          onCommit={(e, value) => act('new_adv_inj', {
            name: value,
          })} />
      </Box>
    </Section>
  );
};

const MutationCombiner = props => {
  const { state, mutations, source } = props;
  const { act, data } = useBackend(props);

  const brefFromName = name => {
    return mutations.find(mutation => mutation.Name === name)?.ByondRef;
  };

  return (
    <Dropdown
      key={source.ByondRef}
      width="240px"
      options={mutations.map(mutation => mutation.Name)}
      disabled={mutations.length === 0}
      selected="Combine mutations"
      onSelected={value => {
        act(`combine_${source.Source}`, {
          firstref: brefFromName(value),
          secondref: source.ByondRef,
        });
      }} />
  );
};
