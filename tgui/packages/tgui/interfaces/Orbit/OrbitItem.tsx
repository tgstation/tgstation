import { Button, Icon, Stack, Tooltip } from 'tgui-core/components';
import { capitalizeFirst } from 'tgui-core/string';

import { useBackend } from '../../backend';
import { getDisplayColor, getDisplayName } from './helpers';
import { JobIcon } from './JobIcon';
import { OrbitTooltip } from './OrbitTooltip';
import { Antagonist, Observable, OrbitData, ViewMode } from './types';

type Props = {
  item: Observable | Antagonist;
  realNameDisplay: boolean;
  viewMode: ViewMode;
  color: string | undefined;
};

/** Each button on the observable section */
export function OrbitItem(props: Props) {
  const { item, realNameDisplay, viewMode, color } = props;
  const { full_name, icon, job, name, orbiters, ref } = item;

  const { data } = useBackend<OrbitData>();
  const { orbiting } = data;

  const selected = ref === orbiting?.ref;
  const validIcon = !!job && !!icon && icon !== 'hudunknown';

  const hasTooltip = item.health || item.extra;

  return (
    <Tooltip
      content={
        hasTooltip ? (
          <OrbitTooltip item={item} realNameDisplay={realNameDisplay} />
        ) : null
      }
    >
      <Stack g={0}>
        {validIcon && <JobIcon item={item} realNameDisplay={realNameDisplay} />}

        <Button
          color={getDisplayColor(item, viewMode, color)}
          pl={validIcon && 0.5}
        >
          <Stack>
            <Stack.Item>
              {realNameDisplay
                ? capitalizeFirst(name || full_name)
                : capitalizeFirst(getDisplayName(full_name, name))}
            </Stack.Item>
            {!!orbiters && (
              <Stack.Item>
                <Icon name="ghost" />
                {orbiters}
              </Stack.Item>
            )}
          </Stack>
          {selected && <div className="OrbitItem__selected" />}
        </Button>
      </Stack>
    </Tooltip>
  );
}
