import com.avVenta.loading.LoadingItem;					// Class which instances loads elements from a path source
import com.avVenta.events.BroadcastableMovieClip;		// Allows events
import com.avVenta.utils.MediaViewer;
import flash.display.BitmapData;						// Allows to created snapshot in images
import mx.transitions.Tween;
import mx.transitions.easing.*;							// Implementing transitons between images changed
import com.gmc.gallery.Item;

class com.gmc.gallery.LargeItem extends BroadcastableMovieClip {
	// 1. Static Private Properties 
	private static var IMAGE_MOVIE:String = "imageContent";	// MovieClip where the image will be loaded
	private static var IMAGE_FORE:String = "foreImage";		// MovieClip to make a snapShot when the image is loaded
	private static var MIN_ALPHA:Number = 40;
	private static var VIDEO_LOADER:String = "videoComponent";		// If what the 
	private static var VIEWER:String = "vdLoader";
	
	// 2. Private Properties 
	private var currentImage:String = "";				// Current image's name. It's used to load the last image just once
	private var transition:Tween;
	private var currentType:String = "";
	private var width:Number = 0;						// width that should be taken into account (not large item size)
	private var height:Number = 0;						// height that should be taken into account
	
	// 3. Static Public Properties 
	static var SymbolName:String = "__Packages.com.gmc.gallery.LargeItem";
	static var SymbolLinked = Object.registerClass(SymbolName, LargeItem);
	
	// 4. Public Properties 
	public static var IMAGE_LOADED:String = "onImageLoaded";
	
	// 5. Constructor 
	/**
	 * Constructor It does nothing
	 *
	 */ 
	function LargeItem(Void) {
		this.createEmptyMovieClip(IMAGE_MOVIE, this.getNextHighestDepth());
		this.createEmptyMovieClip(IMAGE_FORE, this.getNextHighestDepth());		
	}
	
	// 6. Static Private Methods 
	// 7. Private Methods 
	/**
	 * 
	 * @event "onLoad" handled when the large photo is loaded
	 */
	private function onImageLoaded(source:MovieClip) {
		this.transition = new Tween(this, "_alpha", Regular.easeOut, MIN_ALPHA, 100, 1, true);
		this.broadcastEvent(IMAGE_LOADED, null);
	}
	
	// 8. Static Public Methods 	
	
	// 9. Public Methods		
	public function loadItem(imageData:Object):Void {
		
		if (this.currentImage != imageData["source"]) {			
			switch (imageData.type) {
				case Item.TYPES.video:					
					if (this[VIEWER] == null) {
						var viewer:MovieClip = this.attachMovie("videoObj", VIEWER, this.getNextHighestDepth());
						viewer.setVideoObj("vid");					
						viewer.addListener(this);
					}
					if (this.currentType != Item.TYPES.video) {
						this.transition = new Tween(this[IMAGE_MOVIE], "_alpha", Regular.easeOut, 100, 0, 2, true);
						this.transition = new Tween(this[VIEWER], "_alpha", Regular.easeOut, 0, 100, 2, true);
					}
					this.currentType = Item.TYPES.video;
					this[VIEWER].setURL(imageData["source"]);					
					break;
				
				case Item.TYPES.picture :
				default:
					if (this.currentType != Item.TYPES.picture) {
						this.transition = new Tween(this[IMAGE_MOVIE], "_alpha", Regular.easeOut, 0, 100, 2, true);
						this["vdLoader"].stop();
						this.transition = new Tween(this[VIEWER], "_alpha", Regular.easeOut, 100, 0, 2, true);
					}
					this.currentType = Item.TYPES.picture;
					var itemLoad:LoadingItem = new LoadingItem(imageData["source"], this[IMAGE_MOVIE], "movieclip", 100);			
					itemLoad.addEventListener("onLoad", this, "onImageLoaded");
					itemLoad.load();
					break;
			}
			this.currentImage = imageData["source"];
		} 
	}
	
	/**
	 * Centers a video when it's loaded
	 * @event onBufferFull broadcasted by the movie viewer (this[VIEWER])
	 */
	public function onBufferFull() {
		this[VIEWER].autoSize();
		var border = ((this.width - this[VIEWER].getWidth()) > 0)? (this.width - this[VIEWER].getWidth()) / 2: 0;
		this[VIEWER]._x = border;
		border = ((this.height - this[VIEWER].getHeight()) > 0)? (this.height - this[VIEWER].getHeight()) / 2: 0;
		this[VIEWER]._y = border;
		//trace  ();
	}
	
	public function setSize(width:Number, height:Number) {
		this.width = width;
		this.height = height;
	}
	
	public function unloadCurrentImage(Void):Void {
		//if (this.currentImage != "") {
		//	this.currentImage = "";
			this.transition = new Tween(this, "_alpha", Regular.easeOut, 100, 0, 2, true);
		//}
	}
	
	// 10. Getter/Setter Methods
}