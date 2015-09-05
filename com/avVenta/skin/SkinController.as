import TextField.StyleSheet;
import com.avVenta.events.*;
import com.avVenta.debug.*;
import com.avVenta.loading.*;
import com.avVenta.skin.*;

/**
 * This class loads, parses and assigns skins.
 *
 * @author Marco A. Alvarado
 * @version 1.0.0 2007-01-29
 */
class com.avVenta.skin.SkinController {

	// Constants
	static private var DEBUG = true;

	// Variables	
	private var broadcaster:EventBroadcaster;
	private var debugger:DebugController;
	public var name:String;
	public var styles:Object;
	public var images:Object;
	public var objects:Object;
	
	/**
	 * Constructor
	 */
	function SkinController() {
		name = 'SkinController';

		broadcaster = new EventBroadcaster();
		debugger = DebugController.getInstance();
	}
	
	/**
	 * Loads a skin from a given url using the LoadController singleton. 
	 * Progress is informed to the given movie clip each step.
	 */
	public function loadSkin(url:String, target:MovieClip, step:Number) {
		var loader:LoadingItem;
	
		if (DEBUG) debugger.trace(this, 'loading skin');
		
		loader = new LoadingItem(url, target, "xml", step);
		loader.addListener(LoadingItem.ONLOAD_EVENT, this);
		LoadController.loadItem(loader);
	}
	
	/**
	 * Receives and parses the loaded skin.
	 */
	public function onLoad(source:Object, data:Object) {
		
		switch (data.type) {
			case "xml": {
				var xml:XML = data.target.xmlToLoad;
				
				if (DEBUG) debugger.trace(this, 'skin loaded, xml format:\n'+xml);
				
				for (var i:Number = 0; i < xml.childNodes.length; i++)
				{
					var node:XMLNode = xml.childNodes[i];
					
					switch(node.nodeName)
					{
						case "style": {
							var css:StyleSheet = new StyleSheet();
							if (css.parseCSS(node.firstChild.nodeValue))
								styles[node.attributes.name] = css; else
								if (DEBUG) debugger.trace(this, 'css did not parse');
							break;
						}
						
						case "img": {
							images[node.attributes.name] = node.attributes.src;
							break;
						}
						
						case "obj": {
							objects[node.attributes.name] = node.attributes;
							break;
						}
						
						default:
							if (DEBUG) debugger.trace(this, 'unknown node "'+node.nodeName+'" found');
					}
				}				
								
				break;
			}
			
			default:
				if (DEBUG) debugger.trace(this, 'skin loaded, unknown format "'+data.type+'"');
		}
	}
}