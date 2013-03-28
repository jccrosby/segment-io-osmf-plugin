package com.jccrosby.osmf.plugins.tracking.model
{
	import com.jccrosby.osmf.plugins.tracking.model.Marker;
	import com.jccrosby.osmf.plugins.tracking.model.TrackDefinition;
	import com.jccrosby.osmf.plugins.tracking.model.TrackTimeDefinition;
	
	import flash.utils.Dictionary;

	public class Configuration
	{
		public var accounts:Array;
		public var secret:String;
		public var userID:String;
		public var sessionID:String;
		public var url:String;
		public var updateInterval:int = 250;
		public var events:Dictionary;
		public var durrationTrackingEnabled:Boolean;
		
		private var _debug:Boolean;
		private var _configXML:XML;
		
		public function Configuration(configXML:XML=null)
		{
			if(configXML)
			{
				this.configXML = configXML;
			}
		}
		
		// =======================================
		// Control Methods
		// =======================================
		
		public function getTrackEvent( eventType:String ):TrackDefinition
		{
			return events[ eventType ];
		}
		
		
		// =======================================
		// Getter/Setters
		// =======================================
		
		/**
		 *Toggles debugging for the GA for Flash
		 *  
		 * @return Boolean 
		 * 
		 */		
		public function get debug():Boolean
		{
			return _debug;
		}
		public function set debug( value:* ):void
		{
			_debug = value.toString() == "true" ? true:false;
		}
		
		public function set configXML( value:XML ):void
		{
			_configXML = value;
			
			accounts = new Array();
			secret = _configXML.secret;
			userID = _configXML.userID;
			sessionID = _configXML.sessionID;
			
			url = _configXML.url;
			debug = _configXML.debug;
			
			events = new Dictionary();
			for each( var event:XML in _configXML..event )
			{
				var label:String = event.hasOwnProperty( "label" ) == true ?  event.@label:null;
				var trackingValue:int = event.hasOwnProperty( "value" ) == true ? parseInt( event.@value ):null;
				
				var eventName:String = event.@name;
				switch( eventName )
				{
					case "percentWatched":
					case "timeWatched":
					{
						var newTimeEvent:TrackTimeDefinition = new TrackTimeDefinition( event.@name, event.@category, event.@action, label, trackingValue );
						
						for each( var marker:XML in event.marker )
						{
							var markerValue:int = parseInt( eventName == "percentWatched" ? marker.@percent:marker.@time );
							newTimeEvent.markers.push( new Marker( markerValue, marker.@label ) );	
						}
						events[ eventName ] = newTimeEvent;	
						
						durrationTrackingEnabled = true;
						
						break;
					}
					default:
					{
						var newEvent:TrackDefinition = new TrackDefinition( event.attribute( "name" ), event.attribute( "category" ), event.attribute( "action" ), label, trackingValue );
						events[ newEvent.name ] = newEvent;	
					}
				}					
			}
		}
	}
}