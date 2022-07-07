import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  candidates: Candidate[];
  pai: Pai;
};

type Candidate = {
  comments: string;
  ckey: string;
  description: string;
  name: string;
};

type Pai = {
  can_holo: BooleanLike;
  dna: string;
  emagged: BooleanLike;
  laws: string;
  master: string;
  name: string;
  transmit: BooleanLike;
  receive: BooleanLike;
};

export const PaiCard = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { pai } = data;

  return (
    <Window width={400} height={400} title="pAI Options Menu">
      <Window.Content>{!pai ? <PaiDownload /> : <PaiOptions />}</Window.Content>
    </Window>
  );
};

/** Gives a list of candidates as cards */
const PaiDownload = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { candidates = [] } = data;

  return (
    <Section
      buttons={
        <Button
          icon="bell"
          onClick={() => act('request')}
          tooltip="Request candidates.">
          Request
        </Button>
      }
      fill
      scrollable
      title="pAI Candidates">
      {!candidates?.length ? (
        <NoticeBox>None found!</NoticeBox>
      ) : (
        <Stack fill vertical>
          {candidates.map((candidate, index) => {
            return (
              <Stack.Item key={index}>
                <CandidateDisplay candidate={candidate} index={index + 1} />
              </Stack.Item>
            );
          })}
        </Stack>
      )}
    </Section>
  );
};

/**
 * Renders a custom section that displays a candidate.
 */
const CandidateDisplay = (
  props: { candidate: Candidate; index: number },
  context
) => {
  const { act } = useBackend<Data>(context);
  const {
    candidate: { comments, ckey, description, name },
    index,
  } = props;

  return (
    <Box
      style={{
        'background': '#111111',
        'border': '1px solid #4972a1',
        'border-radius': '5px',
        'padding': '1rem',
      }}>
      <Section
        buttons={
          <Button
            icon="download"
            onClick={() => act('download', { ckey })}
            tooltip="Accepts this pAI candidate.">
            Download
          </Button>
        }
        fill
        height={12}
        scrollable
        title={'Candidate ' + index}>
        <Box color="green" fontSize="16px" mb={1}>
          Name: {name || '(Randomized Name)'}
        </Box>
        <LabeledList>
          <LabeledList.Item label="IC Description">
            {description || 'None'}
          </LabeledList.Item>
          <LabeledList.Item label="OOC Comments">
            {comments || 'None'}
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Box>
  );
};

/** Once a pAI has been loaded, you can alter its settings here */
const PaiOptions = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    pai: { can_holo, dna, emagged, laws, master, name, transmit, receive },
  } = data;

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
        {!!master && <LabeledList.Item label="DNA">{dna}</LabeledList.Item>}
        <LabeledList.Item label="Laws">{laws}</LabeledList.Item>
        <LabeledList.Item label="Holoform">
          <Button
            icon={can_holo ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_holo')}
            selected={can_holo}>
            Toggle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Transmit">
          <Button
            icon={transmit ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'transmit' })}
            selected={transmit}>
            Toggle
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Receive">
          <Button
            icon={receive ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggle_radio', { option: 'receive' })}
            selected={receive}>
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
        <Button color="bad" disabled icon="bug" mt={1}>
          Malicious Software Detected
        </Button>
      )}
    </Section>
  );
};
