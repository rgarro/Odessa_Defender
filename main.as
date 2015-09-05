com.mosesSupposes.fuse.FuseFMP.simpleSetup();	
var eventtank:Object;
var totalchoppers:Number;
var misilesound:Object;
var explosound:Object;
var te:Object;
var points:Number;
var aksound:Object;
var replayBot:Object;

points = 0;

eventtank = eventtank1(_root.attachMovie("tanky","evtank_mc",_root.getNextHighestDepth()));
_root.evtank_mc._x = -20;
totalchoppers = eventtank.enemychoppers.chopperqty;
misilesound = new MissileSound();
explosound = new sonidoExplosion();
aksound = new ak47shotsdyn();
te = new tweenEffects();

replayBot = replaybotdyn(_root.attachMovie("replaybot","replaybot_mc",_root.getNextHighestDepth()))