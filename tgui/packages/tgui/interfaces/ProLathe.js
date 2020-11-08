import { classes } from 'common/react';
import { uniqBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { formatSiUnit, formatMoney } from '../format';
import { Flex, Section, Tabs, Box, Button, Fragment, ProgressBar, NumberInput, Icon, Input } from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';
import { createLogger } from "../logging";

const logger = createLogger("Prolathe");

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
  let materialObj = {};

  materials.forEach(m => {
    materialObj[m.name] = m.amount; });

  return materialObj;
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
  let format = { "textColor": COLOR_NONE };

  Object.keys(part.cost).forEach(mat => {
    format[mat] = partBuildColor(part.cost[mat], tally[mat], materials[mat]);

    if (format[mat].color > format["textColor"]) {
      format["textColor"] = format[mat].color;
    }
  });

  return format;
};

const queueCondFormat = (materials, queue) => {
  let materialTally = {};
  let matFormat = {};
  let missingMatTally = {};
  let textColors = {};

  queue.forEach((part, i) => {
    textColors[i] = COLOR_NONE;
    Object.keys(part.cost).forEach(mat => {
      materialTally[mat] = materialTally[mat] || 0;
      missingMatTally[mat] = missingMatTally[mat] || 0;

      matFormat[mat] = partBuildColor(
        part.cost[mat], materialTally[mat], materials[mat]
      );

      if (matFormat[mat].color !== COLOR_NONE) {
        if (textColors[i] < matFormat[mat].color) {
          textColors[i] = matFormat[mat].color;
        }
      }
      else {
        materialTally[mat] += part.cost[mat];
      }

      missingMatTally[mat] += matFormat[mat].deficit;
    });
  });
  return { materialTally, missingMatTally, textColors, matFormat };
};

const searchFilter = (search, allparts) => {
  let searchResults = [];

  if (!search.length) {
    return;
  }

  const resultFilter = createSearch(search, part => (
    (part.name || "")
    + (part.desc || "")
    + (part.searchMeta || "")
  ));

  Object.keys(allparts).forEach(category => {
    allparts[category]
      .filter(resultFilter)
      .forEach(e => { searchResults.push(e); });
  });

  searchResults = uniqBy(part => part.name)(searchResults);

  return searchResults;
};



export const ProLathe = (props, context) => {
  const { act, data } = useBackend(context);

  const queue = data.queue || [];
  const materialAsObj = materialArrayToObj(data.materials || []);
  const department_tag = data.departmentTag || "BAD DEPARTMENT TAG"
  const regents = data.regents || [];


  const {
    materialTally,
    missingMatTally,
    textColors,
  } = queueCondFormat(materialAsObj, queue);

  const [
    displayMatCost,
    setDisplayMatCost,
  ] = useSharedState(context, "display_mats", false);

  const [
    selectedSettings,
    setSelectedSettings
  ] = useSharedState(context, "settings_tab", "Materials");

  return (
    <Window
      resizable
      title={department_tag}
      width={1100}
      height={640}>
      <Window.Content
        scrollable>
        <Flex
          fillPositionedParent
          direction="column">
          <Flex >
          <Flex.Item height="125px"
              mt={1}
              ml={1}>
                <Section height="100%">
              <Tabs
                    vertical>
                      <Tabs.Tab
                        selected={selectedSettings === "Materials"}
                        onClick={() => setSelectedSettings("Materials")}>
                        Materials Storage
                      </Tabs.Tab>
                      {(!!(data.regents) && (
                      <Tabs.Tab
                        selected={selectedSettings === "Regents"}
                        disabled={!(data.regents)}
                        onClick={() => setSelectedSettings("Regents")}>
                        Regent Storage
                      </Tabs.Tab>
                      ))}
                      <Tabs.Tab
                        selected={selectedSettings === "Settings"}
                        onClick={() => setSelectedSettings("Settings")}>
                        Settings
                      </Tabs.Tab>
                  </Tabs>
                  </Section>
            </Flex.Item>
            <Flex.Item
              ml={1}
              mr={1}
              mt={1}
              basis="content"
              grow={1}>
              <Section
                title={selectedSettings}>
                {selectedSettings == "Materials" ? (<Materials />) :
                selectedSettings == "Regents" ?
                  regents.map(regent => (regent.name + " | " + formatSiUnit(amount, 0) +"u"))
                 : (
                <Button.Checkbox
                    onClick={() => setDisplayMatCost(!displayMatCost)}
                    checked={displayMatCost}>
                  Display Material Costs
                </Button.Checkbox>
               )}
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
                    queueMaterials={materialTally}
                    materials={materialAsObj} />
                </Box>
              </Flex.Item>
              <Flex.Item
                width="420px"
                position="relative">
                <Queue
                  queueMaterials={materialTally}
                  missingMaterials={missingMatTally}
                  textColors={textColors} />
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
        onDrag={(e, val) => {
          const newVal = parseInt(val, 10);
          if (Number.isInteger(newVal)) {
            setRemoveMaterials(newVal);
          }
        }} />
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

  const category_order = data.categoryOrder || [];
  const buildableParts = data.buildableParts || {};

  const [
    selectedPartTab,
    setSelectedPartTab,
  ] = useSharedState(
    context,
    "part_tab",
    category_order[0] || ""
  );

  return (
    <Tabs
      vertical>
      {category_order.map(set => (
        !!(buildableParts[set]) && (
          <Tabs.Tab
            key={set}
            selected={set === selectedPartTab}
            onClick={() => setSelectedPartTab(set)}>
            {set}
          </Tabs.Tab>
        )
      ))}
    </Tabs>
  );
};

const PartLists = (props, context) => {
  const { data } = useBackend(context);


  const category_order = data.categoryOrder || [];
  const buildableParts = data.buildableParts || [];

  const {
    queueMaterials,
    materials,
  } = props;

  const [
    selectedPartTab,
    setSelectedPartTab,
  ] = useSharedState(
    context,
    "part_tab",
    category_order[0] || ""
  );

  const [
    searchText,
    setSearchText,
  ] = useSharedState(context, "search_text", "");

  let partsList;
  // Build list of sub-categories if not using a search filter.
  if (!searchText) {
    partsList = buildableParts;
    buildableParts[selectedPartTab].forEach(part => {
      part["format"] = partCondFormat(materials, queueMaterials, part);
    });
  }
  else {
    partsList = [];
    searchFilter(searchText, buildableParts).forEach(part => {
      part["format"] = partCondFormat(materials, queueMaterials, part);
      partsList.push(part);
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
          parts={partsList}
          forceShow
          placeholder="No matching results..." />
      )) || (
          <PartCategory
            name={selectedPartTab}
            parts={partsList[selectedPartTab]} />
        )
      }
    </Fragment>
  );
};

