import { useBackend } from '../backend';
import { flow } from 'common/fp';
import { sortBy } from 'common/collections';
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
  const SortByPath = flow([
    sortBy(to_know => to_know.state !== "Research",
      to_know => to_know.path === "Side"),
  ])(data.to_know || []);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Research Eldritch Knowledge">
          Charges left : {charges}
          {SortByPath!== null ? (
            SortByPath.map(knowledge => (
              <Section
                key={knowledge.name}
                title={knowledge.name}
                level={2}>
                <Box bold mb={1} mt={1}>
                  {knowledge.path} path
                </Box>
                <Box mb={1} mt={1}>
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
                <Box italic mb={1} mt={1}>
                  {knowledge.flavour}
                </Box>
                <Box mb={1} mt={1}>
                  {knowledge.desc}
                </Box>
              </Section>
            ))
          ) : (
            <Box >
              No more knowledge can be found
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
