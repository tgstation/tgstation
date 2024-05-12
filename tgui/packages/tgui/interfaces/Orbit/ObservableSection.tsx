import { capitalizeFirst } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Collapsible, Icon, Stack } from '../../components';
import { JOB2ICON } from '../common/JobToIcon';
import {
  getDisplayColor,
  getDisplayName,
  isJobOrNameMatch,
  sortByRealName,
} from './helpers';
import { ObservableTooltip } from './ObservableTooltip';
import { Observable, OrbitData } from './types';

type Props = {
  autoObserve: boolean;
  color?: string;
  heatMap: boolean;
  searchQuery: string;
  section: Observable[];
  title: string;
};

/**
 * Displays a collapsible with a map of observable items.
 * Filters the results if there is a provided search query.
 */
export function ObservableSection(props: Props) {
  const {
    autoObserve,
    color,
    heatMap,
    searchQuery,
    section = [],
    title,
  } = props;

  const { act } = useBackend<OrbitData>();

  const filteredSection = section
    .filter((observable) => isJobOrNameMatch(observable, searchQuery))
    .sort(sortByRealName);

  if (!filteredSection.length) {
    return null;
  }

  return (
    <Stack.Item>
      <Collapsible
        bold
        color={color ?? 'grey'}
        open={!!color}
        title={title + ` - (${filteredSection.length})`}
      >
        {filteredSection.map((item) => {
          const { extra, full_name, health, job, name, orbiters, ref } = item;

          return (
            <Button
              color={getDisplayColor(item, heatMap, color)}
              key={ref}
              icon={(job && JOB2ICON[job]) || null}
              onClick={() =>
                act('orbit', { auto_observe: autoObserve, ref: ref })
              }
              tooltip={
                (!!health || !!extra) && <ObservableTooltip item={item} />
              }
              tooltipPosition="bottom-start"
            >
              {capitalizeFirst(getDisplayName(full_name, name))}
              {!!orbiters && (
                <>
                  {' '}
                  <Icon mr={0} name={'ghost'} />
                  {orbiters}
                </>
              )}
            </Button>
          );
        })}
      </Collapsible>
    </Stack.Item>
  );
}
