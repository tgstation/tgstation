import { Color } from 'common/color';
import { SFC } from 'inferno';
import { Box } from './Box';
import { Button } from './Button';
import { Icon } from './Icon';
import { Stack } from './Stack';

// The cost of prettiness.
export const DepartmentEntry = (props) => {
  return (
    <Box ClassName="Section" style={props.style}>
      <Box class="Section__title" style={props.titleStyle} minHeight="3.4rem">
        <Box class="Section__titleText" style={props.textStyle}>
          {props.title}
          {props.titleContents}
        </Box>
        {props.titleSubtext}
        <br style={{ 'clear': 'both' }} />
      </Box>
      <Box class="Section__rest">
        <Box class="Section__content">{props.children}</Box>
      </Box>
    </Box>
  );
};

// Specifically not typed for flexibility.
export const JobEntry: SFC<{ job; department; act: Function }> = (data) => {
  const job = data.job;
  const department = data.department;
  return (
    <Stack.Item fill>
      <Button
        width="100%"
        style={{
          // Try not to think too hard about this one.
          'background-color': job.unavailable_reason
            ? 'lightgrey'
            : job.prioritized
              ? '#308d25'
              : Color.fromHex(department.color)
                .darken(10)
                .toString(),
          'color': job.unavailable_reason
            ? 'dimgrey'
            : Color.fromHex(department.color)
              .darken(90)
              .toString(),
          'font-size': '1.1rem',
          'cursor': job.unavailable_reason ? 'initial' : 'pointer',
        }}
        tooltip={
          job.unavailable_reason ? (
            job.unavailable_reason
          ) : job.prioritized ? (
            <div>
              <b>The HoP wants more people in this job!</b>
              <br /> <br />
              {job.description}
            </div>
          ) : (
            job.description
          )
        }
        onClick={() => {
          !job.unavailable_reason && data.act('SelectedJob', { job: job.name });
        }}
        content={
          <div>
            {job.icon && <Icon name={job.icon} />}
            {job.command ? <b>{job.name}</b> : job.name}
            <span style={{ 'float': 'right' }}>
              {job.used_slots} / {job.open_slots}
            </span>
          </div>
        }
      />
    </Stack.Item>
  );
};

export const DepartmentPane: SFC<{
  act;
  departments: object[];
  jobEntryBuilder: (job: object, department: object) => object;
  titleSubtextBuilder: (department: object) => object;
  entryWidth: string;
}> = (data) => {
  return (
    <Box wrap="wrap" style={{ 'columns': '20em' }}>
      {data.departments.map((department) => {
        return (
          <Box key={department['name']} minWidth={data.entryWidth}>
            <DepartmentEntry
              title={department['name']}
              style={{
                'background-color': department['color'],
                'margin-bottom': '1em',
                'break-inside': 'avoid-column',
              }}
              titleStyle={{
                'border-bottom-color': Color.fromHex(department['color'])
                  .darken(50)
                  .toString(),
              }}
              textStyle={{
                'color': Color.fromHex(department['color'])
                  .darken(80)
                  .toString(),
              }}
              titleSubtext={data.titleSubtextBuilder(department)}>
              <Stack vertical>
                {department['jobs'].map((job) =>
                  data.jobEntryBuilder(job, department)
                )}
              </Stack>
            </DepartmentEntry>
          </Box>
        );
      })}
    </Box>
  );
};
