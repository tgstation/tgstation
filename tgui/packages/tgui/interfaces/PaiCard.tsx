import { useBackend } from '../backend';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type PaiCardData = {
  candidates: Candidate[];
  pai: Pai[] | null;
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

export const PaiCard = (props, context) => {
  const { data } = useBackend<PaiCardData>(context);
  const { pai } = data;

  return (
    <Window width={400} height={400} title="pAI Options Menu">
      <Window.Content>{!pai ? <PaiDownload /> : <PaiOptions />}</Window.Content>
    </Window>
  );
};

const PaiDownload = (props, context) => {
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
        <Stack>
          {candidates.map((candidate) => {
            return (
              <Stack.Item key={candidate}>
                <CandidateDisplay candidate={candidate} />
              </Stack.Item>
            );
          })}
        </Stack>
      )}
    </Section>
  );
};

const CandidateDisplay = (props, context) => {
  const { act } = useBackend<PaiCardData>(context);
  const { candidate } = props;
  const { comments, description, key, name } = candidate;
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
            onClick={() => act('download', { key })}
            tooltip="Accepts this pAI candidate.">
            Download
          </Button>
        }
        scrollable
        title={name}>
        <LabeledList>
          <Tooltip content="If entered, describes the playstyle of the pAI.">
            <LabeledList.Item label="Description">
              {description}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip content="Out of character comments.">
            <LabeledList.Item label="Comments">{comments}</LabeledList.Item>
          </Tooltip>
        </LabeledList>
      </Section>
    </Box>
  );
};

const PaiOptions = (props, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { pai } = data;
  return 'Hello';
};
