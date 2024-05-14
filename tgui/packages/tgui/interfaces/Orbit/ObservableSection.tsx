import { capitalizeFirst } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Collapsible, Flex, Icon, Stack } from '../../components';
import { VIEWMODE } from './constants';
import {
  getDisplayColor,
  getDisplayName,
  isJobOrNameMatch,
  sortByDepartment,
  sortByDisplayName,
} from './helpers';
import { JobIcon } from './JobIcon';
import { ObservableTooltip } from './ObservableTooltip';
import { Observable, OrbitData, ViewMode } from './types';

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
export function ObservableSection(props: Props) {
  const {
    autoObserve,
    color,
    searchQuery,
    section = [],
    title,
    viewMode,
  } = props;

  const { act } = useBackend<OrbitData>();

  const filteredSection = section.filter((observable) =>
    isJobOrNameMatch(observable, searchQuery),
  );

  if (viewMode === VIEWMODE.Department) {
    filteredSection.sort(sortByDepartment);
  } else {
    filteredSection.sort(sortByDisplayName);
  }

  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color || 'grey'}
        open={!!color}
        title={title + ` - (${filteredSection.length})`}
      >
        <Flex wrap>
          {filteredSection.map((item) => {
            const { extra, full_name, health, icon, job, name, orbiters, ref } =
              item;

            return (
              <Flex.Item
                align="center"
                key={full_name + ref}
                mb={0.5}
                mr={0.5}
                onClick={() => act('orbit', { auto_observe: autoObserve, ref })}
                style={{
                  display: 'flex',
                }}
              >
                {!!job && <JobIcon icon={icon} job={job} />}

                <Button
                  color={getDisplayColor(item, viewMode, color)}
                  pl={job && 0.5}
                  tooltip={
                    (!!health || !!extra) && <ObservableTooltip item={item} />
                  }
                  tooltipPosition="bottom-start"
                >
                  <Stack>
                    <Stack.Item>
                      {capitalizeFirst(getDisplayName(full_name, name))}
                    </Stack.Item>

                    {!!orbiters && (
                      <Stack.Item>
                        <Icon name="ghost" />
                        {orbiters}
                      </Stack.Item>
                    )}
                  </Stack>
                </Button>
              </Flex.Item>
            );
          })}
        </Flex>
      </Collapsible>
    </Stack.Item>
  );
}
