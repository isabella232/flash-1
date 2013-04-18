package flexUnitTests
{
	import com.pubnub.Pn;
	import com.pubnub.PnCrypto;
	import com.pubnub.PnEvent;
	import com.pubnub.connection.*;
	import com.pubnub.json.PnJSON;
	import com.pubnub.operation.OperationStatus;
	import com.pubnub.subscribe.Subscribe;
	
	import flexunit.framework.Assert;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	import mx.utils.ObjectUtil;
	
	import org.flexunit.async.Async;
	import org.flexunit.async.TestResponder;
	import org.flexunit.token.AsyncTestToken;
	
	public class TestHereNowEncryHTTPS
	{
		public var pn:Pn;
		public var singleChannel:String;
		public var asyncFun:Function;
		
		[Before(async)]
		public function setUp():void
		{
			//make sure the channel label is unque so other listener wont be there
			singleChannel = PrepareTesting.CreateUnqueChannel();
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn, true, true);
			Async.delayCall(this, requestHereNow, 2000);
		}
		
		[After(async)]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test(async, timeout=50000)]
		public function TestHereNowOrder():void
		{
			this.asyncFun = Async.asyncHandler(this, handleIntendedResult,10000, null, handleTimeout);
			pn.addEventListener(PnEvent.HERENOW, asyncFun, false, 0, true);
		}
		
		private function requestHereNow():void
		{
			pn.unsubscribeAll();
			Pn.subscribe(this.singleChannel);	//pn.subscribe(this.singleChannel);
			Async.delayCall(this, fetchHereNow, 1000);
		}
		
		private function fetchHereNow():void
		{
			var args:Object = { };
			args.channel = this.singleChannel;
			args['sub-key'] = pn.subscribeKey;
			Pn.instance.onHereNow(args);
		}
		
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			var messageDataArray:Array = e.data.uuids as Array;
			var occupancy:uint = e.data.occupancy as uint;
			Assert.assertTrue(occupancy > 0);
			Assert.assertTrue(messageDataArray.length > 0);
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("here now timeout");
		}
	}
}