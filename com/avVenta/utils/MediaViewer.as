class com.avVenta.utils.MediaViewer extends MovieClip{
	
	/**
	* This is a helper class used in the component to play local videos with a controless component
	* The component will also load jpg, png
	* 
	* @author: Emmanuel Ulloa
	* @version: 0.0.1 
	* */
	
	var videoNC:NetConnection;
	var videoNS:NetStream;
	[Inspectable (name="Video Instance", defaultValue="")]var videoObjPath:String = "";
	var videoObj:Video;
	var imageObj:MovieClip;
	[Inspectable (name="Media Path", defaultValue="")]var path:String = "";
	[Inspectable (name="Show Progress", defaultValue=false)]var progressOn = false;
	
	var percentage:Number = 0;
	var position:Number = 0;
	var duration:Number = 0;
	
	private var fullW:Number;
	private var fullH:Number;
	private var normalW:Number;
	private var normalH:Number;
	var events:Object;
	
	// Added by Dennis Lizano Mendez
	static var SymbolName:String = "__Packages.com.avVenta.utils.MediaViewer";
	static var SymbolLinked = Object.registerClass(SymbolName, MediaViewer);
	
	function MediaViewer(){
		var root:MediaViewer = this;
		init();
	}
	
	function init(path:String):Void{
		var root:MediaViewer = this;
		videoNC = new NetConnection();
		videoNC.connect(null);
		videoNS = new NetStream(videoNC);
		if(videoObjPath != undefined){
			setVideoObj(videoObjPath);
		}
		/* EVENT BROADCASTER */
		events = new Object();
		AsBroadcaster.initialize(events);
		
		root.onLoad = function(){
			normalW = root._width;
			normalH = root._height;
		}
		
		/* Broadcast Stream Messages */
		videoNS.onStatus = function(info:Object){
			trace("STREAM ONSTATUS: " + info.code);
			if(info.code == "NetStream.Play.Start"){
				root.events.broadcastMessage("onPlayStart");
			}else if(info.code == "NetStream.Play.Stop"){
				root.events.broadcastMessage("onPlayStop");
			}else if(info.code == "NetStream.Buffer.Full"){
				root.events.broadcastMessage("onBufferFull");
			}
		}
		
		videoNS.onMetaData = function(info:Object){
			trace("STREAM ONMETADA");
			root.duration = Number(info["duration"]);
		}
		
		trace("MediaViewer Instanciated");
	}
	
	/* METHODS */
	/*
	* Play the "flv" files 
	*/
	public function play():Void{
		var root:MediaViewer = this;
		if(analizePath() == "flv"){	
			videoNS.play("/" + path);
		}else{
			trace("Media type is not playable");
		}
	}
	
	/*
	* Pause the "flv" files 
	*/
	function pause():Void{
		videoNS.pause(true);
	}
	
	/*
	* Stop the "flv"
	*/
	function stop():Void{
		videoNS.close();
	}
	
	/*
	* Send the "flv" playhead to the end
	*/
	function fforward():Void{
		videoNS.seek(getDuration());
	}
	
	/*
	* Restart the "flv", same as play().
	*/
	function rewind():Void{
		this.play();
	}
	
	/*
	* Resume a paused "flv"
	*/
	function resume():Void{
		videoNS.pause(false);
	}
	
	/*
	* Jump to a set position inside the "flv"
	* */
	function seek(position:Number):Void{
		videoNS.seek(position);
	}
	
	/*
	* Set the size of the movie to the width and height passed through setSize().
	* If the size has not been set then it will use the width and height of the Stage.
	*/
	function fullScreen():Void{
		var root:MediaViewer = this;
		if(fullW == undefined || fullH == undefined){
			fullW = Stage.width;
			fullH = Stage.width;
		}
		
		root._width = fullW;
		root._height = fullH;
	}
	
	function autoSize():Void{
		trace ("autosize: " + videoObj.width + "," + videoObj.height);
		videoObj._width = videoObj.width;
		videoObj._height = videoObj.height;
	}
	
	/*
	* Add an event listener
	*/
	public function addListener(listener:Object):Void{
		events.addListener(listener);
	}
	
	/*
	* Remove an event listener
	*/
	public function removeListener(listener:Object):Void{
		events.removeListener(listener);
	}

	/* PRIVATE METHODS */
	private function analizePath():String{
		if(path != undefined){
			var ext:String = path.substr(path.length-3,3);
			return ext;
		}
	}
	
	public function loadImage():Void{
		var root:MediaViewer = this;
		var targetLevel:Number = root.getNextHighestDepth();
		var targetMC:MovieClip = imageObj = root.createEmptyMovieClip("targetMC", targetLevel);
		var loader:MovieClipLoader = new MovieClipLoader();
		var loaderLevel:Number = root.getNextHighestDepth();
		var loaderMC:MovieClip = root.createEmptyMovieClip("loaderMC", loaderLevel);
		
		//DRAW THE BACKGROUND
		loaderMC._x = loaderMC._y = 5;
		loaderMC.beginFill(0xFFFFFF, 100);
		loaderMC.moveTo(0,0);
		loaderMC.lineTo(60,0);
		loaderMC.lineTo(60,20);
		loaderMC.lineTo(0,20);
		loaderMC.endFill();
		//CREATE THE PERCENTAGE TEXTBOX
		var txtPercentage:TextField = loaderMC.createTextField("percentage_txt", loaderMC.getNextHighestDepth(), 0, 0, 60, 20);
		var percentageTF:TextFormat = new TextFormat();
		percentageTF.font = "Arial";
		percentageTF.color = 0x000000;
		percentageTF.bold = true;
		percentageTF.size = 10;
		percentageTF.align = "right";
		txtPercentage.selectable = false;
		txtPercentage.setNewTextFormat(percentageTF);
		txtPercentage.text = "Loading...";
		
		loaderMC._visible = progressOn;
		
		//SHOW THE PERCENTAGE AS IT LOADS
		var percentageListener:Object = new Object();
		percentageListener.onLoadProgress = function(m:MovieClip, l:Number, t:Number):Void{
			var per:Number = Math.ceil((l/t) * 100);
			txtPercentage.text = per.toString() + "%";
			root.events.broadcastMessage("onLoadProgress");
		}
		percentageListener.onLoadError = function(){
			txtPercentage.text = "Error";
			root.events.broadcastMessage("onLoadError");
		}
		percentageListener.onLoadInit = function(m:MovieClip){
			loaderMC.removeMovieClip();
			//root.normalW = m._width;
			//root.normalH = m._height;
			root.resetSize();
			root.events.broadcastMessage("onLoadInit");
			root.events.broadcastMessage("onLoad");
		}
		percentageListener.onLoadComplete = function(){
			root.events.broadcastMessage("onLoadComplete");
		}
		
		loader.addListener(percentageListener);
		loader.loadClip(path, targetMC);
	}
	
	/* SETTER & GETTER */
	
	/**
	* Set the url of the media file (either "flv", "jpg", "png" or "gif").
	* @param the URL or path where the media file is located.
	*/
	function setURL(path:String):Void{
		this.path = path;
		if(analizePath() == "jpg" || analizePath() == "png" || analizePath() == "gif" || analizePath() == "swf"){
			loadImage();
		}else if(analizePath() == "flv"){
			play();
		}
	}
	
	/**
	* Returns the path of the media file used.
	*/
	function getURL():String{
		return(path);
	}
	
	/**
	* Set the Video Object inside the component or movieclip using the Class.  
	* This is necessary due the fact that is not possible to create a video object dynamically.
	* To create a video object you need to right click the library and select "New Video..."
	* then drag the video object onto the stage from the libray into the movieclip using the class.
	* Give your video object an instance name, this is the name you'll set in the setVideoObj(videoInstanceName) function.
	* @param the name and/or location of the video object inside your movie.
	*/
	function setVideoObj(path:String){
		var root:MediaViewer = this;
		videoObjPath = path;
		videoObj = root[videoObjPath];
		videoObj.smoothing = true;
		videoObj.attachVideo(videoNS);
	}
	
	function setVideoObject(object:Video) {
		var root:MediaViewer = this;
		videoObjPath = "";
		videoObj = root[object];
		videoObj.smoothing = true;
		videoObj.attachVideo(videoNS);
	}
	
	/**
	* Returns the video object which is being used in your movie clip 
	*/
	function getVideoObj():Video{
		return videoObj;
	}
	
	/*
	* Returns the movieclip where the images are loaded
	* */
	function getImageObj():MovieClip{
		if(analizePath() != "flv"){
			return imageObj;
		}else{
			return this;
		}
		
	}
	
	/**
	* Set the size of the component 
	* @param The width and height desired for the component
	*/
	function setSize(w:Number, h:Number){
		videoObj._width = w;
		videoObj._height = h;
	}
	
	/**
	* Reset the size of the movie 
	*/
	function resetSize(){
		setSize(normalW, normalH);
		fullScreen();
	}
	
	function getType():String{
		return analizePath();
	}
	
	function getPercentage():Number{
		if(getType() == "flv"){
			if(getPosition() == 0 || getDuration() == 0){
				percentage = 0;
			}else{
				percentage = Math.round((getPosition()/getDuration())* 100) ;
			}
			return percentage;
		}
	}
	
	function getPosition():Number{
		if(getType() == "flv"){
			position = videoNS.time;
			return position;
		}
	}
	
	function getDuration():Number{
		if(getType() == "flv"){
			return duration;
		}
	}
	
	function getHeight(Void):Number {
		return videoObj._height;
	}
	
	function getWidth(Void):Number {
		return videoObj._width;
	}
	
}