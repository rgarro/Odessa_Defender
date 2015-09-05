import com.avVenta.events.*;
import com.avVenta.loading.LoadingItem;

class com.avVenta.utils.DynamicScrollBar extends BroadcastableMovieClip{

	public static var UPDATEPOSITION:String = "onUpdatePosition";
	
	private var topY:Number;
	private var bottomY:Number;
	private var step:Number;
	private var distance:Number; 
	private var position:Number;

	private var btnUpArrow:MovieClip;
	private var btnDownArrow:MovieClip;
	private var mcDragger:MovieClip;
	private var mcBackground:MovieClip;
	
	// Added by Dennis Lizano Mendez 07/09/2007
	public static var SymbolName:String = "__Packages.com.avVenta.utils.DynamicScrollBar";
	public static var SymbolLinked = Object.registerClass(SymbolName, DynamicScrollBar);	
	private static var IMG_UP:String = "/images/common/DynamicScrollBar/btn_up.gif";
	private static var IMG_DRAGGER:String = "/images/common/DynamicScrollBar/btn_scroll.gif";
	private static var IMG_DOWN:String = "/images/common/DynamicScrollBar/btn_down.gif";
	private static var IMG_BACKG:String = "/images/common/DynamicScrollBar/scroll_bar.gif";
	
	private var height:Number = 0;
	private var imgLoaded:Number = 0;			// Counter for the number of images loaded
	
	//public var updatePosition:Function;
	public function DynamicScrollBar(){
		this.defineFunction()
	}
	
	// Added by Dennis Lizano Mendez 07/09/2007	
	public function setImages (height:Number, imgBtnUp:String, imgBtnDown:String, imgDragger:String, imgBack:String) {
		//trace (imgBtnUp);
		this.imgLoaded = 0;
		this.mcBackground = this.createEmptyMovieClip("mcBackground", this.getNextHighestDepth()); 
		this.btnUpArrow = this.createEmptyMovieClip("btnUpArrow", this.getNextHighestDepth()); 
		this.btnDownArrow = this.createEmptyMovieClip("btnDownArrow", this.getNextHighestDepth()); 
		this.mcDragger = this.createEmptyMovieClip("mcDragger", this.getNextHighestDepth()); 		
		
		var itemImg0:LoadingItem = new LoadingItem(((imgBack != "" && imgBack != null)? imgBack:IMG_BACKG), this.mcBackground, "movieclip", 100);
		itemImg0.addEventListener("onLoad", this, "onItemLoaded");
		itemImg0.load();
		var itemImg1:LoadingItem = new LoadingItem(((imgBtnUp != "" && imgBtnUp != null)? imgBtnUp:IMG_UP), this.btnUpArrow, "movieclip", 100);
		itemImg1.addEventListener("onLoad", this, "onItemLoaded");
		itemImg1.load();
		var itemImg2:LoadingItem = new LoadingItem(((imgBtnDown != "" && imgBtnDown != null)? imgBtnDown:IMG_DOWN), this.btnDownArrow, "movieclip", 100);
		itemImg2.addEventListener("onLoad", this, "onItemLoaded");
		itemImg2.load();
		var itemImg3:LoadingItem = new LoadingItem(((imgDragger != "" && imgDragger != null)? imgDragger:IMG_DRAGGER), this.mcDragger, "movieclip", 100);
		itemImg3.addEventListener("onLoad", this, "onItemLoaded");
		itemImg3.load();
		this.height = height;		
		this.step = 2;
		
		/*if (_root["textText"] == null)
			_root.createTextField("textText", _root.getNextHighestDepth(), 450,450, 150,150);
		var textO = _root["textText"];
		textO.autoSize = true
		textO.text += " - loading scrollImg: " + ((imgDragger != "" && imgDragger != null)? imgDragger:IMG_DRAGGER);*/
	}
	
	
	// Added by Dennis Lizano Mendez
	/**
	 * Initilizes the component once all the images were opened
	 */
	private function onItemLoaded() {
		
		
		this.imgLoaded++;				
		
		if (imgLoaded == 4) {
			this.init(this.height);		
			this.defineFunction();
		}		
		// Define the step depending on the component that it's scrolling		
	}	
	
	private function setScrollLength(scrollHeight:Number) {
		this.step = this.height / scrollHeight;
	}
	