const PartItem = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    part,
  } = props;

  const {
    buildingPart,
  } = data;

  const [
    displayMatCost,
  ] = useSharedState(context, "display_mats", false);

  return (
    <Fragment>
    <Flex
      align="center">
      <Flex.Item>
        <Button
          disabled={buildingPart
          || (part.format.textColor === COLOR_BAD)}
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
          textColor={COLOR_KEYS[part.format.textColor]}>
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
          + part.printTime + "s. "
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


  );
};

const PartSubCategory = (props, context) => {
  const {
    parts,
    name,
  } = props;

  return (
      <Section
        title={name}
        buttons={name == "Parts" && (
          <Button
            disabled={!parts.length}
            color="good"
            content="Queue All"
            icon="plus-circle"
            onClick={() => act("add_queue_set", {
              part_list: parts.map(part => part.id),
            })} />)
        }>
        {parts.map(part => (<PartItem part={part} key={part.name}/>)) }
      </Section>
  );
}

const PartCategory = (props, context) => {
  const { data } = useBackend(context);

  const {
    parts,
    name,
    forceShow,
    placeholder,
  } = props;
 //  catagories

 logger.log("Error:", "Cat: " + name + " ugh: " + data.categories[name]+ " errr " + parts[0].name);
  const sub_category_fixed_order = [];//data.categories[name] || [];

  let all_sub_category = {};
  const insert_into_subcategory = (sub_category_name, part) => {
    if (typeof all_sub_category[sub_category_name] != "array")
      all_sub_category[sub_category_name] = []
    all_sub_category[sub_category_name].push(part)
  };

  const non_categorized_parts = parts.filter(part => {
    const sub_category = part.subCategory
    if(typeof(sub_category) == "array" && sub_category.length > 0) {
      if(!sub_category[sub_category_name])
        sub_category[sub_category_name] = []
      sub_category.forEach(sub_category_name => insert_into_subcategory(sub_category_name,part));
      return false;
    }
    else if(typeof(sub_category) == "string" && sub_category.length > 0) {
      insert_into_subcategory(sub_category_name,part)
      return false;
    } else
        return true; // no sub category
  })
  const unsorted_categorized_parts = Object.keys(all_sub_category).filter(
    sub_category_name => !sub_category_fixed_order.find(sub_category_name)).sort();

  /* The order of printing the sub catagories is as follows.
    1. All non categorized parts are printed FIRST
    2. If we have a hard set category list, then that is printed next
    3. Other sub_catagories are printed after that
  */
  return (
    ((!!parts.length || forceShow) && (
      <Section title={name}>
        {(!parts.length) && (placeholder)}
        {non_categorized_parts.map(part => (<PartItem part={part} key={part.name}/>)) }
        {sub_category_fixed_order.map(sub_category_name =>
             (<PartSubCategory name={sub_category_name} parts={sub_parts}/>)
        )}
        {unsorted_categorized_parts.map(sub_category_name =>
             (<PartSubCategory name={sub_category_name} parts={sub_parts}/>)
        )}
      </Section>
    ))
  );
};

const Queue = (props, context) => {
  const { act, data } = useBackend(context);

  const { isProcessingQueue } = data;

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
              {(!!isProcessingQueue && (
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
    buildingPart,
    storedPart,
  } = data;

  if (storedPart) {
    const {
      name,
    } = storedPart;

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

  if (buildingPart) {
    const {
      name,
      duration,
      printTime,
    } = buildingPart;

    const timeLeft = Math.ceil(duration/10);

    return (
      <Box>
        <ProgressBar
          minValue={0}
          maxValue={printTime}
          value={duration}>
          <Flex>
            <Flex.Item>
              {name}
            </Flex.Item>
            <Flex.Item
              grow={1} />
            <Flex.Item>
              {((timeLeft >= 0) && (timeLeft + "s")) || ("Dispensing...")}
            </Flex.Item>
          </Flex>
        </ProgressBar>
      </Box>
    );
  }
};
