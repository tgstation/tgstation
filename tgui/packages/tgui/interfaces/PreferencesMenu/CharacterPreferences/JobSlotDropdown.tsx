import { useBackend } from 'tgui/backend';
import { Dropdown, Tooltip } from 'tgui-core/components';

import type { PreferencesMenuData } from '../types';

const SLOT_ICONS = {
  '-1': 'fa-random',
  0: 'user',
  1: 'fa-1',
  2: 'fa-2',
  3: 'fa-3',
  4: 'fa-4',
  5: 'fa-5',
  6: 'fa-6',
  7: 'fa-7',
  8: 'fa-8',
  9: 'fa-9',
};

type JobSlotDropdownProps = {
  name: string;
};

export const JobSlotDropdown = (props: JobSlotDropdownProps) => {
  const { data, act } = useBackend<PreferencesMenuData>();
  const { name } = props;

  const prefJobSlots = data.pref_job_slots ?? {};
  const profileIndex = data.profile_index ?? {};

  const currentSlotNumber = prefJobSlots[name] ?? 0;
  const currentSlotName = profileIndex[currentSlotNumber] ?? '';

  const slotOptions = Object.entries(profileIndex).map(([key, slotName]) => ({
    value: key,
    displayText: String(slotName) as React.ReactNode,
  }));

  return (
    <Tooltip content={currentSlotName} position="top-end">
      <div>
        <Dropdown
          noChevron
          iconOnly
          icon={SLOT_ICONS[currentSlotNumber]}
          width="auto"
          menuWidth="auto"
          selected={currentSlotName}
          options={slotOptions}
          onSelected={(value: number) => {
            act('set_job_slot', {
              job: name,
              slot: Number(value),
            });
          }}
        />
      </div>
    </Tooltip>
  );
};
