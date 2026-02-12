import { Button, LabeledList } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { bitflagInfo, type ReagentsData, type ReagentsProps } from './types';

export function TagBox(props: ReagentsProps) {
  const { act, data } = useBackend<ReagentsData>();
  const { bitflags, selectedBitflags } = data;

  const [page, setPage] = props.pageState;

  // first go through all bitflaginfo to find all unique categories
  const allCategories: string[] = [];
  for (const meta of bitflagInfo) {
    if (!allCategories.includes(meta.category)) {
      allCategories.push(meta.category);
    }
  }

  // then fill each category with its respective bitflags
  const categorizedBitflags: Record<string, typeof bitflagInfo> = {};
  for (const category of allCategories) {
    categorizedBitflags[category] = bitflagInfo.filter(
      (meta) => meta.category === category,
    );
  }

  return (
    <LabeledList>
      {Object.entries(categorizedBitflags).map(([category, metas]) => (
        <LabeledList.Item label={category} key={category}>
          {metas.map((meta) => {
            const flag = bitflags[meta.flag];
            return (
              <Button
                key={meta.flag}
                selected={(selectedBitflags & flag) !== 0}
                icon={meta.icon}
                tooltip={meta.tooltip}
                onClick={() => {
                  act(meta.toggle);
                  setPage(1);
                }}
              >
                {meta.flag}
              </Button>
            );
          })}
        </LabeledList.Item>
      ))}
    </LabeledList>
  );
}
