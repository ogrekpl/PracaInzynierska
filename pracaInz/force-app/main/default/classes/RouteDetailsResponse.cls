public class RouteDetailsResponse {

	public class Legs {
		public Summary summary;
		public List<Points> points;
	}

	public class Points {
		public Double latitude;
		public Double longitude;
	}

	public String formatVersion;
	public List<Routes> routes;

	public class Sections {
		public Integer startPointIndex;
		public Integer endPointIndex;
		public String sectionType;
		public String travelMode;
	}

	public class Summary {
		public Integer lengthInMeters;
		public Integer travelTimeInSeconds;
		public Integer trafficDelayInSeconds;
		public Integer trafficLengthInMeters;
		public String departureTime;
		public String arrivalTime;
	}

	public class Routes {
		public Summary summary;
		public List<Legs> legs;
		public List<Sections> sections;
	}

	
	public static RouteDetailsResponse parse(String json) {
		return (RouteDetailsResponse) System.JSON.deserialize(json, RouteDetailsResponse.class);
	}
}