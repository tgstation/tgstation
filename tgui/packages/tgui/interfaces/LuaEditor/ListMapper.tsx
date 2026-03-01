import React, {
  type ComponentProps,
  type Dispatch,
  type SetStateAction,
} from 'react';
import {
  Box,
  Button,
  Collapsible,
  LabeledList,
  Section,
  Tooltip,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { logger } from '../../logging';
import type { CallInfo, LuaEditorModal, Variant, VariantList } from './types';
import type { ListElement, ListPath } from './types';

const mapListVariantsInner = (value: any, variant: Variant) => {
  if (Array.isArray(variant)) {
    const [variant_inner, param] = variant;
    switch (variant_inner) {
      case 'list':
        return mapListVariants(value, param);
      case 'cycle':
        return (
          <Box key="cycle" bold textColor="green">
            Circular Reference
          </Box>
        );
      case 'ref':
        return (
          <Box key="ref" bold backgroundColor="blue">
            {`${value} ${param}`}
          </Box>
        );
    }
  } else {
    switch (variant) {
      case 'error':
        return (
          <Tooltip key="error" content={value}>
            <Box bold textColor="red">
              Conversion Error
            </Box>
          </Tooltip>
        );
      case 'function':
        return (
          <Box key="function" bold backgroundColor="green">
            {value}
          </Box>
        );
      case 'thread':
        return (
          <Box key="thread" bold backgroundColor="yellow">
            Thread: {value}
          </Box>
        );
      case 'userdata':
        return (
          <Box key="userdata" bold backgroundColor="grey">
            Userdata: {value}
          </Box>
        );
      case 'error_as_value':
        return (
          <Box key="error_as_value" bold textColor="red">
            {value}
          </Box>
        );
      default:
        return value;
    }
  }
};

const mapListVariants = (list: any[], variants: VariantList) => {
  logger.log(list, variants);
  return list.map((element, i) => {
    const { key, value } = element;
    const { key: key_variant = null, value: value_variant = null } =
      variants[i] || {};
    if (typeof key === 'number') {
      return {
        key: key,
        value: mapListVariantsInner(value, key_variant),
      };
    } else {
      return {
        key: mapListVariantsInner(key, key_variant),
        value: mapListVariantsInner(value, value_variant),
      };
    }
  });
};

type ListMapperProps = ComponentProps<typeof Box> & {
  list: ListElement[];
} & Partial<{
    variants: VariantList;
    editable: BooleanLike;
    name: string;
    vvAct: (path: ListPath) => void;
    skipNulls: BooleanLike;
    collapsible: BooleanLike;
    callType: 'callFunction' | 'resumeTask';
    path: ListPath;
    setToCall: Dispatch<SetStateAction<CallInfo>>;
    setModal: Dispatch<SetStateAction<LuaEditorModal>>;
  }>;

export const ListMapper = (props: ListMapperProps) => {
  const { act } = useBackend();

  const { variants, list: _, ...safeProps } = props;

  const {
    path,
    editable,
    name,
    vvAct,
    skipNulls,
    collapsible,
    setToCall,
    setModal,
    ...rest
  } = safeProps;

  let { list } = props;

  if (variants) {
    list = mapListVariants(list, variants);
  }

  const ThingNode = (
    thing: any,
    path: ListPath,
    canCall: BooleanLike,
    overrideProps?: ListMapperProps,
  ) => {
    if (Array.isArray(thing)) {
      return (
        <ListMapper
          {...safeProps}
          list={thing}
          name={`List[${thing.length}]`}
          path={path}
          collapsible
          {...rest}
          {...overrideProps}
        />
      );
    } else if (React.isValidElement<any>(thing)) {
      switch (thing.key) {
        case 'ref':
          return (
            <Button
              tooltip="Click to VV"
              onClick={vvAct && (() => vvAct(path))}
              {...thing.props}
            />
          );
        case 'function':
          if (canCall && setToCall && setModal) {
            return (
              <Button
                tooltip="Click to call"
                onClick={() => {
                  setToCall({
                    type: 'callFunction',
                    params: {
                      indices: path.map((v) => v.index),
                    },
                  });
                  setModal('call');
                }}
                {...thing.props}
              />
            );
          } else if (thing === null) {
            return <b>nil</b>;
          } else {
            return thing;
          }
        default:
          return thing;
      }
    } else {
      return <Box {...rest}>{thing}</Box>;
    }
  };

  const ListMapperInner = (element: ListElement, i: number) => {
    const { key, value } = element;
    const basePath: ListPath = path ? path : [];
    const keyPath: ListPath = [...basePath, { index: i + 1, type: 'key' }];
    const valuePath: ListPath = [...basePath, { index: i + 1, type: 'value' }];
    const entryPath: ListPath = [...basePath, { index: i + 1, type: 'entry' }];

    if (key === null && skipNulls) {
      return;
    }

    /*
     * Finding a function only accessible as a table's key is too awkward to
     * deal with for now
     */
    const keyNode = ThingNode(key, keyPath, false);

    /*
     * Likewise, since table, thread, and userdata equality is tested by
     * reference rather than value, we can't find functions whose keys
     * within the table are tables, threads, or userdata
     */
    const uniquelyIndexable =
      typeof key === 'string' ||
      typeof key === 'number' ||
      (React.isValidElement(key) && key.key === 'ref');
    const valueNode = ThingNode(
      value,
      typeof key === 'number' ? keyPath : valuePath,
      uniquelyIndexable,
    );
    return (
      <>
        {i > 0 && (key === null || key === undefined) && (
          <LabeledList.Divider />
        )}
        <LabeledList.Item
          label={keyNode}
          buttons={
            editable && (
              <>
                <Button
                  icon="arrow-up"
                  disabled={i === 0}
                  tooltip="Move Up"
                  onClick={() => act('moveArgUp', { path: entryPath })}
                />
                <Button
                  icon="arrow-down"
                  disabled={i === list.length - 1}
                  tooltip="Move Down"
                  onClick={() => act('moveArgDown', { path: entryPath })}
                />
                <Button
                  icon="window-close"
                  color="red"
                  tooltip="Remove"
                  onClick={() => act('removeArg', { path: entryPath })}
                />
              </>
            )
          }
        >
          {valueNode}
        </LabeledList.Item>
      </>
    );
  };

  const inner = (
    <>
      {list?.map(ListMapperInner)}
      {editable && (
        <Button
          icon="plus"
          tooltip="Add"
          onClick={() => act('addArg', { path: path })}
        />
      )}
    </>
  );

  const buttons = vvAct && list?.length > 0 && (
    <Button icon="search" tooltip="VV List" onClick={() => vvAct(path ?? [])} />
  );

  return collapsible ? (
    <Collapsible title={name} buttons={buttons}>
      {inner}
    </Collapsible>
  ) : (
    <Section title={name} buttons={buttons}>
      {inner}
    </Section>
  );
};
