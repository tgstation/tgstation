import { Job } from "../base";
import { Medical } from "../departments";

const ChiefMedicalOfficer: Job = {
  name: "Chief Medical Officer",
  description: "Coordinate doctors and other medbay employees, ensure they \
    know how to save lives, check for injuries on the crew monitor.",
  department: Medical,
};

export default ChiefMedicalOfficer;
