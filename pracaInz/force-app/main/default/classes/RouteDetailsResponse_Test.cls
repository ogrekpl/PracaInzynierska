@IsTest
public class RouteDetailsResponse_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'    \"formatVersion\": \"0.0.12\",'+
		'    \"routes\": ['+
		'        {'+
		'            \"summary\": {'+
		'                \"lengthInMeters\": 108830,'+
		'                \"travelTimeInSeconds\": 6087,'+
		'                \"trafficDelayInSeconds\": 0,'+
		'                \"trafficLengthInMeters\": 0,'+
		'                \"departureTime\": \"2023-03-09T13:54:15+01:00\",'+
		'                \"arrivalTime\": \"2023-03-09T15:35:41+01:00\"'+
		'            },'+
		'            \"legs\": ['+
		'                {'+
		'                    \"summary\": {'+
		'                        \"lengthInMeters\": 108830,'+
		'                        \"travelTimeInSeconds\": 6087,'+
		'                        \"trafficDelayInSeconds\": 0,'+
		'                        \"trafficLengthInMeters\": 0,'+
		'                        \"departureTime\": \"2023-03-09T13:54:15+01:00\",'+
		'                        \"arrivalTime\": \"2023-03-09T15:35:41+01:00\"'+
		'                    },'+
		'                    \"points\": ['+
		'                        {'+
		'                            \"latitude\": 52.16379,'+
		'                            \"longitude\": 21.04657'+
		'                        },'+
		'                        {'+
		'                            \"latitude\": 51.40277,'+
		'                            \"longitude\": 21.11801'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            ],'+
		'            \"sections\": ['+
		'                {'+
		'                    \"startPointIndex\": 0,'+
		'                    \"endPointIndex\": 1374,'+
		'                    \"sectionType\": \"TRAVEL_MODE\",'+
		'                    \"travelMode\": \"truck\"'+
		'                }'+
		'            ]'+
		'        }'+
		'    ]'+
		'}';
		RouteDetailsResponse obj = RouteDetailsResponse.parse(json);
		System.assert(obj != null);
	}
}