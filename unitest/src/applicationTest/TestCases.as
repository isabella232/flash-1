package applicationTest
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flexunit.framework.Assert;
	
	import org.flexunit.async.Async;
	
	public class TestCases
	{		
		public var  prepTest:TestApplication;
		public var resultFunction:Function;
		
		[Before (async)]
		public function setUp():void
		{
			prepTest = new TestApplication();
			prepTest.initConfig();	
		}
		
		[After (async)]
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
		
		[Test(async, timeout=20000,description="Async testSubscribe")]
		public function testSubscribe():void {
			
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"connect"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.SUBSCRIBE_RESULT,  resultFunction);
			prepTest.subscribe();
		}
		
		protected function handleIntendedResult( event:PubNubEvent,passThroughData:Object ):void {
			if(event.obj is Object){
				Assert.assertEquals(passThroughData.result ,event.obj.result);
			}else if(event.obj is String){
				Assert.assertEquals( passThroughData.result,event.obj);
			}
		}
		
		protected function handleUUIDResult( event:PubNubEvent, passThroughData:Object ):void {
			Assert.assertMatch('not matched to uuid regex', /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/, event.obj);
		}
		
		protected function handleTimeout( passThroughData:Object ):void {
			Assert.fail( "Timeout reached before event"+passThroughData.toString());  
		}
		
		[Test(async, timeout=20000, description="Async publish string")]
		public function testPublishString():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"sent"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.PUBLISH_RESULT,  resultFunction);
			prepTest.publish("Hi from Actionscript");
		}
		
		[Test(async, timeout=20000, description="Async publish JSON")]
		public function testPublishJSON():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"sent"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.PUBLISH_RESULT,  resultFunction);
			prepTest.publish({'message' : 'Hi Hi from Javascript'});
		}
		
		[Test(async, timeout=20000, description="Async publish array")]
		public function testPublishJSONArray():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"sent"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.PUBLISH_RESULT,  resultFunction);
			prepTest.publish(['message' , 'Hi Hi from javascript']);
		}
		
		[Test(async, timeout=60000, description="Async publish string")]
		public function testMultiplePublish():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,60000,{result:true}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.MULTIPLE_PUBLISH_RESULT,  resultFunction);
			prepTest.multiplePublish("sent");
		}
		
		[Test(async, timeout=20000, description="Async time")]
		public function testTime():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"ok"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.TIME_RESULT,  resultFunction);
			prepTest.time();
		}
		
		[Test(async, timeout=35000, description="Async history1")]
		public function testHistory1():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,35000,{result:2}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.HISTORY_RESULT1,  resultFunction);
			prepTest.history();
		}
		
		[Test(async, timeout=35000, description="Async history2")]
		public function testHistory2():void
		{
			var resultCount:int =1;
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,35000,{result:1}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.HISTORY_RESULT2,  resultFunction);
			
			prepTest.history(resultCount);
		}
		
		[Test(async, timeout=20000, description="Async UUID")]
		public function testUUID():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleUUIDResult, 15000, null, handleTimeout);
			prepTest.addEventListener(PubNubEvent.UUID_RESULT,  resultFunction);
			prepTest.uuid();
		}
		
		[Test(async, timeout=20000, description="Async here_now")]
		public function testHereNow():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:1}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.HERE_NOW_RESULT,  resultFunction);
			prepTest.hereNow();
		}
		
		[Test(async, timeout=20000, description="Async set uuid")]
		public function testSetUUID():void
		{
			var testValue:String = "abcd";
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:testValue}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.SET_UUID_RESULT,  resultFunction);
			prepTest.setUUID(testValue);
		}
		
		[Test(async, timeout=20000, description="Async read-write grant with audit")]
		public function testReadWriteGrantAudit():void
		{
			this.resultFunction =  Async.asyncHandler(this, handleIntendedResult,15000,{result:"Success"}, handleTimeout);
			prepTest.addEventListener(PubNubEvent.RW_GRANT_AUDIT_RESULT,  resultFunction);
			prepTest.grantAudit();
		}
	}
}