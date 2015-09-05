import com.avVenta.events.BroadcastableMovieClip;
import com.avVenta.loading.LoadingItem;

class com.gmc.gallery.ButtonView extends BroadcastableMovieClip {
	
	// 1. Static Private Properties 
	private static var IMAGE_LINE:String = "imgLine";
	private static var IMAGE_EXTERNAL:String = "imageExt"
	private static var IMAGE_INTERNAL:String = "imageInt"
	
	// 2. Private Properties 
	private var lastModel:String = "";
	private var isExternal:Boolean = true;
	private var imgIntPath:String = "";
	private var imgExtPath:String = "";
	
	// 3. Static Public Properties 
	// 4. Public Properties 
	
	// 5. Constructor 
	function ButtonView(Void) {
		//trace ("ButtonView created");
	}
	// 6. Static Private Methods 
	// 7. Private Methods 	
	private function loadImages(Void):Void {
		
		if (this.isExternal) {
			var itemLoad:LoadingItem = new LoadingItem(this.imgIntPath, this[IMAGE_INTERNAL], "movieclip", 100);
			itemLoad.load()
		} else {
			var itemLoad:LoadingItem = new LoadingItem(this.imgExtPath, this[IMAGE_EXTERNAL], "movieclip", 100);
			itemLoad.load()
		}
	}
	
	// 8. Static Public Methods 	
	
	// 9. Public Methods
	public function onPress(Void):Void {
		this.isExternal = !this.isExternal;
		this.gotoAndStop(((this.isExternal)? "internal": "external"));
		this.loadImages();
		this.broadcastEvent ("onPress", this.isExternal);
	}
	
	public function setImages(/*carModel:String, */imgExtPath:String, imgIntPath:String) {
		this.imgExtPath = imgExtPath;
		this.imgIntPath = imgIntPath;
		this.loadImages();
	}
	
	
	// 10. Getter/Setter Methods
}