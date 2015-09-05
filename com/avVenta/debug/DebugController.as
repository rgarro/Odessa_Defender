import com.avVenta.events.*;

/**
 * This singleton class controls the message debugging system.
 *
 * Other classes must call getInstance to retrieve the singleton. Every
 * debugging message in the application must be reported to this system
 * using trace().
 *
 * @author Marco A. Alvarado
 * @version 1.0.0 2007-01-18
 * @event  onTrace  Reports the debugging message.
 * @event  onCommand  Orders the execution of a command.
 */
class com.avVenta.debug.DebugController {

	// constants
	static public var EVENT_ON_TRACE:String		= "onTrace";
	static public var EVENT_ON_COMMAND:String	= "onCommand";
	static public var SYSTEM_TRACE:Boolean		= true;
	
	// private vars
	static private var instance:DebugController;
	private var broadcaster:EventBroadcaster;
	
	public var name:String;

	/**
	 * Constructor.
	 */
	public function DebugController() {
		name = "DebugController";

		broadcaster = new EventBroadcaster();
	}
	
	/**
	 * Gets the singleton instance.
	 */
	static public function getInstance():DebugController {
		if (instance == null)
			instance = new DebugController();
		return instance;
	}
	
	/**
	 * Broadcasts a debugging message.
	 *
	 * @param  source  The object that traces the message. It should have a name property.
	 * @param  message  The debugging message.
	 * @event  onTrace  Sends an object containing source and message.
	 */
	public function trace(source:Object, message:String)
	{
		if (SYSTEM_TRACE) 
			trace(source.name+': '+message);
		broadcastEvent(EVENT_ON_TRACE, source, message);
	}
	
	/**
	 * Broadcasts a command message. The command must be parsed by the listener.
	 *
	 * @param  source  The object that sends the message.
	 * @param  message  The command message.
	 * @event  onTrace  Sends an object containing source and message.
	 */
	public function command(source:Object, message:String)
	{
		if (SYSTEM_TRACE) 
			trace(source+': '+message);
		broadcastEvent(EVENT_ON_COMMAND, source, message);
	}
	
	/**
	 * Assigns a listener to the given event.
	 *
	 * @param  event  String  The event to listen.
	 * @param  listener  Object  The object that will receibe the event.
	 */
	public function addListener(event:String, listener:Object):Void {
		broadcaster.addEventListener(event, listener);
	}
	
	/**
	 * Passes the data to the listeners of the given event.
	 *
	 * @param  event  String  The event to trigger.
	 * @param  source  Object  The object that generated the event.
	 * @param  data  Object  The data passed to the listener.
	 */
	public function broadcastEvent(event:String, source:Object, data:Object):Void {
		broadcaster.broadcastEvent(event, source, data);
	}
	
	/**
	 * Unassigns the listener of the given event.
	 *
	 * @param  event  String  The event listened.
	 * @param  listener  Object  The object that receibes the event.
	 */
	public function removeListener(event:String, listener:Object):Void {
		broadcaster.removeEventListener(event, listener);
	}
}