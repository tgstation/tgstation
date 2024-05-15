import { toTitleCase } from 'common/string';

import { useBackend } from '../../backend';
import { NoticeBox, Section, Stack, Table, Tooltip } from '../../components';
import { ANTAG2COLOR } from './constants';
import { getAntagCategories } from './helpers';
import { OrbitCollapsible } from './OrbitCollapsible';
import { AntagGroup, Observable, OrbitData, ViewMode } from './types';

type Props = {
  autoObserve: boolean;
  searchQuery: string;
  viewMode: ViewMode;
};

type ContentSection = {
  content: Observable[];
  title: string;
  color?: string;
};

/**
 * The primary content display for points of interest.
 * Renders a scrollable section replete collapsibles for each
 * observable group.
 */
export function OrbitContent(props: Props) {
  const { autoObserve, searchQuery, viewMode } = props;

  const { act, data } = useBackend<OrbitData>();
  const { antagonists = [], critical = [] } = data;

  let antagGroups: AntagGroup[] = [];
  if (antagonists.length) {
    antagGroups = getAntagCategories(antagonists);
  }

  const sections: readonly ContentSection[] = [
    {
      color: 'purple',
      content: data.deadchat_controlled,
      title: 'Deadchat Controlled',
    },
    {
      color: 'blue',
      content: data.alive,
      title: 'Alive',
    },
    {
      content: data.dead,
      title: 'Dead',
    },
    {
      content: data.ghosts,
      title: 'Ghosts',
    },
    {
      content: data.misc,
      title: 'Misc',
    },
    {
      content: data.npcs,
      title: 'NPCs',
    },
  ];

  return (
    <Section fill>
      <Stack vertical>
        {critical.map((crit) => (
          <Tooltip content="Click to orbit" key={crit.ref}>
            <NoticeBox
              verticalAlign
              color="purple"
              onClick={() => act('orbit', { ref: crit.ref })}
            >
              <Table>
                <Table.Row>
                  <Table.Cell>{toTitleCase(crit.full_name)}</Table.Cell>
                  <Table.Cell collapsing>{crit.extra}</Table.Cell>
                </Table.Row>
              </Table>
            </NoticeBox>
          </Tooltip>
        ))}

        {antagGroups.map(([title, members]) => (
          <OrbitCollapsible
            autoObserve={autoObserve}
            color={ANTAG2COLOR[title] || 'bad'}
            key={title}
            searchQuery={searchQuery}
            section={members}
            title={title}
            viewMode={viewMode}
          />
        ))}

        {sections.map((section) => (
          <OrbitCollapsible
            autoObserve={autoObserve}
            color={section.color}
            key={section.title}
            searchQuery={searchQuery}
            section={section.content}
            title={section.title}
            viewMode={viewMode}
          />
        ))}
      </Stack>
    </Section>
  );
}
