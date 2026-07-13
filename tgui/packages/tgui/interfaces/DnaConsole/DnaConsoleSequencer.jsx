import { Box, Button, Image, Section, Stack } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import {
  CLEAR_GENE,
  GENE_COLORS,
  MUT_NORMAL,
  NEXT_GENE,
  PREV_GENE,
  SUBJECT_DEAD,
  SUBJECT_TRANSFORMING,
} from './constants';
import { MutationInfo } from './MutationInfo';

const GenomeImage = (props) => {
  const { url, selected, inScanner, onClick } = props;
  let outline;
  if (selected) {
    outline = '2px solid #22aa00';
  }
  return (
    <Box
      inline
      position="relative"
      style={{ margin: '2px', marginLeft: '4px' }}
    >
      <Image
        src={url}
        style={{
          width: '64px',
          display: 'block',
          outline,
        }}
        onClick={onClick}
      />
      {inScanner && (
        <Box
          position="absolute"
          bottom="2px"
          right="2px"
          color="good"
          style={{ fontSize: '10px', lineHeight: 1, pointerEvents: 'none' }}
        >
          <b>M</b>
        </Box>
      )}
    </Box>
  );
};

const GeneCycler = (props) => {
  const { act } = useBackend();
  const { alias, gene, index, disabled, ...rest } = props;
  const color = (disabled && GENE_COLORS.X) || GENE_COLORS[gene];
  return (
    <Button
      {...rest}
      color={color}
      onClick={(e) => {
        e.preventDefault();
        if (e.ctrlKey) {
          act('pulse_gene', {
            pos: index + 1,
            pulseAction: CLEAR_GENE,
            alias: alias,
          });
          return;
        }

        act('pulse_gene', {
          pos: index + 1,
          pulseAction: NEXT_GENE,
          alias: alias,
        });

        return;
      }}
      onContextMenu={(e) => {
        e.preventDefault();

        act('pulse_gene', {
          pos: index + 1,
          pulseAction: PREV_GENE,
          alias: alias,
        });
      }}
    >
      {gene}
    </Button>
  );
};

function isPairMatched(sequence, index) {
  const gene1 = sequence.charAt(index);
  const gene2 = sequence.charAt(index + 1);
  return (
    (gene1 === 'A' && gene2 === 'T') ||
    (gene1 === 'T' && gene2 === 'A') ||
    (gene1 === 'G' && gene2 === 'C') ||
    (gene1 === 'C' && gene2 === 'G')
  );
}

function buildGenomePairs(sequence, renderGene) {
  const pairs = [];
  for (let i = 0; i < sequence.length; i += 2) {
    const pair = (
      <Box key={i} inline m={0.5}>
        {renderGene(i)}
        <Box
          mt="-2px"
          ml="10px"
          width="3px"
          height="8px"
          backgroundColor={isPairMatched(sequence, i) ? 'label' : 'red'}
        />
        {renderGene(i + 1)}
      </Box>
    );

    if (i % 8 === 0 && i !== 0) {
      pairs.push(
        <Box
          key={`${i}_divider`}
          inline
          position="relative"
          top="-17px"
          left="-1px"
          width="8px"
          height="2px"
          backgroundColor="label"
        />,
      );
    }

    pairs.push(pair);
  }
  return pairs;
}

const GenomeSequencer = (props) => {
  const { mutation } = props;
  if (!mutation) {
    return <Box color="average">No genome selected for sequencing.</Box>;
  }
  if (mutation.Scrambled) {
    return (
      <Box color="average">
        Sequence unreadable due to unpredictable mutation.
      </Box>
    );
  }
  const sequence = mutation.Sequence;
  const defaultSeq = mutation.DefaultSeq;
  const pairs = buildGenomePairs(sequence, (i) => (
    <GeneCycler
      width="22px"
      textAlign="center"
      disabled={!!mutation.Scrambled || mutation.Class !== MUT_NORMAL}
      className={
        defaultSeq?.charAt(i) === 'X' && !mutation.Active
          ? classes(['outline-solid', 'outline-color-orange'])
          : false
      }
      gene={sequence.charAt(i)}
      index={i}
      alias={mutation.Alias}
    />
  ));
  return (
    <>
      <Box m={-0.5}>{pairs}</Box>
      <Box color="label" mt={1}>
        <b>Tip:</b> Ctrl+Click on the gene to set it to X. Right Click to cycle
        in reverse.
      </Box>
    </>
  );
};

