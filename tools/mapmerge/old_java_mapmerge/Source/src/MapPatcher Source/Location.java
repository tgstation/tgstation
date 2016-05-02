class Location
{
  int x;
  int y;
  int z;

  public Location()
  {
  }

  public Location(int paramInt1, int paramInt2, int paramInt3)
  {
    this.x = paramInt1;
    this.y = paramInt2;
    this.z = paramInt3;
  }

  public void set(int paramInt1, int paramInt2, int paramInt3)
  {
    this.x = paramInt1;
    this.y = paramInt2;
    this.z = paramInt3;
  }

  public boolean equals(Object paramObject)
  {
    if (!(paramObject instanceof Location)) return false;
    Location localLocation = (Location)paramObject;
    if ((this.x != localLocation.x) || (this.y != localLocation.y) || (this.z != localLocation.z)) return false;
    return true;
  }

  public int hashCode()
  {
    return (this.z * 256 + this.y) * 256 + this.x;
  }

  public String toString()
  {
    return "(" + this.x + "," + this.y + "," + this.z + ")";
  }
}
