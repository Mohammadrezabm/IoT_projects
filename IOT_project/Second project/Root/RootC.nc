#include <Timer.h>
#include "root.h"
#include "printf.h"


module RootC {

	uses interface Boot;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Receive;
	uses interface PacketAcknowledgements;


}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t nodeid;
	uint16_t pktid;
	uint16_t pastnodeid;
	uint16_t pastpktid;
	uint16_t tonode;
	uint16_t data;

//********* Booting the devices ***********
	
	event void Boot.booted() {
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
		
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
	task void acker(){
			RootOutMsg* rtopkt = (RootOutMsg*)(call Packet.getPayload(&pkt, sizeof(RootOutMsg)));
			rtopkt -> rootid = TOS_NODE_ID;
			rtopkt -> tonoderootout = nodeid;
			rtopkt -> pktidrootout = pktid;
			rtopkt -> pktdataout = 0;
			if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RootMsg)) == SUCCESS) {
				busy = TRUE;
			}	
	}
	

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
	
			
		if (len == sizeof(RootMsg)) {
			RootMsg* rtpkt = (RootMsg*)payload;
			nodeid = rtpkt -> nodeidroot;
			tonode = rtpkt -> tonoderoot;
			pktid = rtpkt -> pktidroot;
			data = rtpkt -> pktdata;
			if (nodeid != pastnodeid || pktid != pastpktid){
				pastnodeid = nodeid;
				pastpktid = pktid;
				//printf("From node: %u\n", nodeid);
				//printf("Packet id: %u\n", pktid);
				//printf("Packet data: %u\n", data);
				printf("\n%u\n", data);
				printfflush();
				post acker();
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
