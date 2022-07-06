import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

type Data = {
  comments: string;
  description: string;
  name: string;
};

const PAI_DESCRIPTION = `Personal AIs are advanced models
capable of nuanced interaction. They are designed to be used
in a variety of situations, assisting their masters in their
work. They do not possess hands, thus they cannot interact with
equipment or items. While in hologram form, you cannot be
directly killed, but you may be incapacitated.`;

const PAI_RULES = `You are expected to role play to some degree.
Keep in mind: Not entering information may lead to you not being
selected. Press submit to alert pAI cards of your candidacy.`;

export const PaiSubmit = (props, context) => {
  return (
    <Window width={400} height={460} title="pAI Candidacy Menu">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <DetailsDisplay />
          </Stack.Item>
          <Stack.Item>
            <InputDisplay />
          </Stack.Item>
          <Stack.Item>
            <ButtonsDisplay />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays basic info about playing pAI */
const DetailsDisplay = (props, context) => {
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

/** Input boxes for submission details */
const InputDisplay = (props, context) => {
  const { data } = useBackend<Data>(context);
  const { comments, description, name } = data;
  const [input, setInput] = useLocalState<Data>(context, 'input', {
    comments,
    description,
    name,
  });

  return (
    <Section fill title="Input">
      <Stack fill vertical>
        <Stack.Item>
          <Tooltip content="The name of your pAI.">
            <Box bold color="label">
              Name
            </Box>
            <Input
              fluid
              value={name}
              onChange={(e, value) => setInput({ ...input, name: value })}
            />
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="This describes how you will (mis)behave in game.">
            <Box bold color="label">
              Description
            </Box>
            <Input
              fluid
              value={description}
              onChange={(e, value) =>
                setInput({ ...input, description: value })
              }
            />
          </Tooltip>
        </Stack.Item>
        <Stack.Item>
          <Tooltip content="Any other OOC comments about your pAI personality.">
            <Box bold color="label">
              OOC Comments
            </Box>
            <Input
              fluid
              value={comments}
              onChange={(e, value) => setInput({ ...input, comments: value })}
            />
          </Tooltip>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

/** Gives the user a submit button */
const ButtonsDisplay = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { comments, description, name } = data;
  const [input, setInput] = useLocalState<Data>(context, 'input', {
    comments,
    description,
    name,
  });

  return (
    <Section fill>
      <Stack>
        <Stack.Item>
          <Button
            onClick={() => act('save', { candidate: input })}
            tooltip="Saves your candidate data locally.">
            SAVE
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() => act('load')}
            tooltip="Loads saved candidate data, if any.">
            LOAD
          </Button>
        </Stack.Item>
        <Stack.Item>
          <Button
            onClick={() =>
              act('submit', {
                candidate: input,
              })
            }>
            SUBMIT
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