	// Added by Dennis Lizano Mendez 07/09/2007	
	private function defineFunction() {
		this.btnUpArrow.onPress = function(){
			this.onEnterFrame = function(){
				var newPos = this._parent.mcDragger._y - this._parent.step; 				
				if (newPos >= this._parent.topY){
					this._parent.mcDragger._y = newPos;
					this._parent.position = ((this._parent.mcDragger._y - this._parent.topY) * 100) / this._parent.distance;
					//this._parent.updatePosition(this._parent.position);
					this._parent.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this._parent.position});
				}else{
					var moved:Boolean = false;
					while ((++newPos < this._parent.mcDragger._y)&&(!moved)){
						if (newPos >= this._parent.topY){
							this._parent.mcDragger._y = newPos;
							moved = true;
						}
					}
					if (moved){
						this._parent.position = ((this._parent.mcDragger._y - this._parent.topY) * 100) / this._parent.distance;
						//this._parent.updatePosition(this._parent.position);		
						this._parent.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this._parent.position});
					}
				}
			}
		}
		
		this.btnUpArrow.onRelease = function(){
			delete this.onEnterFrame;
		}
		
		this.btnUpArrow.onReleaseOutside = function(){
			delete this.onEnterFrame;
		}
		
		
		this.btnDownArrow.onPress = function(){
			this.onEnterFrame = function(){
				var newPos = this._parent.mcDragger._y + this._parent.step; 
				if (newPos <= this._parent.bottomY){
					this._parent.mcDragger._y = newPos;
					this._parent.position = ((this._parent.mcDragger._y - this._parent.topY) * 100) / this._parent.distance;
					//this._parent.updatePosition(this._parent.position);
					this._parent.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this._parent.position});
				}else{
					var moved:Boolean = false;
					while ((--newPos > this._parent.mcDragger._y)&&(!moved)){
						if (newPos <= this._parent.bottomY){
							this._parent.mcDragger._y = newPos;
							moved = true;
						}
					}
					if (moved){
						this._parent.position = ((this._parent.mcDragger._y - this._parent.topY) * 100) / this._parent.distance;
						//this._parent.updatePosition(this._parent.position);		
						this._parent.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this._parent.position});
					}
				}
			}
		}
		
		this.btnDownArrow.onRelease = function(){
			delete this.onEnterFrame;
		}
		
		this.btnDownArrow.onReleaseOutside = function(){
			delete this.onEnterFrame;
		}
		
		this.mcDragger.onPress = function(){
			this.startDrag(false, this._x, this._parent.topY, this._x, this._parent.bottomY);
			
			this._parent.onEnterFrame = function(){
				this.position = ((this.mcDragger._y - this.topY) * 100) / this.distance;
				//this.updatePosition(this.position, "tween");
				this.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this.position, mode: "tween"});
			}
			
		}
		
		this.mcDragger.onRelease = function(){
			this.stopDrag();
			delete this._parent.onEnterFrame;
		}
		
		this.mcDragger.onReleaseOutside = function(){
			this.stopDrag();
			delete this._parent.onEnterFrame;
		}
	}
	
	public function init(height:Number){
		this.mcBackground._height = height;
		this.btnUpArrow._y = 0;
		this.btnDownArrow._y = height - this.btnDownArrow._height;
		
		
		if (this.btnUpArrow != undefined)
			this.topY = this.btnUpArrow._height + 1;
		else
			this.topY = 0;
			
		if (this.btnDownArrow != undefined)	
			this.bottomY = this.btnDownArrow._y - this.mcDragger._height - 1;
		else
			this.bottomY = height - this.mcDragger._height;
		
		this.distance = this.bottomY - this.topY; 
	
		this.position = 0;		
		
		this.mcDragger._y = this.topY;
	}
	
	//Added by Dennis Lizano Mendez
	public function setEneable(isEnable:Boolean):Void {
		this.btnUpArrow.enabled = isEnable;
		this.btnDownArrow.enabled = isEnable;
		this.mcDragger.enabled = isEnable;
		
		this.btnUpArrow._alpha = (isEnable)? 100: 70;
		this.btnDownArrow._alpha = (isEnable)? 100: 70;
		this.mcBackground._alpha = (isEnable)? 100: 70;
		this.mcDragger._visible = isEnable;
	}
	
	public function setScrollPos(position:Number):Void {		
		var newPos = (12/100) * position; 
		trace ("POS: " + position);
		//this.mcDragger._y = this.topY;
		/*this.mcDragger._y = newPos;
		/*if (moved){
			this._parent.position = ((this._parent.mcDragger._y - this._parent.topY) * 100) / this._parent.distance;
			//this._parent.updatePosition(this._parent.position);		
			//this._parent.broadcastEvent(DynamicScrollBar.UPDATEPOSITION, {position: this._parent.position});
		}*/		
	}
	
	public function sendScrollToTop() {
		this.mcDragger._y = this.topY;
	}
}