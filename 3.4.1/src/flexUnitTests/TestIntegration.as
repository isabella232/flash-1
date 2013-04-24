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

	public class TestIntegration
	{
		public var singleChannel:String = "single_test";
		public var pn:Pn;
		
		public var asyncFun1:Function;
		public var asyncFun2:Function;
		public var asyncFun3:Function;
		public var asyncFun4:Function;
		
		private var messageUnicode:String = "中文";
		private var message1:String = "hello, world";
		private var message2:String = "hello/world/";
		private var message3:String = "中文";
		
		[Before(async)]
		public function setUp():void
		{
			//make sure the channel label is unque so other listener wont be there
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn);
			
			Async.delayCall(this, RequestTest, 500);
		}
		
		[After(async)]
		public function tearDown():void
		{
			//this.pn.removeEventListener(PnEvent.SUBSCRIBE, asyncFun, false);
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test(async, timeout=5000)]
		public function TestTimeToken():void
		{
			pn.time();
			asyncFun1 = Async.asyncHandler(this, handleIntendedResult1, 2000, null, handleTimeout1);
			pn.addEventListener(PnEvent.TIME, asyncFun1, false, 0, true);
		}
		
		[Test(async, timeout=5000)]
		public function TestSubscribeSingle():void
		{
			this.asyncFun2 = Async.asyncHandler(this, handleIntendedResult2,2000, null, handleTimeout2);
			pn.addEventListener(PnEvent.SUBSCRIBE, asyncFun2, false, 0, true);
		}
		
		[Test(async, timeout=5000)]
		public function TestPublishMessage():void
		{
			this.asyncFun3 = Async.asyncHandler(this, handleIntendedResult3,2000, null, handleTimeout3);
			pn.addEventListener(PnEvent.PUBLISH, asyncFun3, false, 0, true);
		}
		
	   [Test(async, timeout=10000)]
		public function TestHistoryInOrder():void
		{
			var args:Object = { };
			args.start = null;
			args.end = null;
			args.count = 10;
			args.reverse = false;
			args.channel = this.singleChannel;
			args['sub-key'] = pn.subscribeKey;
			Pn.instance.detailedHistory(args);
			
			this.asyncFun4 = Async.asyncHandler(this, handleIntendedResult4,5000, null, handleTimeout4);
			pn.addEventListener(PnEvent.DETAILED_HISTORY, asyncFun4, false, 0, true);
		}
		
		private function RequestTest():void
		{
			pn.unsubscribeAll();
			
			Pn.subscribe(this.singleChannel);	
			
			Pn.publish({channel : this.singleChannel, message : message3});
			
		}
		
		public function handleIntendedResult1(e:PnEvent,  passThroughData:Object):void
		{
			Assert.assertTrue(e.data[0] != '');
			/*switch (e.status) {
				case OperationStatus.DATA:
					var resultToken:String = e.data[0];
					var curentDateTime:Date = new Date();
					var currentTimestamp:Number = curentDateTime.time*10000;
					var timeOffSet:Number = Math.abs(currentTimestamp-Number(resultToken));
					Assert.assertTrue(timeOffSet<24*3600*10000);
					break;
				
				case OperationStatus.ERROR:
					Assert.fail("Time() did not return correct value but error out");
					break;
			}*/
		}
		
		public function handleTimeout1(passThroughData:Object):void
		{
			Assert.fail("Time() request timeout");
		}
		
		public function handleIntendedResult2(e:PnEvent,  passThroughData:Object):void
		{
			var channelArray:Array =  Pn.getSubscribeChannels();
			Assert.assertEquals(channelArray.length, 1);
			Assert.assertEquals(channelArray[0], this.singleChannel);
		}
		
		public function handleTimeout2(passThroughData:Object):void
		{
			Assert.fail("subscribe timeout");
		}
		
		public function handleIntendedResult3(e:PnEvent,  passThroughData:Object):void
		{
			Assert.assertTrue(e.data.length > 2);
		}
		
		public function handleTimeout3(passThroughData:Object):void
		{
			Assert.fail("publish timeout");
		}
		
		public function handleIntendedResult4(e:PnEvent,  passThroughData:Object):void
		{
			var messageDataArray:Array = e.data as Array;
			Assert.assertTrue(messageDataArray.length > 0);
		}
		
		public function handleTimeout4(passThroughData:Object):void
		{
			Assert.fail("subscribe timeout");
		}
	}
}