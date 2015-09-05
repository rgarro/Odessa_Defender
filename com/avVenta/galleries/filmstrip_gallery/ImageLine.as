import com.avVenta.events.BroadcastableMovieClip;		// Allows events broadcasting
import com.gmc.gallery.Item;							// Every thumbnail is an item

/**
 *
 * Manages the items filmstrip
 *
 * @author Dennis Lizano Méndez
 * @version 0.0.1 2007-06-27
 * @todo Missed test when the gallery doesn't have any data
 * @todo The animation looks pixeled
 * 
 */
class com.gmc.gallery.ImageLine extends BroadcastableMovieClip {
	
	// 1. Static Private Properties 
	private static var VISIBLE_WIDTH:Number = 0;		 // Visible part of the menu (it doesn't depends on the position, check minXPos)
	private static var FOCUS_RATIO:Number = 10;			 // Ratio for picture in the middle (to stop the moving menu)
	private static var ITEM_HEIGHT:Number = 33; 		 // Picture height, it's different fom redlines
	private static var ITEM_OBJ:String = "Item";		 // Item object's name in the movie
	private static var ITEM_BASIS_NAME:String = "THUMB"; // Basis name for naming the thumbnails added
	
	// Events
	
	// Listened
	private static var ITEM_LOADED = "itemLoaded";			// When the item was loaded
	private static var NEW_FOCUS = "newFocus";				// When the mouse activates the onRollOver event of an item
	private static var LOST_FOCUS = "lostFocus";			// When the mouse activates the onRollOut event of an item
	private static var ITEM_SELECTED = "itemSelected";		// When an item was pressed
	
	// 2. Private Properties
	private var itemSpace:Number = 1; 		 	 		 // Space between thumbnails
	private var minXPos:Number = 0;						 // minimun position of the filmstrip in it's father
	private var target:MovieClip = null;				 // Basis MovieClip target (where the images should be loaded)
	private var item:Array = new Array(0);				 // Array of thumbnails in a filmstrip
	private var isExternal:Boolean = false;				 // Boolean: true means the external photoso of the card are been shown
	private var movInterval:Number = null				 // Interval id that keeps the menu moving
	private var lastSelected:Number = 0;				 // last item index selected
	private var allowMoving:Boolean = true;				 // Allow or not the filmstrip motion
	
	static var SymbolName:String = "__Packages.com.gmc.gallery.ImageLine";
	static var SymbolLinked = Object.registerClass(SymbolName, ImageLine);
	
	// 3. Static Public Properties 
	// 4. Public Properties 
	// Events
	// Broadcasted
	public static var ITEM_CHANGED = "itemChanged";		// When an item was changed
	public static var ITEMS_ORGANIZED = "itemsOrganized";  // When the items were organized (sorted)
	public static var EVENTS:Object = {onOver: "onOver", onOut:"onOut", onOutItem:"onHiddeItem"};
	// 5. Constructor 
	public function ImageLine() {
		this.item = new Array(0);
		for (var i = 0; i < this.item.length; i++) {
			trace ("Verify: " + this.item + "[ " + this.item["target"] +" / "+ this +"]") ;
			if (this.item["target"] == this) {
				removeMovieClip(this.item);
				this.item.splice(i,1);
			}
		}
	}
	
	// 6. Static Private Methods 
	// 7. Private Methods 
	/**
	 * This methos removes all the movieclips created in the last filmstrip
	 * It also removes removes the events registered for every created item
	 */
	public function removeOldLine(Void):Void {
		for (var i = 0; i < this.item.length; i++) {
			if (this.item[i]["target"] == this) {
				//trace ("REMOVING OLD ITEM: " + this.item[i] + " from " + this + this.item[i]._parent);
				// Remove events
				this.item[i].removeListener("newFocus", this, "onMoveMenu");
				this.item[i].removeListener("lostFocus", this, "onLostFocusMenu");
				this.item[i].removeListener("itemSelected", this, "onItemSelected");
				
				// Remove movieclip
				this.item[i].removeMovieClip();	
			}
		}
		// Clear the interval (just in case it's been used)
		clearInterval (this.movInterval);
		
		// Initialize the items array
		this.item = new Array(0);
	}
	
