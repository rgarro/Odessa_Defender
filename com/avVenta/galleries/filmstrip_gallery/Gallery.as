import com.gmc.gallery.ImageLine;					// Instances of this class ared used as filmstrips
import com.gmc.gallery.LargeItem;
import com.gmc.gallery.Item;						// Item types
import com.gmc.data.DataManager;					// XML Admin
import com.gm.global.Callback;						
import com.gmc.data.PhotoGalleryXMLParser;			// XML parser for the gallery file
import mx.transitions.Tween;						// Aniamtions
import mx.transitions.easing.*;						// Animation functions


/**
 *
 * Ths class implement the gmc gallery component 
 *
 * @author Dennis Lizano Méndez
 * @version 0.0.1 2007-06-27
 * @todo Missed an image administrator that keeps loaded images instead of reload them after been used
 * @tricky It's very related with the graphic instance content (there must be movie for the static variables)
 * 
 */
class com.gmc.gallery.Gallery extends MovieClip {
	
	// 1. Static Private Properties 
	private static var FILMSTRIP:String = "imgLine";			// Name of movieClip that contents the items of the filmstrip
	private static var BTN_VIEW:String = "BTNView";				// Name of the button that changes from internal to external pictures (and vice versa) 
	private static var LARGE_IMAGE:String = "largeImage";  		// Name of the movieClip where the images and videos will be loaded
	private static var VIEWER:String = "VIDMediaViewer";		// Name of the movieClip where to load videos
	private static var TEXT_TITLE:String = "TXTTitle";			// Picture desccription
	private static var TEXT_DOWNLOAD:String = "TXTDownload";	// Download file text
	private static var BTN_DOWNLOAD:String = "BTNDownload";		// Boton that downloads the gallery
	private static var TEXT_BEFORE_TITLE:String = " SHOWN: ";	// Picture description first part of the text
	private static var TEXT_4_DOWNLOAD_1:String = "DOWNLOAD ";	// Download file text, first part
	private static var TEXT_4_DOWNLOAD_2:String = " CATALOG";	// Download file text, second part
	private static var EXTERNAL:Boolean = true;					// Defines the value for external galleries
	private static var INTERIOR:Boolean = false;				// Defines the value for interior galleries
	private static var GALLERY_WIDTH:Number = 840;				// Gallery width
	private static var GALLERY_HEIGHT:Number = 320;				// Gallery height
	private static var XML_PATH:String = "../xml/photoGallery.xml" // Xml file path
	private static var ALIGN_CENTER = "CENTER";
	private static var ALIGN_LEFT = "LEFT";
	private static var ALIGN_RIGHT = "RIGHT";
	
	// 2. Private Properties 
	private var isExternal:Boolean = true;						// Stores the internal or externate status of the gallery
	private var dataManager:DataManager = null;					// Manager for loading XML files
	private var galleryXMLParser:PhotoGalleryXMLParser = null;	// Parser for the gallery xml file
	private var carModel:String = "";							// Current car model (for loading pictures from file)
	private var align:String ="CENTER";
	
	// 3. Static Public Properties 
	// 4. Public Properties 
	
	// 5. Constructor 
	/**
	 * Constructor
	 */
	function Gallery(Void) {
		this.carModel = "acadia";
		this.align = "CENTER";
		this.attachMovie(LargeItem.SymbolName, LARGE_IMAGE, this.getNextHighestDepth());
		this.init();
	}
	// 6. Static Private Methods 
	
	// 7. Private Methods 
	/**
	 * Initializes the gallery values (from xml)
	 */
	private function init(Void):Void {
		this["mcBackItems"].swapDepths(this.getNextHighestDepth());
		this[TEXT_TITLE].swapDepths(this.getNextHighestDepth());
		this[BTN_DOWNLOAD].swapDepths(this.getNextHighestDepth());
		this.attachMovie(ImageLine.SymbolName, FILMSTRIP, this.getNextHighestDepth());
		this[FILMSTRIP]._y = GALLERY_HEIGHT - 38;
		this.dataManager = DataManager.getInstance();
		if (!dataManager.isInitialized()){
			// This XML file
			dataManager.backupXML = XML_PATH;
			
			// When it's ready call the dataLoaded method
			var cb:Callback = new Callback(this, "dataLoaded");			
			dataManager.init(cb);
		}else{
			dataLoaded();
		}
	}
	
