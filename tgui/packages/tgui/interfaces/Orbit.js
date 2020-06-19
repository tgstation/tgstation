import { createSearch } from 'common/string';
import { Box, Button, Input, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

const PATTERN_DESCRIPTOR = / \[(?:ghost|dead)\]$/;
const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = searchText => createSearch(searchText, thing => thing.name);

const compareString = (a, b) => a < b ? -1 : a > b;

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

  return compareString(aName, bName);
};

const BasicSection = (props, context) => {
  const { act } = useBackend(context);
  const { searchText, source, title } = props;
  const things = source.filter(searchFor(searchText));
  things.sort(compareNumberedText);
  return source.length > 0 && (
    <Section title={title}>
      {things.map(thing => (
        <Button
          key={thing.name}
          content={thing.name.replace(PATTERN_DESCRIPTOR, "")}
          onClick={() => act("orbit", {
            name: thing.name,
          })} />
      ))}
    </Section>
  );
};

const OrbitedButton = (props, context) => {
  const { act } = useBackend(context);
  const { color, thing } = props;

  return (
    <Button
      color={color}
      onClick={() => act("orbit", {
        name: thing.name,
      })}>
      {thing.name}
      {thing.orbiters && (
        <Box inline ml={1}>
          {"("}{thing.orbiters}{" "}
          <Box
            as="img"
            src="ghost.png"
            opacity={0.7} />
          {")"}
        </Box>
      )}
    </Button>
  );
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
    return compareString(a[0], b[0]);
  });

  const orbitMostRelevant = searchText => {
    for (const source of [
      sortedAntagonists.map(([_, antags]) => antags),
      alive, ghosts, dead, npcs, misc,
    ]) {
      const member = source
        .filter(searchFor(searchText))
        .sort(compareNumberedText)[0];
      if (member !== undefined) {
        act("orbit", { name: member.name });
        break;
      }
    }
  };

  return (
    <Window>
      <Window.Content scrollable>
        <Section>
          <Input
            fluid
            value={searchText}
            onInput={(_, value) => setSearchText(value)}
            onEnter={(_, value) => orbitMostRelevant(value)} />
        </Section>

        {antagonists.length > 0 && (
          <Section title="Ghost-Visible Antagonists">
            {sortedAntagonists.map(([name, antags]) => (
              <Section key={name} title={name} level={2}>
                {antags
                  .filter(searchFor(searchText))
                  .sort(compareNumberedText)
                  .map(antag => (
                    <OrbitedButton
                      key={antag.name}
                      color="bad"
                      thing={antag}
                    />
                  ))}
              </Section>
            ))}
          </Section>
        )}

        <Section title="Alive">
          {alive
            .filter(searchFor(searchText))
            .sort(compareNumberedText)
            .map(thing => (
              <OrbitedButton
                key={thing.name}
                color="good"
                thing={thing} />
            ))}
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
