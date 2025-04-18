package MDSplus;

import org.junit.*;
import java.util.Random;

public class MdsEventTest
{
	class EventReceiver extends MDSplus.Event
	{
		EventReceiver(java.lang.String name) throws Exception
		{
			super(name);
		}

		@Override
		public synchronized void run()
		{
			System.out.println("Event " + getName() + " received");
			eventReceived = true;
		}
	}

	static boolean eventReceived = false;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception
	{}

	@AfterClass
	public static void tearDownAfterClass() throws Exception
	{}

	@Before
	public void setUp() throws Exception
	{}

	@After
	public void tearDown() throws Exception
	{}

	@Test
	public void testData() throws Exception
	{
		java.lang.String eventName = new java.lang.String("MDSEVENTTEST");
		
		final EventReceiver eventRec = new EventReceiver(eventName);
		eventReceived = false;
		MDSplus.Event.setEvent(eventName);
		Thread.sleep(5000);
		Assert.assertEquals("Event not received", eventReceived, true);
		final byte[] rawMsg = "raw message".getBytes();
		eventReceived = false;
		MDSplus.Event.setEventRaw(eventName, rawMsg);
		Thread.sleep(5000);
		Assert.assertEquals("Raw Event not received", eventReceived, true);
		final java.lang.String rawStr = new java.lang.String(eventRec.getRaw());
		Assert.assertEquals("raw message", rawStr);
		final MDSplus.Data dataMsg = new MDSplus.String("data message");
		eventReceived = false;
		MDSplus.Event.setEvent(eventName, dataMsg);
		Thread.sleep(5000);
		Assert.assertEquals("Data Event not received", eventReceived, true);
		Assert.assertEquals("data message", eventRec.getData().getString());
	}
}