	/**
	 * Extract data from XML file and set some header values
	 */
	private function dataLoaded(Void):Void {
		this.galleryXMLParser = new PhotoGalleryXMLParser("//ul[@class = 'cPhotoGallery']", "");
		var isValid = this.loadItems(EXTERNAL);	
		if (isValid) {
			this.attachMovie("switchView",BTN_VIEW, this.getNextHighestDepth(), {_x:717.0, y:5});
			this[BTN_VIEW].setImages(this.galleryXMLParser.getHeaderImages()[0], this.galleryXMLParser.getHeaderImages()[1]);		
			// Button for downloading the gallery file
			this[BTN_DOWNLOAD][TEXT_DOWNLOAD].autoSize = true;
			this[BTN_DOWNLOAD][TEXT_DOWNLOAD].text = TEXT_4_DOWNLOAD_1 + this.carModel.toUpperCase() + TEXT_4_DOWNLOAD_2;	
			this[BTN_DOWNLOAD]._x = 840 - (63 + this[BTN_DOWNLOAD][TEXT_DOWNLOAD]._width);
			this[BTN_DOWNLOAD].onPress = function () {
				getURL("acadia.zip","_self")//trace ("listo");
			}
		} else {
			this.onViewChanged(null, INTERIOR);
		}
		createLargeItemMask();
	}
	
	function createLargeItemMask() {
		var mask:MovieClip = this.createEmptyMovieClip("mcLargeImageMask", this.getNextHighestDepth(), {_x:0, _y:0});
		mask.lineStyle(1, 0x640314, 100);
		mask.beginFill(0x001500, 100);
		mask.moveTo(0, 0);
		mask.lineTo(GALLERY_WIDTH, 0);
		mask.lineTo(GALLERY_WIDTH, GALLERY_HEIGHT - 2);
		mask.lineTo(0, GALLERY_HEIGHT - 2);
		mask.lineTo(0, 0);
		this[LARGE_IMAGE].setMask (mask);			
	}
	
	/**
	 * Initilizes the filmstrip instance addinf the items (and load the first one)
	 * @param isExternal Boolean 'True' means that it's an external pictures gallery, otherwise they're interior pictures
	 * @returns Boolean True id there's any item, false if there isn't
	 */
	private function loadItems(isExternal:Boolean):Boolean {
		// Ask for the items data by using the xml parser
		var items:Array = this.galleryXMLParser.getItems(isExternal);		
		if (items.length <= 0)
			return false;
			
		// Initialize filmstrip values
		
		this[FILMSTRIP].loadGallery(isExternal, GALLERY_WIDTH);
		
		// Show first item
		var initialOBJ:Object = {source: items[0].photo, title: items[0].title, index:0, type: items[0].type};
		this.showComponent(null, initialOBJ);		
		
		// Add a listerner for knowing when the pictures are ready
		this[FILMSTRIP].addEventListener ("itemsOrganized", this, "ubicateImageLine");
		
		// Add every item into the filmstrip
		for (var i = 0; i < items.length; i++) {
			this[FILMSTRIP].addItem(items[i].thumb, items[i].photo, items[i].title, items[i].type);
		}
		return true;
	} 
	
	/**
	 * It centers the whole filmstrip in the stage
	 *
	 * If the filmstrip is longer than the stage it won't be centered, but it's 'x' position will be 0 (zero)
	 * to allow the animation works as it should
	 */	 
	private function ubicateImageLine():Void {
		
		if (GALLERY_WIDTH > this[FILMSTRIP]._width) {
			switch (this.align.toUpperCase()) {
				case ALIGN_CENTER:
					// If the filmstrip is shorter than the Stage it'll be centered
					var border:Number = (GALLERY_WIDTH - this[FILMSTRIP]._width) / 2;
					this[FILMSTRIP].setMinimunPosition (border);
					this[FILMSTRIP]._x = border;
					break;
				
				case ALIGN_LEFT:
					this[FILMSTRIP].setMinimunPosition (0);
					this[FILMSTRIP]._x = 0;
					break;
				
				case ALIGN_RIGHT:
					this[FILMSTRIP].setMinimunPosition (GALLERY_WIDTH - this[FILMSTRIP]._width);
					this[FILMSTRIP]._x = GALLERY_WIDTH - this[FILMSTRIP]._width;
					break;
			}
		} else {
			this[FILMSTRIP].setMinimunPosition (0);
			this[FILMSTRIP]._x = 0;
		}
	}
	
	// 8. Static Public Methods 	
	
