import {
  BlockQuote,
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  candidates: ReadonlyArray<Candidate>;
  pai: Pai;
  range_max: number;
  range_min: number;
};

type Candidate = Readonly<{
  comments: string;
  ckey: string;
  description: string;
  name: string;
}>;

type Pai = {
  can_holo: BooleanLike;
  dna: string;
  emagged: BooleanLike;
  laws: string;
  master: string;
  name: string;
  transmit: BooleanLike;
  receive: BooleanLike;
  range: number;
};

export const PaiCard = (props) => {
  const { data } = useBackend<Data>();
  const { pai } = data;

  return (
    <Window width={400} height={400} title="pAI Options Menu">
      <Window.Content scrollable>
        {!pai ? <PaiDownload /> : <PaiOptions />}
      </Window.Content>
    </Window>
  );
};

/** Gives a list of candidates as cards */
const PaiDownload = (props) => {
  const { act, data } = useBackend<Data>();
  const { candidates = [] } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <NoticeBox info>
          <Stack fill>
            <Stack.Item grow fontSize="16px">
              pAI Candidates
            </Stack.Item>
            <Stack.Item>
              <Button
                color="good"
                icon="bell"
                onClick={() => act('request')}
                tooltip="Request more candidates from beyond."
              >
                Request
              </Button>
            </Stack.Item>
          </Stack>
        </NoticeBox>
      </Stack.Item>
      {candidates.map((candidate, index) => {
        return (
          <Stack.Item key={index}>
            <CandidateDisplay candidate={candidate} index={index + 1} />
          </Stack.Item>
        );
      })}
    </Stack>
  );
};

/**
 * Renders a custom section that displays a candidate.
 */
const CandidateDisplay = (props: { candidate: Candidate; index: number }) => {
  const { act } = useBackend<Data>();
  const {
    candidate: { comments, ckey, description, name },
    index,
  } = props;

  return (
    <Section
      buttons={
        <Button icon="save" onClick={() => act('download', { ckey })}>
          Download
        </Button>
      }
      overflow="hidden"
      title={`Candidate ${index}`}
    >
      <Stack vertical>
        <Stack.Item>
          <Box color="label" mb={1}>
            Name:
          </Box>
          {name ? (
            <Box color="green">{name}</Box>
          ) : (
            'None provided - name will be randomized.'
          )}
        </Stack.Item>
        {!!description && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                IC Description:
              </Box>
              {description}
            </Stack.Item>
          </>
        )}
        {!!comments && (
          <>
            <Stack.Divider />
            <Stack.Item>
              <Box color="label" mb={1}>
                OOC Notes:
              </Box>
              {comments}
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

/** Once a pAI has been loaded, you can alter its settings here */
const PaiOptions = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    range_max,
    range_min,
    pai: {
      can_holo,
      dna,
      emagged,
      laws,
      master,
      name,
      transmit,
      receive,
      range,
    },
  } = data;
  const suppliedLaws = laws[0] ? decodeHtmlEntities(laws[0]) : 'None';

  return (
    <Section fill scrollable title={`Settings: ${name.toUpperCase()}`}>
      <LabeledList>
        <LabeledList.Item label="Master">
          {master || (
            <Button icon="dna" onClick={() => act('set_dna')}>
              Imprint
            </Button>
          )}
        </LabeledList.Item>
        {!!master && (
          <LabeledList.Item color="red" label="DNA">
            {dna}
          </LabeledList.Item>
        )}
        <LabeledList.Item label="Laws">
          <BlockQuote>{suppliedLaws}</BlockQuote>
        </LabeledList.Item>
        <LabeledList.Item label="Holoform">
          <Button
            icon={can_holo ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_holo')}
            selected={can_holo}
          >
            Toggle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Holoform Range">
          {emagged ? (
            '∞'
          ) : (
            <Stack>
              <Stack.Item>
                <Button
                  icon="fa-circle-minus"
                  onClick={() => act('decrease_range')}
                  disabled={range === range_min}
                />
              </Stack.Item>
              <Stack.Item mt={0.5}>{range}</Stack.Item>
              <Stack.Item>
                <Button
                  icon="fa-circle-plus"
                  onClick={() => act('increase_range')}
                  disabled={range === range_max}
                />
              </Stack.Item>
            </Stack>
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Transmit">
          <Button
            icon={transmit ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'transmit' })}
            selected={transmit}
          >
            Toggle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Receive">
          <Button
            icon={receive ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'receive' })}
            selected={receive}
          >
            Toggle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Troubleshoot">
          <Button icon="comment" onClick={() => act('fix_speech')}>
            Fix Speech
          </Button>
          <Button icon="edit" onClick={() => act('set_laws')}>
            Set Laws
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Personality">
          <Button icon="trash" onClick={() => act('wipe_pai')}>
            Erase
          </Button>
        </LabeledList.Item>
      </LabeledList>
      {!!emagged && (
        <Button
          color="bad"
          icon="bug"
          mt={1}
          onClick={() => act('reset_software')}
        >
          Reset Software
        </Button>
      )}
    </Section>
  );
};
