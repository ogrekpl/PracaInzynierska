public class GeocodeResponse {

	public Summary summary;
	public List<Results> results;

	public class Address {
		public String streetNumber;
		public String streetName;
		public String municipalitySubdivision;
		public String municipality;
		public String countrySecondarySubdivision;
		public String countrySubdivision;
		public String postalCode;
		public String countryCode;
		public String country;
		public String countryCodeISO3;
		public String freeformAddress;
		public String localName;
	}

	public class GeoBias {
		public Double lat;
		public Double lon;
	}

	public class Results {
		public String type;
		public String id;
		public Double score;
		public Double dist;
		public MatchConfidence matchConfidence;
		public Address address;
		public GeoBias position;
		public Viewport viewport;
		public List<EntryPoints> entryPoints;
	}

	public class Viewport {
		public GeoBias topLeftPoint;
		public GeoBias btmRightPoint;
	}

	public class Summary {
		public String query;
		public String queryType;
		public Integer queryTime;
		public Integer numResults;
		public Integer offset;
		public Integer totalResults;
		public Integer fuzzyLevel;
		public GeoBias geoBias;
	}

	public class EntryPoints {
		public String type;
		public GeoBias position;
	}

	public class MatchConfidence {
		public Double score;
	}

	
	public static GeocodeResponse parse(String json) {
		return (GeocodeResponse) System.JSON.deserialize(json, GeocodeResponse.class);
	}
}