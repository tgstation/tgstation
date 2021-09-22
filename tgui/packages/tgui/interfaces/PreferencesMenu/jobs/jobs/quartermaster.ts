import { Job } from "../base";
import { Cargo } from "../departments";

const Quartermaster: Job = {
  name: "Quartermaster",
  description: "Coordinate cargo technicians and shaft miners, assist with \
    economical purchasing.",
  department: Cargo,
};

export default Quartermaster;
