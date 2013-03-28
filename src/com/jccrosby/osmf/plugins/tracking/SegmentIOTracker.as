package com.jccrosby.osmf.plugins.tracking
{
	import com.jccrosby.analytics.segmentio.AnalyticsClient;
	import com.jccrosby.analytics.segmentio.Context;
	import com.jccrosby.analytics.segmentio.Traits;

	public class SegmentIOTracker
	{
		private var _client:AnalyticsClient;
		
		public function SegmentIOTracker(secret:String)
		{
			_client = new AnalyticsClient(secret);
		}
		
		public function identify(userID:String=null, sessionID:String=null, traits:Traits=null, context:Context=null, timestamp:Date=null):void
		{
			_client.identify(userID, sessionID, traits, context, timestamp);
		}
		
		public function trackEvent(event:String, properties:Object=null, userID:String=null, sessionID:String=null, context:Context=null, timestamp:Date=null):void
		{
			_client.track(event, properties, userID, sessionID, context, timestamp);
		}
		
		public function trackPageView(pageURL:String):void
		{
			trace("trackPageView is not implemented yet sorry.");
		}
	}
}