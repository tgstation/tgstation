import { useBackend, useLocalState } from "../../backend";
import { Button, Collapsible, LabeledList, Section } from "../../components";

const RefRegex = RegExp("\\[0x[0-9a-fA-F]+]$");

export const ListMapper = (props, context) => {

  const { act } = useBackend(context);

  const {
    list,
    path,
    editable,
    name,
    callType,
    vvAct,
    skipNulls,
    collapsible,
  } = props;

  const [, setToCall] = useLocalState(context, "toCallTaskInfo");
  const [, setModal] = useLocalState(context, "modal");

  const ThingNode = (thing, path, overrideProps) => {
    if (Array.isArray(thing)) {
      return (
        <ListMapper
          {...props}
          list={thing}
          name={`List[${thing.length}]`}
          path={path}
          collapsible
          {...overrideProps}
        />
      );
    } else if (typeof(thing) === "string") {
      if (thing === "__lua_function" && callType) {
        return (
          <Button
            tooltip="Click to call"
            onClick={() => {
              setToCall({ type: callType, params: {
                indices: path.map((v) => v.index),
              },
              });
              setModal("call");
            }}>
            Function
          </Button>);
      } else if (thing.startsWith("__lua_") && thing.length > 6) {
        return (
          <b>
            {thing.charAt(6).toUpperCase() + thing.substring(7)}
          </b>
        );
      } else if (RefRegex.test(thing)) {
        return (
          <Button
            tooltip="Click to VV Datum"
            onClick={() => vvAct(path)}>
            {thing}
          </Button>
        );
      } else {
        return thing;
      }
    } else {
      return thing;
    }
  };

  const ListMapperInner = (element, i) => {
    const { key, value } = element;
    const basePath = path ? path : [];
    let keyPath = [...basePath, { index: i+1, type: "key" }];
    let valuePath = [...basePath, { index: i+1, type: "value" }];
    let entryPath = [...basePath, { index: i+1, type: "entry" }];

    if (key === null && skipNulls) {
      return;
    }

    /*
     * Finding a function only accessible as a table's key is too awkward to
     * deal with for now
     */
    let keyNode = ThingNode(key, keyPath, { callType: null });

    /*
     * Likewise, since table and userdata equality is tested by reference
     * rather than value, we can't find functions whose keys within the
     * table are tables or userdata
     */
    const uniquelyIndexable = (typeof(key) === "string" && (
      !(key.startsWith("__lua_") || RefRegex.test(key))
    )) || typeof(key) === "number";
    let valueNode = ThingNode(value, valuePath, {
      callType: uniquelyIndexable && callType,
    });
    return (
      <LabeledList.Item
        label={keyNode}
        buttons={editable && (
          <>
            <Button
              icon="circle-arrow-up"
              disabled={i===0}
              tooltip="Move Up"
              onClick={() => act("moveArgUp", { path: entryPath })} />
            <Button
              icon="circle-arrow-down"
              disabled={i===list.length-1}
              tooltip="Move Down"
              onClick={() => act("moveArgDown", { path: entryPath })} />
            <Button
              icon="xmark"
              color="red"
              tooltip="Remove"
              onClick={() => act("removeArg", { path: entryPath })}
            />
          </>
        )} >
        {valueNode}
      </LabeledList.Item>
    );
  };

  const inner = (
    <>
      {list && list.map(ListMapperInner)}
      {editable && <Button
        icon="plus"
        tooltip="Add"
        onClick={() => act("addArg", { path: path })} />}
    </>
  );

  return collapsible ? (
    <Collapsible
      title={name}
      buttons={vvAct && (
        <Button
          icon="magnifying-glass"
          tooltip="VV List"
          onClick={() => vvAct(path)}
        />
      )} >
      {inner}
    </Collapsible>
  ) : (
    <Section
      title={name}
      buttons={vvAct && (
        <Button
          icon="magnifying-glass"
          tooltip="VV List"
          onClick={() => vvAct(path)}
        />
      )} >
      {inner}
    </Section>
  );
};
