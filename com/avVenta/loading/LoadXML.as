import com.avVenta.events.EventBroadcaster;
/**
 * @author jose.solano
 * @event onLoadStart
 * @event onLoadProgress
 * @event onLoadComplete
 */
class com.avVenta.loading.LoadXML {
	
	//Static Private Properties
	
   	//Private Properties	
	private var broadcaster:EventBroadcaster;
	private var xml:XML;
	private var url:String;
	private var data:Object;
	private var isLoaded:Boolean;
	private var isLoading:Boolean;
	private var isErrored:Boolean;
	private var loadInterval:Number;
	private var startTime:Number;
	
	//Static Public Properties
	
   	//Public Properties
   	
   	//Constructor
	public function LoadXML(url:String, xml:XML, data:Object) {
		this.xml = xml;
		isLoaded = false;
		isLoading = false;
		isErrored = false;
	}
	
	//Static Private Methods
   	//Private Methods
   	
   	private function destroyLoadProccess():Void{
		clearInterval(loadInterval);
		isLoading = false;
	}
	
	
   	//Static Public Methods
   	//Public Methods
	public function loadStatusMonitor():Void{
		var bytesLoaded:Number  = xml.getBytesLoaded();
		var bytesTotal:Number = xml.getBytesTotal();
		if(bytesTotal > 0) {
				var percentage:Number = Math.round((bytesLoaded / bytesTotal) * 100);
				broadcaster.broadcastEvent('onLoadProgress', {percentage:percentage, data:data});  
				if(bytesLoaded == bytesTotal && xml.loaded) {
					isLoaded = true;
					broadcaster.broadcastEvent('onLoadComplete', this, data);
					destroyLoadProccess();
				}
			}
	}
	
	public function triggerLoad():Void{
		xml.load(url);
		if(!isLoading) {
			isLoading = true;
			broadcaster.broadcastEvent("onLoadStart", this);
			loadInterval = setInterval(this, "loadMonitor", 250);
			startTime = getTimer();
		}
	}
	
	
	
	//Getter/Setter Methods
}