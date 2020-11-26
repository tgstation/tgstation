import { useBackend } from "../backend";
import { Box, Button, Collapsible, Input, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { map } from 'common/collections';

const filterEntryMap = {
  x: <FilterIntegerEntry />,
  y: <FilterIntegerEntry />,
  icon: FilterIconEntry,
  render_source: <FilterTextEntry />,
  flags: <FilterFlagsEntry />,
  size: FilterFloatEntry,
  color: FilterTextEntry,
  offset: FilterFloatEntry,
  radius: FilterFloatEntry,
  falloff: FilterFloatEntry,
}

const FilterIntegerEntry = (props, context) => {
  const { value } = props;
  return (
    <NumberInput
      value={value}
      minValue={-500}
      maxValue={500}
      stepPixelSize={5}
    />
  );
};

const FilterFloatEntry = (props, context) => {
};

const FilterTextEntry = (props, context) => {
  const { value } = props;

  return (
    <Input value={value} />
  );
};

const FilterIconEntry = (props, context) => {
};

const FilterFlagsEntry = (props, context) => {
  return props.value;
};

const FilterEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, filterDataEntry } = props;
  const { type, priority, ...restOfProps } = filterDataEntry;


  return (
    <Collapsible
      title={name + " (" + type + ")"}
      buttons={(
        <Button
          icon="minus"
          color="bad"
          onClick={() => act("remove_filter", {name: name})}
        />
      )}
    >
      <Section level={2}>
        <LabeledList>
          {map((entryValue, entryName) => {
            const FilterEntryEditor = filterEntryMap[entryName] || <Box>"INVALID"</Box>;
            return (
            <LabeledList.Item label={entryName}>
              <FilterEntryEditor name={entryName} value={entryValue}/>
            </LabeledList.Item>
          );})(restOfProps)}
        </LabeledList>
      </Section>
    </Collapsible>
  );
};

export const Filteriffic = (props, context) => {
  const { act, data } = useBackend(context);
  const name = data.target_name || "Unknown Object"
  const filters = data.target_filter_data || {};
  const hasFilters = filters !== {};
  return (
    <Window
      width={500}
      height={500}
      resizable>
      <Window.Content scrollable>
        <Section
          title={name}
          buttons={(
            <Button
              icon="plus"
              content="Add Filter"
            />
          )}
        >
          {!hasFilters ? (
            <Box>
              No filters
            </Box>
          ) : (
            map((entry, key) => (
              <FilterEntry filterDataEntry={entry} name={key} key={key}/>
            ))(filters)
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
