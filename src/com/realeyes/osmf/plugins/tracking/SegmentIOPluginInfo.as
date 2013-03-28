package com.realeyes.osmf.plugins.tracking
{
	import com.realeyes.osmf.plugins.tracking.elements.SegmentIOTrackingElement;
	import com.realeyes.osmf.plugins.tracking.model.Configuration;
	
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactoryItem;
	import org.osmf.media.MediaFactoryItemType;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.PluginInfo;
	import org.osmf.net.NetLoader;
	
	public class SegmentIOPluginInfo extends PluginInfo
	{
		static public const NAMESPACE:String = "http://www.realeyes.com/osmf/plugins/tracking/segmentio";
		
		private var _trackingElement:SegmentIOTrackingElement;
		private var _trackingConfig:Configuration;
		
		public function SegmentIOPluginInfo(mediaFactoryItems:Vector.<MediaFactoryItem>=null, mediaElementCreationNotificationFunction:Function=null)
		{
			trace("SegmentIOPluginInfo()");
			var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
			
			var loader:NetLoader = new NetLoader();
			var item:MediaFactoryItem = new MediaFactoryItem( 
				"com.realeyes.osmf.tracking.SegmentIOPluginInfo", 
				loader.canHandleResource, 
				_createMediaElement,
				MediaFactoryItemType.PROXY
			);
			
			items.push(item);
			
			super(items, mediaElementCreated);
		}
		
		public function _createMediaElement():MediaElement
		{
			// Create the tracking element
			_trackingElement = new SegmentIOTrackingElement(null, _trackingConfig);
			return _trackingElement;
		}
		
		protected function mediaElementCreated(mediaElement:MediaElement):void
		{
			trace("Media element created!");
			//_trackingElement.proxiedElement = mediaElement;
			//_trackingElement.container = mediaElement;
		}
		
		override public function initializePlugin(resource:MediaResourceBase):void
		{
			// This is where we get the metadata associated with the resource, so we can pass in data here.
			var configXML:XML;
			var metadata:Object = resource.getMetadataValue(NAMESPACE);
			
			if(metadata is String)
			{
				configXML = new XML(metadata)
			}
			
			if(metadata is XML)
			{
				configXML = metadata as XML;
			}
			else
			{
				throw new Error( "The Segment.io plugin expects XML configuration" );
			}
			
			_trackingConfig = new Configuration(configXML);
		}
	}
}