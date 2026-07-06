import {
  Box,
  Button,
  Collapsible,
  ImageButton,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Experiment } from '../../ExperimentConfigure';
import { MaterialCostSequence } from '../../Fabrication/MaterialCostSequence';
import { useRemappedBackend } from '../helpers';
import { useTechWebRoute } from '../hooks';
import { LockedExperiment } from '../LockedExperiment';
import type { TechwebNode } from '../types';

type Props = {
  node: TechwebNode;
} & Partial<{
  nocontrols: BooleanLike;
  nodetails: BooleanLike;
}>;

export function TechNode(props: Props) {
  const { act, data } = useRemappedBackend();
  const {
    node_cache,
    design_cache,
    SHEET_MATERIAL_AMOUNT,
    build_types,
    department_flags,
    experiments,
    points = [],
    nodes,
    point_types_abbreviations = [],
    queue_nodes = [],
  } = data;
  const { node, nodetails, nocontrols } = props;
  const {
    id,
    can_unlock,
    have_experiments_done,
    tier,
    enqueued_by_user,
    is_free,
    discount_boosted,
  } = node;
  const {
    name,
    description,
    costs,
    design_ids,
    prereq_ids,
    required_experiments,
    discount_experiments,
    discount_boosts,
  } = node_cache[id];
  const [techwebRoute, setTechwebRoute] = useTechWebRoute();

  const expcompl = required_experiments.filter(
    (x) => experiments[x]?.completed,
  ).length;
  const experimentProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={expcompl / required_experiments.length}
    >
      Experiments ({expcompl}/{required_experiments.length})
    </ProgressBar>
  );

  const techcompl = prereq_ids.filter(
    (x) => nodes.find((y) => y.id === x)?.tier === 0,
  ).length;
  const techProgress = (
    <ProgressBar
      ranges={{
        good: [0.5, Infinity],
        average: [0.25, 0.5],
        bad: [-Infinity, 0.25],
      }}
      value={techcompl / prereq_ids.length}
    >
      Tech ({techcompl}/{prereq_ids.length})
    </ProgressBar>
  );

  // Notice that this logic will have to be changed if we make the discounts
  // pool-specific
  const nodeDiscountExperiments = Object.keys(discount_experiments)
    .filter((x) => experiments[x]?.completed)
    .reduce((tot, curr) => {
      return tot + discount_experiments[curr];
    }, 0);

  // Will need to be changed (along with some backend/DM code) if boosts should
  // ever vary by point type. As is, this simply adds up all discount boosts.
  const nodeDiscountBoosts = discount_boosted
    ? Object.keys(discount_boosts).reduce((tot, curr) => {
        return tot + discount_boosts[curr];
      }, 0)
    : 0;

  return (
    <Section
      className="Techweb__NodeContainer"
      title={name}
      buttons={
        !nocontrols && (
          <>
            {tier > 0 &&
              (!!can_unlock && (is_free || queue_nodes.length === 0) ? (
                <Button
                  icon="lightbulb"
                  disabled={!can_unlock || tier > 1 || queue_nodes.length > 0}
                  onClick={() => act('researchNode', { node_id: id })}
                >
                  Research
                </Button>
              ) : enqueued_by_user ? (
                <Button
                  icon="trash"
                  color="bad"
                  onClick={() => act('dequeueNode', { node_id: id })}
                >
                  Dequeue
                </Button>
              ) : id in queue_nodes && !enqueued_by_user ? (
                <Button icon="check" color="good">
                  Queued
                </Button>
              ) : (
                <Button
                  icon="lightbulb"
                  disabled={
                    !have_experiments_done ||
                    id in queue_nodes ||
                    techcompl < prereq_ids.length
                  }
                  onClick={() => act('enqueueNode', { node_id: id })}
                >
                  Enqueue
                </Button>
              ))}
            {!nodetails && (
              <Button
                icon="tasks"
                onClick={() => {
                  setTechwebRoute({ route: 'details', selectedNode: id });
                }}
              >
                Details
              </Button>
            )}
          </>
        )
      }
    >
      {tier !== 0 && (
        <Stack className="Techweb__NodeProgress">
          {costs.map((k) => {
            const reqPts = Math.max(
              0,
              k.value - nodeDiscountExperiments - nodeDiscountBoosts,
            );
            const nodeProg = Math.min(reqPts, points[k.type]) || 0;
            return (
              <Stack.Item key={k.type} grow basis={0}>
                <ProgressBar
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.25, 0.5],
                    bad: [-Infinity, 0.25],
                  }}
                  value={
                    reqPts === 0
                      ? 1
                      : Math.min(1, (points[k.type] || 0) / reqPts)
                  }
                >
                  {point_types_abbreviations[k.type]} ({nodeProg}/{reqPts})
                </ProgressBar>
              </Stack.Item>
            );
          })}
          {prereq_ids.length > 0 && (
            <Stack.Item grow basis={0}>
              {techProgress}
            </Stack.Item>
          )}
          {required_experiments.length > 0 && (
            <Stack.Item grow basis={0}>
              {experimentProgress}
            </Stack.Item>
          )}
        </Stack>
      )}
      <Box className="Techweb__NodeDescription" mb={2}>
        {description}
      </Box>
      <Box className="Techweb__NodeUnlockedDesigns" mb={2}>
        {design_ids.map((k, i) => (
          <ImageButton
            key={k}
            className={`$Techweb__DesignIcon`}
            imageSize={32}
            asset={['', design_cache[k].class]}
            tooltip={
              <Stack vertical>
                <Stack.Item mt={0.3} ml={0.3}>
                  {design_cache[k].name}
                </Stack.Item>
                <Stack.Item mt={-2} mb={-2} ml={-3}>
                  <ul>
                    <li>
                      {Object.keys(build_types)
                        .filter((key) => design_cache[k].build_types & +key)
                        .map((key) => build_types[key])
                        .join(', ')}
                    </li>
                    {!!Object.keys(department_flags).find(
                      (key) => !(+key & design_cache[k].department_flags),
                    ) && (
                      <li>
                        {Object.keys(department_flags)
                          .filter(
                            (key) => design_cache[k].department_flags & +key,
                          )
                          .map((key) => department_flags[key])
                          .join(', ')}
                      </li>
                    )}
                  </ul>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item mt={-1}>
                  <MaterialCostSequence
                    design={design_cache[k]}
                    amount={1}
                    SHEET_MATERIAL_AMOUNT={SHEET_MATERIAL_AMOUNT}
                  />
                </Stack.Item>
              </Stack>
            }
            tooltipPosition={i % 15 < 7 ? 'right' : 'left'}
          />
        ))}
      </Box>
      {required_experiments.length > 0 && (
        <Collapsible
          className="Techweb__NodeExperimentsRequired"
          title="Required Experiments"
        >
          {required_experiments.map((k, index) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment key={index} />;
            }
            return <Experiment key={thisExp.name} exp={thisExp} />;
          })}
        </Collapsible>
      )}
      {Object.keys(discount_experiments).length > 0 && (
        <Collapsible
          className="TechwebNodeExperimentsRequired"
          title="Discount-Eligible Experiments"
        >
          {Object.keys(discount_experiments).map((k, index) => {
            const thisExp = experiments[k];
            if (thisExp === null || thisExp === undefined) {
              return <LockedExperiment key={index} />;
            }
            return (
              <Experiment key={thisExp.name} exp={thisExp}>
                <Box className="Techweb__ExperimentDiscount">
                  Provides a discount of {discount_experiments[k]} points to all
                  required point pools.
                </Box>
              </Experiment>
            );
          })}
        </Collapsible>
      )}
    </Section>
  );
}
