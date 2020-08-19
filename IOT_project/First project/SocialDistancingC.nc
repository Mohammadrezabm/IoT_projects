#include <Timer.h>
#include "SocialDistancing.h"
#include "printf.h"

module SocialDistancingC {

	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t violating_node;
	uint16_t violated_node;
	
	//Creating an array to store the violating node ID in
	uint16_t arr[1000];
	uint16_t counter = 0;

//********* Booting the devices ***********
	
	event void Boot.booted() {
		//We start the radio
		call AMControl.start();
	}

//********* Turning the radio on and in case of success start the timer***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer.startPeriodic(TIMER_VALUE);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Timer fired, creating, and sending the message which contains the node ID ***********
	//Timer is fired every 500 milliseconds
	event void Timer.fired() {
		//If the radio is not busy we create the message and send it
		if (!busy) {
			//Creating the message and filling it's payload
			SocialDistancingMsg* sdpkt = (SocialDistancingMsg*)(call Packet.getPayload(&pkt, sizeof (SocialDistancingMsg)));
			sdpkt -> nodeid = TOS_NODE_ID;
			//If the returned error of send will be success we set the value of the radio to busy to reserve it this means the AM layer has accepted the packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SocialDistancingMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
	//When the sendDone signals success it means the packet is done correctly
	event void AMSend.sendDone(message_t* msg, error_t error) {
		//If the msg is the same as the buffer we set the busy flag to FALSE to release the radio resource
		if (&pkt == msg) {
			busy = FALSE;
			//Turns of the alarm LED so it won't be left on in case of seperation of violating nodes
			call Leds.led0Off();
		}
	}

//********* Receiving the message and triggering the alarm containing the violating node ID ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
		//We check the length of the message to be the same as we expected
		if (len == sizeof(SocialDistancingMsg)) {
			//We get the payload and from it extract the ID of the violating node
			SocialDistancingMsg* sdpkt = (SocialDistancingMsg*)payload;
			//Assign the ID of violating node to violating_node variable
			violating_node = sdpkt -> nodeid;
			//Start switching ON and OFF the red LED of the node as an alarm
			call Leds.led0Toggle();
			//To prevent constant writting in the memory array we check if the ID of the violating node has changed or not
			if (violating_node != violated_node) {
				//Writes the ID of the violating node in its memory
				arr[counter] = violating_node;
				//updates the violated node ID for comparison
				violated_node = violating_node;
				//printf("Memeory write: %u\n", arr[counter]);	//Uncomment to see the writting process in Cooja
				//Goes to the next memory slot
				counter++;
			}
			//Prints the alarm and the ID of the violating node
			printf("Alarm! The violating mote is: %u\n", violating_node);
			//Cleans the screen of the node
			printfflush();
		}
		return msg;
	}
}
