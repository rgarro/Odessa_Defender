/**
 * Interface used to inforce proper inheritance of the EventBroadcaster through composition.
 * 
 * @version 1.0.0 2007-02-16
 */

interface com.avVenta.events.IBroadcastable {
	
	public function addEventListener(eventName:String, listener:Object, methodName:String):Void;
	
	public function broadcastEvent(eventName:String, data:Object):Void;
	
	public function removeEventListener(eventName:String, listener:Object, methodName:String):Void;
	
}