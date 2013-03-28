package
{
	import flash.display.Sprite;
	
	import org.osmf.media.PluginInfo;
	
	public class SegmentIOPlugin extends Sprite
	{
		private var _pluginInfo:PluginInfo;
		
		public function SegmentIOPlugin()
		{
			
		}
		
		public function get pluginInfo():PluginInfo
		{
			return _pluginInfo;
		}
	}
}