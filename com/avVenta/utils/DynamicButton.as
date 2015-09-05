import com.avVenta.loading.LoadingItem;
import com.avVenta.events.BroadcastableMovieClip;		// Allows events

/**
 * This class implements an image buttons. Every status is display with an image
 * @author Dennis Lizano Mendez
 */
class com.avVenta.utils.DynamicButton extends BroadcastableMovieClip {
	
	//1. Static Private Properties
	private static var IMG_UP:String = "/images/common/dynamicbutton/btn_open.gif";
	private static var IMG_OVER:String = "/images/common/dynamicbutton/btn_close.gif";
	private static var IMG_DOWN:String = "/images/common/dynamicbutton/btn_close.gif";	
	
	// EVENTS:	
	public static var ON_UP:String  = "onDown";
	public static var ON_OVER:String  = "onOver";	
	public static var ON_PRESS:String  = "onPress";
	
	//2. Private Properties 
	//private var button:MovieClip = null;
	private var isNormal:Boolean = false;			// Indicates if this button behavior is like any other button (or if every status is controled "manualy")
	private var imgUp:MovieClip = null;
	private var imgOver:MovieClip = null;
	private var imgDown:MovieClip = null;	
	
	//3. Static Public Properties 
	public static var STATUS:Object = {up:"up", over:"over", down:"down"};
	static var SymbolName:String = "__Packages.com.avVenta.utils.DynamicButton";
	static var SymbolLinked = Object.registerClass(SymbolName, DynamicButton);
	
	//4. Public Properties 
	//5. Constructor 
	/**
	 * Contructor
	 * @param iSNormal Boolean Indicates if this button behavior is like any other button (or if every status is controled "manualy")
	 * @param imgUp String Relative path of the up status image
	 * @param imgOver String Relative path of the over status image
	 * @param imgDown String Relative path of the down status image
	 * @param xPos Number x axis position
	 * @param yPos Number y axis position
	 */
	public function DynamicButton(isNormal:Boolean, imgUp:String, imgOver:String, imgDown:String, xPos:Number, yPos:Number) {		
		this.imgOver = this.createEmptyMovieClip("imgOver", this.getNextHighestDepth()); 
		this.imgDown = this.createEmptyMovieClip("imgDown", this.getNextHighestDepth());
		this.imgUp = this.createEmptyMovieClip("imgUp", this.getNextHighestDepth());
		
		var itemImg1:LoadingItem = new LoadingItem(((imgDown != "" && imgDown != null)? imgDown:IMG_DOWN), this.imgDown, "movieclip", 100);
		//itemImg1.addEventListener("onLoad", this, "onItemLoaded");
		itemImg1.load();
		
		var itemImg2:LoadingItem = new LoadingItem(((imgOver != "" && imgOver != null)? imgOver:IMG_OVER), this.imgOver, "movieclip", 100);
		//itemImg1.addEventListener("onLoad", this, "onItemLoaded");
		itemImg2.load();
		
		var itemImg3:LoadingItem = new LoadingItem(((imgUp != "" && imgUp != null)? imgUp:IMG_UP), this.imgUp, "movieclip", 100);
		//itemImg1.addEventListener("onLoad", this, "onItemLoaded");
		itemImg3.load();		
	
	}
	//6. Static Private Methods 
	//7. Private Methods 
	//8. Static Public Methods 
	//9. Public Methods 
	// If it's a normal button
	public function onRollOver():Void {
		if (this.isNormal) {
			this.imgUp._visible = false;
			this.imgOver._visible = true;
			this.imgDown._visible = false;			
		}
		this.broadcastEvent(ON_OVER);
	}
	
	public function onRollOut():Void {
		if (this.isNormal) {
			this.imgUp._visible = true;
			this.imgOver._visible = false;
			this.imgDown._visible = false;
		}
		this.broadcastEvent(ON_UP);
	}
	
	public function onPress():Void {
		// show Down image?
		this.broadcastEvent(ON_PRESS);
	}
	
	// User status controls
	/**
	 * Sets the status to the button. If it is normal (isNormal = true) this status won't be permanent
	 * @param status 
	 */
	public function defineStatus (status:String) {
		this.imgUp._visible = false;
		this.imgOver._visible = false;
		this.imgDown._visible = false;
		switch (status) {
			case STATUS.up:
				this.imgUp._visible = true;
				break;
				
			case STATUS.over:
				this.imgOver._visible = true;
				break;
				
			case STATUS.down:
				this.imgDown._visible = true;
				break;
		}
	}
	
	//10. Getter/Setter Methods	
}