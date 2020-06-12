import { createSearch } from 'common/string';
import { Box, Button, Input, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

const PATTERN_DESCRIPTOR = / \[(?:ghost|dead)\]$/;
const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareNumberedText = (a, b) => {
  const aName = a.name;
  const bName = b.name;

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const aNumberMatch = aName.match(PATTERN_NUMBER);
  const bNumberMatch = bName.match(PATTERN_NUMBER);

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const aNumber = parseInt(aNumberMatch[1], 10);
    const bNumber = parseInt(bNumberMatch[1], 10);

    return aNumber - bNumber;
  }

  return aName.localeCompare(bName);
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);

  return source.length > 0 && (
    <Section title={title}>
      {
        things.map(thing => (<Button
          key={thing.name}
          content={thing.name.replace(PATTERN_DESCRIPTOR, "")}
          onClick={() => act("orbit", { name: thing.name })}
        />))
      }
    </Section>
  );
};

const OrbitedButton = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (<Button
    color={color}
    content={(
      <span>
        {thing.name}
        {
          thing.orbiters && (
            <span>
              <Box inline mr={1} />
              ({thing.orbiters}{" "}
              <Box
                as="img"
                src="ghost.png"
                opacity={0.7}
              />)
            </span>
          )
        }
      </span>
    )}
    onClick={() => act("orbit", { name: thing.name })}
  />);
};

export const Orbit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    alive,
    antagonists,
    dead,
    ghosts,
    misc,
    npcs,
  } = data;

  const [searchText, setSearchText] = useLocalState(context, "searchText", "");

  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    if (collatedAntagonists[antagonist.antag] === undefined) {
      collatedAntagonists[antagonist.antag] = [];
    }

    collatedAntagonists[antagonist.antag].push(antagonist);
  }

  const sortedAntagonists = Object.entries(collatedAntagonists);
  sortedAntagonists.sort((a, b) => {
    return a[0].localeCompare(b[0]);
  });

  return (
    <Window>
      <Window.Content>
        <Section title={
          <Input
            fluid
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
          />
        } />

        { antagonists.length > 0 && (
          <Section title="Ghost-Visible Antagonists">
            { sortedAntagonists.map(([name, antags]) => {
              return (
                <Section key={name} title={name} level={2}>
                  {
                    antags
                      .filter(searchFor(searchText))
                      .sort(compareNumberedText)
                      .map(antag => (
                        <OrbitedButton
                          key={antag.name}
                          color="bad"
                          thing={antag}
                        />
                      ))
                  }
                </Section>
              );
            }) }
          </Section>
        ) }

        <Section title="Alive">
          { alive
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing}
              />)
            )}
        </Section>

        <BasicSection
          title="Ghosts"
          source={ghosts}
          searchText={searchText}
        />

        <BasicSection
          title="Dead"
          source={dead}
          searchText={searchText}
        />

        <BasicSection
          title="NPCs"
          source={npcs}
          searchText={searchText}
        />

        <BasicSection
          title="Misc"
          source={misc}
          searchText={searchText}
        />
      </Window.Content>
    </Window>
  );
};
