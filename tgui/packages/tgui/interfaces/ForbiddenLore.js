import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const ForbiddenLore = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    charges,
  } = data;
  const to_know = flow([
    sortBy(to_know => to_know.state !== "Research",
      to_know => to_know.path === "Side"),
  ])(data.to_know || []);
  return (
    <Window
      width={500}
      height={900}
      resizable>
      <Window.Content scrollable>
        <Section title="Research Eldritch Knowledge">
          Charges left : {charges}
          {to_know!== null ? (
            to_know.map(knowledge => (
              <Section
                key={knowledge.name}
                title={knowledge.name}
                level={2}>
                <Box bold my={1}>
                  {knowledge.path} path
                </Box>
                <Box my={1}>
                  <Button
                    content={knowledge.state}
                    disabled={knowledge.disabled}
                    onClick={() => act('research', {
                      name: knowledge.name,
                      cost: knowledge.cost,
                    })} />
                  {' '}
                  Cost : {knowledge.cost}
                </Box >
                <Box italic my={1}>
                  {knowledge.flavour}
                </Box>
                <Box my={1}>
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
