import com.avVenta.events.EventBroadcaster;
import com.avVenta.events.IBroadcastable;
import com.utilities.loading.LoadMovieClip;
import com.utilities.loading.LoadQueue;

import TextField.StyleSheet;

/**
 * @author jose.solano
 */
class com.avVenta.skin.Skin implements IBroadcastable{
	
	private var xml:XMLNode;
	private var images:Object;
	private var styleSheet:StyleSheet;
	private var broadcaster:EventBroadcaster;
	private var loadQueue:LoadQueue;
	private var preloadCanvas:MovieClip;
	private var positions:Object;
	private var totalImages:Number = 0;
	
	public function Skin(xml:XMLNode)
	{
		this.xml = xml;
		broadcaster = new EventBroadcaster(this);
		styleSheet = new StyleSheet();
		images = new Object();
		positions = new Object();
		for (var i : Number = 0; i < xml.childNodes.length; i++)
		{
			var node:XMLNode = xml.childNodes[i];
			switch (node.nodeName)
			{
				case "style": 
					if (!styleSheet.parseCSS(node.firstChild.nodeValue))
						trace("WARNING: CSS provided in skin file did not parse");
					break;
				case "img":
					images[node.attributes.element] = node.attributes.src;
					totalImages++;
					break;
				case "position":
					var obj:Object = new Object();
					obj._x = Number(node.attributes._x);
					obj._y = Number(node.attributes._y);
					obj.copyX = Number(node.attributes.copyX);
					obj.copyY = Number(node.attributes.copyY);
					obj.w = Number(node.attributes.w) ;
					obj.h = Number(node.attributes.h);
					positions[node.attributes.element] = obj;
					break;
				default:
					trace("WARNING: Skin constructor: unknown node " + node.nodeName + " found");
			}
		}
	}

	public function preloadAssets(Void):Void
	{
		if (loadQueue)
		{
			delete loadQueue;
		}
		loadQueue = new LoadQueue();
		loadQueue.addEventListener("onQueueEmpty", this, "onPreloadComplete");
		
		var depth:Number = _root.getNextHighestDepth();
		preloadCanvas = _root.createEmptyMovieClip("__SkinPreload" + depth, depth);
		preloadCanvas._x = preloadCanvas._y = -1 * (Stage.width + Stage.height);
		preloadCanvas._visible = false;
		var t = 0;		
		for (var i in images)
		{			
			t++;
			var percentOfImage:Number = ((93*t)/totalImages)+6;			
			loadQueue.addItem(new LoadMovieClip(images[i], newClipOn(preloadCanvas),percentOfImage));			
			
		}
		loadQueue.startQueue();
	}
	//clips not visible onLoad visible, clips on parent invisible onload => not visible
	private function newClipOn(target:MovieClip):MovieClip
	{
		var td = target.getNextHighestDepth();
		return target.createEmptyMovieClip("__clip_" + td , td);
	}
	private function onPreloadComplete(Void):Void
	{
		preloadCanvas.removeMovieClip();
		delete preloadCanvas;
		broadcastEvent("onAssetsPreloaded");
	}
	
	/**
	 * @return a URL to the image resource for the element requested
	 */
	public function getPositionsForElement(elementName:String):Object
	{
		return positions[elementName];
	}
	
	
	
	
	/**
	 * @return a URL to the image resource for the element requested
	 */
	public function getImageForElement(elementName:String):String
	{
		return images[elementName];
	}
	
	
	public function getStyleSheet(Void):StyleSheet
	{
		return styleSheet;
	}
	
	public function styleTextField(tf:TextField):Void
	{
		tf.styleSheet = styleSheet;
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
		return "[Skin]";
	}

}