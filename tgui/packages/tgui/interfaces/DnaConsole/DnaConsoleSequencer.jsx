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
  const { url, selected, onClick } = props;
  let outline;
  if (selected) {
    outline = '2px solid #22aa00';
  }
  return (
    <Image
      src={url}
      style={{
        width: '64px',
        margin: '2px',
        marginLeft: '4px',
        outline,
      }}
      onClick={onClick}
    />
  );
};

const GeneCycler = (props) => {
  const { act } = useBackend();
  const { alias, gene, index, disabled, ...rest } = props;
  const color = (disabled && GENE_COLORS['X']) || GENE_COLORS[gene];
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
          defaultSeq?.charAt(i) === 'X' && !mutation.Active
            ? classes(['outline-solid', 'outline-color-orange'])
            : false
        }
        gene={gene}
        index={i}
        alias={mutation.Alias}
      />
    );
    buttons.push(button);
  }
  // Render genome in two rows
  const pairs = [];
  for (let i = 0; i < buttons.length; i += 2) {
    const pair = (
      <Box key={i} inline m={0.5}>
        {buttons[i]}
        <Box
          mt="-2px"
          ml="10px"
          width="2px"
          height="8px"
          backgroundColor="label"
        />
        {buttons[i + 1]}
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

export const DnaConsoleSequencer = (props) => {
  const { data, act } = useBackend();
  const mutations = data.storage?.occupant ?? [];
  const { isJokerReady, isMonkey, jokerSeconds, subjectStatus } = data;
  const { sequencerMutation, jokerActive } = data.view;
  const mutation = mutations.find(
    (mutation) => mutation.Alias === sequencerMutation,
  );
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
        )}
    </>
  );
};
