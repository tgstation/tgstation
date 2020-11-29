import { useBackend } from "../backend";
import { Fragment } from 'inferno';
import { Box, Button, Collapsible, Dropdown, Input, LabeledList, NoticeBox, NumberInput, Section } from '../components';
import { Window } from '../layouts';
import { map } from 'common/collections';
import { toFixed } from 'common/math';

const FilterIntegerEntry = (props, context) => {
  const { value, name, filterName } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-500}
      maxValue={500}
      stepPixelSize={5}
      width="39px"
      onDrag={(e, value) => act('modify_filter_value', {
        name: filterName,
        new_data: {
          [name]: value,
        },
      })} />
  );
};

const FilterFloatEntry = (props, context) => {
  const { value, name, filterName } = props;
  const { act } = useBackend(context);
  return (
    <NumberInput
      value={value}
      minValue={-500}
      maxValue={500}
      stepPixelSize={4}
      step={0.01}
      format={value => toFixed(value, 2)}
      width="39px"
      onDrag={(e, value) => act('modify_filter_value', {
        name: filterName,
        new_data: {
          [name]: value,
        },
        })} />
  );
};

const FilterTextEntry = (props, context) => {
  const { value, name, filterName } = props;
  const { act } = useBackend(context);

  return (
    <Input
      value={value}
      width="250px"
      onInput={(e, value) => act('modify_filter_value', {
        name: filterName,
        new_data: {
          [name]: value,
        },
      })}
    />
  );
};

const FilterIconEntry = (props, context) => {
  const { value } = props;
  const { act } = useBackend(context);
  return (
    <Fragment>
      <Button
        icon="pencil-alt"
        onClick={() => act('modify_icon_value', {})}
      />
      <Box inline ml={1}>
        {value}
      </Box>
    </Fragment>
  );
};

const FilterFlagsEntry = (props, context) => {
  const { name, value, filterName, filterType } = props;
  const { act, data } = useBackend(context);

  const filterInfo = data.filter_info;
  const flags = filterInfo[filterType]['flags'];
  return (
    map((bitField, flagName) => (
      <Button.Checkbox
        checked={value & bitField}
        content={flagName}
        onClick={() => act('modify_filter_value', {
          name: filterName,
          new_data: {
            [name]: value ^ bitField,
          },
        })}
      />
    ))(flags)
  );
};

const FilterDataEntry = (props, context) => {
  const { name, value, hasValue, filterName } = props;

  const filterEntryTypes = {
    int: <FilterIntegerEntry {...props} />,
    float: <FilterFloatEntry {...props} />,
    string: <FilterTextEntry {...props} />,
    color: <FilterTextEntry {...props} />,
    icon: <FilterIconEntry {...props} />,
    flags: <FilterFlagsEntry {...props} />,
  };

  const filterEntryMap = {
    x: 'int',
    y: 'int',
    icon: 'icon',
    render_source: 'string',
    flags: 'flags',
    size: 'int',
    color: 'color',
    offset: 'float',
    radius: 'float',
    falloff: 'float',
    density: 'int',
    threshold: 'float',
    factor: 'float',
    repeat: 'int'
  };

  return (
    <LabeledList.Item label={name}>
      {filterEntryTypes[filterEntryMap[name]] || "Not Found (This is an error)"}
      {' '}
      {!hasValue && <Box inline color="average">(Default)</Box>}
    </LabeledList.Item>
  );
};

const FilterEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, filterDataEntry } = props;
  const { type, priority, ...restOfProps } = filterDataEntry;

  const filterDefaults = data["filter_info"];

  const targetFilterPossibleKeys = Object.keys(filterDefaults[type]['defaults']);

  return (
    <Collapsible
      title={name + " (" + type + ")"}
      buttons={(
        <Fragment>
          <Button
            icon="chevron-up"
            onClick={() => act('increase_priority', { name: name })}
          />
          <Box inline mr={1}>
            {priority}
          </Box>
          <Button
            icon="chevron-down"
            onClick={() => act('decrease_priority', { name: name })}
          />
          <Button.Input
            content="Rename"
            placeholder={name}
            onCommit={(e, new_name) => act('rename_filter', {
              name: name,
              new_name: new_name,
            })}
            width="90px"
          />
          <Button.Confirm
            icon="minus"
            onClick={() => act("remove_filter", { name: name })}
          />
        </Fragment>
      )}>
      <Section level={2}>
        <LabeledList>
          {targetFilterPossibleKeys.map(entryName => {
            const defaults = filterDefaults[type]['defaults'];
            const value = restOfProps[entryName] || defaults[entryName];
            const hasValue = value !== defaults[entryName];
            return (
              <FilterDataEntry
                key={entryName}
                filterName={name}
                filterType={type}
                name={entryName}
                value={value}
                hasValue={hasValue}
              />
            );
          })}
        </LabeledList>
      </Section>
    </Collapsible>
  );
};

export const Filteriffic = (props, context) => {
  const { act, data } = useBackend(context);
  const name = data.target_name || "Unknown Object";
  const filters = data.target_filter_data || {};
  const hasFilters = filters !== {};
  const filterDefaults = data["filter_info"];
  return (
    <Window
      width={500}
      height={500}
      resizable>
      <Window.Content scrollable>
        <NoticeBox danger>
          DO NOT MESS WITH EXISTING FILTERS IF YOU DO NOT KNOW THE CONSEQUENCES. YOU HAVE BEEN WARNED.
        </NoticeBox>
        <Section
          title={name}
          buttons={(
            <Dropdown
              icon="plus"
              selected="Add Filter"
              nochevron
              doNotUpdate
              options={Object.keys(filterDefaults)}
              onSelected={value => act('add_filter', {
                name: 'default',
                priority: 10,
                type: value,
              })}
            />
          )}>
          {!hasFilters ? (
            <Box>
              No filters
            </Box>
          ) : (
            map((entry, key) => (
              <FilterEntry filterDataEntry={entry} name={key} key={key} />
            ))(filters)
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
