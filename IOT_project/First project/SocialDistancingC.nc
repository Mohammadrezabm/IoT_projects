#include <Timer.h>
#include "SocialDistancing.h"
#include "printf.h"

module SocialDistancingC {

	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t counter = 0;

//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer0.startPeriodic(TIMER_VALUE);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer0.fired() {
		counter++;
		if (!busy) {
			SocialDistancingMsg* sdpkt = (SocialDistancingMsg*)(call Packet.getPayload(&pkt, sizeof (SocialDistancingMsg)));
			sdpkt ->nodeid = TOS_NODE_ID;
			sdpkt ->counter = counter;
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SocialDistancingMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}
	}

//********* Receiving the message ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		if (len == sizeof(SocialDistancingMsg)) {
			SocialDistancingMsg* sdpkt = (SocialDistancingMsg*)payload;
			call Leds.set(sdpkt ->counter);
			printf("Alarm! The violating mote is: %u\n",  sdpkt -> nodeid);
			printfflush();
		}
		return msg;
	}

}
