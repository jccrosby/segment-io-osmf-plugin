package com.realeyes.osmf.plugins.tracking.elements
{
	import com.jccrosby.analytics.segmentio.Context;
	import com.realeyes.osmf.plugins.tracking.SegmentIOPluginInfo;
	import com.realeyes.osmf.plugins.tracking.SegmentIOTracker;
	import com.realeyes.osmf.plugins.tracking.events.DurationMarkerEvent;
	import com.realeyes.osmf.plugins.tracking.model.Configuration;
	import com.realeyes.osmf.plugins.tracking.model.Marker;
	import com.realeyes.osmf.plugins.tracking.model.TrackDefinition;
	import com.realeyes.osmf.plugins.tracking.model.TrackTimeDefinition;
	import com.realeyes.osmf.plugins.tracking.model.TrackType;
	import com.realeyes.osmf.plugins.tracking.util.DurationTracker;
	
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osmf.elements.ProxyElement;
	import org.osmf.events.AudioEvent;
	import org.osmf.events.BufferEvent;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.DVREvent;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.LoadEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.PlayEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.traits.AudioTrait;
	import org.osmf.traits.BufferTrait;
	import org.osmf.traits.DRMTrait;
	import org.osmf.traits.DVRTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayState;
	import org.osmf.traits.PlayTrait;
	import org.osmf.traits.SeekTrait;
	import org.osmf.traits.TimeTrait;
	
	public class SegmentIOTrackingElement extends ProxyElement
	{
		// ==========================================
		// Declarations
		// ==========================================

		public static const DERIVED_RESOURCE_METADATA:String = "http://www.osmf.org/derivedResource/1.0"; // This is to pull out the meta data from URL resources that get obscured by the OSMF management of metadata
		
		private var _config:Configuration;
		private var _tracker:SegmentIOTracker;
		private var _currentTimeTimer:Timer;
		private var _durationTracker:DurationTracker;
		private var _timeTrait:TimeTrait;
		private var _currentMediaID:String;
		
		
		// ==========================================
		// Init
		// ==========================================
		
		public function SegmentIOTrackingElement(proxiedElement:MediaElement=null, trackingConfig:Configuration=null)
		{
			super(proxiedElement);
			
			_config = trackingConfig;
		}
		
		private function _init():void
		{
			_initTimer();
			
			if( _config.durrationTrackingEnabled )
			{
				_initDurationTracker();
			}
			_tracker = new SegmentIOTracker(_config.secret);
		}
		
		private function _initTimer():void
		{
			_currentTimeTimer = new Timer(_config.updateInterval);
			_currentTimeTimer.addEventListener(TimerEvent.TIMER, _onCurrentTime);
			_currentTimeTimer.start();
		}
		
		private function _initDurationTracker():void
		{
			_durationTracker = new DurationTracker();
			_durationTracker.addEventListener( DurationMarkerEvent.PERCENT_MARKER, _onPercentMarker );
			_durationTracker.addEventListener( DurationMarkerEvent.TIME_MARKER, _onTimeMarker );
			
			var marker:Marker;
			var percentEvents:TrackTimeDefinition = TrackTimeDefinition( _config.getTrackEvent( TrackType.PERCENT_WATCHED ) );
			if( percentEvents )
			{
				for each( marker in percentEvents.markers )
				{
					_durationTracker.addPercentMarker( marker );	
				}
			}
			
			var timeEvents:TrackTimeDefinition = TrackTimeDefinition( _config.getTrackEvent( TrackType.TIME_WATCHED ) );
			if( timeEvents )
			{
				for each( marker in timeEvents.markers )
				{
					_durationTracker.addTimeMarker( marker );	
				}
			}
		}
		
		
		// ==========================================
		// Control
		// ==========================================
		
		protected function _sendPageTracking( pageURL:String ):void
		{
			_tracker.trackPageView(pageURL);
		}
		
		protected function _sendEventTracking(trackEvent:TrackDefinition):void
		{
			if(trackEvent)
			{
				var properties:Object = {
					category: trackEvent.category,
						action: trackEvent.action,
						label: trackEvent.label,
						value: trackEvent.value
				};
				
				_tracker.trackEvent(trackEvent.category, properties, _config.userID, _config.sessionID);	
			}
		}
		
		protected function processAutoSwitchChange( event:DynamicStreamEvent ):void
		{
			var newAutoSwitch:Boolean = event.autoSwitch;
			////trace( "processAutoSwitchChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.AUTO_SWITCH_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = newAutoSwitch.toString();
				}
				
				// TODO: context and timestamp 
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processBufferingChange( event:BufferEvent ):void
		{
			var buffering:Boolean = event.buffering;
			////trace( "processBufferingChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.BUFFERING_CHANGE );
			
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = buffering.toString();
				}
				
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processBufferTimeChange( event:BufferEvent ):void
		{
			var newBufferTime:Number = event.bufferTime; 
			////trace( "processBufferTimeChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.BUFFER_TIME_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = newBufferTime.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processBytesTotalChange( event:LoadEvent ):void
		{
			var newBytes:Number = event.bytes;
			
			////trace( "processBytesTotalChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.BYTES_TOTAL_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = newBytes.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processCanPauseChange( event:PlayEvent ):void
		{
			var canPause:Boolean = event.canPause;
			////trace( "processCanPauseChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.CAN_PAUSE_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = canPause.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processComplete( event:TimeEvent ):void
		{
			////trace( "processComplete" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.COMPLETE );
			if( trackEvent )
			{
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processDisplayObjectChange( event:DisplayObjectEvent ):void
		{
			var oldDisplayObject:DisplayObject = event.oldDisplayObject;
			var newView:DisplayObject = event.newDisplayObject;
			
			////trace( "processDisplayObjectChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.DISPLAY_OBJECT_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					// TODO: What are we going to send here
					//trackEvent.label = oldDisplayObject.name + ":" + newView.name;
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processDurationChange(newDuration:Number):void
		{
			////trace( "processDurationChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.DURATION_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = newDuration.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processLoadStateChange( event:LoadEvent ):void
		{
			var loadState:String = event.loadState;
			////trace( "processLoadStateChange: " + loadState );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.LOADSTATE_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = loadState;
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processMediaSizeChange( event:DisplayObjectEvent ):void
		{
			var oldWidth:Number = event.oldWidth; 
			var oldHeight:Number = event.oldHeight;
			var newWidth:Number = event.newWidth; 
			var newHeight:Number = event.newHeight;
			
			////trace( "processMediaSizeChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.MEDIA_SIZE_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = oldWidth + ":" + oldHeight + ":" + newWidth + ":" + newHeight;
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processMutedChange( event:AudioEvent ):void
		{
			////trace( "processMutedChange" );
			var muted:Boolean = event.muted;
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.MUTED_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = muted.toString();
				}
				_sendEventTracking(trackEvent);
			}
			
		}
		
		protected function processNumDynamicStreamsChange( event:DynamicStreamEvent ):void
		{
			////trace( "processNumDynamicStreamsChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.NUM_DYNAMIC_STREAMS_CHANGE );
			if( trackEvent )
			{
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processPanChange( event:AudioEvent ):void
		{
			////trace( "processPanChange" );
			var newPan:Number = event.pan;
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.PAN_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label =  newPan.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processPlayStateChange( event:PlayEvent ):void
		{
			var playState:String = event.playState;
			////trace( "processPlayStateChange: " + playState );
			
			if( playState == PlayState.STOPPED )
			{
				_currentTimeTimer.stop();
			}
			else if( playState == PlayState.PLAYING )
			{
				_currentTimeTimer.start();				
			}
			
			switch(event.playState)
			{
				case PlayState.PLAYING:
				{
					_currentTimeTimer.start();
					break;
				}
				case PlayState.STOPPED:
				case PlayState.PAUSED:
				{
					_currentTimeTimer.stop();
					break;
				}
			}
			
			
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.PLAY_STATE_CHANGE );
			if( trackEvent )
			{
				
				trackEvent.label =  playState;
				
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processSeekingChange( event:SeekEvent ):void
		{
			var seeking:Boolean = event.seeking;
			var time:Number = event.time;
			
			//trace( "processSeekingChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.SEEKING_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label =  seeking.toString() + ":" + time.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processSwitchingChange( event:DynamicStreamEvent ):void
		{
			var switching:Boolean = event.switching;
			//trace( "processSwitchingChange" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.SWITCHING_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label =  switching.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function processTraitAdd(traitType:String):void
		{
			////trace( "processTraitAdd: " + traitType );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.TRAIT_ADD );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = traitType;
				}
				_sendEventTracking(trackEvent);
			}
			
			// So we can start tracking amount viewed etc
			if( traitType == MediaTraitType.TIME )
			{
				_timeTrait = proxiedElement.getTrait( MediaTraitType.TIME ) as TimeTrait
			}
			
		}
		
		protected function processTraitRemove(traitType:String):void
		{
			////trace( "processTraitRemove" );
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.TRAIT_REMOVE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = traitType;
				}
				_sendEventTracking(trackEvent);
			}
			
			if( traitType == MediaTraitType.TIME )
			{
				_timeTrait = null;
				_currentTimeTimer.stop(); // make sure we're not tracking anymore
			}
		}
		
		protected function processVolumeChange( event:AudioEvent ):void
		{
			////trace( "processVolumeChange" );
			var newVolume:Number = event.volume;
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.VOLUME_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = newVolume.toString();
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		protected function trackPageView():void
		{
			if(proxiedElement)
			{
				var pageURL:String;
				var resource:URLResource = proxiedElement.resource as URLResource;
				
				var derivedMetaDataResource:URLResource = resource.getMetadataValue(MetadataNamespaces.DERIVED_RESOURCE_METADATA) as URLResource;
				var meta:Object;
				
				if(derivedMetaDataResource)
				{
					meta = derivedMetaDataResource.getMetadataValue(SegmentIOPluginInfo.NAMESPACE);	
				}
				else
				{
					meta = resource.getMetadataValue(SegmentIOPluginInfo.NAMESPACE);
				}
				
				if(meta)
				{
					pageURL = meta[ "pageURL" ] as String;
				}
				else
				{
					if(resource)
					{	
						pageURL = resource.url;
					}
				}
				
				if(pageURL)
				{
					_sendPageTracking(pageURL);
				}
			}
			
		}
		
		private function processRecordingChange( event:DVREvent ):void
		{
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.RECORDING_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = "Recording Changed";
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		private function processDRMStateChange( event:DRMEvent ):void
		{
			var drmState:String = event.drmState;
			var endDate:Date = event.endDate;
			var mediaError:MediaError = event.mediaError;
			var period:Number = event.period;
			var serverURL:String = event.serverURL;
			var startDate:Date = event.startDate;
			var token:Object = event.token;
			
			var label:Array = [ drmState, endDate.toDateString(), mediaError.name + " (" + mediaError.errorID + ") " + mediaError.message + "-" + mediaError.detail, period, serverURL, startDate.toDateString(), token.toString() ];
			
			var trackEvent:TrackDefinition = _config.getTrackEvent( TrackType.DRM_STATE_CHANGE );
			if( trackEvent )
			{
				if( !trackEvent.label )
				{
					trackEvent.label = label.join( ":" );
				}
				_sendEventTracking(trackEvent);
			}
		}
		
		// ==========================================
		// Event Handlers
		/// ==========================================
		
		protected function _onAddTrait( event:MediaElementEvent ):void
		{
			//trace( "Add: " + event.traitType );
			var trait:MediaTraitBase;
			
			processTraitAdd( event.traitType );
			
			switch( event.traitType )
			{
				case MediaTraitType.AUDIO:
				{
					var audioTrait:AudioTrait = proxiedElement.getTrait( MediaTraitType.AUDIO ) as AudioTrait;
					audioTrait.addEventListener( AudioEvent.MUTED_CHANGE, processMutedChange );
					audioTrait.addEventListener( AudioEvent.PAN_CHANGE, processPanChange );
					audioTrait.addEventListener( AudioEvent.VOLUME_CHANGE, processVolumeChange );
					
					break;
				}
				case MediaTraitType.BUFFER:
				{
					var bufferTrait:BufferTrait = proxiedElement.getTrait( MediaTraitType.BUFFER ) as BufferTrait;
					bufferTrait.addEventListener( BufferEvent.BUFFER_TIME_CHANGE, processBufferTimeChange );
					bufferTrait.addEventListener( BufferEvent.BUFFERING_CHANGE, processBufferingChange );
					
					break;
				}
				case MediaTraitType.DISPLAY_OBJECT:
				{
					var doTrait:DisplayObjectTrait = proxiedElement.getTrait( MediaTraitType.DISPLAY_OBJECT ) as DisplayObjectTrait;
					doTrait.addEventListener( DisplayObjectEvent.DISPLAY_OBJECT_CHANGE, processDisplayObjectChange );
					doTrait.addEventListener( DisplayObjectEvent.MEDIA_SIZE_CHANGE, processMediaSizeChange );
					
					break;
				}
				case MediaTraitType.DRM:
				{
					var drmTrait:DRMTrait = proxiedElement.getTrait( MediaTraitType.DRM ) as DRMTrait;
					drmTrait.addEventListener(DRMEvent.DRM_STATE_CHANGE, processDRMStateChange );
					
					break;
				}
				case MediaTraitType.DVR:
				{
					var dvrTrait:DVRTrait = proxiedElement.getTrait( MediaTraitType.DVR ) as DVRTrait;
					dvrTrait.addEventListener( DVREvent.IS_RECORDING_CHANGE, processRecordingChange );
					
					break;
				}
				case MediaTraitType.DYNAMIC_STREAM:
				{
					var dynStreamTrait:DynamicStreamTrait = proxiedElement.getTrait( MediaTraitType.DYNAMIC_STREAM ) as DynamicStreamTrait;
					dynStreamTrait.addEventListener( DynamicStreamEvent.AUTO_SWITCH_CHANGE, processAutoSwitchChange );
					dynStreamTrait.addEventListener( DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE, processNumDynamicStreamsChange );
					dynStreamTrait.addEventListener( DynamicStreamEvent.SWITCHING_CHANGE, processSwitchingChange );
					
					break;
				}
				case MediaTraitType.LOAD:
				{
					var loadTrait:LoadTrait = proxiedElement.getTrait( MediaTraitType.LOAD ) as LoadTrait;
					loadTrait.addEventListener( LoadEvent.BYTES_TOTAL_CHANGE, processBytesTotalChange );
					loadTrait.addEventListener( LoadEvent.LOAD_STATE_CHANGE, processLoadStateChange );
					break;
				}
				case MediaTraitType.PLAY:
				{
					var playTrait:PlayTrait = proxiedElement.getTrait( MediaTraitType.PLAY ) as PlayTrait;
					playTrait.addEventListener( PlayEvent.CAN_PAUSE_CHANGE, processCanPauseChange );
					playTrait.addEventListener( PlayEvent.PLAY_STATE_CHANGE, processPlayStateChange );
					
					// If the video is playing already (WTF?) we need to start up the tracking
					if( playTrait.playState == PlayState.PLAYING )
					{
						processPlayStateChange( new PlayEvent( PlayEvent.PLAY_STATE_CHANGE, false, false, playTrait.playState, playTrait.canPause ) );	
					}
					break;
				}
				case MediaTraitType.SEEK:
				{
					var seekTrait:SeekTrait = proxiedElement.getTrait( MediaTraitType.SEEK ) as SeekTrait;
					seekTrait.addEventListener( SeekEvent.SEEKING_CHANGE, processSeekingChange );
					break;
				}
				case MediaTraitType.TIME:
				{
					var timeTrait:TimeTrait = proxiedElement.getTrait( MediaTraitType.TIME ) as TimeTrait;
					timeTrait.addEventListener( TimeEvent.COMPLETE, processComplete );
					break;
				}
			}
		}
		
		protected function _onRemoveTrait( event:MediaElementEvent ):void
		{
			//trace( "Remove: " + event.traitType );
		}
		
		private function _onCurrentTime( event:TimerEvent ):void
		{
			if( _timeTrait && _timeTrait.currentTime > _durationTracker.currentTime ) // Only check time going forward
			{
				_durationTracker.checkTime( _timeTrait.currentTime, _timeTrait.duration );
			}
		}
		
		private function _onPercentMarker( event:DurationMarkerEvent ):void
		{
			//trace( "percent marker: " + event.percent.toString() );
			var trackEvent:TrackTimeDefinition = _config.getTrackEvent( TrackType.PERCENT_WATCHED ) as TrackTimeDefinition;
			
			trackEvent.label = event.marker.label;
			trackEvent.value = event.marker.marker;
			
			_sendEventTracking(trackEvent);
		}
		
		private function _onTimeMarker( event:DurationMarkerEvent ):void
		{
			//trace( "time marker: " + event.time.toString() );
			var trackEvent:TrackTimeDefinition = _config.getTrackEvent( TrackType.TIME_WATCHED ) as TrackTimeDefinition;
			
			//_sendEventTracking( trackEvent.category, trackEvent.action, event.marker.label + ":" + event.marker.marker, trackEvent.value );
			
			trackEvent.label = event.marker.label;
			trackEvent.value = event.marker.marker;
			
			_sendEventTracking(trackEvent);
		}
		
		
		// ==========================================
		// Getter/Setters
		// ==========================================
		
		override public function set proxiedElement( value:MediaElement ):void
		{
			super.proxiedElement = value;
			if( proxiedElement )
			{	
				_init();
				
				proxiedElement.addEventListener( MediaElementEvent.TRAIT_ADD, _onAddTrait );
				proxiedElement.addEventListener( MediaElementEvent.TRAIT_REMOVE, _onRemoveTrait );
				
				// track the video as a page view
				var trackDef:TrackDefinition = _config.getTrackEvent( TrackType.PAGE_VIEW );
				
				if( trackDef )
				{
					trackPageView();
				}
			}
		}
	}
}