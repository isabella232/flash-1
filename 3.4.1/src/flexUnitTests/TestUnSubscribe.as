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
	
	
	public class TestUnSubscribe
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
			PrepareTesting.PnConfig(pn);
			
			Async.delayCall(this, requestSubscribe, 2000);
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
		public function TestSubscribeSingle():void
		{
			
		}
		
		private function requestSubscribe():void
		{
			pn.unsubscribeAll();
			Pn.subscribe(this.singleChannel + ",aa,bb,cc");		//pn.subscribe(this.singleChannel);
			Async.delayCall(this, requestUnSubscribe, 2000);
		}
		
		private function requestUnSubscribe():void
		{
			var channelsArr:Array = Pn.getSubscribeChannels();
			var regString:String = ',' + this.singleChannel + ',';
			var reg:RegExp = new RegExp(regString, "g");
			Assert.assertMatch(reg, ',' + channelsArr.join(',') + ',');
			Async.delayCall(this, unSubscribeResult, 5000);
			
			/*this.asyncFun = Async.asyncHandler(this, handleIntendedResult,50000, null, handleTimeout);
			pn.addEventListener(PnEvent.SUBSCRIBE, this.asyncFun, false, 0, true);
			pn.unsubscribe(this.singleChannel);*/
		}
		
		private function unSubscribeResult():void {
			var channelsArr:Array = Pn.getSubscribeChannels();
			if (channelsArr.length > 0) {
				var regString:String = ',' + this.singleChannel + ',';
				var reg:RegExp = new RegExp(regString, "g");
				Assert.assertMatch(reg, ',' + channelsArr.join(',') + ',');
			} else {
				Assert.fail("Not the expected result");
			}
		}
		
		/*public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			switch (e.status) 
			{
				case OperationStatus.CONNECT:
					var channelArray:Array =  Pn.getSubscribeChannels();
					Assert.assertEquals(channelArray.length, 1);
					Assert.assertEquals(channelArray[0], this.singleChannel);
					break;
				case OperationStatus.DISCONNECT:
					Assert.assertEquals(e.data.reason, "");
					Assert.assertEquals(e.data.channel,  this.singleChannel);
					break;
			}
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("subscribe timeout");
		}	*/	
	}
}