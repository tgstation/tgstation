import { useBackend } from '../backend';
import { map } from 'common/collections';
import { Button, Section, Box, Tabs } from '../components';
import { Window } from '../layouts';

export const ForbiddenLore = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    charges,
    to_know = {},
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Research Eldritch Knowledge">
          Charges left : {charges}
          {to_know !== null ? (
            to_know.map(knowledge => (
              <Section
                key={knowledge.name}
                title={knowledge.name}

                level={2}>
                <Box bold>
                  {knowledge.path} path
                </Box>
                <br />
                <Box>
                  <Button
                    content={knowledge.state}
                    disabled={knowledge.disabled}
                    onClick={() => act('research', {
                      name: knowledge.name,
                      cost: knowledge.cost,
                    })} />
                  {' '}
                  Cost : {knowledge.cost}
                </Box>
                <br />
                <Box italic>
                  {knowledge.flavour}
                </Box>
                <br />
                <Box>
                  {knowledge.desc}
                </Box>
              </Section>
            ))
          ) : (
            <Box>
              No more knowledge can be found
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
