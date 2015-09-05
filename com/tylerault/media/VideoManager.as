import com.tylerault.utils.CallbackObject;
import com.tylerault.utils.LogicUtils;

/***
 * Basic VideoManager for handling video; for controls, see VideoControl
 *
 * @author Tyler Ault [tault@digitas.com]
 ***/
class com.tylerault.media.VideoManager
{
	private var videoObject:Video;
	private var theNetConnection:NetConnection;
	private var theNetStream:NetStream;
	private var playing:Boolean;
	private var metaData:Object;
	private var metaDataCallback:CallbackObject;
	public var cuePointCallback:CallbackObject;
	private var bufferPercent:Number;
	private var streamHost:String;
	private var streamApplication:String;
	private var streamPorts:Array;
	private var streamNetConnections:Array;

	public var finishedCallback:CallbackObject;
	public var startedCallback:CallbackObject;

	function VideoManager( newVideoHolder:Video,
		newVideoFile:String, autoPlayBuffer:Number )
	{
		setVideo( newVideoHolder );

		if( LogicUtils.exists( newVideoFile ) )
		{
			loadVideo( newVideoFile, autoPlayBuffer );
		}
	}

	/***
	 * @param videoFile the video file to be loaded
	 * @param autoPlay buffer - a buffer, in milliseconds, before the video starts playing
	 ***/
	public function loadVideo( videoFile:String, autoPlayBuffer:Number ) : Void
	{
		this.theNetConnection = new NetConnection();
		this.theNetConnection.connect( null );
		this.theNetStream = new NetStream( this.theNetConnection );
		loadVideoFile( videoFile, autoPlayBuffer );
	}

	/***
	 * Shared by both progressive (loadVideo) and streaming (streamVideo)
	 ***/
	private function loadVideoFile( videoFile:String, autoPlayBuffer:Number ) : Void
	{
		// _root.debug( "loadVideoFile( " + videoFile + ", " + autoPlayBuffer + ")" );
		this.videoObject.attachVideo( this.theNetStream );

		// handler to capture the metadata
		var manager:VideoManager = this;
		this.theNetStream.onMetaData = function( info:Object )
		{
			manager.setMetaData.apply( manager, [ info ] );
		}

		// handle status 
		this.theNetStream.onStatus = function( info:Object )
		{
			manager.handleStatus.apply( manager, [ info ] );
		}

		if( !LogicUtils.exists( autoPlayBuffer ) || autoPlayBuffer == 0 )
		{
			// play ( and capture the metadata )
			this.theNetStream.play( videoFile );
			this.playing = false;
			this.theNetStream.pause();
		}
		else
		{
			if( autoPlayBuffer > 0 )
			{
				this.theNetStream.setBufferTime( autoPlayBuffer / 1000 );
			}
			this.theNetStream.play( videoFile );
			this.playing = true;
		}
	}

	/***
	 * @param streamName the name of the video file (always without '.flv')
	 * @param autoPlayBuffer milliseconds to buffer
	 ***/
	public function streamVideo( streamName:String, autoPlayBuffer:Number ) : Void
	{
		var manager:VideoManager = this;
		if( LogicUtils.exists( this.streamPorts ) )
		{
			// TODO: not currently working here -- steal from SaveDoug!
			// start a connection for each port; first finished is used and kills the others
			// this.streamNetConnections = new Array();
			// for( var i:Number = 0; i < this.streamPorts.length; i++ )
			// {
			// 	var newConnection:NetConnection = new NetConnection();
			// 	newConnection.onStatus = function( connectionData:Object )
			// 	{ 
			// 		_root.debug( "connection status: " + connectionData.code );
			// 		if( connectionData.code == "NetConnection.Connect.Success" )
			// 		{
			// 			manager.streamPortFound.apply( manager,
			// 				[ i, streamName, autoPlayBuffer ] );
			// 		}
			// 	}
			// 	var PortConnect:String = this.streamPorts[ i ].Protocol + this.streamHost +
			// 			":" + this.streamPorts[ i ].Port + this.streamApplication;
			// 	_root.debug( "trying port: " + PortConnect );
			// 	newConnection.connect( PortConnect );
			// 	newConnection.call( "getStreamLength", this, streamName );
			// 	this.streamNetConnections.push( newConnection );
			// }
		} else {
			// Flash Player will cascade through the default ports
			this.theNetConnection = new NetConnection();
			this.theNetConnection.onStatus = function( connectionData:Object )
			{ 
				if( connectionData.code == "NetConnection.Connect.Success" )
				{
					manager.loadVideoFile.apply( manager, [ streamName, autoPlayBuffer ] );
				}
			}
			this.theNetConnection.connect( "rtmp://" + this.streamHost + this.streamApplication ); 
			this.theNetConnection.call( "getStreamLength", this, streamName );
			this.theNetStream = new NetStream( this.theNetConnection );
		}
		
	}

