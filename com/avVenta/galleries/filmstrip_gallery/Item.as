import com.avVenta.loading.LoadingItem;					// For loading thumbnails images
import com.avVenta.events.BroadcastableMovieClip;		// Allows events

/**
 *
 * Each one of the thumbnails in the image lines (filmstrip)
 *
 * @author Dennis Lizano Méndez
 * @version 0.0.1 2007-06-27
 * @todo Missed an image administrator that keeps loaded images instead of reload them after been used
 * 
 */
class com.gmc.gallery.Item extends BroadcastableMovieClip {	
	// 1. Static Private Properties
	private static var IMAGE_MOVIE:String = "image";	// Component for loading images name
	private static var IMAGE_VIDEO:String = "video";	// Imaged showed when its a video
	private static var BORDER_MOVIE:String = "border";	// Movie
	private static var MIN_ALPHA:Number = 60;
		
	// 2. Private Properties 
	private var target:MovieClip = null;
	private var indexPos:Number = -1;				  // Thumbnail number in the galley menu
	private var imageToLoad:String = "";			  // Large image to load
	private var type:String = "";
	private var title:String = "";
	private var extraData:Object = null;			  // Not included data
	private var pressed:Boolean = false;
	
	static var SymbolName:String = "__Packages.com.gmc.gallery.Item";
	static var SymbolLinked = Object.registerClass(SymbolName, Item);

		
	// 3. Static Public Properties 
	public static var TYPES:Object = {video: "VIDEO", picture: "PICTURE", movie: "MOVIECLIP"};
	
	// 4. Public Properties 	
	// 5. Constructor 
	public function Item() {		
		this[BORDER_MOVIE]._visible = false;
	}
	
	// 6. Static Private Methods 
	
	// 7. Private Methods 
	private function onItemLoaded(Void):Void {
		this[IMAGE_VIDEO]._x = (this._width - this[IMAGE_VIDEO]._width) / 2;
		this[IMAGE_VIDEO]._y = (this._height - this[IMAGE_VIDEO]._height) / 2;
		this.broadcastEvent("itemLoaded");		
	}
	
	private function setBorderVisibility (visible:Boolean) {		
		/*if (this[BORDER_MOVIE] == null) {			
			var border = this.createEmptyMovieClip(BORDER_MOVIE, this.getNextHighestDepth());
			var borderSize:Number = 1;
			
			border.lineStyle(2, 0x640314, 100, 255, "square");
			border.moveTo(0 + borderSize, 0 + borderSize);
			border.lineTo(this[IMAGE_MOVIE]._width - borderSize, 0 + borderSize);
			border.lineTo(this[IMAGE_MOVIE]._width - borderSize, this[IMAGE_MOVIE]._height - borderSize);
			border.lineTo(0 + borderSize, this[IMAGE_MOVIE]._height - borderSize);
			border.lineTo(0 + borderSize, 0 + borderSize);
		}
		this[BORDER_MOVIE]._visible = visible;*/
	}
	
	// 8. Static Public Methods 
	
	// 9. Public Methods
	public function onLoad():Void {		
		//var temp = this.createEmptyMovieClip(IMAGE_MOVIE, this.getNextHighestDepth());		
		//this.createEmptyMovieClip(IMAGE_VIDEO, this.getNextHighestDepth());		
	}
	
	public function onRollOver():Void {
		// Event: newFocus
		this.setBorderVisibility(true);
		this.broadcastEvent("newFocus", {index:this.indexPos, byMouse:true});
	}
	
	public function onRollOut():Void {
		if (!pressed) {
			//this[IMAGE_MOVIE]._alpha = 100;
			this[BORDER_MOVIE]._visible = false;
		}
		this.broadcastEvent("lostFocus", this.indexPos);
	}
	
	public function onPress() {
		this.selectItem(true);
	}
	
	/**
	 * @param isByClick Boolean it indicates if the image was selected by click or automaticly
	 */
	public function selectItem(isByClick:Boolean):Void {
		this[BORDER_MOVIE]._visible = true;
		//this[IMAGE_MOVIE]._alpha = MIN_ALPHA;
		this.setBorderVisibility(true);
		this.broadcastEvent("newFocus", {index:this.indexPos, byMouse:isByClick});		
		var objToSend:Object = { source	: this.imageToLoad,  title: this.title, index: this.indexPos, type: this.type, extraData: this.extraData, isByClick: isByClick, itemData:{x:this._x, width:this._width}};
		this.broadcastEvent("itemSelected", objToSend);
		pressed = true;
	}
	
	public function loadThumbnail(pathSource:String, imageToLoad:String, title:String, type:String, extraData:Object):Void {
		this.createEmptyMovieClip(IMAGE_MOVIE, this.getNextHighestDepth());
		//this.createEmptyMovieClip(IMAGE_VIDEO, this.getNextHighestDepth());	
		
		//this.attachMovie("videoIcon",IMAGE_VIDEO, this.getNextHighestDepth());		
		this.imageToLoad = imageToLoad;		
		this.title = title;
		this.type = type.toUpperCase();
		this.extraData = extraData;
		this[IMAGE_MOVIE]._quality = "BEST";
		
		//this[IMAGE_VIDEO]._visible  = (type == TYPES.video)? true : false;
		var itemLoad:LoadingItem = new LoadingItem(pathSource, this[IMAGE_MOVIE], "movieclip", 100);
		itemLoad.addEventListener("onLoad", this, "onItemLoaded");
		itemLoad.load();
	}
	
	public function anotherSelected(Void):Void {
		this.pressed = false;
		this[IMAGE_MOVIE]._alpha = 100;
		this[BORDER_MOVIE]._visible = false;
	}
			
	// 10. Getter/Setter Methods
	// -----  Getters
	public function getIndexPosition(Void):Number {
		return this.indexPos;
	}
	
	// -----  Setters
	public function setIndexPosition(indexPos:Number):Void {
		this.indexPos = indexPos;
	}
}