import { Job } from "../base";
import { Security } from "../departments";

const Warden: Job = {
  name: "Warden",
  description: "Watch over the Brig and Prison Wing, release prisoners when \
    their time is up, issue equipment to security, be a security officer when \
    they all eventually die.",
  department: Security,
};

export default Warden;