	// 9. Public Methods
	/**
	 * Intializes the filmstrip with a external view of the current brand.
	 * In addition it establishes the listeners for the change image and the change view (internal/external) events
	 */
	public function onLoad() {		
		this.onViewChanged(null, true);
		// Add listeners for items changed
		this[FILMSTRIP].addEventListener("itemChanged",  this, "showComponent");
		this[BTN_VIEW].addEventListener("onPress", this, "onViewChanged");		
		
		this[VIEWER].setVideoObj("vp1");
		this[VIEWER].addListener(this);
		
		// Draw an set a mask from the imagesLine (filmstrip)
		var maskName:String = "filmstripMask";
		var mask:MovieClip = this.createEmptyMovieClip(maskName, this.getNextHighestDepth());
		this[maskName].beginFill(0xFF0000);
		this[maskName].lineStyle(4, 0x000000, 100);
		this[maskName].moveTo(0, GALLERY_HEIGHT - 50);
		this[maskName].lineTo(GALLERY_WIDTH, GALLERY_HEIGHT - 50);
		this[maskName].lineTo(GALLERY_WIDTH, GALLERY_HEIGHT);
		this[maskName].lineTo(0, GALLERY_HEIGHT);
		this[maskName].lineTo(0, GALLERY_HEIGHT - 50);
		this[FILMSTRIP].setMask(mask);
	}
	
	public function onUnload() {
		this[FILMSTRIP].removeOldLine();
	}
	
	/**
	 * Shows a component when it was selected
	 * @param source Object Broadcaster object (the filmstrip)
	 * @componentData Object Picture/Video data
	 */
	public function showComponent (source:Object, componentData:Object):Void {
		/*if (_root["imageText"] == null) {
			_root.createTextField("imageText", _root.getNextHighestDepth(), 450,400,150,150);
			_root["imageText"].autoSize = true;
		}
		_root["imageText"].text += "("+ this[LARGE_IMAGE] +")" + componentData.source + "["+ componentData.type +"]" + " - ";*/
		var root:Gallery = this;
		var type:String = "";
		this[LARGE_IMAGE].loadItem(componentData);
		//The way the item is displayed depends on its type 
		/*switch (componentData.type) {
			case Item.TYPES.picture:
			case Item.TYPES.picture:
				//trace ("ITS A PICTURE");
				type = "IMAGE";
				this[VIEWER].stop();
				//var transition = new Tween(this[VIEWER], "_alpha", Regular.easeOut, 100, 2, 5, true);
				this[VIEWER]._visible = false;
				this[LARGE_IMAGE].loadImage(componentData);
				break;
			
			case Item.TYPES.video:
				type = "VIDEO";
				this[LARGE_IMAGE].unloadCurrentImage();
				this[VIEWER]._visible = true;				
				this[VIEWER].setURL(componentData["source"]);
				break;
			default:
				break;
		}
		*/
		// Set the item description
		this[TEXT_TITLE][TEXT_TITLE].autoSize = true;
		this[TEXT_TITLE][TEXT_TITLE].text = type + TEXT_BEFORE_TITLE + componentData.title.toUpperCase();
		this[BTN_VIEW].swapDepths(this.getNextHighestDepth());
	}
	
	/**
	 * Centers a video when it's loaded
	 * @event onBufferFull broadcasted by the movie viewer (this[VIEWER])
	 */
	public function onBufferFull() {
		// VIDEO!!
		this[VIEWER].autoSize();
		var border = (GALLERY_WIDTH - this[VIEWER].getWidth()) / 2;
		this[VIEWER]._x = border;
		border = (GALLERY_HEIGHT - this[VIEWER].getHeight()) / 2;
		this[VIEWER]._y = border;
	}
	
	/**
	 * Not implemented. It should show an animation when the video finishes (just if it is asked)
	 */
	public function onPlayStop() {
		// VIDEO!!
		trace ("MOVIE STOPED!!!");
	}
	
	/**
	 * It handles the change view event from internal to external (and vice versa)
	 * 
	 * @param  source  Object  it comes from the event broadcaster instance inside the button that changes views.
	 * @param  isExternal  Boolean  Defines if the items that must be loaded are external or internal pictures
	 * @event onPress From this[BTN_VIEW] button
	 */
	public function onViewChanged (source:Object, isExternal:Boolean) {
		this.loadItems(isExternal);
		//this.centerImageLine(Void);
	}
	
	/*
	 * Changes the gallery car model and loads it immediatly
	 * @param carModel String car model it should exists int the xml file
	 */
	public function setModel(carModel:String, align:String):Void {
		this.align = align;
		this.carModel = carModel;
		//this.carModel = "acadia";
		//this.align = "CENTER";
		this.init();
	}
	
	// 10. Getter/Setter Methods
}