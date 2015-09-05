import com.avVenta.events.IBroadcastable;
import com.avVenta.events.EventBroadcaster;
import flash.display.BitmapData;
import flash.geom.Matrix;


/**
 * @author jose.solano
 */
class com.avVenta.skin.SkinElement extends MovieClip implements IBroadcastable{
	
	static public var LINKAGE:String = "__Packages.com.avVenta.skin.SkinElement";
	static private var REGISTER:Object = Object.registerClass(LINKAGE, SkinElement);
	
	private var broadcast:EventBroadcaster;
	
	
	function SkinElement(){
		broadcast = new EventBroadcaster(this);
		
	}
	
	public function buildSkinElement(linkageId:String, mcLibrary:MovieClip):Void{		
		var w:Number = mcLibrary[linkageId]._width;
		var h:Number = mcLibrary[linkageId]._height;
		
		var oBitmap:BitmapData = new BitmapData(w, h, true, 0x000000);
		oBitmap.draw(mcLibrary[linkageId],new Matrix());		
		this.attachBitmap(oBitmap, this.getNextHighestDepth());
	}
	
	public static function create(container:MovieClip, name:String, depth:Number, initObj:Object):SkinElement{		
		if(!depth)depth = container.getNextHighestDepth();		
		return SkinElement(container.attachMovie(SkinElement.LINKAGE, name, depth, initObj));		
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