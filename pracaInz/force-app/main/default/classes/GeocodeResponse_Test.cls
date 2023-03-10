@IsTest
public class GeocodeResponse_Test {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"summary\": {'+
		'    \"query\": \"al jana pawła 23 warszawa polska\",'+
		'    \"queryType\": \"NON_NEAR\",'+
		'    \"queryTime\": 108,'+
		'    \"numResults\": 1,'+
		'    \"offset\": 0,'+
		'    \"totalResults\": 1,'+
		'    \"fuzzyLevel\": 1,'+
		'    \"geoBias\": {'+
		'      \"lat\": 37.337,'+
		'      \"lon\": -121.89'+
		'    }'+
		'  },'+
		'  \"results\": ['+
		'    {'+
		'      \"type\": \"Point Address\",'+
		'      \"id\": \"YO-ANHwy8Ax-CoGloPbQrg\",'+
		'      \"score\": 12.0066423416,'+
		'      \"dist\": 9425831.792675218,'+
		'      \"matchConfidence\": {'+
		'        \"score\": 0.9869853795473089'+
		'      },'+
		'      \"address\": {'+
		'        \"streetNumber\": \"23\",'+
		'        \"streetName\": \"Aleja Jana Pawła II\",'+
		'        \"municipalitySubdivision\": \"Wola\",'+
		'        \"municipality\": \"Warszawa\",'+
		'        \"countrySecondarySubdivision\": \"Warszawa\",'+
		'        \"countrySubdivision\": \"Mazowieckie\",'+
		'        \"postalCode\": \"00-854\",'+
		'        \"countryCode\": \"PL\",'+
		'        \"country\": \"Polska\",'+
		'        \"countryCodeISO3\": \"POL\",'+
		'        \"freeformAddress\": \"Aleja Jana Pawła II 23, 00-854 Warszawa\",'+
		'        \"localName\": \"Warszawa\"'+
		'      },'+
		'      \"position\": {'+
		'        \"lat\": 52.23632,'+
		'        \"lon\": 20.99649'+
		'      },'+
		'      \"viewport\": {'+
		'        \"topLeftPoint\": {'+
		'          \"lat\": 52.23722,'+
		'          \"lon\": 20.99502'+
		'        },'+
		'        \"btmRightPoint\": {'+
		'          \"lat\": 52.23542,'+
		'          \"lon\": 20.99796'+
		'        }'+
		'      },'+
		'      \"entryPoints\": ['+
		'        {'+
		'          \"type\": \"main\",'+
		'          \"position\": {'+
		'            \"lat\": 52.23638,'+
		'            \"lon\": 20.99683'+
		'          }'+
		'        }'+
		'      ]'+
		'    }'+
		'  ]'+
		'}';
		GeocodeResponse obj = GeocodeResponse.parse(json);
		System.assert(obj != null);
	}
}