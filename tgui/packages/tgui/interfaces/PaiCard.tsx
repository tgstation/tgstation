import { useBackend, useLocalState } from '../backend';
import { Box, Button, LabeledList, NoticeBox, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type PaiCardData = {
  candidates: Candidate[];
  pai: Pai;
};

type Candidate = {
  comments: string;
  description: string;
  key: string;
  name: string;
};

type Pai = {
  can_holo: number;
  dna: string;
  emagged: number;
  laws: string;
  master: string;
  name: string;
  transmit: number;
  receive: number;
};

export const PaiCard = (_, context) => {
  const { data } = useBackend<PaiCardData>(context);
  const { pai } = data;

  return (
    <Window width={400} height={400} title="pAI Options Menu">
      <Window.Content>{!pai ? <PaiDownload /> : <PaiOptions />}</Window.Content>
    </Window>
  );
};

/** Gives a list of candidates as cards */
const PaiDownload = (_, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { candidates = [] } = data;

  return (
    <Section
      buttons={
        <Button
          icon="concierge-bell"
          onClick={() => act('request')}
          tooltip="Request candidates.">
          Request
        </Button>
      }
      fill
      scrollable
      title="Viewing pAI Candidates">
      {!candidates.length ? (
        <NoticeBox>None found!</NoticeBox>
      ) : (
        <Stack fill vertical>
          {candidates.map((candidate, index) => {
            return (
              <Stack.Item key={index}>
                <CandidateDisplay candidate={candidate} />
              </Stack.Item>
            );
          })}
        </Stack>
      )}
    </Section>
  );
};

/** Candidate card: Individual. Since this info is refreshing,
 * had to make the comments and descriptions a separate tab.
 * In longer entries, it is much more readable.
 */
const CandidateDisplay = (props, context) => {
  const [tab, setTab] = useLocalState(context, 'tab', 'description');
  const { candidate } = props;
  const { comments, description, name } = candidate;

  const onTabClickHandler = (tab: string) => {
    setTab(tab);
  };

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
          <CandidateTabs
            candidate={candidate}
            onTabClick={onTabClickHandler}
            tab={tab}
          />
        }
        fill
        height={12}
        scrollable
        title="Candidate">
        <Box color="green" fontSize="16px">
          Name: {name || 'Randomized Name'}
        </Box>
        {tab === 'description'
          ? (`Description: ${description.length && description || "None"}`)
          : (`OOC Comments: ${comments.length && comments || "None"}`)}
      </Section>
    </Box>
  );
};

/** Tabs for the candidate */
const CandidateTabs = (props, context) => {
  const { act } = useBackend<PaiCardData>(context);
  const { candidate, onTabClick, tab } = props;
  const { key } = candidate;

  return (
    <Stack>
      <Stack.Item>
        <Tabs>
          <Tabs.Tab
            onClick={() => {
              onTabClick('description');
            }}
            selected={tab === 'description'}>
            Description
          </Tabs.Tab>
          <Tabs.Tab
            onClick={() => {
              onTabClick('comments');
            }}
            selected={tab === 'comments'}>
            OOC
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="download"
          onClick={() => act('download', { key })}
          tooltip="Accepts this pAI candidate.">
          Download
        </Button>
      </Stack.Item>
    </Stack>
  );
};

/** Once a pAI has been loaded, you can alter its settings here */
const PaiOptions = (_, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { pai } = data;
  const { can_holo, dna, emagged, laws, master, name, transmit, receive } = pai;

  return (
    <Section fill scrollable title={name}>
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
