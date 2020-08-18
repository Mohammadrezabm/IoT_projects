#include <Timer.h>
#include "nodes.h"
#include <printf.h>

module NodesC {

	uses interface Boot;
	uses interface Timer<TMilli> as Timer1;
	uses interface Timer<TMilli> as Timer2;
	uses interface Timer<TMilli> as Timer3;
	uses interface Timer<TMilli> as Timer4;
	uses interface Timer<TMilli> as Timer5;
	uses interface Timer<TMilli> as Timer6;
	uses interface Timer<TMilli> as Timer7;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface PacketAcknowledgements;
	uses interface Random;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t nackpktid;
	uint16_t nodeidin;
	uint16_t tonodein;
	uint16_t pktidin;
	
	uint16_t pcktid1 = 0;
	uint16_t pcktid2 = 0;
	uint16_t pcktid3 = 0;
	uint16_t pcktid4 = 0;
	uint16_t pcktid5 = 0;
	uint16_t pcktid6 = 0;
	uint16_t pcktid7 = 0;

//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer1.startPeriodic(TIMER_VALUE1);
			call Timer2.startPeriodic(TIMER_VALUE2);
			call Timer3.startPeriodic(TIMER_VALUE3);
			call Timer4.startPeriodic(TIMER_VALUE4);
			call Timer5.startPeriodic(TIMER_VALUE5);
			call Timer6.startPeriodic(TIMER_VALUE6);
			call Timer7.startPeriodic(TIMER_VALUE7);

		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer1.fired() {
			if (TOS_NODE_ID == 1) {
				pcktid1++;
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid1;
				if (!busy && call AMSend.send(6, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				
			}
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer2.fired() {
			if (TOS_NODE_ID == 2) {
				pcktid2++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid2;
				if (!busy && call AMSend.send(6, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					printf("I got it: %u\n", TOS_NODE_ID);
					busy = TRUE;
				}
				}
			}
	}
	
	event void Timer3.fired() {
			if (TOS_NODE_ID == 2) {
				pcktid3++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt ->nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid3;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				}
			}
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer4.fired() {
			if (TOS_NODE_ID == 3) {
				pcktid4++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt ->nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid4;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				}
			}
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer5.fired() {
			if (TOS_NODE_ID == 4) {
				pcktid5++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt ->nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid5;
				if (!busy && call AMSend.send(6, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				}
			}
	}

	
	event void Timer6.fired() {
			if (TOS_NODE_ID == 4) {
				pcktid6++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt ->nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid6;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				}
			}
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer7.fired() {
		    if 	(TOS_NODE_ID == 5) {
			    pcktid7++;{
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt ->nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid7;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;
				}
				}
			}
	
	}


//********* Receiving the message ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
	
			
		if (len == sizeof(NodesInMsg)) {
			NodesInMsg* ndinpkt = (NodesInMsg*)payload;
			nodeidin = ndinpkt -> nodeidin;
			tonodein = ndinpkt -> tonodein;
			pktidin = ndinpkt -> pktidin;
			printf("Packet to mote: %u\n", tonodein);
			printf("Packet id: %u\n", pktidin);
			printfflush();
			if (pktidin == nackpktid) {
				call Timer2.stop();
			}
		}
			return msg;
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			pcktid1++;
    		busy = FALSE;
    	}
		
	

	}


}
