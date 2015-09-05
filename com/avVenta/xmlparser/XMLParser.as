import com.avVenta.events.*;
import com.avVenta.debug.*;

/**
 * This class loads and parses XML into several formats.
 *
 * @author Marco A. Alvarado
 * @version 1.0.2 2007-04-24
 */
class com.avVenta.xmlparser.XMLParser extends XML implements IBroadcastable {
	
	// constants
	static private var DEBUG 							= true;
	static private var FORMAT_ARRAY_TREE	= 0;		// parses a tree of arrays

	static public var EVENT_PARSED	= "onParsed";

	// variables
	private var broadcaster:EventBroadcaster;
	private var debugger:DebugController;
	private var format:Number = FORMAT_ARRAY_TREE;
	
	public var name:String;
	public var tree:Array;
	
//==================================================
// Generic methods

	/**
	 * Constructor.
	 */
	public function XMLParser() {
		broadcaster = new EventBroadcaster();
		debugger = DebugController.getInstance();
		name = "XMLParser";
		ignoreWhite = true;
		onLoad = parseData;
	}

//==================================================

	/**
	 *
	 */
	public function parseData(success:Boolean)
	{
		if (!success) return;
		
		switch(format)
		{
			case FORMAT_ARRAY_TREE:
trace("PARSED XML: Array {");
				tree = parseArrayTree(this.firstChild, "  ");
trace("}");
				break;
		}
		
		broadcastEvent(EVENT_PARSED, tree);
	}

	/**
	 *
	 */
	public function parseArrayTree(node:XMLNode, tab:String):Array {
// Assigns attributes to first element:
		var n:Array = new Array;
		n.name = node.nodeName;
trace(tab+"name: "+n.name);
		n[0] = new Object();

trace(tab+"0: Object {");
		for (var a:String in node.attributes) {
			n[0][a] = node.attributes[a];
trace(tab+"  "+a+": "+n[0][a]);
		}
trace(tab+"}");

		if (node.childNodes.length <= 0) {
			n.value = node.nodeValue;
trace(tab+"value: "+n.value);
		} else {
// Recursively parses sub-nodes in following elements:
			var i:Number = 0;
			
			for (var c:String in node.childNodes) {
trace(tab+(i+1)+": Array {");
				n[i+1] = parseArrayTree(node.childNodes[i], tab+"  ");
trace(tab+"}");
				i++;
			}
		}
		
		return n;
	}

	/**
	 *
	 */
	public function findNodeInArrayTree(n:Array, name:String):Array {
		var i:Number = 0;
		var a:Array;
		
		for (i = 1; i < n.length; i++) {
			if (n[i].name == name) return n[i];
		}

		for (i = 1; i < n.length; i++) {
			a = findNodeInArrayTree(n[i], name);
			if (a != null) return a;
		}
		
		return null;
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