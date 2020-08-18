#include <Timer.h>
#include "nodes.h"
#include <printf.h>

module NodesC {

	uses interface Boot;
	uses interface Timer<TMilli> as Timer1;
	uses interface Timer<TMilli> as Timer2;
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
	uint16_t ackpktid;
	uint16_t nodeidin;
	uint16_t tonodein;
	uint16_t pktidin;
	uint16_t pcktid = 1;
	uint16_t Timer_Value;
	uint16_t datarand;
	uint16_t indata;
	uint16_t pastpktid;
	

//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
		Timer_Value = (call Random.rand16()%5000)+15000;
		datarand = call Random.rand16()%100;
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer1.startPeriodic(Timer_Value);
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
				ndpkt -> data = datarand;
				if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;	
					call Timer2.startPeriodic(1000);
					call Timer1.stop();
					ackpktid = pcktid;
			}
	}
	
	event void Timer2.fired() {				
				NodesMsg* ndpkt = (NodesMsg*)(call Packet.getPayload(&pkt, sizeof (NodesMsg)));
				ndpkt -> nodeid = TOS_NODE_ID;
				ndpkt -> tonode = 8;
				ndpkt -> pckid = pcktid;
				ndpkt -> data = datarand;
				if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(NodesMsg)) == SUCCESS) {
					busy = TRUE;	
			}
	}

//********* Receiving the message ***********

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {		
			if (len == sizeof(NodesInMsg)) {
				NodesInMsg* ndinpkt = (NodesInMsg*)payload;
				tonodein = ndinpkt -> tonodein;
				if (tonodein == TOS_NODE_ID) {
					pktidin = ndinpkt -> pktidin;
					nodeidin = ndinpkt -> nodeidin;
					indata = ndinpkt -> datain;
					if (pktidin != pastpktid) {
						pastpktid = pktidin;
						//printf("Acked packet id: %u\n", ackpktid);
						if (pktidin == ackpktid) {
							call Timer2.stop();
							call Timer1.startPeriodic(Timer_Value);
							pcktid++;
							datarand = call Random.rand16()%100;
						}
					}
				}
			}
				return msg;
	}
	
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
    		busy = FALSE;
    	}
	}

}
