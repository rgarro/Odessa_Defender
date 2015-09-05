/**
 * Singleton for config the application.
 * @author JoseCarlos Solano
 * @version 1.0
 **/

import com.xfactorstudio.xml.xpath.XPath;
import mx.utils.Delegate;
import com.avVenta.events.IBroadcastable;
import com.avVenta.events.EventBroadcaster;
import com.avVenta.loading.LoadingItem;

dynamic class com.avVenta.config.Settings extends Object {

	static public var ON_SETTINGS_LOADED:String = "onSettingsLoaded";
	static public var URL:String;
	static private var instance:Settings;		
	private var xml:XML;
	private var broadcast:EventBroadcaster;
	private var data:XML;	
	
	
	private function Settings() {
		broadcast = new EventBroadcaster();
		data = new XML();
		data.ignoreWhite = true;
		var loadXml:LoadingItem = new LoadingItem(Settings.URL, data, "xml", 1);
		loadXml.addEventListener(LoadingItem.ONLOAD_EVENT, this, "onDataLoad");
		loadXml.load();
	}
	
	
	private function onDataLoad():Void {
		broadcastEvent("onSettingsLoaded");
	}
	
	
	/**
		Static method used to get the single instance of this class.
	*/
	static public function getInstance():Settings {
		if(Settings.instance == null) {
			if(Settings.URL == null) {
				throw new Error("ERROR: Settings.URL must be defined prior to getting an instance of the Settings class.");
			}
			Settings.instance = new Settings();
		}
		return Settings.instance;
	}
	
	/**
		The __resolve method handles undefined properties and methods.
		It acts as a facade to the XML data.
		When an undefined property is called, this method looks for that value in the xml.
		
		@param id (String) The id of the property to return.
	*/
	public function __resolve(id:String):XMLNode {
		var property:XMLNode = XMLNode(XPath.selectSingleNode(data, "/settings/properties/property[@id = '" + id + "']"));
		return property.attributes.value;
	}
	
	public function addEventListener(eventName : String, listener : Object, methodName : String) : Void {
		broadcast.addEventListener(eventName,listener,methodName);
	}

	public function broadcastEvent(eventName : String, data : Object) : Void {
		broadcast.broadcastEvent(eventName,data);
	}

	public function removeEventListener(eventName : String, listener : Object, methodName : String) : Void {
		broadcast.removeEventListener(eventName,listener,methodName);
	}
	
}