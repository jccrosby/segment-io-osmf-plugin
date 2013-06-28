# OSMF Plugin for [Segment.io](http://segment.io)

## Installation and setup  
* Project Type: ActionScript 3 Library
* Flex SDK: 4.6
* Required libraries: [OSMF](http://osmf.org/)
	* Checkout the [OSMF SVN REPO](http://sourceforge.net/adobe/osmf/svn/2081/tree/)
	* Flash Builder: Import the project in {TRUNK/TAG}/framework/OSMF/

## Usage  
	static public const SIO_NS:String = "http://www.realeyes.com/osmf/plugins/tracking/google";
	static public const SIO_PLUGIN_CONFIG_XML:XML = 
		<value key="reTrackConfig" type="class" class="com.realeyes.osmf.plugins.tracking.google.config.RETrackConfig">
	        <!-- Set your analytics account ID -->
	        <secret><![CDATA[YOUR_SEGMENT_IO_SECRET]]></secret>
	        
	        <!-- The User and/or Session IDs to use -->
	        <userID><![CDATA[test@jccrosby.com]]></userID>
	        <!-- sessionID><![CDATA[session12345]]></sessionID -->
	        
	        <!-- Set up the percent based tracking -->
	        <event name="percentWatched" category="video" action="percentWatched">
	            <marker percent="0" label="start" />
	            <marker percent="25" label="view" />
	            <marker percent="50" label="view" />
	            <marker percent="75" label="view" />
	        </event>
	        
	        <!-- Set up the event tracking for the completed event -->
	        <event name="complete" category="video" action="complete" label="trackingTesting" value="1" />

			<event name="playStateChange" category="video" action="playStateChange"  />
	        
	        <updateInterval><![CDATA[250]]></updateInterval>
		</value>;
		
		var segmentio:SegmentIOPluginInfo = new SegmentIOPluginInfo();
		var pluginInfoResource:PluginInfoResource = new PluginInfoResource(segmentio);
		pluginInfoResource.addMetadataValue(SegmentIOPluginInfo.NAMESPACE, SIO_PLUGIN_CONFIG_XML);
		
		mediaFactory.loadPlugin(pluginInfoResource);

### XML Configuration
	static public const SIO_PLUGIN_CONFIG_XML:XML = 
		<value key="reTrackConfig" type="class" class="com.realeyes.osmf.plugins.tracking.segmentio.config.RETrackConfig">
	        <!-- Set your analytics account ID -->
	        <secret><![CDATA[YOUR_SEGMENT_IO_SECRET]]></secret>
	        
	        <!-- The User and/or Session IDs to use -->
	        <userID><![CDATA[test@jccrosby.com]]></userID>
	        <!-- sessionID><![CDATA[session12345]]></sessionID -->
			
	        <url><![CDATA[http://osmf.realeyes.com]]></url>
	        
	        <!-- Set up the percent based tracking -->
	        <event name="percentWatched" category="video" action="percentWatched">
	            <marker percent="0" label="start" />
	            <marker percent="25" label="view" />
	            <marker percent="50" label="view" />
	            <marker percent="75" label="view" />
	        </event>
	        
	        <!-- Set up the event tracking for the completed event -->
	        <event name="complete" category="video" action="complete" label="trackingTesting" value="1" />

			<event name="playStateChange" category="video" action="playStateChange"  />
	        
	        <!-- These are the other available events that can be tracked -->
	        <!--
	        <event name="autoSwitchChange" category="video" action="autoSwitchChange" />
	        <event name="bufferingChange" category="video" action="bufferingChange" />
	        <event name="bufferTimeChange" category="video" action="bufferTimeChange" />
	        <event name="bytesTotalChange" category="video" action="bytesTotalChange" />
	        <event name="canPauseChange" category="video" action="canPauseChange"  />
	        <event name="displayObjectChange" category="video" action="displayObjectChange"  />
	        <event name="durationChange" category="video" action="durationChange"  />
	        <event name="loadStateChange" category="video" action="loadStateChange"  />
	        <event name="mediaSizeChange" category="video" action="mediaSizeChange"  />
	        <event name="mutedChange" category="video" action="mutedChange"  />
	        <event name="numDynamicStreamsChange" category="video" action="numDynamicStreamsChange"  />
	        <event name="panChange" category="video" action="panChange"  />
			<event name="playStateChange" category="video" action="playStateChange"  />
	        <event name="seekingChange" category="video" action="seekingChange"  />
	        <event name="switchingChange" category="video" action="switchingChange"  />
	        <event name="traitAdd" category="video" action="traitAdd" />
	        <event name="traitRemove" category="video" action="traitRemove"  />
	        <event name="volumeChange" category="video" action="volumeChange" />
	        <event name="recordingChange" category="dvr" action="recordingChange" />
	        -->
	        <!-- Time based tracking (in seconds)-->
	        <!--                            
	        <event name="timeWatched" category="video" action="timeWatched">
	                <marker time="5" label="start" />
	                <marker time="10" label="start" />
	                <marker time="20" label="start" />
	        </event>
	        -->
	        <debug><![CDATA[true]]></debug>
	        <!-- How often you want the timer to check the current position of the media (milliseconds) -->
	        <updateInterval><![CDATA[250]]></updateInterval>
		</value>;

## To Do
[ ] Implement page tacking  
[ ] Figure out a way to make the userID and sessionID dynamic  


## License  
Author: John Crosby <jccrosby@gmail.com>
[http://thekuroko.com](http://thekuroko.com)  
Copyright &copy; 2013 John Crosby  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
