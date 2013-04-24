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
	
	public class TestSubscribeWithTokenEncryHTTPS
	{
		public var pn:Pn;
		public var singleChannel:String = "single_test";
		public var asyncFun:Function;
		public var token:String;
		
		[Before(async)]
		public function setUp():void
		{
			pn = Pn.instance;
			PrepareTesting.PnConfig(pn, true, true);
			Async.delayCall(this, requestSubscribe, 2000);
			
			this.token = (new Date().time*10000).toString();
		}
		
		[After(async)]
		public function tearDown():void
		{
			this.pn.removeEventListener(PnEvent.SUBSCRIBE, asyncFun, false);
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
			this.asyncFun = Async.asyncHandler(this, handleIntendedResult,2000, null, handleTimeout);
			pn.addEventListener(PnEvent.SUBSCRIBE, asyncFun, false, 0, true);
		}
		
		private function requestSubscribe():void
		{
			pn.unsubscribeAll();
			Pn.subscribe(this.singleChannel);		//pn.subscribe(this.singleChannel, this.token);
		}
		
		//todo need check the if last token has been used
		public function handleIntendedResult(e:PnEvent,  passThroughData:Object):void
		{
			var channelArray:Array =  Pn.getSubscribeChannels();
			if (channelArray.length > 0) {
				
				var regString:String = ',' + this.singleChannel + ',';
				var reg:RegExp = new RegExp(regString, "g");
				Assert.assertMatch(reg, ',' + channelArray.join(',') + ',');
			} else {
				Assert.fail("Not the expected result");
			}
		}
		
		public function handleTimeout(passThroughData:Object):void
		{
			Assert.fail("subscribe timeout");
		}
	}
}