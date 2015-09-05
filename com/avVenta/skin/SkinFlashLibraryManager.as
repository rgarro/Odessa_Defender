import com.avVenta.events.EventBroadcaster;
import mx.utils.Delegate;
import com.avVenta.loading.LoadController;
import com.avVenta.loading.LoadingItem;
import flash.display.BitmapData;
import flash.geom.Matrix;
import com.avVenta.skin.SkinElement;
import com.avVenta.config.Settings;
/**
 * this class controls the skin static method.
 * is nescessary that the settings class had been initialized first.
 * @author jose.solano
 */
class com.avVenta.skin.SkinFlashLibraryManager {
	
	static public var ON_SKIN_READY:String = "onSkinReady";
	
	private var broadcaster:EventBroadcaster;
	private static var instance:SkinFlashLibraryManager;
	private var loadController:LoadController;
	private var skinXml:XML;
	public var mcAssets:MovieClip;
	private var images:Array;
	private var settings:Settings;
	
	//var loadXml:LoadingItem;
	//var loadAssets:LoadingItem;
	
	public function SkinFlashLibraryManager() {
		broadcaster = new EventBroadcaster();
		settings = Settings.getInstance();
	}
	
	public static function getInstance(Void):SkinFlashLibraryManager
	{
		if (SkinFlashLibraryManager.instance == null)
		{
			SkinFlashLibraryManager.instance = new SkinFlashLibraryManager();
		}
		return instance;
	}
	
	
	/**
	 * @param target MovieClip movie reference of the container where you want put the skin image
	 * @param linkageId String the name of the element in the flash library.
	 * @param depth [optional] Number An integer specifying the depth level where the SWF file is placed. if you don't specify it the default will be the mayor.
	 * @param initObject Object [optional] an initialize object with properties values.
	 * @return mcReference MovieClip A reference to the newly created instance.
	 */
	public function createInstanceOfElement(target:MovieClip, name:String, linkageId:String, depth:Number, initObject:Object){
		
		var element:SkinElement = SkinElement.create(target, name, depth, initObject);
		element.buildSkinElement(linkageId, mcAssets);
		
	}
	
	/**
	 * Starts load the skin xml file
	 */
	public function startLoad(){
		
		loadController = LoadController.getInstance();
		loadController.addEventListener(loadController.ON_QUEUE_EMPTY_EVENT, this, "initializeSkin");
		
		skinXml  = new XML();
		skinXml.ignoreWhite = true;
		
		mcAssets = _root.createEmptyMovieClip("mcAssets", _root.getNextHighestDepth());
		
		mcAssets._y = -1 * (Stage.width + Stage.height);
		mcAssets._visible = false;
		
		var loadXml = new LoadingItem(settings.skinPropertiesXml, skinXml, "xml", 1);		
		var loadAssets = new LoadingItem(settings.mcWithSkinAssets, mcAssets, "movieclip", 1);
		
		loadController.addLoad(loadXml);
		loadController.addLoad(loadAssets);
		
		loadController.startLoad();
	}
	
	
	
	
	private function initializeSkin(loaded:Boolean){
		loadController.removeEventListener(loadController.ON_QUEUE_EMPTY_EVENT, this, "initializeSkin");
		
		images = new Array();
		
		var totalNodes:Number = skinXml.firstChild.childNodes.length;
		for(var i:Number = 0; i < totalNodes; i++){
			var name = skinXml.firstChild.childNodes[i].attributes.id;
			var obj:Object = new Object();
			obj._x = Number(skinXml.firstChild.childNodes[i].attributes._x);
			obj._y = Number(skinXml.firstChild.childNodes[i].attributes._y);	
			obj._height = Number(skinXml.firstChild.childNodes[i].attributes._height);	
			obj._width = Number(skinXml.firstChild.childNodes[i].attributes._width);
			obj._name = name;
			images[name] = obj;
		}
		
		broadcastEvent(SkinFlashLibraryManager.ON_SKIN_READY);
	}
	
	private function createLibraryElement(linkageId:String):Void{
		
	}
	
	public function getPropertiesForElement(elementName:String):Object{
		return images[elementName];
	}
	
	public function addEventListener(eventName : String, listener : Object, methodName : String) : Void
	{
		broadcaster.addEventListener(eventName, listener, methodName);
	}

	public function broadcastEvent(eventName : String, data : Object) : Void
	{
		broadcaster.broadcastEvent(eventName, data);
	}

	public function removeEventListener(eventName : String, listener : Object, methodName : String) : Void
	{
		broadcaster.removeEventListener(eventName, listener, methodName);
	}

	public function toString(Void):String
	{
		return "[SkinFlashLibraryManager]";
	}
}