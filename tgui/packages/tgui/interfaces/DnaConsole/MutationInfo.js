import { filter, uniqBy } from 'common/collections';
import { flow } from 'common/fp';
import { useBackend } from '../../backend';
import { Box, Button, Divider, Dropdown, LabeledList } from '../../components';
import { CHROMOSOME_NEVER, CHROMOSOME_NONE, CHROMOSOME_USED, MUT_COLORS, MUT_EXTRA } from './constants';

/**
 * The following predicate tests if two mutations are functionally
 * the same on the basis of their metadata. Useful if your intent is
 * to prevent "true" duplicates - i.e. mutations with identical metadata.
 */
const isSameMutation = (a, b) => {
  return a.Alias === b.Alias
    && a.AppliedChromo === b.AppliedChromo;
};

const ChromosomeInfo = (props, context) => {
  const { mutation, disabled } = props;
  const { data, act } = useBackend(context);
  if (mutation.CanChromo === CHROMOSOME_NEVER) {
    return (
      <Box color="label">
        No compatible chromosomes
      </Box>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_NONE) {
    if (disabled) {
      return (
        <Box color="label">
          No chromosome applied.
        </Box>
      );
    }
    return (
      <>
        <Dropdown
          width="240px"
          options={mutation.ValidStoredChromos}
          disabled={mutation.ValidStoredChromos.length === 0}
          selected={mutation.ValidStoredChromos.length === 0
            ? "No Suitable Chromosomes"
            : "Select a chromosome"}
          onSelected={e => act('apply_chromo', {
            chromo: e,
            mutref: mutation.ByondRef,
          })} />
        <Box color="label" mt={1}>
          Compatible with: {mutation.ValidChromos}
        </Box>
      </>
    );
  }
  if (mutation.CanChromo === CHROMOSOME_USED) {
    return (
      <Box color="label">
        Applied chromosome: {mutation.AppliedChromo}
      </Box>
    );
  }
  return null;
};

const MutationCombiner = (props, context) => {
  const {
    mutations = [],
    source,
  } = props;
  const { act, data } = useBackend(context);

  const brefFromName = name => {
    return mutations.find(mutation => mutation.Name === name)?.ByondRef;
  };

  return (
    <Dropdown
      key={source.ByondRef}
      width="240px"
      options={mutations.map(mutation => mutation.Name)}
      disabled={mutations.length === 0}
      selected="Combine mutations"
      onSelected={value => act(`combine_${source.Source}`, {
        firstref: brefFromName(value),
        secondref: source.ByondRef,
      })} />
  );
};

export const MutationInfo = (props, context) => {
  const { mutation } = props;
  const { data, act } = useBackend(context);
  const {
    diskCapacity,
    diskReadOnly,
    hasDisk,
    isInjectorReady,
    isCrisprReady,
    crisprCharges,
  } = data;
  const diskMutations = data.storage.disk ?? [];
  const mutationStorage = data.storage.console ?? [];
  const advInjectors = data.storage.injector ?? [];
  if (!mutation) {
    return (
      <Box color="label">
        Nothing to show.
      </Box>
    );
  }
  if (mutation.Source === 'occupant' && !mutation.Discovered) {
    return (
      <LabeledList>
        <LabeledList.Item label="Name">
          {mutation.Alias}
        </LabeledList.Item>
      </LabeledList>
    );
  }
  const savedToConsole = mutationStorage
    .find(x => isSameMutation(x, mutation));
  const savedToDisk = diskMutations
    .find(x => isSameMutation(x, mutation));
  const combinedMutations = flow([
    uniqBy(mutation => mutation.Name),
    filter(x => x.Name !== mutation.Name),
  ])([
    ...diskMutations,
    ...mutationStorage,
  ]);
  return (
    <>
      <LabeledList>
        <LabeledList.Item label="Name">
          <Box inline color={MUT_COLORS[mutation.Quality]}>{mutation.Name}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {mutation.Description}
        </LabeledList.Item>
        <LabeledList.Item label="Instability">
          {mutation.Instability}
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      <Box>
        {mutation.Source === 'disk' && (
          <MutationCombiner
            disabled={!hasDisk
              || diskCapacity <= 0
              || diskReadOnly}
            mutations={combinedMutations}
            source={mutation} />
        )}
        {mutation.Source === 'console' && (
          <MutationCombiner
            mutations={combinedMutations}
            source={mutation} />
        )}
        {['occupant', 'disk', 'console'].includes(mutation.Source) && (
          <>
            <Dropdown
              width="240px"
              options={advInjectors.map(injector => injector.name)}
              disabled={advInjectors.length === 0 || !mutation.Active}
              selected="Add to advanced injector"
              onSelected={value => act('add_advinj_mut', {
                mutref: mutation.ByondRef,
                advinj: value,
                source: mutation.Source,
              })} />
            <Button
              icon="syringe"
              disabled={!isInjectorReady || !mutation.Active}
              content="Print Activator"
              onClick={() => act('print_injector', {
                mutref: mutation.ByondRef,
                is_activator: 1,
                source: mutation.Source,
              })} />
            <Button
              icon="syringe"
              disabled={!isInjectorReady || !mutation.Active}
              content="Print Mutator"
              onClick={() => act('print_injector', {
                mutref: mutation.ByondRef,
                is_activator: 0,
                source: mutation.Source,
              })} />
            <Button
              icon="syringe"
              disabled={!mutation.Active || !isCrisprReady}
              content={`CRISPR [${crisprCharges}]`}
              onClick={() => act('crispr', {
                mutref: mutation.ByondRef,
                source: mutation.Source,
              })} />
          </>
        )}
      </Box>
      {['disk', 'occupant'].includes(mutation.Source) && (
        <Button
          icon="save"
          disabled={savedToConsole
            || !mutation.Active}
          content="Save to Console"
          onClick={() => act('save_console', {
            mutref: mutation.ByondRef,
            source: mutation.Source,
          })} />
      )}
      {['console', 'occupant'].includes(mutation.Source) && (
        <Button
          icon="save"
          disabled={savedToDisk
            || !hasDisk
            || diskCapacity <= 0
            || diskReadOnly
            || !mutation.Active}
          content="Save to Disk"
          onClick={() => act('save_disk', {
            mutref: mutation.ByondRef,
            source: mutation.Source,
          })} />
      )}
      {['console', 'disk', 'injector'].includes(mutation.Source) && (
        <Button
          icon="times"
          color="red"
          content={`Delete from ${mutation.Source}`}
          onClick={() => act(`delete_${mutation.Source}_mut`, {
            mutref: mutation.ByondRef,
          })} />
      )}
      {(mutation.Class === MUT_EXTRA || !!mutation.Scrambled
        && mutation.Source === 'occupant')
        && (
          <Button
            content="Nullify"
            onClick={() => act('nullify', {
              mutref: mutation.ByondRef,
            })} />
        )}
      <Divider />
      <ChromosomeInfo
        disabled={mutation.Source !== 'occupant'}
        mutation={mutation} />
    </>
  );
};
