import { classes } from 'common/react';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Collapsible, Dimmer, Divider, Dropdown, Flex, Icon, LabeledList, NumberInput, ProgressBar, Section, Tabs } from '../components';
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

const STORAGE_SUBMODE_MUTATIONS = 'mutations';
const STORAGE_SUBMODE_CHROMOSOMES = 'chromosomes';

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
      {consoleMode === CONSOLE_MODE_INJECTORS && (
        <DnaConsoleAdvancedInjectors state={state} />
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
  const { hasDisk } = data;
  const { consoleMode } = data.view;
  return (
    <Section title="DNA Console">
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
            disabled={!data.isViableSubject}
            selected={consoleMode === CONSOLE_MODE_ENZYMES}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_ENZYMES,
            })} />
          <Button
            content="Advanced Injectors"
            selected={consoleMode === CONSOLE_MODE_INJECTORS}
            onClick={() => act('set_view', {
              consoleMode: CONSOLE_MODE_INJECTORS,
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
  const { storageMode, storageSubMode } = data.view;
  return (
    <Fragment>
      <Button
        selected={storageSubMode === STORAGE_SUBMODE_MUTATIONS}
        content="Mutations"
        onClick={() => act('set_view', {
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
      <Button
        selected={storageSubMode === STORAGE_SUBMODE_CHROMOSOMES}
        disabled={storageMode !== STORAGE_MODE_CONSOLE}
        content="Chromosomes"
        onClick={() => act('set_view', {
          storageSubMode: STORAGE_SUBMODE_CHROMOSOMES,
        })} />
      <Box inline mr={1} />
      <Button
        content="Console"
        selected={storageMode === STORAGE_MODE_CONSOLE}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_CONSOLE,
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
      <Button
        content="Disk"
        disabled={!hasDisk}
        selected={storageMode === STORAGE_MODE_DISK}
        onClick={() => act('set_view', {
          storageMode: STORAGE_MODE_DISK,
          storageSubMode: STORAGE_SUBMODE_MUTATIONS,
        })} />
    </Fragment>
  );
};

const DnaConsoleStorage = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const { storageSubMode } = data.view;
  return (
    <Section
      title="Storage"
      buttons={(
        <StorageButtons state={state} />
      )}>
      {storageSubMode === STORAGE_SUBMODE_MUTATIONS && (
        <StorageMutations state={state} />
      )}
      {storageSubMode === STORAGE_SUBMODE_CHROMOSOMES && (
        <StorageChromosomes state={state} />
      )}
    </Section>
  );
};

const StorageMutations = props => {
  const { state } = props;
  const { data, act } = useBackend(props);
  const isDisk = data.view.storageMode === STORAGE_MODE_DISK;
  const mutations = isDisk
    ? (data.diskMutations ?? [])
    : (data.mutationStorage ?? []);
  const mutationRef = data.view.storageMutationRef;
  const mutation = mutations
    .find(mutation => mutation.ByondRef === mutationRef);
  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title={isDisk
            ? "Disk Storage"
            : "Console Storage"}
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
                storageMutationRef: mutation.ByondRef,
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
  const chromoName = data.view.storageChromoName;
  const chromo = chromos.find(chromo => chromo.Name === chromoName);
  return (
    <Flex>
      <Flex.Item width="140px">
        <Section
          title="Console Storage"
          level={2}>
          {chromos.map(chromo => (
            <Button
              key={chromo.Name}
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
    advInjectors,
    diskCapacity,
    diskReadOnly,
    hasDisk,
    isInjectorReady,
    mutationCapacity,
  } = data;
  const diskMutations = data.diskMutations ?? [];
  const mutationStorage = data.diskMutations ?? [];
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
        {mutation.Source === 'occupant' && (
          <Dropdown
            width="240px"
            options={advInjectors.map(injector => injector.name)}
            disabled={advInjectors.length === 0 || !mutation.Active}
            selected="Add to advanced injector"
            onSelected={value => act('add_advinj_mut', {
              mutref: mutation.ByondRef,
              advinj: value,
            })} />
        )}
        {['occupant', 'disk', 'console'].includes(mutation.Source) && (
          <Fragment>
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
      {['console', 'disk'].includes(mutation.Source) && (
        // TODO: MUTATION COMBINING LOGIC GOES HERE
        //  1. Some way to select any mutation that isn't this mutation.
        //    1.1. DM code is now set up to allow combining of mutations across
        //         both console and disk.
        //    1.2. Build a list of all mutations across both console and disk
        //    1.3. Trim duplicate alias mutations. Combined mutations do not
        //         inherit any metadata, so a list with no duplicate names is
        //         also ideal.
        //    1.5. 'this' mutation' should not be included in the list,
        //         including mutations with the same alias as 'this'.
        // 2. act(`combine_${mutation.Source}`, {
        //      firstref: mutation.ByondRef
        //      secondref: selectedMutation.ByondRef
        //    })
        // 3. disabled logic is the same as Save to Console/Disk as the action
        //    requires the ability to save a new mutation to the storage medium
        // 4. Minor edge case - If this is the list of possible mutations to
        //    combine this mutation with has a length of zero. This will occur
        //    when the DNA Console/Disk only has a single Alias of mutation, so
        //    the list of eligible mutations for combination will be empty.
        false
      )}
      {['console', 'disk', 'advinj'].includes(mutation.Source) && (
        <Button
          icon="times"
          color="red"
          content="Delete from storage"
          onClick={() => act(`delete_${mutation.Source}_mut`, {
            mutref: mutation.ByondRef,
          })} />
      )}
      {mutation.Source === 'occupant'
        && mutation.class === MUT_EXTRA
        && !mutation.Scrambled
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
  const mutations = data.subjectMutations ?? [];
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
        <Flex.Item width="154px">
          <Section
            title="Sequences"
            minHeight="100%">
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
  const { gene, onChange, ...rest } = props;
  const length = GENES.length;
  const index = GENES.indexOf(gene);
  const color = GENE_COLORS[gene];
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
        className={
          (defaultSeq.charAt(i) === 'X' && !mutation.Active)
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
    RADIATION_STRENGTH_MAX,
    RADIATION_DURATION_MAX,
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
    subjectUNI,
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
          index: i,
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

const GeneticMakeupBufferInfo = props => {
  const { index, makeup } = props;
  const { act, data } = useBackend(props);
  const {
    isViableSubject,
    hasDisk,
    diskReadOnly,
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
      <LabeledList>
        <LabeledList.Item label="Subject">
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
      <Divider />
      <Box bold color="label" mb={1}>
        Makeup Actions
      </Box>
      <LabeledList>
        <LabeledList.Item label="Enzymes">
          <Button
            icon="syringe"
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
    advInjectors = [],
  } = data;
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
          {injector.mutations.length === 0 && (
            <Box color="average">
              No mutations stored in this injector.
            </Box>
          ) || (
            <Tabs vertical>
              {injector.mutations.map(mutation => (
                <Tabs.Tab
                  key={mutation.ByondRef}
                  label={mutation.Name}>
                  {() => (
                    <Fragment>
                      <MutationInfo
                        state={state}
                        mutation={mutation} />
                      <Button
                        color="red"
                        icon="times"
                        content="Delete from advanced injector"
                        onClick={() => act('del_adv_mut', {
                          advinj: injector.name,
                          mutref: mutation.ByondRef,
                        })} />
                    </Fragment>
                  )}
                </Tabs.Tab>
              ))}
            </Tabs>
          )}
        </Collapsible>
      ))}
      <Box mt={2}>
        <Button.Input
          minWidth="200px"
          content="Create new injector"
          onCommit={(e, value) => act('new_adv_inj', {
            name: value,
          })} />
      </Box>
    </Section>
  );
};
