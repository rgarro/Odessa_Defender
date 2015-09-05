import com.avVenta.events.*;
import com.avVenta.debug.*;
import mx.utils.Delegate;

class com.avVenta.loading.LoadingItem implements IBroadcastable{
	private var source:String;
	private var objectToLoad:Object;
	private var type:String;
	private var step:Number;
	private var nextStep:Number = 0;
	private var monitorInterval:Number;
	private var broadcast:EventBroadcaster;
	private var debugger:DebugController;
	private var loader:MovieClipLoader;
	
	static public var ONSTARTLOAD_EVENT = "onStartLoad";
	static public var ONLOAD_EVENT = "onLoad";
	static public var ONLOADERROR_EVENT = "onLoadError";
	static public var ONLOADINGSTATUS_EVENT = "onLoadingStatus";

	public var name:String;
	
	/**
	 * @param source String url of the external data.
	 * @param objectToLoad Object the object that will resive the external data. it could be an XML or a MovieClip.\
	 * @param type String The tyoe of object to load, could be xml, image or message, the last one is for dispatch an event that you can use to be informate after some load process.
	 * @param step Number Sets the interval percent of the load and that onLoadingStatus event will dispatched.                                                                                   
	 */
	public function LoadingItem(source:String, objectToLoad:Object, type:String, step:Number){
		name = "LoadingItem";

		this.source = source;
		this.objectToLoad = objectToLoad;
		this.type = type;
		this.step = step;
		this.broadcast = new EventBroadcaster();
		this.debugger = DebugController.getInstance();
		this.loader = new MovieClipLoader();
	}
	
	public function load(){
		debugger.trace(this, 'loading '+type+' from "'+source+'" in container "'+objectToLoad+'"');
	
		switch (this.type){
			case "movieclip":{
			
				onStartLoad();
				
				loader.addListener(this);
				loader.loadClip(source, objectToLoad);
				
				break;
			}
			
			case "xml":{
				
				//this.objectToLoad = new XML(); 
				
				this.onStartLoad();
				
				this.objectToLoad.ignoreWhite = true;
				this.objectToLoad.load(this.source);
				
				this.objectToLoad.step = this.step;
				this.objectToLoad.next = 0;
				this.objectToLoad.loadingItem = this;
				
				break;
			}
			
			case "message":{
				this.onLoad({type: "message", source: this.source, target: objectToLoad});
				break;
			}			
		}
		
		if(type != "message"){
			monitorInterval = setInterval(Delegate.create(this, loadingMonitor), 100);
		}
		
	}
	
	private function loadingMonitor():Void{
		var percent = Math.floor( 10000 * (objectToLoad.getBytesLoaded() / objectToLoad.getBytesTotal()) ) / 100;
		if (percent >= nextStep){
			onLoadingStatus({percent: percent});
			var intPercent = Math.floor(percent);
			nextStep = intPercent - (intPercent % this.step) + this.step;
		}

		if ((type != "movieclip") && (objectToLoad.getBytesTotal() > 0))
			if (objectToLoad.getBytesTotal() == objectToLoad.getBytesLoaded()){
				clearInterval(monitorInterval);
				onLoad({target: objectToLoad, type: this.type});
			}	
	}
	
	private function onLoadInit(target_mc:MovieClip, httpStatus:Number) {
		clearInterval(monitorInterval);
		onLoad({target: objectToLoad, type: this.type});
	}
	
	private function onLoadError(target_mc, errorCode) {
		broadcastEvent(LoadingItem.ONLOADERROR_EVENT, {target: objectToLoad, type: this.type, error:errorCode});
	}
	
	private function onLoad(evtObject:Object){
		broadcastEvent(LoadingItem.ONLOAD_EVENT, evtObject);
	}
	
	private function onStartLoad(evtObject:Object){
		this.broadcastEvent(LoadingItem.ONSTARTLOAD_EVENT, evtObject);
	}
	
	private function onLoadingStatus(evtObject:Object){
		this.broadcastEvent(LoadingItem.ONLOADINGSTATUS_EVENT, evtObject);
	}
	
	public function getObject():Object {
		return objectToLoad;
	}

	public function addEventListener(eventName : String, listener : Object, methodName : String) : Void {
		broadcast.addEventListener(eventName,listener,methodName);
	}

	public function broadcastEvent(eventName : String, data : Object) : Void {
		broadcast.broadcastEvent(eventName, this, data);
	}

	public function removeEventListener(eventName : String, listener : Object, methodName : String) : Void {
		broadcast.removeEventListener(eventName,listener,methodName);
	}
}