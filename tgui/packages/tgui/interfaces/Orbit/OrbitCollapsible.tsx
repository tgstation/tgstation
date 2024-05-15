import { Collapsible, Flex, Tooltip } from '../../components';
import { VIEWMODE } from './constants';
import {
  isJobOrNameMatch,
  sortByDepartment,
  sortByDisplayName,
} from './helpers';
import { OrbitItem } from './OrbitItem';
import { OrbitTooltip } from './OrbitTooltip';
import { Observable, ViewMode } from './types';

type Props = {
  autoObserve: boolean;
  color?: string;
  searchQuery: string;
  section: Observable[];
  title: string;
  viewMode: ViewMode;
};

/**
 * Displays a collapsible with a map of observable items.
 * Filters the results if there is a provided search query.
 */
export function OrbitCollapsible(props: Props) {
  const {
    autoObserve,
    color,
    searchQuery,
    section = [],
    title,
    viewMode,
  } = props;

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
              content={<OrbitTooltip item={item} />}
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