	/**
	 *  Depending on the mouse position over the principal movieclip this methos defines
	 *  the volocity the filmstrip must be moved, even the direction (left or right)
	 * @param menu MovieClip MovieClip that containst the filmstrip (principal movie)
	 * @param middlePx Number Central position of the principal movie clip. It's used to define the diretion
	 * @param maxVelocity Number Maximun velociity allowed for moving the filmstrip.
	 */
	private function keepMenuMoving(menu:MovieClip, middlePx:Number, maxVelocity:Number):Void {		
		var isLeft:Boolean = (menu._parent._xmouse > middlePx);
		
		// Define velocity
		var velocity = (maxVelocity * (Math.abs(menu._parent._xmouse - middlePx))) / (middlePx);// + ()
		
		// Define firection
		if (menu.verifyContinue(isLeft)) {
			menu._x += (velocity*((isLeft)? -1:1));
		}
	}
	
	// 9. Public Methods	
	/**
	 * Initilizes the current gallery values 
	 * @param isExternal Boolean If it is true the gallery will load imagen of external views, otherwise loads interior views
	 */
	public function loadGallery (isExternal:Boolean, gallerySize:Number):Void {
		// Remove last filmstrip items
		this.removeOldLine();
		
		// Initialize current values
		this.isExternal = isExternal;		
		this.target = this;		
		minXPos = this._x;
		VISIBLE_WIDTH = gallerySize;
	}
	
	/**
	 * Adds a new item (thumbnail + large picture reference) into the current filmstrip
	 * @param name String Item movieClip name, it should be in the current target reference
	 * @param thumbnail String Path that refers where to find the thumbnail image (the small one)
	 */
	public function addItem(thumbnail:String, largeImage:String, title:String, type:String, extraData:Object) {
		var name = ITEM_BASIS_NAME + this.item.length;
		// Create item, and store it in the item array
		var newItem:MovieClip = this.attachMovie(Item.SymbolName, name, this.getNextHighestDepth());
		
		// Load thumbnail for this item		
		newItem["target"] = this;
		newItem.setIndexPosition(this.item.length);
		newItem.loadThumbnail(thumbnail, largeImage, title, type, extraData);
		newItem.addEventListener(ITEM_LOADED, this, "organizeItems");
		newItem.addEventListener(NEW_FOCUS, this, "onMoveMenu");
		newItem.addEventListener(LOST_FOCUS, this, "onLostFocusMenu");
		newItem.addEventListener(ITEM_SELECTED, this, "onItemSelected");		
		this.item.push(newItem);
	}
	
	
	
	/**
	 * This method starts the filmstrip motion when it's neccesary
	 * @event newFocus Activated when the mouses passes over an item
	 * @param source MovieClip MovieClip that sends the event. It isn't used here
	 * indexNumber Number Array index position (where the mouseis passing over)
	 */
	public function onMoveMenu (source:Object, objData:Object) {
		this.item[objData.index]["byMouse"] = objData.byMouse;
		trace ("FIRST: ON OVER: " + this.item[objData.index]["byMouse"]);
		this.broadcastEvent(EVENTS.onOver, this.item[objData.index]);
		// First filter: If the filmstrip is in the nearest position from the left border it won't be animated.
		if (this.minXPos == 0 && this.allowMoving) {			
			clearInterval (this.movInterval);
			
			// Created the interval for the animation
			this.movInterval = setInterval(keepMenuMoving, 1, this, (VISIBLE_WIDTH / 2), 2);
		}
	}
	
	/**
	 *	Stops menu animation when the mouse leaves the filmstrip area
	 */
	public function onLostFocusMenu() {
		var ymouse:Number = this._parent._ymouse; 	// Mouse position when cursor leaves the gallery menu
		var xmouse:Number = this._parent._xmouse; 	// Mouse position when cursor leaves the gallery menu
		//var xEnd:Number = this._x + this._width;
		// Just if the mouse leaves the y position of the filmstrip it'll be stoped
		//trace ("WIDTH:::["+ xmouse +"] " + this._width + " from " + (xmouse <= this._x));
		if (((ymouse <= this._y) || (ymouse >= (this._y + ITEM_HEIGHT))) || 
		    ((xmouse <= this._x) || (xmouse >= (this._x + this._width - 3)))){
			this.broadcastEvent(EVENTS.onOut);
			this.stopMenu();
		}
		this.broadcastEvent(EVENTS.onOutItem);
	}
	
