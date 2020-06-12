import { Button, Input, Section } from '../components';
import { Window } from '../layouts';
import { useBackend, useLocalState } from '../backend';

const PATTERN_DESCRIPTOR = / \[(?:ghost|dead)\]$/;
const PATTERN_NUMBER = / \(([0-9]+)\)$/;

const searchFor = bySearch => thing => {
  return thing.name.toLowerCase().startsWith(bySearch.toLowerCase());
};

const sortByName = (a, b) => {
  const [aName, bName] = [a.name, b.name];

  // Check if aName and bName are the same except for a number at the end
  // e.g. Medibot (2) and Medibot (3)
  const [aNumberMatch, bNumberMatch] = [
    aName.match(PATTERN_NUMBER),
    bName.match(PATTERN_NUMBER),
  ];

  if (aNumberMatch
    && bNumberMatch
    && aName.replace(PATTERN_NUMBER, "") === bName.replace(PATTERN_NUMBER, "")
  ) {
    const [aNumber, bNumber] = [
      parseInt(aNumberMatch[1], 10),
      parseInt(bNumberMatch[1], 10),
    ];

    return aNumber - bNumber;
  }

  return aName.localeCompare(bName);
};

const BasicSection = props => {
  const { orbit, search, source, title } = props;

  return source.length > 0 && (
    <Section title={title}>
      { source.filter(searchFor(search)).sort(sortByName).map(thing => (<Button
        key={thing.name}
        content={thing.name.replace(PATTERN_DESCRIPTOR, "")}
        onClick={() => orbit(thing.name)}
      />)) }
    </Section>
  );
};

const OrbitedButton = props => {
  const { color, orbit, thing } = props;

  return (<Button
    color={color}
    content={(
      <span>
        {thing.name}{" "}
        {
          thing.orbiters
            ? (
              <span>
                ({thing.orbiters}{" "}
                <img
                  src="ghost.png"
                  style={{
                    opacity: "0.7",
                  }}
                />)
              </span>
            )
            : undefined
        }
      </span>
    )}
    onClick={() => orbit(thing.name)}
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

  const [search, setSearch] = useLocalState(context, "search", "");

  const collatedAntagonists = {};
  for (const antagonist of antagonists) {
    if (collatedAntagonists[antagonist.antag] === undefined) {
      collatedAntagonists[antagonist.antag] = [];
    }

    collatedAntagonists[antagonist.antag].push(antagonist);
  }

  const orbit = name => act("orbit", { name });

  return (
    <Window>
      <Window.Content>
        <Section title={
          <Input
            fluid
            value={search}
            onInput={(_, value) => setSearch(value)}
          />
        } />

        { antagonists.length > 0 && (
          <Section title="Ghost-Visible Antagonists">
            { Object.entries(collatedAntagonists).sort((a, b) => {
              return a.localeCompare(b);
            }).map(([name, antags]) => {
              return (
                <Section key={name} title={name} level={2}>
                  {
                    antags
                      .filter(searchFor(search))
                      .sort(sortByName)
                      .map(antag => (
                        <OrbitedButton
                          key={antag.name}
                          color="bad"
                          thing={antag}
                          orbit={orbit}
                        />
                      ))
                  }
                </Section>
              );
            }) }
          </Section>
        ) }

        <Section title="Alive">
          { alive.filter(searchFor(search)).sort(sortByName).map(thing => (
            <OrbitedButton
              key={thing.name}
              color="good"
              thing={thing}
              orbit={orbit}
            />)) }
        </Section>

        <BasicSection
          title="Dead"
          source={dead}
          orbit={orbit}
          search={search}
        />

        <BasicSection
          title="NPCs"
          source={npcs}
          orbit={orbit}
          search={search}
        />

        <BasicSection
          title="Misc"
          source={misc}
          orbit={orbit}
          search={search}
        />

        <BasicSection
          title="Ghosts"
          source={ghosts}
          orbit={orbit}
          search={search}
        />
      </Window.Content>
    </Window>
  );
};
