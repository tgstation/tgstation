import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack } from '../components';
import { Window } from '../layouts';

type Candidate = {
  comments: string;
  description: string;
  name: string;
};

const PAI_DESCRIPTION = `Personal AIs are advanced models
capable of nuanced interaction.
They are designed to be used in a variety of situations,
assisting their masters in their work. They do not possess
hands, thus they cannot interact with equipment or items.
While in hologram form, you cannot be directly killed, but you may
be incapacitated. `;

const PAI_RULES = `You are expected to role play to some degree.
Keep in mind: Not entering information may lead to you not being selected.
Press submit to alert PAI owners of your candidacy.`;

export const PaiSubmit = (props, context) => {
  const [input, setInput] = useLocalState<Candidate>(context, 'input', {
    comments: '',
    description: '',
    name: '',
  });

  const onChangeHandler = (e, value) => {
    setInput({ ...input, [value]: e.target.value });
  };

  return (
    <Window width={400} height={460} title="PAI Candidacy Menu">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay input={input} onChangeHandler={onChangeHandler} />
          </Stack.Item>
          <Stack.Item>
            <SubmitDisplay input={input} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const DetailsDisplay = () => {
  return (
    <Section fill scrollable title="Details">
      <Box color="label">
        {PAI_DESCRIPTION}
        <br />
        <br />
        {PAI_RULES}
      </Box>
    </Section>
  );
};

const InputDisplay = (props) => {
  const { input, onChangeHandler } = props;
  return (
    <Section fill title="Input">
      <Stack fill vertical>
        <Stack.Item>
          <Box bold color="label">
            Name
          </Box>
          <Input
            fluid
            value={input.name}
            onChange={(e) => onChangeHandler(e, 'name')}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            Description
          </Box>
          <Input
            fluid
            value={input.description}
            onChange={(e) => onChangeHandler(e, 'description')}
          />
        </Stack.Item>
        <Stack.Item>
          <Box bold color="label">
            OOC Comments
          </Box>
          <Input
            fluid
            value={input.comments}
            onChange={(e) => onChangeHandler(e, 'comments')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const SubmitDisplay = (props, context) => {
  const { act } = useBackend(context);
  const { input } = props;
  return (
    <Section fill>
      <Button
        onClick={() =>
          act('submit', {
            candidate: input,
          })
        }>
        SUBMIT
      </Button>
    </Section>
  );
};
