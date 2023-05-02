import { Box, Popper } from '../components';

export const meta = {
  title: 'Popper',
  render: () => <Story />,
};

const Story = () => {
  return (
    <>
      <Popper
        popperContent={
          <Box
            style={{
              background: 'white',
              border: '2px solid blue',
            }}>
            Loogatme!
          </Box>
        }
        options={{
          placement: 'bottom',
        }}>
        <Box
          style={{
            border: '5px solid white',
            height: '300px',
            width: '200px',
          }}
        />
      </Popper>

      <Popper
        popperContent={
          <Box
            style={{
              background: 'white',
              border: '2px solid blue',
            }}>
            I am on the right!
          </Box>
        }
        options={{
          placement: 'right',
        }}>
        <Box
          style={{
            border: '5px solid white',
            height: '500px',
            width: '100px',
          }}
        />
      </Popper>
    </>
  );
};
