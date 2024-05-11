import { useBackend } from '../../backend';
import { Stack } from '../../components';
import { ANTAG2COLOR } from './constants';
import { getAntagCategories } from './helpers';
import { ObservableSection } from './ObservableSection';
import { AntagGroup, Observable, OrbitData } from './types';

type Props = {
  autoObserve: boolean;
  heatMap: boolean;
  searchQuery: string;
};

type Section = {
  content: Observable[];
  title: string;
  color?: string;
};

/**
 * The primary content display for points of interest.
 * Renders a scrollable section replete with subsections for each
 * observable group.
 */
export function ObservableContent(props: Props) {
  const { autoObserve, heatMap, searchQuery } = props;

  const { data } = useBackend<OrbitData>();
  const {
    alive = [],
    antagonists = [],
    deadchat_controlled = [],
    dead = [],
    ghosts = [],
    misc = [],
    npcs = [],
  } = data;

  let collatedAntagonists: AntagGroup[] = [];

  if (antagonists.length) {
    collatedAntagonists = getAntagCategories(antagonists);
  }

  const sections: readonly Section[] = [
    {
      color: 'purple',
      content: deadchat_controlled,
      title: 'Deadchat Controlled',
    },
    {
      color: 'blue',
      content: alive,
      title: 'Alive',
    },
    {
      content: dead,
      title: 'Dead',
    },
    {
      content: ghosts,
      title: 'Ghosts',
    },
    {
      content: misc,
      title: 'Misc',
    },
    {
      content: npcs,
      title: 'NPCs',
    },
  ];

  return (
    <Stack vertical>
      {collatedAntagonists?.map(([title, antagonists]) => {
        return (
          <Stack.Item key={title}>
            <ObservableSection
              autoObserve={autoObserve}
              color={ANTAG2COLOR[title] || 'bad'}
              heatMap={heatMap}
              searchQuery={searchQuery}
              section={antagonists}
              title={title}
            />
          </Stack.Item>
        );
      })}
      {sections.map((section) => {
        return (
          <Stack.Item key={section.title}>
            <ObservableSection
              autoObserve={autoObserve}
              color={section.color}
              heatMap={heatMap}
              searchQuery={searchQuery}
              section={section.content}
              title={section.title}
            />
          </Stack.Item>
        );
      })}
    </Stack>
  );
}
