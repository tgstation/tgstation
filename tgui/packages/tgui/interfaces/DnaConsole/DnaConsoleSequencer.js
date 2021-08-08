import { classes } from 'common/react';
import { resolveAsset } from '../../assets';
import { useBackend } from '../../backend';
import { Box, Button, Section, Stack } from '../../components';
import { MutationInfo } from './MutationInfo';
import { GENES, GENE_COLORS, MUT_NORMAL, SUBJECT_DEAD, SUBJECT_TRANSFORMING } from './constants';

const GenomeImage = (props, context) => {
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

const GeneCycler = (props, context) => {
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

const GenomeSequencer = (props, context) => {
  const { mutation } = props;
  const { data, act } = useBackend(context);
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

    if ((i % 8 === 0) && (i !== 0)) {
      pairs.push(
        <Box
          key={`${i}_divider`}
          inline
          position="relative"
          top="-17px"
          left="-1px"
          width="8px"
          height="2px"
          backgroundColor="label" />,
      );
    }

    pairs.push(pair);
  }
  return (
    <>
      <Box m={-0.5}>
        {pairs}
      </Box>
      <Box color="label" mt={1}>
        <b>Tip:</b> Ctrl+Click on the gene to set it to X.
        Right Click to cycle in reverse.
      </Box>
    </>
  );
};

export const DnaConsoleSequencer = (props, context) => {
  const { data, act } = useBackend(context);
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
    <>
      <Stack mb={1}>
        <Stack.Item width={mutations.length <= 8 && "154px" || "174px"}>
          <Section
            title="Sequences"
            height="214px"
            overflowY={mutations.length > 8 && "scroll"}>
            {mutations.map(mutation => (
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
                }} />
            ))}
          </Section>
        </Stack.Item>
        <Stack.Item grow={1} basis={0}>
          <Section
            title="Sequence Info"
            minHeight="100%">
            <MutationInfo
              mutation={mutation} />
          </Section>
        </Stack.Item>
      </Stack>
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
              <>
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
              </>
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
            mutation={mutation} />
        </Section>
      )}
    </>
  );
};
