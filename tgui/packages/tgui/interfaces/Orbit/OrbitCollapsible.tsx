import { useContext } from 'react';

import { Collapsible, Flex, Tooltip } from '../../components';
import { OrbitContext } from '.';
import { VIEWMODE } from './constants';
import {
  isJobOrNameMatch,
  sortByDepartment,
  sortByDisplayName,
} from './helpers';
import { OrbitItem } from './OrbitItem';
import { OrbitTooltip } from './OrbitTooltip';
import { Observable } from './types';

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
  const { color, section = [], title } = props;

  const { autoObserve, realNameDisplay, searchQuery, viewMode } =
    useContext(OrbitContext);

  const filteredSection = section.filter((observable) =>
    isJobOrNameMatch(observable, searchQuery),
  );

  if (viewMode === VIEWMODE.Department) {
    filteredSection.sort(sortByDepartment);
  } else {
    filteredSection.sort(sortByDisplayName);
  }

  if (!filteredSection.length) {
    return;
  }

  return (
    <Collapsible
      bold
      color={color || 'grey'}
      open={!!color}
      title={title + ` - (${filteredSection.length})`}
    >
      <Flex wrap>
        {filteredSection.map((item) => {
          const content = (
            <OrbitItem
              autoObserve={autoObserve}
              realNameDisplay={realNameDisplay}
              color={color}
              item={item}
              key={item.ref}
              viewMode={viewMode}
            />
          );

          if (!item.health && !item.extra) {
            return content;
          }

          return (
            <Tooltip
              content={<OrbitTooltip item={item} realNameDisplay={false} />}
              key={item.ref}
              position="bottom-start"
            >
              {content}
            </Tooltip>
          );
        })}
      </Flex>
    </Collapsible>
  );
}
