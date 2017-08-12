package org;

public class Foot {
	private double ref;
	private double lat;
	private double lon;
	public Foot(double ref, double lat, double lon) {
		this.ref = ref;
		this.lat = lat; 
		this.lon = lon; 
		}  
	
	public double getRef() { 
		return ref;
		} 
    public void setRef(double ref) { 
		this.ref = ref; 
		} 
	public double getLat() { 
			return lat;
			} 
    public void setLat(double lat) { 
			this.lat = lat; 
			} 
    public double getLon() { 
				return lon;
				} 
	public void setLon(double lon) {
				this.lon = lon;
				}
    @Override public String toString() {
				return "Foot[ref="+ref+",lat=" + lat + ", lon=" + lon + "]"; 
				} 
}
