#include <Timer.h>
#include "nodes.h"
#include <printf.h>

module NodesC {

	uses interface Boot;
	uses interface Timer<TMilli> as Timer1;
	uses interface Timer<TMilli> as Timer2;
	uses interface Timer<TMilli> as Timer3;
	uses interface Timer<TMilli> as Timer4;
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
	uint16_t pcktid = 1;


//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer1.startPeriodic((call Random.rand16()%10000)+3000);
			call Timer3.startPeriodic((call Random.rand16()%10000)+3010);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

//********* Timer fired, creating, and sending the message ***********
	
	event void Timer1.fired() {	
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				if (!busy && call AMSend.send(6, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;	
			}
	}
	
	event void Timer2.fired() {				
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				if (!busy && call AMSend.send(6, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;				
			}
	}
	
	event void Timer3.fired() {	
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;	
			}
	}
	
	event void Timer4.fired() {				
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				if (!busy && call AMSend.send(7, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;				
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
				call Timer4.stop();
			}
		}
			return msg;
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			pcktid++;
    		busy = FALSE;
    		call Timer2.startOneShot(1000);
    		call Timer4.startOneShot(1000);
    		nackpktid = pcktid;
    	}
	}

}
