import com.avVenta.loading.LoadingItem;					// Class which instances loads elements from a path source
import com.avVenta.events.BroadcastableMovieClip;		// Allows events
import flash.display.BitmapData;						// Allows to created snapshot in images
import mx.transitions.Tween;
import mx.transitions.easing.*;							// Implementing transitons between images changed

class com.gmc.gallery.LargeImage extends BroadcastableMovieClip {
	// 1. Static Private Properties 
	private static var IMAGE_MOVIE:String = "imageContent";	// MovieClip where the image will be loaded
	private static var IMAGE_FORE:String = "foreImage";		// MovieClip to make a snapShot when the image is loaded
	private static var MIN_ALPHA:Number = 40;
	private static var VIDEO:String = "videoComponent";		// If what the 
	
	// 2. Private Properties 
	private var currentImage:String = "";				// Current image's name. It's used to load the last image just once
	private var transition:Tween;
	
	// 3. Static Public Properties 
	static var SymbolName:String = "__Packages.com.gmc.gallery.LargeImage";
	static var SymbolLinked = Object.registerClass(SymbolName, LargeImage);
	
	// 4. Public Properties 
	public static var IMAGE_LOADED:String = "onImageLoaded";
	
	// 5. Constructor 
	/**
	 * Constructor It does nothing
	 *
	 */ 
	function LargeImage(Void) {
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
		this.takeSnapshot(this[IMAGE_MOVIE], this[IMAGE_FORE]);
		this.broadcastEvent(IMAGE_LOADED, null);
	}
	
	private function takeSnapshot(source:MovieClip, target:MovieClip){
		var myBitmap:BitmapData = new BitmapData(source._width,source._height,true,0x00FFFFFF);
		myBitmap.draw(source);
		target.attachBitmap(myBitmap,1);		
	}		
	
	// 8. Static Public Methods 	
	
	// 9. Public Methods		
	public function loadImage(imageData:Object):Void {
		if (this.currentImage != imageData["source"]) {			
			//if (imageData.type == Item.TYPES.picture) {
				var itemLoad:LoadingItem = new LoadingItem(imageData["source"], this[IMAGE_MOVIE], "movieclip", 100);			
				itemLoad.addEventListener("onLoad", this, "onImageLoaded");
				itemLoad.load();
			//}
			this.currentImage = imageData["source"];
		} 
	}
	
	public function unloadCurrentImage(Void):Void {
		if (this.currentImage != "") {
			this.currentImage = "";
			this.transition = new Tween(this, "_alpha", Regular.easeOut, 100, 0, 2, true);
		}
	}
	
	// 10. Getter/Setter Methods
}