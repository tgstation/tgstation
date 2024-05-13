import { capitalizeFirst } from 'common/string';

import { useBackend } from '../../backend';
import { Button, Collapsible, DmIcon, Icon, Stack } from '../../components';
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
          const { extra, full_name, health, icon, job, name, orbiters, ref } =
            item;

          return (
            <Button
              color={getDisplayColor(item, heatMap, color)}
              key={ref}
              onClick={() =>
                act('orbit', { auto_observe: autoObserve, ref: ref })
              }
              tooltip={
                (!!health || !!extra) && <ObservableTooltip item={item} />
              }
              tooltipPosition="bottom-start"
            >
              <Stack>
                {!!job && <JobIcon icon={icon} job={job} />}

                <Stack.Item ml={0.5}>
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
          );
        })}
      </Collapsible>
    </Stack.Item>
  );
}

function JobIcon(props) {
  const { icon, job } = props;

  if (icon) {
    return (
      <Stack.Item style={{ height: '18px', width: '18px' }}>
        <DmIcon
          icon="icons/mob/huds/hud.dmi"
          icon_state={icon}
          style={{ transform: 'scale(2)  translateX(8px) translateY(1px)' }}
        />
      </Stack.Item>
    );
  }

  const toDisplay = JOB2ICON[job];
  if (!toDisplay) return null;

  return <Icon name={toDisplay} />;
}