// Read only version of the genome sequencer.
const GenomeSequencerReadOnly = (props) => {
  const { sequence } = props;
  const pairs = buildGenomePairs(sequence, (i) => {
    const gene = sequence.charAt(i);
    return (
      <Button
        key={i}
        width="22px"
        textAlign="center"
        color={GENE_COLORS[gene] || GENE_COLORS.X}
        style={{ pointerEvents: 'none' }} //Probably a better way but hehe >:)
      >
        {gene}
      </Button>
    );
  });
  return <Box m={-0.5}>{pairs}</Box>;
};

export const DnaConsoleSequencer = (props) => {
  const { data, act } = useBackend();
  const mutations = data.storage?.occupant ?? [];
  const {
    isJokerReady,
    isMonkey,
    jokerSeconds,
    subjectStatus,
    heldScannerBuffer,
  } = data;
  const { sequencerMutation, jokerActive } = data.view;
  const mutation = mutations.find(
    (mutation) => mutation.Alias === sequencerMutation,
  );
  const scannerSequence =
    heldScannerBuffer && mutation && heldScannerBuffer[mutation.Alias];
  return (
    <>
      <Stack mb={1}>
        <Stack.Item width={(mutations.length <= 8 && '154px') || '174px'}>
          <Section
            title="Sequences"
            height="214px"
            overflowY={mutations.length > 8 && 'scroll'}
          >
            {mutations.map((mutation) => (
              <GenomeImage
                key={mutation.Alias}
                url={resolveAsset(mutation.Image)}
                selected={mutation.Alias === sequencerMutation}
                inScanner={!!heldScannerBuffer?.[mutation.Alias]}
                onClick={() => {
                  act('set_view', {
                    sequencerMutation: mutation.Alias,
                  });
                  act('check_discovery', {
                    alias: mutation.Alias,
                  });
                }}
              />
            ))}
          </Section>
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <Section title="Sequence Info" minHeight="100%">
            <MutationInfo mutation={mutation} />
          </Section>
        </Stack.Item>
      </Stack>
      {(subjectStatus === SUBJECT_DEAD && (
        <Section color="bad">
          Genetic sequence corrupted. Subject diagnostic report: DECEASED.
        </Section>
      )) ||
        (isMonkey && mutation?.Name !== 'Monkified' && (
          <Section color="bad">
            Genetic sequence corrupted. Subject diagnostic report: MONKEY.
          </Section>
        )) ||
        (subjectStatus === SUBJECT_TRANSFORMING && (
          <Section color="bad">
            Genetic sequence corrupted. Subject diagnostic report: TRANSFORMING.
          </Section>
        )) || (
          <>
            <Section
              title="Genome Sequencer™"
              buttons={
                (!isJokerReady && (
                  <Box lineHeight="20px" color="label">
                    Joker on cooldown ({jokerSeconds}s)
                  </Box>
                )) ||
                (jokerActive && (
                  <>
                    <Box mr={1} inline color="label">
                      Click on a gene to reveal it.
                    </Box>
                    <Button
                      content="Cancel Joker"
                      onClick={() =>
                        act('set_view', {
                          jokerActive: '',
                        })
                      }
                    />
                  </>
                )) || (
                  <Button
                    icon="crown"
                    color="purple"
                    content="Use Joker"
                    onClick={() =>
                      act('set_view', {
                        jokerActive: '1',
                      })
                    }
                  />
                )
              }
            >
              <GenomeSequencer mutation={mutation} />
            </Section>
            {!!scannerSequence && (
              <Section title="Held Scanner">
                <GenomeSequencerReadOnly sequence={scannerSequence} />
              </Section>
            )}
          </>
        )}
    </>
  );
};
