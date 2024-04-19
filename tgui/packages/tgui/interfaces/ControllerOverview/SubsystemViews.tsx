import { filter } from 'common/collections';
import { createSearch } from 'common/string';
import { useMemo, useState } from 'react';

import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { FilterState } from './filters';
import { sortSubsystemBy } from './helpers';
import { SubsystemBar } from './SubsystemBar';
import { SubsystemCollapsible } from './SubsystemCollapsible';
import { ControllerData, SubsystemData, SubsystemSortBy } from './types';

type Props = {
  filterOpts: FilterState;
};

export function SubsystemViews(props: Props) {
  const { data } = useBackend<ControllerData>();
  const { subsystems } = data;
  const { filterOpts } = props;

  const [bars, setBars] = useState(false);

  // Filter and sort subsystems
  const toDisplay = useMemo(() => {
    let subsystemsToSort = subsystems;

    if (filterOpts.name) {
      subsystemsToSort = filter(
        subsystems,
        createSearch(
          filterOpts.name,
          (subsystem: SubsystemData) => subsystem.name,
        ),
      );
    }

    return sortSubsystemBy(
      subsystemsToSort,
      filterOpts.sortType,
      filterOpts.ascending,
    );
  }, [filterOpts.ascending, filterOpts.name, filterOpts.sortType, subsystems]);

  const totals: number[] = [];
  let currentMax = 0;
  if (filterOpts.sortType === SubsystemSortBy.COST) {
    for (let i = 0; i < toDisplay.length; i++) {
      totals.push(toDisplay[i].cost_ms);
    }

    currentMax = Math.max(...totals);
  }

  return (
    <Section
      fill
      title="Subsystem Overview"
      buttons={
        <Button icon="bars" onClick={() => setBars(!bars)}>
          Bars
        </Button>
      }
    >
      {toDisplay.map((subsystem) => {
        if (bars) {
          return (
            <SubsystemBar
              filterInactive={filterOpts.inactive}
              filterSmall={filterOpts.smallValues}
              key={subsystem.ref}
              max={currentMax}
              subsystem={subsystem}
              value={subsystem.cost_ms}
            />
          );
        }
        return (
          <SubsystemCollapsible key={subsystem.ref} subsystem={subsystem} />
        );
      })}
    </Section>
  );
}
