import com.avVenta.events.*;
import com.avVenta.debug.*;

/**
 * This class is an event-driven state machine for deterministic systems (i.e. animations).
 *
 * @author Marco A. Alvarado
 * @version 1.0.0 2007-08-07
 */
class com.avVenta.states.StateMachine implements IBroadcastable {

//==================================================
// Constants

	static private var DEBUG 							= true;
	static private var MODE_INMEDIATE			= 0;
	static private var MODE_DELAY					= 1;
	static private var MODE_LOAD_CLIP			= 2;
	
	static public var UPDATE_STATE_EVENT	= 'onUpdateState';
	static public var ENTER_STATE_EVENT		= 'onEnterState';
	static public var EXIT_STATE_EVENT		= 'onExitState';

//==================================================
// Variables

	private var broadcaster:EventBroadcaster;
	private var debugger:DebugController;
	private var loader:MovieClipLoader;
	
	private var curState:String;
	private var curData:Object;
	private var nextState:String;
	private var nextData:Object;
	private var nextMode:Number;
	private var delayTime:Number;			// milliseconds
	private var loadCount:Number;

//==================================================
// Generic methods

	/**
	 * Constructor.
	 */
	public function StateMachine(iniState:String) {
		broadcaster = new EventBroadcaster();
		debugger = DebugController.getInstance();
		loader = new MovieClipLoader();
		loader.addListener(this);
		curState = iniState;
		nextState = iniState;
		nextMode = MODE_INMEDIATE;
		delayTime = 0;
		loadCount = 0;
	}

//==================================================
// Events
	
	/**
	 * onLoadInit()
	 */
	public function onLoadInit() {
		loadCount--;
	}

//==================================================
// State control methods

	/**
	 * setState()
	 */
	public function setState(newState:String, data:Object) {
		nextState = newState;
		nextData = data;
		nextMode = MODE_INMEDIATE;
	}
	
	/**
	 * setStateAfterDelay()
	 */
	public function setStateAfterDelay(newState:String, milliseconds:Number, data:Object) {
		nextState = newState;
		nextData = data;
		nextMode = MODE_DELAY;
		if (milliseconds == null) milliseconds = 0;
		delayTime = (new Date()).getTime()+milliseconds;
	}
	
	/**
	 * setStateAfterLoadClip()
	 */
	public function setStateAfterLoadClip(newState:String, url:String, target:MovieClip, data:Object) {
		nextState = newState;
		nextData = data;
		nextMode = MODE_LOAD_CLIP;
		target.createEmptyMovieClip("mc", 1);
		loader.loadClip(url, target.mc);
		loadCount++;
	}
	
	/**
	 * update()
	 * @comment Call this method frequently to update the state machine.
	 */
	public function update() {
		
		if (curState != nextState) {
			var next:Boolean = false;
			
			switch(nextMode) {
				case MODE_INMEDIATE:
					next = true;
					break;
					
				case MODE_DELAY:
					next = (delayTime <= (new Date()).getTime());
					break;
					
				case MODE_LOAD_CLIP:
					next = (loadCount == 0);
					break;
			}
			
			if (next) {
// broadcast exit state event
				if (curData == null) curData = new Object();
				curData.state = curState;
				broadcastEvent(EXIT_STATE_EVENT, curData);

// switch state
				curState = nextState;
				curData = nextData;
				
// broadcast enter state event
				if (curData == null) curData = new Object();
				curData.state = curState;
				broadcastEvent(ENTER_STATE_EVENT, curData);
			}
		}
		
// broadcast update state event
		broadcastEvent(UPDATE_STATE_EVENT, {state: curState});
	}
	
//==================================================
// Event methods

	/**
	 *
	 */
	public function addEventListener(eventName:String, listener:Object, methodName:String):Void {
		broadcaster.addEventListener(eventName,listener,methodName);
	}

	/**
	 *
	 */
	public function broadcastEvent(eventName:String, data:Object):Void {
		broadcaster.broadcastEvent(eventName,this,data);
	}

	/**
	 *
	 */
	public function removeEventListener(eventName:String, listener:Object, methodName:String):Void {
		broadcaster.removeEventListener(eventName,listener,methodName);
	}
}