import { useBackend } from '../backend';
import {
  Button,
  Collapsible,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

type PaiCardData = {
  candidates: Candidate[];
  pai: Pai[];
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
    <Stack fill vertical>
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
          candidates.map((candidate) => {
            return <CandidateDisplay candidate={candidate} key={candidate} />;
          })
        )}
      </Section>
    </Stack>
  );
};

const CandidateDisplay = (props, context) => {
  const { act } = useBackend<PaiCardData>(context);
  const { candidate } = props;
  const { comments, description, key, name } = candidate;
  return (
    <Collapsible title={name}>
      <LabeledList>
        <Tooltip content="If entered, describes the playstyle of the pAI.">
          <LabeledList.Item label="Description">{description}</LabeledList.Item>
        </Tooltip>
        <Tooltip content="Out of character comments.">
          <LabeledList.Item label="Comments">{comments}</LabeledList.Item>
        </Tooltip>
      </LabeledList>
      <Button
        icon="download"
        mt={1}
        onClick={() => act('accept', { candidate: key })}
        tooltip="Accepts this pAI candidate.">
        Download
      </Button>
    </Collapsible>
  );
};

const PaiOptions = (props, context) => {
  const { act, data } = useBackend<PaiCardData>(context);
  const { pai } = data;
  return 'Hello';
};
