class SavingThread extends Thread
{
  int z;
  Map mymap;
  boolean done;
  int progress;
  StringBuilder result;

  public SavingThread(int paramInt1, Map paramMap, int paramInt2)
  {
    this.z = paramInt1;
    this.mymap = paramMap;
    this.progress = 0;
    this.done = false;
    this.result = new StringBuilder(paramInt2);
  }

  public void run()
  {
    this.result.append("(" + this.mymap.minx + "," + this.mymap.miny + "," + this.z + ") = {\"\r\n");

    int i = (this.mymap.maxx - this.mymap.minx) * (this.mymap.maxy - this.mymap.miny) / 100;
    int j = 0;
    for (int k = this.mymap.miny; k <= this.mymap.maxy; k++)
    {
      for (int m = this.mymap.minx; m <= this.mymap.maxx; m++)
      {
        this.result.append(this.mymap.getIdFor(this.mymap.contentAt(m, k, this.z)));
        j++; if (j >= i) { j = 0; this.progress += 1; }
      }
      this.result.append("\r\n");
    }
    this.result.append("\"}\r\n");
    this.result.append("\r\n");
    this.done = true;
  }
}