	/**
	 * It defines if the animation should continue. It dependes on the number of items and the current filmstrip position
	 *
	 * @param isLeft Boolean indicates the direction of the animation (important to validate) if it is true the menu is moving to the left
	 * @return Boolean It returns true if the animation can continue normaly
	 */
	public function verifyContinue(isLeft:Boolean):Boolean {
		var xPos:Number = this._x;
		if (isLeft && (xPos < minXPos)) {
			// Stop the animation when the last picture is shown and it's moving to the left
			var parentSize:Number = VISIBLE_WIDTH;
			
			if ((Math.abs(xPos) + parentSize) >= this._width) {				
				this.stopMenu();
				return false;
			}
		} else if (!isLeft && (xPos >= minXPos)) {
			// Stop the animation when the first picture is shown and it's moving to the rigth
			this._x = minXPos;			
			this.stopMenu();
			return false;
		} else if (((this._parent._xmouse - FOCUS_RATIO) < (VISIBLE_WIDTH / 2)) && 
				   ((this._parent._xmouse + FOCUS_RATIO) > (VISIBLE_WIDTH / 2))) {
			// The cursor is the middle of the area, that means the menu can be stopped
			this.stopMenu();
			return false;
		}
		
		// There're no exceptions: continue animation
		return true;
	}
	
	/*
	 * Send an event telling the gallery to change the item visualization (picture or video)
	 * 
	 * @param source Object Where the event comes from
	 * @param imageData Object Image information: thumbail, large picture path, etc.
	 * @event itemSelected trigger when an item is pressed
	 */
	public function onItemSelected(source:Object, imageData:Object):Void {
		// Just if it's a different image
		if (lastSelected != imageData.index)
			this.item[lastSelected].anotherSelected();
		lastSelected = imageData.index;
		
		// Send the event
		this.broadcastEvent(ITEM_CHANGED, imageData);
		
		// Stops the menu animation
		this.stopMenu ();
	}
	
	/**
	 * Stops the menu animation
	 * 
	 */
	public function stopMenu () {
		clearInterval(this.movInterval);
		this.movInterval = null;
	}
	
	/**
	 * Sorts the images line (They're sorted as they were added)
	 */
	public function organizeItems(Void):Void {
		var xAcum:Number = 0;
		for (var i=0; i < this.item.length; i++) {
			this.item[i]._x = xAcum;
			xAcum += (this.item[i]._width + this.itemSpace);
		}
		this.broadcastEvent(ITEMS_ORGANIZED, null);
	}	
	
	/**
	 * Selects and item
	 * @param index Number itemIndex array position
	 */
	public function selectItem(itemIndex:Number) {
		this.item[itemIndex].selectItem(false);
	}
	
	/**
	 * Select a new item sorted or not
	 * @param isRandom Boolean defines if the next item selected will be selected in order or not
	 */
	public function selectNextItem(isRandom:Boolean):Void {
		
		var nextIndex:Number  = -1;
		if (isRandom) {
			nextIndex = (Math.random() * (this.item.length - 1));
		} else {
			nextIndex = (this.lastSelected == (this.item.length - 1))? 0 : this.lastSelected + 1;
		}
		this.selectItem(int(nextIndex));
	}
	
	public function onUnload () {
		this.item = new Array(0);
	}
	
	
	// 10. Getter/Setter Methods
	// ------ Getters
	/**
	 * Get for items.length
	 * @returns this.items.length Number of elements that have been created (added) to this filmstrip
	 */
	public function getNumberOfItems(Void):Number {
		return this.item.length;
	}
	
	// ------ Setters
	/**
	 * Setter: minXPosition. It delimits the filmstrip
	 */
	public function setMinimunPosition(minXPos:Number):Void {
		this.minXPos = minXPos;
	}
	/**
	 * Changes the space between thumbnails
	 * 
	 * @param itemSpace Number Number of pixels between thumbnails
	 * @param organize Boolean If it's set in 'true' the imageList will be organized, otherway the new space won't be applied
	 */	 
	public function setSpace(itemSpace:Number, organize:Boolean):Void {
		this.itemSpace = itemSpace;
		if (organize)
			organizeItems();
	}
	
	public function setGallerySize(gallerySize:Number):Void {
		VISIBLE_WIDTH = gallerySize;
	}
	
	public function setAllowMoving(allowMoving:Boolean):Void {
		this.allowMoving = allowMoving;
	}
}