	/***
	 * Should only be called by streamVideo's streamNetConnections' onStatus
	 ***/
	public function streamPortFound( connectionIndex:Number, streamName:String, buffer:Number ) : Void
	{
		this.theNetConnection = this.streamNetConnections[ connectionIndex ];
		for( var i:Number = 0; i < this.streamNetConnections.length; i++ )
		{
			if( i != connectionIndex ) {
				delete this.streamNetConnections[ i ];
				this.streamNetConnections[ i ] == null;
			}
		}
		delete this.streamNetConnections;
		 
		this.theNetStream = new NetStream( this.theNetConnection );
		loadVideoFile( streamName, buffer ); 
	}

	public function handleStatus( info:Object ) : Void
	{
		switch( info.code )
		{
			case "NetStream.Play.Stop" :
				if( getSeconds() >= ( getDuration() - 0.5 ) )
				{
					this.finishedCallback.run();
				}
				break;
			case "NetStream.Play.Start" :
				if( LogicUtils.exists( this.startedCallback ) )
				{
					this.startedCallback.run();
				}
				break;
		}
	}

	public function togglePlay() : Void
	{
		this.playing = !this.playing;
		this.theNetStream.pause();
	}

	public function setPlaying( newValue:Boolean )
	{
		if( this.playing != newValue )
		{
			togglePlay();
		}
	}

	public function setMetaData( newInfo:Object )
	{
		this.metaData = newInfo;
		this.metaDataCallback.run( this.metaData ); 
		// trace( "metaData set" );
		// for( var i:String in newInfo )
		// {
		// 	trace( i + ": " + newInfo[ i ] );
		// }
		if( this.bufferPercent != undefined )
		{
			this.theNetStream.setBufferTime( this.bufferPercent * this.metaData.duration );
		}
	}

	// for getting time of stream in seconds
	public function onResult( detectedBufferTime:Number )
	{
		if( this.metaData == undefined ){ this.metaData = new Object(); }
		this.metaData.duration = detectedBufferTime;
		this.metaDataCallback.run( this.metaData ); 
	}

	/***
	 * We have to do this because, when streaming, the stop is called before the stream ends.
	 * @param dedicatedClip a movieclip with an onEnterFrame that can be dedicated to monitoring the stream
	 ***/
	public function setStreamFinishedMonitor( dedicatedClip:MovieClip ) : Void
	{
		var manager:VideoManager = this;
		dedicatedClip.onEnterFrame = function()
		{
			var d:Number = manager.getDuration();
			if( manager.getSeconds() >= ( d - 0.5 ) )
			{
				if( !isNaN( d ) && d > 0 ) {
					manager.finishedCallback.run();
					delete this.onEnterFrame;
				}
			}
		}
	}

	public function getMetaData() : Object
	{ return this.metaData; }

	public function getDuration() : Number
	{ return this.metaData.duration; }

	public function closeStream()
	{ this.theNetStream.close(); }

	public function getPlaying() : Boolean
	{ return this.playing; }

	public function setSeconds( Seconds:Number )
	{ this.theNetStream.seek( Seconds ); }
	
	public function getSeconds() : Number
	{ return this.theNetStream.time; }
	
	public function getBytesLoaded():Number
	{ return this.theNetStream.bytesLoaded; }
	
	public function getBytesTotal():Number
	{ return this.theNetStream.bytesTotal; } 

	public function getNetStream():NetStream
	{ return this.theNetStream; }

	public function setVideo( newVideo:Video ) : Void
	{ this.videoObject = newVideo; }

	public function getVideo():Video
	{ return this.videoObject; }

	public function setFinishedCallback( newCallback:CallbackObject ) : Void
	{ this.finishedCallback = newCallback; }

	public function setStartedCallback( newCallback:CallbackObject ) : Void
	{ this.startedCallback = newCallback; }

	public function setMetaDataCallback( newCallback:CallbackObject ) : Void
	{ this.metaDataCallback = newCallback; }


	/***
	 * @param Host the host name, without protocol or path
	 * @param Application the path to the streaming app, starting with a "/"
	 * @param Ports an array of objects: [ { Protocol:"rmtp", Port:1935 }, ... ]
	 ***/
	public function setStreamData( Host:String, Application:String, Ports:Array ) : Void
	{
		this.streamHost = Host;
		this.streamApplication = Application;
		this.streamPorts = Ports;
	}

	/***
	 * @param newPercent a number whose value is 0 <= N <= 1
	 ***/
	public function setBufferPercent( newPercent:Number ) : Void
	{
		this.bufferPercent = newPercent;
		if( this.metaData.duration != undefined )
		{
			this.theNetStream.setBufferTime( this.bufferPercent * this.metaData.duration );
		}
	}

	/***
	 * Sets a callback object for cuepoints embedded in FLVs; must be set after loadVideo is called
	 ***/
	public function setEmbeddedCuePointCallback( newCallback:CallbackObject ) : Void
	{
		this.cuePointCallback = newCallback;
		var manager:VideoManager = this;
		this.theNetStream.onCuePoint = function( infoObject:Object ) 
		{
			manager.cuePointCallback.run( infoObject );
		}
	}

}
