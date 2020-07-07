import { classes } from 'common/react';
import { uniqBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { formatSiUnit, formatMoney } from '../format';
import { Flex, Section, Tabs, Box, Button, Fragment, ProgressBar, NumberInput, Icon, Input } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

const MATERIAL_KEYS = {
  "iron": "sheet-metal_3",
  "glass": "sheet-glass_3",
  "silver": "sheet-silver_3",
  "gold": "sheet-gold_3",
  "diamond": "sheet-diamond",
  "plasma": "sheet-plasma_3",
  "uranium": "sheet-uranium",
  "bananium": "sheet-bananium",
  "titanium": "sheet-titanium_3",
  "bluespace crystal": "polycrystal",
  "plastic": "sheet-plastic_3",
};

const COLOR_NONE = 0;
const COLOR_AVERAGE = 1;
const COLOR_BAD = 2;

const COLOR_KEYS = {
  [COLOR_NONE]: false,
  [COLOR_AVERAGE]: "average",
  [COLOR_BAD]: "bad",
};

const materialArrayToObj = materials => {
  let material_obj = {};

  materials.forEach(m => {
    material_obj[m.name] = m.amount; });

  return material_obj;
};

const partBuildColor = (cost, tally, material) => {
  if (cost > material) {
    return { color: COLOR_BAD, deficit: (cost - material) };
  }

  if (tally > material) {
    return { color: COLOR_AVERAGE, deficit: cost };
  }

  if (cost + tally > material) {
    return { color: COLOR_AVERAGE, deficit: ((cost + tally) - material) };
  }

  return { color: COLOR_NONE, deficit: 0 };
};

const partCondFormat = (materials, tally, part) => {
  let format = { "text_color": COLOR_NONE };

  Object.keys(part.cost).forEach(mat => {
    format[mat] = partBuildColor(part.cost[mat], tally[mat], materials[mat]);

    if (format[mat].color > format["text_color"]) {
      format["text_color"] = format[mat].color;
    }
  });

  return format;
};

const queueCondFormat = (materials, queue) => {
  let material_tally = {};
  let mat_format = {};
  let missing_mat_tally = {};
  let text_colors = {};

  queue.forEach((part, i) => {
    text_colors[i] = COLOR_NONE;
    Object.keys(part.cost).forEach(mat => {
      material_tally[mat] = material_tally[mat] || 0;
      missing_mat_tally[mat] = missing_mat_tally[mat] || 0;

      mat_format[mat] = partBuildColor(
        part.cost[mat], material_tally[mat], materials[mat]
      );

      if (mat_format[mat].color !== COLOR_NONE) {
        if (text_colors[i] < mat_format[mat].color) {
          text_colors[i] = mat_format[mat].color;
        }
      }
      else {
        material_tally[mat] += part.cost[mat];
      }

      missing_mat_tally[mat] += mat_format[mat].deficit;
    });
  });
  return { material_tally, missing_mat_tally, text_colors, mat_format };
};

const searchFilter = (search, allparts) => {
  let searchResults = [];

  if (!search.length) {
    return;
  }

  const resultFilter = createSearch(search, part => (
    (part.name || "")
    + (part.desc || "")
    + (part.search_meta || "")
  ));

  Object.keys(allparts).forEach(category => {
    allparts[category]
      .filter(resultFilter)
      .forEach(e => { searchResults.push(e); });
  });

  searchResults = uniqBy(part => part.name)(searchResults);

  return searchResults;
};

export const ExosuitFabricator = (props, context) => {
  const { act, data } = useBackend(context);

  const queue = data.queue || [];
  const material_obj = materialArrayToObj(data.materials || []);

  const {
    material_tally,
    missing_mat_tally,
    text_colors,
  } = queueCondFormat(material_obj, queue);

  const [
    displayMatCost,
    setDisplayMatCost,
  ] = useSharedState(context, "display_mats", false);

  return (
    <Window resizable>
      <Window.Content scrollable>
        <Flex
          fillPositionedParent
          direction="column">
          <Flex>
            <Flex.Item
              ml={1}
              mr={1}
              mt={1}
              basis="content"
              grow={1}>
              <Section
                title="Materials">
                <Materials />
              </Section>
            </Flex.Item>
            <Flex.Item
              mt={1}
              mr={1}>
              <Section
                title="Settings"
                height="100%">
                <Button.Checkbox
                  onClick={() => setDisplayMatCost(!displayMatCost)}
                  checked={displayMatCost}>
                  Display Material Costs
                </Button.Checkbox>
              </Section>
            </Flex.Item>
          </Flex>
          <Flex.Item
            grow={1}
            m={1}>
            <Flex
              spacing={1}
              height="100%"
              overflowY="hide">
              <Flex.Item position="relative" basis="content">
                <Section
                  height="100%"
                  overflowY="auto"
                  title="Categories"
                  buttons={(
                    <Button
                      content="R&D Sync"
                      onClick={() => act("sync_rnd")} />
                  )}>
                  <PartSets />
                </Section>
              </Flex.Item>
              <Flex.Item
                position="relative"
                grow={1}>
                <Box
                  fillPositionedParent
                  overflowY="auto">
                  <PartLists
                    queueMaterials={material_tally}
                    materials={material_obj} />
                </Box>
              </Flex.Item>
              <Flex.Item
                width="420px"
                position="relative">
                <Queue
                  queueMaterials={material_tally}
                  missingMaterials={missing_mat_tally}
                  textColors={text_colors} />
              </Flex.Item>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

const EjectMaterial = (props, context) => {
  const { act } = useBackend(context);

  const { material } = props;

  const {
    name,
    removable,
    sheets,
    ref,
  } = material;

  const [
    removeMaterials,
    setRemoveMaterials,
  ] = useSharedState(context, "remove_mats_" + name, 1);

  if ((removeMaterials > 1) && (sheets < removeMaterials)) {
    setRemoveMaterials(sheets || 1);
  }

  return (
    <Fragment>
      <NumberInput
        width="30px"
        animated
        value={removeMaterials}
        minValue={1}
        maxValue={sheets || 1}
        initial={1}
        onDrag={(e, val) => setRemoveMaterials(val)} />
      <Button
        icon="eject"
        disabled={!removable}
        onClick={() => act("remove_mat", {
          ref: ref,
          amount: removeMaterials,
        })} />
    </Fragment>
  );
};

const Materials = (props, context) => {
  const { data } = useBackend(context);

  const materials = data.materials || [];

  return (
    <Flex
      wrap="wrap">
      {materials.map(material => (
        <Flex.Item
          width="80px"
          key={material.name}>
          <MaterialAmount
            name={material.name}
            amount={material.amount}
            formatsi />
          <Box
            mt={1}
            style={{ "text-align": "center" }}>
            <EjectMaterial
              material={material} />
          </Box>
        </Flex.Item>
      ))}
    </Flex>
  );
};

const MaterialAmount = (props, context) => {
  const {
    name,
    amount,
    formatsi,
    formatmoney,
    color,
    style,
  } = props;

  return (
    <Flex
      direction="column"
      align="center">
      <Flex.Item>
        <Box
          className={classes([
            'sheetmaterials32x32',
            MATERIAL_KEYS[name],
          ])}
          style={style} />
      </Flex.Item>
      <Flex.Item>
        <Box
          textColor={color}
          style={{ "text-align": "center" }}>
          {(formatsi && formatSiUnit(amount, 0))
          || (formatmoney && formatMoney(amount))
          || (amount)}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

const PartSets = (props, context) => {
  const { data } = useBackend(context);

  const part_sets = data.part_sets || [];
  const buildable_parts = data.buildable_parts || {};

  const [
    selectedPartTab,
    setSelectedPartTab,
  ] = useSharedState(context, "part_tab", part_sets.length ? part_sets[0] : "");

  return (
    <Tabs
      vertical>
      {part_sets.map(set => (
        <Tabs.Tab
          key={set}
          selected={set === selectedPartTab}
          disabled={!(buildable_parts[set])}
          onClick={() => setSelectedPartTab(set)}>
          {set}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const PartLists = (props, context) => {
  const { act, data } = useBackend(context);

  const part_sets = data.part_sets || [];
  const buildable_parts = data.buildable_parts || {};

  const {
    queueMaterials,
    materials,
  } = props;

  const [
    selectedPartTab,
  ] = useSharedState(context, "part_tab", part_sets.length ? part_sets[0] : "");

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  let parts_list;

  // Build list of sub-categories if not using a search filter.
  if (!searchText) {
    parts_list = { "Parts": [] };
    buildable_parts[selectedPartTab].forEach(part => {
      part["format"] = partCondFormat(materials, queueMaterials, part);
      if (!part.sub_category) {
        parts_list["Parts"].push(part);
        return;
      }
      if (!(part.sub_category in parts_list)) {
        parts_list[part.sub_category] = [];
      }
      parts_list[part.sub_category].push(part);
    });
  }
  else {
    parts_list = [];
    searchFilter(searchText, buildable_parts).forEach(part => {
      part["format"] = partCondFormat(materials, queueMaterials, part);
      parts_list.push(part);
    });
  }


  return (
    <Fragment>
      <Section>
        <Flex>
          <Flex.Item mr={1}>
            <Icon
              name="search" />
          </Flex.Item>
          <Flex.Item
            grow={1}>
            <Input
              fluid
              placeholder="Search for..."
              onInput={(e, v) => setSearchText(v)} />
          </Flex.Item>
        </Flex>
      </Section>
      {(!!searchText && (
        <PartCategory
          name={"Search Results"}
          parts={parts_list}
          forceShow
          placeholder="No matching results..." />
      )) || (
        Object.keys(parts_list).map(category => (
          <PartCategory
            key={category}
            name={category}
            parts={parts_list[category]} />
        ))
      )}
    </Fragment>
  );
};

const PartCategory = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    building_part,
  } = data;

  const {
    parts,
    name,
    forceShow,
    placeholder,
  } = props;

  const [
    displayMatCost,
  ] = useSharedState(context, "display_mats", false);

  return (
    ((!!parts.length || forceShow) && (
      <Section
        title={name}
        buttons={
          <Button
            disabled={!parts.length}
            color="good"
            content="Queue All"
            icon="plus-circle"
            onClick={() => act("add_queue_set", {
              part_list: parts.map(part => part.id),
            })} />
        }>
        {(!parts.length) && (placeholder)}
        {parts.map(part => (
          <Fragment
            key={part.name}>
            <Flex
              align="center">
              <Flex.Item>
                <Button
                  disabled={building_part
                  || (part.format.text_color === COLOR_BAD)}
                  color="good"
                  height="20px"
                  mr={1}
                  icon="play"
                  onClick={() => act("build_part", { id: part.id })} />
              </Flex.Item>
              <Flex.Item>
                <Button
                  color="average"
                  height="20px"
                  mr={1}
                  icon="plus-circle"
                  onClick={() => act("add_queue_part", { id: part.id })} />
              </Flex.Item>
              <Flex.Item>
                <Box
                  inline
                  textColor={COLOR_KEYS[part.format.text_color]}>
                  {part.name}
                </Box>
              </Flex.Item>
              <Flex.Item
                grow={1} />
              <Flex.Item>
                <Button
                  icon="question-circle"
                  transparent
                  height="20px"
                  tooltip={
                    "Build Time: "
                  + part.print_time + "s. "
                  + (part.desc || "")
                  }
                  tooltipPosition="left" />
              </Flex.Item>
            </Flex>
            {(displayMatCost && (
              <Flex mb={2}>
                {Object.keys(part.cost).map(material => (
                  <Flex.Item
                    width={"50px"}
                    key={material}
                    color={COLOR_KEYS[part.format[material].color]}>
                    <MaterialAmount
                      formatmoney
                      style={{
                        transform: 'scale(0.75) translate(0%, 10%)',
                      }}
                      name={material}
                      amount={part.cost[material]} />
                  </Flex.Item>
                ))}
              </Flex>
            ))}

          </Fragment>
        ))}
      </Section>
    ))
  );
};

const Queue = (props, context) => {
  const { act, data } = useBackend(context);

  const { is_processing_queue } = data;

  const queue = data.queue || [];

  const {
    queueMaterials,
    missingMaterials,
    textColors,
  } = props;

  return (
    <Flex
      height="100%"
      width="100%"
      direction="column">
      <Flex.Item
        height={0}
        grow={1}>
        <Section
          height="100%"
          title="Queue"
          overflowY="auto"
          buttons={
            <Fragment>
              <Button.Confirm
                disabled={!queue.length}
                color="bad"
                icon="minus-circle"
                content="Clear Queue"
                onClick={() => act("clear_queue")} />
              {(!!is_processing_queue && (
                <Button
                  disabled={!queue.length}
                  content="Stop"
                  icon="stop"
                  onClick={() => act("stop_queue")} />
              )) || (
                <Button
                  disabled={!queue.length}
                  content="Build Queue"
                  icon="play"
                  onClick={() => act("build_queue")} />
              )}
            </Fragment>
          }>
          <Flex
            direction="column"
            height="100%">
            <Flex.Item>
              <BeingBuilt />
            </Flex.Item>
            <Flex.Item>
              <QueueList
                textColors={textColors} />
            </Flex.Item>
          </Flex>
        </Section>
      </Flex.Item>
      {!!queue.length && (
        <Flex.Item mt={1}>
          <Section
            title="Material Cost">
            <QueueMaterials
              queueMaterials={queueMaterials}
              missingMaterials={missingMaterials} />
          </Section>
        </Flex.Item>
      )}
    </Flex>
  );
};

const QueueMaterials = (props, context) => {
  const {
    queueMaterials,
    missingMaterials,
  } = props;

  return (
    <Flex wrap="wrap">
      {Object.keys(queueMaterials).map(material => (
        <Flex.Item
          width="12%"
          key={material}>
          <MaterialAmount
            formatmoney
            name={material}
            amount={queueMaterials[material]} />
          {(!!missingMaterials[material] && (
            <Box
              textColor="bad"
              style={{ "text-align": "center" }}>
              {formatMoney(missingMaterials[material])}
            </Box>
          ))}
        </Flex.Item>
      ))}
    </Flex>
  );
};

const QueueList = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    textColors,
  } = props;

  const queue = data.queue || [];

  if (!queue.length) {
    return (
      <Fragment>
        No parts in queue.
      </Fragment>
    );
  }

  return (
    queue.map((part, index) => (
      <Box
        key={part.name}>
        <Flex
          mb={0.5}
          direction="column"
          justify="center"
          wrap="wrap"
          height="20px" inline>
          <Flex.Item
            basis="content">
            <Button
              height="20px"
              mr={1}
              icon="minus-circle"
              color="bad"
              onClick={() => act("del_queue_part", { index: index+1 })} />
          </Flex.Item>
          <Flex.Item>
            <Box
              inline
              textColor={COLOR_KEYS[textColors[index]]}>
              {part.name}
            </Box>
          </Flex.Item>
        </Flex>
      </Box>
    ))
  );
};

const BeingBuilt = (props, context) => {
  const { data } = useBackend(context);

  const {
    building_part,
    stored_part,
  } = data;

  if (stored_part) {
    const {
      name,
    } = stored_part;

    return (
      <Box>
        <ProgressBar
          minValue={0}
          maxValue={1}
          value={1}
          color="average">
          <Flex>
            <Flex.Item>
              {name}
            </Flex.Item>
            <Flex.Item
              grow={1} />
            <Flex.Item>
              {"Fabricator outlet obstructed..."}
            </Flex.Item>
          </Flex>
        </ProgressBar>
      </Box>
    );
  }

  if (building_part) {
    const {
      name,
      duration,
      print_time,
    } = building_part;

    const time_left = Math.ceil(duration/10);

    return (
      <Box>
        <ProgressBar
          minValue={0}
          maxValue={print_time}
          value={duration}>
          <Flex>
            <Flex.Item>
              {name}
            </Flex.Item>
            <Flex.Item
              grow={1} />
            <Flex.Item>
              {((time_left >= 0) && (time_left + "s")) || ("Dispensing...")}
            </Flex.Item>
          </Flex>
        </ProgressBar>
      </Box>
    );
  }
};
