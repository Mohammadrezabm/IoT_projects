//********* This is the Root node and acts as the sink and take care of the duplicates and sends back ACKs on receiving packets ***********


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

}

implementation {

	bool busy = FALSE;
	message_t pkt;
	uint16_t nodeid;
	uint16_t pktid;
	uint16_t pastnodeid;
	uint16_t pastpktid;
	uint16_t tonode;
	uint16_t usage;
	uint16_t temp;

//********* Booting the devices ***********
	
	event void Boot.booted() {
	
		//Here we try to turn on the radio
		call AMControl.start();
	}

//********* Turning the radio on ***********

	event void AMControl.startDone(error_t err) {
	
		//It checks if the radio was turned on correctly
		if (err == SUCCESS) {
		
		}
		else {
		
			//If the radio was not turned on correctly we try to turn it on again
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}
	
	//This is the acker function that creats a packet to be send as the acknowledgement of the received packet
	task void acker(){
	
			//Creates and start filling the payload of the ACK packet
			RootOutMsg* rtopkt = (RootOutMsg*)(call Packet.getPayload(&pkt, sizeof(RootOutMsg)));
			
			//Sets its own node ID as the Source address of the packet
			rtopkt -> rootid = TOS_NODE_ID;
			
			//Sets the received packet source address as the Destination address of the packet
			rtopkt -> tonoderootout = nodeid;
			
			//Sets the received packet's packet ID as the packet ID of the packet
			rtopkt -> pktidrootout = pktid;
			
			//Sets the data of the payload to zero which can be used to send back data in case needed
			rtopkt -> pktusageout = 0;
			rtopkt -> pkttempout = 0;
			
			//If the radio layer accepts the packet it signals success and then sets the busy flag of the radio to TRUE to reserve it
			if (!busy && call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(RootMsg)) == SUCCESS) {
				busy = TRUE;
				//printf("Acknowledgement of the packet with the ID: %u has successfully been sent to node with destination address: %u.\n", pktid, nodeid);	//Uncomment please to see the debug statement
			}	
	}

//********* Receiving and processing the packet ***********
	//Receives the packet and gets its payload and process it
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
	
		//If the length of the received packet is the same as what we expected we start the processing
		if (len == sizeof(RootMsg)) {
			RootMsg* rtpkt = (RootMsg*)payload;
			
			//Get the Source address of the packet
			nodeid = rtpkt -> nodeidroot;
			
			//Get the Destination address of the packet
			tonode = rtpkt -> tonoderoot;
			
			//Get the packet ID of the packet
			pktid = rtpkt -> pktidroot;
			
			//Gets the data in the packet's payload
			usage = rtpkt -> pktusage;
			temp = rtpkt -> pkttemp;
			
			//Checks if the packet is a duplicate or not if it is the packet is ignored if not the data is sent to upper layers
			if (nodeid != pastnodeid || pktid != pastpktid){
			
				//Saves the node ID and the packet ID of the received packet for checking for duplicates for later use
				pastnodeid = nodeid;
				pastpktid = pktid;
				
				//printf("Packet with the ID: %u from the source address: %u to the destination address: %u with the payload Usage data: %u and Temperature data: %u has been received", pktid, nodeid, tonode, usage, temp);	//Uncomment please to see the debug statement

				
				//Prints the Usage data in the received packet
				printf("\n Usage: %u\n", usage);
				printfflush();
				
				//Prints the Temperature data in the received packet
				printf("\n Temperature: %u\n", temp);
				printfflush();
				
				//Calls the acker function that creates and send the ACK packet back to the Suorce address
				post acker();
			}
		}
			return msg;
	}

//********* Sending the packet ***********
	//If the pakcet is sent correctly the sendDone signals success
	event void AMSend.sendDone(message_t* msg, error_t error) {
	
		//If the packet is the same as buffer it sets the busy flag of the radio to FALSE to release the radio resource
		if (&pkt == msg) {
			busy = FALSE;	
		}

	}
}
