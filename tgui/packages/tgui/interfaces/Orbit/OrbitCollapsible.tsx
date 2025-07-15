import { useContext } from 'react';
import { Collapsible, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { OrbitContext } from '.';
import { VIEWMODE } from './constants';
import {
  isJobCkeyOrNameMatch,
  sortByDepartment,
  sortByDisplayName,
} from './helpers';
import { OrbitItem } from './OrbitItem';
import type { Observable } from './types';

type Props = {
  color?: string;
  section: Observable[];
  title: string;
};

/**
 * Displays a collapsible with a map of observable items.
 * Filters the results if there is a provided search query.
 */
export function OrbitCollapsible(props: Props) {
  const { act } = useBackend();

  const { color, section = [], title } = props;

  const { autoObserve, realNameDisplay, searchQuery, viewMode } =
    useContext(OrbitContext);

  const filteredSection = section.filter((observable) =>
    isJobCkeyOrNameMatch(observable, searchQuery),
  );

  if (viewMode === VIEWMODE.Department) {
    filteredSection.sort(sortByDepartment);
  } else {
    filteredSection.sort(sortByDisplayName);
  }

  if (filteredSection.length === 0) {
    return;
  }

  return (
    <Collapsible
      bold
      color={color || 'grey'}
      open={!!color}
      title={`${title} - (${filteredSection.length})`}
    >
      <Stack wrap g={0.5}>
        {filteredSection.map((item) => (
          <Stack.Item
            key={item.ref}
            onClick={() =>
              act('orbit', { auto_observe: autoObserve, ref: item.ref })
            }
          >
            <OrbitItem
              realNameDisplay={realNameDisplay}
              color={color}
              item={item}
              viewMode={viewMode}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Collapsible>
  );
}
